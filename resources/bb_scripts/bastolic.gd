extends BBScript




func get_bb_replacements(args: Array = []) -> Dictionary[String, BBContainerData]:
    var magic_damage_bb: BBContainerData = BBContainerData.new()
    magic_damage_bb.right_image_color = Stats.MAGIC_DAMAGE.color
    magic_damage_bb.text_color = Stats.MAGIC_DAMAGE.color
    magic_damage_bb.right_image = Stats.MAGIC_DAMAGE.icon
    magic_damage_bb.stat_resource = Stats.MAGIC_DAMAGE
    magic_damage_bb.text = "(?)"

    if args.size() > 1 and is_instance_valid(args[1]):
        var amount: float = ceilf((args[1] as Character).get_stat_amount(Stats.HEALTH)[0] * 0.05)
        magic_damage_bb.text = "(" + Format.number(amount) + ")"

    var dict: Dictionary[String, BBContainerData] = {
        "({magic_damage})": magic_damage_bb
    }

    return dict



func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []
    var magic_damage_bb: BBContainerData = BBContainerData.new()
    magic_damage_bb.text = "({magic_damage})"

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.BASTOLIC, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.BASTOLIC, 1))
    bb_container_data.push_back(BBContainerData.new(" When you deal "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAGIC_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(", deal another"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(magic_damage_bb)
    bb_container_data.push_back(BBContainerData.new(" 5% of your max health", Stats.MAGIC_DAMAGE.color))
    bb_container_data.push_back(BBContainerData.new(" to a random enemy"))


    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.BASTOLIC, 2))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.BASTOLIC, 2))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAGIC_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" you receive on the first"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new(" turn will be converted to "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new(" resets every battle", Color.DIM_GRAY))


    return bb_container_data
