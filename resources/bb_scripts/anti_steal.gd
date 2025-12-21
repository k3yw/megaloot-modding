extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Protects you from "))
    bb_container_data += Abilities.get_bb_container_data(Abilities.STEAL)

    return bb_container_data
