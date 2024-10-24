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
