extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Gain +100% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAGIC_ATTACK))
    bb_container_data.push_back(BBContainerData.new(" on the first turn"))

    return bb_container_data
