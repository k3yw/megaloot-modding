extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("When an ally dies, gain a stack", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("of ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.PURIFICATION)

    return bb_container_data
