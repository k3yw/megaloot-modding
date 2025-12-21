extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("All attacks against you will lose 100% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACCURACY))


    return bb_container_data
