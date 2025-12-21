extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Deals ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ELECTRIC_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" equals to the amount of stacks to the owner every turn", Color.DARK_GRAY))

    return bb_container_data
