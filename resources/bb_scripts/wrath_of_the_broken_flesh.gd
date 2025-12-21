extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Every time your health is damaged, gain a stack of ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.FURY)


    return bb_container_data
