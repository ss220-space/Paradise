/obj/item/mod/control/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MODsuit")
		ui.open()

/obj/item/mod/control/ui_data(mob/user)
	var/data = list()
	// Suit information
	var/suit_status = list(
		"core_name" = core?.declent_ru(NOMINATIVE),
		"charge_current" = get_charge(),
		"charge_max" = get_max_charge(),
		"chargebar_color" = get_chargebar_color(),
		"chargebar_string" = get_chargebar_string(),
		"active" = active,
		// Wires
		"open" = open,
		"seconds_electrified" = seconds_electrified,
		"malfunctioning" = malfunctioning,
		"locked" = locked,
		"interface_break" = interface_break,
		// Modules
		"complexity" = complexity,
	)
	data["suit_status"] = suit_status
	// User information
	var/user_status = list(
		"user_name" = wearer ? (wearer.get_authentification_name(UNKNOWN_NAME_RUS) || UNKNOWN_NAME_RUS) : "",
		"user_assignment" = wearer ? wearer.get_assignment(UNKNOWN_STATUS_RUS, NOJOB_STATUS_RUS, FALSE) : "",
	)
	data["user_status"] = user_status
	// Module information
	var/module_custom_status = list()
	var/module_info = list()
	for(var/obj/item/mod/module/module as anything in modules)
		module_custom_status += module.add_ui_data()
		module_info += list(list(
			"module_name" = DECLENT_RU_CAP(module, NOMINATIVE),
			"description" = module.desc,
			"module_type" = module.module_type,
			"module_active" = module.active,
			"pinned" = module.pinned_to[user.UID()],
			"idle_power" = module.idle_power_cost,
			"active_power" = module.active_power_cost,
			"use_energy" = module.use_energy_cost,
			"module_complexity" = module.complexity,
			"cooldown_time" = module.cooldown_time,
			"cooldown" = round(COOLDOWN_TIMELEFT(module, cooldown_timer), 1 SECONDS),
			"id" = module.tgui_id,
			"ref" = module.UID(),
			"configuration_data" = module.get_configuration(user),
		))
	data["module_custom_status"] = module_custom_status
	data["control"] = DECLENT_RU_CAP(src, NOMINATIVE)
	data["module_info"] = module_info
	var/part_info = list()
	for(var/obj/item/part as anything in get_parts())
		part_info += list(list(
			"slot" = english_list(parse_slot_flags(part.slot_flags)),
			"name" = DECLENT_RU_CAP(part, NOMINATIVE),
			"deployed" = part.loc != src,
			"ref" = part.UID(),
		))
	data["parts"] = part_info
	return data

/obj/item/mod/control/ui_static_data(mob/user)
	var/data = list()
	data["ui_theme"] = ui_theme
	data["complexity_max"] = complexity_max
	return data

/obj/item/mod/control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(malfunctioning && prob(MOD_MALFUNCTION_PROB))
		balloon_alert(ui.user, "сбой управления!")
		return
	switch(action)
		if("lock")
			if(!locked || allowed(ui.user))
				locked = !locked
				balloon_alert(ui.user, "[locked ? "заблокирован" : "разблокирован"]")
			else
				balloon_alert(ui.user, "отказано в доступе!")
				playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		if("activate")
			toggle_activate(ui.user)
		if("select")
			var/obj/item/mod/module/module = locateUID(params["ref"])
			if(!module)
				return
			module.on_select(ui.user) // We can now
		if("configure")
			var/obj/item/mod/module/module = locateUID(params["ref"])
			if(!module)
				return
			module.configure_edit(params["key"], params["value"])
		if("pin")
			var/obj/item/mod/module/module = locateUID(params["ref"])
			if(!module)
				return
			module.pin(ui.user)
		if("deploy")
			var/obj/item/mod_part = locateUID(params["ref"])
			if(!mod_part)
				return
			if(mod_part.loc == src)
				deploy(ui.user, mod_part)
			else
				retract(ui.user, mod_part)

	return TRUE
