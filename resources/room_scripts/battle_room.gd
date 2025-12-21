extends RoomProcessor

var ability_scripts: Array[AbilityScript] = [null, null, null]


func _ready() -> void :
    super._ready()
    var local_player: Player = memory.local_player
    action_container = action_container as BattleRoomActionContainer

    gameplay_state.pressed_primary_action.connect( func(forced: bool): do_action(forced, BattleTurn.Type.ATTACK))
    action_container.attack_button.pressed.connect( func(): do_action(false, BattleTurn.Type.ATTACK))


    gameplay_state.pressed_base_ability_action.connect( func(forced: bool): do_action(forced, BattleTurn.Type.ABILITY_0))
    action_container.ability_button.pressed.connect( func(): do_action(false, BattleTurn.Type.ABILITY_0))

    gameplay_state.pressed_learned_ability_1_action.connect( func(forced: bool): do_action(forced, BattleTurn.Type.ABILITY_1))
    action_container.learned_ability_buttons[0].pressed.connect( func(): do_action(false, BattleTurn.Type.ABILITY_1))

    gameplay_state.pressed_learned_ability_2_action.connect( func(forced: bool): do_action(forced, BattleTurn.Type.ABILITY_2))
    action_container.learned_ability_buttons[1].pressed.connect( func(): do_action(false, BattleTurn.Type.ABILITY_2))

    local_player.ability_learned.connect(_on_ability_learned)

    gameplay_state.pressed_stance_action.connect( func(forced: bool): do_action(forced, BattleTurn.Type.STANCE))
    action_container.stance_button.pressed.connect( func(): do_action(false, BattleTurn.Type.STANCE))

    ability_scripts[0] = local_player.adventurer.ability.ability_script.new(gameplay_state, local_player) as AbilityScript
    add_child(ability_scripts[0])

    add_learned_ability_scripts()


    for idx in action_container.learned_ability_buttons.size():
        var learned_ability_button: GenericButton = action_container.learned_ability_buttons[idx]
        learned_ability_button.visible = idx < memory.local_player.adventurer.abilities_to_learn_size
        learned_ability_button.disabled = memory.local_player.learned_abilities.size() <= idx
        match idx:
            0:
                if not can_use_ability(BattleTurn.Type.ABILITY_1):
                    learned_ability_button.disabled = true
            1:
                if not can_use_ability(BattleTurn.Type.ABILITY_2):
                    learned_ability_button.disabled = true




func add_learned_ability_scripts() -> void :
    var local_player: Player = memory.local_player

    if local_player.learned_abilities.size() > 0:
        ability_scripts[1] = local_player.learned_abilities[0].ability_script.new(gameplay_state, local_player) as AbilityScript
        add_child(ability_scripts[1])

    if local_player.learned_abilities.size() > 1:
        ability_scripts[2] = local_player.learned_abilities[1].ability_script.new(gameplay_state, local_player) as AbilityScript
        add_child(ability_scripts[2])





func _on_ability_learned(_ability: AbilityResource) -> void :
    add_learned_ability_scripts()
    update_learned_abilities()




func update_learned_abilities() -> void :
    var selected_player: Player = gameplay_state.get_selected_player()

    action_container.ability_button.hover_info_module.hover_info_name = selected_player.adventurer.ability.name
    action_container.ability_button.hover_info_module.use_limit = selected_player.adventurer.ability.use_limit
    action_container.ability_button.icon_texture = selected_player.adventurer.ability.icon

    action_container.ability_button.hover_info_module.data = [selected_player.adventurer.ability, selected_player]
    action_container.attack_button.hover_info_module.data = [selected_player]
    action_container.stance_button.hover_info_module.data = [selected_player]

    for idx in action_container.learned_ability_buttons.size():
        var learned_ability_button: GenericButton = action_container.learned_ability_buttons[idx]
        learned_ability_button.visible = idx < selected_player.adventurer.abilities_to_learn_size
        learned_ability_button.disabled = selected_player.learned_abilities.size() <= idx

        match idx:
            0:
                if not can_use_ability(BattleTurn.Type.ABILITY_1):
                    learned_ability_button.disabled = true
            1:
                if not can_use_ability(BattleTurn.Type.ABILITY_2):
                    learned_ability_button.disabled = true

        learned_ability_button.hover_info_module.bb_container_data_arr = []

        if selected_player.learned_abilities.size() > idx:
            learned_ability_button.hover_info_module.data = [selected_player.learned_abilities[idx], selected_player]
            learned_ability_button.icon_texture = selected_player.learned_abilities[idx].icon
            learned_ability_button.hover_info_module.hover_info_name = selected_player.learned_abilities[idx].name
            learned_ability_button.hover_info_module.use_limit = selected_player.learned_abilities[idx].use_limit
            learned_ability_button.icon_texture = selected_player.learned_abilities[idx].icon
            continue

        var unlearned_text: String = T.get_translated_string("unlearned-ability")
        learned_ability_button.hover_info_module.bb_container_data_arr.push_back(BBContainerData.new(unlearned_text, Color.DIM_GRAY))



