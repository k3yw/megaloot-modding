extends BBScript










func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Grants all allies "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.GOLDEN_HEART)

    return bb_container_data
