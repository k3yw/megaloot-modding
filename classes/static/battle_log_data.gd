class_name BattleLogData extends RefCounted



var damage_result: DamageResult = Empty.damage_result
var source: DamageData.Source

var killer: CharacterReference = CharacterReference.new()
var killed: CharacterReference = CharacterReference.new()


var stolen_from: CharacterReference = CharacterReference.new()
var stealer: CharacterReference = CharacterReference.new()

var stolen_stat: StatResource = StatResource.new()
var amount_stolen: float = 0.0


var applied_status_effect: StatusEffect = Empty.status_effect
var status_effect_applier: CharacterReference = CharacterReference.new()
var status_effect_target: CharacterReference = CharacterReference.new()

var cleansed_character: CharacterReference = CharacterReference.new()
var cleansed_debuffs: Array[StatusEffect] = []

var heal_target: CharacterReference = CharacterReference.new()
var amount_healed: float = 0.0

var turn: int = 1



func get_bb_container_data() -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    var status_effect_applier_char: Character = DamageResult.get_ref(status_effect_applier)
    var status_effect_target_char: Character = DamageResult.get_ref(status_effect_target)
    var cleansed_char: Character = DamageResult.get_ref(cleansed_character)
    var heal_target_char: Character = DamageResult.get_ref(heal_target)
    var stolen_from_char: Character = DamageResult.get_ref(stolen_from)
    var stealer_char: Character = DamageResult.get_ref(stealer)
    var killed_char: Character = DamageResult.get_ref(killed)
    var killer_char: Character = DamageResult.get_ref(killer)


    var killed_name: String = ""
    var killer_name: String = ""


    if is_instance_valid(killed_char):
        killed_name = killed_char.get_translated_log_name().to_lower()

    if is_instance_valid(killer_char):
        killer_name = killer_char.get_translated_log_name().to_lower()


    if is_instance_valid(damage_result):
        bb_container_data += get_damage_result_bb()


    if killed_name.length() and killer_name.length():
        var text: String = T.get_translated_string("Battle Log Killed")
        text = text.replace("{character-1}", killer_name)
        text = text.replace("{character-2}", killed_name)
        bb_container_data.push_back(BBContainerData.new(text))




    if is_instance_valid(applied_status_effect) and applied_status_effect.amount > 0:
        var text: String = T.get_translated_string("Battle Log Applied Status Effect")
        var applier_name: String = ""


        if is_instance_valid(status_effect_applier_char):
            applier_name = status_effect_applier_char.get_translated_log_name().to_lower()

        text = text.replace("{character-1}", applier_name)
        text = text.replace("{character-2}", status_effect_target_char.get_translated_log_name().to_lower())


        if is_instance_valid(status_effect_applier_char):
            if status_effect_applier_char == status_effect_target_char:
                text = T.get_translated_string("Battle Log Applied Status On Self")
                text = text.replace("{character}", status_effect_applier_char.get_translated_log_name().to_lower())


        var status_effect_bb: Array[BBContainerData] = StatusEffects.get_bb_container_data(applied_status_effect.resource)
        var amount: float = applied_status_effect.amount

        bb_container_data.push_back(BBContainerData.new(text))

        bb_container_data.push_back(BBContainerData.new(": "))

        if amount > 1:
            var amount_str: String = Format.number(amount, [Format.Rules.USE_SUFFIX])
            bb_container_data.push_back(BBContainerData.new(amount_str, applied_status_effect.resource.color))
            bb_container_data.push_back(BBContainerData.new(" "))

        for bb in status_effect_bb:
            bb.text_color = applied_status_effect.resource.color

        bb_container_data += status_effect_bb



    if amount_stolen > 0:
        var text: String = T.get_translated_string("battle-log-steal")
        var stolen_stat_bb: BBContainerData = Stats.get_bb_container_data(stolen_stat)
        var amount_str: String = Format.number(amount_stolen, [Format.Rules.USE_SUFFIX])

        text = text.replace("{character}", stealer_char.get_translated_log_name().to_lower())
        text = text.replace("{source}", stolen_from_char.get_translated_log_name().to_lower())
        bb_container_data.push_back(BBContainerData.new(text))

        bb_container_data.push_back(BBContainerData.new(": "))
        bb_container_data.push_back(BBContainerData.new(amount_str, stolen_stat.color))
        bb_container_data.push_back(BBContainerData.new(" "))
        stolen_stat_bb.text_color = stolen_stat.color
        bb_container_data.push_back(stolen_stat_bb)



    if amount_healed > 0:
        var text: String = T.get_translated_string("battle-log-healed")
        var health_bb: BBContainerData = Stats.get_bb_container_data(Stats.HEALTH)
        var amount_str: String = Format.number(amount_healed, [Format.Rules.USE_SUFFIX])

        text = text.replace("{character}", heal_target_char.get_translated_log_name().to_lower())
        bb_container_data.push_back(BBContainerData.new(text))

        bb_container_data.push_back(BBContainerData.new(": "))
        bb_container_data.push_back(BBContainerData.new(amount_str, Stats.HEALTH.color))
        bb_container_data.push_back(BBContainerData.new(" "))
        health_bb.text_color = Stats.HEALTH.color
        bb_container_data.push_back(health_bb)



    if cleansed_debuffs.size():
        var cleansed_character_name: String = ""
        var text: String = T.get_translated_string("Battle Log Cleanse") + ": "

        if is_instance_valid(cleansed_char):
            cleansed_character_name = cleansed_char.get_translated_log_name().to_lower()

        text = text.replace("{character}", cleansed_character_name)
        bb_container_data.push_back(BBContainerData.new(text))

        for cleansed_debuff in cleansed_debuffs:
            var amount: float = 0.0

            if cleansed_debuff.amount > 1:
                amount = cleansed_debuff.amount

            bb_container_data += StatusEffects.get_bb_container_data(cleansed_debuff.resource, amount)
            bb_container_data.push_back(BBContainerData.new(", "))

        bb_container_data.pop_back()


    for bb in bb_container_data:
        bb.clear_references()


    return bb_container_data








