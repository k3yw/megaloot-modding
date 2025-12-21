extends Node



var item_time: float = 0.0



func _ready() -> void :
    T.language_changed.connect( func(): update_difficulity_progress_bar())

func _process(delta: float) -> void :
    item_time += delta

func _notification(what: int) -> void :
    match what:
        NOTIFICATION_APPLICATION_FOCUS_OUT:
            UI.minimized = true

        NOTIFICATION_APPLICATION_FOCUS_IN:
            UI.minimized = false




func update_player_portraits(selected_player: Player) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    var adventurer_portrait: AdventurerPortrait = curr_state.canvas_layer.adventurer_portrait
    var partner_idx: int = curr_state.memory.partners.find(selected_player)
    var local_player: Player = curr_state.memory.local_player


    var lobby_player: LobbyPlayer = Lobby.get_player_from_profile_id(selected_player.profile_id)
    if is_instance_valid(lobby_player):
        adventurer_portrait.border_texture_rect.texture = AdventurerBorder.get_texture(AdventurerBorder.get_type(selected_player.adventurer, lobby_player.floor_number))
    adventurer_portrait.set_adventurer(selected_player.adventurer)


    adventurer_portrait.set_as_normal()
    if selected_player.is_phantom:
        adventurer_portrait.set_as_phantom()


    for idx in curr_state.memory.partners.size():
        for partner_container_holder in [curr_state.room_screen.partner_container_holder]:
            var parter_container: PartnerContainer = curr_state.room_screen.partner_container_holder.get_child(idx)
            var partner: Player = curr_state.memory.partners[idx]
            if not is_instance_valid(parter_container):
                continue

            parter_container.adventurer_portrait.set_as_normal()
            if partner.is_phantom:
                parter_container.adventurer_portrait.set_as_phantom()









func update_attack_container() -> void :
    var curr_state: Node = StateManager.get_current_state()

    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    var selected_player: Player = curr_state.get_selected_player()
    var attack_containers: Array[StatContainer] = []
    var main_attack_container: StatContainer = null

    var damage_data: DamageData = selected_player.get_attack_damage_data(DamageData.Source.ATTACK)
    var damage_type: StatResource = StatUtils.get_attack_type(damage_data.type)
    selected_player.apply_damage_output_boosters(damage_data)


    if curr_state.memory.room_type == Rooms.BATTLE:
        var action_container: BattleRoomActionContainer = curr_state.room_processor.action_container as BattleRoomActionContainer

        if is_instance_valid(action_container):
            main_attack_container = action_container.attack_stat_container
            attack_containers.push_back(action_container.attack_stat_container)
            main_attack_container.label.target_value = damage_data.damage

        damage_data.free()


    for attack_container in attack_containers:
        attack_container.texture_rect.texture = damage_type.icon
        attack_container.set_color(0, damage_type.color)
        if selected_player.battle_profile.has_active_status_effect_resource(StatusEffects.WEAKNESS):
            attack_container.set_color(0, Color("5988ff"))







func update_mana_info(character: Character) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var selected_player: Character = curr_state.get_selected_player()
        if not character == selected_player:
            return

        var mana_bar: SmallResourceBar = curr_state.canvas_layer.mana_bar
        var armor: float = character.get_stat_amount(Stats.ARMOR)[0]
        var max_mana: int = character.get_max_mana() * 10
        var mana: int = character.get_mana() * 10

        mana_bar.hide()
        if max_mana:
            mana_bar.show()

        mana_bar.progress_bar.max_value = max_mana

        var mana_parent = curr_state.canvas_layer.resource_bar_holder
        if armor > 0:
            mana_parent = curr_state.canvas_layer.health_bar_holder

        if not mana_bar.get_parent() == mana_parent:
            mana_bar.reparent(mana_parent)


        mana_bar.progress_bar.value = max_mana - mana





func update_gold_coins(character: Character) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    var selected_player: Character = curr_state.get_selected_player()
    if not character == selected_player:
        return

    if curr_state.memory.game_mode == GameModes.PRACTICE:
        curr_state.canvas_layer.gold_coins_container.label.target_value = -1
        return

    curr_state.canvas_layer.gold_coins_container.label.target_value = Character.get_gold_coins(character)



func update_diamonds(character: Character) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    var selected_player: Character = curr_state.get_selected_player()
    if not character == selected_player:
        return

    if curr_state.memory.game_mode == GameModes.PRACTICE:
        curr_state.canvas_layer.diamonds_container.label.target_value = -1
        return

    curr_state.canvas_layer.diamonds_container.label.target_value = Character.get_diamonds(character)





