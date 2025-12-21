extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Unlocks "))
    bb_container_data.push_back(Keywords.get_bb_container_data(Keywords.TINKER))

    return bb_container_data
