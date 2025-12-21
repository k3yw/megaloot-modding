extends BBScript





func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var specialization: Specialization = args[0] as Specialization
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.HUNTER, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.HUNTER, 1))
    bb_container_data.push_back(BBContainerData.new(" Every 1% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.CRIT_CHANCE))
    bb_container_data.push_back(BBContainerData.new(" above 100% will be converted to"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new(" 10% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.CRITICAL_DAMAGE))

    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.HUNTER, 3))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.HUNTER, 3))
    bb_container_data.push_back(BBContainerData.new(" Targets cannot "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.DODGE))
    bb_container_data.push_back(BBContainerData.new(" your "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.CRITICAL_STRIKE))
    bb_container_data.push_back(BBContainerData.new(" attacks"))


    match specialization:
        Specializations.BEASTBOUND:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" "))
            bb_container_data.push_back(Stats.get_bb_container_data(Stats.CRIT_CHANCE))
            bb_container_data.push_back(BBContainerData.new(" will affect "))
            bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.PARRY))
            bb_container_data.push_back(BBContainerData.new(" attacks"))

    return bb_container_data
