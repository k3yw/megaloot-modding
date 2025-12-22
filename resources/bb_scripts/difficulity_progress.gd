extends BBScript





var room_mapping = {
	"CHEST": {
		"key": "golden_chest",
		"bb_container_properties": {
			"icon": load("res://assets/textures/deprecated/icons/chest_icon.png"),
			"color_text": Color.ORANGE,
			"color_icon": Color.DARK_ORANGE
		}
	},
	"DISMANTLE": {
		"type": "button",
		"bb_container_properties": {
			"icon": load("res://assets/textures/icons/dismantle_icon.png"),
			"color_text": Color(0.368627, 0.501961, 0.486275, 1),
			"color_icon": Color(0.368627, 0.501961, 0.486275, 1)
		}
	},
	"MERCHANT": {
		"bb_container_properties": {
			"icon": load("res://assets/textures/icons/rooms/merchant_icon.png"),
			"color_text": Color.SANDY_BROWN,
			"color_icon": Color(0.956863, 0.643137, 0.376471, 1)
		}
	},
	"MYSTIC_TRADER": {
		"bb_container_properties": {
			"icon": load("res://assets/textures/icons/status_effects/confusion_icon.png"),
			"color_text": Color.SLATE_BLUE,
			"color_icon": Color.DARK_SLATE_BLUE
		}
	}
}

func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
	var bb_container_data: Array[BBContainerData] = []
	var battles_remaining: int = 0
	var gold_per_kill: int = 0
	var rooms_upcoming;
	

	if args.size() > 2:
		battles_remaining = args[2] as int
		gold_per_kill = args[1] as int
		
	if args.size() > 3 and typeof(args[3]) == TYPE_DICTIONARY:
		rooms_upcoming = args[3]

	if T.translations.size():
		var battles_remaining_text: String = T.get_translated_string("Battles Remaining", "Text").to_lower() + ": "
		var gold_per_kill_text: String = T.get_translated_string("Gold Per Kill", "Text").to_lower() + ": "

		bb_container_data.push_back(BBContainerData.new(gold_per_kill_text))
		bb_container_data.push_back(BBContainerData.new(Format.number(gold_per_kill, [Format.Rules.USE_SUFFIX]) + " ", Stats.GOLD.color))
		bb_container_data.push_back(Stats.get_bb_container_data(Stats.GOLD))
		bb_container_data.push_back(BBContainerData.new("\n"))

		bb_container_data.push_back(BBContainerData.new(battles_remaining_text + str(battles_remaining + 1)))
		
		for rooms_upcoming_key in rooms_upcoming:
			var value = rooms_upcoming[rooms_upcoming_key]
			if value >= 0:
				var room_data = {
					"key": rooms_upcoming_key,
					"type": "enemy-name",
					"bb_container_properties": null
				}

				if room_mapping.has(rooms_upcoming_key):
					var mapping_value = room_mapping[rooms_upcoming_key]
					for data_key in room_data:
						if mapping_value.has(data_key):
							room_data[data_key] = mapping_value[data_key]
				
				bb_container_data.push_back(BBContainerData.new("\n"))
				var bb_string = "%s: %d" % [
					T.get_translated_string(
						room_data.key.to_lower(), room_data.type
					).to_lower(), value
				]
				
				var container_props = room_data.bb_container_properties
				if container_props != null:
					var test_bb_container_data = BBContainerData.new()

					test_bb_container_data.text = " " + bb_string
					test_bb_container_data.stat_resource = Stats.GOLD
					test_bb_container_data.left_image = container_props.icon
					test_bb_container_data.left_image_color = container_props.color_icon
					test_bb_container_data.text_color = container_props.color_text
					bb_container_data.push_back(test_bb_container_data)
				else:
					bb_container_data.push_back(BBContainerData.new(bb_string))

		return bb_container_data


	return bb_container_data
