#define ANALYZER_MODE_SURROUNDINGS 0
#define ANALYZER_MODE_TARGET 1
#define ANALYZER_HISTORY_SIZE 30
#define ANALYZER_HISTORY_MODE_KPA "kpa"
#define ANALYZER_HISTORY_MODE_MOL "mol"

/obj/item/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels."
	name = "analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throw_speed = 3
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	origin_tech = "magnets=1;engineering=1"
	tool_behaviour = TOOL_ANALYZER
	/// Boolean whether this has a CD
	var/cooldown = FALSE
	/// The time in deciseconds
	var/cooldown_time = 25 SECONDS
	/// 0 is best accuracy
	var/barometer_accuracy
	/// Cached gasmix data from ui_interact
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
	. += span_notice("Right-click [src] to open the gas reference.")
	. += span_notice("Alt-click [src] to activate the barometer function.")

/obj/item/analyzer/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!"))
	return BRUTELOSS

/obj/item/analyzer/click_alt(mob/living/user) //Barometer output for measuring when the next storm happens
	if(cooldown)
		to_chat(user, span_warning("[src]'s barometer function is prepraring itself."))
		return CLICK_ACTION_BLOCKING

	var/turf/T = get_turf(user)
	if(!T)
		return NONE

	playsound(src, 'sound/effects/pop.ogg', 100)
	var/area/user_area = T.loc
	var/datum/weather/ongoing_weather = null

	if(!user_area.outdoors)
		to_chat(user, span_warning("[src]'s barometer function won't work indoors!"))
		return CLICK_ACTION_BLOCKING

	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if(W.barometer_predictable && (T.z in W.impacted_z_levels) && W.area_type == user_area.type && !(W.stage == END_STAGE))
			ongoing_weather = W
			break

	if(ongoing_weather)
		if((ongoing_weather.stage == MAIN_STAGE) || (ongoing_weather.stage == WIND_DOWN_STAGE))
			to_chat(user, span_warning("[src]'s barometer function can't trace anything while the storm is [ongoing_weather.stage == MAIN_STAGE ? "already here!" : "winding down."]"))
			return CLICK_ACTION_BLOCKING

		to_chat(user, span_warning("The next [ongoing_weather] will hit in [butchertime(ongoing_weather.next_hit_time - world.time)]."))
		if(ongoing_weather.aesthetic)
			to_chat(user, span_warning("[src]'s barometer function says that the next storm will breeze on by."))

	else
		var/next_hit = SSweather.next_hit_by_zlevel["[T.z]"]
		var/fixed = next_hit ? next_hit - world.time : -1
		if(fixed < 0)
			to_chat(user, span_warning("[src]'s barometer function was unable to trace any weather patterns."))
		else
			to_chat(user, span_warning("[src]'s barometer function says a storm will land in approximately [butchertime(fixed)]."))

	cooldown = TRUE
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/analyzer, ping)), cooldown_time)
	return CLICK_ACTION_SUCCESS

/obj/item/analyzer/proc/ping()
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, span_notice("[src]'s barometer function is ready!"))
	playsound(src, 'sound/machines/click.ogg', 100)
	cooldown = FALSE

/// Applies the barometer inaccuracy to the gas reading.
/obj/item/analyzer/proc/butchertime(amount)
	if(!amount)
		return
	if(barometer_accuracy)
		var/inaccurate = round(barometer_accuracy * (1 / 3))
		if(prob(50))
			amount -= inaccurate
		if(prob(50))
			amount += inaccurate
	return DisplayTimeText(max(1, amount))

/obj/item/analyzer/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GasAnalyzer", name)
		ui.open()

