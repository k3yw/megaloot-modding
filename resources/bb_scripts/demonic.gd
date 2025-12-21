extends BBScript








func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var specialization: Specialization = args[0] as Specialization
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.DEMONIC, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.DEMONIC, 1))
    bb_container_data.push_back(BBContainerData.new(" For every 25 base "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new(" gain 1% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.PHYSICAL_ATTACK))


    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.DEMONIC, 3))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.DEMONIC, 3))
    bb_container_data.push_back(BBContainerData.new(" Receive "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MULTI_ATTACK_CHARGE)
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new(" at the start of the first turn"))


    match specialization:
        Specializations.CHALLENGER:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" 45% of the damage dealt to an enemy"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("  with an ", Color.DARK_GRAY))
            bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.ARTHURS_MARK)
            bb_container_data.push_back(BBContainerData.new(" will"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("  spread to adjacent enemies"))



    return bb_container_data
