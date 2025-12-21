extends Node

signal memory_slot_deleted(memory_slot_idx: int)
signal active_trials_changed

const MAX_BACKUPS: int = 10

var memory_slots: Array[MemorySlot] = []
var active_memory_slot_idx: int = -1

var profile: Profile = Profile.new()






func _ready() -> void :
    StateManager.state_changed.connect(_on_state_changed)
    profile.selected_adventurer = Empty.adventurer
    process_mode = ProcessMode.PROCESS_MODE_ALWAYS
    load_profile()
    load_memories()



func _on_state_changed() -> void :
    var state = StateManager.get_current_state()
    if not is_instance_valid(state):
        return

    if state is LobbyState:
        state.trial_selected.connect( func(trial: Trial):
            if profile.active_trials.has(trial):
                profile.active_trials.erase(trial)
                active_trials_changed.emit()
                return
            profile.active_trials.push_back(trial)
            active_trials_changed.emit()


            Lobby.data.active_trials = UserData.profile.active_trials
            profile.save()
            )

    if state is GameplayState:
        state.memory.enemy_encountered.connect( func(enemy_resource: EnemyResource):
            if not is_instance_valid(state):
                return
            if state.memory.game_mode == GameModes.PRACTICE:
                return
            profile.encounter_enemy(enemy_resource)
        )

        state.item_encountered.connect( func(item_resource: ItemResource):
            if not is_instance_valid(state):
                return
            if state.memory.game_mode == GameModes.PRACTICE:
                return
            profile.encounter_item(item_resource)
        )


    if state is MainMenuState:
        profile.save()

    if state is MemorySelectionState:
        state.delete_button.pressed.connect( func(): delete_memory_slot(state.selected_memory_slot_idx))
        UserData.active_memory_slot_idx = -1



func get_or_add_memory_slot(new_memory_slot: MemorySlot) -> int:
    for idx in memory_slots.size():
        var memory_slot: MemorySlot = memory_slots[idx]
        if not is_instance_valid(memory_slot):
            continue

        if not memory_slot.memory.start_time == new_memory_slot.memory.start_time:
            continue

        if memory_slot.memory.id == new_memory_slot.memory.id:
            memory_slots[idx] = new_memory_slot
            return idx

        if memory_slot.memory.tower_seed == new_memory_slot.memory.tower_seed:
            memory_slots[idx] = new_memory_slot
            return idx

    for idx in memory_slots.size():
        var memory_slot: MemorySlot = memory_slots[idx]
        if not is_instance_valid(memory_slot):
            memory_slots[idx] = new_memory_slot
            return idx

    memory_slots.push_back(new_memory_slot)

    return memory_slots.size() - 1






func delete_memory_slot(memory_slot_idx: int) -> void :
    var backups_path: String = File.get_user_file_dir() + "/backups/memory_slot_" + str(memory_slot_idx)
    var memory_slots_path: String = File.get_user_file_dir() + "/memory_slots"
    memory_slots[memory_slot_idx] = null

    DirAccess.remove_absolute(memory_slots_path + "/memory_slot_" + str(memory_slot_idx) + ".save")
    DirAccess.remove_absolute(backups_path)

    active_memory_slot_idx = -1

    memory_slot_deleted.emit(memory_slot_idx)








func save_memory_slot(idx: int) -> void :
    var memory_slots_path: String = File.get_user_file_dir() + "/memory_slots"
    var memory_slot: MemorySlot = MemorySlot.new()
    var memory_slots_dir = DirAccess.open(memory_slots_path)


    if memory_slots_dir == null:
        DirAccess.make_dir_recursive_absolute(memory_slots_path)


    SaveSystem.save_encrypted(memory_slots[idx], memory_slots_path + "/memory_slot_" + str(idx) + ".save")






func load_profile() -> void :
    print("loading profile")
    SaveSystem.load_encrypted(profile, Profile.get_save_path())
    if not is_instance_valid(profile.selected_adventurer):
        profile.selected_adventurer = Empty.adventurer

    var build: ItemContainer = UserData.profile.get_selected_build()
    if build.items.size() < build.resource.size:
        UserData.profile.builds[UserData.profile.selected_build_idx] = ItemContainer.new(ItemContainerResources.BUILD, ItemContainerResources.BUILD.size)

    print(profile.id)
    print("finished loading profile")






func load_memories() -> void :
    var memory_slots_path: String = File.get_user_file_dir() + "/memory_slots"
    var memory_slots_dir = DirAccess.open(memory_slots_path)
    var new_memory_slots: Array[MemorySlot] = []

    if memory_slots_dir == null:
        DirAccess.make_dir_recursive_absolute(memory_slots_path)

    var memory_slot_names: Array[String] = File.get_file_paths(memory_slots_path)
    for memory_slot_name in memory_slot_names:
        var memory_slot: MemorySlot = MemorySlot.new()
        var idx: int = int(memory_slot_name.split("memory_slot_")[1].replace(".save", ""))
        new_memory_slots.resize(maxi(new_memory_slots.size(), idx + 1))
        SaveSystem.load_encrypted(memory_slot, memory_slots_path + "/" + memory_slot_name)
        new_memory_slots[idx] = memory_slot


    memory_slots = new_memory_slots







func get_active_memeory_slot() -> MemorySlot:
    if active_memory_slot_idx == -1:
        return null
    return memory_slots[active_memory_slot_idx]


func get_memeory_slot(memory_slot_idx: int) -> MemorySlot:
    if memory_slot_idx == -1:
        return null
    return memory_slots[memory_slot_idx]


func has_memory_slot() -> bool:
    for memory_slot in memory_slots:
        if is_instance_valid(memory_slot):
            return true

    return false



func create_backup(memory_slot_idx: int) -> void :
    var timestamp: String = Time.get_datetime_string_from_system().replace(":", "_").replace("T", "_").replace("-", "_")
    var backups_path: String = File.get_user_file_dir() + "/backups/memory_slot_" + str(memory_slot_idx)
    var backups_dir = DirAccess.open(backups_path)

    if backups_dir == null:
        DirAccess.make_dir_recursive_absolute(backups_path)

    SaveSystem.save_encrypted(memory_slots[memory_slot_idx], MemorySlot.get_backup_save_path(memory_slot_idx, timestamp))
    var backup_file_names: Array[String] = File.get_file_paths(backups_path)

    for idx in range(backup_file_names.size() - 1, -1, -1):
        var file_name: String = backup_file_names[idx]
        if backup_file_names.size() - idx > MAX_BACKUPS:
            DirAccess.remove_absolute(backups_path + "/" + file_name)

    print("creating backup file")




func set_practice_mode(practice_mode: bool) -> void :
    profile.practice_mode = practice_mode