func update_selected_player_health_info(character: Character) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var selected_player: Character = curr_state.get_selected_player()
        if not character == selected_player:
            return
        curr_state.canvas_layer.update_health_info(selected_player)



func update_player_status_effects(character: Character) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    var selected_player: Character = curr_state.get_selected_player()
    if not character == selected_player:
        return
    update_effect_containers(curr_state.canvas_layer.effect_container_holder, character)





func update_effect_containers(effect_container_holder: EffectContainerHolder, character: Character) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState


    var is_player: bool = curr_state.memory.is_player(character)
    var specializations: Array[Specialization] = character.get_active_specializations()
    var item_sets: Array[ItemSetResource] = character.get_active_item_sets()
    var effects: Array = []



    for item_set in item_sets:
        var skip: bool = false
        for specialization in specializations:
            if specialization.original_item_set == item_set:
                skip = true
                break

        if skip:
            continue

        effects.push_back(item_set)


    for specialization in specializations:
        effects.push_back(specialization)


    if item_sets.size() > 0:
        effects.push_back(null)

    for status_effect in character.battle_profile.get_active_status_effects():
        if not is_instance_valid(status_effect):
            continue

        if not is_player or not StatusEffects.IMPACT_HEALTH.has(status_effect.resource):
            effects.push_back(status_effect)


    if curr_state.memory.game_mode == GameModes.PVP:
        for player in curr_state.memory.get_all_players():
            if not player == character:
                continue

            var team_status_effect = StatusEffect.new()
            if player.team == Team.Type.BLUE:
                team_status_effect.resource = StatusEffects.BLUE_TEAM
            if player.team == Team.Type.RED:
                team_status_effect.resource = StatusEffects.RED_TEAM

            effects.push_back(team_status_effect)



    for stat_resource in Stats.MAIN_DISPLAY:
        var amount: float = character.get_stat_amount(stat_resource)[0]
        if is_equal_approx(amount, 0.0):
            continue

        var new_stat_resource: StatResource = stat_resource
        if character.get_active_item_sets().has(ItemSets.SHADOW):
            if stat_resource == Stats.CRIT_CHANCE:
                new_stat_resource = Stats.OMNI_CRIT_CHANCE

        var stat = BonusStat.new(new_stat_resource, amount)
        effects.push_back(stat)

    effect_container_holder.update_effects(effects, character)






func update_difficulity_progress_bar() -> void :
    var curr_state: Node = StateManager.get_current_state()

    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    var total_rooms: int = curr_state.memory.get_room_count()
    var difficulty_progress_bar: DifficultyProgressBar = curr_state.canvas_layer.difficulty_progress_bar
    var room_idx: int = curr_state.memory.room_idx

    difficulty_progress_bar.hover_info_module.data = [
        curr_state.memory.get_gold_on_kill(curr_state.memory.local_player, curr_state.memory.floor_number), 
        total_rooms - (curr_state.memory.room_idx + 1), 
    ]

    var last_floor: int = curr_state.memory.game_mode.last_floor
    if curr_state.memory.is_endless:
        last_floor = -1

    difficulty_progress_bar.set_remaining_rooms(total_rooms - maxi(0, curr_state.memory.room_idx))
    difficulty_progress_bar.set_floor(curr_state.memory.floor_number + 1, last_floor)





func update_turn_label() -> void :
    var curr_state: Node = StateManager.get_current_state()

    if not curr_state is GameplayState:
        return

    curr_state = curr_state as GameplayState

    var turn_label: GenericLabel = curr_state.canvas_layer.room_screen.turn_label
    if not curr_state.memory.room_type == Rooms.BATTLE:
        turn_label.hide()
        return

    turn_label.show()

    var curr_turn: int = maxi(1, curr_state.memory.battle.current_turn)
    var text: String = T.get_translated_string("Current Turn")
    turn_label.set_text_color(GlobalColors.Type.BORDER_COLOR)
    text = text.replace("{turn-number}", str(curr_turn))


    if OptionsManager.options.display_run_time:
        var time: float = curr_state.memory.run_time

        if curr_state.run_time_freeze > 0.0 and not is_equal_approx(0.0, curr_state.run_time_freeze):
            turn_label.set_text_color(GlobalColors.Type.PRIMARY_COLOR)
            time = curr_state.frozen_run_time

        text = Format.time(time) + " | " + text



    turn_label.text = text.to_upper()







