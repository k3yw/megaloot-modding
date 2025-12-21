extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.new("Upon dropping below 45% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))
    bb_container_data.push_back(BBContainerData.new(", apply"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.CONFUSION)
    bb_container_data.push_back(BBContainerData.new(" to all enemies"))


    return bb_container_data
