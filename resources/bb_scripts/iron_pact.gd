extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.new("Every time your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACTIVE_ARMOR))
    bb_container_data.push_back(BBContainerData.new(" reaches 0%, consume 10%"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))
    bb_container_data.push_back(BBContainerData.new(" and convert it to "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACTIVE_ARMOR))


    return bb_container_data
