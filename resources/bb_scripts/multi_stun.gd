extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Receive "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MULTI_ATTACK_CHARGE)
    bb_container_data.push_back(BBContainerData.new(" and "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.STUN_ATTACK_CHARGE)
    bb_container_data.push_back(BBContainerData.new(","))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("attack afterwards"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("ACTIVATION CONDITION: parry an attack", Color.DIM_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("resets every battle", Color.DIM_GRAY))

    return bb_container_data
