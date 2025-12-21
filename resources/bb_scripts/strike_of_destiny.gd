extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Remove all buffs from the target on hit"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("if you have "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.INVULNERABILITY)

    return bb_container_data
