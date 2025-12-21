extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Next time you about to get hit, break one shield and", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("ignore ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ARMOR, Stats.DisplayMode.UNKNOWN))
    bb_container_data.push_back(BBContainerData.new("+1", Stats.ARMOR.color))
    bb_container_data.push_back(BBContainerData.new(" damage", Color.DARK_GRAY))

    return bb_container_data
