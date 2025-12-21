extends BBScript





func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Deal "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.CINDER_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" that equals to 25% of your "))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))
    bb_container_data.push_back(BBContainerData.new(" to all enemies in front"))

    return bb_container_data
