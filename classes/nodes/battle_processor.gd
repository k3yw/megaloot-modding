class_name BattleProcesor extends GameplayComponent

signal character_received_damage(target: Character, attacker: Character, damage_result: DamageResult)
signal turn_completed(turn_type: BattleTurn.Type)

var game_logic_scripts: Array[GameLogicScript] = []
var ability_scripts: Array[AbilityScript] = []


func _init(arg_gameplay_state: GameplayState) -> void :
    set_gameplay_state(arg_gameplay_state)




func kill_heart_of_the_tower(battle: Battle) -> void :
    var selected_heart: Enemy = battle.get_selected_enemy()

    room_screen.interact_button.hide()
    battle_manager.set_turn_in_progress(battle, true)


    var attacks: int = 100
    for idx in attacks:
        var damage_data: DamageData = DamageData.new(DamageData.Source.ATTACK, Stats.PHYSICAL_ATTACK, 0.0)
        damage_data.pure = true
        if idx == attacks - 1:
            damage_data.damage = pow(3.5, 35)
        await try_to_damage_character(selected_heart, null, damage_data)

        var delay: float = 1.0 / ((float(idx) * 0.25) + 1)
        await gameplay_state.get_tree().create_timer(delay).timeout



    battle_manager.set_turn_in_progress(battle, false)
    battle.completed = true




func open_chest(battle: Battle) -> void :
    var damage_data: DamageData = memory.local_player.get_attack_damage_data(DamageData.Source.ATTACK)
    var selected_chest: Enemy = battle.get_selected_enemy()

    room_screen.interact_button.hide()
    battle_manager.set_turn_in_progress(battle, true)
    damage_data.pure = true

    await try_to_damage_character(selected_chest, null, damage_data)
    for player in memory.get_all_players():
        character_manager.add_diamonds(player, player.active_trials.size())

    battle_manager.set_turn_in_progress(battle, false)
    battle.completed = true







func setup_turn(battle: Battle, player: Character, turn_type: BattleTurn.Type) -> void :
    var enemy_characters_in_combat: Array[Character] = battle.get_enemy_characters_in_combat()
    var character_in_combat: Array[Character] = ([player] as Array[Character]) + enemy_characters_in_combat

    for character in character_in_combat:
        var characters_active_item_sets: Array[ItemSetResource] = character.get_active_item_sets()
        var curr_turn: BattleTurn = character.battle_profile.get_curr_turn()
        var characters_passives: Array[Passive] = character.get_passives()

        curr_turn.attack_type = character.get_attack_damage_type()

        for stat in character.cached_stats:
            stat = stat as StatResource

            if is_equal_approx(character.get_stat_amount(stat)[0], 0.0):
                continue

            if not is_instance_valid(stat.stat_script):
                continue

            var game_logic_script: GameLogicScript = await stat.stat_script.new([gameplay_state, self, character]) as GameLogicScript
            game_logic_scripts.push_back(game_logic_script)
            @warning_ignore("redundant_await")
            await game_logic_script.initialize()



        for active_item_set in characters_active_item_sets:
            if not is_instance_valid(active_item_set.game_logic_script):
                continue
            var game_logic_script: GameLogicScript = active_item_set.game_logic_script.new([gameplay_state, self, character]) as GameLogicScript
            game_logic_scripts.push_back(game_logic_script)
            @warning_ignore("redundant_await")
            await game_logic_script.initialize()


        for passive in characters_passives:
            if not is_instance_valid(passive.game_logic_script):
                continue
            var game_logic_script: GameLogicScript = await passive.game_logic_script.new([gameplay_state, self, character]) as GameLogicScript
            game_logic_scripts.push_back(game_logic_script)
            @warning_ignore("redundant_await")
            await game_logic_script.initialize()



        if character.battle_profile.is_stunned():
            continue


        if characters_active_item_sets.has(ItemSets.MAGMA):
            await try_to_apply_status_effect(character, character, StatusEffects.CINDER_ESSENCE)


        for idx in character.inventory.items.size():
            var item: Item = character.inventory.items[idx]
            if not ItemUtils.is_valid(item):
                continue

            if not item.toggled:
                continue


            await try_to_activate(battle, character, Slot.new(character.inventory, idx), turn_type)


        character.battle_profile.consume_stack(StatusEffects.CINDER_ESSENCE, -1)
        character.battle_profile.consume_stack(StatusEffects.MAGIC_BLITZ, -1)
        character.battle_profile.consume_stack(StatusEffects.OMNI_BLITZ, -1)
        character.battle_profile.consume_stack(StatusEffects.VIMBLOW)


    await setup_players_turn(battle, player, turn_type)






func setup_players_turn(battle: Battle, player: Character, turn_type: BattleTurn.Type) -> void :

    var status_effects_to_receive: Array[StatusEffect] = player.get_status_effects_per_turn()
    var original_equipment_data: Dictionary = SaveSystem.get_data(player.equipment)
    var curr_turn: BattleTurn = player.battle_profile.get_curr_turn()
    var turn_size: int = player.get_turn_size()

    SaveSystem.load_data(player.battle_profile.equipment, original_equipment_data)

    if turn_size == 1:
        battle_manager.process_entering_combat(battle, player)

    curr_turn.type = turn_type


    if turn_size == 1:
        status_effects_to_receive += player.get_starting_status_effects()

    for starting_status_effect in status_effects_to_receive:
        await try_to_apply_status_effect(player, player, starting_status_effect.resource, starting_status_effect.amount)




func try_to_activate(battle: Battle, character: Character, slot: Slot, turn_type: BattleTurn.Type) -> bool:
    var item_texture_rect: ItemTextureRect = canvas_layer.get_item_texture_rect(slot)

    if not is_instance_valid(character):
        return false

    var item_to_activate: Item = slot.get_item()

    if not MultiplayerManager.can_activate_item(character, item_to_activate, turn_type):
        return false


    var status_effect: BonusStatusEffect = item_to_activate.resource.activation_effect.status_effect
    var armor_percent_to_restore: int = item_to_activate.resource.activation_effect.armor_percent_to_restore
    var health_percent_to_restore: int = item_to_activate.resource.activation_effect.health_percent_to_restore
    var temp_stats_to_add: Array[BonusStat] = item_to_activate.resource.activation_effect.temp_stats
    var mana_to_regenerate: int = item_to_activate.resource.activation_effect.mana_to_regenerate

    if is_instance_valid(status_effect):
        var new_status_effect_resource: StatusEffectResource = StatusEffects.modify_resource(character, status_effect.resource)
        await try_to_apply_status_effect(character, character, new_status_effect_resource, status_effect.amount)

    if armor_percent_to_restore:
        var amount: float = StatUtils.multiply(character.get_stat_amount(Stats.ARMOR)[0], armor_percent_to_restore)
        character.change_active_armor(amount)

    if mana_to_regenerate:
        character_manager.regen_mana(character, mana_to_regenerate)


    if health_percent_to_restore:
        var amount: float = StatUtils.multiply(character.get_max_health(), health_percent_to_restore)
        amount = minf(character.get_missing_health(), amount)
        if amount <= 0.0:
            return false
        heal(character, amount, false)

    item_to_activate.uses += 1


    for temp_stat_to_add in temp_stats_to_add:
        character_manager.add_temp_stat(character, temp_stat_to_add)


    if not is_instance_valid(item_to_activate.resource.activation_effect.ability):
        character.battle_profile.consumed_potions += 1


    if is_instance_valid(item_texture_rect):
        var tone_event: ToneEventResource = ToneEventResource.new()
        tone_event.tones.push_back(Tone.new(preload("res://assets/sfx/consume_item.wav"), -4.5))
        tone_event.space_type = ToneEventResource.SpaceType._2D
        tone_event.position = item_texture_rect.global_position
        AudioManager.play_event(tone_event, name)


    return true









func make_a_turn(battle: Battle, player: Player, turn_type: BattleTurn.Type) -> void :
    if not is_instance_valid(player):
        print("can't make turn, player is not valid")
        return

    print(self, ": make_a_turn")

    battle.current_turn += 1
    gameplay_state.canvas_layer.battle_log_tab_container.update_new_turn(battle.current_turn)

    battle.battling_player = player
    UIManager.update_partner_containers()

    battle_manager.set_turn_in_progress(battle, true)
    gameplay_state.update_all_ui_requested = true

    await setup_turn(battle, player, turn_type)
    await execute_turn(battle, player, turn_type)




func clear_room(battle: Battle) -> void :
    for idx in 3:
        await remove_from_combat(battle, null, 3)
    battle.completed = true



func heal(character: Character, amount: float, forced: bool = false) -> void :
    var battle: Battle = memory.battle
    if not is_instance_valid(battle):
        return

    var character_active_specializations: Array[Specialization] = character.get_active_specializations()
    var character_active_item_sets: Array[ItemSetResource] = character.get_active_item_sets()
    var character_passives: Array[Passive] = character.get_passives()

    var first_heal: bool = character.battle_profile.get_curr_turn().health_recovered == 0

    if character.died:
        return

    if not forced and character.get_health() == 0:
        return

    if amount <= 0:
        return

    if Character.get_item_set_count(character, ItemSets.ORION) >= 4:
        return

    var new_amount = character.heal(amount)

    if not new_amount:
        return


    var heal_volume: float = -7.5

    if not character == memory.local_player:
        heal_volume = -9.5

    gameplay_state.play_sfx(preload("res://assets/sfx/heal.wav"), heal_volume)


    if first_heal:
        if character_passives.has(Passives.ELDRIDS_FURY):
            await try_to_apply_status_effect(character, null, StatusEffects.VIMBLOW)




    if character_active_specializations.has(Specializations.VAMPIERCER):
        var damage_data = DamageData.new(DamageData.Source.BLOODCASTER, Stats.PHYSICAL_DAMAGE, new_amount)
        damage_data.penetration = 100

        await battle_manager.create_battle_animation_timer(0.25)
        await try_to_damage_character(battle.get_selected_enemy(), character, damage_data)

    if character_active_specializations.has(Specializations.BLOODCASTER):
        var damage_data = DamageData.new(DamageData.Source.BLOODCASTER, Stats.MAGIC_DAMAGE, new_amount)
        await battle_manager.create_battle_animation_timer(0.25)
        await try_to_damage_character(battle.get_selected_enemy(), character, damage_data)

    if character_active_specializations.has(Specializations.VENOMIRE):
        await battle_manager.create_battle_animation_timer(0.25)
        await try_to_apply_status_effect(battle.get_selected_enemy(), character, StatusEffects.POISON, new_amount)


    var battle_log = BattleLogData.new()
    battle_log.heal_target = memory.get_character_reference(character)
    battle_log.amount_healed = new_amount
    gameplay_state.add_to_battle_log(battle, battle_log)


    UIManager.update_selected_player_health_info(character)





