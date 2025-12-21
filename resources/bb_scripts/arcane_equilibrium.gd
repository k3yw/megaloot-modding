extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("At the end of every turn, convert everyone's"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.INVULNERABILITY)
    bb_container_data.push_back(BBContainerData.new(" into "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MAGIC_SHIELD)


    return bb_container_data
