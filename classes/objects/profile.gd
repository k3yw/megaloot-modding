class_name Profile extends RefCounted

signal selected_build_idx_changed
signal saved

const FILE_NAME: String = "profile"
const FILE_TYPE: String = "save"

var encountered_enemies: Array[EnemyResource] = []
var encountered_items: Array[ItemResource] = []


var builds: Array[ItemContainer] = [ItemContainer.new(ItemContainerResources.BUILD, ItemContainerResources.BUILD.size)]
var selected_build_idx: int = 0

var selected_adventurer: Adventurer = Empty.adventurer
var active_trials: Array[Trial] = []

var floor_records: Array[FloorRecord] = []
var seen_tutorial_popup: bool = false
var id: String = UUID.v4()
var temp_id: String = ""




func _init() -> void :
	for item in Items.LIST:
		if not item.spawn_floor == 1:
			continue

		encountered_items.push_back(item)




func set_selected_build_idx(idx: int) -> void :
	selected_build_idx = idx
	selected_build_idx_changed.emit()



func get_selected_build() -> ItemContainer:
	return builds[mini(selected_build_idx, builds.size() - 1)]




func fix_builds() -> void :
	for idx in range(builds.size() - 1, -1, -1):
		if idx == 0:
			break

		if builds[idx].get_items().size() == 0:
			builds.remove_at(idx)

	selected_build_idx = mini(selected_build_idx, builds.size() - 1)


func encounter_enemy(enemy_resource: EnemyResource) -> void :
	if encountered_enemies.has(enemy_resource):
		return

	encountered_enemies.push_back(enemy_resource)



func encounter_item(item_resource: ItemResource) -> void :
	if encountered_items.has(item_resource):
		return

	encountered_items.push_back(item_resource)





func save() -> void :
	fix_builds()
	temp_id = ""
	SaveSystem.save_encrypted(self, Profile.get_save_path())





func set_floor_record(adventurer: Adventurer, record: int) -> void :
	for floor_record in floor_records:
		if not is_instance_valid(floor_record):
			continue

		if floor_record.adventurer == adventurer and floor_record.version == System.get_version():
			floor_record.record = maxi(floor_record.record, record)
			return

	var floor_record = FloorRecord.new()
	floor_record.version = System.get_version()
	floor_record.adventurer = adventurer
	floor_record.record = record
	floor_records.push_back(floor_record)
	save()




func get_floor_record(adventurer: Adventurer, version: String = System.get_version()) -> int:
	for floor_record in floor_records:
		if not is_instance_valid(floor_record):
			continue

		if floor_record.adventurer == adventurer and floor_record.version == version:
			return floor_record.record

	return 0




func get_name() -> String:
	if ISteam.is_active():
		if not temp_id.is_empty():
			return "[ALT] " + ISteam.get_own_name()
		return ISteam.get_own_name()

	return "Player"


func get_id() -> String:
	if not temp_id.is_empty():
		return temp_id
	return id



static func get_save_path() -> String:
	return File.get_user_file_dir() + "/" + FILE_NAME + "." + FILE_TYPE


static func get_backup_save_path(memory_slot_idx: int, date: String) -> String:
	return File.get_user_file_dir() + "/backups/memory_slot_" + str(memory_slot_idx) + "/" + date + "_" + FILE_NAME + "." + FILE_TYPE