func try_to_cleanse(battle: Battle, character: Character) -> Array[StatusEffect]:
    var active_debuffs: Array[StatusEffect] = character.battle_profile.get_active_status_effects(StatusEffectTypes.DEBUFF)
    var active_item_sets: Array[ItemSetResource] = character.get_active_item_sets()
    var cleansed_debuffs: Array[StatusEffect] = []
    var chosen_status_effect: StatusEffect = null

    var curr_turn: BattleTurn = character.battle_profile.get_curr_turn()

    if not active_debuffs.size():
        return cleansed_debuffs

    chosen_status_effect = active_debuffs[RNGManager.pick_random(RNGManager.gameplay_rand, active_debuffs.size())]

    var copied_status_effect: StatusEffect = StatusEffect.new(chosen_status_effect.resource, chosen_status_effect.amount)
    character.battle_profile.remove_matching_status_effects(chosen_status_effect.resource)
    curr_turn.cleansed_debuffs.push_back(copied_status_effect)
    cleansed_debuffs.push_back(copied_status_effect)


    match chosen_status_effect:
        StatusEffects.CONFUSION:
            canvas_layer.room_screen.confused = false


    if cleansed_debuffs.size():
        var cleanse_text: String = T.get_translated_string("CLEANSE").to_upper()
        canvas_layer.room_screen.environment_animation_player.stop()
        canvas_layer.room_screen.environment_animation_player.play("cleanse")


        var battle_log = BattleLogData.new()
        battle_log.cleansed_character = memory.get_character_reference(character)
        battle_log.cleansed_debuffs = cleansed_debuffs
        gameplay_state.add_to_battle_log(battle, battle_log)


        canvas_layer.create_popup_label(PopupLabelData.new(cleanse_text, Color.SKY_BLUE))
        gameplay_state.play_sfx(preload("res://assets/sfx/cleanse.wav"), 4.25)


        if Character.get_item_set_count(character, ItemSets.SILVER) >= 3:
            var faith: float = character.get_stat_amount(Stats.FAITH)[0]
            await try_to_apply_status_effect(character, character, StatusEffects.GRACE, faith)


        character_manager.add_temp_stat(character, BonusStat.new(Stats.FAITH, -25), true)


        for debuff in cleansed_debuffs:
            match debuff.resource:
                StatusEffects.INHERITED_SIN:
                    if not active_item_sets.has(ItemSets.ROYAL):
                        continue

                    await battle_manager.create_battle_animation_timer(0.25)
                    await try_to_apply_status_effect(character, character, StatusEffects.DEBUFF_IMMUNITY, 5)



    UIManager.update_selected_player_health_info(character)
    UIManager.update_player_status_effects(character)
    return cleansed_debuffs










func apply_status_effect_to_random_enemy(battle: Battle, status_effect_resource: StatusEffectResource, amount: int = 1):
    var enemies_to_battle: Array[Enemy] = battle.enemies_to_battle
    var weight_pool: PackedFloat32Array

    for idx in enemies_to_battle.size():
        var enemy: Enemy = enemies_to_battle[idx]
        if not is_instance_valid(enemy):
            continue

        if enemy.out_of_combat:
            weight_pool.push_back(0.0)
            continue

        weight_pool.push_back(1.0)


    while weight_pool.size():
        var chosen_idx: int = RNGManager.gameplay_rand.rand_weighted(weight_pool)
        if chosen_idx == -1:
            return

        var chosen_enemy: Enemy = enemies_to_battle[chosen_idx]
        weight_pool.remove_at(chosen_idx)

        if not is_instance_valid(chosen_enemy):
            continue

        if chosen_enemy.battle_profile.can_receive_status_effect(status_effect_resource):
            await battle_manager.create_battle_animation_timer(0.75)
            if not is_instance_valid(chosen_enemy):
                return
            await try_to_apply_status_effect(chosen_enemy, memory.local_player, status_effect_resource, amount)
            return







func try_to_apply_status_effect(target: Character, applier: Character, status_effect_resource: StatusEffectResource, amount: float = 1.0) -> bool:
    if not is_instance_valid(memory.battle):
        return false

    amount = floorf(amount)

    if amount == 0:
        return false


    var battle: Battle = memory.battle
    var enemy_characters_in_combat: Array[Character] = battle.get_enemy_characters_in_combat()
    var appliers_specializations: Array[Specialization] = []
    var appliers_item_sets: Array[ItemSetResource] = []
    var applied_status_effect: bool = false
    var targets: Array[Character] = [target]

    if not is_instance_valid(status_effect_resource):
        return false

    if status_effect_resource.type == StatusEffectTypes.BUFF:
        if target.battle_profile.has_active_status_effect_resource(StatusEffects.FEAR):
            canvas_layer.create_popup_label(PopupLabelData.new("BUFF FAILED", StatusEffects.FEAR.color))
            return false


    if is_instance_valid(applier):
        appliers_specializations = applier.get_active_specializations()
        appliers_item_sets = applier.get_active_item_sets()

        if appliers_item_sets.has(ItemSets.UNCHAINED) and status_effect_resource.type == StatusEffectTypes.DEBUFF:
            if memory.is_player(applier) and not memory.is_player(target):
                targets = enemy_characters_in_combat


    for target_character in targets:
        if not is_instance_valid(target):
            continue

        var targets_turn: BattleTurn = target.battle_profile.get_curr_turn()
        var target_passives: Array[Passive] = target.get_passives()
        var new_amount: float = amount

        if status_effect_resource.affected_by_tenacity:
            if Math.rand_success(target.get_stat_amount(Stats.TENACITY)[0], RNGManager.gameplay_rand):
                continue

        if status_effect_resource.type == StatusEffectTypes.DEBUFF:
            if target_character.battle_profile.has_active_status_effect_resource(StatusEffects.DEBUFF_IMMUNITY):
                canvas_layer.create_popup_label(PopupLabelData.new("DEBUFF IMMUNE", Color.SKY_BLUE))
                continue


            if Character.get_item_set_count(applier, ItemSets.UNCHAINED) >= 2:
                new_amount *= 2.0


        match status_effect_resource:
            StatusEffects.STUN:
                target.battle_profile.consume_stack(StatusEffects.CLARITY, 1)
                if StatusEffect.get_amount(targets_turn.consumed_stacks, StatusEffects.CLARITY):
                    continue

            StatusEffects.EPHEMERAL_ARMOR:
                if target_character.battle_profile.get_status_effect_amount(StatusEffects.EPHEMERAL_LOCK):
                    continue


        if target_character.try_to_add_status_effect(applier, status_effect_resource, new_amount):
            await Await.emit(target_character.recieved_status_effect, [StatusEffect.new(status_effect_resource, new_amount)])
            applied_status_effect = true

            var battle_log = BattleLogData.new()
            battle_log.applied_status_effect = StatusEffect.new(status_effect_resource, new_amount)
            battle_log.status_effect_applier = memory.get_character_reference(applier)
            battle_log.status_effect_target = memory.get_character_reference(target)
            gameplay_state.add_to_battle_log(battle, battle_log)


        if not applied_status_effect:
            continue



        var targets_curr_turn: BattleTurn = target.battle_profile.get_curr_turn()


        if status_effect_resource == StatusEffects.SILENCE:
            targets_curr_turn.abilities.clear()


        if status_effect_resource == StatusEffects.STUN:
            var stun_turns: int = 2
            if Character.get_item_set_count(applier, ItemSets.THUNDER) >= 3:
                stun_turns = (stun_turns - 1) * 2

            target_character.battle_profile.stun_turns_left += stun_turns

            if appliers_specializations.has(Specializations.THUNDERBORN):
                await attack_character(battle, target, applier, DamageData.Source.ATTACK)


        match status_effect_resource:
















            StatusEffects.EPHEMERAL_ARMOR:
                character_manager.add_temp_stat(target_character, BonusStat.new(Stats.ARMOR, new_amount))


        gameplay_state.play_status_effect(status_effect_resource, new_amount)


        if status_effect_resource.type == StatusEffectTypes.DEBUFF:
            pass


        if target_character == memory.local_player:
            if status_effect_resource == StatusEffects.CONFUSION:
                canvas_layer.room_screen.confused = true

            if status_effect_resource == StatusEffects.STUN:
                room_screen.screen_flash_effect.show_as_stun()
                room_screen.screen_flash_effect.flash()



        if status_effect_resource == StatusEffects.CONFUSION:
            if appliers_specializations.has(Specializations.MINDBREAKER):
                await try_to_apply_status_effect(target_character, applier, StatusEffects.MADNESS, 2)


        UIManager.update_selected_player_health_info(target_character)
        UIManager.update_player_status_effects(target_character)


        await process_applied_status_effect(target_character, applier, status_effect_resource, new_amount)




    return applied_status_effect




func process_applied_status_effect(target: Character, applier: Character, status_effect_resource: StatusEffectResource, amount: float) -> void :
    if not is_instance_valid(memory.battle):
        return

    var battle: Battle = memory.battle
    var appliers_specializations: Array[Specialization] = []
    var appliers_item_sets: Array[ItemSetResource] = []
    var applied_status_effect: bool = false

    if is_instance_valid(applier):
        appliers_specializations = applier.get_active_specializations()
        appliers_item_sets = applier.get_active_item_sets()

    if appliers_item_sets.has(ItemSets.CHROMALURE) and status_effect_resource == StatusEffects.POISON:
        var damage_data: DamageData = DamageData.new(DamageData.Source.CHROMALURE, Stats.POISON_DAMAGE, amount)
        await try_to_damage_character(target, null, damage_data)




func break_magic_shield(target: Character, _breaker: Character) -> void :
    var targets_specializations: Array[Specialization] = target.get_active_specializations()
    await target.break_magic_shield()

    if target == memory.local_player:
        UIManager.update_selected_player_health_info(target)
        canvas_layer.update_armor_info(target)
        UIManager.update_player_status_effects(target)


    if targets_specializations.has(Specializations.INVULNERIUM):
        var toal_magic_shields_broke: int = 0
        for turn in target.battle_profile.get_valid_turns():
            toal_magic_shields_broke += turn.magic_shields_broke_on_self

        if toal_magic_shields_broke == 1:
            await try_to_apply_status_effect(target, target, StatusEffects.INVULNERABILITY)


    if targets_specializations.has(Specializations.STUNIUM):
        for enemy in memory.battle.get_enemy_characters_in_combat():
            await try_to_apply_status_effect(enemy, target, StatusEffects.STUN)












func apply_safeguard(source: Character, targets: Array[Character]) -> void :
    var amount: int = ceili(float(source.get_max_health()) * 0.25)
    source.change_stat_amount(source.stats, Stat.new([Stats.ACTIVE_ARMOR, amount]))
    source.change_stat_amount(source.stats, Stat.new([Stats.ARMOR, amount]))
    targets.erase(source)

    for target in targets:
        target.change_stat_amount(target.stats, Stat.new([Stats.ACTIVE_ARMOR, amount]))
        target.change_stat_amount(target.stats, Stat.new([Stats.ARMOR, amount]))





