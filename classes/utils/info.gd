class_name Info







static func from_stat(character: Character, stat: BonusStat, item_sets: Array[ItemSetResource] = [], new_stat_value: float = 0.0, is_bonus: bool = false, is_reforged: bool = false) -> Array[BBContainerData]:
	var bb_container_data_arr: Array[BBContainerData] = [BBContainerData.new("\n")]
	var new_stat_resource: StatResource = stat.resource

	if is_instance_valid(character):
		for transformed_stat in character.transformed_stats:
			if transformed_stat.origin_stat == stat.resource:
				new_stat_resource = transformed_stat

	var stat_bb_container = Stats.get_bb_container_data(new_stat_resource)

	var bonus_amount: float = new_stat_value - maxf(0, stat.amount)
	var rules: Array[Format.Rules] = [Format.Rules.USE_PREFIX]

	if new_stat_resource.is_percentage or stat.is_modifier:
		rules.push_back(Format.Rules.PERCENTAGE)

	if stat.amount > 100000000:
		rules.push_back(Format.Rules.USE_SUFFIX)

	var bonus_amount_str: String = Format.number(bonus_amount, rules)
	var amount_str: String = Format.number(stat.amount, rules)
	var bonus_amount_text: String = " " + bonus_amount_str
	var amount_text: String = amount_str + " "
	var amount_color: Color = Color.DARK_GRAY

	stat_bb_container.text = stat_bb_container.text.to_lower()
	stat_bb_container.character = character


	if is_bonus:
		amount_color = Color.LIGHT_GREEN

	if is_reforged:
		amount_text = amount_str

	var amount_bb = BBContainerData.new(amount_text, amount_color)

	bb_container_data_arr.push_back(amount_bb)
	if is_reforged:
		bb_container_data_arr.push_back(BBContainerData.new("* ", Color.DIM_GRAY))
	bb_container_data_arr.push_back(stat_bb_container)

	if bonus_amount > 0:
		bb_container_data_arr.push_back(BBContainerData.new(bonus_amount_text, Color.LIGHT_GREEN))

	for idx in item_sets.size():
		var item_set: ItemSetResource = item_sets[idx]
		var set_bb_container_data = BBContainerData.new()
		set_bb_container_data.item_set_resource = item_set
		bb_container_data_arr.push_back(set_bb_container_data)
		set_bb_container_data.remove_space = idx > 0
		set_bb_container_data.is_multiplier = true


	for bb_container_data in bb_container_data_arr:
		bb_container_data.character = character


	return bb_container_data_arr






static func from_stat_resource(hover_info_data: HoverInfoData, character: Character, stat_resource: StatResource) -> HoverInfoData:
	hover_info_data.name = T.get_translated_string(stat_resource.name, "Stat Name")
	hover_info_data.name_color = Color.DARK_GRAY
	hover_info_data.name_icon_colors = [stat_resource.color]
	hover_info_data.name_icons = [stat_resource.icon]

	if is_instance_valid(stat_resource.bb_script):
		var script: BBScript = stat_resource.bb_script.new() as BBScript
		hover_info_data.bb_container_data_arr += script.get_bb_container_data([stat_resource, character])


	if T.translations.size():
		hover_info_data.bb_container_data_arr = get_translated_bb_container_data_arr(stat_resource.name, "Stat Description", character)
		var misc_text_arr: Array[String] = []

		if not stat_resource.max_amount == -1:
			var misc_text: String = T.get_translated_string("Max Amount")
			misc_text = misc_text.replace("{amount}", str(stat_resource.max_amount))
			if stat_resource.is_percentage:
				misc_text += "%"
			misc_text_arr.push_back(misc_text)


		if not misc_text_arr.is_empty():
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))

		for idx in misc_text_arr.size():
			var misc_text: String = misc_text_arr[idx]
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(misc_text, Color.DIM_GRAY))
			if not idx == misc_text_arr.size() - 1:
				hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(", ", Color.DIM_GRAY))



	for bb_container_data in hover_info_data.bb_container_data_arr:
		bb_container_data.character = character


	if not hover_info_data.bb_container_data_arr.size():
		hover_info_data.unreference()
		return null

	return hover_info_data








