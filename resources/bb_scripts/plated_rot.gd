extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Damage dealt to "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ARMOR))
    bb_container_data.push_back(BBContainerData.new(", will be converted to "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))


    return bb_container_data
