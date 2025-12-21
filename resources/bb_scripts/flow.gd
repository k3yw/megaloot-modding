extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Unable to take a turn while "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.FLOW))
    bb_container_data.push_back(BBContainerData.new(" is below 0%"))

    return bb_container_data
