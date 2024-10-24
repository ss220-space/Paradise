/datum/affiliate/tiger
	name = AFFIL_TIGER
	affil_info = list("Группа фанатиков верующих в Генокрадов.",
					"Стандартные цели:",
					"Сделать члена экипажа генокрадом вколов в его труп яйца генокрада",
					"Увеличить популяцию бореров",
					"Украсть определенное количество ценных вещей",
					"Убить определенное количество еретиков")
	slogan = "Душой и телом, с беспределом."
	icon_state = "tiger"
	normal_objectives = 4
	objectives = list(
					list(/datum/objective/steal = 40, /datum/objective/maroon = 40, /datum/objective/new_mini_changeling = 20),
					/datum/objective/borers,
					/datum/objective/escape
					)

/datum/affiliate/tiger/get_weight(mob/living/carbon/human/H)
	return (!ismachineperson(H)) * 2

/datum/affiliate/tiger/finalize_affiliate(datum/mind/owner)
	. = ..()
	ADD_TRAIT(owner, TRAIT_NO_GUNS, TIGER_TRAIT)
	add_discount_item(/datum/uplink_item/dangerous/sword, 0.70)
	add_discount_item(/datum/uplink_item/implants/adrenal, 0.75)
	add_discount_item(/datum/uplink_item/implants/adrenal/prototype, 0.5)

/datum/affiliate/tiger/give_default_objective()
	if(prob(65))
		if(length(active_ais()) && prob(100 / length(GLOB.player_list)))
			traitor.add_objective(/datum/objective/destroy)

		else if(prob(5))
			traitor.add_objective(/datum/objective/debrain)

		else if(prob(15))
			traitor.add_objective(/datum/objective/protect)

		else
			traitor.add_objective(/datum/objective/maroon)

	else
		traitor.add_objective(/datum/objective/steal)
