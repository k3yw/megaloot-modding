extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Receive +100% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.TENACITY))
    bb_container_data.push_back(BBContainerData.new(" while you have "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.INVULNERABILITY)

    return bb_container_data
