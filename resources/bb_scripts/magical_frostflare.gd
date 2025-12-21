extends BBScript







func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Receive "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.EPHEMERAL_ARMOR)
    bb_container_data.push_back(BBContainerData.new(" that equals to "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAGIC_DAMAGE))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("dealt to enemies with "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.FREEZE)

    return bb_container_data
