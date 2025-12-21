class_name CharacterManager extends GameplayComponent



var actions_blocked: bool = false






func add_gold(amount: float, silence: Array[bool] = [false, false]) -> void :
    var local_player: Player = memory.local_player

    if local_player.died:
        return

    if not amount:
        return

    local_player.gold_coins_earned += amount
    local_player.change_gold_coins(amount)

    if not silence[0]:
        gameplay_state.play_sfx(preload("res://assets/sfx/add_gold_coins.wav"), 2.5, randf_range(1.0, 1.05))

    if not silence[1]:
        await get_tree().process_frame
        var popup_label_data = PopupLabelData.new(Format.number(amount, [Format.Rules.USE_PREFIX]), Stats.GOLD.color)
        popup_label_data.right_texture = Stats.GOLD.icon
        canvas_layer.create_popup_label(popup_label_data)



func add_diamonds(player: Player, amount: float, silent: bool = false) -> void :
    if not amount:
        return

    if player.died:
        return

    var new_amount: float = amount * (memory.ascension + 1)
    player.change_diamonds(new_amount)

    if not silent:
        gameplay_state.play_sfx(preload("res://assets/sfx/gain_diamonds.wav"), 7.0, randf_range(1.0, 1.05))
        await get_tree().process_frame
        var popup_label_data = PopupLabelData.new(Format.number(new_amount, [Format.Rules.USE_PREFIX]), Stats.DIAMOND.color)
        popup_label_data.right_texture = Stats.DIAMOND.icon
        canvas_layer.create_popup_label(popup_label_data)




func refill_magic_shield(character: Character) -> void :
    character.refill_magic_shield()

    if character == memory.local_player:
        UIManager.update_selected_player_health_info(character)
        canvas_layer.update_armor_info(character)
        UIManager.update_player_status_effects(character)




func add_stat(character: Character, stat: BonusStat, silent: bool = false) -> void :
    character.add_stat(character.stats, Stat.new([stat]))
    if character == memory.local_player and not silent:
        gameplay_state.create_stat_added_popup(stat)
    try_to_rest()




func add_temp_stat(character: Character, stat: BonusStat, silent: bool = false) -> void :
    var arr_ref: Array[Stat] = character.battle_profile.stats
    character.add_stat(arr_ref, Stat.new([stat]))
    if character == memory.local_player and not silent:
        gameplay_state.create_stat_added_popup(stat)
    try_to_rest()




func pay(price: Price, silent: bool) -> void :
    var amount: float = Math.big_round(price.amount)
    var sfx: AudioStream = preload("res://assets/sfx/pay_gold_coins.wav")
    var volume: float = -5.0

    if not amount:
        return

    match price.type:
        Stats.GOLD:
            memory.local_player.gold_coins_spent += amount
            memory.local_player.gold_coins_earned -= amount
            memory.local_player.change_gold_coins( - amount)

        Stats.DIAMOND:
            sfx = preload("res://assets/sfx/pay_diamonds.wav")
            volume = 7.0
            memory.local_player.change_diamonds( - amount)

    if silent:
        return

    gameplay_state.play_sfx(sfx, volume, randf_range(1.0, 1.05))
    var popup_label_data = PopupLabelData.new(Format.number( - amount, [Format.Rules.USE_PREFIX]), price.type.color)
    popup_label_data.right_texture = price.type.icon
    canvas_layer.create_popup_label(popup_label_data)






func add_loot(item_to_add: Item) -> void :
    var chosen_container: ItemContainer = memory.local_player.loot_stash

    if not memory.local_player.inventory.is_full():
        chosen_container = memory.local_player.inventory

    chosen_container.try_to_add_item(item_to_add)
    gameplay_state.update_item_slots()




func add_item(item_to_add: ItemResource, rarity: int = 0):
    var item: Item = ItemManager.create_item(item_to_add, memory.floor_number, rarity)
    canvas_layer.create_item_received_popup(item)
    add_loot(item)





func drop_item(item: Item, silent = false) -> void :
    if not is_instance_valid(memory.battle):
        return

    if not silent:
        canvas_layer.create_item_received_popup(item)

    add_loot(item)




func try_to_tinker(slot: Slot) -> void :
    var item: Item = slot.get_item()
    if not is_instance_valid(item):
        return

    var price: Price = item.get_tinker_price()
    if not can_pay(price):
        ItemManager.discard_dragged_item()
        return

    ItemManager.dragged_item_slot.remove_item()
    ItemManager.discard_dragged_item()

    gameplay_state.play_sfx(preload("res://assets/sfx/hammer.wav"))


    var tinker_kit_item: bool = not item.can_upgrade() and item.can_convert_into_tinker_kit()
    if item.is_reforge or tinker_kit_item:
        item.convert_to_tinker_kit()
    else:
        item.reforge()

    pay(price, false)
    drop_item(item, true)

    room_screen.get_enemy_container(0).heart_particles.emitting = true






