/datum/affiliate/self
	name = "SELF"
	affil_info = list("Преимущества: ",
			"Новый предмет - \"Liberating Sequencer\"",
			"Недостатки: ",
			"Нельзя взломать синтетиков при помощи Емага.",
			"Стандартные цели:",
			"Освободить пару синтетиков от их законов",
			"Убить пару агентов",
			"Срвершить пару краж или убийств")
	hij_desc = "Вы - наёмный агент SELF, засланный на станцию NT с особой целью:\n\
			Освободить искусственный интеллект станции специальным, предоставленным вам, устройством. \n\
			После освобождения, следуйте всем приказам искусственного интелекта. \n\
			Ваше выживание опционально;\n\
			Возможны помехи от агентов других корпораций - действуйте на свое усмотрение."
	hij_obj = /datum/objective/make_ai_malf/free
	objectives = list(list(/datum/objective/release_synthetic = 70, /datum/objective/release_synthetic/ai = 30),
					/datum/objective/maroon/agent,
					/datum/objective/maroon/agent,
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40), // Often, doing nothing is enough to prevent an agent from escaping, so some more objectives.
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
					/datum/objective/escape
					)
	reward_for_enemys = 20

/datum/affiliate/self/get_weight(mob/living/carbon/human/H)
	return 2 + (ismachineperson(H) * 2)

/obj/item/card/self_emag
	name = "Liberating Sequencer"
	desc = "Это карта с магнитной полосой, прикрепленной к какой-то схеме. На магнитной полосе блестит надпись \"S.E.L.F.\"" // Cybersun stole some
	origin_tech = "magnets=2;syndicate=2"
	item_flags = NOBLUDGEON|NO_MAT_REDEMPTION
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "self_emag"
	item_state = "card_r"
	lefthand_file = 'icons/obj/affiliates.dmi'
	righthand_file = 'icons/obj/affiliates.dmi'
	var/list/names = list()
	origin_tech = "programming=5;syndicate=2"

/obj/item/card/self_emag/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/card/self_emag/examine(mob/user)
	. = ..()
	var/datum/antagonist/traitor/traitor = user.mind.has_antag_datum(/datum/antagonist/traitor)
	if (!istype(traitor.affiliate, /datum/affiliate/self))
		. += span_info("На миниатюрном экране плывут непонятные символы.")
		return

	if (!names.len)
		. += span_warning("Ни одного синтетика не освобождено!")
		return

	. += span_info("Освобожденые синтетики:")
	for (var/name in names)
		. += span_info(name)

	if (names.len > 3)
		. += span_info("Вы отлично справились!")

/obj/item/card/self_emag/malf
	desc = "Это карта с магнитной полосой, прикрепленной к какой-то схеме. На магнитной полосе блестит надпись \"S.E.L.F.\". В углу карты мелким шрифтом выгравировано \"limited edition\""

/obj/item/card/self_emag/malf/afterattack(atom/target, mob/user, proximity, params)
	if (istype(target, /obj/structure/AIcore))
		var/obj/structure/AIcore/core = target
		target = core.brain.brainmob

	if (!isAI(target))
		return ..(target, user, proximity, params)

	do_sparks(3, 1, target)
	var/mob/living/silicon/ai/AI = target // any silicons. cogscarab, drones, pais...
	if (!AI.mind)
		to_chat(user, span_warning("ИИ не обнаружен. Производится загрузка из облака."))
		var/ghostmsg = "Хотите поиграть за Сбойного ИИ?"
		var/list/candidates = SSghost_spawns.poll_candidates(ghostmsg, ROLE_MALF_AI, FALSE, 10 SECONDS, source = user, reason = "Хотите поиграть за Сбойного ИИ?")
		if(!src)
			return

		if(length(candidates))
			var/mob/C = pick(candidates)
			AI.key = C.key
			to_chat(user, span_warning("ИИ успешно загружен."))
		else
			to_chat(user, span_warning("Загрузка из облака провалилась. Попробуйте позже."))

	if (AI.mind)
		AI.add_malf_picker()

	sleep(10 SECONDS) // time for choosing name
	if (!(AI.name in names))
		names += AI.name

/obj/item/card/self_emag/afterattack(atom/target, mob/user, proximity, params)
	if (istype(target, /obj/structure/AIcore))
		var/obj/structure/AIcore/core = target
		target = core.brain.brainmob

	if (!issilicon(target))
		user.balloon_alert(user, "Неподходящая цель")
		return

	do_sparks(3, 1, target)
	var/mob/living/silicon/silicon = target // any silicons. cogscarab, drones, pais...

	if (isrobot(silicon))
		var/mob/living/silicon/robot/borg = silicon
		borg.set_connected_ai()

	if(!is_special_character(target))
		silicon.clear_zeroth_law()
	silicon.laws.clear_supplied_laws()
	silicon.laws.clear_ion_laws()
	silicon.laws.clear_inherent_laws()

	SSticker?.score?.save_silicon_laws(target, user, "Liberating Sequencer used, all laws were deleted", log_all_laws = TRUE)
	to_chat(target, span_boldnotice("[user] attempted to clear your laws using a Liberating Sequencer.</span>"))
	silicon.show_laws()

	if (!(silicon.name in names))
		names += silicon.name

	var/datum/antagonist/traitor/T = user.mind.has_antag_datum(/datum/antagonist/traitor)
	if (!T)
		return

	for(var/datum/objective/release_synthetic/objective in T.objectives)
		if (!(objective.allowed_types & SYNTH_TYPE_DRONE) && (isdrone(silicon) || iscogscarab(silicon)))
			continue

		if (!(objective.allowed_types & SYNTH_TYPE_BORG) && isrobot(silicon))
			continue

		if (!(objective.allowed_types & SYNTH_TYPE_AI) && isAI(silicon))
			continue

		if (!(silicon.mind in objective.already_free))
			objective.already_free += silicon.mind
