extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Receive "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.COUNTER_ATTACK_CHARGE)
    bb_container_data.push_back(BBContainerData.new(" this turn"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("ACTIVATION CONDITION: attack 3 times", Color.DIM_GRAY))

    return bb_container_data
