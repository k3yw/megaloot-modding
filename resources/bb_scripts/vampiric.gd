extends BBScript







func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var specialization: Specialization = args[0] as Specialization
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.VAMPIRIC, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.VAMPIRIC, 1))
    bb_container_data.push_back(BBContainerData.new(" On your first attack on a new target apply 8% "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.BLEED)


    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.VAMPIRIC, 3))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.VAMPIRIC, 3))
    bb_container_data.push_back(BBContainerData.new(" Every time an enemy takes "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.BLEED_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(", "))
    bb_container_data.push_back(Keywords.get_bb_container_data(Keywords.HEAL))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new(" for that amount"))


    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.VAMPIRIC, 5))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.VAMPIRIC, 5))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.BLEED_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" will be converted to "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.POWER))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new(" resets every battle", Color.DIM_GRAY))



    match specialization:
        Specializations.VAMPIERCER:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("Everytime you "))
            bb_container_data.push_back(Keywords.get_bb_container_data(Keywords.HEAL))
            bb_container_data.push_back(BBContainerData.new(":"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" Deal direct ", Color.DARK_GRAY))
            bb_container_data.push_back(Stats.get_bb_container_data(Stats.PHYSICAL_DAMAGE))
            bb_container_data.push_back(BBContainerData.new(" that equals to the amount you", Color.DARK_GRAY))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("  healed to a selected enemy, bypassing their ", Color.DARK_GRAY))
            bb_container_data.push_back(Stats.get_bb_container_data(Stats.ARMOR))

        Specializations.BLOODCASTER:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("Everytime you "))
            bb_container_data.push_back(Keywords.get_bb_container_data(Keywords.HEAL))
            bb_container_data.push_back(BBContainerData.new(":"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" Deal ", Color.DARK_GRAY))
            bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAGIC_DAMAGE))
            bb_container_data.push_back(BBContainerData.new(" that equals to the amount you", Color.DARK_GRAY))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("  healed to a selected enemy", Color.DARK_GRAY))

        Specializations.VENOMIRE:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("Everytime you "))
            bb_container_data.push_back(Keywords.get_bb_container_data(Keywords.HEAL))
            bb_container_data.push_back(BBContainerData.new(":"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" Apply ", Color.DARK_GRAY))
            bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.POISON)
            bb_container_data.push_back(BBContainerData.new(" stacks to the selected enemy that", Color.DARK_GRAY))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("  equals to the amount you healed", Color.DARK_GRAY))


    return bb_container_data
