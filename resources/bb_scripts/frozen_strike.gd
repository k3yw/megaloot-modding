extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Apply 3 stacks ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.WEAKNESS)
    bb_container_data.push_back(BBContainerData.new(" to target on hit", Color.DARK_GRAY))

    return bb_container_data
