extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Absorb damage in place of ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))


    return bb_container_data
