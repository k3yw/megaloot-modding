extends BBScript










func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Gain 100% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.CRIT_CHANCE))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("this turn"))

    return bb_container_data
