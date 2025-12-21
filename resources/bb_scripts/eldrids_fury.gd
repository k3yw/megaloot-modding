extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Everytime you heal gain a stack of ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.VIMBLOW)
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("once per turn", Color.DIM_GRAY))

    return bb_container_data
