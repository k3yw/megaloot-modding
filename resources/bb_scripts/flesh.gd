extends BBScript










func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Allows to "))
    bb_container_data.push_back(Keywords.get_bb_container_data(Keywords.HEAL))
    bb_container_data.push_back(BBContainerData.new(" over your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("the over healed amount is removed at the", Color.DIM_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("end of the turn", Color.DIM_GRAY))

    return bb_container_data
