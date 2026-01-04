#define APC_BREAK_PROBABILITY 25 // the probability that a given APC will be disabled

/datum/event/apc_short
	var/const/announce_after_mc_ticks = 5
	var/const/event_max_duration_mc_ticks = announce_after_mc_ticks * 2
	var/const/event_min_duration_mc_ticks = announce_after_mc_ticks

	announceWhen = announce_after_mc_ticks

/datum/event/apc_short/setup()
	endWhen = rand(event_min_duration_mc_ticks, event_max_duration_mc_ticks)

/datum/event/apc_short/start()
	power_failure(announce = FALSE)
	var/sound/sound = sound('sound/effects/powerloss.ogg')
	for(var/mob/living/target in GLOB.player_list)
		var/turf/turf = get_turf(target)
		if(!target.client || !is_station_level(turf.z))
			continue
		SEND_SOUND(target, sound)

/datum/event/apc_short/announce()
	GLOB.minor_announcement.announce(
		message = "Зафиксирована перегрузка энергосети станции [station_name()]. Инженерному отделу надлежит проверить все замкнувшие ЛКП.",
		new_title = ANNOUNCE_APC_FAILURE_RU,
		new_sound = 'sound/AI/power_short.ogg'
	)

/datum/event/apc_short/end()
	return TRUE

/**
 * Depowers all APCs on the station by draining their cells
 *
 * Sends a station announcement and sets the charge of all APC cells to 0, except for critical areas.
 */
/proc/depower_apcs()
	var/static/list/skipped_areas_apc = typecacheof(list(
		/area/engineering/engine,
		/area/engineering/supermatter,
		/area/turret_protected/ai,
	))
	GLOB.minor_announcement.announce(
		message = "Зафиксирована перегрузка энергосети станции [station_name()]. Вероятно, отказали гравитационные системы.",
		new_title = ANNOUNCE_APC_FAILURE_RU,
		new_sound = 'sound/AI/attention.ogg'
	)
	for(var/thing in GLOB.apcs)
		var/obj/machinery/power/apc/apc = thing
		var/area/current_area = get_area(apc)
		if((current_area.type in skipped_areas_apc) || !is_station_level(apc.z))
			continue
		var/obj/item/stock_parts/cell/cell = apc.get_cell()
		if(cell)
			cell.charge = 0
		current_area.power_change()
	log_and_message_admins("Power has been drained from all APCs.")

/**
 * Causes random APCs to short out with a given probability
 *
 * Sends a station announcement and randomly cuts main power wires in APCs,
 * toggling their breaker if they were operating. Skips critical areas.
 *
 * Arguments:
 * * announce - If TRUE, sends a station announcement
 * * probability - Chance for each APC to short out
 */
/proc/power_failure(announce = TRUE, probability = APC_BREAK_PROBABILITY)
	var/static/list/skipped_areas_apc = typecacheof(list(
		/area/engineering/engine,
		/area/engineering/supermatter,
		/area/turret_protected/ai,
	))

	if(announce)
		GLOB.minor_announcement.announce(
			message = "Зафиксирована перегрузка энергосети станции [station_name()]. Инженерному отделу надлежит проверить все замкнувшие ЛКП.",
			new_title = ANNOUNCE_APC_FAILURE_RU,
			new_sound = 'sound/AI/attention.ogg'
		)

	var/affected_apc_count = 0
	for(var/thing in GLOB.apcs)
		var/obj/machinery/power/apc/apc = thing
		var/area/current_area = get_area(apc)

		if((current_area.type in skipped_areas_apc) || !is_station_level(apc.z))
			continue

		if(!prob(probability))
			continue

		if(apc.wires)
			if(!apc.wires.is_cut(WIRE_MAIN_POWER1))
				apc.wires.cut(WIRE_MAIN_POWER1)
			if(!apc.wires.is_cut(WIRE_MAIN_POWER2))
				apc.wires.cut(WIRE_MAIN_POWER2)

		if(apc.operating)
			apc.toggle_breaker()

		current_area.power_change()
		affected_apc_count++

	log_and_message_admins("APC Short Out event has shorted out [affected_apc_count] APCs.")

/**
 * Can recharge APC cells, repair cut wires, or both. Sends station announcement if requested.
 *
 * Arguments:
 * * announce - If TRUE, sends a station announcement
 * * power_type - Type of restoration (POWER_RESTORE_ONLY, APC_REPAIR_ONLY, APC_REPAIR_AND_CHARGE)
 */
/proc/power_restore(announce = TRUE, power_type)
	switch(power_type)
		if(POWER_RESTORE_ONLY)
			if(announce)
				GLOB.minor_announcement.announce(
					message = "Все работающие ЛКП на станции [station_name()] были полностью заряжены.",
					new_title = ANNOUNCE_APC_REPAIR_RU,
					new_sound = 'sound/AI/power_restore.ogg'
				)

			var/affected_apc_count = 0
			for(var/thing in GLOB.apcs)
				var/obj/machinery/power/apc/apc = thing
				if(!is_station_level(apc.z))
					continue

				var/area/current_area = get_area(apc)
				if(!length(apc.wires.cut_wires) && apc.operating && !apc.shorted)
					apc.recharge_apc()
					affected_apc_count++
				current_area.power_change()

			log_and_message_admins("Power has been restored to [affected_apc_count] APCs.")

		if(APC_REPAIR_ONLY)
			if(announce)
				GLOB.minor_announcement.announce(
					message = "Все ЛКП на станции [station_name()] были восстановлены.",
					new_title = ANNOUNCE_APC_REPAIR_RU,
					new_sound = 'sound/AI/power_restore.ogg'
				)

			for(var/thing in GLOB.apcs)
				var/obj/machinery/power/apc/apc = thing
				if(!is_station_level(apc.z))
					continue

				var/area/current_area = get_area(apc)
				apc.repair_apc()
				current_area.power_change()

			log_and_message_admins("Power has been restored to all APCs.")

		if(APC_REPAIR_AND_CHARGE)
			if(announce)
				GLOB.minor_announcement.announce(
					message = "Все ЛКП на станции [station_name()] были полностью заряжены и восстановлены. Приносим извинения за доставленные неудобства.",
					new_title = ANNOUNCE_APC_REPAIR_RU,
					new_sound = 'sound/AI/power_restore.ogg'
				)

			for(var/thing in GLOB.apcs)
				var/obj/machinery/power/apc/apc = thing
				if(!is_station_level(apc.z))
					continue

				var/area/current_area = get_area(apc)
				apc.repair_apc()
				apc.recharge_apc()
				current_area.power_change()

			log_and_message_admins("Power has been restored to all APCs.")

/**
 * Quickly restores all SMES units to full capacity and maximum output
 *
 * Arguments:
 * * announce - If TRUE, sends a station announcement
 */
/proc/power_restore_quick(announce = TRUE)
	if(announce)
		GLOB.minor_announcement.announce(
			message = "Все СКАНы на станции [station_name()] были перезаряжены. Приносим извинения за доставленные неудобства.",
			new_title = ANNOUNCE_APC_REPAIR_RU,
			new_sound = 'sound/AI/power_restore.ogg'
		)
	// fix all of the SMESs
	for(var/obj/machinery/power/smes/smes in SSmachines.get_by_type(/obj/machinery/power/smes))
		if(!is_station_level(smes.z))
			continue
		smes.charge = smes.capacity
		smes.output_level = smes.output_level_max
		smes.output_attempt = 1
		smes.input_attempt = 1
		smes.update_icon()
		smes.power_change()

#undef APC_BREAK_PROBABILITY
