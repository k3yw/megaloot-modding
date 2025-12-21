extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Steal 1 "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MANA))
    bb_container_data.push_back(BBContainerData.new(" on hit"))

    return bb_container_data
