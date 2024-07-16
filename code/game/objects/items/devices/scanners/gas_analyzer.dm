#define ANALYZER_MODE_SURROUNDINGS 0
#define ANALYZER_MODE_TARGET 1
#define ANALYZER_HISTORY_SIZE 30
#define ANALYZER_HISTORY_MODE_KPA "kpa"
#define ANALYZER_HISTORY_MODE_MOL "mol"

/obj/item/analyzer
	name = "analyzer"
	desc = "A hand-held environmental scanner which reports current gas levels."
	icon = 'icons/obj/device.dmi'
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=30, MAT_GLASS=20)
	origin_tech = "magnets=1;engineering=1"
	var/cooldown = FALSE
	var/cooldown_time = 250
	var/accuracy // 0 is the best accuracy.
	var/list/last_gasmix_data
	var/list/history_gasmix_data
	var/history_gasmix_index = 0
	var/history_view_mode = ANALYZER_HISTORY_MODE_KPA
	var/scan_range = 1
	var/auto_updating = TRUE
	var/target_mode = ANALYZER_MODE_SURROUNDINGS
	var/atom/scan_target

/obj/item/analyzer/examine(mob/user)
	. = ..()
	. += span_notice("To scan an environment, activate it or use it on your location.")
	. += span_notice("Alt-click [src] to activate the barometer function.")

/obj/item/analyzer/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!"))
	return BRUTELOSS

/obj/item/analyzer/AltClick(mob/living/user) //Barometer output for measuring when the next storm happens
	..()
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return

		if(cooldown)
			to_chat(user, "<span class='warning'>[src]'s barometer function is preparing itself.</span>")
			return

		var/turf/T = get_turf(user)
		if(!T)
			return

		playsound(src, 'sound/effects/pop.ogg', 100)
		var/area/user_area = T.loc
		var/datum/weather/ongoing_weather = null

		if(!user_area.outdoors)
			to_chat(user, "<span class='warning'>[src]'s barometer function won't work indoors!</span>")
			return

		for(var/V in SSweather.processing)
			var/datum/weather/W = V
			if(W.barometer_predictable && (T.z in W.impacted_z_levels) && W.area_type == user_area.type && !(W.stage == END_STAGE))
				ongoing_weather = W
				break

		if(ongoing_weather)
			if((ongoing_weather.stage == MAIN_STAGE) || (ongoing_weather.stage == WIND_DOWN_STAGE))
				to_chat(user, "<span class='warning'>[src]'s barometer function can't trace anything while the storm is [ongoing_weather.stage == MAIN_STAGE ? "already here!" : "winding down."]</span>")
				return

			to_chat(user, "<span class='notice'>The next [ongoing_weather] will hit in [butchertime(ongoing_weather.next_hit_time - world.time)].</span>")
			if(ongoing_weather.aesthetic)
				to_chat(user, "<span class='warning'>[src]'s barometer function says that the next storm will breeze on by.</span>")
		else
			var/next_hit = SSweather.next_hit_by_zlevel["[T.z]"]
			var/fixed = next_hit ? next_hit - world.time : -1
			if(fixed < 0)
				to_chat(user, "<span class='warning'>[src]'s barometer function was unable to trace any weather patterns.</span>")
			else
				to_chat(user, "<span class='warning'>[src]'s barometer function says a storm will land in approximately [butchertime(fixed)].</span>")
		cooldown = TRUE
		addtimer(CALLBACK(src, PROC_REF(ping)), cooldown_time)

/obj/item/analyzer/proc/ping()
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, "<span class='notice'>[src]'s barometer function is ready!</span>")
	playsound(src, 'sound/machines/click.ogg', 100)
	cooldown = FALSE

/// Applies the barometer inaccuracy to the gas reading.
/obj/item/analyzer/proc/butchertime(amount)
	if(!amount)
		return
	if(accuracy)
		var/inaccurate = round(accuracy * (1 / 3))
		if(prob(50))
			amount -= inaccurate
		if(prob(50))
			amount += inaccurate
	return DisplayTimeText(max(1, amount))

/obj/item/analyzer/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "GasAnalyzer",  name, 500, 500, master_ui, state)
		ui.open()

/obj/item/analyzer/ui_data(mob/user)
	var/list/data = list()
	if(auto_updating)
		on_analyze(source=src, target=scan_target)
	LAZYINITLIST(last_gasmix_data)
	LAZYINITLIST(history_gasmix_data)
	data["gasmixes"] = last_gasmix_data
	data["autoUpdating"] = auto_updating
	data["historyGasmixes"] = history_gasmix_data
	data["historyViewMode"] = history_view_mode
	data["historyIndex"] = history_gasmix_index
	return data

