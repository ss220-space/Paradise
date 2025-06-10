/datum/surgery/plastic_surgery_robotics
	name = "Изменение/восстановление внешности"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/reshape_face_robotics,
		/datum/surgery_step/robotics/external/close_hatch
	)
	possible_locs = list(BODY_ZONE_HEAD)
	requires_organic_bodypart = FALSE


/datum/surgery_step/reshape_face_robotics
	name = "изменение/восстановление внешности"
	allowed_tools = list(/obj/item/multitool = 100, /obj/item/screwdriver = 55, /obj/item/kitchen/knife = 20, TOOL_SCALPEL = 25)
	time = 6.4 SECONDS

/datum/surgery_step/reshape_face_robotics/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] изменять внешность [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете изменять внешность [target], используя [tool.declent_ru(ACCUSATIVE)].")
	)
	return ..()

/datum/surgery_step/reshape_face_robotics/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/head/head = target.get_organ(target_zone)
	var/species_names = target.dna.species.name
	if(head.undisfigure())
		user.visible_message(
			span_notice("[user] восстанавлива[pluralize_ru(user.gender, "ет", "ют")] внешность [target], используя [tool.declent_ru(ACCUSATIVE)]."),
			span_notice("Вы восстанавливаете внешность [target], используя [tool.declent_ru(ACCUSATIVE)].")
		)
	else
		var/list/names = list()
		var/list_size = 10

		//IDs in hand
		if(ishuman(user)) //Only 'humans' can hold ID cards
			var/mob/living/carbon/human/H = user
			var/obj/item/card/id/id = H.get_id_from_hands()
			if(istype(id))
				names += id.registered_name
				list_size-- //To stop list bloat

		//IDs on body
		var/list/id_list = list()
		for(var/obj/item/I in range(0, target)) //Get ID cards
			if(I.GetID())
				id_list += I.GetID()

		for(var/obj/item/card/id/id in id_list) //Add card names to 'names'
			if(id.registered_name != target.real_name)
				names += id.registered_name
				list_size--

		if(!isabductor(user))
			for(var/i in 1 to list_size)
				names += random_name(target.gender, species_names)

		else //Abductors get to pick fancy names
			list_size-- //One less cause they get a normal name too
			for(var/i in 1 to list_size)
				names += "Субъект [target.gender == MALE ? "I" : "O"]-[pick("A", "B", "C", "D", "E")]-[rand(10000, 99999)]"
			names += random_name(target.gender, species_names) //give one normal name in case they want to do regular plastic surgery
		var/chosen_name = tgui_input_list(user, "Выберите новое имя для субъекта.", "Смена имени", names)
		if(!chosen_name)
			return
		var/oldname = target.real_name
		target.real_name = chosen_name
		var/newname = target.real_name	//something about how the code handles names required that I use this instead of target.real_name
		user.visible_message(
			span_notice("[user] изменя[pluralize_ru(user.gender, "ет", "ют")] внешность [oldname], используя [tool.declent_ru(ACCUSATIVE)]. Теперь [genderize_ru(target.gender, "его", "её", "его", "их")] зовут [newname]."),
			span_notice("Вы изменяете внешность [oldname], используя [tool.declent_ru(ACCUSATIVE)]. Теперь [genderize_ru(target.gender, "его", "её", "его", "их")] зовут [newname].")
		)
	target.sec_hud_set_ID()
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/reshape_face_robotics/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/head/head = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(ACCUSATIVE)] корпус на голове [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(ACCUSATIVE)] корпус на голове [target]!")
	)
	target.apply_damage(10, BRUTE, head)
	return SURGERY_STEP_RETRY
