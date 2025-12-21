extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Doubles your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.TOTAL_ATTACKS))
    bb_container_data.push_back(BBContainerData.new(", but after every attack"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("lose 5% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACCURACY))
    bb_container_data.push_back(BBContainerData.new(" resets every turn", Color.DIM_GRAY))

    return bb_container_data
