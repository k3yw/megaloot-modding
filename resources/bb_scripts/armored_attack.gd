extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("An attack where the damage is equals to %", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACTIVE_ARMOR))


    return bb_container_data
