extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Receive +5 "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.TOTAL_ATTACKS))
    bb_container_data.push_back(BBContainerData.new(" but your first 5"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("attacks will deal 99% less damage"))


    return bb_container_data
