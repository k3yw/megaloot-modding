extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []



    bb_container_data.push_back(BBContainerData.new("Every turn receive ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.TRUE_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" that equals to 1% of your ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("(recieved when a battle takes too long)", Color.DIM_GRAY))


    return bb_container_data