func process_electro_charges(battle: Battle) -> void :
    if not is_instance_valid(battle):
        return

    var characters_in_combat: Array[Character] = memory.get_characters_in_combat()

    for character in characters_in_combat:
        var electro_charges: float = character.battle_profile.get_status_effect_amount(StatusEffects.ELECTRO_CHARGE)
        if electro_charges:
            var damage_data = DamageData.new(DamageData.Source.ELECTRICITY, Stats.ELECTRIC_DAMAGE, electro_charges)
            await battle_manager.create_battle_animation_timer(0.25)
            if is_instance_valid(damage_data):
                await try_to_damage_character(character, null, damage_data)




func try_to_counter_attack(battle: Battle, counter_attacker: Character, target: Character, source: DamageData.Source) -> void :
    if counter_attacker.battle_profile.is_stunned():
        return

    if source == DamageData.Source.COUNTER_ATTACK:
        return

    if counter_attacker == target:
        return

    var counter_attackers_turn: BattleTurn = counter_attacker.battle_profile.get_curr_turn()
    await battle_manager.create_battle_animation_timer(0.25)

    canvas_layer.create_popup_label(BattleActions.COUNTER_ATTACK.get_action_popup_label_data())
    await attack_character(battle, target, counter_attacker, DamageData.Source.COUNTER_ATTACK)
    counter_attackers_turn.counter_attacks += 1

    if not source == DamageData.Source.VENGEFUL_EDGE:
        await Await.emit(counter_attacker.counter_attacked, [target])




func try_to_backstab(battle: Battle, backstabber: Character, target: Character) -> void :
    if backstabber.battle_profile.is_stunned():
        return

    if backstabber == target:
        return

    var backstabber_turn: BattleTurn = backstabber.battle_profile.get_curr_turn()
    await battle_manager.create_battle_animation_timer(0.25)

    canvas_layer.create_popup_label(BattleActions.BACKSTAB.get_action_popup_label_data())
    await attack_character(battle, target, backstabber, DamageData.Source.BACKSTAB)
    backstabber_turn.backstabs += 1


func try_to_steal(battle: Battle, target: Character, stealer: Character, percent: float) -> void :
    if target.get_active_item_sets().has(ItemSets.POVERTY):
        await battle_manager.create_battle_animation_timer(0.45)
        canvas_layer.create_popup_label(PopupLabelData.new("FAILED STEAL", Color.SANDY_BROWN))
        return


    var steal_text: String = T.get_translated_string("STEAL").to_upper()
    var stolen_gold: int = ceili(float(target.gold_coins) * percent)
    await battle_manager.create_battle_animation_timer(0.45)
    canvas_layer.create_popup_label(PopupLabelData.new(steal_text, Color.GOLD))


    var death_log = BattleLogData.new()
    death_log.stolen_from = memory.get_character_reference(target)
    death_log.stealer = memory.get_character_reference(stealer)
    death_log.stolen_stat = Stats.GOLD
    death_log.amount_stolen = stolen_gold
    gameplay_state.add_to_battle_log(battle, death_log)


    if target == memory.local_player:
        stealer.gold_coins += stolen_gold
        character_manager.pay(Price.new(Stats.GOLD, stolen_gold), false)

    if stealer == memory.local_player:
        target.gold_coins -= stolen_gold
        character_manager.add_gold(stolen_gold)


    await battle_manager.create_battle_animation_timer(0.45)


    if stealer.base_passive == Passives.ESCAPE:
        var escaped_text: String = T.get_translated_string("ESCAPED").to_upper()
        canvas_layer.create_popup_label(PopupLabelData.new(escaped_text, Color.DARK_GOLDENROD))
        await remove_from_combat(battle, null, battle.get_enemy_idx_from_character(stealer))





func try_to_execute(battle: Battle, target: Character, executer: Character) -> void :
    if not is_instance_valid(executer):
        return

    var executers_letahlity: float = executer.get_stat_amount(Stats.LETHALITY)[0]
    if not executers_letahlity > 0:
        return

    if target.get_health_percent() >= executers_letahlity:
        return


    canvas_layer.create_popup_label(PopupLabelData.new("EXECUTED", Color.GRAY))
    var damage_result: DamageResult = memory.create_damage_result(target)
    damage_result.direct_damage = target.get_health()
    damage_result.source = DamageData.Source.LETHALITY
    await directly_damage(damage_result)





func use_abilities(battle: Battle, character: Character, abilities: Array[Ability], cast_types: Array[bool]) -> void :
    var specializations: Array[Specialization] = character.get_active_specializations()
    if not is_instance_valid(battle):
        return

    for idx in range(abilities.size() - 1, -1, -1):
        var ability: Ability = abilities[idx]
        var can_use_ability_result: Character.UseAbilityResult = character_manager.can_use_ability(battle, character, ability.resource)
        var successful_cast: bool = false
        var use_cost: bool = true


        if can_use_ability_result == Character.UseAbilityResult.SUCCESS:
            if cast_types.has(ability.resource.quick_cast):
                successful_cast = true


        if ability.mimicked:
            if can_use_ability_result == Character.UseAbilityResult.MANA:
                successful_cast = true

            use_cost = false


        if not successful_cast:
            continue


        if not memory.is_player(character):
            gameplay_state.play_enemy_ability(battle.get_enemy_idx_from_character(character), ability.resource)

        await activate_ability(battle, character, ability, use_cost)










func activate_ability(battle: Battle, character: Character, ability: Ability, use_cost: bool) -> void :
    var curr_turn: BattleTurn = character.battle_profile.get_curr_turn()
    if not is_instance_valid(battle):
        return

    print("activating ability: ", ability.resource.name)

    var enemy_characters_in_combat: Array[Character] = battle.get_enemy_characters_in_combat()

    if character.battle_profile.free_ability_uses > 0 and ability.resource.mana_cost > 0:
        character.battle_profile.free_ability_uses -= 1
        use_cost = false

    if use_cost:
        await character_manager.use_mana(battle, character, ability.resource.mana_cost)

    curr_turn.abilities.push_back(ability)


    for status_effect in ability.resource.status_effects_on_activation:
        await try_to_apply_status_effect(character, character, status_effect.resource, status_effect.amount)


    if is_instance_valid(ability.resource.ability_script):
        var ability_script: AbilityScript = ability.resource.ability_script.new(gameplay_state, character) as AbilityScript
        ability_scripts.push_back(ability_script)
        await ability_script.activate(self)
        return


    match ability.resource:
        Abilities.FROZEN_WIND:
            var character_to_target: Character = battle.get_selected_enemy()

            if enemy_characters_in_combat.has(character):
                character_to_target = battle.battling_player

            await try_to_apply_status_effect(character_to_target, character, StatusEffects.WEAKNESS)
            await battle_manager.create_battle_animation_timer(0.25)

        Abilities.ASTRAL_DISSOLUTION:
            var character_to_target: Character = battle.get_selected_enemy()

            if enemy_characters_in_combat.has(character):
                character_to_target = battle.battling_player

            character_to_target.battle_profile.remove_buffs()
            await battle_manager.create_battle_animation_timer(0.25)



        Abilities.DROP_OF_CHAOS:
            var character_to_target: Character = battle.get_selected_enemy()
            var debuffs: Array[StatusEffectResource] = StatusEffects.get_debuffs()
            var rand_debuff: StatusEffectResource = debuffs[RNGManager.pick_random(RNGManager.gameplay_rand, debuffs.size())]

            if enemy_characters_in_combat.has(character):
                character_to_target = battle.battling_player

            await try_to_apply_status_effect(character_to_target, character, rand_debuff)


        Abilities.GALEFIRE:
            var character_to_target: Character = battle.get_selected_enemy()

            if enemy_characters_in_combat.has(character):
                character_to_target = battle.battling_player

            if await try_to_apply_status_effect(character_to_target, character, StatusEffects.SLOWNESS):
                await battle_manager.create_battle_animation_timer(0.75)

        Abilities.SAFEGUARD:
            var characters_to_safeguard: Array[Character] = enemy_characters_in_combat

            if not enemy_characters_in_combat.has(character):
                characters_to_safeguard = [character] as Array[Character]


            apply_safeguard(character, characters_to_safeguard)


        Abilities.MULTI_MAGIC_SHIELD:
            var characters_to_magic_shield: Array[Character] = enemy_characters_in_combat

            if not enemy_characters_in_combat.has(character):
                characters_to_magic_shield = [character] as Array[Character]

            for character_to_magic_shield in characters_to_magic_shield:
                await battle_manager.create_battle_animation_timer(0.45)
                character_to_magic_shield.refill_magic_shield()


        Abilities.MULTI_SHIELD:
            var characters_to_shield: Array[Character] = enemy_characters_in_combat

            if not enemy_characters_in_combat.has(character):
                characters_to_shield = [character] as Array[Character]

            for character_to_shield in characters_to_shield:
                var shield_amount: float = character.get_health()
                await battle_manager.create_battle_animation_timer(0.45)
                await try_to_apply_status_effect(character_to_shield, character, StatusEffects.EPHEMERAL_ARMOR, shield_amount)


        Abilities.VENOM_SPIT:
            var character_to_target: Character = battle.get_selected_enemy()

            if enemy_characters_in_combat.has(character):
                character_to_target = battle.battling_player

            if await try_to_apply_status_effect(character_to_target, character, StatusEffects.POISON, character.get_toxicity()):
                await battle_manager.create_battle_animation_timer(0.75)

        Abilities.STEAL:
            var character_to_target: Character = battle.get_selected_enemy()

            if enemy_characters_in_combat.has(character):
                character_to_target = battle.battling_player

            await try_to_steal(battle, character_to_target, character, 0.25)


        Abilities.MULTI_HEAL:
            var characters_to_heal: Array[Character] = enemy_characters_in_combat

            if not enemy_characters_in_combat.has(character):
                characters_to_heal = [character] as Array[Character]

            for character_to_heal in characters_to_heal:
                var ally_max_health: float = character_to_heal.get_max_health()
                var ally_health: float = character_to_heal.get_max_health()

                if ally_max_health == ally_health:
                    continue

                var heal_amount: float = minf(ally_max_health - ally_health, ceilf(ally_max_health * 0.25))
                canvas_layer.create_popup_label(PopupLabelData.new("HEAL", Color.PALE_GREEN))
                await battle_manager.create_battle_animation_timer(0.75)
                heal(character_to_heal, heal_amount)


        Abilities.MULTI_CLEANSE:
            var characters_to_cleanse: Array[Character] = enemy_characters_in_combat

            if not enemy_characters_in_combat.has(character):
                characters_to_cleanse = [character] as Array[Character]

            for character_to_cleanse in characters_to_cleanse:
                var cleansed_debuffs: Array[StatusEffect] = await try_to_cleanse(battle, character_to_cleanse)
                if cleansed_debuffs.size():
                    await battle_manager.create_battle_animation_timer(0.75)




func process_per_turn_effects(battle: Battle) -> void :
    for player in memory.get_alive_players():
        await curse_of_the_tower(player, battle)

    await process_electro_charges(battle)




