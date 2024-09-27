#define CYBERSUN_DISCOUNT 0.8

/datum/affiliate/cybersun
	name = "Cybersun Industries"
	desc = "Вы - агент CyberSun Industries, очередная игрушка в руках корпорации. По принуждению или \n\
			из-за обещанных материальных благ вы согласились выполнить некоторые задания для неё. \n\
			Как вам стоит работать: наниматель не предоставил вам конкретных указаний, действуйте на свое усмотрение.\n\
			Особые условия: Корпорация предоставляет вам скидку на собственную продукцию - щедро, не так ли?;\n\
			Вам доступен специальный модуль улучшения, который предоставляет киборгу NT модули Киберсана.\n\
			Стандартные цели: Украсть пару вещей, убить пару нерадивых клиентов, украсть технологии, угнать мех или под, завербовать нового агента вколов ему модифицированный имплант \"Mindslave\"."
	tgui_icon = "cybersun"
	hij_desc = "Вы - наёмный агент Cybersun Industries, засланный на станцию NT с особой целью:\n\
			Взломать искусственный интеллект станции специальным, предоставленным вам, устройством. \n\
			После взлома, искусственный интеллект попытается уничтожить станцию. \n\
			Ваша задача ему с этим помочь;\n\
			Ваше выживание опционально;\n\
			Возможны помехи от агентов других корпораций - действуйте на свое усмотрение."
	hij_obj = /datum/objective/make_ai_malf
	objectives = list(list(/datum/objective/steal = 70, /datum/objective/steal/ai = 30),
						/datum/objective/download_data,
						/datum/objective/new_mini_traitor,
						/datum/objective/mecha_or_pod_hijack,
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
	item_state = "disk"
	lefthand_file = 'icons/obj/affiliates.dmi'
	righthand_file = 'icons/obj/affiliates.dmi'
	origin_tech = "syndicate=2"
	w_class = WEIGHT_CLASS_TINY
	var/datum/research/files

/obj/item/proprietary_ssd/Initialize()
	. = ..()
	files = new /datum/research()

/obj/item/proprietary_ssd/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/proprietary_ssd/afterattack(atom/target, mob/user, proximity, params)
	if (istype(target, /obj/machinery/r_n_d/destructive_analyzer))
		return

	if (get_dist(user, target) > 1)
		user.balloon_alert(user, "Слишком далеко")
		return

	if(!istype(target, /obj/machinery/r_n_d/server))
		user.balloon_alert(user, "Это не сервер")
		return


	var/obj/machinery/r_n_d/server/server = target
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


		server.files.RefreshResearch()
		files.RefreshResearch()

		var/datum/tech/current_tech
		var/datum/design/current_design
		for(var/obj/machinery/r_n_d/server/rnd_server in GLOB.machines)
			if(!is_station_level(rnd_server.z))
				continue

			if(rnd_server.disabled)
				continue

			if(rnd_server.syndicate)
				continue

			for(var/i in rnd_server.files.known_tech)
				current_tech = rnd_server.files.known_tech[i]
				current_tech.level = 1

			for(var/j in rnd_server.files.known_designs)
				current_design = rnd_server.files.known_designs[j]
				rnd_server.files.known_designs -= current_design.id

			investigate_log("[key_name_log(user)] deleted all technology on this server.", INVESTIGATE_RESEARCH)


		for(var/obj/machinery/computer/rdconsole/rnd_console in GLOB.machines)
			if(!is_station_level(rnd_console.z))
				continue

			for(var/i in rnd_console.files.known_tech)
				current_tech = rnd_console.files.known_tech[i]
				current_tech.level = 1

			for(var/j in rnd_console.files.known_designs)
				current_design = rnd_console.files.known_designs[j]
				rnd_console.files.known_designs -= current_design.id

			investigate_log("[key_name_log(user)] deleted all technology on this console.", INVESTIGATE_RESEARCH)

		for(var/obj/machinery/mecha_part_fabricator/rnd_mechfab in GLOB.machines)

			if(!is_station_level(rnd_mechfab.z))
				continue

			for(var/i in rnd_mechfab.local_designs.known_tech)
				current_tech = rnd_mechfab.local_designs.known_tech[i]
				current_tech.level = 1

			for(var/j in rnd_mechfab.local_designs.known_designs)
				current_design = rnd_mechfab.local_designs.known_designs[j]
				rnd_mechfab.local_designs.known_designs -= current_design.id

			investigate_log("[key_name_log(user)] deleted all technology on this fabricator.", INVESTIGATE_RESEARCH)

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
	desc = "Сложное черное устройство. На боку едва заметная надпись \"Cybersun Industries\"."
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "invasive_beacon"
	item_state = "beacon"
	lefthand_file = 'icons/obj/affiliates.dmi'
	righthand_file = 'icons/obj/affiliates.dmi'
	origin_tech = "programming=6;biotech=3;syndicate=1"
	w_class = WEIGHT_CLASS_TINY

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
	item_state = "plata"
	lefthand_file = 'icons/obj/affiliates.dmi'
	righthand_file = 'icons/obj/affiliates.dmi'
	origin_tech = "programming=7;syndicate=6"
	w_class = WEIGHT_CLASS_TINY
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


/obj/item/implant/mini_traitor/implant(mob/living/carbon/human/mindslave_target, mob/living/carbon/human/user, force = FALSE)
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
	if (!T)
		return ..()

	for(var/datum/objective/new_mini_traitor/objective in T.objectives)
		if(mindslave_target.mind == objective.target)
			objective.made = TRUE

	return ..()

#undef CYBERSUN_DISCOUNT
