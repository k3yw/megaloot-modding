extends Node

# ! Comments prefixed with "!" mean they are extra info. Comments without them
# ! should be kept because they give your mod structure and make it easier to
# ! read by other modders
# ! Comments with "?" should be replaced by you with the appropriate information

# ! This template file is statically typed. You don't have to do that, but it can help avoid bugs
# ! You can learn more about static typing in the docs
# ! https://docs.godotengine.org/en/3.5/tutorials/scripting/gdscript/static_typing.html

# ? Makes dismantle floor more often to appear, starts by default at 10th floor and repeats every 5th floor instead of every 25th
# ? ...Also makes you accumulate +1 diamonds from chests (multiplicative)

const MOD_DIR := "k3ywarrior-More_dismantle" # Name of the directory that this file is in
const LOG_NAME := "k3ywarrior-More_dismantle:Main" # Full ID of the mod (AuthorName-ModName)

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""


# ! your _ready func.
func _init() -> void:
	ModLoaderLog.info("Init", LOG_NAME)
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	# Add extensions
	install_hooks()
	
func install_hooks() -> void:
	ModLoaderMod.add_hook(
		add_diamonds, 
		"res://scenes/managers/character_manager/character_manager.gd",
		"add_diamonds"
	)
	
	ModLoaderMod.add_hook(
		get_last_room, 
		"res://resources/game_mode_scripts/challenge.gd",
		"get_last_room"
	)
	
func add_diamonds(chain: ModLoaderHookChain, player: Player, amount: float, silent: bool = false) -> void:
	if not amount:
		return
	amount = amount + 1
	await chain.execute_next([player, amount, silent])

func get_last_room(chain: ModLoaderHookChain, floor_number: int) -> RoomResource:
	if floor_number >= 9 and (floor_number - 9) % 5 == 0:
		chain.execute_next([floor_number])
		return Rooms.DISMANTLE
	return chain.execute_next([floor_number])
	
func _ready() -> void:
	ModLoaderLog.info("Ready", LOG_NAME)

	# ! This uses Godot's native `tr` func, which translates a string. You'll
	# ! find this particular string in the example CSV here: translations/modname.csv
	#ModLoaderLog.info("Translation Demo: " + tr("MODNAME_READY_TEXT"), LOG_NAME)
	# OS.alert("This is the alert message!", "Alert Title")
