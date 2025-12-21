extends BBScript










func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    var damage_type_bb = Stats.get_bb_container_data(Stats.PHYSICAL_DAMAGE)
    bb_container_data.push_back(BBContainerData.new("Makes you ", Color.DARK_GRAY))
    bb_container_data.push_back(Keywords.get_bb_container_data(Keywords.HEAL))
    bb_container_data.push_back(BBContainerData.new(" % ", Color.DARK_GRAY))

    if args[0] == Stats.OMNI_VAMP:
        damage_type_bb = BBContainerData.new("damage", Color.DARK_GRAY)

    bb_container_data.push_back(damage_type_bb)
    bb_container_data.push_back(BBContainerData.new(" dealt to ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))


    return bb_container_data