/obj/item/analyzer/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("autoscantoggle")
			auto_updating = !auto_updating
			return TRUE
		if("input")
			if(!length(history_gasmix_data))
				return TRUE
			var/target = text2num(params["target"])
			auto_updating = FALSE
			history_gasmix_index = target
			last_gasmix_data = history_gasmix_data[history_gasmix_index]
			return TRUE
		if("clearhistory")
			history_gasmix_data = list()
			return TRUE
		if("modekpa")
			history_view_mode = ANALYZER_HISTORY_MODE_KPA
			return TRUE
		if("modemol")
			history_view_mode = ANALYZER_HISTORY_MODE_MOL
			return TRUE

/// Called when our analyzer is used on something
/obj/item/analyzer/proc/on_analyze(datum/source, atom/target, save_data=TRUE)
	SIGNAL_HANDLER
	LAZYINITLIST(history_gasmix_data)
	switch(target_mode)
		if(ANALYZER_MODE_SURROUNDINGS)
			scan_target = get_turf(src)
		if(ANALYZER_MODE_TARGET)
			scan_target = target
			if(!can_see(src, target, scan_range))
				target_mode = ANALYZER_MODE_SURROUNDINGS
				scan_target = get_turf(src)
			if(!scan_target)
				target_mode = ANALYZER_MODE_SURROUNDINGS
				scan_target = get_turf(src)

	var/mixture = scan_target.return_analyzable_air()
	if(!mixture)
		return FALSE
	var/list/airs = islist(mixture) ? mixture : list(mixture)
	var/list/new_gasmix_data = list()
	for(var/datum/gas_mixture/air as anything in airs)
		var/mix_name = capitalize(lowertext(scan_target.name))
		if(scan_target == get_turf(src))
			mix_name = "Location Reading"
		if(airs.len != 1) //not a unary gas mixture
			mix_name += " - Node [airs.Find(air)]"
		new_gasmix_data += list(gas_mixture_parser(air, mix_name))
	last_gasmix_data = new_gasmix_data
	history_gasmix_index = 0
	if(save_data)
		if(length(history_gasmix_data) >= ANALYZER_HISTORY_SIZE)
			history_gasmix_data.Cut(ANALYZER_HISTORY_SIZE, length(history_gasmix_data) + 1)
		history_gasmix_data.Insert(1, list(new_gasmix_data))

/obj/item/analyzer/attack_self(mob/user)
	if(user.stat != CONSCIOUS)
		return
	target_mode = ANALYZER_MODE_SURROUNDINGS
	atmos_scan(user=user, target=get_turf(src), silent=FALSE, print=FALSE)
	on_analyze(source=user, target=get_turf(src), save_data=!auto_updating)
	ui_interact(user)
	add_fingerprint(user)

/obj/item/analyzer/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!can_see(user, target, scan_range))
		return
	if(target.return_analyzable_air())
		atmos_scan(user, target)
	else
		atmos_scan(user, get_turf(target))

/**
 * Outputs a message to the user describing the target's gasmixes.
 * Used in chat-based gas scans.
 */