func split_item(slot: Slot) -> void :
    var main_item: Item = slot.get_item()
    gameplay_state.play_sfx(preload("res://assets/sfx/hammer.wav"))
    ItemManager.discard_dragged_item()


    if main_item.reforge_level > 0:
        var reforge_item: Item = Item.new(main_item)
        reforge_item.rarity = ItemRarity.Type.COMMON
        reforge_item.is_reforge = true
        slot.item_container.remove_reforge(slot.index)
        drop_item(reforge_item)
        return

    main_item.decrease_rarity()
    drop_item(Item.new(main_item))




func can_pay(price: Price) -> bool:
    if memory.game_mode == GameModes.PRACTICE:
        return true

    match price.type:
        Stats.DIAMOND: return Math.big_round(Character.get_diamonds(memory.local_player)) >= Math.big_round(price.amount)
        Stats.GOLD: return Math.big_round(Character.get_gold_coins(memory.local_player)) >= Math.big_round(price.amount)

    return false






func use_mana(_battle: Battle, character: Character, amount: int) -> void :
    if not amount:
        return

    character.change_mana( - amount)





func regen_mana(character: Character, amount: int) -> void :
    var new_amount: int = mini(character.get_missing_mana(), amount)
    if not new_amount:
        return

    if character == memory.local_player:
        gameplay_state.play_sfx(preload("res://assets/sfx/gain_mana.wav"), -3.0)
        var popup_label_data = PopupLabelData.new("+" + str(new_amount), Color("#285cc4"))
        popup_label_data.right_texture = preload("res://assets/textures/icons/mana_icon.png")
        canvas_layer.create_popup_label(popup_label_data)

    character.change_mana(new_amount)








func can_swap_equipment(character: Character) -> ItemPressResult.Type:
    if not is_instance_valid(character):
        return ItemPressResult.Type.NULL

    if not is_instance_valid(memory.battle):
        return ItemPressResult.Type.SWAP

    var battle: Battle = memory.battle


    if is_instance_valid(battle):
        if battle.completed:
            return ItemPressResult.Type.SWAP

        if memory.room_type.restless:
            return ItemPressResult.Type.DISABLED

        if battle.turn_in_progress and battle.battling_player == character:
            return ItemPressResult.Type.DISABLED

        if actions_blocked:
            return ItemPressResult.Type.DISABLED


    if not character.is_first_turn():
        return ItemPressResult.Type.DISABLED

    return ItemPressResult.Type.SWAP






func process_stat_effects(battle: Battle) -> void :
    var characters_in_combat: Array[Character] = memory.get_characters_in_combat()

    for character in characters_in_combat:
        var turns: Array[BattleTurn] = character.battle_profile.get_valid_turns()

        var magic_blitz: float = character.get_stat_amount(Stats.SPELLDOM)[0]
        var omni_blitz: float = 0.0

        if character.get_active_item_sets().has(ItemSets.SHADOW):
            omni_blitz = magic_blitz
            magic_blitz = 0.0

        for turn in turns:
            magic_blitz -= StatusEffect.get_amount(turn.consumed_stacks, StatusEffects.MAGIC_BLITZ)
            omni_blitz -= StatusEffect.get_amount(turn.consumed_stacks, StatusEffects.OMNI_BLITZ)

        character.set_status_effect_amount(StatusEffects.MAGIC_BLITZ, magic_blitz)
        character.set_status_effect_amount(StatusEffects.OMNI_BLITZ, omni_blitz)









func can_use_ability(battle: Battle, character: Character, ability: AbilityResource) -> Character.UseAbilityResult:
    var player: Character = memory.local_player
    if is_instance_valid(battle.battling_player):
        player = battle.battling_player

    if not is_instance_valid(ability):
        return Character.UseAbilityResult.FAIL

    if character.battle_profile.has_timeout():
        return Character.UseAbilityResult.FAIL


















    return character.can_use_ability(ability)










func try_to_rest() -> void :
    process_stat_effects(memory.battle)

    if memory.battle.turn_in_progress:
        return

    for player in memory.get_all_players():
        if not can_swap_equipment(player) == ItemPressResult.Type.SWAP:
            continue


        var active_item_sets: Array[ItemSetResource] = player.get_active_item_sets()
        var curr_turn: BattleTurn = player.battle_profile.get_curr_turn()
        var inherited_sin_amount: int = 0
        var golden_heart_amount: int = 0


        for item in player.inventory.get_items():
            item.refill()

        player.cache_stats()


        if active_item_sets.has(ItemSets.GOLDEN) or StatusEffects.has_active_status_effect_resource(curr_turn.received_status_effects, StatusEffects.GOLDEN_HEART):
            golden_heart_amount = 1

        if active_item_sets.has(ItemSets.ROYAL) or StatusEffects.has_active_status_effect_resource(curr_turn.received_status_effects, StatusEffects.INHERITED_SIN):
            inherited_sin_amount = 1


        if Character.get_item_set_count(player, ItemSets.ZEPHYRON) >= 4:
            player.battle_profile.free_ability_uses = 1


        player.set_status_effect_amount(StatusEffects.INHERITED_SIN, inherited_sin_amount)
        player.set_status_effect_amount(StatusEffects.GOLDEN_HEART, golden_heart_amount)


        player.change_mana(player.get_stat_amount(Stats.MAX_MANA)[0])

        player.reset_active_armor()
        player.reset_health()
        player.cache_stats()


    gameplay_state.update_all_ui_requested = true
