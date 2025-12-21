extends BBScript





func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Increases ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.GOLD))
    bb_container_data.push_back(BBContainerData.new(" per kill", Color.DARK_GRAY))

    return bb_container_data
