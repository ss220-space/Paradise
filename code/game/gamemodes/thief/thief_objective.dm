
//==========================
//======Steal Difficult=====
//==========================
/datum/objective/steal/hard
	type_theft_flag = THEFT_FLAG_HARD


/datum/objective/steal/medium
	type_theft_flag = THEFT_FLAG_MEDIUM


//==========================
//======Steal Structure=====
//==========================
/datum/objective/steal_structure
	explanation_text = "Украсть структуру: "
	var/obj/wanted_type
	var/range_distance = 2

	var/list/possible_targets_list = list(
		/obj/structure/statue/bananium/clown/unique,
		/obj/structure/statue/tranquillite/mime/unique,
		/obj/structure/toilet/captain_toilet,
		/obj/machinery/nuclearbomb,
	)

/datum/objective/steal_structure/find_target()
	var/list/valid_targets_list = possible_targets_list.Copy()

	while(!wanted_type)
		if(!length(valid_targets_list))
			return FALSE

		var/obj/target_type = pick(valid_targets_list)
		valid_targets_list.Remove(target_type)
		get_structure(target_type)

		if(wanted_type)
			return TRUE

	//Шанс мал, но вдруг выдастся новая цель в момент, когда все структуры сожрала сингулярность или клоун разобрал на составные компоненты?
	explanation_text = "Украдите самую ценную структуру и ресурсы на станции."
	return FALSE

/datum/objective/steal_structure/proc/select_target()
	var/target_type = input("Select target:", "Objective target", null) as null|anything in possible_targets_list
	if(!target_type)
		return FALSE
	return get_structure(target_type)

/datum/objective/steal_structure/proc/get_structure(var/obj/target_type)
	var/list/targets_list = get_all_of_type(target_type, subtypes = TRUE)
	if(!length(targets_list))
		return FALSE

	for(var/obj/temp_target in targets_list)
		wanted_type = target_type
		explanation_text += temp_target.name
		return TRUE

/datum/objective/steal_structure/check_completion()
	if(!wanted_type)
		return TRUE

	if(!owner.current)
		return FALSE

	for(var/obj/S in range(range_distance, owner.current.loc))
		if(istype(S, wanted_type))
			return TRUE
	return FALSE


//==========================
//========Steal Pet=========
//==========================
/datum/objective/steal_pet
	explanation_text = "Украсть живого питомца "
	var/mob/living/wanted_type
	var/obj/item/holder/wanted_holder_type
	var/range_distance = 2

	var/list/possible_targets_list = list(
		//simple mobs
		/mob/living/simple_animal/pet/dog/corgi/Ian,
		/mob/living/simple_animal/pet/dog/corgi/borgi,
		/mob/living/simple_animal/pet/dog/bullterrier/Genn,
		/mob/living/simple_animal/pet/dog/brittany/Psycho,
		/mob/living/simple_animal/pet/dog/security,
		/mob/living/simple_animal/pet/dog/security/ranger,
		/mob/living/simple_animal/pet/dog/security/warden,
		/mob/living/simple_animal/pet/dog/security/detective,
		/mob/living/simple_animal/pet/dog/fox/Renault,
		/mob/living/simple_animal/pet/dog/fox/fennec/Fenya,
		/mob/living/simple_animal/pet/cat/floppa,
		/mob/living/simple_animal/pet/cat/Runtime,
		/mob/living/simple_animal/pet/cat/Iriska,
		/mob/living/simple_animal/pet/sloth/paperwork,
		/mob/living/simple_animal/pet/slugcat,
		/mob/living/simple_animal/crab/royal/Coffee,
		/mob/living/simple_animal/chicken/Wife,
		/mob/living/simple_animal/cock/Commandor,
		/mob/living/simple_animal/cow/Betsy,
		/mob/living/simple_animal/pig/Sanya,
		/mob/living/simple_animal/parrot/Poly,
		/mob/living/simple_animal/goose/Scientist,
		/mob/living/simple_animal/mouse/hamster/Representative,
		/mob/living/simple_animal/mouse/rat/white/Brain,
		/mob/living/simple_animal/mouse/rat/gray/Ratatui,
		/mob/living/simple_animal/possum/Poppy,

		//carbons
		/mob/living/carbon/human/lesser/monkey/punpun,

	)

/datum/objective/steal_pet/find_target()
	var/list/valid_targets_list = possible_targets_list.Copy()

	while(!wanted_type)
		if(!length(valid_targets_list))
			return FALSE

		var/mob/living/target_type = pick(valid_targets_list)
		valid_targets_list.Remove(target_type)
		get_pet_alive(target_type)

		if(wanted_type)
			return TRUE

	var/mob/living/target_type = pick(possible_targets_list)
	return get_pet_anyway(target_type)

