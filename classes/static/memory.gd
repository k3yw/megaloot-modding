class_name Memory extends RefCounted

signal enemy_encountered(enemy_resource: EnemyResource)

var dismantle: ItemContainer = ItemContainer.new(ItemContainerResources.DISMANTLE, 1)
var _gamemode_script: GameModeScript = null


var local_player: Player = Player.new()
var dismantling_player_id: String = ""
var dismantle_item_count: int = 0
var partners: Array[Player] = []

var blue_team: Team = Team.new()
var red_team: Team = Team.new()



var battle: Battle = Battle.new()
var enemy_upgrade_seed: int = -1
var room_idx: int = -1

var phantom_processed: bool = false

var floor_number: int = 0



var gameplay_rand_state: int = 0
var market_rand_state: int = 0
var enemy_rand_state: int = 0


var game_mode: GameMode = GameModes.CHALLENGE
var room_type: RoomResource = Rooms.ENTRANCE
var is_game_ended: bool = false
var is_endless: bool = false
var last_save_time: String = ""
var profile_id: String = ""
var version: String = ""
var run_time: float = 0.0
var start_time: int = 0
var tower_seed: int = 0
var ascension: int = 0
var id: String = ""


var initialized: bool = false











func get_character_reference(character: Character) -> CharacterReference:
    var character_reference: CharacterReference = CharacterReference.new()
    character_reference._ref = character

    if not is_instance_valid(character):
        return character_reference

    for player in get_all_players():
        if player == character:
            character_reference.type = CharacterReference.Type.PLAYER
            character_reference.id = player.profile_id
            return character_reference


    for idx in battle.enemies_to_battle.size():
        if not EnemyUtils.is_valid(battle.enemies_to_battle[idx]):
            continue
        var enemy: Enemy = battle.enemies_to_battle[idx]

        if enemy == character:
            character_reference.type = CharacterReference.Type.ENEMY
            character_reference.idx = idx
            return character_reference


    for idx in battle.next_enemies.size():
        if not EnemyUtils.is_valid(battle.next_enemies[idx]):
            continue
        var enemy: Enemy = battle.next_enemies[idx]

        if enemy == character:
            character_reference.type = CharacterReference.Type.ENEMY
            character_reference.is_next = true
            character_reference.idx = idx
            return character_reference

    print("error: character not found -> ", character)
    return character_reference





func create_damage_result(arg_target: Character = null, arg_attacker: Character = null, arg_damage_type: StatResource = null) -> DamageResult:
    var damage_result: DamageResult = DamageResult.new(
        get_character_reference(arg_target), 
        get_character_reference(arg_attacker), 
        arg_damage_type
        )

    return damage_result



func spawn_enemies() -> void :
    if not is_instance_valid(battle):
        return

    var battle_count: int = get_battle_count()

    match room_type:
        Rooms.BATTLE:
            var enemies_to_spawn: Array[Array] = get_enemies_to_spawn(battle_count)
            battle.enemies_to_battle = enemies_to_spawn[0]
            battle.next_enemies = enemies_to_spawn[1]


            for enemy in battle.enemies_to_battle + battle.next_enemies:
                if not is_instance_valid(enemy):
                    continue

                enemy_encountered.emit(enemy.resource)

        Rooms.FINAL:
            var enemy_to_spawn: Enemy = Enemy.new()
            enemy_to_spawn.resource = Enemies.HEART_OF_THE_TOWER
            battle.enemies_to_battle.push_back(enemy_to_spawn)
            enemy_to_spawn.update_all()


        Rooms.ENEMY_UPGRADE:
            enemy_upgrade_seed = RNGManager.enemy_rand.seed
            var enemies_to_spawn: Array[Array] = get_enemies_to_spawn(battle_count + 1)
            battle.enemies_to_battle = enemies_to_spawn[0]


        Rooms.MERCHANT:
            var enemy_to_spawn: Enemy = Enemy.new()
            enemy_to_spawn.resource = Enemies.MERCHANT
            battle.enemies_to_battle.push_back(enemy_to_spawn)
            enemy_to_spawn.update_all()


        Rooms.MYSTIC_TRADER:
            var enemies_to_spawn: Array[EnemyResource] = [Enemies.MYSTIC_BISON, Enemies.MYSTIC_TRADER]
            for enemy_resource in enemies_to_spawn:
                var enemy_to_spawn: Enemy = Enemy.new()
                enemy_to_spawn.resource = enemy_resource
                battle.enemies_to_battle.push_back(enemy_to_spawn)
                enemy_to_spawn.update_all()


        Rooms.CHEST:
            var enemy_to_spawn: Enemy = Enemy.new()
            enemy_to_spawn.resource = Enemies.COMMON_CHEST

            if floor_number >= 4:
                enemy_to_spawn.resource = Enemies.GOLDEN_CHEST

            battle.enemies_to_battle.push_back(enemy_to_spawn)
            enemy_to_spawn.update_all()

        _: return






