/// If our item has material type and this type included in special_diet (species) it can be eaten.
/datum/component/eatable
	/// How many bites did
	var/current_bites
	/// our item material type
	var/material_type
	/// The maximum amount of bites before item is depleted
	var/max_bites
	/// integrity spend after bite
	var/integrity_bite // integrity spend after bite
	/// How much nutrition add
	var/nutritional_value
	/// Grab if help_intent was used
	var/is_only_grab_intent
	/// If true - your item can be eaten without special diet check.
	var/is_always_eatable
	/// Amount of stack which will be spend on bite.
	var/stack_use

/datum/component/eatable/Initialize(
	current_bites = 0,
	material_type = MATERIAL_CLASS_NONE,
	max_bites = 1,
	integrity_bite = 10,
	nutritional_value = 20,
	is_only_grab_intent = FALSE,
	is_always_eatable = FALSE,
	stack_use = 1
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.current_bites = current_bites
	src.material_type = material_type
	src.max_bites = max_bites
	src.integrity_bite = integrity_bite
	src.nutritional_value = nutritional_value
	src.is_only_grab_intent = is_only_grab_intent
	src.is_always_eatable = is_always_eatable
	src.stack_use = stack_use

/datum/component/eatable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACKBY, PROC_REF(pre_try_eat_item))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/eatable/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_PRE_ATTACKBY, COMSIG_PARENT_EXAMINE))

/datum/component/eatable/proc/on_examine(datum/source, mob/living/carbon/human/human, list/examine_list)
	SIGNAL_HANDLER

	examine_list += item_string_material()

	if(!istype(human))
		return

	if(material_type & human.dna.species.special_diet)
		examine_list += "Вкуснятина! [is_only_grab_intent ? "\nНужно аккуратно есть." : ""]"

	if(!isstack(parent))
		examine_list += get_bite_info()

/datum/component/eatable/proc/get_bite_info()
	var/text
	var/bites_split = max_bites > 3 ? round(max_bites / 4) : 1

	if(current_bites >= 1 && current_bites <= bites_split)
		text = "Выглядит покусанным..."

	else if(current_bites >= bites_split && current_bites <= (bites_split * 2))
		text = "Видны оторванные части..."

	else if((current_bites >= bites_split * 2) && current_bites <= (bites_split * 3))
		text = "Видна внутренняя часть..."

	else if((current_bites >= bites_split * 3))
		text = "Осталась одна труха..."

	return text

/datum/component/eatable/proc/item_string_material()
	var/material_string
	switch(material_type)
		if(MATERIAL_CLASS_NONE)
			return
		if(MATERIAL_CLASS_CLOTH)
			material_string = "\nТканевый предмет."
		if(MATERIAL_CLASS_TECH)
			material_string = "\nТехнологичный предмет."
		if(MATERIAL_CLASS_SOAP)
			material_string = "\nМыльный предмет."
	return material_string

/datum/component/eatable/proc/pre_try_eat_item(datum/source, mob/living/carbon/human/target, mob/user)
	SIGNAL_HANDLER

	if(!istype(target))
		return FALSE

	if(!(material_type & target.dna.species.special_diet) && !is_always_eatable)
		return FALSE

	if(is_only_grab_intent && user.a_intent != INTENT_GRAB)
		return FALSE

	target.changeNext_move(CLICK_CD_MELEE)
	INVOKE_ASYNC(src, PROC_REF(try_eat_item), target, user)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/eatable/proc/try_eat_item(mob/living/carbon/human/target, mob/user)
	var/obj/item/item = parent
	var/chat_message_to_user = "Вы кормите [target] [item.name]."
	var/chat_message_to_target = "[user] покормил вас [item.name]."

	switch(user.a_intent)
		if(INTENT_HELP, INTENT_GRAB)
			if(target.nutrition >= NUTRITION_LEVEL_FULL)
				chat_message_to_user = "В [target == user ? "вас" : target] больше не лезет [item.name]. [target == user ? "Вы" : target] наел[target == user ? "ись" : genderize_ru(target.gender,"ся","ась","ось","ись")]!"
				return FALSE
			else if (target == user)
				chat_message_to_user = "Вы откусили от [item.name]. Вкуснятина!"
		if(INTENT_HARM)
			chat_message_to_user = "В [target == user ? "вас" : target] больше не лезет. Но [target == user ? "вы" : user] насильно запихива[target == user ? "ете" : pluralize_ru(user.gender,"ет","ют")] [item.name] в рот!"
			if (target != user)
				chat_message_to_target = "В ваш рот насильно запихивают [item.name]!"
			if(target.nutrition >= NUTRITION_LEVEL_FULL)
				target.vomit(nutritional_value + 20)
				target.adjustStaminaLoss(15)

	if(target != user)
		if(!forceFed(target, user, FALSE, NONE))
			return FALSE

		to_chat(target, span_notice("[chat_message_to_target]"))
		add_attack_logs(user, item, "Force Fed [target], item [item]")

	if(!isstack(item))
		to_chat(user, span_notice("[chat_message_to_user]"))

	eat(target, user)
	return

/datum/component/eatable/proc/eat(mob/target, mob/user)
	var/obj/item/item = parent

	playsound(target.loc, 'sound/items/eatfood.ogg', 50, FALSE)
	if(!isvampire(target)) //Dont give nutrition to vampires
		target.adjust_nutrition(nutritional_value)

	SSticker.score.score_food_eaten++

	if(isstack(item))
		var/obj/item/stack/stack = item
		target.visible_message(span_notice("[target] съел [stack.name]."))
		stack.use(stack_use)
	else
		current_bites++
		item.obj_integrity = max(item.obj_integrity - integrity_bite, 0)
		item.add_atom_colour(get_colour(), FIXED_COLOUR_PRIORITY)
		if(current_bites >= max_bites)
			target.visible_message(span_notice("[target] доел [item.name]."))
			qdel(item)
	return

/datum/component/eatable/proc/forceFed(mob/target, mob/user, var/instant_application = FALSE)
	var/obj/item/item = parent

	if(!instant_application)
		item.visible_message(span_warning("[user] пытается накормить [target], запихивая в рот [item.name]."))
		if(!do_after(user, target, 2 SECONDS, NONE))
			return FALSE

	return TRUE

/datum/component/eatable/proc/get_colour()
	var/bites_split = max_bites > 3 ? round(max_bites / 4) : 1
	var/colour

	if(current_bites >= 1 && current_bites <= bites_split)
		colour = "#d9e0e7ff"

	else if(current_bites >= bites_split && current_bites <= (bites_split * 2))
		colour = "#b7c3ccff"

	else if((current_bites >= bites_split * 2) && current_bites <= (bites_split * 3))
		colour = "#929eabff"

	else if((current_bites >= bites_split * 3))
		colour = "#697581ff"

	return colour
