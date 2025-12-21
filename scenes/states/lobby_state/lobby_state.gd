class_name LobbyState extends Node

signal trial_selected(trial: Trial)



@export var lobby_menu_button: GenericButton
@export var begin_button: GenericButton
@export var back_button: GenericButton

@export_group("Team Nodes")
@export var blue_team_lobby_player_container_holder: VBoxContainer
@export var red_team_lobby_player_container_holder: VBoxContainer

@export var blue_team_container: VBoxContainer
@export var red_team_container: VBoxContainer
@export var blue_team_label: GenericLabel

@export var blue_team_join_label_button: LabelButton
@export var red_team_join_label_button: LabelButton


@export_group("")
@export var trial_container_holder: GridContainer

@export var connected_players_label: GenericLabel
@export var game_mode_label: GenericLabel

@export var lobby_chat: Chat


var selected_memory_slot: MemorySlot = UserData.get_active_memeory_slot()
var profile: Profile = UserData.profile




func _ready() -> void :
    var adventurers: Array[Adventurer] = Adventurers.get_list()
    for idx in adventurers.size():
        var card_container: AdventurerTreeNode = PopupManager.adventurer_selection_popup.card_holder.get_child(idx)
        card_container.pressed.connect( func():
            UserData.profile.selected_adventurer = adventurers[idx]
            Lobby.send_update_player_data()
            update_lobby_ui()
            await get_tree().process_frame
            PopupManager.adventurer_selection_popup.hide()
            )

    Lobby.client_joined.connect( func(_client_id: int): get_window().request_attention())
    Lobby.joined.connect( func(_lobby_name: String): update_lobby_ui())
    Lobby.data_synced.connect(update_lobby_ui)
    Lobby.updated.connect(update_lobby_ui)

    add_trial_containers()
    update_lobby_ui()









func _process(_delta: float) -> void :
    lobby_menu_button.disabled = not Lobby.is_lobby_owner()

    if lobby_menu_button.is_pressed:
        PopupManager.pop(PopupManager.lobby_menu_popup)


    process_trial_containers()
    process_ui()



func process_ui() -> void :
    update_connected_players()
    update_game_mode()
    process_begin_button()


    if blue_team_join_label_button.is_pressed or red_team_join_label_button.is_pressed:
        Lobby.swap_team()




func process_begin_button() -> void :
    if not Lobby.is_lobby_owner():
        begin_button.disabled = true
        return

    for lobby_player in Lobby.data.players:
        if lobby_player.adventurer.name.is_empty():
            begin_button.disabled = true
            return

    if not Lobby.data.new_save:
        if not is_instance_valid(selected_memory_slot):
            begin_button.disabled = true
            return

        if not selected_memory_slot.memory.partners.size() + 1 == Lobby.get_lobby_player_count():
            begin_button.disabled = true
            return


    if Lobby.data.game_mode == GameModes.PVP.get_id():
        var blue_team_players: int = 0
        var red_team_players: int = 0

        for player in Lobby.data.players:
            if player.team == Team.Type.BLUE:
                blue_team_players += 1

            if player.team == Team.Type.RED:
                red_team_players += 1

        if blue_team_players == 0 or red_team_players == 0:
            begin_button.disabled = true
            return


    begin_button.disabled = false





func add_trial_containers() -> void :
    for trial_idx in Trials.LIST.size():
        var trial: Trial = Trials.LIST[trial_idx]
        var trial_container: IconButton = preload("res://scenes/ui/icon_button/icon_button.tscn").instantiate()
        trial_container_holder.add_child(trial_container)
        trial_container.add_to_group("visible_by_joypad")
        trial_container.set_trial(trial)

        trial_container.pressed.connect( func():
            if not Lobby.is_lobby_owner():
                return

            trial_selected.emit(trial)
            Lobby.sync_trials()
            )




func process_trial_containers():
    for idx in Trials.LIST.size():
        var trial: Trial = Trials.LIST[idx]
        var trial_container: IconButton = trial_container_holder.get_child(idx)

        if not is_instance_valid(trial_container):
            continue

        trial_container.selected = Lobby.data.active_trials.has(trial)

        if not Lobby.data.new_save:
            trial_container.locked = true
            continue

        trial_container.locked = not Lobby.is_lobby_owner()




func update_lobby_ui() -> void :
    clear_lobby_player_containers()


    for player in Lobby.data.players:
        var lobby_player_container = preload("res://scenes/ui/lobby_player_container/lobby_player_container.tscn").instantiate()
        var border_type: AdventurerBorder.Type = player.border_type
        var selected_adventurer: Adventurer = player.adventurer

        if player.team == Team.Type.BLUE:
            blue_team_lobby_player_container_holder.add_child(lobby_player_container)

        if player.team == Team.Type.RED:
            red_team_lobby_player_container_holder.add_child(lobby_player_container)


        if player.profile_id == UserData.profile.get_id():
            var is_adventurer_selected: bool = not selected_adventurer == Empty.adventurer

            if not is_instance_valid(selected_adventurer):
                is_adventurer_selected = false

            lobby_player_container.disabled = not Lobby.data.new_save

            if not lobby_player_container.disabled:
                lobby_player_container.adventurer_portrait.add_to_group("pressable")
            lobby_player_container.own_container = true


            if not is_adventurer_selected:
                lobby_player_container.select_adventurer_label.show()


        lobby_player_container.adventurer_portrait.border_texture_rect.texture = AdventurerBorder.get_texture(border_type)
        lobby_player_container.adventurer_portrait.set_adventurer(selected_adventurer)
        lobby_player_container.name_label.text = player.name




    blue_team_join_label_button.visible = Lobby.data.game_mode == GameModes.PVP.get_id()
    red_team_join_label_button.visible = Lobby.data.game_mode == GameModes.PVP.get_id()

    blue_team_label.visible = Lobby.data.game_mode == GameModes.PVP.get_id()
    red_team_container.visible = Lobby.data.game_mode == GameModes.PVP.get_id()


    if Lobby.data.game_mode == GameModes.PVP.get_id():
        var own_data: LobbyPlayer = Lobby.get_own_player_data()
        if own_data.team == Team.Type.BLUE:
            blue_team_join_label_button.hide()

        if own_data.team == Team.Type.RED:
            red_team_join_label_button.hide()





func update_connected_players() -> void :
    connected_players_label.text = str(Lobby.data.players.size()) + "/" + str(Lobby.get_max_players())


func update_game_mode() -> void :
    var game_mode: GameMode = GameModes.from_name(Lobby.data.game_mode)
    if not is_instance_valid(game_mode):
        return
    game_mode_label.text = game_mode.get_translated_name().to_upper()


func clear_lobby_player_containers() -> void :
    for child in blue_team_lobby_player_container_holder.get_children():
        if child is LobbyPlayerContainer:
            child.queue_free()

    for child in red_team_lobby_player_container_holder.get_children():
        if child is LobbyPlayerContainer:
            child.queue_free()




func get_trial_containers() -> Array[IconButton]:
    var trial_containers: Array[IconButton] = []

    for child in trial_container_holder.get_children():
        if child is IconButton:
            trial_containers.push_back(child)

    return trial_containers
