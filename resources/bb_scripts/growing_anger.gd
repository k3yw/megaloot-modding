extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Gain 5% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.CRIT_CHANCE))
    bb_container_data.push_back(BBContainerData.new(" every hit "))
    bb_container_data.push_back(BBContainerData.new("(resets every battle)", Color.DIM_GRAY))

    return bb_container_data