func get_enemies_to_spawn(arg_battle_idx: int) -> Array[Array]:
    var enemies_to_battle: Array[Enemy] = []
    var next_enemies: Array[Enemy] = [null, null, null]

    if not enemy_upgrade_seed == -1:
        RNGManager.enemy_rand.seed = enemy_upgrade_seed

    var level: int = local_player.active_trials.count(Trials.HONOR)
    var max_enemies: int = get_max_enemies()

    var front_enemies: int = RNGManager.enemy_rand.randi_range(ceili(float(max_enemies) / 2), mini(3, max_enemies))
    var battle_count: int = get_total_battle_count()

    if game_mode == GameModes.PVP:
        battle_count = floori(float(battle_count) * 0.5)

    var hidden_slots: PackedFloat32Array = PackedFloat32Array([0, 0, 0])
    var is_gang: bool = false


    front_enemies = mini(3, front_enemies)

    if local_player.active_trials.has(Trials.SWARM):
        front_enemies = 3
        max_enemies = 6


    if RNGManager.enemy_rand.randi_range(0, 99) < 5:
        is_gang = true


    var chosen_enemy: Enemy = null


    for idx in range(front_enemies):
        if not is_instance_valid(chosen_enemy) or not is_gang:
            chosen_enemy = create_rand_enemy(
                floor_number, 
                battle_count + 1, 
                level, 
                is_gang
                )

        if is_gang:
            chosen_enemy = Enemy.new(chosen_enemy)

        if partners.size() > 0 and not game_mode == GameModes.PVP:
            if partners.size() - 1 >= idx:
                chosen_enemy.immune_to = get_random_player(RNGManager.enemy_rand).profile_id

        enemies_to_battle.push_back(chosen_enemy)
        hidden_slots[idx] = 1



    for idx in range(max_enemies - front_enemies):
        if not is_instance_valid(chosen_enemy) or not is_gang:
            chosen_enemy = create_rand_enemy(
                floor_number, 
                battle_count + 1, 
                level, 
                is_gang
                )

        if is_gang:
            chosen_enemy = Enemy.new(chosen_enemy)

        var rand_idx: int = RNGManager.enemy_rand.rand_weighted(hidden_slots)
        hidden_slots[rand_idx] = 0
        next_enemies[rand_idx] = chosen_enemy

    return [enemies_to_battle, next_enemies]