/datum/objective/steal_pet/proc/select_target()
	var/target_type = input("Select target:", "Objective target", null) as null|anything in possible_targets_list
	if(!target_type)
		return FALSE
	return get_pet_anyway(target_type)

/datum/objective/steal_pet/proc/get_pet_alive(var/mob/living/target_type)
	//ищем переименованных маперами мобов
	for(var/mob/living/temp_target in GLOB.mob_living_list)
		if(istype(temp_target, target_type))
			if(temp_target.stat != DEAD)
				wanted_type = target_type
				if(temp_target.holder_type)
					wanted_holder_type = temp_target.holder_type
				explanation_text += temp_target.name
				return TRUE
	return FALSE

/datum/objective/steal_pet/proc/get_pet_anyway(var/mob/living/target_type)
	wanted_type = target_type
	var/holder_type = initial(wanted_type.holder_type)
	if(holder_type)
		wanted_holder_type = holder_type
	explanation_text += initial(wanted_type.name)
	return TRUE

/datum/objective/steal_pet/check_completion()
	if(!wanted_type)
		return TRUE

	if(!owner.current)
		return FALSE

	return check_in_contents_range(wanted_type, range_distance)

/datum/objective/proc/check_in_contents_range(var/wanted_type, var/range_distance = 1)
	if(additional_conditions())
		return TRUE

	for(var/find_object in range(range_distance, owner.current.loc))
		if(find_check(find_object, wanted_type))
			return TRUE

		if(istype(find_object, /obj/structure/closet))
			var/obj/structure/closet/closet = find_object
			var/list/closet_contents = closet.GetAllContents()
			for(var/temp_object in closet_contents)
				if(find_check(temp_object, wanted_type))
					return TRUE
				if(additional_conditions())
					return TRUE
	return FALSE

/datum/objective/proc/additional_conditions()
	return TRUE

/datum/objective/proc/find_check(var/find_object, var/wanted_type)
	return TRUE

/datum/objective/steal_pet/find_check(var/find_object, var/wanted_type)
	if(!find_object || !wanted_type)
		return FALSE

	if(istype(find_object, wanted_type))
		var/mob/M = find_object
		check_stat(M)

	//переноска
	if(istype(find_object, /obj/item/pet_carrier))
		var/obj/item/pet_carrier/C = find_object
		if(!C.contains_pet)
			return FALSE
		for(var/mob/M in C.contents)
			check_stat(M)
	return FALSE

/datum/objective/steal_pet/additional_conditions()
	var/list/all_items = owner.current.GetAllContents()
	for(var/I in all_items)
		//из переноски
		if(ismob(I))
			var/mob/M = I
			check_stat(M)

		//животное-предмет "холдер"
		if(wanted_holder_type)
			if(!istype(I, wanted_holder_type))
				var/obj/item/holder/H = I
				for(var/mob/M in H.contents)
					check_stat(M)
	return FALSE

/datum/objective/steal_pet/proc/check_stat(var/mob/M)
	if(!istype(M, wanted_type))
		return FALSE
	if(M.stat != DEAD)
		return TRUE



//==========================
//=========Collect==========
//==========================
/datum/objective/collect
	var/type_theft_flag = THEFT_FLAG_COLLECT
	var/datum/theft_objective/collect/collect_objective
	explanation_text = "Собрать: "

/datum/objective/collect/find_target()
	var/list/valid_objectives_list = list()
	for(var/theft_type in get_theft_list_objectives(type_theft_flag))
		for(var/datum/objective/collect/objective in owner.objectives)
			if(istype(objective) && istype(objective.collect_objective, theft_type))
				continue
		var/datum/theft_objective/O = new theft_type
		if(O.flags & 2)
			continue
		valid_objectives_list += O

	if(length(valid_objectives_list))

		while(!collect_objective)
			if(!length(valid_objectives_list))
				return FALSE
			var/datum/theft_objective/collect/temp_objective = pick(valid_objectives_list)
			valid_objectives_list.Remove(temp_objective)
			check_collection(temp_objective)

	if(collect_objective)
		return TRUE
	return FALSE

/datum/objective/collect/proc/check_collection(var/datum/theft_objective/collect/temp_objective)
	if(length(temp_objective.wanted_items))
		collect_objective = temp_objective
		explanation_text += collect_objective.name
		return TRUE
	return FALSE

/datum/objective/collect/proc/select_target()
	var/new_target_type = input("Select target:", "Objective target", null) as null|anything in get_theft_list_objectives(type_theft_flag)
	if(!new_target_type)
		return FALSE
	var/datum/theft_objective/collect/temp_objective = new new_target_type
	return check_collection(temp_objective)

/datum/objective/collect/check_completion()
	if(!collect_objective)
		return TRUE // Free Objective

	if(!owner.current)
		return FALSE

	return collect_objective.check_completion(owner)
