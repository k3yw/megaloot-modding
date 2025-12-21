extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Receive a "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.CLARITY)
    bb_container_data.push_back(BBContainerData.new(" in the first 3 turns"))

    return bb_container_data