static func from_ability(hover_info_data: HoverInfoData, ability: AbilityResource, character: Character) -> HoverInfoData:
	hover_info_data.name = T.get_translated_string(ability.name, "Ability Name")
	hover_info_data.name_color = Color.DARK_GRAY

	if ability.mana_cost:
		hover_info_data.cost = ability.mana_cost
		hover_info_data.cost_type = Stats.MANA


	if ability.use_limit and not ability.mana_cost:
		var usage_count: int = 0

		if is_instance_valid(character):
			usage_count = character.battle_profile.get_used_ability_count(ability)

		hover_info_data.top_hint_color = Color.DARK_GRAY
		hover_info_data.top_hint = str(usage_count) + "/" + str(ability.use_limit)


	if is_instance_valid(ability.bb_script):
		var script: BBScript = ability.bb_script.new() as BBScript
		hover_info_data.bb_container_data_arr += script.get_bb_container_data()



	match ability:
		Abilities.PERSISTENT_PAYBACK:
			hover_info_data.bb_container_data_arr.push_back(BattleActions.get_bb_container_data(BattleActions.COUNTER_ATTACK))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" for this turn", Color.DARK_GRAY))

		Abilities.FEAR_OF_FAITH:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Gain 2 stacks of ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr += StatusEffects.get_bb_container_data(StatusEffects.INVULNERABILITY)

		Abilities.DROP_OF_CHAOS:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Apply a random debuff on your target", Color.DARK_GRAY))

		Abilities.BARRIER:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Gain a ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr += StatusEffects.get_bb_container_data(StatusEffects.MAGIC_SHIELD)

		Abilities.REPULSE:
			hover_info_data.bb_container_data_arr.push_back(BattleActions.get_bb_container_data(BattleActions.PARRY))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" this turn", Color.DARK_GRAY))

		Abilities.MIND_CONTROL:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Apply ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr += StatusEffects.get_bb_container_data(StatusEffects.CONFUSION)
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" to all targets", Color.DARK_GRAY))

		Abilities.CONFUSION_STRIKE:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Apply 2 stacks of ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr += StatusEffects.get_bb_container_data(StatusEffects.CONFUSION)
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" on hit", Color.DARK_GRAY))

		Abilities.MANA_REGEN:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Regenerate all your missing ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr.push_back(Stats.get_bb_container_data(Stats.MANA))


		Abilities.FROZEN_WIND:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Apply ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr += StatusEffects.get_bb_container_data(StatusEffects.WEAKNESS)
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" on target, attack it afterwards", Color.DARK_GRAY))

		Abilities.ENCHANTED_ATTACK:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Gain +100% attack damage this turn", Color.DARK_GRAY))

		Abilities.NOXIOUS_EMPOWERMENT:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Multiply ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr.push_back(Stats.get_bb_container_data(Stats.TOXICITY))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" by 2 this turn", Color.DARK_GRAY))

		Abilities.SAFEGUARD:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Grant ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr.push_back(Stats.get_bb_container_data(Stats.ARMOR))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" to you and your allies", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("equal to 25% of your ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))

		Abilities.SHATTER_STRIKE:
			hover_info_data.bb_container_data_arr.push_back(BattleActions.get_bb_container_data(BattleActions.ARMOR_BREAK))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" on hit", Color.DARK_GRAY))


		Abilities.STUN_ATTACK, Abilities.STUN_STRIKE, Abilities.HEADBUTT:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Apply ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr += StatusEffects.get_bb_container_data(StatusEffects.STUN)
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" on the target on hit", Color.DARK_GRAY))

		Abilities.GALEFIRE:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Apply ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr += StatusEffects.get_bb_container_data(StatusEffects.SLOWNESS)
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" on the target", Color.DARK_GRAY))

		Abilities.MULTI_SHIELD:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Grant you and your allies ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr += StatusEffects.get_bb_container_data(StatusEffects.EPHEMERAL_ARMOR)
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("that equals to your ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr.push_back(Stats.get_bb_container_data(Stats.HEALTH))

		Abilities.MULTI_MAGIC_SHIELD:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Grant you and your allies ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr += StatusEffects.get_bb_container_data(StatusEffects.MAGIC_SHIELD)

		Abilities.MULTI_HEAL:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Restore 25% health to you and all allies", Color.DARK_GRAY))

		Abilities.MULTI_CLEANSE:
			hover_info_data.bb_container_data_arr.push_back(BattleActions.get_bb_container_data(BattleActions.CLEANSE))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" yourself and all allies", Color.DARK_GRAY))

		Abilities.STEAL:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Steal 25% ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr.push_back(Stats.get_bb_container_data(Stats.GOLD))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" from the target", Color.DARK_GRAY))


	if T.is_initialized():
		hover_info_data.bb_container_data_arr = get_translated_bb_container_data_arr(ability.name, "Ability Description")
		if ability.to_attack:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
			var attack_on_activation_bb = BBContainerData.new(" " + T.get_translated_string("attack-on-activation-ability"), Color.DIM_GRAY)
			attack_on_activation_bb.left_image = preload("res://assets/textures/icons/attack_icon.png")
			attack_on_activation_bb.left_image_color = Color.DIM_GRAY
			hover_info_data.bb_container_data_arr.push_back(attack_on_activation_bb)


	for bb_container_data in hover_info_data.bb_container_data_arr:
		if bb_container_data.text_color == Color.WHITE:
			bb_container_data.text_color = Color.DARK_GRAY


	if not hover_info_data.bb_container_data_arr.size():
		hover_info_data.unreference()
		return null

	return hover_info_data





