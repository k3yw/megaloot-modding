extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Apply 5 stacks of "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.ENERVATION)
    bb_container_data.push_back(BBContainerData.new(" to all enemies"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("ACTIVATION CONDITION: receive a hit from an enemy with ", Color.DIM_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.POISON)

    return bb_container_data
