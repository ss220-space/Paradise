/obj/mecha/ui_close(mob/user)
	. = ..()
	ui_view.hide_from(user)

/obj/mecha/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mecha", name)
		ui.open()
		ui_view.display_to(user, ui.window)

/obj/mecha/ui_status(mob/user, datum/ui_state/state)
	if(occupant != user)
		return UI_CLOSE

	if(user.incapacitated())
		return UI_DISABLED

	return UI_INTERACTIVE

/obj/mecha/ui_static_data(mob/user)
	var/list/data = list()
	data["ui_theme"] = ui_theme
	//same thresholds as in air alarm
	data["cabin_pressure_warning_min"]  = WARNING_LOW_PRESSURE
	data["cabin_pressure_hazard_min"]  = HAZARD_LOW_PRESSURE
	data["cabin_pressure_warning_max"]  = WARNING_HIGH_PRESSURE
	data["cabin_pressure_hazard_max"]  = HAZARD_HIGH_PRESSURE
	data["cabin_temp_warning_min"]  = BODYTEMP_COLD_DAMAGE_LIMIT - T0C
	data["cabin_temp_warning_max"]  = BODYTEMP_HEAT_DAMAGE_LIMIT - T0C
	data["one_atmosphere"]  = ONE_ATMOSPHERE
	data["mineral_material_amount"] = MINERAL_MATERIAL_AMOUNT

	data["internal_damage_keys"] = list(
		"MECHA_INT_FIRE" = MECHA_INT_FIRE,
		"MECHA_INT_TEMP_CONTROL" = MECHA_INT_TEMP_CONTROL,
		"MECHA_INT_TANK_BREACH" = MECHA_INT_TANK_BREACH,
		"MECHA_INT_CONTROL_LOST" = MECHA_INT_CONTROL_LOST,
		"MECHA_INT_SHORT_CIRCUIT" = MECHA_INT_SHORT_CIRCUIT,
	)

	var/list/user_accesses = user.get_access()

	data["regions"] = length(user_accesses) ? get_accesslist_static_data(REGION_GENERAL, REGION_COMMAND, user_accesses) : null
	return data

/obj/mecha/ui_data(mob/user)
	var/list/data = list()
	var/isoperator = user == occupant //maintenance mode outside of mech
	data["isoperator"] = isoperator
	data["cell"] = cell?.name
	ui_view.appearance = appearance
	data["name"] = name
	data["integrity"] = obj_integrity
	data["integrity_max"] = max_integrity
	data["power_level"] = cell?.charge
	data["power_max"] = cell?.maxcharge
	data["lights"] = lights
	data["internal_damage"] = internal_damage

	data["radio_data"] = list(
		"microphone" = radio.broadcasting,
		"speaker" = radio.listening,
		"frequency" = radio.frequency,
		"minFrequency" = radio.freerange ? RADIO_LOW_FREQ : PUBLIC_LOW_FREQ,
		"maxFrequency" = radio.freerange ? RADIO_HIGH_FREQ : PUBLIC_HIGH_FREQ,
	)

	data["accesses"] = operation_req_access
	data["one_access"] = one_access
	data["id_lock_on"] = id_lock_on

	data["maint_access"] = maint_access
	data["maintance_progress"] = maintenance_progress
	data["use_internal_tank"] = use_internal_tank
	data["dna_lock"] = dna_lock
	data["cabin_temp"] =  round(cabin_air.temperature - T0C)
	data["cabin_pressure"] = round(cabin_air.return_pressure())
	data["mech_view"] = ui_view.assigned_map
	data["modules"] = get_module_ui_data()
	data["cargo"] = get_cargo_ui_data()
	data["selected_module_index"] = ui_selected_module_index
	data["ui_honked"] = ui_honked

	return data

/obj/mecha/proc/get_cargo_ui_data()
	var/list/data = list("capacity" = cargo_capacity)
	var/list/cargo_list = list()

	for(var/atom/thing as anything in cargo)
		var/obj/item/stack/stack = thing
		var/amount = istype(stack) ? stack.amount : 1
		cargo_list += list(list("name" = thing.declent_ru(NOMINATIVE), "amount" = amount, "ref" = thing.UID()))

	data["cargo_list"] = cargo_list

	return data

