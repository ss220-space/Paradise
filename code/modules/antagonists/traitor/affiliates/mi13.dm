/datum/affiliate/mi13
	name = AFFIL_MI13
	affil_info = list("Агенство специализирующееся на добыче и продаже секретной информации и разработок.",
					"Стандартные цели:",
					"Украсть секретные документы",
					"Украсть определенное количество ценных вещей",
					"Убить определенное количество членов экипажа",
					"Обменяться секретными документами с другим агентом",
					"Выглядеть стильно")
	slogan = "Да, я Бонд. Джеймс Бонд."
	normal_objectives = 2
	objectives = list(
//					/datum/objective/steal/documents,
//					list(/datum/objective/steal = 30, /datum/objective/maroon/blueshield = 70), // blueshield also has CQC.
					/datum/objective/maroon/agent,
					/datum/objective/maroon/agent,
					/datum/objective/steal,
					/datum/objective/escape
					)

/proc/is_MI13_agent(mob/living/user)
	var/datum/antagonist/traitor/traitor = user?.mind?.has_antag_datum(/datum/antagonist/traitor)
	return istype(traitor?.affiliate, /datum/affiliate/mi13)

/datum/affiliate/mi13/finalize_affiliate(datum/mind/owner)
	. = ..()
	var/datum/antagonist/traitor/traitor = owner.has_antag_datum(/datum/antagonist/traitor)
	traitor.assign_exchange_role(SSticker.mode.exchange_red)
	uplink.get_intelligence_data = TRUE
	add_discount_item(/datum/uplink_item/stealthy_weapons/cqc, 0.8)

/datum/affiliate/mi13/give_bonus_objectives(datum/mind/mind)
	var/datum/antagonist/traitor/traitor = mind?.has_antag_datum(/datum/antagonist/traitor)

	traitor.add_objective(/datum/objective/steal)
	traitor.add_objective(/datum/objective/steal)

/datum/affiliate/mi13/give_default_objective()
	if(prob(40))
		if(length(active_ais()) && prob(100 / length(GLOB.player_list)))
			traitor.add_objective(/datum/objective/destroy)

		else if(prob(5))
			traitor.add_objective(/datum/objective/debrain)

		else if(prob(10))
			traitor.add_objective(/datum/objective/protect)

		else if(prob(5))
			traitor.add_objective(/datum/objective/steal/documents)

		else
			traitor.add_objective(/datum/objective/maroon)

	else
		traitor.add_objective(/datum/objective/steal)
