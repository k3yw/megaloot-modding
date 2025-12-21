extends Node

enum Type{GD_SYNC, STEAM, MANUAL}

signal data_synced(new_players: PackedInt64Array)
signal player_confirmed(player_id: int)
signal client_joined(client_id: int)
signal joined(lobby_name: String)
signal lobbies_received
signal data_reset
signal updated



var kick_cooldowns: Dictionary[int, float] = {}

var data: LobbyData = LobbyData.new()
var gd_sync_lobbies: Array = []
var steam_lobbies: Array = []
var lobby_to_join: String = ""

var created_lobby_name: String = ""
var custom_name: String = ""
var is_public: bool = false

var selected_lobby_has_password: bool = false
var selected_lobby: Dictionary = {}


class LobbyData extends Object:
    var type: Type = Type.GD_SYNC
    var steam_lobby_id: int = -1

    var game_mode: String = GameModes.CHALLENGE.get_id()
    var players: Array[LobbyPlayer] = []
    var active_trials: Array[Trial] = []
    var new_save: bool = true
    var max_players: int = 4



func _ready() -> void :
    PopupManager.lobby_menu_popup.confirm_buttom.pressed.connect(_on_lobby_menu_confirm_button_pressed)
    PopupManager.lobby_join_popup.join_button.pressed.connect(_on_lobby_join_button_pressed)
    tree_exiting.connect( func(): leave_lobby())

    if ISteam.is_active():
        ISteam.steam.lobby_chat_update.connect(_on_lobby_chat_update)
        ISteam.steam.lobby_data_update.connect(_on_lobby_data_update)
        ISteam.steam.lobby_match_list.connect(_on_lobby_match_list)
        ISteam.steam.lobby_joined.connect(_on_steam_lobby_joined)


    StateManager.state_changed.connect(_on_state_changed)

    GDSync.lobby_creation_failed.connect(_on_lobby_creation_failed)
    GDSync.steam_join_request.connect(_on_steam_join_request)
    GDSync.lobby_data_changed.connect(_on_lobby_data_changed)
    GDSync.lobby_join_failed.connect(_on_lobby_join_failed)
    GDSync.lobby_tag_changed.connect(_on_lobby_tag_changed)
    GDSync.lobbies_received.connect(_on_lobbies_received)
    GDSync.lobby_joined.connect(_on_gd_sync_lobby_joined)
    GDSync.connected.connect(_on_gd_sync_connected)
    GDSync.client_joined.connect(_on_client_joined)
    GDSync.client_left.connect(_on_client_left)
    GDSync.kicked.connect(_on_lobby_kicked)


    multiplayer.connected_to_server.connect(_on_manual_lobby_joined)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    multiplayer.peer_connected.connect(_on_peer_connected)

    GDSync.expose_func(receive_player_data)
    GDSync.expose_func(update_player_data)
    GDSync.expose_func(sync_lobby_data)
    GDSync.expose_func(set_trials)
    GDSync.expose_func(swap_team)

    process_mode = ProcessMode.PROCESS_MODE_ALWAYS




func _on_lobby_join_button_pressed() -> void :
    var input: String = PopupManager.lobby_join_popup.line_edit.line_edit.text
    PopupManager.lobby_join_popup.hide()

    if selected_lobby["Name"].is_empty():
        join_lobby_with_ip(input)
        return

    join_lobby(selected_lobby["Name"], input)




func _on_lobby_menu_confirm_button_pressed() -> void :
    var connection_type_changed: bool = not data.type == PopupManager.lobby_menu_popup.connection_type_drop_down.selected_idx
    var password: String = PopupManager.lobby_menu_popup.password_line_edit.line_edit.text

    data.game_mode = GameModes.LIST[PopupManager.lobby_menu_popup.game_mode_drop_down.selected_idx].get_id()
    is_public = PopupManager.lobby_menu_popup.public_toggle_button.button_pressed
    custom_name = PopupManager.lobby_menu_popup.name_line_edit.line_edit.text

    if connection_type_changed:
        create_lobby(true, PopupManager.lobby_menu_popup.connection_type_drop_down.selected_idx)

    match data.type:
        Type.STEAM:
            return


    if password.length():
        GDSync.lobby_change_password(password)

    GDSync.lobby_set_tag("game_mode", data.game_mode)
    GDSync.lobby_set_tag("name", custom_name)
    GDSync.lobby_set_visibility(is_public)
    updated.emit()






