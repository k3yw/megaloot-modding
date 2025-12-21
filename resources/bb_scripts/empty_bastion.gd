extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Multiplies your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ARMOR))
    bb_container_data.push_back(BBContainerData.new(" by 8, but you start"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("with 0 "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACTIVE_ARMOR))
    bb_container_data.push_back(BBContainerData.new(" every battle "))


    return bb_container_data
