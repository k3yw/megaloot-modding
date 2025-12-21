extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("At the end of the turn, transform opponents status effects"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.WEAKNESS)
    bb_container_data.push_back(BBContainerData.new(" into "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.ENERVATION)
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.CURSE)
    bb_container_data.push_back(BBContainerData.new(" into "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.BLACK_CURSE)



    return bb_container_data