func process_legacy(battle: Battle) -> void :
    var apply_arthurs_mark: bool = false

    for player in memory.get_all_players():
        if player.get_active_item_sets().has(ItemSets.LEGACY):
            if player.get_turn_size() == 1:
                apply_arthurs_mark = true

    for enemy_character in battle.get_enemy_characters_in_combat():
        if enemy_character.battle_profile.has_active_status_effect_resource(StatusEffects.ARTHURS_MARK):
            apply_arthurs_mark = false
            break

    if not apply_arthurs_mark:
        return

    await apply_status_effect_to_random_enemy(battle, StatusEffects.ARTHURS_MARK)




func process_poison(battle: Battle, character: Character) -> void :
    for enemy in battle.enemies_to_battle:
        if enemy.out_of_combat:
            continue

        await poison(battle, enemy)

    await poison(battle, character)




func poison(battle: Battle, character: Character) -> void :
    var poison_damage: float = character.battle_profile.get_status_effect_amount(StatusEffects.POISON)

    if poison_damage:
        var damage_data = DamageData.new(DamageData.Source.POISON, Stats.POISON_DAMAGE, poison_damage)
        await battle_manager.create_battle_animation_timer(0.25)
        await try_to_damage_character(character, null, damage_data)







func immolate(battle: Battle, source: Character) -> void :
    if source.died:
        return

    if source is Enemy:
        if source.out_of_combat:
            return

    var cinder_damage: float = StatUtils.multiply(source.get_max_health(), 25) + source.get_stat_amount(Stats.CINDER_DAMAGE)[1]
    cinder_damage = StatUtils.modify(cinder_damage, source.get_stat_amount(Stats.CINDER_DAMAGE)[2])

    var targets: Array[Character] = battle.get_enemy_characters_in_combat()

    if is_equal_approx(cinder_damage, 0.0):
        return


    if not memory.is_player(source):
        var enemy_idx: int = battle.get_enemy_idx_from_character(source)
        var enemy_container = canvas_layer.room_screen.get_enemy_container(enemy_idx)

        targets = [battle.battling_player] as Array[Character]

        if is_instance_valid(enemy_container):
            enemy_container.emit_cinder_particles()
            await battle_manager.create_battle_animation_timer(0.25)


    for target in targets:
        var damage_data = DamageData.new(DamageData.Source.CINDER, Stats.CINDER_DAMAGE, cinder_damage)
        await try_to_damage_character(target, source, damage_data)
        await battle_manager.create_battle_animation_timer(0.25)




func curse_of_the_tower(player: Character, battle: Battle) -> void :
    if not player.battle_profile.has_active_status_effect_resource(StatusEffects.CURSE_OF_THE_TOWER):
        return

    var amount: float = player.battle_profile.get_status_effect_amount(StatusEffects.CURSE_OF_THE_TOWER)
    var true_damage: float = ceilf(maxf(player.get_max_health(), player.get_health()) * 0.01 * amount)
    var damage_data = DamageData.new(DamageData.Source.CURSE_OF_THE_TOWER, Stats.TRUE_DAMAGE, true_damage)

    if true_damage:
        await battle_manager.create_battle_animation_timer(0.25)
        await try_to_damage_character(player, null, damage_data)




func polymorph(battle: Battle, idx: int) -> void :
    var enemy_container: EnemyContainer = canvas_layer.room_screen.get_enemy_container(idx)
    var enemy: Enemy = battle.enemies_to_battle[idx]

    if not EnemyUtils.is_valid(enemy):
        return

    if enemy.out_of_combat:
        return

    var enemy_turn: BattleTurn = enemy.battle_profile.get_curr_turn()
    enemy_turn.abilities.clear()

    if is_instance_valid(enemy_container):
        var death_particles_position = canvas_layer.room_screen.battle_viewport.global_position
        death_particles_position += enemy_container.get_death_particles_position()
        canvas_layer.vfx_manager.create_death_particles(death_particles_position)


    var enemy_pool: Array[EnemyResource] = Enemies.get_from_floor(Enemies.LIST, memory.floor_number)
    var rand_idx: int = RNGManager.pick_random(RNGManager.gameplay_rand, enemy_pool.size())
    enemy.resource = enemy_pool[rand_idx]
    enemy.update_all()

    enemy_container.set_texture(enemy.resource.texture)
    UIManager.update_enemy(battle, idx)












func execute_turn(battle: Battle, player: Player, turn_type: BattleTurn.Type) -> void :
    var enemy_characters_in_combat: Array[Character] = battle.get_enemy_characters_in_combat()
    var character_in_combat: Array[Character] = ([player] as Array[Character]) + enemy_characters_in_combat
    var target: Character = battle.get_selected_enemy()
    var players_passive: Array[Passive] = player.get_passives()

    await process_poison(battle, player)



    if player.get_health() == 0:
        battle_manager.set_turn_in_progress(battle, false)
        await complete_turn(battle, player, turn_type)
        return



    if players_passive.has(Passives.ALL_IS_MINE):
        for buff in target.battle_profile.get_active_status_effects(StatusEffectTypes.BUFF):
            await try_to_apply_status_effect(player, player, buff.resource, buff.amount)
        target.battle_profile.remove_buffs()

    if players_passive.has(Passives.EVIL_MARK):
        await try_to_apply_status_effect(target, player, StatusEffects.CURSE)


    for character in character_in_combat:
        for consumed_stacks in character.battle_profile.get_curr_turn().get_consumed_stacks():
            if consumed_stacks.resource == StatusEffects.CINDER_ESSENCE:
                await immolate(battle, character)


    var turn: BattleTurn = player.battle_profile.get_curr_turn()

    for enemy_idx in battle.get_enemies_in_combat_idx():
        var enemy: Enemy = battle.enemies_to_battle[enemy_idx]
        await use_abilities(battle, enemy, [Ability.new(enemy.get_ability())], [true])


    var attacks_self: bool = player.battle_profile.has_active_status_effect_resource(StatusEffects.MADNESS)

    if not player.battle_profile.is_stunned():
        var own_ability: AbilityResource = null
        var abilities: Array[Ability] = []
        var attacking: bool = turn_type == BattleTurn.Type.ATTACK

        for game_logic_script in game_logic_scripts:
            abilities += game_logic_script.get_abilities()


        match turn_type:
            BattleTurn.Type.ABILITY_0: own_ability = player.adventurer.ability
            BattleTurn.Type.ABILITY_1: own_ability = player.learned_abilities[0]
            BattleTurn.Type.ABILITY_2: own_ability = player.learned_abilities[1]


        if is_instance_valid(own_ability):
            abilities.push_back(Ability.new(own_ability))
            attacking = own_ability.to_attack


        if not turn_type == BattleTurn.Type.STANCE:
            await use_abilities(battle, player, abilities, [true, false])

        if attacking:
            await start_player_attack(battle, player, attacks_self)



    await start_enemy_attack_turn(player)

    if player.died:
        battle_manager.set_turn_in_progress(battle, false)
        return

    await complete_turn(battle, player, turn_type)





func get_player_attack_targets(battle: Battle, player: Character, attacks_self: bool) -> Array[Character]:
    var multi_attack: bool = player.battle_profile.has_active_status_effect_resource(StatusEffects.MULTI_ATTACK_CHARGE)
    var selected_enemy: Enemy = battle.get_selected_enemy()
    var attack_targets: Array[Character] = []


    if not selected_enemy.out_of_combat:
        attack_targets.push_back(selected_enemy)

    if multi_attack:
        attack_targets = battle.get_enemy_characters_in_combat()

    if player.get_health() == 0:
        attack_targets.clear()

    if attacks_self:
        attack_targets = [player]


    return attack_targets





func start_player_attack(battle: Battle, player: Character, attacks_self: bool) -> void :
    var attack_targets: Array[Character] = get_player_attack_targets(battle, player, attacks_self)
    var total_attacks: float = player.get_stat_amount(Stats.TOTAL_ATTACKS)[0]
    var turn: BattleTurn = player.battle_profile.get_curr_turn()

    await Await.emit(player.about_to_start_attacking, [attack_targets])


    while total_attacks - turn.attack_cycles > 0.0 and not turn.stopped_attacking:
        if attack_targets.is_empty():
            total_attacks = 0
            break

        for enemy_character in attack_targets:
            await battle_manager.create_battle_animation_timer(0.45)
            await attack_character(battle, enemy_character, player, DamageData.Source.ATTACK)

        total_attacks = player.get_stat_amount(Stats.TOTAL_ATTACKS)[0]
        attack_targets = get_player_attack_targets(battle, player, attacks_self)
        turn.attack_cycles += 1






func start_enemy_attack_turn(player: Character) -> void :
    if not is_instance_valid(memory.battle):
        return
    var battle: Battle = memory.battle

    for enemy_idx in battle.enemies_to_battle.size():
        var enemy: Enemy = battle.enemies_to_battle[enemy_idx]
        if not EnemyUtils.is_valid(enemy):
            continue

        await Await.emit(enemy.about_to_start_attacking, [[player] as Array[Character]])

        var turn: BattleTurn = enemy.battle_profile.get_curr_turn()
        var total_attacks: int = int(enemy.get_stat_amount(Stats.TOTAL_ATTACKS)[0])

        if enemy.battle_profile.has_timeout():
            continue

        if enemy.battle_profile.is_stunned():
            continue

        if enemy.out_of_combat:
            continue

        if should_skip_target(enemy, player):
            continue


        if enemy.battle_profile.has_active_status_effect_resource(StatusEffects.FEAR):
            if player.battle_profile.has_active_status_effect_resource(StatusEffects.DREAD):
                total_attacks = 0
                continue

        await use_abilities(battle, enemy, [Ability.new(enemy.get_ability())], [false])


        while total_attacks - turn.attack_cycles > 0 and not turn.stopped_attacking:
            if enemy.out_of_combat:
                break

            var attacks_self: bool = enemy.battle_profile.has_active_status_effect_resource(StatusEffects.MADNESS)
            var target: Character = player

            if attacks_self:
                target = enemy

            await battle_manager.create_battle_animation_timer(0.45)
            if not is_instance_valid(enemy):
                break

            if should_skip_target(enemy, target):
                break


            await attack_character(battle, target, enemy, DamageData.Source.ATTACK)

            if target.died:
                break

            total_attacks = enemy.get_stat_amount(Stats.TOTAL_ATTACKS)[0]
            turn.attack_cycles += 1


func should_skip_target(attacker: Character, target: Character) -> bool:
    for script in game_logic_scripts:
        if script.get_ignored_targets(attacker).has(target):
            return true
    return false




