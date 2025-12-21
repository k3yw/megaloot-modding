extends BBScript











func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Hitting a target will pop all ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.SPARKLE)
    bb_container_data.push_back(BBContainerData.new(" stacks and will", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("do the following for each stack:", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("- Grant ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.EPHEMERAL_ARMOR)
    bb_container_data.push_back(BBContainerData.new(" to the attacker", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("- Deal ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.DAZZLE_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" to the target", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))


    return bb_container_data