func create_rand_enemy(spawn_floor: int, battle_count: int, level: int, is_gang: bool) -> Enemy:
    var enemy_to_spawn: Enemy = Enemy.new()
    enemy_to_spawn.resource = Enemies.TRAINING_DUMMY

    var enemy_pool: Array[EnemyResource] = []


    if not game_mode == GameModes.PRACTICE:
        enemy_to_spawn.resource = Enemies.LIST.front()
        enemy_pool = Enemies.get_from_floor(Enemies.LIST, spawn_floor)

        if is_gang:
            for idx in range(enemy_pool.size() - 1, -1, -1):
                var enemy: EnemyResource = enemy_pool[idx]
                if enemy.is_unique:
                    enemy_pool.remove_at(idx)


        for enemy in battle.enemies_to_battle + battle.next_enemies:
            if not EnemyUtils.is_valid(enemy):
                continue
            if enemy.resource.is_unique:
                enemy_pool.erase(enemy.resource)

        var weight_pool: PackedFloat32Array
        for enemy in enemy_pool:
            weight_pool.push_back(enemy.get_weight(spawn_floor))

        enemy_to_spawn.resource = enemy_pool[RNGManager.enemy_rand.rand_weighted(weight_pool)]



    var new_level: int = level
    var level_points_left: int = abs((spawn_floor + 1) - (enemy_to_spawn.resource.floor_number + 1))
    var thereshold: int = 5

    while level_points_left - thereshold >= 0 and new_level < 7:
        var thereshold_to_add: int = 5
        thereshold += thereshold_to_add
        new_level += 1


    if not game_mode == GameModes.PVP:
        enemy_to_spawn.player_count = partners.size()
    enemy_to_spawn.player_trials = local_player.active_trials
    enemy_to_spawn.battle_count = battle_count
    enemy_to_spawn.set_spawn_floor(spawn_floor + 1)
    enemy_to_spawn.transform_to_elite(new_level)

    var blue_team_upgrade_stats: Array[Stat] = blue_team.get_enemy_upgrade_stats(enemy_to_spawn.resource)
    var red_team_upgrade_stats: Array[Stat] = red_team.get_enemy_upgrade_stats(enemy_to_spawn.resource)
    var upgrade_stats: Array[Stat] = []

    match get_team_in_battle():
        Team.Type.BLUE:
            if room_type == Rooms.ENEMY_UPGRADE:
                enemy_to_spawn.upgrade_stats = blue_team_upgrade_stats
            else:
                enemy_to_spawn.upgrade_stats = red_team_upgrade_stats

        Team.Type.RED:
            if room_type == Rooms.ENEMY_UPGRADE:
                enemy_to_spawn.upgrade_stats = red_team_upgrade_stats
            else:
                enemy_to_spawn.upgrade_stats = blue_team_upgrade_stats



    enemy_to_spawn.update_all()

    for idx in mini(enemy_to_spawn.resource.starting_status_effects.size(), enemy_to_spawn.level + 1):
        var starting_status_effects: StartingStatusEffects = enemy_to_spawn.resource.starting_status_effects[idx]
        if not is_instance_valid(starting_status_effects):
            continue
        for starting_status_effect in starting_status_effects.status_effects:
            enemy_to_spawn.try_to_add_status_effect(null, starting_status_effect.resource, starting_status_effect.amount)


    return enemy_to_spawn







func get_all_players() -> Array[Player]:
    return [local_player] as Array[Player] + partners




func get_allies(character: Character) -> Array[Character]:
    var allies: Array[Character] = battle.get_enemy_characters_in_combat()
    var is_player_ally: bool = false

    allies.erase(character)

    for player in get_all_players():
        if player == character:
            is_player_ally = true
            break

    if is_player_ally:
        allies.clear()
        for ally in get_alive_players((character as Player).team):
            if ally == character:
                continue
            allies.push_back(ally)

    return allies



func pick_random_ally(character: Character) -> Character:
    var allies: Array[Character] = get_allies(character)
    if allies.is_empty():
        return null
    return allies[RNGManager.gameplay_rand.randi_range(0, allies.size() - 1)]



func get_opponents(character: Character) -> Array[Character]:
    var opponents: Array[Character] = battle.get_enemy_characters_in_combat()
    var is_player_opponent: bool = true

    for player in get_all_players():
        if player == character:
            is_player_opponent = false
            break

    if is_player_opponent:
        opponents.clear()
        opponents.push_back(battle.battling_player)

    return opponents



func get_player_from_client_id(client_id: int) -> Player:
    for player in get_all_players():
        if player.client_id == client_id:
            return player

    if client_id == -1 or client_id == Lobby.get_client_id():
        return local_player

    return null



func get_alive_players(team: Team.Type = Team.Type.NULL) -> Array[Player]:
    if not partners.size():
        if not local_player.died:
            return [local_player] as Array[Player]

        return []

    var alive_players: Array[Player] = []
    for player in get_all_players():
        if player.is_phantom:
            continue

        if not team == Team.Type.NULL:
            if not player.team == team:
                continue

        alive_players.push_back(player)


    return alive_players






func get_partner(client_id: int) -> Player:
    for partner in partners:
        if not is_instance_valid(partner):
            continue

        if partner.client_id == client_id:
            return partner

    return null




func get_timeout_player_ids() -> PackedStringArray:
    var timeout_player_ids: PackedStringArray = []

    for player in get_all_players():
        if player.battle_profile.has_timeout():
            timeout_player_ids.push_back(player.profile_id)

    return timeout_player_ids



func is_local_coop() -> bool:
    var scanned_ids: PackedStringArray = []
    for player in get_all_players():
        if scanned_ids.has(player.profile_id):
            return true
        scanned_ids.push_back(player.profile_id)
    return false



func get_player_to_battle(team: Team.Type = Team.Type.NULL) -> Player:
    var player_without_timeout: Array[Player] = []

    for player in get_alive_players(team):
        if player.battle_profile.has_timeout():
            continue
        player_without_timeout.push_back(player)


    if player_without_timeout.size() == 1:
        return player_without_timeout[0]

    return null



