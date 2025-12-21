extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Enemies with ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.FEAR)
    bb_container_data.push_back(BBContainerData.new(" won't attack you", Color.DARK_GRAY))

    return bb_container_data
