extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Dealing damage to the target that would leave it below % "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("that equals to % "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.LETHALITY)
    bb_container_data.push_back(BBContainerData.new(" will "))
    bb_container_data.push_back(Keywords.get_bb_container_data(Keywords.EXECUTE))
    bb_container_data.push_back(BBContainerData.new(" it"))

    return bb_container_data
