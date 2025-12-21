extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Removes a random debuff and reduces your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.FAITH))
    bb_container_data.push_back(BBContainerData.new(" by 25%"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("resets every battle", Color.DIM_GRAY))

    return bb_container_data