func _on_lobby_chat_update(lobby_id: int, changed_id: int, making_change_id: int, chat_state: int) -> void :
    if not data.type == Type.STEAM:
        return

    match chat_state:
        ISteam.steam.CHAT_MEMBER_STATE_CHANGE_ENTERED: process_client_joined(changed_id)



func _on_lobby_data_update(_lobby: int, _member: int, _success: bool) -> void :
    var game_mode: String = ISteam.steam.getLobbyData(data.steam_lobby_id, "game_mode")
    if game_mode.is_empty():
        return
    data.game_mode = game_mode



func _on_state_changed() -> void :
    var state = StateManager.get_current_state()

    if not state is MemorySelectionState:
        selected_lobby = {"Name": ""}


    if state is GameplayState:
        state.death_screen.confirm_button.pressed.connect( func():
            GDSync.lobby_set_tag("in_game", false)
            data.new_save = true
            )

        GDSync.lobby_set_tag("in_game", true)
        if data.players.size() <= 1:
            leave_lobby()


    if state is LobbyState:
        state.back_button.pressed.connect( func(): leave_lobby())
        state.lobby_chat.text_submitted.connect( func(submitted_text: String):
            if submitted_text.begins_with("/kick"):
                var args: PackedStringArray = submitted_text.split(" ")
                var idx: int = int(args[1])
                if idx == 0:
                    return
                kick_player(data.players[idx].client_id)
            )

        if get_lobby_player_count() <= 1:
            create_lobby(true, data.type)
            return


    if state is MemorySelectionState:
        state.interact_button.pressed.connect( func():
            if state.tab_container.current_tab == MemorySelectionState.Tabs.LOBBIES:
                if selected_lobby_has_password:
                    PopupManager.lobby_join_popup.show_as_password()

                    return

                if selected_lobby.has("SteamID"):
                    print("Joining Steam Lobby...")
                    Lobby.data.steam_lobby_id = selected_lobby["SteamID"]
                    Lobby.data.type = Lobby.Type.STEAM
                    ISteam.steam.joinLobby(selected_lobby["SteamID"])
                    return

                if selected_lobby["Name"].is_empty():
                    PopupManager.lobby_join_popup.show_as_ip()
                    return

                join_lobby(selected_lobby["Name"])
            )

        leave_lobby()


    if state is MainMenuState:
        leave_lobby()



func _on_lobby_creation_failed(lobby_name: String, error: int) -> void :
    print("failed creating lobby, error: ", error)




func _on_steam_join_request(lobby_name: String, has_password: bool) -> void :
    if has_password:
        PopupManager.pop(PopupManager.lobby_join_popup)
        selected_lobby["Name"] = lobby_name
        return

    print("Steam join requested: ", lobby_name)

    if not GDSync.is_active():
        lobby_to_join = lobby_name
        return

    join_lobby(lobby_name)




func _on_lobby_data_changed(key: String, value) -> void :
    print("Lobby data changed: ", key, ", ", value)
    match key:
        "new_save": data.new_save = value



func _on_lobby_join_failed(lobby_name: String, error: int) -> void :
    print("Failed join lobby: ", lobby_name, ", error code: ", error)



func _on_lobby_tag_changed(key: String, value) -> void :
    match key:
        "game_mode": data.game_mode = value
    updated.emit()





func _on_lobby_match_list(lobbies: Array) -> void :
    steam_lobbies.clear()
    for lobby in lobbies:
        ISteam.steam.requestLobbyData(lobby)

        var lobby_data: Dictionary = {
            "SteamID": int(ISteam.steam.getLobbyData(lobby, "steam_id")), 
            "PlayerLimit": ISteam.steam.getLobbyMemberLimit(lobby), 
            "PlayerCount": ISteam.steam.getNumLobbyMembers(lobby), 
            "HasPassword": false, 
            "Name": str(lobby), 

            "Tags": {
                "partner_ids": PackedStringArray(JSON.parse_string(ISteam.steam.getLobbyData(lobby, "partner_ids"))), 
                "version": ISteam.steam.getLobbyData(lobby, "version"), 
                "game_mode": ISteam.steam.getLobbyData(lobby, "game_mode"), 
                "name": ISteam.steam.getLobbyData(lobby, "name"), 
            }
        }

        steam_lobbies.push_back(lobby_data)





