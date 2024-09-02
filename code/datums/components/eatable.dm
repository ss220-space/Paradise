/// If our item has material type and this type included in special_diet (species) it can be eaten.
/datum/component/eatable
	
/datum/component/eatable/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/eatable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(try_eat_item))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/eatable/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK, COMSIG_PARENT_EXAMINE))

/datum/component/eatable/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/obj/item/item = parent
	var/mob/living/carbon/human/human = user

	if(item.material_type & human.dna.species.special_diet)
		examine_list += "Вкуснятина! [item.is_only_grab_intent ? "\nНужно аккуратно есть." : ""]"

	if(!isstack(item))
		examine_list += get_bite_info()

/datum/component/eatable/proc/get_bite_info()
	var/obj/item/item = parent
	var/text
	var/bites_split = item.max_bites > 3 ? round(item.max_bites / 4) : 1
	if(item.current_bites >= 1 && item.current_bites <= bites_split)
		text = "Выглядит покусанным..."
	else if(item.current_bites >= bites_split && item.current_bites <= (bites_split * 2))
		text = "Видны оторванные части..."
	else if((item.current_bites >= bites_split * 2) && item.current_bites <= (bites_split * 3))
		text = "Видна внутренняя часть..."
	else if((item.current_bites >= bites_split * 3))
		text = "Осталась одна труха..."
	return text

/datum/component/eatable/proc/try_eat_item(datum/source, mob/living/carbon/human/target, mob/user)

	var/obj/item/item = parent
	if(!(item.material_type & target.dna.species.special_diet))
		return NONE

	var/chat_message_to_user = "Вы кормите [target] [item.name]."
	var/chat_message_to_target = "[user] покормил вас [item.name]."

	switch(user.a_intent)
		if(INTENT_HELP, INTENT_GRAB)
			if(target.nutrition >= NUTRITION_LEVEL_FULL)
				chat_message_to_user = "В [target == user ? "вас" : target] больше не лезет [item.name]. [target == user ? "Вы" : target] наел[target == user ? "ись" : genderize_ru(target.gender,"ся","ась","ось","ись")]!"
				return NONE
			else if (target == user && !isstack(item))
				chat_message_to_user = "Вы откусили от [item.name]. Вкуснятина!"
		if(INTENT_HARM)
			chat_message_to_user = "В [target == user ? "вас" : target] больше не лезет. Но [target == user ? "вы" : user] насильно запихива[target == user ? "ете" : pluralize_ru(user.gender,"ет","ют")] [item.name] в рот!"
			if (target != user)
				chat_message_to_target = "В ваш рот насильно запихивают [item.name]!"
			if(target.nutrition >= NUTRITION_LEVEL_FULL)
				target.vomit(item.nutritional_value + 20)
				target.adjustStaminaLoss(15)

	if(target != user)
		if(!forceFed(target, user, FALSE, NONE))
			return NONE
		to_chat(target, span_notice("[chat_message_to_target]"))
		add_attack_logs(user, item, "Force Fed [target], item [item]")

	to_chat(user, span_notice("[chat_message_to_user]"))
	eat(target, user)

/datum/component/eatable/proc/eat(mob/target, mob/user)
	var/obj/item/item = parent
	
	playsound(target.loc, 'sound/items/eatfood.ogg', 50, 0)
	if(!isvampire(target)) //Dont give nutrition to vampires
		target.adjust_nutrition(item.nutritional_value)
	SSticker.score.score_food_eaten++

	if(isstack(item))
		var/obj/item/stack/stack = item
		to_chat(user, span_notice("[target == user ? "Вы съели" : "[target] съел"] [item.name]."))
		if(stack.amount == 1)
			qdel(stack)
		stack.amount--
	else
		item.current_bites++
		item.obj_integrity = max(item.obj_integrity - item.integrity_bite, 0)
		item.add_atom_colour(get_colour(), FIXED_COLOUR_PRIORITY)
		if(item.current_bites >= item.max_bites)
			to_chat(user, span_notice("[target == user ? "Вы доели" : "[target] доел"] [item.name]."))
			qdel(item)

/datum/component/eatable/proc/forceFed(mob/living/carbon/target, mob/user, var/instant_application = FALSE)
	var/obj/item/item = parent
	if(!instant_application)
		item.visible_message(span_warning("[user] пытается накормить [target], запихивая в рот [item.name]."))

	if(!instant_application)
		if(!do_after(user, target, 2 SECONDS, NONE))
			return FALSE
	return TRUE

/datum/component/eatable/proc/get_colour()
	var/obj/item/item = parent
	var/bites_split = item.max_bites > 3 ? round(item.max_bites / 4) : 1
	var/colour
	if(item.current_bites >= 1 && item.current_bites <= bites_split)
		colour = "#d9e0e7ff"
	else if(item.current_bites >= bites_split && item.current_bites <= (bites_split * 2))
		colour = "#b7c3ccff"
	else if((item.current_bites >= bites_split * 2) && item.current_bites <= (bites_split * 3))
		colour = "#929eabff"
	else if((item.current_bites >= bites_split * 3))
		colour = "#697581ff"
	return colour