/obj/item/analyzer/ui_data(mob/user)
	var/list/data = list()
	if(auto_updating)
		on_analyze(source = src, target = scan_target)
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
			if(!can_see(target, scan_range))
				target_mode = ANALYZER_MODE_SURROUNDINGS
				scan_target = get_turf(src)
			if(!scan_target)
				target_mode = ANALYZER_MODE_SURROUNDINGS
				scan_target = get_turf(src)

	var/mixture = scan_target?.return_analyzable_air()
	if(!mixture)
		return FALSE

	var/list/airs = islist(mixture) ? mixture : list(mixture)
	var/list/new_gasmix_data = list()
	for(var/datum/gas_mixture/air as anything in airs)
		var/mix_name = capitalize(lowertext(scan_target.name))
		if(scan_target == get_turf(src))
			mix_name = "Location Reading"

		if(length(airs) != 1) //not a unary gas mixture
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
	atmos_scan(user = user, target = get_turf(src), silent = FALSE, print = FALSE)
	on_analyze(source = user, target = get_turf(src), save_data = !auto_updating)
	ui_interact(user)
	add_fingerprint(user)

/obj/item/analyzer/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!user.can_see(target, scan_range))
		return

	target_mode = ANALYZER_MODE_TARGET
	if(target == user || target == user.loc)
		target_mode = ANALYZER_MODE_SURROUNDINGS

	atmos_scan(user = user, target = (target.return_analyzable_air() ? target : get_turf(src)), print = FALSE)
	on_analyze(source = user, target = (target.return_analyzable_air() ? target : get_turf(src)), save_data = !auto_updating)
	ui_interact(user)

/**
 * Outputs a message to the user describing the target's gasmixes.
 *
 * Gets called by analyzer_act, which in turn is called by tool_act.
 * Also used in other chat-based gas scans.
 */