func can_use_ability(ability_type: BattleTurn.Type = BattleTurn.Type.ABILITY_0) -> bool:
    var selected_player: Player = gameplay_state.get_selected_player()

    match ability_type:
        BattleTurn.Type.ABILITY_0:
            if not selected_player.can_use_ability(selected_player.adventurer.ability) == Character.UseAbilityResult.SUCCESS or not ability_scripts[0].can_activate():
                return false

        BattleTurn.Type.ABILITY_1:
            if selected_player.learned_abilities.size() < 1:
                return false

            if not is_instance_valid(ability_scripts[1]):
                return false

            if not selected_player.can_use_ability(selected_player.learned_abilities[0]) == Character.UseAbilityResult.SUCCESS or not ability_scripts[1].can_activate():
                return false

        BattleTurn.Type.ABILITY_2:
            if selected_player.learned_abilities.size() < 2:
                return false

            if not is_instance_valid(ability_scripts[2]):
                return false

            if not selected_player.can_use_ability(selected_player.learned_abilities[1]) == Character.UseAbilityResult.SUCCESS or not ability_scripts[2].can_activate():
                return false

    return true




func do_action(_forced: bool, type: BattleTurn.Type) -> void :
    action_container = action_container as BattleRoomActionContainer

    var battle: Battle = memory.battle
    if not is_instance_valid(battle):
        return

    if not battle_manager.has_battle_actions(memory.local_player, battle.initial_selected_enemy_idx) == OK:
        return

    if character_manager.actions_blocked:
        return

    if [BattleTurn.Type.ABILITY_0, BattleTurn.Type.ABILITY_1, BattleTurn.Type.ABILITY_2].has(type) and not can_use_ability(type):
        return

    for action_button in action_container.get_action_buttons():
        action_button.disabled = true

    MultiplayerManager.send_turn(battle, type)




func _process(delta: float) -> void :
    var ability_use_count: int = memory.local_player.battle_profile.get_used_ability_count(memory.local_player.adventurer.ability)
    var battle: Battle = memory.battle

    action_container = action_container as BattleRoomActionContainer

    var attack_action_buttons: Array[GenericButton] = action_container.get_action_buttons()
    for action_button in attack_action_buttons:
        action_button.disabled = true

    action_container = action_container as BattleRoomActionContainer
    action_container.attack_stat_hover_info_module.data = [gameplay_state.get_selected_player()]
    action_container.ability_button.hover_info_module.usage_count = ability_use_count


    if not is_instance_valid(battle):
        return

    super._process(delta)

    if not memory.local_player.team == memory.get_team_in_battle():
        action_container.hide()
        return


    if not is_instance_valid(memory.local_player):
        return

    action_container.stance_button.icon_texture = preload("res://assets/textures/icons/timeout_icon.png")
    if memory.local_player.get_guard_reduction() > 0.0:
        action_container.stance_button.icon_texture = preload("res://assets/textures/icons/guard_icon.png")

    if battle_manager.battle_completed(battle):
        return

    var player_to_battle: Player = memory.get_player_to_battle(memory.local_player.team)

    if is_instance_valid(player_to_battle) and not player_to_battle == memory.local_player:
        return

    if memory.local_player.died:
        return

    if battle.turn_in_progress:
        return

    if character_manager.actions_blocked:
        return

    for action_button in attack_action_buttons:
        action_button.disabled = false

    if not can_use_ability():
        action_container.ability_button.disabled = true

    update_learned_abilities()

    if not memory.local_player == gameplay_state.get_selected_player():
        for action_button in attack_action_buttons:
            action_button.disabled = true
