extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("When attacking, consume one stack and gain bonus ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.PHYSICAL_ATTACK))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("equal to 25% of your ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))

    return bb_container_data