/proc/atmos_scan(mob/user, atom/target, silent = FALSE, print = TRUE, milla_turf_details = FALSE)
	var/datum/gas_mixture/air
	var/list/milla = null
	if(milla_turf_details && istype(target, /turf))
		milla = new/list(MILLA_TILE_SIZE)
		get_tile_atmos(target, milla)
		air = new()
		air.copy_from_milla(milla)
	else
		air = target.return_analyzable_air()
		if(!air)
			return FALSE

	if(!air)
		return FALSE

	var/icon = target
	var/list/message = list()
	if(!silent && isliving(user))
		playsound(user, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
		user.visible_message(
			span_notice("[user] uses the analyzer on [icon2html(icon, viewers(icon))] [target]."),
			span_notice("You use the analyzer on [icon2html(icon, user)] [target]"),
		)
	message += span_boldnotice("Results of analysis of [icon2html(icon, user)] [target].")

	if(!print)
		return TRUE

	var/total_moles = air.total_moles()
	var/pressure = air.return_pressure()
	var/volume = air.return_volume() //could just do mixture.volume... but safety, I guess?
	var/heat_capacity = air.heat_capacity()
	var/thermal_energy = air.thermal_energy()

	if(total_moles)
		message += span_notice("Total: [round(total_moles, 0.01)] moles")
		if(air.oxygen() && (milla_turf_details || air.oxygen() / total_moles > 0.01))
			message += span_oxygen("  Oxygen: [round(air.oxygen(), 0.01)] moles ([round(air.oxygen() / total_moles * 100, 0.01)] %)")
		if(air.nitrogen() && (milla_turf_details || air.nitrogen() / total_moles > 0.01))
			message += span_nitrogen("  Nitrogen: [round(air.nitrogen(), 0.01)] moles ([round(air.nitrogen() / total_moles * 100, 0.01)] %)")
		if(air.carbon_dioxide() && (milla_turf_details || air.carbon_dioxide() / total_moles > 0.01))
			message += span_carbon_dioxide("  Carbon Dioxide: [round(air.carbon_dioxide(), 0.01)] moles ([round(air.carbon_dioxide() / total_moles * 100, 0.01)] %)")
		if(air.toxins() && (milla_turf_details || air.toxins() / total_moles > 0.01))
			message += span_plasma("  Plasma: [round(air.toxins(), 0.01)] moles ([round(air.toxins() / total_moles * 100, 0.01)] %)")
		if(air.sleeping_agent() && (milla_turf_details || air.sleeping_agent() / total_moles > 0.01))
			message += span_sleeping_agent("  Nitrous Oxide: [round(air.sleeping_agent(), 0.01)] moles ([round(air.sleeping_agent() / total_moles * 100, 0.01)] %)")
		if(air.agent_b() && (milla_turf_details || air.agent_b() / total_moles > 0.01))
			message += span_agent_b("  Agent B: [round(air.agent_b(), 0.01)] moles ([round(air.agent_b() / total_moles * 100, 0.01)] %)")
		if(air.hydrogen() && (milla_turf_details || air.hydrogen() / total_moles > 0.01))
			message += span_hydrogen("  Hydrogen: [round(air.hydrogen(), 0.01)] moles ([round(air.hydrogen() / total_moles * 100, 0.01)] %)")
		if(air.water_vapor() && (milla_turf_details || air.water_vapor() / total_moles > 0.01))
			message += span_water_vapor("  Water Vapor: [round(air.water_vapor(), 0.01)] moles ([round(air.water_vapor() / total_moles * 100, 0.01)] %)")

		message += span_notice("Temperature: [round(air.temperature()-T0C)] &deg;C ([round(air.temperature())] K)")
		message += span_notice("Volume: [round(volume)] Liters")
		message += span_notice("Pressure: [round(pressure, 0.1)] kPa")
		message += span_notice("Heat Capacity: [display_joules(heat_capacity)] / K")
		message += span_notice("Thermal Energy: [display_joules(thermal_energy)]")
	else
		message += span_notice("[target] is empty!")
		message += span_notice("Volume: [round(volume)] Liters") // don't want to change the order volume appears in, suck it

	if(milla)
		// Values from milla/src/lib.rs, +1 due to array indexing difference.
		message += span_notice("Airtight N/E/S/W: [(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_NORTH) ? "yes" : "no"]/[(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_EAST) ? "yes" : "no"]/[(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_SOUTH) ? "yes" : "no"]/[(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_WEST) ? "yes" : "no"]")
		switch(milla[MILLA_INDEX_ATMOS_MODE])
			// These are enum values, so they don't get increased.
			if(0)
				message += span_notice("Atmos Mode: Space")
			if(1)
				message += span_notice("Atmos Mode: Sealed")
			if(2)
				message += span_notice("Atmos Mode: Exposed to Environment (ID: [milla[MILLA_INDEX_ENVIRONMENT_ID]])")
			else
				message += span_notice("Atmos Mode: Unknown ([milla[MILLA_INDEX_ATMOS_MODE]]), contact a coder.")

		message += span_notice("Superconductivity N/E/S/W: [milla[MILLA_INDEX_SUPERCONDUCTIVITY_NORTH]]/[milla[MILLA_INDEX_SUPERCONDUCTIVITY_EAST]]/[milla[MILLA_INDEX_SUPERCONDUCTIVITY_SOUTH]]/[milla[MILLA_INDEX_SUPERCONDUCTIVITY_WEST]]")
		message += span_notice("Turf's Innate Heat Capacity: [milla[MILLA_INDEX_INNATE_HEAT_CAPACITY]]")
		message += span_notice("Hotspot: [floor(milla[MILLA_INDEX_HOTSPOT_TEMPERATURE]-T0C)] &deg;C ([floor(milla[MILLA_INDEX_HOTSPOT_TEMPERATURE])] K), [round(milla[MILLA_INDEX_HOTSPOT_VOLUME] * CELL_VOLUME, 1)] Liters ([milla[MILLA_INDEX_HOTSPOT_VOLUME]]x)")
		message += span_notice("Wind: ([round(milla[MILLA_INDEX_WIND_X], 0.001)], [round(milla[MILLA_INDEX_WIND_Y], 0.001)])")
		message += span_notice("Fuel burnt last tick: [milla[MILLA_INDEX_FUEL_BURNT]] moles")

	// we let the join apply newlines so we do need handholding
	to_chat(user, chat_box_examine((jointext(message, "\n"))), type = MESSAGE_TYPE_INFO)
	return TRUE

#undef ANALYZER_MODE_SURROUNDINGS
#undef ANALYZER_MODE_TARGET
#undef ANALYZER_HISTORY_SIZE
#undef ANALYZER_HISTORY_MODE_KPA
#undef ANALYZER_HISTORY_MODE_MOL
