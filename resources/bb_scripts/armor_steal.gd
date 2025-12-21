extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("The amount of "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ARMOR))
    bb_container_data.push_back(BBContainerData.new(" to steal from the target on hit"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("You cannot steal more than your missing ", Color.DIM_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ARMOR))


    return bb_container_data
