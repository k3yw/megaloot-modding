extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("The amount of ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MAGIC_BLITZ)
    bb_container_data.push_back(BBContainerData.new(" you get on the first turn", Color.DARK_GRAY))

    return bb_container_data