func directly_damage(damage_result: DamageResult) -> void :
    var attacker: Character = DamageResult.get_ref(damage_result.attacker)
    var target: Character = DamageResult.get_ref(damage_result.target)
    var battle: Battle = memory.battle

    var targets_specializations: Array[Specialization] = target.get_active_specializations()
    var curr_turn: BattleTurn = target.battle_profile.get_curr_turn()
    var atatckers_active_sets: Array[ItemSetResource] = []
    var atatckers_passives: Array[Passive] = []


    damage_result.direct_damage = minf(target.get_health(), damage_result.direct_damage)


    if target.get_turn_size() == 1 and target.get_passives().has(Passives.EDGE_OF_DEATH):
        damage_result.direct_damage = minf(target.get_health() - 1, damage_result.direct_damage)


    if is_instance_valid(attacker):
        await heal(attacker, StatUtils.multiply(damage_result.direct_damage, damage_result.life_steal))
        await Await.emit(attacker.dealt_damage, [damage_result])
        atatckers_active_sets = attacker.get_active_item_sets()
        atatckers_passives = attacker.get_passives()


    if target.battle_profile.has_active_status_effect_resource(StatusEffects.FREEZE):
        if atatckers_active_sets.has(ItemSets.ANCIENT_ICE) and damage_result.damage_type == Stats.FREEZE_DAMAGE:
            await try_to_apply_status_effect(attacker, attacker, StatusEffects.EPHEMERAL_ARMOR, damage_result.uncapped_total_damage)

        if atatckers_passives.has(Passives.MAGICAL_FROSTFLARE) and damage_result.damage_type == Stats.MAGIC_DAMAGE:
            await try_to_apply_status_effect(attacker, attacker, StatusEffects.EPHEMERAL_ARMOR, damage_result.uncapped_total_damage)


    if damage_result.armor_removed:
        target.change_stat_amount(target.stats, Stat.new([Stats.ACTIVE_ARMOR, - damage_result.armor_removed]))
        curr_turn.armor_damage_taken = damage_result.armor_removed

        if target.battle_profile.get_status_effect_amount(StatusEffects.EPHEMERAL_ARMOR):
            await try_to_apply_status_effect(target, null, StatusEffects.EPHEMERAL_LOCK)



    curr_turn.health_damage_taken += damage_result.direct_damage
    target.change_health( - damage_result.direct_damage)


    await Await.emit(character_received_damage, [target, attacker, damage_result])
    await Await.emit(target.received_damage, [damage_result])


    if await try_to_execute(battle, target, attacker):
        return


    if targets_specializations.has(Specializations.BLOODMOON):
        character_manager.add_temp_stat(target, BonusStat.new(Stats.PHYSICAL_ATTACK, damage_result.direct_damage * 2))


    if not target.get_health() == 0:
        return


    if target.battle_profile.has_active_status_effect_resource(StatusEffects.GOLDEN_HEART):
        await battle_manager.create_battle_animation_timer(0.45)

        target.battle_profile.remove_matching_status_effects(StatusEffects.GOLDEN_HEART)

        var amount_to_heal: float = ceilf(target.get_max_health() * 0.25)
        await heal(target, amount_to_heal, true)

        if ItemUtils.get_item_set_count(target.get_equipment_items(), ItemSets.GOLDEN) >= 3:
            await try_to_apply_status_effect(target, target, StatusEffects.INVULNERABILITY)


    if not target.get_health() == 0:
        return

    await kill_character(battle, damage_result)





func kill_character(battle: Battle, damage_result: DamageResult) -> void :
    var attacker: Character = DamageResult.get_ref(damage_result.attacker)
    var target: Character = DamageResult.get_ref(damage_result.target)

    target.set_health(0.0)

    var death_log = BattleLogData.new()
    death_log.killer = memory.get_character_reference(attacker)
    death_log.killed = memory.get_character_reference(target)
    gameplay_state.add_to_battle_log(battle, death_log)


    if not memory.is_player(target):
        var enemy_idx: int = battle.get_enemy_idx_from_character(target)
        if not enemy_idx == -1:
            await remove_from_combat(battle, attacker, enemy_idx)


    if memory.is_player(target):
        if not target.is_phantom:
            await gameplay_state.transform_player_to_phantom(battle, target)
            var characters_to_tick_timeout: Array[Character] = memory.get_characters_in_combat()
            tick_timeout(battle, characters_to_tick_timeout)
            if memory.partners.is_empty():
                call("free")
            return

        if not target == memory.local_player:
            return

        if memory.partners.is_empty():
            gameplay_state.try_to_end_game()
            call("queue_free")
        return


    target.died = true








func attack_character(battle: Battle, target: Character, attacker: Character, source: DamageData.Source) -> void :
    if not is_instance_valid(battle):
        return

    if not is_instance_valid(target):
        return

    var targets_specializations: Array[Specialization] = target.get_active_specializations()
    var attackers_turn: BattleTurn = attacker.battle_profile.get_curr_turn()
    var damage_data: DamageData = attacker.get_attack_damage_data(source)
    var attackers_passives: Array[Passive] = attacker.get_passives()

    var is_crit: bool = attacker.try_to_crit(RNGManager.gameplay_rand, damage_data.type)
    damage_data.accuracy = attacker.get_stat_amount(Stats.ACCURACY)[0]
    damage_data.is_crit = is_crit
    attackers_turn.attacks += 1





    if source == DamageData.Source.BACKSTAB:
        var health_percent: float = target.get_health_percent()
        if health_percent > 75:
            damage_data.apply_multiplier(0.55)

        if health_percent <= 75:
            damage_data.is_crit = true
            damage_data.accuracy += 25


    var target_enemy_idx: int = -1

    if not memory.is_player(attacker):
        if not battle.get_enemy_characters_in_combat().has(attacker):
            return

        var enemy_idx: int = battle.get_enemy_idx_from_character(attacker)
        await room_screen.play_enemy_attack(enemy_idx, 1.0 / battle_manager.battle_speed)


    if not memory.is_player(target):
        if not battle.get_enemy_characters_in_combat().has(target):
            return

        target_enemy_idx = battle.get_enemy_idx_from_character(target)


    var targets_malice: float = target.get_stat_amount(Stats.MALICE)[0]
    if targets_malice:
        var malice_damage_damage_data = DamageData.new(DamageData.Source.MALICE, Stats.MALICE_DAMAGE, targets_malice)

        await try_to_damage_character(attacker, target, malice_damage_damage_data)
        await battle_manager.create_battle_animation_timer(0.16)


    await try_to_damage_character(target, attacker, damage_data)


    var bleed_amount: float = attacker.battle_profile.get_status_effect_amount(StatusEffects.BLEED)
    var bleed_damage: float = ceilf(attacker.get_max_health() * 0.01 * bleed_amount)
    if bleed_damage > 0:
        var bleed_damage_data: DamageData = DamageData.new(DamageData.Source.BLEED, Stats.BLEED_DAMAGE, bleed_damage)
        bleed_damage_data.penetration = 100.0
        bleed_damage_data.unavoidable = true
        await try_to_damage_character(attacker, null, bleed_damage_data)






