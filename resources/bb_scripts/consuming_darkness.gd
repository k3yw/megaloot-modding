extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("When an enemy with "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.FEAR)
    bb_container_data.push_back(BBContainerData.new(" and "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.CONFUSION)
    bb_container_data.push_back(BBContainerData.new(" is killed,"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("gain all it's base stats "))
    bb_container_data.push_back(BBContainerData.new("(resets every battle)", Color.DIM_GRAY))

    return bb_container_data