static func from_passive(hover_info_data: HoverInfoData, passive: Passive) -> HoverInfoData:
	hover_info_data.name = T.get_translated_string(passive.name, "Passive Name")
	hover_info_data.name_color = Color.DARK_GRAY

	if is_instance_valid(passive.bb_script):
		var script: BBScript = passive.bb_script.new() as BBScript
		hover_info_data.bb_container_data_arr += script.get_bb_container_data()

	match passive:
		Passives.SHADED_ESSENCE:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Deal +375% ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr.push_back(Stats.get_bb_container_data(Stats.MAGIC_DAMAGE))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" to enemies with ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr += StatusEffects.get_bb_container_data(StatusEffects.SILENCE)

		Passives.ESCAPE:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Leave the battle after attempting to steal", Color.DARK_GRAY))

		Passives.IRONCLAD:
			hover_info_data.bb_container_data_arr.push_back(BattleActions.get_bb_container_data(BattleActions.BLOCK))



	if T.is_initialized():
		hover_info_data.bb_container_data_arr = T.get_translated_bb_code(passive.name, "Passive Description")

		if not is_instance_valid(passive.bb_script):
			for bonus_stat in passive.bonus_stats:
				hover_info_data.bb_container_data_arr += from_stat(null, bonus_stat, [])



	for bb_container_data in hover_info_data.bb_container_data_arr:
		if bb_container_data.text_color == Color.WHITE:
			bb_container_data.text_color = Color.DARK_GRAY

	if not hover_info_data.bb_container_data_arr.size():
		hover_info_data.unreference()
		return null

	return hover_info_data





static func from_status_effect_resource(hover_info_data: HoverInfoData, status_effect_resource: StatusEffectResource, character: Character = null) -> HoverInfoData:
	if not is_instance_valid(status_effect_resource):
		return hover_info_data
	hover_info_data.name = T.get_translated_string(status_effect_resource.name, "Status Effect Name")
	hover_info_data.name_color = Color.DARK_GRAY
	hover_info_data.name_icon_colors = [status_effect_resource.color]
	hover_info_data.name_icons = [status_effect_resource.icon]

	if is_instance_valid(status_effect_resource.bb_script):
		var script: BBScript = status_effect_resource.bb_script.new() as BBScript
		hover_info_data.bb_container_data_arr += script.get_bb_container_data([status_effect_resource])


	if T.translations.size():
		hover_info_data.bb_container_data_arr = get_translated_bb_container_data_arr(status_effect_resource.name, "Status Effect Description", character)
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))

		var type_text: String = T.get_translated_string(status_effect_resource.type.name, "Status Effect Type Name").to_lower()
		var to_replace: String = T.get_translated_string("Unlimited Amount").to_lower()
		var misc_text: String = T.get_translated_string("Max Amount")

		if not status_effect_resource.limit == -1:
			to_replace = str(status_effect_resource.limit)

		misc_text = misc_text.replace("{amount}", to_replace)

		if status_effect_resource.is_percent:
			misc_text += "%"

		misc_text += ", " + type_text

		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(misc_text, Color.DIM_GRAY))



	for bb_container_data in hover_info_data.bb_container_data_arr:
		if bb_container_data.text_color == Color.WHITE:
			bb_container_data.text_color = Color.DARK_GRAY
		bb_container_data.character = character


	if not hover_info_data.bb_container_data_arr.size():
		hover_info_data.unreference()
		return null

	return hover_info_data





static func from_battle_action(hover_info_data: HoverInfoData, battle_action: BattleAction) -> HoverInfoData:
	hover_info_data.name = T.get_translated_string(battle_action.name, "Battle Action Name")
	hover_info_data.name_color = Color.DARK_GRAY
	hover_info_data.name_icon_colors = [battle_action.color]
	hover_info_data.name_icons = [battle_action.icon]


	if is_instance_valid(battle_action.bb_script):
		var script: BBScript = battle_action.bb_script.new() as BBScript
		hover_info_data.bb_container_data_arr += script.get_bb_container_data([battle_action])


	match battle_action:
		BattleActions.ARMOR_BREAK:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Break target's armor by reducing it to 0", Color.DARK_GRAY))

		BattleActions.BLOCK:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Reduce incoming damage by 100%", Color.DARK_GRAY))


	if T.translations.size():
		hover_info_data.bb_container_data_arr = get_translated_bb_container_data_arr(battle_action.name, "Battle Action Description")

	for bb_container_data in hover_info_data.bb_container_data_arr:
		if bb_container_data.text_color == Color.WHITE:
			bb_container_data.text_color = Color.DARK_GRAY


	if not hover_info_data.bb_container_data_arr.size():
		hover_info_data.unreference()
		return null

	return hover_info_data




