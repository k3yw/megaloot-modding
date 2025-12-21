class_name MemorySlot extends Object


const FILE_NAME: String = "memory_slot"
const FILE_TYPE: String = "save"

var phantom_memory: Memory = Memory.new()
var memory: Memory = Memory.new()











static func get_backup_save_path(memory_slot_idx: int, date: String) -> String:
    return File.get_user_file_dir() + "/backups/memory_slot_" + str(memory_slot_idx) + "/" + date + "_" + FILE_NAME + "_" + str(memory_slot_idx) + "." + FILE_TYPE
