extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("All your hits will apply "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.STUN)
    bb_container_data.push_back(BBContainerData.new(" on the target"))

    return bb_container_data