func _on_lobbies_received(lobbies: Array) -> void :
    gd_sync_lobbies = lobbies
    lobbies_received.emit()


func _on_lobby_created(lobby_name: String) -> void :
    data.new_save = true

    if UserData.active_memory_slot_idx > -1:
        @warning_ignore("unused_variable")
        var memory_slot: MemorySlot = UserData.memory_slots[UserData.active_memory_slot_idx]
        data.new_save = false

    print("Succesfully created lobby " + lobby_name)




func _on_steam_lobby_joined(lobby: int, permissions: int, locked: bool, response: int) -> void :
    if not data.type == Type.STEAM:
        return

    print("Succesfully joined steam lobby: ", lobby, ", ", permissions, ", ", locked, ", ", response)

    for idx in ISteam.steam.getNumLobbyMembers(Lobby.data.steam_lobby_id):
        var memeber: int = ISteam.steam.getLobbyMemberByIndex(Lobby.data.steam_lobby_id, idx)
        print("Accepting P2P session with: ", memeber)
        ISteam.steam.acceptP2PSessionWithUser(memeber)

        Net.call_func(
            receive_player_data, 
            [
            ISteam.steam.getSteamID(), 
            SaveSystem.get_data(create_own_player_data())
            ], 
            [ISteam.steam.getLobbyOwner(lobby)]
        )

    joined.emit(str(lobby))




func _on_gd_sync_lobby_joined(lobby_name: String):
    if lobby_name == created_lobby_name:
        return

    while GDSync.lobby_get_all_tags().is_empty():
        await get_tree().process_frame

    var partner_ids: PackedStringArray = GDSync.lobby_get_tag("partner_ids", [])

    data.new_save = partner_ids.is_empty()
    data.steam_lobby_id = -1
    data.type = Type.GD_SYNC

    print("Succesfully joined GDSync lobby " + lobby_name)


    if GDSync.lobby_get_player_count() > 1:
        Net.call_func(
            receive_player_data, 
            [
            Lobby.get_client_id(), 
            SaveSystem.get_data(create_own_player_data())
            ], 
            [Lobby.get_host()]
        )


    joined.emit(lobby_name)





func _on_manual_lobby_joined() -> void :
    print("joined manual lobby")

    data.steam_lobby_id = -1
    data.type = Type.MANUAL

    Net.call_func(
        receive_player_data, 
        [
        Lobby.get_client_id(), 
        SaveSystem.get_data(create_own_player_data())
        ], 
        [Lobby.get_host()]
    )

    joined.emit("manual")





func _on_gd_sync_connected() -> void :
    var state = StateManager.get_current_state()

    init_lobby_refresh_process()

    if state is LobbyState and data.type == Type.GD_SYNC:
        create_lobby(true)

    if not lobby_to_join.is_empty():
        join_lobby(lobby_to_join)
        lobby_to_join = ""



func _on_peer_disconnected(peer_id: int) -> void :
    print("Client left: ", peer_id)
    remove_player(peer_id)


func _on_client_joined(client_id: int) -> void :
    if client_id == Lobby.get_client_id():
        return
    print("Client joined: ", client_id)
    process_client_joined(client_id)


func process_client_joined(client_id: int) -> void :
    var lobby_player: LobbyPlayer = LobbyPlayer.new()
    lobby_player.client_id = client_id

    if is_lobby_owner():
        if kick_cooldowns.has(client_id):
            match data.type:
                Type.STEAM: ISteam.steam.setLobbyMemberData(client_id, "kicked", "1")
                Type.GD_SYNC: GDSync.lobby_kick_client(client_id)
            return

    for player in data.players:
        if player.client_id == client_id:
            return

    data.players.push_back(lobby_player)
    client_joined.emit(client_id)
    updated.emit()




func _on_client_left(client_id: int) -> void :
    print("Client left: ", client_id)
    remove_player(client_id)


func _on_lobby_kicked() -> void :
    print("Got kicked")
    reset_data()




func _on_peer_connected(client_id: int) -> void :
    print("peer connected: ", client_id)
    process_client_joined(client_id)


