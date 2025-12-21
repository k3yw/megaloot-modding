extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.new("While you have "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.CURSE)
    bb_container_data.push_back(BBContainerData.new(" or "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.BLACK_CURSE)
    bb_container_data.push_back(BBContainerData.new(":"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("attacks will deal extra damage that equals"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("to targets 11% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))


    return bb_container_data
