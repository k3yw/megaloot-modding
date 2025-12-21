extends BBScript







func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []
    bb_container_data.push_back(BBContainerData.new("The amount of times you will attack a target"))
    return bb_container_data