func is_player(character: Character) -> bool:
    if local_player == character:
        return true

    for partner in partners:
        if partner == character:
            return true

    return false






func get_random_player(rng: RandomNumberGenerator) -> Player:
    var players: Array[Player] = get_all_players()
    players.sort_custom(sort_players)

    return players[rng.randi_range(0, players.size() - 1)]


func sort_players(character_a: Player, character_b: Player) -> bool:
    return character_a.profile_id > character_b.profile_id



func players_have_item(item_resource: ItemResource) -> bool:
    for player in get_all_players():
        var item_containers: Array[ItemContainer] = [
            player.inventory, 
            player.loot_stash, 
        ]

        for item_container in item_containers:
            for item in item_container.get_items():
                if item.resource == item_resource:
                    return true

    return false



func get_characters_in_combat() -> Array[Character]:
    var characters_in_combat: Array[Character] = []
    characters_in_combat += battle.get_enemy_characters_in_combat()

    for player in get_alive_players():
        characters_in_combat.push_back(player as Character)

    return characters_in_combat



func get_total_battle_count() -> int:
    return _gamemode_script.get_rooms_up_to_floor(floor_number, room_idx).count(Rooms.BATTLE)

func get_battle_count() -> int:
    return _gamemode_script.get_battle_count(floor_number, room_idx)

func get_battles_this_floor() -> int:
    return _gamemode_script.get_rooms_in_floor(floor_number, get_room_count()).count(Rooms.BATTLE)


func get_enemies_to_battle() -> Array[Enemy]:
    if not is_instance_valid(battle):
        return []

    return battle.enemies_to_battle




func update_game_mode_script() -> void :
    if is_instance_valid(_gamemode_script):
        _gamemode_script.free()
    _gamemode_script = game_mode.get_script_instance()






func get_room_count() -> int:
    return _gamemode_script.get_room_count(floor_number)


func update_room_type() -> void :
    room_type = _gamemode_script.get_room_type(floor_number, room_idx)

func get_max_enemies() -> int:
    return _gamemode_script.get_max_enemies(floor_number, room_idx)

func get_base_gold_on_kill(floor_number: int) -> float:
    return _gamemode_script.get_gold_on_kill(null, floor_number)

func get_gold_on_kill(player: Player, arg_floor_number: int) -> float:
    return _gamemode_script.get_gold_on_kill(player, arg_floor_number)


func get_market_refresh_price(refresh_count: int) -> float:
    var base: float = get_base_gold_on_kill(floor_number) * 0.45
    var growth: float = 1.0 + (float(mini(3, refresh_count)) * 0.25)

    var refresh_price: float = pow(base, growth) + refresh_count
    refresh_price += floorf(floor_number * 0.25)
    if refresh_count > 3:
        refresh_price *= refresh_count - 2

    return ceilf(refresh_price)


func get_dismantle_price() -> int:
    return dismantle_item_count * 5


func get_chest_gold_reward() -> float:
    if floor_number >= 4:
        return ceilf(get_base_gold_on_kill(floor_number) * 12.45)
    return ceilf(get_base_gold_on_kill(floor_number) * 6.25)




func get_team_in_battle() -> Team.Type:
    if not game_mode == GameModes.PVP:
        return Team.Type.BLUE

    var pattern: Array[Team.Type] = [
        Team.Type.BLUE, 
        Team.Type.BLUE, 
        Team.Type.RED, 
        Team.Type.RED, 
        ]

    if floor_number % 2 == 1:
        pattern.reverse()

    return pattern[room_idx % pattern.size()]



func is_last_room() -> bool:
    return _gamemode_script.is_last_room(floor_number, room_idx)


func is_last_battle(arg_battle_idx: int = room_idx) -> bool:
    return arg_battle_idx == get_room_count() - 2




func get_item_containers(character: Character) -> Array[ItemContainer]:
    var item_containers: Array[ItemContainer] = [dismantle] as Array[ItemContainer]

    if character == local_player:
        item_containers += local_player.get_item_containers()
        return item_containers

    if is_instance_valid(character):
        item_containers += [character.equipment, character.inventory]

    return item_containers


func all_players_left_room() -> bool:
    for player in get_all_players():
        if not player.left_room:
            return false

    return true



func is_turn_timer_active() -> bool:
    if game_mode == GameModes.PVP:
        return true

    if local_player.active_trials.has(Trials.SAGACITY):
        return true

    return false



