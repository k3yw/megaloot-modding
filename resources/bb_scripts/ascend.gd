extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Start an ascended run from floor 1, the "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.DIAMOND))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("you earn will be multiplied by 2"))
    bb_container_data.push_back(BBContainerData.new(" (+1 each level)", Color.DIM_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("Floor 2+ items used in previous runs will be", Color.ORANGE_RED))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("removed", Color.ORANGE_RED))

    return bb_container_data
