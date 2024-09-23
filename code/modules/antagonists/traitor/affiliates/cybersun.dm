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
		var/datum/uplink_item/new_item = new path
		new_item.cost = round(new_item.cost * CYBERSUN_DISCOUNT)
		new_item.name += ((1-CYBERSUN_DISCOUNT)*100) +"%"
		new_item.category = "Discounted Gear"
		uplink.uplink_items.Add(new_item)


/obj/item/proprietary_ssd
	name = "Proprietary SSD"
	desc = "На боку едва заметная надпись \"Cybersun Industries\"."
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "proprietary_ssd"
	var/datum/research/files

/obj/item/proprietary_ssd/Initialize()
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

			origin_tech += (origin_tech != "" ? ";" : "") + "[files.known_tech[T.id].name]=[files.known_tech[T.id].level]"
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
	origin_tech = "programming=6;biotech=3"

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
	icon = 'icons/obj/module.dmi'
	icon_state = "syndicate_cyborg_upgrade"

/obj/item/CIndy_patcher/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/CIndy_patcher/afterattack(atom/target, mob/user, proximity, params)
	if(isrobot(target))
		if(do_after(user, 10 SECONDS, target, max_interact_count = 1))
			var/mob/prev_robot = target
			var/mob/living/silicon/robot/syndicate/robot = new(get_turf(target))
			prev_robot.mind?.transfer_to(robot)
			robot.reset_module()
			QDEL_NULL(prev_robot)
			qdel(src)
		return

/obj/item/invasive_beacon //
	name = "Invasive Beacon"
	desc = "Looks like it can't transmit data anymore."
	icon = 'icons/obj/device.dmi'
	icon_state = "broken_bacon"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/broken_bacon/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/broken_bacon/afterattack(atom/target, mob/user, proximity, params)
	if(ismecha(target))
		var/obj/mecha/mecha = target
		mecha.hacked = TRUE
		do_sparks(5, 1, mecha)
		qdel(src)

#undef CYBERSUN_DISCOUNT
