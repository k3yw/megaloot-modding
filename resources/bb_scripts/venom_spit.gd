extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Apply stacks of ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.POISON)
    bb_container_data.push_back(BBContainerData.new(" equal to total", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.TOXICITY))
    bb_container_data.push_back(BBContainerData.new(" to your target", Color.DARK_GRAY))


    return bb_container_data
