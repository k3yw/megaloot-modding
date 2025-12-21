extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("At the start of the turn, steal all"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("buffs from the target"))

    return bb_container_data
