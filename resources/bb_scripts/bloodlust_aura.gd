extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Apply "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MADNESS)
    bb_container_data.push_back(BBContainerData.new(" to all enemies"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("ACTIVATION CONDITION: ", Color.DIM_GRAY))
    bb_container_data.push_back(Keywords.get_bb_container_data(Keywords.HEAL))
    bb_container_data.push_back(BBContainerData.new(" 25% of", Color.DIM_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("your ", Color.DIM_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))
    bb_container_data.push_back(BBContainerData.new(" in one turn", Color.DIM_GRAY))

    return bb_container_data