static func from_keyword(hover_info_data: HoverInfoData, keyword: Keyword) -> HoverInfoData:
	hover_info_data.name = T.get_translated_string(keyword.name, "Keyword Name")
	hover_info_data.name_color = Color.DARK_GRAY
	hover_info_data.name_icon_colors = [keyword.color]
	hover_info_data.name_icons = [keyword.icon]

	var script: BBScript = null
	if is_instance_valid(keyword.bb_script):
		script = keyword.bb_script.new() as BBScript
		hover_info_data.bb_container_data_arr += script.get_bb_container_data([keyword])

	match keyword:
		Keywords.HEAL:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("The action of replenishing a character's current ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr.push_back(Stats.get_bb_container_data(Stats.HEALTH))

	if T.is_initialized():
		hover_info_data.bb_container_data_arr = T.get_translated_bb_code(keyword.name, "Keyword Description")

		if is_instance_valid(script):
			var bb_replacements: Dictionary[String, BBContainerData] = script.get_bb_replacements([])
			var string_replacements: Dictionary[String, String] = script.get_text_replacements([])
			for idx in hover_info_data.bb_container_data_arr.size():
				var bb: BBContainerData = hover_info_data.bb_container_data_arr[idx]
				for replacement in string_replacements:
					bb.text = bb.text.replace(replacement, string_replacements[replacement])

				for replacement in bb_replacements:
					if replacement == bb.text:
						hover_info_data.bb_container_data_arr[idx] = bb_replacements[replacement]


	for bb_container_data in hover_info_data.bb_container_data_arr:
		if bb_container_data.text_color == Color.WHITE:
			bb_container_data.text_color = Color.DARK_GRAY


	if not hover_info_data.bb_container_data_arr.size():
		hover_info_data.unreference()
		return null

	return hover_info_data





static func from_item_set(hover_info_data: HoverInfoData, character: Character, item_set_resource: ItemSetResource, specialization: Specialization = null) -> HoverInfoData:
	hover_info_data.name = T.get_translated_string(item_set_resource.name, "Item Set Name") + " " + T.get_translated_string("set")
	hover_info_data.name_color = item_set_resource.color

	hover_info_data.name_icons = [item_set_resource.icon] as Array[Texture2D]
	hover_info_data.name_icon_colors = [item_set_resource.color] as Array[Color]

	if item_set_resource == ItemSets.ESSENTIAL:
		hover_info_data.name = T.get_translated_string(item_set_resource.name, "Item Set Name")

	if is_instance_valid(specialization) and specialization.original_item_set == item_set_resource:
		hover_info_data.name = T.get_translated_string(specialization.name, "Specialization")
		hover_info_data.name_icons = [specialization.original_item_set.icon] as Array[Texture2D]
		hover_info_data.name_icon_colors = [specialization.get_color()] as Array[Color]
		hover_info_data.name_color = specialization.get_color()


	var script: BBScript = null
	if is_instance_valid(item_set_resource.bb_script):
		script = item_set_resource.bb_script.new() as BBScript
		hover_info_data.bb_container_data_arr += script.get_bb_container_data([specialization, character])



	match item_set_resource:
		ItemSets.PHANTOM:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Unable to equip", Color.DARK_GRAY))

		ItemSets.CATACLYSM:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("All enemies will receive up to 45% ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr += StatusEffects.get_bb_container_data(StatusEffects.LETHALITY)

		ItemSets.JADE:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("Reapply all ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr += StatusEffects.get_bb_container_data(StatusEffects.SPARKLE)
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" stacks on the target after popping them", Color.DARK_GRAY))

		ItemSets.GOLDEN:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("At the start of every battle, gain ", Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr += StatusEffects.get_bb_container_data(StatusEffects.GOLDEN_HEART)



	if T.is_initialized():
		var bb_container_data_arr: Array[BBContainerData] = Info.get_translated_bb_container_data_arr(item_set_resource.name, "item-set-description", character)
		if is_instance_valid(specialization):
			bb_container_data_arr = Info.get_translated_bb_container_data_arr(specialization.name, "specialization-description", character)

		hover_info_data.bb_container_data_arr.clear()
		for bb in bb_container_data_arr:
			hover_info_data.bb_container_data_arr.push_back(bb)

		if is_instance_valid(script):
			var bb_replacements: Dictionary[String, BBContainerData] = script.get_bb_replacements([specialization, character])
			var string_replacements: Dictionary[String, String] = script.get_text_replacements([specialization, character])


			for idx in hover_info_data.bb_container_data_arr.size():
				var bb: BBContainerData = hover_info_data.bb_container_data_arr[idx]

				for replacement in string_replacements:
					if bb.text == replacement:
						var new_bb: BBContainerData = BBContainerData.new()
						hover_info_data.bb_container_data_arr[idx] = new_bb
						SaveSystem.load_data(new_bb, SaveSystem.get_data(bb))
						bb = new_bb

					bb.text = bb.text.replace(replacement, string_replacements[replacement])

				for replacement in bb_replacements:
					if replacement == bb.text:
						hover_info_data.bb_container_data_arr[idx] = bb_replacements[replacement]


				if is_instance_valid(character):
					for transformed_stat in character.transformed_stats:
						if transformed_stat.origin_stat == bb.stat_resource:
							hover_info_data.bb_container_data_arr[idx] = Stats.get_bb_container_data(transformed_stat)

						if transformed_stat == Stats.OMNI_CRIT_CHANCE:
							if bb.battle_action == BattleActions.CRITICAL_STRIKE:
								hover_info_data.bb_container_data_arr[idx] = BattleActions.get_bb_container_data(BattleActions.OMNI_CRIT)




	for bb_container_data in hover_info_data.bb_container_data_arr:
		bb_container_data.character = character


	return hover_info_data




static func get_modifier_hint(stat_value: int, modified_stat_value: int, prefix: String) -> BBContainerData:
	var bb_container_data = BBContainerData.new()

	var modifier_hint_value: int = modified_stat_value - stat_value
	var modifier_hint: String = "%+d" % modifier_hint_value

	bb_container_data.text_color = Color.DARK_SEA_GREEN

	if modifier_hint_value < 0:
		bb_container_data.text_color = Color.PALE_VIOLET_RED

	bb_container_data.text = " (" + modifier_hint + prefix + ")"

	return bb_container_data




static func from_stats(item: Item, character: Character, extra_stats: Array[BonusStat] = []) -> Array[BBContainerData]:
	var bb_container_data_arr: Array[BBContainerData] = []
	var bonus_stats: Array[BonusStat] = item.get_bonus_stats()
	if not is_instance_valid(item.resource):
		return bb_container_data_arr


	for bonus_stat in bonus_stats:
		var new_amount: float = bonus_stat.amount
		var is_reforged: bool = true

		for extra_stat in extra_stats:
			if extra_stat.resource == bonus_stat.resource and extra_stat.is_modifier == bonus_stat.is_modifier:
				new_amount += extra_stat.amount

		var display_stat = BonusStat.new(bonus_stat.resource, bonus_stat.amount, bonus_stat.is_modifier)


		for base_stat in item.resource.bonus_stats:
			if base_stat.resource == bonus_stat.resource and base_stat.is_modifier == bonus_stat.is_modifier:
				is_reforged = false


		bb_container_data_arr += from_stat(
			character, 
			display_stat, 
			bonus_stat.boosting_sets, 
			new_amount, 
			false, 
			is_reforged
			)


	for extra_stat in extra_stats:
		var skip: bool = false
		for bonus_stat in bonus_stats:
			if extra_stat.resource == bonus_stat.resource and extra_stat.is_modifier == bonus_stat.is_modifier:
				skip = true

		if skip:
			continue

		bb_container_data_arr += from_stat(
			character, 
			extra_stat, 
			extra_stat.boosting_sets, 
			0.0, 
			true
			)


	return bb_container_data_arr





static func get_item_name(item: Item) -> String:
	if item.name_override.length():
		return item.name_override

	var rarity_name: String = (ItemRarity.Type.keys()[maxi(item.rarity, 0)] as String)
	var item_name: String = item.resource.get_translated_name()
	var is_consumable: bool = item.resource.is_consumable()
	var is_essential: bool = item.resource.is_essential()
	var is_tome: bool = item.resource.is_tome()


	rarity_name = T.get_translated_string(rarity_name, "Rarity Name").capitalize() + " "

	if is_essential or is_tome or is_consumable or item.resource.is_special:
		rarity_name = ""


	if item.is_reforge:
		item_name = T.get_translated_string("item-reforge").replace("{item-name}", item_name)
		rarity_name = ""

	if item.is_tinker_kit:
		item_name = T.get_translated_string("tinker-kit-item-name")

	if item.is_banish:
		rarity_name = T.get_translated_string("banished-item")
		rarity_name = rarity_name.replace("{item-name}", "")
		rarity_name = rarity_name.capitalize() + " "
	
	if item.is_buyout:
		rarity_name = T.get_translated_string("ascended-item")
		rarity_name = rarity_name.replace("{item-name}", "")
		rarity_name = rarity_name.capitalize() + " "

	return rarity_name + item_name






static func from_item(hover_info_data: HoverInfoData, item: Item, character: Character, extra_stats: Array[BonusStat] = []) -> HoverInfoData:
	hover_info_data.name = T.get_translated_string("unknown-item")
	hover_info_data.name_color = Color.DARK_GRAY

	if not is_instance_valid(item) or not is_instance_valid(item.resource):
		return hover_info_data

	var item_set_resources: Array[ItemSetResource] = item.get_set_resources()

	var is_consumable: bool = item.resource.is_consumable()
	var is_essential: bool = item.resource.is_essential()
	var floor_number: int = 0


	if is_instance_valid(character):
		floor_number = character.floor_number

	hover_info_data.item_set_resources = item_set_resources
	hover_info_data.name = get_item_name(item)

	hover_info_data.name_outline_color = ItemRarity.get_outline_color(item.rarity)
	hover_info_data.name_color = ItemRarity.get_font_color(item.rarity)



	if item.resource.is_tome():
		for text in T.get_translated_string("learn-ability").split("{ability}"):
			if text.is_empty():
				hover_info_data.bb_container_data_arr += Abilities.get_bb_container_data(item.resource.ability_to_learn, true)
				continue
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(text))


	if item.is_banish:
		var text: String = T.get_translated_string("banish-description")
		text = text.replace("{item-name}", item.resource.get_translated_name())
		var text_arr: PackedStringArray = text.split("\n")

		for idx in text_arr.size():
			var bb_text = text_arr[idx]
			bb_text = bb_text.replace("|", "")
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(bb_text, Color.DIM_GRAY))
			if not idx == text_arr.size() - 1:
				hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
	
	if item.is_buyout:
		var text: String = T.get_translated_string("ascend-item-description")
		text = text.replace("{item-name}", item.resource.get_translated_name())
		var text_arr: PackedStringArray = text.split("\n")

		for idx in text_arr.size():
			var bb_text = text_arr[idx]
			bb_text = bb_text.replace("|", "")
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(bb_text, Color.DIM_GRAY))
			if not idx == text_arr.size() - 1:
				hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))

		return hover_info_data



	var passives: Array[Passive] = []
	var reforged_passive: Passive = null


	if is_instance_valid(item.reforged_passive) and not item.reforged_passive == Empty.passive:
		passives.push_back(item.reforged_passive)
		if is_instance_valid(item.resource.passive) and not item.resource.passive == item.reforged_passive:
			reforged_passive = item.reforged_passive


	for idx in passives.size():
		var passive: Passive = passives[idx]

		if idx > 0:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))

		var passive_text: String = T.get_translated_string("passive").to_upper() + ": "
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(passive_text))
		hover_info_data.bb_container_data_arr.push_back(Passives.get_bb_container_data(passive))

		if passive == reforged_passive:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("* ", Color.DIM_GRAY))



	hover_info_data.bb_container_data_arr += from_stats(item, character, extra_stats)



	if is_essential:
		var activation_effect_bb_container_data: Array[BBContainerData] = item.resource.activation_effect.get_bb_container_data()

		for bb in activation_effect_bb_container_data:
			if not is_instance_valid(bb.status_effect_resource):
				continue
			var new_status_effect_resource: StatusEffectResource = StatusEffects.modify_resource(character, bb.status_effect_resource)
			bb.status_effect_resource = new_status_effect_resource

		hover_info_data.bb_container_data_arr += activation_effect_bb_container_data



	var transform_stat_a: StatResource = null
	var transform_stat_b: StatResource = null

	if item.resource.is_stat_adapter():
		transform_stat_a = item.resource.stat_to_adapt
		transform_stat_b = Stats.ADAPTIVE_ATTACK

	if item.has_transformer_stat():
		transform_stat_a = item.transform_stat.origin_stat
		transform_stat_b = item.transform_stat


	if is_instance_valid(transform_stat_a) and is_instance_valid(transform_stat_b):
		var transform_text: String = T.get_translated_string("stat-transform")
		for bb_text in transform_text.split("|"):
			var bb: BBContainerData = BBContainerData.new(bb_text)

			if bb_text == "{stat-1}":
				bb = Stats.get_bb_container_data(transform_stat_a)

			if bb_text == "{stat-2}":
				bb = Stats.get_bb_container_data(transform_stat_b)

			hover_info_data.bb_container_data_arr.push_back(bb)




	if is_consumable:
		hover_info_data.bb_container_data_arr += item.resource.consumption_effect.get_bb_container_data(item.spawn_floor)


	var equipment: Array[Item] = []
	if is_instance_valid(character):
		equipment = character.equipment.items

	return get_misc(hover_info_data, item, equipment, character)