/proc/atmos_scan(mob/user, atom/target, silent = FALSE, print = TRUE, milla_turf_details = FALSE)
	var/mixture
	var/list/milla = null
	if(milla_turf_details)
		milla = new/list(MILLA_TILE_SIZE)
		get_tile_atmos(target, milla)
		var/datum/gas_mixture/GM = new()
		GM.copy_from_milla(milla)
		mixture = GM
	else
		mixture = target.return_analyzable_air()
	if(!mixture)
		return FALSE

	var/list/message = list()
	if(!silent && isliving(user))
		user.visible_message(span_notice("[user] uses the analyzer on [bicon(target)] [target]."), span_notice("You use the analyzer on [bicon(icon)] [target]"))
	message += span_boldnotice("Results of analysis of [bicon(target)] [target].")

	if(!print)
		return TRUE

	var/list/airs = islist(mixture) ? mixture : list(mixture)
	for(var/datum/gas_mixture/air as anything in airs)
		var/mix_name = capitalize(lowertext(target.name))
		if(length(air) > 1) //not a unary gas mixture
			var/mix_number = airs.Find(air)
			message += span_boldnotice("Node [mix_number]")
			mix_name += " - Node [mix_number]"

		var/total_moles = air.total_moles()
		var/pressure = air.return_pressure()
		var/volume = air.return_volume() //could just do mixture.volume... but safety, I guess?
		var/heat_capacity = air.heat_capacity()
		var/thermal_energy = air.thermal_energy()

		if(total_moles)
			message += "<span class='info'>Total: [round(total_moles, 0.01)] moles</span>"
			if(air.oxygen() && (milla_turf_details || air.oxygen() / total_moles > 0.01))
				message += "  <span class='oxygen'>Oxygen: [round(air.oxygen(), 0.01)] moles ([round(air.oxygen() / total_moles * 100, 0.01)] %)</span>"
			if(air.nitrogen() && (milla_turf_details || air.nitrogen() / total_moles > 0.01))
				message += "  <span class='nitrogen'>Nitrogen: [round(air.nitrogen(), 0.01)] moles ([round(air.nitrogen() / total_moles * 100, 0.01)] %)</span>"
			if(air.carbon_dioxide() && (milla_turf_details || air.carbon_dioxide() / total_moles > 0.01))
				message += "  <span class='carbon_dioxide'>Carbon Dioxide: [round(air.carbon_dioxide(), 0.01)] moles ([round(air.carbon_dioxide() / total_moles * 100, 0.01)] %)</span>"
			if(air.toxins() && (milla_turf_details || air.toxins() / total_moles > 0.01))
				message += "  <span class='plasma'>Plasma: [round(air.toxins(), 0.01)] moles ([round(air.toxins() / total_moles * 100, 0.01)] %)</span>"
			if(air.sleeping_agent() && (milla_turf_details || air.sleeping_agent() / total_moles > 0.01))
				message += "  <span class='sleeping_agent'>Nitrous Oxide: [round(air.sleeping_agent(), 0.01)] moles ([round(air.sleeping_agent() / total_moles * 100, 0.01)] %)</span>"
			if(air.agent_b() && (milla_turf_details || air.agent_b() / total_moles > 0.01))
				message += "  <span class='agent_b'>Agent B: [round(air.agent_b(), 0.01)] moles ([round(air.agent_b() / total_moles * 100, 0.01)] %)</span>"
			message += "<span class='info'>Temperature: [round(air.temperature()-T0C)] &deg;C ([round(air.temperature())] K)</span>"
			message += "<span class='info'>Volume: [round(volume)] Liters</span>"
			message += "<span class='info'>Pressure: [round(pressure, 0.1)] kPa</span>"
			message += "<span class='info'>Heat Capacity: [DisplayJoules(heat_capacity)] / K</span>"
			message += "<span class='info'>Thermal Energy: [DisplayJoules(thermal_energy)]</span>"
		else
			message += length(airs) > 1 ? "<span class='info'>This node is empty!</span>" : "<span class='info'>[target] is empty!</span>"
			message += "<span class='info'>Volume: [round(volume)] Liters</span>" // don't want to change the order volume appears in, suck it

		if(milla)
			// Values from milla/src/lib.rs, +1 due to array indexing difference.
			message += "<span class='info'>Airtight North: [(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_NORTH) ? "yes" : "no"]</span>"
			message += "<span class='info'>Airtight East: [(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_EAST) ? "yes" : "no"]</span>"
			message += "<span class='info'>Airtight South: [(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_SOUTH) ? "yes" : "no"]</span>"
			message += "<span class='info'>Airtight West: [(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_WEST) ? "yes" : "no"]</span>"
			switch(milla[MILLA_INDEX_ATMOS_MODE])
				// These are enum values, so they don't get increased.
				if(0)
					message += "<span class='info'>Atmos Mode: Space</span>"
				if(1)
					message += "<span class='info'>Atmos Mode: Sealed</span>"
				if(2)
					message += "<span class='info'>Atmos Mode: Exposed to Environment (ID: [milla[MILLA_INDEX_ENVIRONMENT_ID]])</span>"
				else
					message += "<span class='info'>Atmos Mode: Unknown ([milla[MILLA_INDEX_ATMOS_MODE]]), contact a coder.</span>"
			message += "<span class='info'>Superconductivity North: [milla[MILLA_INDEX_SUPERCONDUCTIVITY_NORTH]]</span>"
			message += "<span class='info'>Superconductivity East: [milla[MILLA_INDEX_SUPERCONDUCTIVITY_EAST]]</span>"
			message += "<span class='info'>Superconductivity South: [milla[MILLA_INDEX_SUPERCONDUCTIVITY_SOUTH]]</span>"
			message += "<span class='info'>Superconductivity West: [milla[MILLA_INDEX_SUPERCONDUCTIVITY_WEST]]</span>"
			message += "<span class='info'>Turf's Innate Heat Capacity: [milla[MILLA_INDEX_INNATE_HEAT_CAPACITY]]</span>"

	to_chat(user, chat_box_examine(message.Join("\n")))
	return TRUE

#undef ANALYZER_MODE_SURROUNDINGS
#undef ANALYZER_MODE_TARGET
#undef ANALYZER_HISTORY_SIZE
#undef ANALYZER_HISTORY_MODE_KPA
#undef ANALYZER_HISTORY_MODE_MOL
