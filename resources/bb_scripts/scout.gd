extends BBScript





func get_text_replacements(_args: Array = []) -> Dictionary[String, String]:
    var dict: Dictionary[String, String] = {
        "{lethality-amount}": "2"
    }

    return dict




func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var specialization: Specialization = args[0] as Specialization
    var bb_container_data: Array[BBContainerData] = []



    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.SCOUT, 1))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.SCOUT, 1))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.DODGE))
    bb_container_data.push_back(BBContainerData.new(" is guaranteed if you have any amount of "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.AGILITY))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.SCOUT, 3))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.SCOUT, 3))
    bb_container_data.push_back(BBContainerData.new(" After you "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.DODGE))
    bb_container_data.push_back(BBContainerData.new(" 3 times, become "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.ELUSIVE)

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.SCOUT, 0))


    if is_instance_valid(specialization):
        bb_container_data.push_back(BBContainerData.new("\n"))
        bb_container_data.push_back(BBContainerData.new("\n"))
        bb_container_data.push_back(BBContainerData.new("Every time you avoid an attack:"))


    match specialization:
        Specializations.PURSUER:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" Gain {lethality-amount}% "))
            bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.LETHALITY)
            bb_container_data.push_back(BBContainerData.new(" - resets every battle", Color.DIM_GRAY))


        Specializations.WINDWALKER: pass


    if specialization == Specializations.STRIKER:
        bb_container_data.push_back(BBContainerData.new("\n"))
        bb_container_data.push_back(BBContainerData.new("<.>"))
        bb_container_data.push_back(BBContainerData.new(" "))
        bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.COUNTER_ATTACK))



    return bb_container_data
