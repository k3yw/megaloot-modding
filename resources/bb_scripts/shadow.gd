extends BBScript









func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var specialization: Specialization = args[0] as Specialization
    var bb_container_data: Array[BBContainerData] = []

    match specialization:
        Specializations.BLOODMOON:

            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" Transforms 200% of lost "))
            bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))
            bb_container_data.push_back(BBContainerData.new(" into "))
            bb_container_data.push_back(Stats.get_bb_container_data(Stats.PHYSICAL_ATTACK))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("  resets every battle", Color.DIM_GRAY))
            bb_container_data.push_back(BBContainerData.new("\n"))


    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.SHADOW, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.SHADOW, 1))
    bb_container_data.push_back(BBContainerData.new(" Every time you avoid an attack, "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.BACKSTAB))
    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.SHADOW, 3))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.SHADOW, 3))
    bb_container_data.push_back(BBContainerData.new(" Damage avoided while "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.ELUSIVE)
    bb_container_data.push_back(BBContainerData.new(" will be gained"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new(" as "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ADAPTIVE_ATTACK))
    bb_container_data.push_back(BBContainerData.new(" - resets every battle", Color.DIM_GRAY))


    match specialization:
        Specializations.MOONLIGHTER: pass

        Specializations.NIGHTHRUST:

            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" Gain attack damage avoided with "))
            bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.DODGE))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("  resets every battle", Color.DIM_GRAY))

    return bb_container_data
