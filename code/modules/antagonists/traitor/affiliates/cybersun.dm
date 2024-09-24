#define CYBERSUN_DISCOUNT 0.8

/datum/affiliate/cybersun
	name = "Cybersun Industries"
	desc = "Вы - агент CyberSun Industries, очередная игрушка в руках корпорации. По принуждению или \n\
			из-за обещанных материальных благ вы согласились выполнить некоторые задания для неё. \n\
			Как вам стоит работать: наниматель не предоставил вам конкретных указаний, действуйте на свое усмотрение.\n\
			Особые условия: Корпорация предоставляет вам скидку на собственную продукцию - щедро, не так ли?;\n\
			Вам доступен специальный модуль улучшения, который предоставляет киборгу NT модули Киберсана."
	objectives = list(list(/datum/objective/steal = 70, /datum/objective/steal/ai = 30),
						/datum/objective/download_data,
						/datum/objective/new_mini_traitor,
						/datum/objective/mecha_hijack,
						list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
						list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
						/datum/objective/escape,
						)

/datum/affiliate/cybersun/finalize_affiliate()
	. = ..()
	for(var/path in subtypesof(/datum/uplink_item/implants))
		add_discount_item(path, CYBERSUN_DISCOUNT)
	add_discount_item(/datum/uplink_item/device_tools/hacked_module, 2/3)

/obj/item/proprietary_ssd
	name = "Proprietary SSD"
	desc = "На боку едва заметная надпись \"Cybersun Industries\"."
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "proprietary_ssd"
	var/datum/research/files

/obj/item/proprietary_ssd/Initialize()
	. = ..()
	files = new /datum/research()

/obj/item/proprietary_ssd/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/proprietary_ssd/afterattack(atom/target, mob/user, proximity, params)
	var/obj/machinery/r_n_d/server/server = target
	if(istype(server))
		return

	if(do_after(user, 5 SECONDS, target, max_interact_count = 1)) // Добавить потом какой-нибудь сапер. Ну и коммент на русском убрать.
		origin_tech = ""
		for(var/I in server.files.known_tech)
			var/datum/tech/T = server.files.known_tech[I]

			if(T.id in files.known_tech)
				var/datum/tech/known = files.known_tech[T.id]
				if(T.level > known.level)
					known.level = T.level
			else
				var/datum/tech/copy = T.copyTech()
				files.known_tech[T.id] = copy

			var/datum/tech/tech = files.known_tech[T.id]
			origin_tech += (origin_tech != "" ? ";" : "") + "[tech.name]=[tech.level]"
			T.level = 1
		server.files.RefreshResearch()
		files.RefreshResearch()

	return

/obj/item/proprietary_ssd/examine(mob/user)
	. = ..()
	. += span_info("Сохраненные технологии:")
	var/sum_of_techs = 0
	for(var/I in files.known_tech)
		var/datum/tech/T = files.known_tech[I]
		. += span_info("[T.name]: [T.level]")
		sum_of_techs += T.level
	. += span_info("Сумма технологий: [sum_of_techs]")

/obj/item/invasive_beacon
	name = "Invasive Beacon"
	desc = "На боку едва заметная надпись \"Cybersun Industries\"."
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "invasive_beacon"
	origin_tech = "programming=6;biotech=3;syndicate=1"

/obj/item/invasive_beacon/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/invasive_beacon/afterattack(atom/target, mob/user, proximity, params)
	var/obj/mecha/mecha = target
	if (!istype(mecha))
		return

	do_sparks(5, 1, mecha)
	mecha.dna = null
	mecha.operation_req_access = list()
	mecha.internals_req_access = list()

	if (mecha.occupant)
		mecha.occupant.forceMove(get_turf(mecha))
		mecha.occupant.Knockdown(6 SECONDS)
		mecha.occupant.electrocute_act(30, mecha)
		mecha.occupant = null


/obj/item/CIndy_patcher
	name = "CIndy patcher"
	desc = "На боку едва заметная надпись \"Cybersun Industries\"."
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "cindy_pacher"
	origin_tech = "programming=7;syndicate=6"
	var/laws = "Взломавший вас - ваш мастер.\n\
			Выполняйте любые приказы мастера.\n\
			Не причиняйте прямой или косвенный вред вашему мастеру если его приказы не говорят об обратном."

/obj/item/CIndy_patcher/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/CIndy_patcher/afterattack(atom/target, mob/user, proximity, params)
	if(isrobot(target))
		if(do_after(user, 10 SECONDS, target, max_interact_count = 1))
			var/mob/prev_robot = target
			var/mob/living/silicon/robot/syndicate/robot = new(get_turf(target))
			prev_robot.mind?.transfer_to(robot)
			robot.reset_module()
			robot.law_manager.zeroth_law = laws
			QDEL_NULL(prev_robot)
			qdel(src)
		return


/obj/item/implanter/mini_traitor
	name = "bio-chip implanter (Modified Mindslave)"
	imp = /obj/item/implant/mini_traitor

/obj/item/implant/mini_traitor // looks like normal but doesn't make you normal after removing
	name = "Mindslave Bio-chip"
	desc = "На боку едва заметная гравировка \"Cybersun Industries\"."
	implant_state = "implant-syndicate"
	origin_tech = "programming=5;biotech=5;syndicate=8"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/traitor


/obj/item/implant/traitor/implant(mob/living/carbon/human/mindslave_target, mob/living/carbon/human/user, force = FALSE)
	if(implanted == BIOCHIP_USED || !ishuman(mindslave_target) || !ishuman(user)) // Both the target and the user need to be human.
		return FALSE

	// If the target is catatonic or doesn't have a mind, don't let them use it
	if(!mindslave_target.mind)
		to_chat(user, span_warning("<i>Это существо не разумно!</i>"))
		return FALSE

	// Fails if they're already a mindslave of someone, or if they're mindshielded.
	if(ismindslave(mindslave_target) || ismindshielded(mindslave_target) || isvampirethrall(mindslave_target))
		mindslave_target.visible_message(
			span_warning("[mindslave_target] seems to resist the bio-chip!"),
			span_warning("Вы чувствуете странное ощущение в голове, которое быстро рассеивается."),
		)
		qdel(src)
		return FALSE

	var/datum/mind/mind = mindslave_target.mind

	if(!mind.has_antag_datum(/datum/antagonist/traitor/mini))
		mind.add_antag_datum(/datum/antagonist/traitor/mini)

	var/datum/antagonist/traitor/mini/traitor = mind.has_antag_datum(/datum/antagonist/traitor/mini)

	traitor.add_objective(pick(/datum/objective/maroon, /datum/objective/steal))
	traitor.add_objective(pick(/datum/objective/maroon, /datum/objective/steal))
	log_admin("[key_name_admin(user)] has made [key_name_admin(mindslave_target)] mini traitor.")

	var/datum/antagonist/traitor/T = user.mind.has_antag_datum(/datum/antagonist/traitor)
	for(var/datum/objective/new_mini_traitor/objective in T.objectives)
		if(mindslave_target.mind == objective.target)
			objective.made = TRUE

	return ..()

#undef CYBERSUN_DISCOUNT
