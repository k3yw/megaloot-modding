extends BBScript








func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var specialization: Specialization = args[0] as Specialization
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.new("After getting hit from an attack:", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" Deal ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACTIVE_ARMOR, Stats.DisplayMode.UNKNOWN))
    bb_container_data.push_back(BBContainerData.new(" as ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAGIC_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" to the attacker", Color.DARK_GRAY))

    match specialization:
        Specializations.CHROMATHORN:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" Everytime you get hit, apply ", Color.DARK_GRAY))
            bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.POISON)
            bb_container_data.push_back(BBContainerData.new(" on the", Color.DARK_GRAY))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("  attacker that equals to your ", Color.DARK_GRAY))
            bb_container_data.push_back(Stats.get_bb_container_data(Stats.TOXICITY))

        Specializations.MINDTHORN:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" Get +25% ", Color.DARK_GRAY))
            bb_container_data.push_back(Stats.get_bb_container_data(Stats.WISDOM))
            bb_container_data.push_back(BBContainerData.new(" (resets every battle)", Color.DIM_GRAY))

        Specializations.CINDERTHORN:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" ", Color.DARK_GRAY))
            bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.IMMOLATE))

        Specializations.THORNFROST:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" apply 2 stacks of ", Color.DARK_GRAY))
            bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.WEAKNESS)
            bb_container_data.push_back(BBContainerData.new(" on the attacker", Color.DARK_GRAY))


    return bb_container_data
