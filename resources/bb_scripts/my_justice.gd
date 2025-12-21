extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Receive "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.INVULNERABILITY)
    bb_container_data.push_back(BBContainerData.new(" and "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.COUNTER_ATTACK_CHARGE)
    bb_container_data.push_back(BBContainerData.new(" this turn"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("ACTIVATION CONDITION: receive ", Color.DIM_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.INVULNERABILITY)

    return bb_container_data
