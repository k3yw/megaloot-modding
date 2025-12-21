extends BBScript




func get_text_replacements(args: Array = []) -> Dictionary[String, String]:
    var wisdom_text: String = "?"

    if is_instance_valid(args[1]):
        var character: Character = args[1]
        wisdom_text = Format.number(character.get_stat_amount(Stats.WISDOM)[0], [Format.Rules.USE_SUFFIX])

    var dict: Dictionary[String, String] = {
        "{wisdom-result}": wisdom_text
    }


    return dict



func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var specialization: Specialization = args[0] as Specialization
    var bb_container_data: Array[BBContainerData] = []



    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.ARCANUM, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.ARCANUM, 1))

    bb_container_data.push_back(BBContainerData.new(" While "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MAGIC_SHIELD)
    bb_container_data.push_back(BBContainerData.new(" is active, gain "))
    bb_container_data.push_back(BBContainerData.new("+" + str(375) + "%", Stats.MAGIC_DAMAGE.color))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAGIC_DAMAGE))




    match specialization:
        Specializations.STUNIUM:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" When your "))
            bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MAGIC_SHIELD)
            bb_container_data.push_back(BBContainerData.new(" breaks, "))
            bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.STUN)
            bb_container_data.push_back(BBContainerData.new(" all enemies"))




    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.ARCANUM, 2))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.ARCANUM, 2))
    bb_container_data.push_back(BBContainerData.new(" Gain a "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MAGIC_SHIELD)
    bb_container_data.push_back(BBContainerData.new(" at the end of the turn", Color.DARK_GRAY))



    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.ARCANUM, 4))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.ARCANUM, 4))
    bb_container_data.push_back(BBContainerData.new(" Gain a "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MAGIC_SHIELD)
    bb_container_data.push_back(BBContainerData.new(" after killing an enemy", Color.DARK_GRAY))



    match specialization:
        Specializations.INVULNERIUM:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" The first time your ", Color.DARK_GRAY))
            bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MAGIC_SHIELD)
            bb_container_data.push_back(BBContainerData.new(" breaks, gain ", Color.DARK_GRAY))
            bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.INVULNERABILITY)

        Specializations.EVADIUM:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.> "))
            bb_container_data.push_back(BBContainerData.new(" Every time you ", Color.DARK_GRAY))
            bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.DODGE))
            bb_container_data.push_back(BBContainerData.new(", ", Color.DARK_GRAY))
            bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.COUNTER_ATTACK))


    return bb_container_data
