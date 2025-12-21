extends Node


signal state_changed


@export var screen_transition: ScreenTransition

var is_changing_state: bool
var _current_state: Node




func _ready() -> void :
    GDSync.client_left.connect(_on_client_left)
    Lobby.joined.connect(_on_lobby_joined)
    GDSync.kicked.connect(_on_kicked)

    GDSync.expose_func(_start_game)

    var intro_state: IntroState = preload("res://scenes/states/intro_state/intro_state.tscn").instantiate()
    StateManager.change_state(intro_state)

    process_mode = ProcessMode.PROCESS_MODE_ALWAYS






func _on_client_left(_client_id: int) -> void :
    if _current_state is GameplayState:
        if not _current_state.memory.is_game_ended:
            _change_to_lobby_state()



func _on_kicked() -> void :
    if _current_state is GameplayState:
        if not _current_state.memory.is_game_ended:
            _change_to_lobby_state()
        return

    _change_to_memory_selection_state()



func _on_lobby_joined(lobby_name: String) -> void :
    if lobby_name == Lobby.created_lobby_name:
        return

    if _current_state is LobbyState:
        return

    _change_to_lobby_state()




func _process(_delta: float) -> void :
    if is_instance_valid(NodeManager.main_canvas_layer):
        if NodeManager.main_canvas_layer.esc_menu_screen.restart_button.is_pressed:
            _current_state = _current_state as GameplayState

            if not _current_state.memory.game_mode == GameModes.PRACTICE:
                UserData.profile.set_floor_record(_current_state.memory.local_player.adventurer, _current_state.memory.floor_number)

            UserData.profile.selected_adventurer = _current_state.memory.local_player.adventurer
            UserData.delete_memory_slot(_current_state.memory_slot_idx)
            UserData.active_memory_slot_idx = -1
            _change_to_gameplay_state(_current_state.memory.game_mode.get_id())
            return

    if _current_state is MainMenuState:
        if _current_state.library_button.is_pressed:
            StateManager.finish_transition_end_animation()
            _change_to_library_state()
            return







func change_state(node: Node):
    if is_instance_valid(_current_state):
        _current_state.queue_free()
    _current_state = node
    add_child(node)

    state_changed.emit()




func _change_state_with_fade(node: Node, transition_speed: float = 1.0):
    is_changing_state = true

    screen_transition.animation_player.play("transition_start", -1, transition_speed)
    await screen_transition.animation_player.animation_finished

    is_changing_state = false
    change_state(node)







func create_library_state() -> LibraryState:
    var library_state = preload("res://scenes/states/library_state/library_state.tscn").instantiate()
    library_state.enemy_resources = Enemies.LIST.duplicate()

    return library_state




func change_to_main_menu_state(sync_music: bool) -> void :
    var main_menu_state: MainMenuState = preload("res://scenes/states/main_menu_state/main_menu_state.tscn").instantiate()
    main_menu_state.menu_item_emitter.item_content = Items.LIST.duplicate()

    main_menu_state.enter_the_tower_button.pressed.connect( func():
        finish_transition_end_animation()
        _change_to_memory_selection_state()
        )


    main_menu_state.profile_button.pressed.connect( func():
        finish_transition_end_animation()
        _change_to_profile_state()
        )

    main_menu_state.workshop_button.pressed.connect( func():
        finish_transition_end_animation()
        _change_to_workshop_state()
        )

    await _change_state_with_fade(main_menu_state, true)
    screen_transition.animation_player.play("transition_end")

    var music = Music.new(preload("res://assets/music/main_menu/main_menu.ogg"), 0.0, 1.75)
    music.sync = sync_music

    AudioManager.play_music(music)

    ISteam.set_rich_presence("steam_display", "#StatusWithoutScore")
    ISteam.set_rich_presence("gamestatus", "AtMainMenu")




func _change_to_profile_state() -> void :
    var profile_state: ProfileState = preload("res://scenes/states/profile_state/profile_state.tscn").instantiate()

    profile_state.back_button.pressed.connect( func():
        finish_transition_end_animation()
        change_to_main_menu_state(true)
        )

    await _change_state_with_fade(profile_state, true)
    StateManager.screen_transition.animation_player.play("transition_end")

    var music = Music.new(preload("res://assets/music/main_menu/library.ogg"), 0.0, 1.75)
    music.sync = true

    AudioManager.play_music(music)





func _change_to_library_state() -> void :
    var library_state = StateManager.create_library_state()

    await _change_state_with_fade(library_state, true)
    StateManager.screen_transition.animation_player.play("transition_end")

    var music = Music.new(preload("res://assets/music/main_menu/library.ogg"), 0.0, 1.75)
    music.sync = true

    AudioManager.play_music(music)









