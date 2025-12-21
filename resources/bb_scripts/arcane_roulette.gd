extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Every time your "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MAGIC_SHIELD)
    bb_container_data.push_back(BBContainerData.new(" breaks, attack a random"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("enemy"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("ACTIVATION CONDITION: have an active ", Color.DIM_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MAGIC_SHIELD)

    return bb_container_data