func update_enemy(battle: Battle, idx: int) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    var enemy_container: EnemyContainer = curr_state.room_screen.get_enemy_container(idx)

    if not is_instance_valid(enemy_container):
        return

    if curr_state.memory.local_player.died:
        return

    if battle.enemies_to_battle.size() < idx + 1:
        enemy_container.hide()
        return

    var enemy: Enemy = battle.enemies_to_battle[idx]

    if not is_instance_valid(enemy):
        return

    if enemy.out_of_combat and not is_instance_valid(battle.next_enemies[idx]):
        enemy_container.hide()

    enemy_container.stats_container.visible = not enemy.resource.hide_stats

    update_enemy_ability_preview_particles(battle, idx)
    update_enemy_status_effects(battle, idx)
    update_enemy_shield_visuals(battle, idx)
    update_enemy_ice_visuals(battle, idx)
    update_enemy_health_info(battle, idx)
    update_enemy_armor_info(battle, idx)
    update_enemy_mana_info(battle, idx)
    update_enemy_immunity(battle, idx)

    update_next_enemy_flying(battle, idx)
    update_enemy_flying(battle, idx)

    update_enemy_selection(battle, idx)
    update_enemy_elite_glow(battle, idx)








func update_enemy_shield_visuals(battle: Battle, idx: int) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var enemy_container: EnemyContainer = curr_state.room_screen.get_enemy_container(idx)
        var enemy: Enemy = battle.enemies_to_battle[idx]
        var shield_sprite_visible: bool = false

        if enemy.has_magic_shield():
            enemy_container.set_shield_sprite_color(Color("#8ab1ff"))
            shield_sprite_visible = true

        if enemy.is_invulnerable():
            enemy_container.set_shield_sprite_color(Color("#fef3c0"))
            shield_sprite_visible = true

        enemy_container.shield_sprite.visible = shield_sprite_visible





func update_enemy_ice_visuals(battle: Battle, idx: int) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var enemy_container: EnemyContainer = curr_state.room_screen.get_enemy_container(idx)
        var enemy: Enemy = battle.enemies_to_battle[idx]

        enemy_container.target_ice_alpha = 0.0
        if enemy.battle_profile.has_active_status_effect_resource(StatusEffects.FREEZE):
            enemy_container.target_ice_alpha = 1.0




func update_enemy_health_info(battle: Battle, idx: int):
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var active_lethality: float = curr_state.memory.local_player.get_stat_amount(Stats.LETHALITY)[0]
        var enemy_container: EnemyContainer = curr_state.room_screen.get_enemy_container(idx)
        var enemy: Enemy = battle.enemies_to_battle[idx]

        enemy_container.enemy_health_bar.update_as_health(enemy)
        enemy_container.enemy_health_bar.set_target_over(active_lethality)






func update_stats_scroll_container(character: Character, forced: bool = false) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var selected_player: Character = curr_state.get_selected_player()
        if not character == selected_player:
            return

        if not curr_state.canvas_layer.stats_scroll_container.is_visible_in_tree():
            return

        for stat_resource in Stats.DISPLAY:
            update_stat_label(character, stat_resource, forced)



func update_stat_label(character: Character, stat_resource: StatResource, forced: bool = false) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var stat_label_container: StatLabelContiner = curr_state.canvas_layer.get_stat_label_container(stat_resource)
        var stat_amount: Array[float] = character.get_stat_amount(stat_resource)

        stat_label_container.final_value_label.is_percent = stat_resource.is_percentage
        stat_label_container.base_value_label.target_value = stat_amount[1]
        stat_label_container.multiplier_label.target_value = stat_amount[2]
        stat_label_container.final_value_label.target_value = stat_amount[0]

        if forced:
            stat_label_container.base_value_label.set_curr_value(stat_amount[1])
            stat_label_container.multiplier_label.set_curr_value(stat_amount[2])
            stat_label_container.final_value_label.set_curr_value(stat_amount[0])

        var stat_to_update: StatResource = stat_resource
        for transformed_stat in character.transformed_stats:
            if transformed_stat.origin_stat == stat_resource:
                stat_to_update = transformed_stat

        if [Stats.CRIT_CHANCE, Stats.LIFE_STEAL].has(stat_resource):
            stat_label_container.update(stat_to_update)





