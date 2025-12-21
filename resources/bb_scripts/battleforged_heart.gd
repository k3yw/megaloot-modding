extends BBScript







func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("After your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ARMOR))
    bb_container_data.push_back(BBContainerData.new(" is damaged, convert"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("that amount to "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("resets every battle", Color.DIM_GRAY))

    return bb_container_data
