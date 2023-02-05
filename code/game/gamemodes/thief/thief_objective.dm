/datum/objective/steal/hard
	type_theft_flag = THEFT_FLAG_HARD

/datum/objective/steal/medium
	type_theft_flag = THEFT_FLAG_MEDIUM

/datum/objective/steal/collect
	explanation_text = "Собрать "
	type_theft_flag = THEFT_FLAG_COLLECT

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
	steal_target = pick(possible_structures_list)
	explanation_text += steal_target.name
	//!!!!!!!!! Exception has occurred: Cannot read /obj/structure/statue/tranquil... (/obj/structure/statue/tranquillite/mime/unique).name


/datum/objective/steal_structure/check_completion()
	if(steal_target && owner.current)
		for(var/obj/S in range(range_complete, owner.current.loc))
			if(istype(S, steal_target))
				return TRUE
	return FALSE

/datum/objective/steal_structure/proc/select_target()
	var/new_target = input("Select target:", "Objective target", null) as null|anything in possible_structures_list
	if(!new_target) return
	steal_target = new new_target
	//explanation_text = "Украсть структуру: [steal_target.name]."
	explanation_text += steal_target.name
	return steal_target

/datum/objective/steal_pet
	explanation_text = "Украсть живого питомца "
	var/mob/living/steal_target
	var/range_complete = 2

	var/possible_pets_list = list(
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
	steal_target = pick(possible_pets_list)
	explanation_text += steal_target.name

/datum/objective/steal_pet/check_completion()
	if(!steal_target)
		return TRUE

	if(!owner.current)
		return FALSE

	var/list/all_items = owner.current.GetAllContents()
	for(var/obj/item/holder/H in all_items)
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
	var/new_target = input("Select target:", "Objective target", null) as null|anything in possible_pets_list
	if(!new_target) return
	steal_target = new_target//new new_target
	//var/target_name = ismonkeybasic(steal_target) :
	//!!!!!!!Exception has occurred: Cannot read /mob/living/simple_animal/pet/... (/mob/living/simple_animal/pet/cat/Runtime).name

	explanation_text += steal_target.name
	return steal_target


/datum/objective/collect	//Раскомментировать глобал список
	//var/datum/theft_objective/collect/collect_targets
	explanation_text = "Соберите "
	var/step=1
	var/required_amount=0
	var/list/obj/typepath_list = list()

/*
/datum/objective/collect/find_target()
	var/list/valid_theft_objectives = list()
	for(var/thefttype in GLOB.potential_theft_objectives_collect)
		for(var/datum/objective/collect/objective in owner.objectives)
			if(istype(objective) && istype(objective.collect_targets, thefttype))
				continue
		var/datum/theft_objective/O = new thefttype
		if(O.flags & 2)
			continue
		valid_theft_objectives += O

	if(length(valid_theft_objectives))
		var/datum/theft_objective/O = pick(valid_theft_objectives)
		collect_targets = O

		explanation_text = "Собрать [collect_targets]"
		return

	explanation_text = "Украдите что угодно хоть сколько-нибудь ценное."

/datum/objective/collect/check_completion()
	if(!typepath_list)
		return 1 // Free Objective

	if(!owner.current)
		return FALSE

	var/list/all_items = owner.current.GetAllContents()

	for(var/obj/I in all_items)
		for(var/obj/typeI in typepath_list)
			if(istype(I, typeI))
				return collect_targets.check_special_completion(I)


*/
/datum/objective/collect/proc/select_target()
	//var/new_target = input("Select target:", "Objective target", null) as null|anything in potential_theft_objectives_collect
	//if(!new_target) return
	//steal_target = new new_target
	//explanation_text = "Кража живого питомца: [steal_target.name]."
	//return steal_target
	return FALSE
