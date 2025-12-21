extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Reduces "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACCURACY))
    bb_container_data.push_back(BBContainerData.new(" by 100%"))


    return bb_container_data