/obj/mecha/proc/get_module_ui_data()
	var/list/data = list()
	for(var/obj/item/mecha_parts/mecha_equipment/module in equipment)
		data += list(list(
			"icon" = module.icon,
			"icon_state" = module.icon_state,
			"name" = module.declent_ru(NOMINATIVE),
			"desc" = module.desc,
			"integrity" = (module.get_integrity()/module.max_integrity),
			"detachable" = !module.integrated,
			"can_be_toggled" = module.selectable == MODULE_SELECTABLE_TOGGLE,
			"can_be_triggered" = module.selectable == MODULE_SELECTABLE_FULL,
			"active" = module.active,
			"active_label" = module.active_label,
			"equip_cooldown" = module.equip_cooldown && DisplayTimeText(module.equip_cooldown),
			"energy_per_use" = module.energy_drain,
			"snowflake" = module.get_snowflake_data(),
			"ref" = module.UID(),
		))

	return data

/obj/mecha/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("clear_all")
			operation_req_access = list()
		if("grant_all")
			operation_req_access = ui.user.get_access()
		if("one_access")
			one_access = !one_access
		if("set")
			var/access = text2num(params["access"])
			if (!(access in operation_req_access))
				operation_req_access += access
			else
				operation_req_access -= access
		if("grant_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			operation_req_access |= (get_region_accesses(region) & ui.user.get_access())
		if("deny_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			operation_req_access -= (get_region_accesses(region) & ui.user.get_access())
		if("drop_from_cargo")
			var/atom/movable/cargo_thing = locateUID(params["cargo_item"])
			if(istype(cargo_thing) && (cargo_thing in cargo))
				occupant_message(span_notice("You unload [cargo_thing]."))
				cargo_thing.forceMove(loc)
				cargo -= cargo_thing
			return
		if("toggle_internal_tank")
			toggle_internal_tank()
			return
		if("toggle_lights")
			toggle_lights()
			return
		if("toggle_maint_access")
			maint_access = !maint_access
			return
		if("toggle_microphone")
			radio.broadcasting = !radio.broadcasting
			return TRUE
		if("toggle_speaker")
			radio.listening = !radio.listening
			return TRUE
		if("set_frequency")
			var/new_frequency = text2num(params["new_frequency"])
			radio.set_frequency(sanitize_frequency(new_frequency, radio.freerange ? RADIO_LOW_FREQ : PUBLIC_LOW_FREQ,  radio.freerange ? RADIO_HIGH_FREQ : PUBLIC_HIGH_FREQ))
			return TRUE
		if("select_module")
			ui_selected_module_index = text2num(params["index"])
			return TRUE
		if("changename")
			var/newname = strip_html_simple(tgui_input_text(occupant, "Choose new exosuit name", "Rename exosuit", initial(name)), MAX_NAME_LEN)
			if(newname && trim(newname))
				name = newname
				add_misc_logs(occupant, "has renamed an exosuit [newname]")
			else
				alert(occupant, "nope.avi")
			return
		if("dna_lock")
			var/mob/living/carbon/user = usr
			if(!istype(user) || !user.dna)
				to_chat(user, "[icon2html(src, occupant)][span_notice("You can't create a DNA lock with no DNA!.")]")
				return
			dna_lock = user.dna.unique_enzymes
			to_chat(user, "[icon2html(src, occupant)][span_notice("You feel a prick as the needle takes your DNA sample.")]")
		if("reset_dna")
			dna_lock = null
		if("equip_act")
			var/obj/item/mecha_parts/mecha_equipment/gear = locateUID(params["ref"])
			return gear?.ui_act(params["gear_action"], params, ui, state)
	return TRUE

/obj/mecha/proc/occupant_message(message as text)
	if(message)
		if(occupant && occupant.client)
			to_chat(occupant, "[bicon(src)] [message]")
	return