static func add_requirement_unlock_info(hover_info_data: HoverInfoData, item_resource: ItemResource, player: Player) -> void :
	hover_info_data.bb_container_data_arr += get_requirement_unlock_info(item_resource, player)


static func get_requirement_unlock_info(item_resource: ItemResource, player: Player) -> Array[BBContainerData]:
	var requirement_unlock_bb: Array[BBContainerData] = []

	if item_resource.unlock_requirements.size() > 0:
		var text: String = T.get_translated_string("unlock-requirements-description")
		requirement_unlock_bb.push_back(BBContainerData.new("\n"))
		requirement_unlock_bb.push_back(BBContainerData.new("\n"))
		requirement_unlock_bb.push_back(BBContainerData.new(text, Color.DIM_GRAY))

	for requirement in item_resource.unlock_requirements:
		var item_name: String = requirement.item_resource.get_translated_name()
		var item_counter: GameObjectCounter = null
		var completed_battle_count: int = 0

		if is_instance_valid(player):
			item_counter = player.get_used_item_counter(requirement.item_resource)

		if is_instance_valid(item_counter):
			completed_battle_count = mini(item_counter.amount, requirement.completed_battles)

		requirement_unlock_bb.push_back(BBContainerData.new("\n"))
		requirement_unlock_bb.push_back(BBContainerData.new("<.>", Color.DIM_GRAY))
		requirement_unlock_bb.push_back(BBContainerData.new(" "))
		requirement_unlock_bb.push_back(BBContainerData.new(item_name, Color.DIM_GRAY))
		requirement_unlock_bb.push_back(BBContainerData.new(": ", Color.DIM_GRAY))
		if is_instance_valid(player):
			requirement_unlock_bb.push_back(BBContainerData.new(str(completed_battle_count), Color.DIM_GRAY))
			requirement_unlock_bb.push_back(BBContainerData.new("/", Color.DIM_GRAY))
		requirement_unlock_bb.push_back(BBContainerData.new(str(requirement.completed_battles), Color.DIM_GRAY))

	return requirement_unlock_bb






