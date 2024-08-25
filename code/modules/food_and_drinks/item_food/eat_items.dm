/obj/item/proc/check_item_eat(mob/target, mob/user)
	switch(material_type)
		if(MATERIAL_CLASS_NONE)
			return FALSE
		if(MATERIAL_CLASS_CLOTH)
			if(!ismoth(target))
				return FALSE
		if(MATERIAL_CLASS_TECH)
			if(!isvox(target))
				return FALSE
		if(MATERIAL_CLASS_SOAP)
			if(!isdrask(target))
				return FALSE
	if(is_only_grab_intent && user.a_intent != INTENT_GRAB)
		return FALSE
	return TRUE

/obj/item/proc/item_string_material(mob/user)
	var/material_string
	var/material_promt = "Вкуснятина! [is_only_grab_intent ? "\nНужно аккуратно есть." : ""]"
	switch(material_type)
		if(MATERIAL_CLASS_CLOTH)
			material_string = "\nТканевый предмет. [ismoth(user) ? material_promt : ""]"
		if(MATERIAL_CLASS_TECH)
			material_string = "\nТехнологичный предмет. [isvox(user) ? material_promt : ""]"
		if(MATERIAL_CLASS_SOAP)
			material_string = "\nМыльный предмет. [isdrask(user) ? material_promt : ""]"

	var/bites_split = max_bites > 3 ? round(max_bites / 4) : 1
	var/bites_damage_string = ""
	if(current_bites >= 1 && current_bites <= bites_split)
		bites_damage_string = "Выглядит покусанным..."
	else if(current_bites >= bites_split && current_bites <= (bites_split * 2))
		bites_damage_string = "Видны оторванные части..."
	else if((current_bites >= bites_split * 2) && current_bites <= (bites_split * 3))
		bites_damage_string = "Видна внутренняя часть..."
	else if((current_bites >= bites_split * 3))
		bites_damage_string = "Осталась одна труха..."
	if(bites_damage_string)
		material_string += "\n[bites_damage_string]"

	return material_string


/obj/item/proc/try_item_eat(mob/living/carbon/target, mob/user)
	if(ishuman(target) && check_item_eat(target, user))
		INVOKE_ASYNC(src, PROC_REF(item_eat), target, user)
		return TRUE
	return FALSE

//Eat all thing in my hand
/obj/item/proc/item_eat(mob/living/carbon/target, mob/user)
	var/chat_message_to_user = "Вы кормите [target] [name]."
	var/chat_message_to_target = "[user] покормил вас [name]."
	switch(user.a_intent)
		if(INTENT_HELP, INTENT_GRAB)
			if(target.nutrition >= NUTRITION_LEVEL_FULL)
				chat_message_to_user = "В [target == user ? "вас" : target] больше не лезет [name]. [target == user ? "Вы" : target] наел[target == user ? "ись" : genderize_ru(target.gender,"ся","ась","ось","ись")]!"
				return
			else if(target == user)
				chat_message_to_user = "Вы откусили от [name]. Вкуснятина!"
		if(INTENT_HARM)
			chat_message_to_user = "В [target == user ? "вас" : target] больше не лезет. Но [target == user ? "вы" : user] насильно запихива[target == user ? "ете" : pluralize_ru(user.gender,"ет","ют")] [src.name] в рот!"
			if(target != user)
				chat_message_to_target = "В ваш рот насильно запихивают [name]!"
			if(target.nutrition >= NUTRITION_LEVEL_FULL)
				target.vomit(nutritional_value + 20)
				target.adjustStaminaLoss(15)

	if(target != user)
		if(!forceFed(target, user, FALSE))
			return
		to_chat(target, span_notice("[chat_message_to_target]"))
		add_attack_logs(user, src, "Force Fed [target], item [src]")

	to_chat(user, span_notice("[chat_message_to_user]"))

	current_bites++
	playsound(target.loc, 'sound/items/eatfood.ogg', 50, FALSE)
	if(!isvampire(target)) //Dont give nutrition to vampires
		target.adjust_nutrition(nutritional_value)
	obj_integrity = max(obj_integrity - integrity_bite, 0)
	colour_change()
	if(current_bites >= max_bites)
		to_chat(user, span_notice("[target == user ? "Вы доели" : "[target] доел"] [name]."))
		qdel(src)

	SSticker.score.score_food_eaten++


/obj/item/proc/forceFed(mob/living/carbon/target, mob/user, instant_application = FALSE)
	if(!instant_application)
		target.visible_message("<span class='warning'>[user] пытается накормить [target], запихивая в рот [src.name].</span>")
		if(!do_after(user, 2 SECONDS, target, NONE))
			return FALSE
	return TRUE

/obj/item/proc/colour_change()
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

	if (colour)
		add_atom_colour(colour, FIXED_COLOUR_PRIORITY)
