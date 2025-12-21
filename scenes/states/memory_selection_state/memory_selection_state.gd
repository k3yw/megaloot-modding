class_name MemorySelectionState extends Node

enum Tabs{MEMORIES, LOBBIES}


@export var tab_container: GenericTabContainer
@export var memory_slot_holder: AnimatedBoxContainer
@export var scroll_container: GenericScrollContainer
@export var lobby_info_container: LobbyContainer
@export var user_folder_button: TabButton
@export var interact_button: GenericButton
@export var delete_button: GenericButton
@export var lobby_holder: VBoxContainer
@export var back_button: GenericButton

var selected_lobby_container: LobbyContainer = null
var selected_memory_slot_idx: int = -1






func _ready() -> void :
    Lobby.lobbies_received.connect( func(): update_public_lobbies())
    UserData.memory_slot_deleted.connect(_on_memory_slot_deleted)

    lobby_info_container.players_label.text = lobby_info_container.players_label.text.capitalize()
    lobby_info_container.name_label.text = lobby_info_container.name_label.text.capitalize()

    update_memory_slot_containers()
    update_memory_slot_selection()
    update_public_lobbies()



func _on_memory_slot_deleted(memory_slot_idx: int):
    for child in memory_slot_holder.get_children():
        child = child as MemorySlotContainer
        if child.memory_slot_idx == memory_slot_idx:
            child.hide()
            child.queue_free()
    memory_slot_holder.process_size.call_deferred()
    scroll_container.update.call_deferred()

func update_memory_slot_containers() -> void :
    for child in memory_slot_holder.get_children():
        memory_slot_holder.remove_child(child)
        child.queue_free()

    var sorted_memory_slots: Array[MemorySlot] = UserData.memory_slots.duplicate()
    sorted_memory_slots.sort_custom(sort_memory_slots)

    for memory_slot in sorted_memory_slots:
        add_memory_slot_container(UserData.memory_slots.find(memory_slot))

    memory_slot_holder.process_size.call_deferred()
    scroll_container.update.call_deferred()




func sort_memory_slots(a: MemorySlot, b: MemorySlot) -> bool:
    if not is_instance_valid(a) or not is_instance_valid(b):
        return false

    return a.memory.last_save_time >= b.memory.last_save_time


func _process(_delta: float) -> void :
    if Input.is_action_just_pressed("press"):
        if UI.is_hovered(user_folder_button):
            var memory_slots_path: String = File.get_user_file_dir() + "/memory_slots"
            OS.shell_open(memory_slots_path)
            return

    process_buttons()





func process_buttons() -> void :
    var selected_memory_slot: MemorySlot = UserData.get_memeory_slot(selected_memory_slot_idx)
    interact_button.text = T.get_translated_string("Select Save Slot").to_upper()
    interact_button.disabled = false
    delete_button.disabled = false

    if tab_container.current_tab == Tabs.LOBBIES:
        var join_text: String = T.get_translated_string("join lobby").to_upper()
        interact_button.disabled = Lobby.selected_lobby.is_empty()
        interact_button.text = join_text
        return

    if not is_instance_valid(selected_memory_slot):
        interact_button.text = T.get_translated_string("New Journey").to_upper()
        delete_button.disabled = true
        return


    if selected_memory_slot.memory.can_ascend():
        interact_button.text = T.get_translated_string("ascend").to_upper()
        return


    if selected_memory_slot.memory.is_game_ended:
        interact_button.disabled = true

    if OS.is_debug_build():
        interact_button.disabled = false



func add_memory_slot_container(idx: int) -> void :
    var memory_slot: MemorySlot = UserData.memory_slots[idx]

    if not is_instance_valid(memory_slot):
        return

    var memory_slot_container: MemorySlotContainer = preload("res://scenes/ui/memory_slot_container/memory_slot_container.tscn").instantiate()
    memory_slot_container.selected.connect( func():
        var new_idx: int = idx
        if selected_memory_slot_idx == idx:
            new_idx = -1
        selected_memory_slot_idx = new_idx
        update_memory_slot_selection()
        )

    memory_slot_holder.add_child(memory_slot_container)
    memory_slot_container.memory_slot_idx = idx

    memory_slot_container.update(memory_slot.memory)




func update_memory_slot_selection() -> void :
    for child in memory_slot_holder.get_children():
        if child is MemorySlotContainer:
            child.selection_panel.visible = child.memory_slot_idx == selected_memory_slot_idx







func update_public_lobbies() -> void :
    for child in lobby_holder.get_children():
        lobby_holder.remove_child(child)
        child.queue_free()

    selected_lobby_container = null
    for lobby in Lobby.gd_sync_lobbies + Lobby.steam_lobbies:
        var game_mode: String = GameModes.CHALLENGE.get_id()
        var partner_ids: PackedStringArray = []
        var in_game: bool = false


        if lobby["PlayerCount"] == lobby["PlayerLimit"]:
            continue


        if not (lobby["Tags"] as Dictionary).has("version"):
            continue

        if not lobby["Tags"]["version"] == System.get_version():
            continue

        if (lobby["Tags"] as Dictionary).has("in_game"):
            in_game = lobby["Tags"]["in_game"]


        if (lobby["Tags"] as Dictionary).has("partner_ids"):
            partner_ids = lobby["Tags"]["partner_ids"]


        if (lobby["Tags"] as Dictionary).has("game_mode"):
            game_mode = lobby["Tags"]["game_mode"]

        if not OS.is_debug_build():
            if not partner_ids.is_empty() and not partner_ids.has(UserData.profile.id):
                continue

        if in_game:
            continue

        var lobby_container: LobbyContainer = preload("res://scenes/ui/lobby_container/lobby_container.tscn").instantiate()
        var custom_name: String = ""

        if (lobby["Tags"] as Dictionary).has("name"):
            custom_name = lobby["Tags"]["name"]

        lobby_container.selected.connect( func():
            if is_instance_valid(selected_lobby_container):
                selected_lobby_container.selection_panel.hide()

            selected_lobby_container = lobby_container
            lobby_container.selection_panel.show()

            Lobby.selected_lobby_has_password = lobby["HasPassword"]
            Lobby.selected_lobby["Name"] = lobby["Name"]
            if lobby.has("SteamID"):
                Lobby.selected_lobby["SteamID"] = lobby["SteamID"]
            )

        lobby_container.set_lobby_name(lobby["Name"], custom_name)

        if lobby_container.lobby_name == Lobby.selected_lobby["Name"]:
            selected_lobby_container = lobby_container
            lobby_container.selection_panel.show()

        lobby_container.players_label.text = str(lobby["PlayerCount"]) + "/" + str(lobby["PlayerLimit"])
        lobby_container.game_mode_label.text = GameModes.from_name(game_mode).get_translated_name()
        lobby_container.lock_texture_rect.visible = lobby["HasPassword"]
        lobby_container.locked_label.hide()
        lobby_holder.add_child(lobby_container)


    if not is_instance_valid(selected_lobby_container):
        Lobby.selected_lobby_has_password = false
        Lobby.selected_lobby.erase("SteamID")
        Lobby.selected_lobby["Name"] = ""





func _on_generic_tab_container_tab_changed(tab: int) -> void :
    delete_button.visible = tab == Tabs.MEMORIES
