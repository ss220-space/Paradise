/datum/objective/steal/hard
	type_theft_flag = THEFT_FLAG_HARD

/datum/objective/steal/easy
	type_theft_flag = THEFT_FLAG_EASY

/datum/objective/steal/collect
	type_theft_flag = THEFT_FLAG_COLLECT

/datum/objective/steal_structure
	explanation_text = "Кража структуры: "
	var/obj/structure/wanted_type
	var/range_complete = 2

/datum/objective/steal_structure/find_target()
	var/list/list_structures = list(
		/obj/structure/statue/bananium/clown/unique,
		/obj/structure/statue/tranquillite/mime/unique,
		/obj/structure/toilet/captain_toilet,
	)
	wanted_type = pick(list_structures)
	explanation_text += wanted_type.name

/datum/objective/steal_structure/check_completion()
	if(wanted_type && owner.current)
		for(var/obj/structure/S in range(range_complete, owner.current.loc))
			if(istype(S, wanted_type))
				return TRUE
	return FALSE


/datum/objective/steal_pet
	explanation_text = "Кража живого питомца: "
	var/mob/living/wanted_type
	var/range_complete = 2

/datum/objective/steal_pet/find_target()
	var/list/list_pets = list(
		/mob/living/simple_animal/pet/dog/corgi/Ian,
		/mob/living/simple_animal/pet/dog/corgi/borgi,
		/mob/living/simple_animal/pet/dog/fox/Renault,
		/mob/living/simple_animal/pet/cat/floppa,
		/mob/living/simple_animal/pet/cat/Runtime,
		/mob/living/simple_animal/crab/Coffee,
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
	wanted_type = pick(list_pets)
	explanation_text += wanted_type.name

/datum/objective/steal_pet/check_completion()
	if(!wanted_type)
		return TRUE

	if(!owner.current)
		return FALSE

	var/list/all_items = owner.current.GetAllContents()
	for(var/obj/item/holder/H in all_items)
		if(!istype(H, wanted_type.holder_type))
			continue
		for(var/mob/M in H.contents)
			if(!istype(M, wanted_type))
				continue
			if(M.stat != DEAD)
				return TRUE

	var/mob/living/simple_animal/M

	for(var/O in range(range_complete, owner.current.loc))
		if(istype(O, wanted_type))
			M = O
			if(M.stat != DEAD)
				return TRUE

		if(istype(O, /obj/structure/closet))
			var/obj/structure/closet/C = O
			for(var/mob/living/temp_M in C.contents)
				if(istype(O, wanted_type))
					M = temp_M
					if(M.stat != DEAD)
						return TRUE
	return FALSE

/datum/objective/collect
	var/datum/theft_objective/collect/collect_targets
	name = "Украдите что угодно хоть сколько-нибудь ценное"
	var/step=1
	var/required_amount=0
	var/list/obj/typepath_list = list()

/datum/objective/steal/check_completion()
	if(!collect_targets)
		return 1 // Free Objective

	if(!owner.current)
		return FALSE

	var/list/all_items = owner.current.GetAllContents()

	for(var/obj/I in all_items)
		//!!!!Проверку на каждый предмет
		if(istype(I, collect_targets.typepath))
			return collect_targets.check_special_completion(I)
		if(I.type in collect_targets.altitems)
			return collect_targets.check_special_completion(I)


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

	explanation_text = "Украдите что угодно."