func process_on_hit(battle: Battle, damage_result: DamageResult, source: DamageData.Source) -> void :
    var attacker: Character = DamageResult.get_ref(damage_result.attacker)
    var target: Character = DamageResult.get_ref(damage_result.target)


    var targets_specializations: Array[Specialization] = target.get_active_specializations()
    var targets_active_item_sets: Array[ItemSetResource] = target.get_active_item_sets()
    var targets_turn: BattleTurn = target.battle_profile.get_curr_turn()
    var targets_passives: Array[Passive] = target.get_passives()


    var attackers_specializations: Array[Specialization] = attacker.get_active_specializations()
    var attackers_active_item_sets: Array[ItemSetResource] = attacker.get_active_item_sets()
    var attackers_turn: BattleTurn = attacker.battle_profile.get_curr_turn()
    var attackers_passives: Array[Passive] = attacker.get_passives()

    var status_effects_on_hit: Array[StatusEffect] = attacker.get_status_effects_on_hit()
    var adjacent_status_effects_on_hit: Array[StatusEffect] = attacker.get_adjacent_status_effects_on_hit()
    var status_effects_to_apply: Array[StatusEffect] = []
    var target_enemy_idx: int = -1


    for ability_script in ability_scripts:
        status_effects_on_hit += ability_script.get_status_effects_on_hit(attacker)

    if not memory.is_player(target):
        if not battle.get_enemy_characters_in_combat().has(target):
            return

        target_enemy_idx = battle.get_enemy_idx_from_character(target)



    if attackers_passives.has(Passives.ABSOLUTION):
        var enemies: Array[Character] = battle.get_enemy_characters_in_combat()
        var rand_idx: int = RNGManager.pick_random(RNGManager.gameplay_rand, enemies.size())
        if rand_idx > -1:
            await battle_manager.create_battle_animation_timer(0.25)
            var absolution_damage_data = DamageData.new(DamageData.Source.PASSIVE, Stats.MAGIC_DAMAGE, 5)
            await try_to_damage_character(enemies[rand_idx], attacker, absolution_damage_data)




    if attackers_passives.has(Passives.THUNDERSTRIKE) and target.battle_profile.has_active_status_effect_resource(StatusEffects.ELECTRO_CHARGE):
        status_effects_on_hit.push_back(StatusEffect.new(StatusEffects.STUN))

    if attacker.battle_profile.has_active_status_effect_resource(StatusEffects.STUN_ATTACK_CHARGE):
        status_effects_on_hit.push_back(StatusEffect.new(StatusEffects.STUN))


    if attackers_specializations.has(Specializations.FAITHBOUND):
        for turn in attacker.battle_profile.get_valid_turns():
            status_effects_on_hit += turn.cleansed_debuffs



    if DamageData.HIT_SOURCES.has(damage_result.source):
        var active_armor_percentage: float = Math.get_percentage(target.get_stat_amount(Stats.ARMOR)[0], target.get_stat_amount(Stats.ACTIVE_ARMOR)[0])
        var armor_to_steal: float = ceilf(target.get_stat_amount(Stats.ACTIVE_ARMOR)[0] * attacker.get_stat_amount(Stats.ARMOR_STEAL)[0] * 0.01)
        armor_to_steal = minf(armor_to_steal, attacker.get_missing_armor())
        var broke_armor: bool = false

        if attacker == target:
            armor_to_steal = 0.0

        if armor_to_steal > 0.0:
            attacker.add_stat(attacker.battle_profile.stats, Stat.new([Stats.ARMOR, armor_to_steal]))
            target.change_stat_amount(target.stats, Stat.new([Stats.ACTIVE_ARMOR, - armor_to_steal]))

            var death_log = BattleLogData.new()
            death_log.stolen_from = memory.get_character_reference(target)
            death_log.stealer = memory.get_character_reference(attacker)
            death_log.stolen_stat = Stats.ARMOR
            death_log.amount_stolen = armor_to_steal
            gameplay_state.add_to_battle_log(battle, death_log)


        if attackers_passives.has(Passives.MANA_STEAL):
            if target.get_mana() > 0:
                attacker.change_mana(1)
                target.change_mana(-1)


        if attackers_passives.has(Passives.FAULT_BREAKER):
            broke_armor = active_armor_percentage <= 75


        if attackers_turn.is_used_ability(Abilities.SHATTER_STRIKE):
            broke_armor = true


        if broke_armor:
            gameplay_state.armor_break(battle, target, attacker)



        if targets_specializations.has(Specializations.CHROMATHORN):
            var poison_amount: float = target.get_stat_amount(Stats.TOXICITY)[0]
            await try_to_apply_status_effect(attacker, target, StatusEffects.POISON, poison_amount)




        if targets_active_item_sets.has(ItemSets.BLACKTHORN):
            var blackthorn_damage: float = StatUtils.multiply(target.get_stat_amount(Stats.ACTIVE_ARMOR)[0], clampf(100 - damage_result.penetration, 0, 100))

            if blackthorn_damage:
                await battle_manager.create_battle_animation_timer(0.25)
                var thorns_damage_damage_data = DamageData.new(DamageData.Source.BLACKTHORN, Stats.MAGIC_DAMAGE, blackthorn_damage)
                await try_to_damage_character(attacker, target, thorns_damage_damage_data)
                await battle_manager.create_battle_animation_timer(0.16)

            if targets_specializations.has(Specializations.MINDTHORN):
                character_manager.add_temp_stat(target, BonusStat.new(Stats.WISDOM, 25, true))

            if targets_specializations.has(Specializations.CINDERTHORN):
                await immolate(battle, target)

            if targets_specializations.has(Specializations.THORNFROST):
                await try_to_apply_status_effect(attacker, target, StatusEffects.WEAKNESS, 2)



        if target.battle_profile.has_active_status_effect_resource(StatusEffects.SPARKLE):
            var sparkle_amount: float = target.battle_profile.get_status_effect_amount(StatusEffects.SPARKLE)

            target.battle_profile.remove_matching_status_effects(StatusEffects.SPARKLE)

            if attackers_active_item_sets.has(ItemSets.JADE):
                status_effects_to_apply.push_back(StatusEffect.new(StatusEffects.SPARKLE, sparkle_amount))

            if sparkle_amount:
                var dazzle_damage_data = DamageData.new(DamageData.Source.DAZZLE, Stats.DAZZLE_DAMAGE, sparkle_amount)
                await try_to_damage_character(target, null, dazzle_damage_data)

            if sparkle_amount:
                await try_to_apply_status_effect(attacker, target, StatusEffects.EPHEMERAL_ARMOR, sparkle_amount)

            gameplay_state.play_sfx(preload("res://assets/sfx/pop_sparkle.wav"))

            await battle_manager.create_battle_animation_timer(0.25)



        if not memory.is_player(target):
            for enemy_character in get_adjacent_enemy_characters_in_combat(target):
                for status_effect in adjacent_status_effects_on_hit:
                    if not is_instance_valid(status_effect):
                        continue
                    await try_to_apply_status_effect(enemy_character, attacker, status_effect.resource, status_effect.amount)


        if attackers_passives.has(Passives.CINDER_TOUCH):
            await immolate(battle, attacker)




    if damage_result.result_type == BattleActions.DODGE:
        if is_instance_valid(attacker):
            if targets_specializations.has(Specializations.EVADIUM):
                await try_to_counter_attack(battle, target, attacker, source)

            if targets_specializations.has(Specializations.NIGHTHRUST):
                var attack_type: StatResource = StatUtils.get_attack_type(damage_result.damage_type)
                if is_instance_valid(attack_type):
                    character_manager.add_temp_stat(target, BonusStat.new(attack_type, damage_result.initial_damage))


    var can_parry: bool = damage_result.result_type == BattleActions.PARRY
    if source == DamageData.Source.COUNTER_ATTACK:
        can_parry = false

    if can_parry and targets_turn.parries < 10:
        await battle_manager.create_battle_animation_timer(0.25)
        targets_turn.parries += 1

        await Await.emit(target.parried, [attacker])

        var damage_data: DamageData = attacker.get_attack_damage_data(DamageData.Source.PARRY)
        if targets_specializations.has(Specializations.BEASTBOUND) and not damage_data.is_crit:
            damage_data.is_crit = target.try_to_crit(RNGManager.gameplay_rand, damage_data.type)

        await try_to_damage_character(attacker, target, damage_data)

        var applied_status_effect: bool = false
        for status_effect in status_effects_on_hit:
            if await try_to_apply_status_effect(attacker, target, status_effect.resource, status_effect.amount):
                applied_status_effect = true

        status_effects_on_hit = []

        if applied_status_effect:
            await battle_manager.create_battle_animation_timer(0.75)


    if damage_result.result_type == BattleActions.DODGE:
        if target.base_passive == Passives.EXPLOITED_OPPORTUNITY:
            await battle_manager.create_battle_animation_timer(0.25)
            await try_to_apply_status_effect(attacker, target, StatusEffects.STUN)



    if target.battle_profile.get_status_effect_amount(StatusEffects.COUNTER_ATTACK_CHARGE):
        await try_to_counter_attack(battle, target, attacker, source)



    if DamageData.HIT_SOURCES.has(damage_result.source) or attackers_passives.has(Passives.CURSED_CHAIN):
        status_effects_to_apply += status_effects_on_hit

    for status_effect in status_effects_to_apply:
        if not is_instance_valid(status_effect):
            continue
        await try_to_apply_status_effect(target, attacker, status_effect.resource, status_effect.amount)





func steal_attack(target: Character, stealer: Character, percent: int) -> void :
    var attack_type: StatResource = target.get_attack_type()
    var amount: float = target.get_stat_amount(attack_type)[0]

    if amount:
        var amount_to_steal: float = StatUtils.multiply(amount, percent)
        stealer.change_stat_amount(stealer.battle_profile.stats, Stat.new([attack_type, amount_to_steal]))
        target.change_stat_amount(target.battle_profile.stats, Stat.new([attack_type, - amount_to_steal]))



func try_to_damage_character(target: Character, attacker: Character, damage_data: DamageData) -> void :
    var battle: Battle = memory.battle
    if not is_instance_valid(battle):
        return

    if not is_instance_valid(target):
        return

    if damage_data.source == DamageData.Source.ATTACK and is_instance_valid(attacker):
        await Await.emit(attacker.about_to_attack, [target, damage_data])

    await Await.emit(target.about_to_receive_damage, [attacker, damage_data])
    if is_instance_valid(attacker):
        await Await.emit(target.about_to_deal_damage, [target, damage_data])


    var damage_result: DamageResult = await calculate_damage_result(battle, target, attacker, damage_data)

    var targets_specializations: Array[Specialization] = target.get_active_specializations()
    var targets_item_sets: Array[ItemSetResource] = target.get_active_item_sets()
    var targets_passives: Array[Passive] = target.get_passives()

    var battling_players_specializations: Array[Specialization] = []
    var attackers_specializations: Array[Specialization] = []
    var battling_players_passives: Array[Passive] = []
    var attackers_passives: Array[Passive] = []




    if is_instance_valid(battle.battling_player):
        battling_players_specializations = battle.battling_player.get_active_specializations()
        battling_players_passives = battle.battling_player.get_passives()

    if is_instance_valid(attacker):
        attackers_specializations = attacker.get_active_specializations()
        attackers_passives = attacker.get_passives()


    gameplay_state.create_damage_popup(battle, damage_result)


    var battle_log = BattleLogData.new()
    battle_log.damage_result = damage_result
    battle_log.source = damage_data.source
    gameplay_state.add_to_battle_log(battle, battle_log)


    if damage_result.result_type == BattleActions.DODGE:
        await process_dodge(battle, target)


    if DamageData.HIT_SOURCES.has(damage_data.source):
        if is_instance_valid(attacker):
            await Await.emit(attacker.attacked, [target])
            await Await.emit(target.got_attacked, [attacker])


        if [BattleActions.MISS, BattleActions.DODGE].has(damage_result.result_type):
            await Await.emit(target.attack_avoided, [attacker, damage_data])

            if targets_passives.has(Passives.ARCANE_CONTROL):
                await break_magic_shield(target, null)
                await target.refill_magic_shield()

            if targets_specializations.has(Specializations.PURSUER):
                character_manager.add_temp_stat(target, BonusStat.new(Stats.LETHALITY, 2))

            if targets_specializations.has(Specializations.STRIKER):
                await try_to_counter_attack(battle, target, attacker, damage_data.source)


        if is_instance_valid(attacker):

            if damage_result.result_type == BattleActions.HIT:
                if is_instance_valid(target):
                    var hit_data: HitData = HitData.new()
                    hit_data.attackers_active_status_effects = attacker.battle_profile.get_active_status_effects()
                    target.battle_profile.get_curr_turn().hits_received.push_back(hit_data)
                await Await.emit(attacker.attack_hit, [target, damage_data])


            await process_on_hit(battle, damage_result, damage_data.source)





    match damage_result.result_type:
        BattleActions.HIT:
            if damage_result.take_damage:
                var adjacent_enemy_characters_in_combat: Array[Character] = get_adjacent_enemy_characters_in_combat(target)

                await directly_damage(damage_result)

                if attackers_specializations.has(Specializations.CHALLENGER):
                    if target.battle_profile.has_active_status_effect_resource(StatusEffects.ARTHURS_MARK):
                        var other_enemies: Array[Character] = battle.get_enemy_characters_in_combat()
                        other_enemies.erase(target)

                        for other_enemy in other_enemies:
                            var damage: float = roundf(damage_result.uncapped_total_damage * 0.45)
                            var spread_damage_data = DamageData.new(damage_data.source, damage_data.type, damage)
                            await try_to_damage_character(other_enemy, attacker, spread_damage_data)


                if damage_data.type == Stats.POISON_DAMAGE and not battle.battling_player == target:
                    if battling_players_passives.has(Passives.TOXSHIELD):
                        var poison_amount: float = battle.battling_player.get_stat_amount(Stats.TOXICITY)[0]
                        await try_to_apply_status_effect(battle.battling_player, battle.battling_player, StatusEffects.EPHEMERAL_ARMOR, poison_amount)


                if attackers_passives.has(Passives.SHATTERWAVE) and damage_data.source == DamageData.Source.ATTACK:
                    for adjacent_enemy in adjacent_enemy_characters_in_combat:
                        var damage: float = roundf(damage_result.uncapped_total_damage * 0.25)
                        var spread_damage_data = DamageData.new(DamageData.Source.SHATTERWAVE, damage_data.type, damage)
                        await try_to_damage_character(adjacent_enemy, attacker, spread_damage_data)


                if Character.get_item_set_count(attacker, ItemSets.ZEPHYRON) >= 2:
                    if damage_data.type == Stats.MAGIC_DAMAGE and not damage_data.source == DamageData.Source.ZEPHYRON:
                        for enemy in battle.get_enemies_in_combat():
                            if not enemy.battle_profile.has_active_status_effect_resource(StatusEffects.SILENCE):
                                continue
                            var silence_damage_data = DamageData.new(DamageData.Source.ZEPHYRON, Stats.MAGIC_DAMAGE, damage_result.uncapped_total_damage)
                            await try_to_damage_character(enemy, attacker, silence_damage_data)



        BattleActions.MISS:
            var attackers_turn: BattleTurn = attacker.battle_profile.get_curr_turn()
            canvas_layer.create_popup_label(BattleActions.MISS.get_action_popup_label_data())

            await Await.emit(attacker.missed)

            attackers_turn.misses += 1

            if attackers_turn.misses >= 10:
                attackers_turn.stopped_attacking = true



    if not target == memory.local_player:
        if is_instance_valid(gameplay_state.last_damage_result):
            gameplay_state.last_damage_result.cleanup()
            gameplay_state.last_damage_result.free()
        gameplay_state.last_damage_result = damage_result
    else:
        if is_instance_valid(gameplay_state.last_local_player_damage_result):
            gameplay_state.last_local_player_damage_result.cleanup()
            gameplay_state.last_local_player_damage_result.free()
        gameplay_state.last_local_player_damage_result = damage_result


    damage_data.free()



