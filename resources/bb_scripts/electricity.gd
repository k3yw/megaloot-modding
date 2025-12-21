extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []



    bb_container_data.push_back(BBContainerData.new("Apply stacks of ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.ELECTRO_CHARGE)
    bb_container_data.push_back(BBContainerData.new(" equal to total ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ELECTRICITY))
    bb_container_data.push_back(BBContainerData.new(" to the target", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("on hit, adjacent enemies will receive 25% of the stacks", Color.DARK_GRAY))


    return bb_container_data
