extends BBScript












func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Grants 1 stack of ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.CINDER_ESSENCE)
    bb_container_data.push_back(BBContainerData.new(" before", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new(" \n"))
    bb_container_data.push_back(BBContainerData.new("the start of the turn", Color.DARK_GRAY))

    return bb_container_data
