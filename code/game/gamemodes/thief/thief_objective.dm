/datum/objective/steal/hard
	type_theft_flag = THEFT_FLAG_HARD


/datum/objective/steal/medium
	type_theft_flag = THEFT_FLAG_MEDIUM


/datum/objective/steal_structure
	explanation_text = "Украсть структуру: "
	var/obj/steal_target
	var/range_complete = 2

	var/list/possible_structures_list = list(
		/obj/structure/statue/bananium/clown/unique,
		/obj/structure/statue/tranquillite/mime/unique,
		/obj/structure/toilet/captain_toilet,
		/obj/machinery/nuclearbomb,
	)

/datum/objective/steal_structure/find_target()
	var/list/valid_targets_list = possible_structures_list

	while(!steal_target)
		if(!length(valid_targets_list))
			return FALSE

		var/obj/target_type = pick(valid_targets_list)
		valid_targets_list.Remove(target_type)
		get_structure(target_type)

/datum/objective/steal_structure/proc/get_structure(var/obj/target_type)
	var/list/targets_list = get_all_of_type(target_type, subtypes = TRUE)
	if(!length(targets_list))
		return FALSE

	for(var/obj/temp_target in targets_list)
		steal_target = temp_target
		explanation_text += steal_target.name
		return TRUE

/datum/objective/steal_structure/check_completion()
	if(steal_target && owner.current)
		for(var/obj/S in range(range_complete, owner.current.loc))
			if(istype(S, steal_target))
				return TRUE
	return FALSE

/datum/objective/steal_structure/proc/select_target()
	var/new_target_type = input("Select target:", "Objective target", null) as null|anything in possible_structures_list
	if(!new_target_type)
		return FALSE
	return get_structure(new_target_type)


/datum/objective/steal_pet
	explanation_text = "Украсть живого питомца "
	var/mob/living/steal_target
	var/range_complete = 2

	var/list/possible_targets_list = list(
		/mob/living/simple_animal/pet/dog/corgi/Ian,
		/mob/living/simple_animal/pet/dog/corgi/borgi,
		/mob/living/simple_animal/pet/dog/fox/Renault,
		/mob/living/simple_animal/pet/cat/floppa,
		/mob/living/simple_animal/pet/cat/Runtime,
		/mob/living/simple_animal/crab/royal/Coffee,
		/mob/living/simple_animal/pet/dog/security,
		/mob/living/simple_animal/pet/dog/security/ranger,
		/mob/living/simple_animal/pet/dog/security/warden,
		/mob/living/simple_animal/pet/dog/security/detective,
		/mob/living/simple_animal/pet/dog/bullterrier/Genn,
		/mob/living/simple_animal/pet/sloth/paperwork,
		/mob/living/simple_animal/chicken/Wife,
		/mob/living/simple_animal/cock/Commandor,
		/mob/living/simple_animal/cow/Betsy,
		/mob/living/simple_animal/pig/Sanya,
		/mob/living/simple_animal/parrot/Poly,
		/mob/living/simple_animal/goose/Scientist,
		/mob/living/simple_animal/pet/cat/Iriska,
		/mob/living/simple_animal/mouse/hamster/Representative,
		/mob/living/carbon/human/lesser/monkey/punpun,
	)

/datum/objective/steal_pet/find_target()
	var/list/valid_targets_list = possible_targets_list

	while(!steal_target)
		if(!length(valid_targets_list))
			return FALSE

		var/mob/living/target_type = pick(valid_targets_list)
		valid_targets_list.Remove(target_type)
		get_alive_pet(target_type)

/datum/objective/steal_pet/proc/get_alive_pet(var/mob/living/target_type)
	var/list/targets_list = get_all_of_type(target_type, subtypes = TRUE)
	if(!length(targets_list))
		return FALSE

	for(var/mob/living/temp_target in targets_list)
		if(temp_target.stat != DEAD)
			steal_target = temp_target
			explanation_text += steal_target.name
			return TRUE

/datum/objective/steal_pet/check_completion()
	if(!steal_target)
		return TRUE

	if(!owner.current)
		return FALSE

	var/list/all_items = owner.current.GetAllContents()
	for(var/obj/item/holder/H in all_items)
		//var/list/holder_items = H.GetAllContents()
		//for(var/i in holder_items)
		if(!istype(H, steal_target.holder_type))
			continue
		for(var/mob/M in H.contents)
			if(!istype(M, steal_target))
				continue
			if(M.stat != DEAD)
				return TRUE

	var/mob/living/simple_animal/M

	for(var/O in range(range_complete, owner.current.loc))
		if(istype(O, steal_target))
			M = O
			if(M.stat != DEAD)
				return TRUE

		if(istype(O, /obj/structure/closet))
			var/obj/structure/closet/C = O
			for(var/mob/living/temp_M in C.contents)
				if(istype(O, steal_target))
					M = temp_M
					if(M.stat != DEAD)
						return TRUE
	return FALSE

/datum/objective/steal_pet/proc/select_target()
	var/new_target_type = input("Select target:", "Objective target", null) as null|anything in possible_targets_list
	if(!new_target_type)
		return FALSE
	return get_alive_pet(new_target_type)


/datum/objective/collect
	var/type_theft_flag = THEFT_FLAG_COLLECT
	var/datum/theft_objective/collect/collect_targets
	explanation_text = "Собрать: "
	var/required_amount=0

/datum/objective/collect/find_target()
	var/list/valid_collect_objectives = list()
	for(var/theft_type in get_theft_list_objectives(type_theft_flag))
		for(var/datum/objective/collect/objective in owner.objectives)
			if(istype(objective) && istype(objective.collect_targets, theft_type))
				continue
		var/datum/theft_objective/O = new theft_type
		if(O.flags & 2)
			continue
		valid_collect_objectives += O

	if(length(valid_collect_objectives))
		var/datum/theft_objective/collect/O = pick(valid_collect_objectives)
		collect_targets = O
		explanation_text += collect_targets.name
		return TRUE

	explanation_text = "Украдите что угодно хоть сколько-нибудь ценное."

/datum/objective/collect/check_completion()
	if(!collect_targets)
		return TRUE // Free Objective

	if(!owner.current)
		return FALSE

	collect_targets.check_completion(owner)

/datum/objective/collect/proc/select_target()
	var/new_target = input("Select target:", "Objective target", null) as null|anything in get_theft_list_objectives(type_theft_flag)
	if(!new_target) return
	collect_targets = new new_target
	explanation_text += collect_targets.name
	return collect_targets
