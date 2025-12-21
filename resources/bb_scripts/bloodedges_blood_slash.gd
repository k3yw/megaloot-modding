extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Every time you're about to attack, convert 10%"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("of your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))
    bb_container_data.push_back(BBContainerData.new(" to "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.PHYSICAL_ATTACK))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("resets every battle", Color.DIM_GRAY))


    return bb_container_data