func _process(delta: float) -> void :
    for client_id in kick_cooldowns:
        kick_cooldowns[client_id] -= delta
        if kick_cooldowns[client_id] > 0.0:
            continue

        kick_cooldowns.erase(client_id)


func init_lobby_refresh_process() -> void :
    while true:
        GDSync.get_public_lobbies()

        ISteam.steam.addRequestLobbyListDistanceFilter(ISteam.steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
        ISteam.steam.requestLobbyList()

        await get_tree().create_timer(5.0).timeout



func get_default_max_players() -> int:
    if UserData.active_memory_slot_idx > -1:
        var memory_slot: MemorySlot = UserData.memory_slots[UserData.active_memory_slot_idx]
        if memory_slot.memory.partners.size() > 0:
            return memory_slot.memory.partners.size() + 1

    return 4



func create_lobby(forced: bool = false, type: Type = Type.GD_SYNC) -> void :
    if type == Type.GD_SYNC and not GDSync.is_active():
        return

    if not forced and is_in_lobby():
        print("lobby creation failed: already in lobby")
        return

    if forced:
        leave_lobby()

    reset_data(type)

    var max_players: int = get_default_max_players()
    var client_id: int = Lobby.get_client_id()
    var partner_ids: PackedStringArray = []
    var lobby_name: String = custom_name
    var is_open: bool = is_public

    if lobby_name.is_empty():
        lobby_name = Net.own_name + "'s Lobby"

    if not data.new_save:
        is_open = true


    if UserData.active_memory_slot_idx > -1:
        var memory_slot: MemorySlot = UserData.memory_slots[UserData.active_memory_slot_idx]

        for partner in memory_slot.memory.partners:
            partner_ids.push_back(partner.profile_id)

        data.game_mode = memory_slot.memory.game_mode.get_id()

        get_own_player_data().adventurer = Player.get_from_profile_id(
            memory_slot.memory.get_all_players(), 
            UserData.profile.get_id()
            ).adventurer



    created_lobby_name = RNGManager.generate_random_string(16)

    match type:
        Type.GD_SYNC:
            print("Creating GDSync lobby, max players: ", max_players, " : ", partner_ids)
            GDSync.lobby_create(created_lobby_name, "", is_open, max_players, {
                "version": System.get_version(), 
                "game_mode": data.game_mode, 
                "partner_ids": partner_ids, 
                "name": lobby_name
            })

            GDSync.lobby_created.connect( func(lobby_name: String):
                join_lobby(lobby_name)
                _on_lobby_created(lobby_name)
                )


        Type.STEAM:
            print("Creating Steam lobby, max players: ", max_players, " : ", partner_ids)
            var lobby_type = ISteam.steam.LOBBY_TYPE_FRIENDS_ONLY
            if is_public:
                lobby_type = ISteam.steam.LOBBY_TYPE_PUBLIC
            ISteam.steam.createLobby(lobby_type, max_players)

            ISteam.steam.lobby_created.connect( func(connect: int, lobby_id: int):
                if not data.type == Type.STEAM:
                    return
                ISteam.steam.setLobbyData(lobby_id, "version", System.get_version())
                ISteam.steam.setLobbyData(lobby_id, "game_mode", data.game_mode)
                ISteam.steam.setLobbyData(lobby_id, "partner_ids", str(partner_ids))

                ISteam.steam.setLobbyData(lobby_id, "steam_id", str(lobby_id))
                ISteam.steam.setLobbyData(lobby_id, "name", lobby_name)
                data.steam_lobby_id = lobby_id

                _on_lobby_created(lobby_name)
                )


        Type.MANUAL:
            var peer = ENetMultiplayerPeer.new()
            var error = peer.create_server(Net.DEFAULT_PORT, max_players)
            if error == OK:
                print("created server")
            multiplayer.multiplayer_peer = peer



    updated.emit()








func sync_trials() -> void :
    var trial_indexes: PackedInt32Array = []
    for active_trial in data.active_trials:
        trial_indexes.push_back(Trials.LIST.find(active_trial))

    Net.call_func(set_trials, [trial_indexes])



func set_trials(trial_indexes: PackedInt32Array) -> void :
    var trials: Array[Trial] = []
    for trial_idx in trial_indexes:
        trials.push_back(Trials.LIST[trial_idx])

    data.active_trials = trials
    UserData.active_trials_changed.emit()



func swap_team(sender_id: int = -1, new_team: Team.Type = Team.Type.BLUE) -> void :
    if sender_id == -1:
        if get_own_player_data().team == Team.Type.BLUE:
            new_team = Team.Type.RED
        Net.call_func(swap_team, [Lobby.get_client_id(), new_team])

    for lobby_player in data.players:
        if sender_id == -1 and lobby_player.client_id == Lobby.get_client_id():
            lobby_player.team = new_team

        if lobby_player.client_id == sender_id:
            lobby_player.team = new_team

    updated.emit()



func add_player_from_data(player_data: Dictionary) -> void :
    var lobby_player: LobbyPlayer = LobbyPlayer.new()
    SaveSystem.load_data(lobby_player, player_data)
    data.players.push_back(lobby_player)




func create_own_player_data() -> LobbyPlayer:
    var lobby_player = LobbyPlayer.new()
    var selected_adventurer: Adventurer = UserData.profile.selected_adventurer
    lobby_player.floor_number = UserData.profile.get_floor_record(selected_adventurer)
    lobby_player.border_type = AdventurerBorder.get_type(selected_adventurer, lobby_player.floor_number)
    lobby_player.profile_id = UserData.profile.get_id()
    lobby_player.name = UserData.profile.get_name()
    lobby_player.client_id = Lobby.get_client_id()
    lobby_player.adventurer = selected_adventurer

    return lobby_player



func get_own_player_data() -> LobbyPlayer:
    for lobby_player in data.players:
        if lobby_player.profile_id == UserData.profile.get_id():
            return lobby_player

    return null


func send_update_player_data() -> void :
    var own_player_data: Dictionary = SaveSystem.get_data(create_own_player_data())
    update_player_data(Lobby.get_client_id(), own_player_data)

    Net.call_func(update_player_data, [
        Lobby.get_client_id(), 
        own_player_data
        ])



func update_player_data(sender_id: int, player_data: Dictionary) -> void :
    var lobby_player: LobbyPlayer = LobbyPlayer.new()
    SaveSystem.load_data(lobby_player, player_data)

    print("updated data: ", player_data)
    print("updated data: ", lobby_player.adventurer.name)

    for idx in data.players.size():
        var player: LobbyPlayer = data.players[idx]
        if not player.client_id == sender_id:
            continue
        data.players[idx] = lobby_player
        updated.emit()






func receive_player_data(sender_id: int, player_data: Dictionary) -> void :
    var selected_memory_slot: MemorySlot = UserData.get_active_memeory_slot()
    var lobby_player: LobbyPlayer = LobbyPlayer.new()
    SaveSystem.load_data(lobby_player, player_data)

    print("received data: ", player_data)
    print("received data: ", lobby_player.adventurer.name)

    if not data.new_save and is_instance_valid(selected_memory_slot):
        var non_save_player: bool = true

        for player in selected_memory_slot.memory.get_all_players():
            if player.profile_id == lobby_player.profile_id:
                lobby_player.adventurer = player.adventurer
                non_save_player = false
                break

        if non_save_player:

            print("kicked new player")
            GDSync.lobby_kick_client(sender_id)

            return



    for idx in data.players.size():
        var player: LobbyPlayer = data.players[idx]
        if player.client_id == lobby_player.client_id:
            data.players[idx] = lobby_player


    Net.call_func(sync_lobby_data, [SaveSystem.get_data(data)])
    print("Received player data: ", sender_id)
    player_confirmed.emit(sender_id)
    updated.emit()





func sync_lobby_data(lobby_data_dict: Dictionary) -> void :
    var new_data: LobbyData = LobbyData.new()
    var old_players: PackedInt64Array = []
    SaveSystem.load_data(new_data, lobby_data_dict)

    for old_player in data.players:
        if old_player.name.is_empty():
            continue
        old_players.push_back(old_player.client_id)

    data = new_data


    for new_player in new_data.players:
        if new_player.name.is_empty():
            continue
        if old_players.has(new_player.client_id):
            continue
        player_confirmed.emit(new_player.client_id)

    data_synced.emit()
    print("Updated lobby data: ", lobby_data_dict)





func get_player_from_profile_id(profile_id: String) -> LobbyPlayer:
    for lobby_player in data.players:
        if lobby_player.profile_id == profile_id:
            return lobby_player
    return null




func get_sorted_partners(partners: Array[Player], own_client_id: int) -> Array[Player]:
    var sorted_partners: Array[Player] = []

    for lobby_player in data.players:
        if lobby_player.client_id == own_client_id:
            continue

        for idx in partners.size():
            var partner: Player = partners[idx]

            if partner.profile_id == lobby_player.profile_id:
                partner.battle_log_name = [lobby_player.name]
                partner.client_id = lobby_player.client_id
                sorted_partners.push_back(partner)
                break

    return sorted_partners





func has_player(client_id: int) -> bool:
    for idx in data.players.size():
        var existing_lobby_player: LobbyPlayer = data.players[idx]
        if existing_lobby_player.client_id == client_id:
            return true

    return false



func remove_player(client_id: int) -> void :
    for player in data.players:
        if player.client_id == client_id:
            data.players.erase(player)
            updated.emit()
            return



func get_client_id() -> int:
    match data.type:
        Type.GD_SYNC: return GDSync.get_client_id()
        Type.STEAM: return ISteam.steam.getSteamID()
        Type.MANUAL: return multiplayer.get_unique_id()

    return -1



func get_host() -> int:
    match data.type:
        Type.GD_SYNC: return GDSync.get_host()
        Type.STEAM: return ISteam.steam.getLobbyOwner(data.steam_lobby_id)
        Type.MANUAL: return 1

    return 0


func is_lobby_owner() -> bool:
    match data.type:
        Type.GD_SYNC:
            if not GDSync.is_active():
                return true

            if GDSync.lobby_get_player_count() == 1:
                return true

            return GDSync.is_host()

        Type.STEAM:
            return ISteam.steam.getLobbyOwner(data.steam_lobby_id) == ISteam.steam.getSteamID()

        Type.MANUAL:
            return multiplayer.is_server()

    return true



func get_lobby_player_count() -> int:
    match data.type:
        Type.GD_SYNC: return maxi(1, GDSync.lobby_get_player_count())
        Type.STEAM: return maxi(1, ISteam.steam.getNumLobbyMembers(data.steam_lobby_id))
        Type.MANUAL: return multiplayer.get_peers().size() + 1

    return -1


func get_max_players() -> int:
    match data.type:
        Type.GD_SYNC: return maxi(1, GDSync.lobby_get_player_limit())
        Type.STEAM: return maxi(1, ISteam.steam.getLobbyMemberLimit(data.steam_lobby_id))
        Type.MANUAL: return data.max_players

    return -1




func kick_player(client_id: int) -> void :
    kick_cooldowns[client_id] = 5.0
    GDSync.lobby_kick_client(client_id)




func join_lobby_with_ip(ip: String) -> void :
    var peer = ENetMultiplayerPeer.new()
    var error = peer.create_client(ip, Net.DEFAULT_PORT)
    if error:
        print("unable to join: ", ip)
        return

    multiplayer.multiplayer_peer = peer



func join_lobby(lobby_name: String, password: String = "") -> void :
    print("joining lobby: ", lobby_name)
    GDSync.lobby_join(lobby_name, password)



func leave_lobby() -> void :
    if is_in_lobby():
        print("leaving lobby...")

    match data.type:
        Type.GD_SYNC: GDSync.lobby_leave()
        Type.STEAM: ISteam.steam.leaveLobby(data.steam_lobby_id)
        Type.MANUAL:
            multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
            multiplayer.multiplayer_peer.close()

    reset_data()



func is_in_lobby():
    match data.type:
        Type.GD_SYNC: return not GDSync.lobby_get_name().is_empty()
        Type.STEAM: return not data.steam_lobby_id == -1
        Type.MANUAL: return multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

    return false



func reset_data(type: Type = Type.GD_SYNC) -> void :
    for player in data.players:
        player.free()

    data.players.clear()

    data.active_trials = UserData.profile.active_trials
    data.game_mode = GameModes.CHALLENGE.get_id()
    data.max_players = get_default_max_players()
    data.steam_lobby_id = -1
    data.type = type

    add_player_from_data(SaveSystem.get_data(create_own_player_data()))

    data_reset.emit()
    updated.emit()