func get_adjacent_enemy_characters_in_combat(target: Character) -> Array[Character]:
    var battle: Battle = memory.battle
    if not is_instance_valid(battle):
        return []

    return battle.get_adjacent_enemy_characters_in_combat(target)





func calculate_damage_result(battle: Battle, target: Character, attacker: Character, damage_data: DamageData) -> DamageResult:
    @warning_ignore("unused_variable")
    var damage_result = memory.create_damage_result(target, attacker, damage_data.type)
    damage_result.is_lucky = damage_data.is_lucky
    damage_result.is_crit = damage_data.is_crit
    damage_result.source = damage_data.source

    if not is_instance_valid(target):
        return damage_result


    var targets_turn: BattleTurn = target.battle_profile.get_curr_turn()
    var attackers_active_item_sets: Array[ItemSetResource] = []
    var attackers_specializations: Array[Specialization] = []
    var attackers_turn: BattleTurn = BattleTurn.new()



    var magic_shield_broken: bool = false

    if not target.get_health():
        return damage_result

    var ephemeral_lock_reduction: float = 1.0 - (target.battle_profile.get_status_effect_amount(StatusEffects.EPHEMERAL_LOCK) * 0.12)
    var targets_elemental_resistance: float = target.get_stat_amount(Stats.ELEMENTAL_RESISTANCE)[0]
    var targets_specializations: Array[Specialization] = target.get_active_specializations()
    var targets_active_item_sets: Array[ItemSetResource] = target.get_active_item_sets()
    var targets_toughness: float = target.get_stat_amount(Stats.TOUGHNESS)[0]
    var targets_passives: Array[Passive] = target.get_passives()



    if is_instance_valid(attacker):
        attackers_specializations = attacker.get_active_specializations()
        attackers_active_item_sets = attacker.get_active_item_sets()
        damage_data.penetration += attacker.get_penetration()

        damage_data.activate_damage_boosters(attacker, target)
        attacker.apply_damage_output_boosters(damage_data)
        damage_result.initial_damage = damage_data.damage


        if targets_specializations.has(Specializations.LIONHEART):
            if attacker.battle_profile.has_active_status_effect_resource(StatusEffects.ARTHURS_MARK):
                damage_data.apply_multiplier(0.001)


        if targets_specializations.has(Specializations.HARBINGER):
            if target.battle_profile.has_active_status_effect_resource(StatusEffects.ARTHURS_MARK):
                damage_data.apply_multiplier(1000.0)


        if damage_data.type == Stats.PHYSICAL_DAMAGE or attacker.transformed_stats.has(Stats.OMNI_VAMP):
            damage_result.life_steal = attacker.get_stat_amount(Stats.LIFE_STEAL)[0]

        if damage_data.source == DamageData.Source.BLOODCASTER:
            damage_result.life_steal = 0.0


        if attacker.base_passive == Passives.SHADED_ESSENCE:
            if target.battle_profile.has_active_status_effect_resource(StatusEffects.SILENCE):
                damage_data.apply_multiplier(3.75)


        if not memory.is_player(target) and not memory.partners.is_empty():
            var enemy: Enemy = battle.get_enemy_from_character(target)
            if battle.battling_player.profile_id == enemy.immune_to:
                damage_data.apply_multiplier(battle.get_partner_damage_reduction())



    for game_logic_script in game_logic_scripts:
        if not is_instance_valid(game_logic_script):
            continue
        damage_data.apply_multiplier(game_logic_script.get_damage_multiplier(damage_data.source))


    if target.battle_profile.has_active_status_effect_resource(StatusEffects.FREEZE):
        damage_data.apply_multiplier(1.25)



    for ally in memory.get_allies(target):
        if ally.get_passives().has(Passives.PRIME_GUARD) and not target.get_passives().has(Passives.PRIME_GUARD):
            damage_data.apply_multiplier(0.01)



    var dodged: bool = target.try_to_dodge(RNGManager.gameplay_rand)
    var blocked: bool = target.try_to_block()
    var can_parry: bool = true
    var missed: bool = false


    if damage_data.unavoidable:
        can_parry = false
        dodged = false




    if Stats.PENALTY_DAMAGE.has(damage_data.type):
        damage_data.penetration = 100.0
        can_parry = false
        blocked = false
        dodged = false


    if damage_data.source == DamageData.Source.PARRY:
        can_parry = false


    if damage_data.is_crit and Character.get_item_set_count(attacker, ItemSets.HUNTER) >= 3:
        dodged = false


    if is_instance_valid(attacker):
        attackers_turn = attacker.battle_profile.get_curr_turn()

        missed = not attacker.try_to_hit(target, damage_data.accuracy)



    if missed and damage_data.source == DamageData.Source.ATTACK:
        damage_result.result_type = BattleActions.MISS
        return damage_result


    if dodged:
        damage_result.result_type = BattleActions.DODGE
        return damage_result


    if can_parry and target.try_to_parry():
        damage_result.result_type = BattleActions.PARRY
        return damage_result


    if damage_data.source == DamageData.Source.ATTACK or Character.get_item_set_count(target, ItemSets.ANCIENT_SHELL) >= 1:
        var reduction: float = targets_toughness * 0.01
        damage_data.apply_multiplier(1.0 - reduction)

    if Stats.ELEMENTAL_DAMAGE.has(damage_data.type):
        var reduction: float = targets_elemental_resistance * 0.01
        damage_data.apply_multiplier(1.0 - reduction)


    damage_data.apply_multiplier(ephemeral_lock_reduction)


    if blocked and damage_data.damage > 0.0:
        damage_data.apply_multiplier(0)




    if targets_turn.type == BattleTurn.Type.STANCE:
        damage_data.apply_multiplier(1.0 - target.get_guard_reduction())

    if targets_passives.has(Passives.CRYSTAL_HARDENING) and target.get_turn_size() == 1:
        damage_data.apply_multiplier(0)



    var damge_to_magic_shield: float = 0.0
    if not damage_data.type == Stats.MAGIC_DAMAGE:
        damge_to_magic_shield += damage_data.damage


    if target.has_magic_shield():
        damage_data.apply_multiplier(0)
        if damge_to_magic_shield > 0:
            magic_shield_broken = true


    if target.is_invulnerable():
        damage_data.apply_multiplier(0)



    var damage_to_reduce: float = target.try_to_reduce_damage(damage_data.damage)
    damage_data.damage = maxf(0, damage_data.damage - damage_to_reduce)


    var direct_damage: float = StatUtils.multiply(damage_data.damage, damage_data.penetration)

    var damage_to_armor: float = roundf(damage_data.damage - direct_damage)


    if not damage_to_armor and not direct_damage and damage_data.damage:
        damage_to_armor = maxf(1.0, damage_to_armor)


    damage_result.armor_removed = minf(target.get_stat_amount(Stats.ACTIVE_ARMOR)[0], damage_to_armor)
    direct_damage += damage_to_armor - damage_result.armor_removed


    damage_result.direct_damage = minf(target.get_health(), direct_damage)
    damage_result.penetration = damage_data.penetration

    damage_result.total_damage = damage_result.direct_damage + damage_result.armor_removed
    damage_result.uncapped_total_damage = direct_damage + damage_result.armor_removed


    if targets_active_item_sets.has(ItemSets.CELESTIAL):
        target.add_stat(target.battle_profile.stats, Stat.new([Stats.ELEMENTAL_POWER, damage_result.total_damage]))



    if damage_result.direct_damage:
        if target.battle_profile.get_status_effect_amount(StatusEffects.TOXIC_TRANSMUTE) > 0:
            if not [Stats.POISON_DAMAGE, Stats.BLACKROT_DAMAGE].has(damage_data.type):
                await try_to_apply_status_effect(target, null, StatusEffects.POISON, damage_result.direct_damage)
                damage_result.take_damage = false



    if not memory.is_player(target):
        var enemy_idx: int = battle.get_enemy_idx_from_character(target)
        if not enemy_idx == -1:
            if is_instance_valid(canvas_layer):
                canvas_layer.play_impact(damage_data.type, enemy_idx)
            await room_screen.play_player_attack(enemy_idx, 1.0 / battle_manager.battle_speed)

        gameplay_state.play_attack_sound(enemy_idx, damage_data.is_crit)


    if target == memory.local_player:
        var local_player: Player = memory.local_player

        if damage_result.direct_damage:
            gameplay_state.play_sfx(preload("res://assets/sfx/enemy_attack.wav"), -5)

            if local_player.get_health_percent() <= 45:
                room_screen.screen_flash_effect.play_damage()


    var dmg_label_size: float = 1.0
    if damage_data.is_crit:
        dmg_label_size = 1.45



    if not damage_result.direct_damage:
        gameplay_state.play_sfx(preload("res://assets/sfx/block.wav"))


    if options.screen_shake:
        if damage_result.direct_damage or damage_result.armor_removed:
            room_screen.camera.shake()


    if magic_shield_broken:
        await break_magic_shield(target, attacker)



    for status_effect in damage_data.get_status_effects_on_land():
        await try_to_apply_status_effect(target, attacker, status_effect.resource, status_effect.amount)


    damage_result.result_type = BattleActions.HIT

    return damage_result






func process_dodge(battle: Battle, dodged_character: Character) -> void :
    var dodged_character_turn: BattleTurn = dodged_character.battle_profile.get_curr_turn()
    var total_dodges: int = dodged_character.battle_profile.get_total_dodges() + 1
    var enemy_idx: int = battle.get_enemy_idx_from_character(dodged_character)
    var curr_agility: float = dodged_character.get_stat_amount(Stats.AGILITY)[0]

    gameplay_state.play_sfx(preload("res://assets/sfx/dodge.wav"), 0.25, randf_range(0.95, 1.05))
    character_manager.add_temp_stat(dodged_character, BonusStat.new(Stats.AGILITY, -25), true)

    dodged_character_turn.dodges += 1

    if not enemy_idx == -1:
        room_screen.get_enemy_container(enemy_idx).animation_player.play("enemy_dodge", -1, 1.0 / battle_manager.battle_speed)
        await room_screen.get_enemy_container(enemy_idx).animation_player.animation_finished


    if Character.get_item_set_count(dodged_character, ItemSets.SCOUT) >= 3 and total_dodges % 3 == 0:
        await try_to_apply_status_effect(dodged_character, dodged_character, StatusEffects.ELUSIVE)





