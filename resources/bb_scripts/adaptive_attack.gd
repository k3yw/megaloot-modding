extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
	var bb_container_data: Array[BBContainerData] = []

	bb_container_data.push_back(BBContainerData.new("Converts % of your ", Color.DARK_GRAY))
	bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACTIVE_ARMOR))
	bb_container_data.push_back(BBContainerData.new(" to ", Color.DARK_GRAY))
	bb_container_data.push_back(Stats.get_bb_container_data(Stats.ARMOR_DAMAGE))
	bb_container_data.push_back(BBContainerData.new(" dealt on hit", Color.DARK_GRAY))

	return bb_container_data
