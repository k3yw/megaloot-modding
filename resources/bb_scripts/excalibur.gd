extends BBScript






func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("\"a gift from the lake\"", Color.DIM_GRAY))

    return bb_container_data
