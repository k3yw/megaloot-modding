extends BBScript










func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.new("When attacking consume all stacks and gain +100%", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))

    if args[0] == StatusEffects.OMNI_BLITZ:
        bb_container_data.push_back(Stats.get_bb_container_data(Stats.PHYSICAL_ATTACK))
        bb_container_data.push_back(BBContainerData.new(" and ", Color.DARK_GRAY))

    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAGIC_ATTACK))
    bb_container_data.push_back(BBContainerData.new(" per stack", Color.DARK_GRAY))


    return bb_container_data