static func from_adventurer(hover_info_data: HoverInfoData, adventurer: Adventurer) -> HoverInfoData:
	hover_info_data.name = T.get_translated_string(adventurer.name, "Adventurer Name")
	hover_info_data.name_color = Color.DARK_GRAY

	if adventurer.name_override.length():
		hover_info_data.name = adventurer.name_override


	var modifier_stats: Array[BonusStat] = []
	var stats_added: int = 0

	for idx in adventurer.bonus_stats.size():
		var stat = adventurer.bonus_stats[idx]

		if stat.is_modifier:
			modifier_stats.push_back(stat)
			continue

		if not stat.amount:
			continue

		var stat_amount: int = stat.amount

		match stat.resource:
			Stats.ACTIVE_ARMOR: continue
			Stats.HEALTH: continue

			Stats.TOTAL_ATTACKS:
				if stat.amount < 2:
					continue


		if stats_added % 4 == 0:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))

		var stat_amount_text: String = str(stat_amount)
		if stat.resource.is_percentage:
			stat_amount_text = stat_amount_text + "%"


		var bb_container_data = BBContainerData.new(" " + stat_amount_text + "  ")
		bb_container_data.stat_resource = stat.resource

		bb_container_data.left_image = stat.resource.icon
		bb_container_data.left_image_color = Color.DARK_GRAY

		hover_info_data.bb_container_data_arr.push_back(bb_container_data)
		stats_added += 1




	if is_instance_valid(adventurer.ability):
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
		var ability_text: String = T.get_translated_string("ability").to_upper() + ": "
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(ability_text))
		hover_info_data.bb_container_data_arr += Abilities.get_bb_container_data(adventurer.ability)


	if is_instance_valid(adventurer.passive):
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
		var passive_text: String = T.get_translated_string("passive").to_upper() + ": "
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(passive_text))
		hover_info_data.bb_container_data_arr.push_back(Passives.get_bb_container_data(adventurer.passive))




	if is_instance_valid(adventurer.doubled_stat):
		var text: String = T.get_translated_string("doubles-own-stat")
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))

		for bb_text in text.split("|"):
			if bb_text == "{stat}":
				hover_info_data.bb_container_data_arr.push_back(Stats.get_bb_container_data(adventurer.doubled_stat))
				continue
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(bb_text))


	if not modifier_stats.is_empty():
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))

	for modifier_stat in modifier_stats:
		var stat_bb = from_stat(null, modifier_stat, [])
		stat_bb.pop_front()

		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
		hover_info_data.bb_container_data_arr += stat_bb




	for socket in SocketTypes.BASE_SOCKETS:
		if not adventurer.sockets.has(socket):
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
			var socket_name: String = T.get_translated_string(socket.name, "Socket Name").to_lower()
			var translated_text: String = T.get_translated_string("Missing Item Socket").to_lower()
			translated_text = translated_text.replace("{socket-name}", socket_name)

			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(translated_text, Color.DIM_GRAY))



	return hover_info_data