func get_damage_result_bb() -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []


    var text: String = T.get_translated_string("Battle Log Received Damage")
    var attacker_char: Character = DamageResult.get_ref(damage_result.attacker)
    var target_char: Character = DamageResult.get_ref(damage_result.target)

    var attacker_name: String = ""
    var target_name: String = ""

    if is_instance_valid(target_char):
        target_name = target_char.get_translated_log_name().to_lower()

    if is_instance_valid(attacker_char):
        attacker_name = attacker_char.get_translated_log_name().to_lower()

    text = text.replace("{character}", target_name)

    match damage_result.result_type:
        BattleActions.HIT, BattleActions.BLOCK:
            var damage: float = damage_result.uncapped_total_damage

            if source == DamageData.Source.ATTACK:
                if damage_result.result_type == BattleActions.HIT:
                    text = T.get_translated_string("Battle Log Hit")
                    text = text.replace("{character-1}", attacker_name)
                    text = text.replace("{character-2}", target_name)

                if damage_result.result_type == BattleActions.BLOCK:
                    text = T.get_translated_string("Battle Log Block")
                    text = text.replace("{character-2}", attacker_name)
                    text = text.replace("{character-1}", target_name)
                    damage = damage_result.initial_damage


            var stat_bb: BBContainerData = Stats.get_bb_container_data(damage_result.damage_type)
            var damage_text: String = Format.number(damage, [Format.Rules.USE_SUFFIX])
            stat_bb.text_color = damage_result.damage_type.color

            bb_container_data.push_back(BBContainerData.new(text))
            bb_container_data.push_back(BBContainerData.new(": "))
            bb_container_data.push_back(BBContainerData.new(damage_text, damage_result.damage_type.color))
            bb_container_data.push_back(BBContainerData.new(" "))
            bb_container_data.push_back(stat_bb)


        BattleActions.DODGE:
            text = T.get_translated_string("Battle Log Dodged")
            text = text.replace("{character}", target_name)
            bb_container_data.push_back(BBContainerData.new(text))


        BattleActions.PARRY:
            print(T.get_translated_string("Battle Log Parry"))
            text = T.get_translated_string("Battle Log Parry")
            text = text.replace("{character-2}", attacker_name)
            text = text.replace("{character-1}", target_name)
            bb_container_data.push_back(BBContainerData.new(text))

    return bb_container_data





func get_final_bb_container_data(base_bb_container_data: Array[BBContainerData]) -> Array[BBContainerData]:
    return base_bb_container_data



func get_id(base_bb_container_data: Array[BBContainerData]) -> String:
    var id: String = ""
    for bb in base_bb_container_data:
        id += bb.text
    return id



func cleanup() -> void :
    killer.free()
    killed.free()
    stolen_from.free()
    stealer.free()
    status_effect_applier.free()
    status_effect_target.free()
    cleansed_character.free()
    heal_target.free()

    if not applied_status_effect == Empty.status_effect:
        if is_instance_valid(applied_status_effect):
            applied_status_effect.unreference()
