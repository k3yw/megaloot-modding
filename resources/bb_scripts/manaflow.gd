extends BBScript












func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Sets your", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_MANA))
    bb_container_data.push_back(BBContainerData.new(" to 1", Color.DARK_GRAY))

    return bb_container_data