static func from_specialization(hover_info_data: HoverInfoData, specialization: Specialization) -> HoverInfoData:
	if not is_instance_valid(specialization):
		return hover_info_data

	hover_info_data.name = T.get_translated_string(specialization.name, "Specialization Name")
	hover_info_data.name_color = Color.DARK_GRAY

	hover_info_data.bb_container_data_arr += T.get_translated_bb_code(specialization.name, "Specialization Description")


	if is_instance_valid(specialization.original_item_set):
		var specialization_info: String = T.get_translated_string("Specialization Info").capitalize()
		hover_info_data.name = T.get_translated_string("Specialization")

		hover_info_data.bb_container_data_arr.clear()

		for bb_text in specialization_info.split("|"):
			if bb_text.to_lower() == "{specialization}":
				hover_info_data.bb_container_data_arr.push_back(ItemSets.get_bb_container_data(specialization.original_item_set, specialization))
				continue

			if bb_text.to_lower() == "{item-set}":
				hover_info_data.bb_container_data_arr.push_back(ItemSets.get_bb_container_data(specialization.original_item_set))
				continue

			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(bb_text, Color.DARK_GRAY))


	return hover_info_data




static func from_trial(hover_info_data: HoverInfoData, trial: Trial) -> HoverInfoData:
	hover_info_data.name = T.get_translated_string(trial.name, "Trial Name")
	hover_info_data.name_color = Color.DARK_GRAY


	if is_instance_valid(trial.bb_script):
		var script: BBScript = trial.bb_script.new() as BBScript
		hover_info_data.bb_container_data_arr += script.get_bb_container_data([trial])


	if T.is_initialized():
		hover_info_data.bb_container_data_arr.clear()
		hover_info_data.bb_container_data_arr += T.get_translated_bb_code(trial.name, "Trial Description")
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("<.>"))
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(" "))
		hover_info_data.bb_container_data_arr.push_back(Keywords.get_bb_container_data(Keywords.TIER_I_REWARD))





	return hover_info_data




