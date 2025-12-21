extends BBScript










func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var display_mode: Stats.DisplayMode = Stats.DisplayMode.UNKNOWN
    var specialization: Specialization = args[0] as Specialization
    var bb_container_data: Array[BBContainerData] = []
    var luck: float = 0.0

    if args.size() > 1 and is_instance_valid(args[1]):
        luck = (args[1] as Character).get_stat_amount(Stats.LUCK)[0]
        display_mode = Stats.DisplayMode.AMOUNT

    bb_container_data.push_back(BBContainerData.new("If a target is over 90% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))
    bb_container_data.push_back(BBContainerData.new(":"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.MERCENARY, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.MERCENARY, 1))
    bb_container_data.push_back(BBContainerData.new(" Deal 25%"))
    bb_container_data.push_back(BBContainerData.new(" +", Stats.LUCK.color))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.LUCK, display_mode, luck))
    bb_container_data.push_back(BBContainerData.new(" increased attack damage"))

    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.MERCENARY, 3))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.MERCENARY, 3))
    bb_container_data.push_back(BBContainerData.new(" Gain +1 "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.TOTAL_ATTACKS))
    bb_container_data.push_back(BBContainerData.new(" this turn"))



    match specialization:
        Specializations.DESERTER:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" gain +1 to ", Color.DARK_GRAY))
            bb_container_data.push_back(Stats.get_bb_container_data(Stats.TOTAL_ATTACKS))
            bb_container_data.push_back(BBContainerData.new(" every 10 floors", Color.DARK_GRAY))

        Specializations.FAITHBOUND:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" PASSIVE: ", Color.DARK_GRAY))
            bb_container_data.push_back(Passives.get_bb_container_data(Passives.JUDGMENTS_CALL))


    return bb_container_data
