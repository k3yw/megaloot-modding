extends BBScript










func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []



    bb_container_data.push_back(BBContainerData.new("While active, blocks any damage, then breaks and", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("becomes inactive", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("(will not break from ", Color.DIM_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAGIC_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(")", Color.DIM_GRAY))


    return bb_container_data
