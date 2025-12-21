extends BBScript










func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.new("Temporary ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ARMOR))
    bb_container_data.push_back(BBContainerData.new(" that disappears after the end of the battle", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("Receive ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.EPHEMERAL_LOCK)
    bb_container_data.push_back(BBContainerData.new(" after taking damage", Color.DARK_GRAY))


    return bb_container_data
