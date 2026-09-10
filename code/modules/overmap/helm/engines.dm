/obj/machinery/computer/engines
	name = "engines control console"
	desc = "Удалённое управление двигателями космического аппарата."
	icon_keyboard = "tech_key"
	icon_screen = "power"
	light_color = LIGHT_COLOR_ORANGE
	circuit = /obj/item/circuitboard/engines
	var/obj/overmap/entity/vessel

/obj/machinery/computer/engines/get_ru_names()
	return alist(
		NOMINATIVE = "консоль управления двигателями",
		GENITIVE = "консоли управления двигателями",
		DATIVE = "консоли управления двигателями",
		ACCUSATIVE = "консоль управления двигателями",
		INSTRUMENTAL = "консолью управления двигателями",
		PREPOSITIONAL = "консоли управления двигателями",
	)

/obj/machinery/computer/engines/Initialize(mapload)
	. = ..()
	GLOB.engine_consoles += src
	if(SSovermap?.initialized)
		link_vessel()

/obj/machinery/computer/engines/Destroy()
	GLOB.engine_consoles -= src
	if(vessel)
		vessel.engine_consoles -= src
	vessel = null
	return ..()

/obj/machinery/computer/engines/proc/link_vessel()
	var/obj/overmap/entity/resolved = SSovermap?.resolve_vessel(src)
	if(!resolved)
		return
	if(vessel && vessel != resolved)
		vessel.engine_consoles -= src
	vessel = resolved
	resolved.engine_consoles |= src

/obj/machinery/computer/engines/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	if(..())
		return TRUE
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/engines/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/engines/ui_interact(mob/user, datum/tgui/ui = null)
	link_vessel()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapEngines", name)
		ui.open()

/obj/machinery/computer/engines/ui_data(mob/user)
	var/list/data = list()
	data["linked"] = !!vessel
	if(!vessel)
		return data
	data["vessel_name"] = vessel.name
	data["global_on"] = !!vessel.flight?.engines_state
	data["global_limit"] = round((vessel.flight?.thrust_limit || 0) * 100)
	data["total_thrust"] = vessel.get_total_thrust()
	data["mass"] = vessel.vessel_mass
	data["accel"] = round(OVERMAP_DISPLAY_SPEED(vessel.get_acceleration()), 0.01)
	var/list/engines = list()
	for(var/obj/machinery/ship_engine/engine as anything in vessel.engines)
		engines += list(list(
			"name" = engine.name,
			"ref" = engine.UID(),
			"on" = engine.on,
			"thrust" = engine.get_thrust(),
			"limit" = round(engine.thrust_limit * 100),
			"status" = engine.get_status(),
		))
	data["engines"] = engines
	return data

/obj/machinery/computer/engines/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!vessel)
		link_vessel()
		if(!vessel)
			return TRUE
	switch(action)
		if("global_toggle")
			if(vessel.flight)
				vessel.flight.engines_state = !vessel.flight.engines_state
			for(var/obj/machinery/ship_engine/engine as anything in vessel.engines)
				if(vessel.flight && vessel.flight.engines_state != engine.on)
					engine.toggle()
			. = TRUE
		if("set_global_limit")
			if(vessel.flight)
				vessel.flight.thrust_limit = clamp(text2num(params["value"]) / 100, 0, 1)
				for(var/obj/machinery/ship_engine/engine as anything in vessel.engines)
					engine.thrust_limit = vessel.flight.thrust_limit
			. = TRUE
		if("toggle_engine")
			var/obj/machinery/ship_engine/engine = locateUID(params["ref"])
			if(engine && (engine in vessel.engines))
				engine.toggle()
			. = TRUE
		if("set_engine_limit")
			var/obj/machinery/ship_engine/engine = locateUID(params["ref"])
			if(engine && (engine in vessel.engines))
				engine.thrust_limit = clamp(text2num(params["value"]) / 100, 0, 1)
			. = TRUE
		if("relink")
			link_vessel()
			. = TRUE

/obj/machinery/computer/engines/process()
	if(..())
		SStgui.update_uis(src)