func remove_from_combat(battle: Battle, killer: Character, idx: int) -> void :
    if not is_instance_valid(killer) or killer is Enemy:
        killer = battle.battling_player
    killer = killer as Player

    var enemy: Enemy = null

    if battle.enemies_to_battle.size() > idx:
        enemy = battle.enemies_to_battle[idx]

    if not EnemyUtils.is_valid(enemy):
        return

    if is_instance_valid(killer):
        await Await.emit(killer.killed_target, [enemy])

    var enemy_container: EnemyContainer = canvas_layer.room_screen.get_enemy_container(idx)
    var next_enemy: Enemy = battle.next_enemies[idx]
    var gold_reward: float = memory.get_gold_on_kill(memory.local_player, memory.floor_number)


    var gold_to_reward: PackedFloat64Array = []
    var apply_arthurs_mark: bool = false
    var drops: int = 0


    if enemy.out_of_combat:
        return

    enemy.out_of_combat = true


    if is_instance_valid(enemy_container):
        var death_particles_position = canvas_layer.room_screen.battle_viewport.global_position
        death_particles_position += enemy_container.get_death_particles_position()
        canvas_layer.vfx_manager.create_death_particles(death_particles_position)

        enemy_container.set_alpha(0.0)
        for node in enemy_container.nodes_to_hide_on_death:
            node.hide()

        if not is_instance_valid(next_enemy):
            enemy_container.hide()

    if memory.room_type == Rooms.CHEST:
        var chest_gold_reward: float = memory.get_chest_gold_reward()
        gold_to_reward.push_back(chest_gold_reward)
        drops = 1
        if memory.floor_number >= 4:
            drops = 2

        for item in memory.local_player.inventory.get_items():
            if item.resource == Items.RIBBON_OF_FORTUNE:
                if Math.rand_success(25, RNGManager.gameplay_rand):
                    drops += 1

        gold_reward = 0


    if enemy.battle_profile.has_active_status_effect_resource(StatusEffects.ARTHURS_MARK):
        apply_arthurs_mark = true



    if enemy.get_health() <= 0:
        for enemy_character in battle.get_enemy_characters_in_combat():
            if enemy_character.base_passive == Passives.UNDEAD_BLESSING:
                await try_to_apply_status_effect(enemy_character, enemy_character, StatusEffects.PURIFICATION)

        if is_instance_valid(killer):
            var killers_active_specializations: Array[Specialization] = killer.get_active_specializations()
            var killers_turn: BattleTurn = killer.battle_profile.get_curr_turn()
            var killers_passsives: Array[Passive] = killer.get_passives()

            killers_turn.kills += 1

            if killers_passsives.has(Passives.TOXIC_REDEMPTION):
                var poison_amount: float = killer.battle_profile.get_status_effect_amount(StatusEffects.POISON)
                killer.battle_profile.remove_matching_status_effects(StatusEffects.POISON)
                for enemey in battle.get_enemies_in_combat():
                    var damage_data = DamageData.new(DamageData.Source.TOXIC_REDEMPTION, Stats.PHYSICAL_DAMAGE, poison_amount)
                    await try_to_damage_character(enemey, killer, damage_data)

            if Character.get_item_set_count(killer, ItemSets.DARKNESS) >= 3:
                if enemy.battle_profile.has_active_status_effect_resource(StatusEffects.FEAR):
                    await try_to_apply_status_effect(killer, killer, StatusEffects.DREAD, 2)


            for player in memory.get_alive_players():
                if player.get_passives().has(Passives.CONSUMING_DARKNESS):
                    if enemy.battle_profile.has_active_status_effect_resource(StatusEffects.CONFUSION):
                        if enemy.battle_profile.has_active_status_effect_resource(StatusEffects.FEAR):
                            gameplay_state.copy_stats(enemy, player)

            if enemy.get_passives().has(Passives.UNDYING_CURSE):
                await try_to_apply_status_effect(killer, enemy, StatusEffects.CURSE)

            gameplay_state.try_to_drop_loot(killer)


        gold_to_reward.push_back(gold_reward)


        if not enemy.gold_coins == 0:
            gold_to_reward.push_back(enemy.gold_coins)
            enemy.gold_coins = 0


    if memory.local_player.team == memory.get_team_in_battle():
        reward_gold_from_enemy(gold_to_reward, enemy_container)

    await gameplay_state.drop_items(drops)

    await gameplay_state.process_next_enemies(battle, battle_manager.is_instant())

    if apply_arthurs_mark:
        await apply_status_effect_to_random_enemy(battle, StatusEffects.ARTHURS_MARK)





func reward_gold_from_enemy(gold_to_add: PackedFloat64Array, enemy_container: EnemyContainer) -> void :
    for gold in gold_to_add:
        if gold <= 0:
            continue

        await battle_manager.create_battle_animation_timer(0.45)
        if not is_instance_valid(enemy_container):
            continue

        character_manager.add_gold(gold, [false, true])
        var pos: Vector2 = UI.get_rect(enemy_container.selection_rect).get_center()

        canvas_layer.vfx_manager.create_small_popup_label(
            pos + Vector2(randf_range(-15, 15), 
            randf_range(-15, 15)), 
            Format.number(gold, [Format.Rules.USE_PREFIX]), 
            Stats.GOLD.color, 
            Stats.GOLD.icon
            )






func complete_turn(battle: Battle, player: Player, turn_type: BattleTurn.Type) -> void :
    var enemy_characters_in_combat: Array[Character] = battle.get_enemy_characters_in_combat()
    var characters_to_tick_timeout: Array[Character] = memory.get_characters_in_combat()
    var characters_in_combat: Array[Character] = ([player] as Array[Character]) + enemy_characters_in_combat
    var players_item_sets: Array[ItemSetResource] = player.get_active_item_sets()
    var total_turns: int = player.get_turn_size()

    characters_to_tick_timeout.erase(player)
    await Await.emit(turn_completed, [turn_type])

    for character in characters_in_combat:
        var health_to_recover: float = StatUtils.multiply(character.get_recovery(), character.get_missing_health())
        if health_to_recover > 0.0:
            await battle_manager.create_battle_animation_timer(0.25)
            await heal(character, health_to_recover)


    await process_per_turn_effects(battle)
    await process_legacy(battle)


    for character in characters_in_combat:
        var turn: BattleTurn = character.battle_profile.get_curr_turn()

        character.battle_profile.remove_matching_status_effects(StatusEffects.BLEED, 2)

        if turn.is_used_ability(Abilities.MANA_REGEN):
            await battle_manager.create_battle_animation_timer(0.45)
            if not is_instance_valid(character):
                continue
            character_manager.regen_mana(character, character.get_missing_mana())

        var cleansed: bool = turn.is_used_ability(Abilities.PURIFY)
        if character.battle_profile.has_active_status_effect_resource(StatusEffects.PURIFICATION):
            if not cleansed:
                character.battle_profile.remove_matching_status_effects(StatusEffects.PURIFICATION, 1)
            cleansed = true

        if cleansed:
            if await try_to_cleanse(battle, character):
                await battle_manager.create_battle_animation_timer(0.45)

        if character.get_health_percent() > 100:
            character.set_stat_amount(Stats.HEALTH, character.get_max_health())


    player.battle_profile.removed_status_effects = []

    tick_timeout(battle, characters_to_tick_timeout)


    var timeout_amount: int = memory.get_alive_players(player.team).size() - 1
    await try_to_apply_status_effect(player, player, StatusEffects.TIMEOUT, timeout_amount)



    for character in characters_in_combat:
        var status_effects_to_re_apply: Array[StatusEffect] = []

        if enemy_characters_in_combat.has(character):
            if player.get_passives().has(Passives.EMULATOR):
                for debuff in character.battle_profile.get_active_status_effects(StatusEffectTypes.DEBUFF):
                    status_effects_to_re_apply.push_back(StatusEffect.new(debuff.resource, debuff.amount))

            if players_item_sets.has(ItemSets.ANCIENT_ICE):
                await try_to_apply_status_effect(character, player, StatusEffects.FREEZE)


        character.battle_profile.turns.push_back(BattleTurn.new())
        character.battle_profile.waken()

        if memory.is_player(character):
            UIManager.update_player_status_effects(character)

        var enemy_idx: int = battle.get_enemy_idx_from_character(character)
        if enemy_idx > -1:
            UIManager.update_enemy_status_effects(battle, enemy_idx)

        for status_effect_to_re_apply in status_effects_to_re_apply:
            await try_to_apply_status_effect(character, player, status_effect_to_re_apply.resource, status_effect_to_re_apply.amount)

        character.cache_stats()



    if player == memory.local_player:
        canvas_layer.room_screen.confused = player.battle_profile.is_confused()


    for enemy_idx in battle.get_enemies_in_combat_idx():
        gameplay_state.fix_enemy_status_effect_labels(battle, enemy_idx)


    var curse_of_the_tower_turn: int = 21
    if player.get_turn_size() >= curse_of_the_tower_turn:
        player.try_to_add_status_effect(null, StatusEffects.CURSE_OF_THE_TOWER, 5)


    character_manager.actions_blocked = false
    battle_manager.set_turn_in_progress(battle, false)
    battle_manager.try_to_complete_battle(memory.battle)

    gameplay_state.update_all_ui_requested = true


    if Lobby.is_lobby_owner() and memory.partners.size() > 0:
        gameplay_state.sync_state(battle)


    if await gameplay_state.try_to_advance(battle):
        for arg_player in memory.get_all_players():
            arg_player.set_last_battle_items(arg_player.get_equipment_items())
        return

    cleanup()


    battle.turn_time_left = battle.turn_time
    battle.battling_player = null

    UIManager.update_partner_containers()



    await process_stunned_player(battle, player)

    character_manager.try_to_rest()





func tick_timeout(battle: Battle, characters_to_tick_timeout: Array[Character]) -> void :
    for character in characters_to_tick_timeout:
        if not character.battle_profile.has_active_status_effect_resource(StatusEffects.TIMEOUT):
            continue
        character.battle_profile.remove_matching_status_effects(StatusEffects.TIMEOUT, 1)
        if not memory.is_player(character):
            battle_manager.process_entering_combat(battle, character)



func process_stunned_player(battle: Battle, player: Player) -> void :
    var player_to_battle: Player = memory.get_player_to_battle(player.team)
    if not is_instance_valid(player_to_battle):
        return

    if not player_to_battle.battle_profile.is_stunned():
        return

    var has_battle_actions_result: int = battle_manager.has_battle_actions(player_to_battle, -1)
    if has_battle_actions_result == OK:
        await make_a_turn(battle, player_to_battle, BattleTurn.Type.STANCE)




func cleanup() -> void :
    for ability_script in ability_scripts:
        if not is_instance_valid(ability_script):
            continue
        ability_script.free()

    for game_logic_script in game_logic_scripts:
        if not is_instance_valid(game_logic_script):
            continue
        game_logic_script.free()

    game_logic_scripts.clear()
    ability_scripts.clear()
