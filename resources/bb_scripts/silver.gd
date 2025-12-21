extends BBScript








func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []
    var display_mode: Stats.DisplayMode = Stats.DisplayMode.UNKNOWN
    var faith: float = 0.0

    if args.size() > 1 and is_instance_valid(args[1]):
        faith = (args[1] as Character).get_stat_amount(Stats.FAITH)[0]
        display_mode = Stats.DisplayMode.AMOUNT


    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.SILVER, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.SILVER, 1))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.CLEANSE))
    bb_container_data.push_back(BBContainerData.new(" is guaranteed if you have any"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("  amount of "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.FAITH))

    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.SILVER, 3))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.SILVER, 3))
    bb_container_data.push_back(BBContainerData.new(" On "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.CLEANSE))
    bb_container_data.push_back(BBContainerData.new(" recieve "))

    bb_container_data.push_back(Stats.get_bb_container_data(
        Stats.FAITH, 
        display_mode, 
        faith
        ))

    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data += (StatusEffects.get_bb_container_data(StatusEffects.GRACE))


    return bb_container_data
