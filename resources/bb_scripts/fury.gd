extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.new("Increase your ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.PHYSICAL_ATTACK))
    bb_container_data.push_back(BBContainerData.new(" by 25% for every stack of ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.FURY)
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("(resets at the end of the battle)", Color.DIM_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))

    return bb_container_data