func update_enemy_armor_info(battle: Battle, idx: int) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var enemy_container: EnemyContainer = curr_state.room_screen.get_enemy_container(idx)
        var enemy: Enemy = battle.enemies_to_battle[idx]
        var active_armor: float = enemy.get_stat_amount(Stats.ACTIVE_ARMOR)[0]
        var armor: float = enemy.get_stat_amount(Stats.ARMOR)[0]

        enemy_container.enemy_armor_bar.visible = armor


        enemy_container.enemy_armor_bar.set_color(Color("#4a5462"))
        if enemy.has_magic_shield():
            enemy_container.enemy_armor_bar.set_color(Color("#8ab1ff"))
            active_armor += 1.0
            armor += 1.0


        enemy_container.enemy_armor_bar.max_amount_label.target_value = armor

        enemy_container.enemy_armor_bar.amount_label.target_value = active_armor
        enemy_container.enemy_armor_bar.set_target_value_under(active_armor)
        enemy_container.enemy_armor_bar.set_target_value(active_armor)
        enemy_container.enemy_armor_bar.set_max_value(armor)





func update_enemy_mana_info(battle: Battle, idx: int):
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var enemy_container: EnemyContainer = curr_state.room_screen.get_enemy_container(idx)
        var enemy: Enemy = battle.enemies_to_battle[idx]

        var max_mana: int = enemy.get_max_mana() * 10
        var mana: int = enemy.get_mana() * 10


        enemy_container.enemy_mana_bar.hide()
        if max_mana:
            enemy_container.enemy_mana_bar.show()


        enemy_container.enemy_mana_bar.progress_bar.max_value = max_mana

        enemy_container.enemy_mana_bar.progress_bar.value = max_mana - mana




func update_enemy_ability_preview_particles(battle: Battle, idx: int) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    var enemy_container: EnemyContainer = curr_state.room_screen.get_enemy_container(idx)
    var enemy: Enemy = battle.enemies_to_battle[idx]
    var curr_turn: BattleTurn = enemy.battle_profile.get_curr_turn()

    enemy_container.stop_ability_preview_particles()

    if not is_instance_valid(curr_turn):
        return

    if not curr_state.character_manager.can_use_ability(battle, enemy, enemy.get_ability()) == Character.UseAbilityResult.SUCCESS:
        return

    if curr_state.memory.room_type == Rooms.ENEMY_UPGRADE:
        return

    enemy_container.start_ability_preview_particles(enemy.get_ability().get_preview_color())





func update_enemy_status_effects(battle: Battle, idx: int) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    var enemy_container: EnemyContainer = curr_state.room_screen.get_enemy_container(idx)
    var enemy: Enemy = battle.enemies_to_battle[idx]
    UIManager.update_effect_containers(enemy_container.effect_container_holder, enemy)





func update_enemy_elite_glow(battle: Battle, idx: int) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var enemy_container: EnemyContainer = curr_state.room_screen.get_enemy_container(idx)
        var material: ShaderMaterial = enemy_container.enemy_texture_rect.material as ShaderMaterial
        var enemy: Enemy = battle.enemies_to_battle[idx]

        material.set_shader_parameter("enabled", enemy.level)


        match enemy.level:
            1:
                material.set_shader_parameter("line_color", Color("#cac8c9"))
                material.set_shader_parameter("hue_tex", preload("res://resources/hues/elite_lvl_1.tres"))
            2:
                material.set_shader_parameter("line_color", Color("#51ff2c"))
                material.set_shader_parameter("hue_tex", preload("res://resources/hues/elite_lvl_2.tres"))
            3:
                material.set_shader_parameter("line_color", Color("#00cbde"))
                material.set_shader_parameter("hue_tex", preload("res://resources/hues/elite_lvl_3.tres"))
            4:
                material.set_shader_parameter("line_color", Color("#db5cd1"))
                material.set_shader_parameter("hue_tex", preload("res://resources/hues/elite_lvl_4.tres"))
            5:
                material.set_shader_parameter("line_color", Color("#efa300"))
                material.set_shader_parameter("hue_tex", preload("res://resources/hues/elite_lvl_5.tres"))
            6:
                material.set_shader_parameter("line_color", Color("#c80038"))
                material.set_shader_parameter("hue_tex", preload("res://resources/hues/elite_lvl_6.tres"))
            7:
                material.set_shader_parameter("line_color", Color("#34000f"))
                material.set_shader_parameter("hue_tex", preload("res://resources/hues/elite_lvl_7.tres"))






