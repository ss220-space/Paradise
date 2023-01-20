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

/datum/objective/steal_structure/New()
	..()
	var/list/list_structures = list(
		/obj/structure/statue/bananium/clown/unique,
		/obj/structure/statue/tranquillite/mime/unique
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
	var/mob/living/simple_animal/pet/wanted_type
	var/range_complete = 2

/datum/objective/steal_pet/New()
	..()
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
	)
	wanted_type = pick(list_pets)
	explanation_text += wanted_type.name

/datum/objective/steal_pet/check_completion()
	if(wanted_type && owner.current)
		var/mob/living/simple_animal/M
		//!!!!Проверку на нахождение в руке или инвентаре

		for(var/O in range(range_complete, owner.current.loc))
			if(istype(O, wanted_type))
				M = O
				if(M.stat != DEAD)
					return TRUE

			if(istype(O, /obj/structure/closet))
				var/obj/structure/closet/C = O
				for(var/mob/living/simple_animal/temp_M in C.contents)
					if(istype(O, wanted_type))
						M = temp_M
						if(M.stat != DEAD)
							return TRUE
	return FALSE

/datum/theft_objective/hard
	flags = THEFT_FLAG_HARD




/datum/theft_objective/easy
	flags = THEFT_FLAG_EASY



/datum/theft_objective/easy
	name = "the chief engineer's advanced magnetic boots"
	typepath = /obj/item/clothing/shoes/magboots/advance
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/collect
	flags = THEFT_FLAG_COLLECT
	var/possible_amount_min	= 2
	var/possible_amount_max	= 5
