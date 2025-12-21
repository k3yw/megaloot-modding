extends BBScript





func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(Keywords.get_bb_container_data(Keywords.HEAL))
    bb_container_data.push_back(BBContainerData.new(" a portion of your missing ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))
    bb_container_data.push_back(BBContainerData.new(" each turn", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("based on your ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.RECOVERY))


    return bb_container_data
