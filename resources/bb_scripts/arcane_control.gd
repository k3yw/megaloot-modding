extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Every time you avoid an attack, break your"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MAGIC_SHIELD)
    bb_container_data.push_back(BBContainerData.new(" and immediately refill it"))


    return bb_container_data
