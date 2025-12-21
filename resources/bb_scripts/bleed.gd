extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("After every attack, take "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.BLEED_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" to your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("that equal to % "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.BLEED)
    bb_container_data.push_back(BBContainerData.new(" stacks on you multiplied by your"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))

    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("every turn lose 2% ", Color.DIM_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.BLEED)


    return bb_container_data
