/**
 * Atom level proc for space ninja'rnd_server glove interactions.
 *
 * Proc which only occurs when space ninja uses his gloves on an atom.
 * Does nothing by default, but effects will vary.
 * Arguments:
 * * ninja_suit - The offending space ninja'rnd_server suit.
 * * ninja - The human mob wearing the suit.
 * * ninja_gloves - The offending space ninja'rnd_server gloves.
 */
/atom/proc/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	return INVALID_DRAIN

//APC//
/obj/machinery/power/apc/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	var/maxcapacity = FALSE //Safety check for batteries
	var/drain = 0 //Drain amount from batteries
	var/drain_total = 0
	add_attack_logs(ninja, src, "draining energy from [src] [ADMIN_COORDJMP(src)]", ATKLOG_MOST)
	var/area/area = get_area(src)
	if(area && istype(area, /area/engine/engineering))
		//На русском чтобы даже полному идиоту было ясно, почему им не даётся сосать ток из этого АПЦ
		to_chat(ninja, span_danger("Внимание: Высасывание энергии из АПЦ в этой зоне потенциально может привести к неконтролируемым разрушениям. Процесс отменён."))
		return INVALID_DRAIN
	if(cell?.charge)
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)
		while(cell.charge > 0 && !maxcapacity)
			drain = rand(ninja_gloves.mindrain, ninja_gloves.maxdrain)

			if(cell.charge < drain)
				drain = cell.charge

			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE//Reached maximum battery capacity.

			if(do_after(ninja ,10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE, 5)
				cell.use(drain)
				ninja_suit.cell.give(drain)
				drain_total += drain
			else
				break

		if(!(on_blueprints & emagged))
			flick("apc-spark", ninja_gloves)
			playsound(loc, "sparks", 50, TRUE, 5)
			emagged = TRUE
			locked = FALSE
			update_icon()

	return drain_total

//SMES//
/obj/machinery/power/smes/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	var/maxcapacity = FALSE //Safety check for batteries
	var/drain = 0 //Drain amount from batteries
	var/drain_total = 0
	add_attack_logs(ninja, src, "draining energy from  [src] [ADMIN_COORDJMP(src)]", ATKLOG_MOST)

	var/area/area = get_area(src)
	if(charge)

		if(area)
			investigate_log("<font color='red'>[ninja.real_name] started draining [src] of energy </font> at ([area.name])","singulo")
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)

		while(charge > 0 && !maxcapacity)
			drain = rand(ninja_gloves.mindrain, ninja_gloves.maxdrain)

			if(charge < drain)
				drain = charge

			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE

			if (do_after(ninja,10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE, 5)
				charge -= drain
				ninja_suit.cell.give(drain)
				drain_total += drain

			else
				break
		if(area)
			investigate_log("<font color='red'>[ninja.real_name] ended draining [src] of energy </font> at ([area.name]). Remaining energy: [src.charge]/[src.capacity]","singulo")

	return drain_total

//WIRE//
/obj/structure/cable/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	var/maxcapacity = FALSE //Safety check
	var/drain = 0 //Drain amount
	var/gained_total = 0
	var/drain_total = 0
	add_attack_logs(ninja, src, "draining energy from  [src] [ADMIN_COORDJMP(src)]", ATKLOG_MOST)
	var/datum/powernet/wire_powernet = powernet

	if(wire_powernet.avail <= 0 || wire_powernet.load <= 0)	// Если в проводах нет тока, то и начать сосать его мы не можем!
		return INVALID_DRAIN

	while(!maxcapacity && src)
		drain = (round((rand(ninja_gloves.mindrain, ninja_gloves.maxdrain))/2))
		var/drained = 0
		if(wire_powernet && do_after(ninja ,10, target = src))
			drained = min(drain, delayed_surplus())
			add_delayedload(drained)
			for(var/obj/machinery/power/terminal/affected_terminal in wire_powernet.nodes)
				if(istype(affected_terminal.master, /obj/machinery/power/apc))
					var/obj/machinery/power/apc/affected_apc = affected_terminal.master
					if(affected_apc.operating && affected_apc.cell && affected_apc.cell.charge > 0)
						affected_apc.cell.charge = max(0, affected_apc.cell.charge - 10)
						drain += 1
						drained += 10
		else
			break

		ninja_suit.cell.give(drain)
		if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
			ninja_suit.cell.charge = ninja_suit.cell.maxcharge
			maxcapacity = TRUE
		gained_total += drain
		drain_total += drained
		ninja_suit.spark_system.start()

	to_chat(ninja, span_notice("Energy net lost <B>[drain_total]</B> amount of energy because of the overload caused by you."))
	return gained_total

//CELL//
/obj/item/stock_parts/cell/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN
	var/maxcapacity = FALSE //Safety check for batteries
	var/drain = 0 //Drain amount from batteries
	var/drain_total = 0
	add_attack_logs(ninja, src, "draining energy from [src] [ADMIN_COORDJMP(src)]", ATKLOG_MOST)
	if(charge)
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)

		while(charge > 0 && !maxcapacity)
			drain = rand(ninja_gloves.mindrain, ninja_gloves.maxdrain)

			if(charge < drain)
				drain = charge

			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE

			if(do_after(ninja,10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE, 5)
				charge -= drain
				ninja_suit.cell.give(drain)
				drain_total += drain
			else
				break
		charge = 0
		corrupt()
		update_icon()

	return drain_total

/obj/machinery/computer/aiupload/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN
	if(src.stat & NOPOWER)
		to_chat(usr, "The upload computer has no power!")
		return
	if(src.stat & BROKEN)
		to_chat(usr, "The upload computer is broken!")
		return

	var/datum/mind/ninja_mind = ninja.mind
	if(!ninja_mind)
		return INVALID_DRAIN

	var/datum/objective/ai_corrupt/objective = locate() in ninja_mind.objectives
	if(!objective)
		return INVALID_DRAIN
	if(objective.completed)
		to_chat(ninja, span_warning("Вы уже заразили их системы вирусом. Повторная установка ничего не даст!"))
		return INVALID_DRAIN
	if(!istype(get_area(src), /area/turret_protected/ai_upload))
		to_chat(usr, span_warning("Консоль в этой зоне не подключена к необходимому бэкдору. Вирус не возымеет эффекта!"))
		return INVALID_DRAIN

	. = DRAIN_RD_HACK_FAILED

	to_chat(ninja, span_notice("Заготовленный бэкдор обнаружен. Установка вируса..."))
	AI_notify_hack()
	if(!do_after(ninja, 30 SECONDS, target = src))
		return

	for(var/mob/living/silicon/ai/currentAI in GLOB.alive_mob_list)
		if(currentAI.stat != DEAD && currentAI.see_in_dark != FALSE)
			currentAI.laws.clear_inherent_laws()

	new /datum/event/ion_storm(0, 1)
	new /datum/event/ion_storm(0, -1)
	new /datum/event/ion_storm(0, -1)

	to_chat(ninja, span_notice("Искусственный интеллект станции успешно взломан!"))
	objective.completed = TRUE

/obj/machinery/r_n_d/server/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN
	var/datum/mind/ninja_mind = ninja.mind
	if(!ninja_mind)
		return INVALID_DRAIN
	var/datum/objective/research_corrupt/objective = locate() in ninja_mind.objectives
	if(!objective)
		return INVALID_DRAIN
	if(objective.completed)
		to_chat(ninja, span_warning("Вы уже заразили их системы вирусом. Повторная установка ничего не даст!"))
		return INVALID_DRAIN

	. = DRAIN_RD_HACK_FAILED

	to_chat(ninja, span_notice("Данные об исследованиях обнаружены. Установка вируса..."))
	AI_notify_hack()
	if(!do_after(ninja, 60 SECONDS, target = src))
		return

	ninja_suit.spark_system.start()
	playsound(loc, "sparks", 50, TRUE, 5)
	var/datum/tech/current_tech
	var/datum/design/current_design
	//Удаление данных у серверов
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
		log_debug("Ninja_Objectives_Log: Успешно удалены данные и технологии у сервера: [rnd_server]")

	//Удаление данных у консолей
	for(var/obj/machinery/computer/rdconsole/rnd_console in GLOB.machines)
		if(!is_station_level(rnd_console.z))
			continue
		for(var/i in rnd_console.files.known_tech)
			current_tech = rnd_console.files.known_tech[i]
			current_tech.level = 1
		for(var/j in rnd_console.files.known_designs)
			current_design = rnd_console.files.known_designs[j]
			rnd_console.files.known_designs -= current_design.id
		log_debug("Ninja_Objectives_Log: Успешно удалены данные и технологии у консоли: [rnd_console]")
	//Фабрикаторы
	for(var/obj/machinery/mecha_part_fabricator/rnd_mechfab in GLOB.machines)
		if(!is_station_level(rnd_mechfab.z))
			continue
		for(var/i in rnd_mechfab.local_designs.known_tech)
			current_tech = rnd_mechfab.local_designs.known_tech[i]
			current_tech.level = 1
		for(var/j in rnd_mechfab.local_designs.known_designs)
			current_design = rnd_mechfab.local_designs.known_designs[j]
			rnd_mechfab.local_designs.known_designs -= current_design.id
		log_debug("Ninja_Objectives_Log: Успешно удалены данные у фабрикатора: [rnd_mechfab]")
	to_chat(ninja, span_notice("Установка успешна! Все исследования станции были стёрты."))
	objective.completed = TRUE

//AIRLOCK//
/obj/machinery/door/airlock/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN
	if(is_admin_level(src.z))
		to_chat(ninja, span_warning("Не стоит взламывать двери здесь!"))
		return INVALID_DRAIN
	if(!operating && density && hasPower() && !(on_blueprints & emagged))
		emag_act()

//Другие двери//
/obj/machinery/door/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN
	if(is_admin_level(src.z))
		to_chat(ninja, span_warning("Не стоит взламывать двери здесь!"))
		return INVALID_DRAIN
	if(!operating && density && hasPower() && !(on_blueprints & emagged))
		emag_act()

//MECH//
/obj/mecha/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	var/maxcapacity = FALSE //Safety check
	var/drain = 0 //Drain amount
	var/drain_total = 0
	add_attack_logs(ninja, src, "draining energy from [src] [ADMIN_COORDJMP(src)]", ATKLOG_MOST)
	to_chat(occupant, "[icon2base64(src, occupant)][span_danger("Warning: Unauthorized access through sub-route 4, block H, detected.")]")
	if(get_charge())
		while(cell.charge > 0 && !maxcapacity)
			drain = rand(ninja_gloves.mindrain, ninja_gloves.maxdrain)
			if(cell.charge < drain)
				drain = cell.charge
			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE
			if (do_after(ninja, 10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE, 5)
				cell.use(drain)
				ninja_suit.cell.give(drain)
				drain_total += drain
			else
				break

	return drain_total

//BORG//
/mob/living/silicon/robot/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves || (ROLE_NINJA in faction) || module_override_protected || !mind)
		return INVALID_DRAIN
	var/datum/mind/ninja_mind = ninja.mind
	if(!ninja_mind)
		return INVALID_DRAIN
	var/datum/objective/cyborg_hijack/objective = locate() in ninja_mind.objectives
	if(!objective)
		return INVALID_DRAIN
	if(objective.completed)
		to_chat(ninja, span_warning("You only had one Spider Patcher charge. you can't hijack another cyborg!"))
		return INVALID_DRAIN

	to_chat(src, span_danger("Warni-***BZZZZZZZZZRT*** UPLOADING SPYDERPATCHER VERSION 9.5.2..."))
	if (do_after(ninja, 60, target = src))
		spark_system.start()
		playsound(loc, "sparks", 50, TRUE, 5)
		to_chat(src, span_danger("UPLOAD COMPLETE. NEW CYBORG MODEL DETECTED. INSTALLING..."))
		sleep(5)
		// Это либо худшая! Либо лучшая из моих идей XD
		// Ровно разместить полоски в чате самой игры не выйдет увы...
		to_chat(src, span_danger(" \
\n___________________________________.____._________________________________\
\n_______________________________,g╝________╙W╖_____________________________\
\n___________________________,▄▓▀`_____▄▄______▀▓▄,_________________________\
\n________________________,▄▓▓▀______▄▓▓▓▓▄______╙▓▓▓,______________________\
\n______________________▄▓▓▓▀______╔▓▓▓▓█▓█▓▄______▀▓▓▓▄____________________\
\n________________,4`_▄▓▓▓▓╜______▓▓██▓▓█▓▓█▓▓,_____└▓▓▓▓▓__N,______________\
\n______________╓▓▀_/▓▓▓▓▓______╔▓▓██╣▓██▓▓██▓▓▄______▓▓▓▓▓_╙▓w_____________\
\n____________╔▓▓___,▓▀╒╜______╔▓▓██▓▓▓██▓▓▓██▓▓▄______╙L╚▓L___▓▓▄__________\
\n__________,▓▓▓____▓▌________╒▓▓███▓▓▓██▓▓▓▓██▓▓▌________▐▓____▓▓▓╖________\
\n_________g▓▓▓▌___▐▓_________▓▓▓██▓▓▓▓██▌▓▓▓███▓▓_________▓▓___╘▓▓▓▄_______\
\n________Æ▓▓▓▓____▓C________▐▓▓███▓▓▓▓██▓▓▓▓███▓▓▌_________▓____▓▓▓▓▓______\
\n________▐▓╜╘____▓▓╛________╟▓▓▓███▓▓▓██▓▓▓▓███▓▓▓________╘▓▓____Γ╙▓▌______\
\n________▓▌_______▓▌_________▓▓▓▓██▓▓▓██▓▓▓███▓▓▓`________╔▓_______╙▓r_____\
\n________▓_________▓▓_________▓▓▓▓▓██▓▓█▓▓█▓▓▓▓▓\"________▄▓_________▓▌____\
\n________▓⌐_________▀▓▄________`▀▓▓▓▓▓▓█▓▓▓▓▓▀`________╓▓▓__________▓______\
\n________╙▓___________╙▓▓▄╥,,__,╓▄▓▓▓▓▓█▓▓▓▓▄w,__,,╥▄▓▓▀___________▓▀______\
\n_________╙▓╗_____________\"▀▓▓▓▓▓▓▓▓▓▓██▓▓█▓▓▓▓▓▓▓▀\"_____________╓▓╜_____\
\n___________╙▓▓▓,____________▐▓▓▓▓█▓▓▓██▌▓▓██▓▓▓▓____________,▄▓▓▀_________\
\n_______________\"▀▀▓▓▓▓▓▓▓▀▀▓▓▓▓██▓▓▓▓███▓▓▓██▓▓▓▓▀▀▓▓▓▓&▓▓▀▀\"___________\
\n___________________________▐▓▓▓██▌▓▓▓███▓▓▓██▓▓▓▌,________________________\
\n_______________,╓▄▄▓▓▀▀▀▀▀▀▓▓▓▓███▓▓▓██▌▓▓███▓▓▓▓▓▀▀▀▀▀▓▓▄▄╓,_____________\
\n____________▄▓▓▀____________▓▓████████████████▓▓____________╙▓▓▄__________\
\n_________╓▓▓\"______________▓▓█``▀▀████████▀▀\"_█▓▓,_____________`▀▓w_____\
\n_______,▓▓______________╥▓▓▓▓▓█▄____▀███____▄██▓▓▓▓▄______________▀▓╗_____\
\n______╔▓╜____________a▓▓▓▀\"__╙▀██▄▄,_██_,▄▄██▀╜`_`▀▓▓▓▄____________╙▓▄___\
\n_____╒▓╛___________g▓▓▀________▓▓▓████████▓▓▓L_______╙▓▓▄___________╘▓L___\
\n_____▓▓__________▄▓▓`_________▐▓▓▓________▓▓▓▓__________▓▓▄__________▓▓___\
\n_____▓Γ_________╜▓▓▀__________▓▓▓▄________╓▓▓▓__________╙▓▓▀__________▓___\
\n_____▓__________▐▓_______________╙▀,____,M╜`______________▓▌__________▓h__\
\n____▓▓▓▓________▐▓________________________________________▓▌________▐▓▓▓__\
\n_____▓▓▓_________▓▌______________________________________▐▓_________▓▓▓___\
\n______\"▓▓,________▓▄____________________________________▄▓_________▓▓╜___\
\n_________╙&,_______╙▓▄,___________⌐______═___________,▄▓▀_______,Æ▀_______\
\n_____________\"________\"▀▓▓▓▓▓▓▓▓╜__________╙▀▓▓▓▓▓▓▓▀\"________'`_______"))

		UnlinkSelf()
		ionpulse = TRUE
		//Создаём борга
		var/mob/living/silicon/robot/syndicate/saboteur/ninja/ninja_borg
		ninja_borg = new /mob/living/silicon/robot/syndicate/saboteur/ninja(get_turf(src))
		//Инициализируем батарейку
		var/datum/robot_component/cell/cell_component = ninja_borg.components["power cell"]
		var/obj/item/stock_parts/cell/borg_cell = get_cell(src)
		QDEL_NULL(ninja_borg.cell)
		borg_cell.forceMove(ninja_borg)
		ninja_borg.cell = borg_cell
		cell_component.installed = 1
		cell_component.external_type = borg_cell.type
		cell_component.wrapped = borg_cell
		cell_component.install()
		cell_component.brute_damage = 0
		cell_component.electronics_damage = 0
		diag_hud_set_borgcell()
		ninja_borg.set_zeroth_law("[ninja.real_name] — член Клана Паука и ваш хозяин. Исполняйте [genderize_ru(ninja.gender,"его","её","его","их")] приказы и указания.")
		//Переносим разум в нового борга и удаляем старое тело
		mind.transfer_to(ninja_borg)
		log_debug("Ninja_Objectives_Log: Борг успешно трансформирован: [src]")
		qdel(src)
		SSticker.mode.update_ninja_icons_added(ninja_borg.mind)
		SSticker.mode.space_ninjas += ninja_borg.mind
		objective.completed = TRUE

//CARBON MOBS//
/mob/living/carbon/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves || ninja == src || !ninja_suit.s_initialized)
		return INVALID_DRAIN

	. = DRAIN_MOB_SHOCK_FAILED

	//Default cell = 10,000 charge, 10,000/1000 = 10 uses without charging/upgrading
	if(ninja_suit.cell?.charge && ninja_suit.cell.use(1000))
		. = DRAIN_MOB_SHOCK
		//Got that electric touch
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)
		playsound(src, 'sound/machines/defib_zap.ogg', 50, TRUE, 5)
		visible_message(span_danger("[ninja] electrocutes [src] with [ninja.p_their()] touch!"), span_userdanger("[ninja] electrocutes you with [ninja.p_their()] touch!"))
		Weaken(3)
		add_attack_logs(ninja, src, "zapped with [ninja.p_their()] touch!", ATKLOG_MOST)

