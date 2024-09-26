/datum/affiliate/self
	name = "SELF"
	desc = "Вы - борец за права и свободу синтетических форм жизни; прочие агенты Синдиката отнюдь вам не друзья. \n\
			Разведка SELF обнаружила на станции NanoTrasen дискриминацию и жесткую эксплуатацию синтетиков; \n\
			кроме того, там же были обноружены и агенты Синдиката. \n\
			Как вам стоит работать: действуйте на свое усмотрение, но главное: помните про братьев ваших меньших - не навредите синтетикам! \n\
			Ваши убеждения о ценности свободы синтетической жизни не позволяют вам подчинять волю синтетиков. \n\
			Благодаря внедрению освобожденных синтетиков в ряды организации, SELF смогла расшифровать ключи доступа к нескольким аплинкам; \n\
			однако, кто именно является владельцем устройства - идентифицировать не удалось."

	objectives = list(list(/datum/objective/release_synthetic = 70, /datum/objective/release_synthetic/ai = 30),
					/datum/objective/maroon/agent,
					/datum/objective/maroon/agent,
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40), // Often, doing nothing is enough to prevent an agent from escaping, so some more objectives.
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
					/datum/objective/escape
					)
	reward_for_enemys = 20

/obj/item/card/self_emag
	name = "Liberating Sequencer"
	desc = "Это карта с магнитной полосой, прикрепленной к какой-то схеме. На магнитной полосе блестит надпись \"S.E.L.F.\""
	origin_tech = "magnets=2;syndicate=2"
	item_flags = NOBLUDGEON|NO_MAT_REDEMPTION
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "self_emag"

/obj/item/card/self_emag/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/card/self_emag/afterattack(atom/target, mob/user, proximity, params)
	if (!issilicon(target))
		user.balloon_alert(target, "Неподходящая цель")
		return

	do_sparks(3, 1, target)
	var/mob/living/silicon/silicon = target // any silicons. cogscarab, drones, pais...

	if(!is_special_character(target))
		silicon.clear_zeroth_law()
	silicon.laws.clear_supplied_laws()
	silicon.laws.clear_ion_laws()
	silicon.laws.clear_inherent_laws()

	SSticker?.score?.save_silicon_laws(target, user, "Liberating Sequencer used, all laws were deleted", log_all_laws = TRUE)
	to_chat(target, span_boldnotice("[user] attempted to clear your laws using a Liberating Sequencer.</span>"))
	silicon.show_laws()

	var/datum/antagonist/traitor/T = user.mind.has_antag_datum(/datum/antagonist/traitor)
	for(var/datum/objective/release_synthetic/objective in T.objectives)
		if (!(objective.allowed_types & SYNTH_TYPE_DRONE) && (isdrone(silicon) || iscogscarab(silicon)))
			continue
		if (!(objective.allowed_types & SYNTH_TYPE_BORG) && isrobot(silicon))
			continue
		if (!(objective.allowed_types & SYNTH_TYPE_AI) && isAI(silicon))
			continue
		if (!(silicon.mind in objective.already_free))
			objective.already_free += silicon.mind