func get_music_start_track() -> Music:
    var music = Music.new(preload("res://assets/music/gameplay/floor_1_start.ogg"))

    if floor_number + 1 > 60:
        music.stream = preload("res://assets/music/gameplay/floors_61_to_x_start.ogg")
        return music

    if range(31, 61).has(floor_number + 1):
        music.stream = preload("res://assets/music/gameplay/floors_31_to_60_start.ogg")
        return music

    if range(21, 31).has(floor_number + 1):
        music.stream = preload("res://assets/music/gameplay/floors_21_to_30_start.ogg")
        return music

    if range(16, 21).has(floor_number + 1):
        music.stream = preload("res://assets/music/gameplay/floors_16_to_20_start.ogg")
        return music

    if range(11, 16).has(floor_number + 1):
        music.stream = preload("res://assets/music/gameplay/floors_11_to_15_start.ogg")
        return music


    match floor_number + 1:
        1: music.stream = preload("res://assets/music/gameplay/floor_1_start.ogg")
        2: music.stream = preload("res://assets/music/gameplay/floor_2_start.ogg")
        3: music.stream = preload("res://assets/music/gameplay/floor_3_start.ogg")
        4: music.stream = preload("res://assets/music/gameplay/floor_4_start.ogg")
        5: music.stream = preload("res://assets/music/gameplay/floor_5_start.ogg")
        6: music.stream = preload("res://assets/music/gameplay/floor_6_start.ogg")
        7: music.stream = preload("res://assets/music/gameplay/floor_7_start.ogg")
        8: music.stream = preload("res://assets/music/gameplay/floor_8_start.ogg")
        9: music.stream = preload("res://assets/music/gameplay/floor_9_start.ogg")
        10: music.stream = preload("res://assets/music/gameplay/floor_10_start.ogg")


    return music







func get_music_loop_track() -> Music:
    var music = Music.new(preload("res://assets/music/gameplay/floor_1_loop.ogg"))
    music.sync = true


    if floor_number + 1 > 60:
        music.stream = preload("res://assets/music/gameplay/floors_61_to_x_loop.ogg")
        return music

    if range(41, 61).has(floor_number + 1):
        music.stream = preload("res://assets/music/gameplay/floors_31_to_60_loop.ogg")
        return music

    if range(31, 41).has(floor_number + 1):
        music.stream = preload("res://assets/music/gameplay/floors_21_to_30_loop.ogg")
        return music

    if range(26, 31).has(floor_number + 1):
        music.stream = preload("res://assets/music/gameplay/floors_16_to_20_loop.ogg")
        return music

    if range(19, 26).has(floor_number + 1):
        music.stream = preload("res://assets/music/gameplay/floors_11_to_15_loop.ogg")
        return music


    match floor_number + 1:
        1, 2: music.stream = preload("res://assets/music/gameplay/floor_1_loop.ogg")
        3, 4: music.stream = preload("res://assets/music/gameplay/floor_2_loop.ogg")
        5, 6: music.stream = preload("res://assets/music/gameplay/floor_3_loop.ogg")
        7, 8: music.stream = preload("res://assets/music/gameplay/floor_4_loop.ogg")
        9, 10: music.stream = preload("res://assets/music/gameplay/floor_5_loop.ogg")
        11, 12: music.stream = preload("res://assets/music/gameplay/floor_6_loop.ogg")
        12, 13: music.stream = preload("res://assets/music/gameplay/floor_7_loop.ogg")
        13, 14: music.stream = preload("res://assets/music/gameplay/floor_8_loop.ogg")
        15, 16: music.stream = preload("res://assets/music/gameplay/floor_9_loop.ogg")
        17, 18: music.stream = preload("res://assets/music/gameplay/floor_10_loop.ogg")


    return music





func get_floor_state() -> PackedInt64Array:
    return [floor_number, room_idx, battle.current_turn]


func can_ascend() -> bool:
    if not game_mode == GameModes.CHALLENGE:
        return false

    if floor_number < game_mode.last_floor:
        return false

    return is_game_ended



func cleanup_battle() -> void :
    if not is_instance_valid(battle):
        return

    for enemy in battle.enemies_to_battle:
        if not EnemyUtils.is_valid(enemy):
            continue
        enemy.cleanup()

    for enemy in battle.next_enemies:
        if not EnemyUtils.is_valid(enemy):
            continue
        enemy.cleanup()


    battle.cleanup()
    battle.free()
