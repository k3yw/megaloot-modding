extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Apply ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.POISON)
    bb_container_data.push_back(BBContainerData.new(" stack on hit for every ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.TOXICITY))


    return bb_container_data
