extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" All enemies gain +1 to "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.TOTAL_ATTACKS))

    return bb_container_data
