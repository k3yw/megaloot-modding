extends BBScript










func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []
    var battles_remaining: int = 0
    var gold_per_kill: int = 0

    if args.size() > 2:
        battles_remaining = args[2] as int
        gold_per_kill = args[1] as int


    if T.translations.size():
        var battles_remaining_text: String = T.get_translated_string("Battles Remaining", "Text").to_lower() + ": "
        var gold_per_kill_text: String = T.get_translated_string("Gold Per Kill", "Text").to_lower() + ": "

        bb_container_data.push_back(BBContainerData.new(gold_per_kill_text))
        bb_container_data.push_back(BBContainerData.new(Format.number(gold_per_kill, [Format.Rules.USE_SUFFIX]) + " ", Stats.GOLD.color))
        bb_container_data.push_back(Stats.get_bb_container_data(Stats.GOLD))
        bb_container_data.push_back(BBContainerData.new("\n"))

        bb_container_data.push_back(BBContainerData.new(battles_remaining_text + str(battles_remaining + 1)))

        return bb_container_data


    return bb_container_data