func _change_to_lobby_state() -> void :
    var lobby_state = preload("res://scenes/states/lobby_state/lobby_state.tscn").instantiate()
    var active_memeory_slot: MemorySlot = UserData.get_active_memeory_slot()

    lobby_state.back_button.pressed.connect( func():
        if is_changing_state:
            return
        finish_transition_end_animation()
        _change_to_memory_selection_state()
        )

    lobby_state.begin_button.pressed.connect( func():
        if is_changing_state:
            return

        var tower_seed: int = randi()
        var id: String = UUID.v4()

        var slot_memory_data: Dictionary = {}


        if not Lobby.data.new_save:
            var active_memory_slot: MemorySlot = UserData.get_active_memeory_slot()
            slot_memory_data = SaveSystem.get_data(active_memory_slot)
            id = active_memory_slot.memory.id

        _change_to_gameplay_state(Lobby.data.game_mode, id, tower_seed)

        Net.call_func(_start_game, [slot_memory_data, Lobby.data.game_mode, id, tower_seed])
        )

    await _change_state_with_fade(lobby_state, true)
    StateManager.screen_transition.animation_player.play("transition_end")

    var music = Music.new(preload("res://assets/music/main_menu/new_journey.ogg"), 0.0, 1.75)
    music.sync = true

    AudioManager.play_music(music)






func _change_to_memory_selection_state() -> void :
    var memory_selection_state: MemorySelectionState = preload("res://scenes/states/memory_selection_state/memory_selection_state.tscn").instantiate()
    UserData.active_memory_slot_idx = -1


    memory_selection_state.back_button.pressed.connect( func():
        change_to_main_menu_state(true)
        )


    memory_selection_state.interact_button.pressed.connect( func():
        var memory_slot: MemorySlot = null

        if memory_selection_state.tab_container.current_tab == MemorySelectionState.Tabs.LOBBIES:
            return

        if not memory_selection_state.selected_memory_slot_idx == -1:
            memory_slot = UserData.memory_slots[memory_selection_state.selected_memory_slot_idx]

        if memory_selection_state.selected_memory_slot_idx == -1 or not is_instance_valid(memory_slot):
            finish_transition_end_animation()
            _change_to_lobby_state()
            return


        UserData.active_memory_slot_idx = memory_selection_state.selected_memory_slot_idx

        if not OS.is_debug_build() and memory_slot.memory.local_player.died:
            if not memory_slot.memory.can_ascend():
                return

        if not memory_slot.memory.partners.size():
            _change_to_gameplay_state()
            return

        Lobby.data.active_trials = memory_slot.memory.local_player.active_trials
        _change_to_lobby_state()
        )


    await _change_state_with_fade(memory_selection_state, true)
    StateManager.screen_transition.animation_player.play("transition_end")

    var music = Music.new(preload("res://assets/music/main_menu/new_journey.ogg"), 0.0, 1.75)
    music.sync = true

    AudioManager.play_music(music)






func _change_to_workshop_state() -> void :
    var workshop_state: WorkshopState = preload("res://scenes/states/workshop_state/workshop_state.tscn").instantiate()

    workshop_state.back_button.pressed.connect( func():
        finish_transition_end_animation()
        change_to_main_menu_state(true)
        )

    await _change_state_with_fade(workshop_state, true)
    StateManager.screen_transition.animation_player.play("transition_end")

    var music = Music.new(preload("res://assets/music/main_menu/library.ogg"), 0.0, 1.75)
    music.sync = true

    AudioManager.play_music(music)




func _start_game(memory_slot_data: Dictionary, game_mode: String, id: String, tower_seed: int) -> void :
    var new_game: bool = memory_slot_data.size() == 0

    if new_game:
        UserData.active_memory_slot_idx = -1

    if not new_game:
        var new_memory_slot: MemorySlot = MemorySlot.new()
        SaveSystem.load_data(new_memory_slot, memory_slot_data)

        UserData.active_memory_slot_idx = UserData.get_or_add_memory_slot(new_memory_slot)

        var host_player: Character = new_memory_slot.memory.local_player

        for idx in new_memory_slot.memory.partners.size():
            var partner: Player = new_memory_slot.memory.partners[idx]

            if partner.profile_id == UserData.profile.get_id():
                new_memory_slot.memory.local_player.battle_log_name = [T.get_translated_string("Local Player Name")]
                new_memory_slot.memory.partners.remove_at(idx)
                new_memory_slot.memory.local_player = partner
                break

        new_memory_slot.memory.partners.push_back(host_player)



    _change_to_gameplay_state(game_mode, id, tower_seed)