static func from_enemy(hover_info_data: HoverInfoData, enemy: Enemy, show_extra: bool = false) -> HoverInfoData:
	hover_info_data.name = T.get_translated_string(enemy.resource.name, "Enemy Name")
	hover_info_data.name_color = Color.DARK_GRAY

	var level_name: String = T.get_translated_string("Level") + "." + str(enemy.level + 1) + " "
	if enemy.resource.hide_stats:
		level_name = ""
	hover_info_data.name = level_name + hover_info_data.name





	for stat_resource in Stats.DISPLAY:
		var amount: float = enemy.get_stat_amount(stat_resource)[0]

		if is_equal_approx(amount, 0.0):
			continue

		match stat_resource:
			Stats.ACTIVE_ARMOR: continue
			Stats.ARMOR: continue
			Stats.MAX_HEALTH: continue
			Stats.HEALTH: continue
			Stats.MAX_MANA: if not show_extra: continue
			Stats.MANA: continue

			Stats.ACCURACY:
				if is_equal_approx(amount, 100.0):
					continue

			Stats.TOTAL_ATTACKS:
				if amount < 2:
					continue


		var rules: Array[Format.Rules] = []

		if stat_resource.is_percentage:
			rules.push_back(Format.Rules.PERCENTAGE)

		if amount > 100000000:
			rules.push_back(Format.Rules.USE_SUFFIX)

		var bb_container_data = BBContainerData.new(" " + Format.number(amount, rules) + "  ", Color.DARK_GRAY)
		bb_container_data.stat_resource = stat_resource
		bb_container_data.character = enemy

		bb_container_data.left_image = stat_resource.icon
		bb_container_data.left_image_color = Color.DARK_GRAY

		hover_info_data.bb_container_data_arr.push_back(bb_container_data)






	if enemy.resource.abilities.size():
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
		var ability_text: String = T.get_translated_string("Abilities").to_upper() + ": "
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(ability_text, Color.DARK_GRAY))

	for idx in enemy.resource.abilities.size():
		var ability: AbilityResource = enemy.resource.abilities[idx]
		if not is_instance_valid(ability):
			continue

		var level_text: String = T.get_translated_string("Level") + "." + str(idx + 1) + ": "
		var ability_bb: Array[BBContainerData] = []
		ability_bb.push_back(BBContainerData.new("\n"))
		ability_bb.push_back(BBContainerData.new(level_text, Color.DARK_GRAY))
		ability_bb += Abilities.get_bb_container_data(ability)

		if idx > enemy.level:
			for bb_container_data in ability_bb:
				bb_container_data.brightness -= 0.5

		hover_info_data.bb_container_data_arr += ability_bb


	if enemy.resource.passives.size():
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
		var passive_text: String = T.get_translated_string("passives").to_upper() + ": "
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(passive_text, Color.DARK_GRAY))


	for idx in enemy.resource.passives.size():
		var passive: Passive = enemy.resource.passives[idx]
		if not is_instance_valid(passive):
			continue

		var level_text: String = T.get_translated_string("Level") + "." + str(idx + 1) + ": "
		var passive_bb: Array[BBContainerData] = []
		passive_bb.push_back(BBContainerData.new("\n"))
		passive_bb.push_back(BBContainerData.new(level_text, Color.DARK_GRAY))
		passive_bb.push_back(Passives.get_bb_container_data(passive))

		if idx > enemy.level:
			for bb_container_data in passive_bb:
				bb_container_data.brightness -= 0.5

		hover_info_data.bb_container_data_arr += passive_bb


	if show_extra:
		for item_set in enemy.resource.active_item_sets:
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
			var passive_text: String = T.get_translated_string("active").to_upper() + ": "
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new(passive_text, Color.DARK_GRAY))
			hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
			hover_info_data.bb_container_data_arr.push_back(ItemSets.get_bb_container_data(item_set))



	return hover_info_data







static func get_misc(hover_info_data: HoverInfoData, item: Item, _equipment: Array[Item], _character: Character) -> HoverInfoData:
	var misc_bb_container_data_arr: Array[BBContainerData] = []

	if not is_instance_valid(item.resource):
		return hover_info_data


	if is_instance_valid(item.resource.bb_script):
		hover_info_data.bb_container_data_arr.push_back(BBContainerData.new("\n"))
		hover_info_data.bb_container_data_arr += get_translated_bb_container_data_arr(item.resource.name, "item-description")


	return hover_info_data




static func get_translated_bb_container_data_arr(name: String, type: String, character: Character = null) -> Array[BBContainerData]:
	var translated_bb_container_data_arr: Array[BBContainerData] = T.get_translated_bb_code(name, type)
	var new_translated_bb_container_data_arr: Array[BBContainerData] = []
	var current_bb_counter: BBCounter = null
	var equipment: Array[Item] = []


	if is_instance_valid(character):
		equipment = character.equipment.get_items()


	for idx in translated_bb_container_data_arr.size():
		var translated_bb_container_data: BBContainerData = translated_bb_container_data_arr[idx]


		if is_instance_valid(translated_bb_container_data.bb_counter):
			current_bb_counter = translated_bb_container_data.bb_counter
			continue


		if is_instance_valid(current_bb_counter):
			var has_amount: bool = false

			if is_instance_valid(current_bb_counter.item_set_resource) and is_instance_valid(character):
				has_amount = Character.get_item_set_count(character, current_bb_counter.item_set_resource) >= current_bb_counter.amount

			if is_instance_valid(current_bb_counter.stat_resource) and is_instance_valid(character):
				has_amount = character.get_stat_amount(current_bb_counter.stat_resource)[0] >= current_bb_counter.amount


			if not is_instance_valid(character):
				has_amount = true

			translated_bb_container_data.brightness = 0.0

			if not has_amount:
				translated_bb_container_data.brightness = -0.5


		if translated_bb_container_data.is_value:
			var stat = translated_bb_container_data.stat_resource
			var display_mode = Stats.DisplayMode.UNKNOWN
			var amount: float = 0.0


			if is_instance_valid(stat):
				if is_instance_valid(character):
					display_mode = Stats.DisplayMode.AMOUNT
					amount = character.get_stat_amount(stat)[0]

				new_translated_bb_container_data_arr.push_back(Stats.get_bb_container_data(stat, display_mode, amount))
				continue


		if is_instance_valid(translated_bb_container_data.ability):
			for ability_bb in Abilities.get_bb_container_data(translated_bb_container_data.ability, true):
				ability_bb.brightness = translated_bb_container_data.brightness
				new_translated_bb_container_data_arr.push_back(ability_bb)
			continue







		new_translated_bb_container_data_arr.push_back(translated_bb_container_data)



	return new_translated_bb_container_data_arr
