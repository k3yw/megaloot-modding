extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Every time your health is about to take damage,", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("negate it, convert it to ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.POISON)
    bb_container_data.push_back(BBContainerData.new(" and apply", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("on yourself", Color.DARK_GRAY))

    return bb_container_data