func _change_to_gameplay_state(game_mode: String = Lobby.data.game_mode, id: String = UUID.v4(), tower_seed: int = randi()) -> void :
    var gameplay_state = States.GAMEPLAY_STATE.instantiate()
    var active_memory_slot: MemorySlot = UserData.get_active_memeory_slot()
    var memory: Memory = gameplay_state.memory
    var ascended: bool = false

    gameplay_state.death_screen.confirm_button.pressed.connect( func():
        _change_to_lobby_state()
    )

    if is_instance_valid(active_memory_slot):
        if not active_memory_slot.memory.can_ascend():
            gameplay_state.phantom_memory = active_memory_slot.phantom_memory
            gameplay_state.memory = active_memory_slot.memory
            memory = gameplay_state.memory
        else:
            id = active_memory_slot.memory.id
            ascended = true


    gameplay_state.memory_slot_idx = UserData.active_memory_slot_idx
    for idx in UserData.memory_slots.size():
        var memory_slot: MemorySlot = UserData.memory_slots[idx]
        if not is_instance_valid(memory_slot):
            continue
        if memory_slot.memory.id == id:
            UserData.active_memory_slot_idx = idx
            gameplay_state.memory_slot_idx = idx


    var new_memory_slot: MemorySlot = null
    if UserData.active_memory_slot_idx == -1 or ascended:
        var local_player_adventurer: Adventurer = UserData.profile.selected_adventurer
        new_memory_slot = MemorySlot.new()

        if ascended:
            var old_memory: Memory = UserData.memory_slots[UserData.active_memory_slot_idx].memory
            local_player_adventurer = old_memory.local_player.adventurer
            new_memory_slot.memory.ascension = old_memory.ascension + 1

        gameplay_state.phantom_memory = new_memory_slot.phantom_memory
        gameplay_state.memory = new_memory_slot.memory
        memory = gameplay_state.memory

        memory.local_player.apply_adventurer(UserData.profile.selected_adventurer)
        memory.game_mode = GameModes.from_name(game_mode)
        memory.version = System.get_version()
        memory.tower_seed = tower_seed
        memory.id = id
        memory.start_time = Time.get_ticks_msec()

        memory.local_player.team = Lobby.get_own_player_data().team

        memory.local_player.active_trials += Lobby.data.active_trials
        memory.local_player.profile_id = UserData.profile.get_id()


        for idx in Lobby.data.players.size():
            var lobby_player: LobbyPlayer = Lobby.data.players[idx]

            if lobby_player.profile_id == UserData.profile.get_id():
                continue

            var partner: Player = Player.new()
            partner.apply_adventurer(lobby_player.adventurer)
            partner.active_trials += Lobby.data.active_trials
            memory.partners.push_back(partner)
            partner.profile_id = lobby_player.profile_id
            partner.client_id = lobby_player.client_id
            partner.team = lobby_player.team
            partner.gold_coins = 15


    memory.partners = Lobby.get_sorted_partners(memory.partners, Lobby.get_client_id())


    if ascended:
        for old_save_player in active_memory_slot.memory.get_all_players():
            var new_save_player: Player = null

            for player in memory.get_all_players():
                if player.profile_id == old_save_player.profile_id:
                    new_save_player = player

            for item in old_save_player.banned_items:
                new_save_player.banned_items.push_back(item)

            for counter in old_save_player.used_items:
                if counter.item_resource.spawn_floor <= 1:
                    continue
                new_save_player.banned_items.push_back(counter.item_resource)


    var slot_indexes_to_delete: Array[int] = []
    if UserData.active_memory_slot_idx == -1 or ascended:
        for memory_slot in UserData.memory_slots:
            if not is_instance_valid(memory_slot):
                continue

            if memory_slot.memory.id == id:
                slot_indexes_to_delete.push_back(UserData.memory_slots.find(memory_slot))
                break

        gameplay_state.memory_slot_idx = UserData.get_or_add_memory_slot(new_memory_slot)


    await _change_state_with_fade(gameplay_state)

    for slot_index_to_delete in slot_indexes_to_delete:
        UserData.delete_memory_slot(slot_index_to_delete)

    screen_transition.animation_player.play("transition_end")


    ISteam.set_rich_presence("steam_display", "#StatusWithScore")
    ISteam.set_rich_presence("gamestatus", "Gameplay")
    ISteam.update_rich_presence_floor(gameplay_state.memory.floor_number)










func finish_transition_end_animation() -> void :
    var curr_animation_name = screen_transition.animation_player.current_animation

    if not curr_animation_name == "transition_end":
        return

    var curr_animation = screen_transition.animation_player.get_animation(curr_animation_name)
    screen_transition.animation_player.seek(curr_animation.length, true)



func get_current_state() -> Node:
    return _current_state



func is_busy() -> bool:
    if screen_transition.animation_player.is_playing():
        return true

    return false
