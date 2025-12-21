class_name BattleManager extends GameplayComponent

enum BattleActionFailResult{OK, MP_PHANTOM = 4}

var battle_speed: float = 1.0



func _process(delta: float) -> void :
    process_turn_timer(delta)


func process_turn_timer(delta: float) -> void :
    if not is_instance_valid(memory.battle):
        return

    if not memory.is_turn_timer_active():
        return

    var room_type: RoomResource = memory.room_type

    if room_type == Rooms.ENTRANCE:
        return


    if memory.battle.turn_in_progress or memory.battle.setup_in_progress:
        memory.battle.turn_time_left = memory.battle.turn_time
        return

    if memory.battle.turn_time_left > 0.0:
        memory.battle.turn_time_left = maxf(0.0, memory.battle.turn_time_left - delta)


    if memory.battle.turn_time_left == 0.0:
        if memory.local_player.active_trials.has(Trials.SAGACITY):
            MultiplayerManager.send_room_action(Lobby.get_client_id(), RoomAction.Type.END_GAME, memory.get_floor_state())
            return

        if room_type == Rooms.MERCHANT:
            MultiplayerManager.leave_room()

        if memory.get_team_in_battle() == memory.local_player.team:
            match room_type:
                Rooms.BATTLE: gameplay_state.pressed_primary_action.emit(true)
                Rooms.ENEMY_UPGRADE: MultiplayerManager.leave_room()

        memory.battle.turn_time_left = -1




func make_a_turn(battle: Battle, player: Player, turn_type: BattleTurn.Type) -> void :
    var battle_processor = BattleProcesor.new(gameplay_state)
    print("making a turn: ", battle_processor)
    await battle_processor.make_a_turn(battle, player, turn_type)
    battle_processor.cleanup()
    battle_processor.free()


func clear_room(battle: Battle) -> void :
    var battle_processor = BattleProcesor.new(gameplay_state)
    print("clearing room: ", battle_processor)
    await battle_processor.clear_room(battle)
    battle_processor.cleanup()
    battle_processor.free()



func set_battle_speed(new_battle_speed: int) -> void :
    MultiplayerManager.set_battle_speed(new_battle_speed)

    if memory.partners.is_empty():
        return

    Net.call_func(MultiplayerManager.set_battle_speed, [new_battle_speed])





func process_battle_speed(battle: Battle) -> void :
    var battle_speed_container: BattleSpeedContainer = room_screen.battle_speed_container
    var attacks: int = 0

    battle_speed_container.visible = memory.room_type == Rooms.BATTLE


    if battle_speed_container.is_pressed:
        set_battle_speed(wrapi(int(options.battle_speed) + 1, 0, Options.BattleSpeed.size()))


    if not is_instance_valid(battle):
        battle_speed = 1.75
        return


    for player in memory.get_all_players():
        for turn in player.battle_profile.get_valid_turns():
            attacks += turn.attacks


    for enemy_character in battle.get_enemy_characters_in_combat():

        for turn in enemy_character.battle_profile.get_valid_turns():
            attacks += turn.attacks

    var target_battle_speed: float = 1.75

    match options.battle_speed:
        Options.BattleSpeed.X1: target_battle_speed = 1.0
        Options.BattleSpeed.X2: target_battle_speed = 1.75
        Options.BattleSpeed.X4: target_battle_speed = 3.45
        Options.BattleSpeed.X8: target_battle_speed = 10.0

    battle_speed = maxf(1.0 - (float(attacks) * 0.025), 0.25)
    battle_speed /= maxf(1.0, target_battle_speed)
    battle_speed = maxf(0.001, battle_speed)

    room_screen.enemy_container_holder.battle_speed = 1.0 / battle_speed




