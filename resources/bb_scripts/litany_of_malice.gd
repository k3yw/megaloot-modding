extends BBScript







func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("For every unique status effect on the target, "))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("Deal +25% bonus "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MALICE_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" to it"))

    return bb_container_data
