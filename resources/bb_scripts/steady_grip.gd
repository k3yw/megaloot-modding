extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Increase your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.TOTAL_ATTACKS))
    bb_container_data.push_back(BBContainerData.new(" by 1 for this battle"))


    return bb_container_data
