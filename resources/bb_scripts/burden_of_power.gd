extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Steal 75% attack damage from all enemies with "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.FEAR)
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("at the start of the turn"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("ACTIVATION CONDITION: Applied ", Color.DIM_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.FEAR)
    bb_container_data.push_back(BBContainerData.new(" on an enemy", Color.DIM_GRAY))

    return bb_container_data