func update_enemy_flying(battle, idx: int) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var enemy_container: EnemyContainer = curr_state.room_screen.get_enemy_container(idx)
        var enemy: Enemy = battle.enemies_to_battle[idx]


        if enemy.resource.flying:
            await get_tree().create_timer(idx * 0.1).timeout

            if not is_instance_valid(enemy_container):
                return

            if not enemy_container.animation_player.is_playing():
                enemy_container.animation_player.play("enemy_flying_idle")
            return

        if enemy_container.animation_player.current_animation == "enemy_flying_idle":
            enemy_container.animation_player.stop()






func update_next_enemy_flying(battle, idx: int) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var enemy_container: EnemyContainer = curr_state.room_screen.get_enemy_container(idx)
        var next_enemy: Enemy = battle.next_enemies[idx]

        if not is_instance_valid(next_enemy):
            return

        if next_enemy.resource.flying:
            await get_tree().create_timer(idx * 0.1).timeout

            if not is_instance_valid(enemy_container):
                return

            if not enemy_container.next_enemy_animation_player.is_playing():
                enemy_container.next_enemy_animation_player.play("flying_idle")
            return

        enemy_container.next_enemy_animation_player.stop()





func update_enemy_selection(battle: Battle, idx: int):
    var curr_state: Node = StateManager.get_current_state()

    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState

    var enemy_container: EnemyContainer = curr_state.room_screen.get_enemy_container(idx)

    enemy_container.selection_texture_rect.hide()

    if curr_state.memory.game_mode.team_based:
        if not curr_state.memory.get_team_in_battle() == curr_state.memory.local_player.team:
            return

    if not [Rooms.BATTLE, Rooms.ENEMY_UPGRADE].has(curr_state.memory.room_type):
        return

    if battle.selected_enemy_idx == idx:
        enemy_container.selection_texture_rect.show()









func update_enemy_immunity(battle: Battle, idx: int) -> void :
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var enemy_container: EnemyContainer = curr_state.room_screen.get_enemy_container(idx)
        var enemy: Enemy = battle.enemies_to_battle[idx]
        var type: GlobalColors.Type = GlobalColors.Type.DARKER_BORDER_COLOR

        enemy_container.immunity_texture_rect.visible = enemy.immune_to.length() > 0

        if enemy.immune_to == curr_state.memory.local_player.profile_id:
            type = GlobalColors.Type.ACCENT_COLOR

        (enemy_container.immunity_texture_rect.material as ShaderMaterial).set_shader_parameter("type", int(type))





func update_item_slots() -> void :
    var curr_state: Node = StateManager.get_current_state()

    if curr_state is GameplayState:
        var item_containers: Array[ItemContainer] = curr_state.memory.get_item_containers(curr_state.get_selected_player())
        curr_state.canvas_layer.update_item_slots(item_containers, ItemManager.dragged_item_slot)




func update_partner_containers() -> void :
    var curr_state: Node = StateManager.get_current_state()

    if not curr_state is GameplayState:
        return
    curr_state = curr_state as GameplayState


    var battle: Battle = curr_state.memory.battle

    for idx in curr_state.memory.partners.size():
        for partner_container_holder in [curr_state.room_screen.partner_container_holder]:
            var partner_container: PartnerContainer = partner_container_holder.get_child(idx)
            var partner: Player = curr_state.memory.partners[idx]
            if not is_instance_valid(partner_container):
                continue

            partner_container.show_as_normal()

            if curr_state.memory.partners.size() > 1:
                (partner_container.border_texture_rect.texture as AtlasTexture).region.position.x = (idx + 1) * 38

            if curr_state.memory.game_mode.team_based:
                partner_container.border_texture_rect.texture = Team.get_border(partner.team)


            if partner.battle_profile.has_active_status_effect_resource(StatusEffects.TIMEOUT):
                partner_container.show_as_waiting()

            if battle.battling_player == partner:
                partner_container.show_as_attacking()

            if partner.left_room:
                partner_container.show_as_left()


            if is_instance_valid(ItemManager.dragged_item_slot):
                if is_instance_valid(ItemManager.dragged_item_slot.get_item()):
                    if not curr_state.memory.game_mode.team_based or partner.team == curr_state.memory.local_player.team:
                        partner_container.show_as_to_gift()
