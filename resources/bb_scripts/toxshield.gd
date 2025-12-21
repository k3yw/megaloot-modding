extends BBScript







func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.new("Every time ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.POISON_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" is dealt during your", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("turn gain ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.EPHEMERAL_ARMOR)
    bb_container_data.push_back(BBContainerData.new(" that equals to", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("that amount", Color.DARK_GRAY))


    return bb_container_data
