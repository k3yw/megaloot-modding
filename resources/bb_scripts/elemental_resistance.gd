extends BBScript





func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.new("Reduces the following: ", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new(" ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.FREEZE_DAMAGE))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new(" ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.CINDER_DAMAGE))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new(" ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ELECTRIC_DAMAGE))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new(" ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.TOXICITY))


    return bb_container_data
