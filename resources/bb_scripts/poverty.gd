extends BBScript










func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" While below 25% ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))
    bb_container_data.push_back(BBContainerData.new(", gain 75% ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.CRIT_CHANCE))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" Gain ", Color.DARK_GRAY))
    bb_container_data.push_back(Keywords.get_bb_container_data(Keywords.ANTI_STEAL))

    return bb_container_data
