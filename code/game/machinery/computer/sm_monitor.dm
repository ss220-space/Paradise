/obj/machinery/computer/sm_monitor
	name = "консоль мониторинга суперматерии"
	desc = "Используется для мониторинга состояния осколка суперматерии."
	icon_keyboard = "power_key"
	icon_screen = "smmon_0"
	circuit = /obj/item/circuitboard/sm_monitor
	light_color = LIGHT_COLOR_DIM_YELLOW
	/// Cache-list of all supermatter shards
	var/list/supermatters
	/// Last status of the active supermatter for caching purposes
	var/last_status
	/// Reference to the active shard
	var/obj/machinery/atmospherics/supermatter_crystal/active

/obj/machinery/computer/sm_monitor/get_ru_names()
	return list(
		NOMINATIVE = "консоль мониторинга суперматерии",
		GENITIVE = "консоли мониторинга суперматерии",
		DATIVE = "консоли мониторинга суперматерии",
		ACCUSATIVE = "консоль мониторинга суперматерии",
		INSTRUMENTAL = "консолью мониторинга суперматерии",
		PREPOSITIONAL = "консоли мониторинга суперматерии"
	)

/obj/machinery/computer/sm_monitor/Destroy()
	active = null
	return ..()

/obj/machinery/computer/sm_monitor/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/sm_monitor/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/sm_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SupermatterMonitor", declent_ru(NOMINATIVE))
		ui.open()

/obj/machinery/computer/sm_monitor/ui_data(mob/user)
	var/list/data = list()

	if(istype(active))
		var/turf/supermatter_turf = get_turf(active)
		// If we somehow delam during this proc, handle it somewhat
		if(!supermatter_turf)
			active = null
			refresh()
			return

		var/datum/gas_mixture/air = supermatter_turf.get_readonly_air()
		if(!air)
			active = null
			return

		data["active"] = TRUE
		data["SM_integrity"] = active.get_integrity_percent()
		data["SM_power"] = active.power
		data["SM_pre_reduction_power"] = active.pre_reduction_power
		data["SM_ambienttemp"] = air.temperature()
		data["SM_ambientpressure"] = air.return_pressure()
		data["SM_moles"] = air.total_moles()
		data["SM_gas_coefficient"] = active.gas_coefficient
		var/list/gas_data = list()
		var/total_moles = air.total_moles()
		if(total_moles)
			gas_data.Add(list(list("name"= "Oxygen", "amount" = air.oxygen(), "portion" = round(100 * air.oxygen() / total_moles, 0.01))))
			gas_data.Add(list(list("name"= "Carbon Dioxide", "amount" = air.carbon_dioxide(), "portion" = round(100 * air.carbon_dioxide() / total_moles, 0.01))))
			gas_data.Add(list(list("name"= "Nitrogen", "amount" = air.nitrogen(), "portion" = round(100 * air.nitrogen() / total_moles, 0.01))))
			gas_data.Add(list(list("name"= "Plasma", "amount" = air.toxins(), "portion" = round(100 * air.toxins() / total_moles, 0.01))))
			gas_data.Add(list(list("name"= "Nitrous Oxide", "amount" = air.sleeping_agent(), "portion" = round(100 * air.sleeping_agent() / total_moles, 0.01))))
			gas_data.Add(list(list("name"= "Agent B", "amount" = air.agent_b(), "portion" = round(100 * air.agent_b() / total_moles, 0.01))))
			gas_data.Add(list(list("name"= "Hydrogen", "amount" = air.hydrogen(), "portion" = round(100 * air.hydrogen() / total_moles, 0.01))))
			gas_data.Add(list(list("name"= "Water Vapor", "amount" = air.water_vapor(), "portion" = round(100 * air.water_vapor() / total_moles, 0.01))))
		else
			gas_data.Add(list(list("name"= "Oxygen", "amount" = 0, "portion" = 0)))
			gas_data.Add(list(list("name"= "Carbon Dioxide", "amount" = 0,"portion" = 0)))
			gas_data.Add(list(list("name"= "Nitrogen", "amount" = 0,"portion" = 0)))
			gas_data.Add(list(list("name"= "Plasma", "amount" = 0,"portion" = 0)))
			gas_data.Add(list(list("name"= "Nitrous Oxide", "amount" = 0,"portion" = 0)))
			gas_data.Add(list(list("name"= "Agent B", "amount" = 0,"portion" = 0)))
			gas_data.Add(list(list("name"= "Hydrogen", "amount" = 0,"portion" = 0)))
			gas_data.Add(list(list("name"= "Water Vapor", "amount" = 0,"portion" = 0)))
		data["gases"] = gas_data
	else
		var/list/supermatters_list = list()
		for(var/obj/machinery/atmospherics/supermatter_crystal/supermatter in supermatters)
			var/area/supermatter_area = get_area(supermatter)
			if(!supermatter_area)
				continue

			supermatters_list.Add(list(list(
				"area_name" = supermatter_area.name,
				"integrity" = supermatter.get_integrity_percent(),
				"supermatter_id" = supermatter.supermatter_id
			)))

		data["active"] = FALSE
		data["supermatters"] = supermatters_list

	return data

/**
 * Supermatter List Refresher
 *
 * This proc loops through the list of supermatters in the atmos SS and adds them to this console's cache list
 */
/obj/machinery/computer/sm_monitor/proc/refresh()
	supermatters = list()
	var/turf/user_turf = get_turf(ui_host()) // Get the UI host incase this ever turned into a supermatter monitoring module for AIs to use or something
	if(!user_turf)
		return

	for(var/obj/machinery/atmospherics/supermatter_crystal/supermatter in SSair.atmos_machinery)
		// Delaminating, not within coverage, not on a tile.
		if(!are_zs_connected(supermatter, user_turf) || !issimulatedturf(supermatter.loc))
			continue

		supermatters.Add(supermatter)

	if(!(active in supermatters))
		active = null

/obj/machinery/computer/sm_monitor/process()
	if(stat & (NOPOWER|BROKEN))
		return FALSE

	if(active)
		var/new_status = active.get_status()
		if(last_status != new_status)
			last_status = new_status
			if(last_status == SUPERMATTER_ERROR)
				last_status = SUPERMATTER_INACTIVE
			icon_screen = "smmon_[last_status]"
			update_icon()

	return TRUE

/obj/machinery/computer/sm_monitor/ui_act(action, params)
	if(..())
		return

	if(stat & (BROKEN|NOPOWER))
		return

	. = TRUE

	switch(action)
		if("refresh")
			refresh()

		if("view")
			var/new_uid = text2num(params["view"])
			for(var/obj/machinery/atmospherics/supermatter_crystal/supermatter in supermatters)
				if(supermatter.supermatter_id == new_uid)
					active = supermatter
					break

		if("back")
			active = null
