extends BBScript







func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("At the start of the turn, apply ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.SILENCE)
    bb_container_data.push_back(BBContainerData.new("\n", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("on first enemy with an ability", Color.DARK_GRAY))

    return bb_container_data