func process_entering_combat(battle: Battle, character: Character) -> void :
    if not is_instance_valid(character):
        return

    var enemy_characters_in_combat: Array[Character] = battle.get_enemy_characters_in_combat()
    var character_active_item_sets: Array[ItemSetResource] = character.get_active_item_sets()
    var character_passives: Array[Passive] = character.get_passives()

    if memory.is_player(character):
        if character_passives.has(Passives.LUMINOUS_TRIAL):
            for enemy in enemy_characters_in_combat:
                enemy.set_status_effect_amount(StatusEffects.BLINDNESS, 1)
        return


    if character_passives.has(Passives.GOLDEN_ALTRUISM):
        for ally in enemy_characters_in_combat:
            if character == ally:
                continue
            ally.set_status_effect_amount(StatusEffects.GOLDEN_HEART, 1)

    if character_passives.has(Passives.WINDS_GRACE):
        for ally in enemy_characters_in_combat:
            if character == ally:
                continue
            if ally.battle_profile.active_item_sets.has(ItemSets.SWIFTNESS):
                continue
            ally.battle_profile.active_item_sets.push_back(ItemSets.SWIFTNESS)

    if character_passives.has(Passives.LUMINOUS_TRIAL):
        for player in memory.get_alive_players():
            player.set_status_effect_amount(StatusEffects.BLINDNESS, 1)



func try_to_complete_battle(battle: Battle) -> void :
    var room_type: RoomResource = memory.room_type

    if not room_type == Rooms.BATTLE:
        return

    if not battle_completed(battle):
        return

    if not memory.partners.size() and memory.local_player.get_health() == 0:
        return


    battle.completed = true





func has_battle_actions(player: Player, selected_enemy_idx: int) -> int:
    if memory.room_type == Rooms.ENTRANCE:
        return OK

    if not is_instance_valid(memory.battle):
        return 1

    var battle: Battle = memory.battle

    if not is_instance_valid(room_screen):
        return 2

    if not is_instance_valid(player):
        return 3

    if memory.game_mode == GameModes.PVP:
        if not memory.get_team_in_battle() == player.team:
            return 14

    if player.battle_profile.has_active_status_effect_resource(StatusEffects.TIMEOUT):
        return 4

    if memory.partners.size() > 0:
        if player.is_phantom:
            return BattleActionFailResult.MP_PHANTOM

    if memory.partners.size() == 0:
        if not memory.phantom_processed and player.is_phantom:
            return 5

    if player.died:
        return 6


    if battle.get_enemies_in_combat().size() == 0:
        return 7

    if battle.turn_in_progress:
        return 8

    if battle.setup_in_progress:
        return 9

    for enemy in battle.enemies_to_battle:
        if not is_instance_valid(enemy):
            continue


    var enemies_in_combat: Array[Enemy] = battle.get_enemies_in_combat()
    var minimum_enemies_required: int = 0

    if enemies_in_combat.size() <= minimum_enemies_required:
        return 10


    if not selected_enemy_idx == -1:
        if selected_enemy_idx > battle.enemies_to_battle.size() - 1:
            return 11


        var selected_enemy: Enemy = battle.enemies_to_battle[selected_enemy_idx]

        if not is_instance_valid(selected_enemy):
            return 12

        if selected_enemy.out_of_combat:
            return 13



    return OK





func battle_completed(battle: Battle) -> bool:
    var local_player: Player = memory.local_player

    if not is_instance_valid(battle):
        return true

    if battle.has_enemies_to_battle():
        return false

    if battle.turn_in_progress:
        return false

    if local_player.died:
        return false

    return true




func set_turn_in_progress(battle: Battle, in_progress: bool) -> void :
    battle.turn_in_progress = in_progress


func get_battle_wait_time(base_value: float) -> float:
    return maxf(1e-05, base_value * battle_speed)

func create_battle_animation_timer(base_value: float) -> void :
    await get_tree().create_timer(get_battle_wait_time(base_value)).timeout



func is_instant() -> bool:
    return options.battle_speed == Options.BattleSpeed.X8
