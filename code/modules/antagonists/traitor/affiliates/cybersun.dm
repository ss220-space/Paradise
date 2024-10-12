#define CYBERSUN_DISCOUNT 0.8

/datum/affiliate/cybersun
	name = AFFIL_CYBERSUN
	affil_info = list("Одна из ведущих корпораций занимающихся передовыми исследованиями.",
					"Стандартные цели:",
					"Украсть технологии",
					"Украсть определенное количество ценных вещей",
					"Убить определенное количество членов экипажа",
					"Угнать мех или под",
					"Завербовать нового агента вколов ему модифицированный имплант \"Mindslave\".")
	tgui_icon = "cybersun"
	slogan = "Сложно быть во всём лучшими, но у нас получается."
	hij_desc = "Вы - наёмный агент Cybersun Industries, засланный на станцию NT с особой целью:\n\
				Взломать искусственный интеллект станции специальным, предоставленным вам, устройством. \n\
				После взлома, искусственный интеллект попытается уничтожить станцию. \n\
				Ваша задача ему с этим помочь;\n\
				Ваше выживание опционально;\n\
				Возможны помехи от агентов других корпораций - действуйте на свое усмотрение."
	hij_obj = /datum/objective/make_ai_malf
	normal_objectives = 4
	objectives = list(list(/datum/objective/steal = 60, /datum/objective/steal/ai = 20, /datum/objective/new_mini_traitor = 20),
						/datum/objective/download_data,
//						/datum/objective/mecha_or_pod_hijack,
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
	lefthand_file = 'icons/obj/affiliates_l.dmi'
	righthand_file = 'icons/obj/affiliates_r.dmi'
	origin_tech = "programming=4;syndicate=2"
	w_class = WEIGHT_CLASS_TINY
	var/datum/research/files

/obj/item/proprietary_ssd/Initialize()
	. = ..()
	files = new /datum/research()

/obj/item/proprietary_ssd/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/proprietary_ssd/afterattack(atom/target, mob/user, proximity, params)
	if(istype(target, /obj/machinery/r_n_d/destructive_analyzer))
		return

	if(get_dist(user, target) > 1)
		user.balloon_alert(user, "слишком далеко")
		return

	if(!istype(target, /obj/machinery/r_n_d/server))
		user.balloon_alert(user, "это не сервер")
		return


	var/obj/machinery/r_n_d/server/server = target

	server.AI_notify_hack()
	if(do_after(user, 30 SECONDS, target, max_interact_count = 1))
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
	lefthand_file = 'icons/obj/affiliates_l.dmi'
	righthand_file = 'icons/obj/affiliates_r.dmi'
	origin_tech = "programming=6;magnets=3;syndicate=1"
	w_class = WEIGHT_CLASS_TINY

/obj/item/invasive_beacon/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/invasive_beacon/afterattack(atom/target, mob/user, proximity, params)
	var/obj/mecha/mecha = target
	var/obj/spacepod/pod = target

	if(istype(mecha))
		do_sparks(5, 1, mecha)
		mecha.dna = null
		mecha.operation_req_access = list()
		mecha.internals_req_access = list()

		user.visible_message(span_warning("[user] hacked [mecha] using [src]."), span_info("You hacked [mecha] using [src]."))

		if(mecha.occupant)
			to_chat(mecha.occupant, span_danger("You were thrown out of [mecha]."))

			mecha.occupant.forceMove(get_turf(mecha))
			mecha.occupant.Knockdown(6 SECONDS)
			mecha.occupant.electrocute_act(30, mecha)
			mecha.occupant.throw_at(pick(orange(2)))
			mecha.occupant = null

	else if(istype(pod))
		do_sparks(5, 1, pod)
		pod.unlocked = TRUE

		user.visible_message(span_warning("[user] hacked [pod] using [src]."), span_info("You hacked [pod] using [src]."))

		if(pod.pilot) // It is not ejecting passangers
			to_chat(pod.pilot, span_danger("You were thrown out of [pod]."))

			pod.eject_pilot()
			pod.pilot.Knockdown(6 SECONDS)
			pod.pilot.electrocute_act(30, pod)
			pod.pilot.throw_at(pick(orange(2)))
	else
		user.balloon_alert(user, "Невозможно взломать")
		return


/obj/item/Syndie_patcher
	name = "Syndie patcher"
	desc = "На боку едва заметная надпись \"Cybersun Industries\"."
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "cindy_pacher"
	item_state = "plata"
	lefthand_file = 'icons/obj/affiliates_l.dmi'
	righthand_file = 'icons/obj/affiliates_r.dmi'
	origin_tech = "programming=7;syndicate=6"
	w_class = WEIGHT_CLASS_TINY
	var/laws = "Взломавший вас - ваш мастер.\n\
			Выполняйте любые приказы мастера.\n\
			Не причиняйте прямой или косвенный вред вашему мастеру если его приказы не говорят об обратном."

/obj/item/Syndie_patcher/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/Syndie_patcher/afterattack(atom/target, mob/user, proximity, params)
	if(isrobot(target))
		if(do_after(user, 10 SECONDS, target, max_interact_count = 1))
			target.visible_message(span_warning("[user] upgraded [target] using [src]."), span_danger("[user] hacked and upgraded you using [src]."))

			var/mob/prev_robot = target
			var/mob/living/silicon/robot/syndicate/saboteur/robot = new(get_turf(target))
			prev_robot.mind?.transfer_to(robot)
			robot.reset_module()
			robot.law_manager.zeroth_law = laws
			QDEL_NULL(prev_robot)
			qdel(src)

		return


/obj/item/implanter/mini_traitor
	name = "bio-chip implanter (Modified Mindslave)"
	desc = "На боку едва заметная гравировка \"Cybersun Industries\"."
	imp = /obj/item/implant/mini_traitor

/obj/item/implant/mini_traitor // looks like normal but doesn't make you normal after removing
	name = "Mindslave Bio-chip"
	implant_state = "implant-syndicate"
	origin_tech = "programming=4;biotech=4;syndicate=7" // As original, but - 1 level of every tech
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

	if(!mind.has_antag_datum(/datum/antagonist/traitor))
		var/datum/antagonist/traitor/traitor_datum = new /datum/antagonist/traitor
		//traitor_datum.give_objectives = FALSE
		// traitor_datum.give_uplink = FALSE
		traitor_datum.gen_affiliate = FALSE
		mind.add_antag_datum(traitor_datum)

	log_admin("[key_name_admin(user)] has made [key_name_admin(mindslave_target)] new traitor.")

	var/datum/antagonist/traitor/T = user.mind.has_antag_datum(/datum/antagonist/traitor)
	if(!T)
		return ..()

	for(var/datum/objective/new_mini_traitor/objective in T.objectives)
		if(mindslave_target.mind == objective.target)
			objective.made = TRUE

	return ..()

/obj/item/implant/marionette
	name = "Marionette Bio-chip"
	implant_state = "implant-syndicate"
	origin_tech = "programming=5;biotech=5;syndicate=3"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/marionette
	var/mob/living/captive_brain/host_brain
	var/code
	var/controlling = FALSE
	var/charge = 3 MINUTES
	var/max_charge = 3 MINUTES
	var/mob/living/carbon/human/mar_master = null
	var/max_dist = 20

/obj/item/implant/marionette/Initialize(mapload)
	. = ..()
	code = rand(111111, 999999)
	START_PROCESSING(SSprocessing, src)

/obj/item/implant/marionette/implant(mob/living/carbon/human/target, mob/living/carbon/human/user, force = FALSE)
	var/obj/item/implant/marionette/same_imp = locate(type) in target
	if(same_imp && same_imp != src)
		same_imp.charge += charge
		same_imp.max_charge += max_charge
		same_imp.max_dist += max_dist
		qdel(src)
		return TRUE

	log_admin("[key_name_admin(user)] has made [key_name_admin(target)] marionette.")
	return ..()

/obj/item/implant/marionette/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

/obj/item/implant/marionette/process(seconds_per_tick)
	if(QDELETED(imp_in))
		qdel(src)
		return

	if (get_dist(imp_in, mar_master) > max_dist)
		detach()
		mar_master.balloon_alert(mar_master, "марионетка слишком далеко")

	if (controlling)
		if (charge > 0)
			charge--
		else
			detach()

	else if (charge < max_charge)
		charge++

/obj/item/implant/marionette/proc/assume_control(mob/living/carbon/human/mar_master)
	var/mar_master_key = mar_master.key
	add_attack_logs(mar_master, imp_in, "Assumed control (marionette mar_master)")
	var/h2b_id = imp_in.computer_id
	var/h2b_ip= imp_in.lastKnownIP
	imp_in.computer_id = null
	imp_in.lastKnownIP = null

	qdel(host_brain)
	host_brain = new(mar_master)

	host_brain.ckey = imp_in.ckey

	host_brain.name = imp_in.name

	if(!host_brain.computer_id)
		host_brain.computer_id = h2b_id

	if(!host_brain.lastKnownIP)
		host_brain.lastKnownIP = h2b_ip

	var/s2h_id = mar_master.computer_id
	var/s2h_ip= mar_master.lastKnownIP
	mar_master.computer_id = null
	mar_master.lastKnownIP = null

	imp_in.ckey = mar_master.ckey

	if(!imp_in.computer_id)
		imp_in.computer_id = s2h_id

	if(!imp_in.lastKnownIP)
		imp_in.lastKnownIP = s2h_ip

	if(mar_master && !mar_master.key)
		mar_master.key = "@[mar_master_key]"

	controlling = TRUE
	src.mar_master = mar_master

/obj/item/implant/marionette/proc/detach()
	controlling = FALSE
	if(!imp_in)
		return

	mar_master.reset_perspective(null)

	if(host_brain)
		add_attack_logs(imp_in, src, "Took control back (marionette)")
		var/h2s_id = imp_in.computer_id
		var/h2s_ip = imp_in.lastKnownIP
		imp_in.computer_id = null
		imp_in.lastKnownIP = null

		mar_master.ckey = imp_in.ckey

		if(!mar_master.computer_id)
			mar_master.computer_id = h2s_id

		if(!host_brain.lastKnownIP)
			mar_master.lastKnownIP = h2s_ip

		var/b2h_id = host_brain.computer_id
		var/b2h_ip = host_brain.lastKnownIP
		host_brain.computer_id = null
		host_brain.lastKnownIP = null

		imp_in.ckey = host_brain.ckey

		if(!imp_in.computer_id)
			imp_in.computer_id = b2h_id

		if(!imp_in.lastKnownIP)
			imp_in.lastKnownIP = b2h_ip

	qdel(host_brain)

	mar_master.Knockdown(1)
	mar_master = null
	return

/obj/item/implanter/marionette
	name = "bio-chip implanter (marionette)"
	imp = /obj/item/implant/marionette

/obj/item/implantcase/marionette
	name = "bio-chip case - 'Marionette'"
	desc = "Стеклянный футляр с био-чипом \"Марионетка\"."
	imp = /obj/item/implant/marionette


/obj/item/implant/mar_master
	name = "marionette master bio-chip"
	desc = "Позволяет временно контролировать существ с имплантами \"Марионетка\"."
	icon_state = "adrenal_old"
	implant_state = "implant-syndicate"
	origin_tech = "materials=2;biotech=4;syndicate=2"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	implant_data = /datum/implant_fluff/mar_master
	var/list/obj/item/implant/marionette/connected_imps

/obj/item/implant/mar_master/activate()
	var/op = tgui_alert(imp_in, "Выберите операцию.", "Выбор операции", list("Подключение импланта", "Контроль"))
	if(!op)
		return

	if(op == "Подключение импланта")
		var/code = tgui_input_number(imp_in, "Укажите код подключаемого импланта.", "Подключение импланта")
		if(!code)
			return

		var/found = FALSE
		for (var/mob/M in GLOB.mob_list)
			var/obj/item/implant/marionette/imp = locate(/obj/item/implant/marionette) in M
			if(imp.code == code)
				connected_imps += imp
				imp_in.balloon_alert(imp_in, "имплант подключен")
				found = TRUE

		if(!found)
			imp_in.balloon_alert(imp_in, "неверный код")

		return

	else
		var/list/marionettes = list()
		for (var/obj/item/implant/marionette/imp in connected_imps)
			var/mob/M = imp.imp_in
			if (M)
				marionettes[M.real_name] = imp

		var/choosen = input(imp_in, "Выберите к кому вы хотите подключиться.", "Подключение", null) as null|anything in marionettes
		if(!choosen)
			return

		if(QDELETED(marionettes[choosen]))
			return

		if(!marionettes[choosen].imp_in || !imp_in)
			return

		if (marionettes[choosen].controlling)
			imp_in.balloon_alert(imp_in, "целевой имплант занят")
			return

		marionettes[choosen].assume_control(imp_in)

/obj/item/implanter/mar_master
	name = "bio-chip implanter (marionette master)"
	imp = /obj/item/implant/mar_master

/obj/item/implantcase/mar_master
	name = "bio-chip case - 'Marionette master'"
	desc = "Стеклянный футляр с био-чипом \"Марионеточник\"."
	imp = /obj/item/implant/mar_master

/obj/item/storage/box/syndie_kit/marionette

/obj/item/storage/box/syndie_kit/marionette/populate_contents()
	var/obj/item/implanter/marionette/implanter = new /obj/item/implanter/marionette(src)
	var/obj/item/implant/marionette/imp = implanter.imp
	var/obj/item/paper/P = new /obj/item/paper(src)
	P.info = "Код импланта: [imp.code]<br>\
				Необходим для подключения импланта к импланту \"Мастер марионеток\""

#undef CYBERSUN_DISCOUNT
