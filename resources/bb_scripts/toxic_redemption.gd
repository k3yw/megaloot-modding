extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Upon killing an enemy, remove all ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.POISON)
    bb_container_data.push_back(BBContainerData.new(" on you and deal ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.PHYSICAL_DAMAGE))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("to all enemies that equals to the amount of the removed poison", Color.DARK_GRAY))

    return bb_container_data
