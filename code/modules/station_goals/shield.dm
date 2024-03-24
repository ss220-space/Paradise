GLOBAL_LIST_INIT(meteor_shields, list())

// Щиты станции
// Цепь спутников, окружающих станцию
// Спутники активируются, создавая щит, который будет препятствовать прохождению неорганической материи.
/datum/station_goal/station_shield
	name = "Station Shield"
	VAR_PRIVATE/cached_coverage_length
	var/coverage_goal = 10000

/datum/station_goal/station_shield/get_report()
	return {"<b>Сооружение щитов станции</b><br>
	В области вокруг станции большое количество космического мусора. У нас есть прототип щитовой системы, которую вы должны установить для уменьшения числа происшествий, связанных со столкновениями.
	<br><br>
	Вы можете заказать доставку спутников и системы их управления через шаттл отдела снабжения."}

/datum/station_goal/station_shield/on_report()
	//Unlock
	var/datum/supply_packs/P = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/shield_sat]"]
	P.special_enabled = TRUE
	supply_list.Add(P)

	P = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/shield_sat_control]"]
	P.special_enabled = TRUE
	supply_list.Add(P)

/datum/station_goal/station_shield/check_completion()
	if(..())
		return TRUE
	update_coverage()
	if(cached_coverage_length >= coverage_goal)
		return TRUE
	return FALSE

/datum/station_goal/station_shield/proc/get_coverage()
	return cached_coverage_length

/datum/station_goal/station_shield/proc/update_coverage()
	var/list/coverage = list()
	for(var/obj/machinery/satellite/meteor_shield/shield_satt as anything in GLOB.meteor_shields)
		if(!shield_satt.active || !is_station_level(shield_satt.z))
			continue
		for(var/turf/covered in view(shield_satt.kill_range, shield_satt))
			coverage |= covered
	cached_coverage_length = length(coverage)

/obj/item/circuitboard/computer/sat_control
	board_name = "Контроллер сети спутников"
	build_path = /obj/machinery/computer/sat_control
	origin_tech = "engineering=3"

/obj/machinery/computer/sat_control
	name = "Управление спутниками"
	desc = "Используется для управления спутниковой сетью."
	circuit = /obj/item/circuitboard/computer/sat_control
	icon_screen = "accelerator"
	icon_keyboard = "accelerator_key"
	var/notice

/obj/machinery/computer/sat_control/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/computer/sat_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SatelliteControl", name, 475, 400)
		ui.open()

/obj/machinery/computer/sat_control/ui_data(mob/user)
	var/list/data = list()

	data["satellites"] = list()
	for(var/obj/machinery/satellite/S in GLOB.machines)
		data["satellites"] += list(list(
			"id" = S.id,
			"active" = S.active,
			"mode" = S.mode
		))
	data["notice"] = notice

	var/datum/station_goal/station_shield/G = locate() in SSticker.mode.station_goals
	if(G)
		data["meteor_shield"] = 1
		data["meteor_shield_coverage"] = G.get_coverage()
		data["meteor_shield_coverage_max"] = G.coverage_goal
		data["meteor_shield_coverage_percentage"] = (G.get_coverage() / G.coverage_goal) * 100
	return data

/obj/machinery/computer/sat_control/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("toggle")
			toggle(text2num(params["id"]))
			. = TRUE

/obj/machinery/computer/sat_control/proc/toggle(id)
	for(var/obj/machinery/satellite/S in GLOB.machines)
		if(S.id == id && atoms_share_level(src, S))
			if(!S.toggle())
				notice = "Вы можете активировать только находящиеся в космосе спутники"
			else
				notice = null


/obj/machinery/satellite
	name = "Недействующий спутник"
	desc = ""
	icon = 'icons/obj/machines/satellite.dmi'
	icon_state = "sat_inactive"
	density = TRUE
	use_power = FALSE
	var/mode = "NTPROBEV0.8"
	var/active = FALSE
	/// global counter of IDs
	var/static/global_id = 0
	/// id number for this satellite
	var/id = 0
	/// toggle cooldown
	COOLDOWN_DECLARE(toggle_sat_cooldown)

/obj/machinery/satellite/Initialize(mapload)
	. = ..()
	id = global_id++

/obj/machinery/satellite/attack_hand(mob/user)
	if(..())
		return TRUE
	interact(user)

/obj/machinery/satellite/interact(mob/user)
	toggle(user)

/obj/machinery/satellite/proc/toggle(mob/user)
	if(!COOLDOWN_FINISHED(src, toggle_sat_cooldown))
		return FALSE
	if(!active && !isinspace())
		if(user)
			to_chat(user, span_warning("Вы можете активировать только находящиеся в космосе спутники."))
		return FALSE
	if(user)
		to_chat(user, span_notice("Вы [active ? "деактивировали": "активировали"] [src]"))
	active = !active
	COOLDOWN_START(src, toggle_sat_cooldown, 1 SECONDS)
	if(active)
		anchored = TRUE
		if(pulledby)
			pulledby.stop_pulling()
		animate(src, pixel_y = 2, time = 10, loop = -1)
	else
		animate(src, pixel_y = 0, time = 10)
		anchored = FALSE
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/satellite/update_icon_state()
	icon_state = active ? "sat_active" : "sat_inactive"

/obj/machinery/satellite/multitool_act(mob/living/user, obj/item/I)
	..()
	add_fingerprint(user)
	to_chat(user, span_notice("// NTSAT-[id] // Режим : [active ? "ОСНОВНОЙ" : "ОЖИДАНИЕ"] //[emagged ? "ОТЛАДКА //" : ""]"))
	return TRUE

/obj/machinery/satellite/meteor_shield
	name = "Спутник метеорного щита"
	desc = "Узловой спутник метеорной защиты"
	mode = "M-SHIELD"
	speed_process = TRUE
	var/kill_range = 14

/obj/machinery/satellite/meteor_shield/examine(mob/user)
	. = ..()
	if(active)
		. += span_notice("It is currently active. You can interact with it to shut it down.")
		if(emagged)
			. += span_warning("Rather than the usual sounds of beeps and pings, it produces a weird and constant hiss of white noise…")
		else
			. += span_notice("It emits periodic beeps and pings as it communicates with the satellite network.")
	else
		. += span_notice("It is currently disabled. You can interact with it to set it up.")
		if(emagged)
			. += span_warning("But something seems off about it...?")

/obj/machinery/satellite/meteor_shield/proc/space_los(meteor)
	for(var/turf/T as anything in get_line(src, meteor))
		if(!isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/satellite/meteor_shield/process()
	if(!active)
		return
	for(var/obj/effect/meteor/meteor_to_destroy as anything in GLOB.meteor_list)
		if(meteor_to_destroy.z != z)
			continue
		if(get_dist(meteor_to_destroy, src) > kill_range)
			continue
		if(!emagged && space_los(meteor_to_destroy))
			Beam(get_turf(meteor_to_destroy), icon_state = "sat_beam", time = 5, maxdistance = kill_range)
			qdel(meteor_to_destroy)

/obj/machinery/satellite/meteor_shield/Process_Spacemove(movement_dir)
	return active

/obj/machinery/satellite/meteor_shield/toggle(user)
	. = ..()
	if(!.)
		return
	if(emagged)
		if(active)
			change_meteor_chance(2)
		else
			change_meteor_chance(0.5)

	var/datum/station_goal/station_shield/shield_goal = locate() in SSticker.mode.station_goals
	if(shield_goal)
		shield_goal.update_coverage()

/obj/machinery/satellite/meteor_shield/proc/change_meteor_chance(mod)
	for(var/datum/event_container/container in SSevents.event_containers)
		for(var/datum/event_meta/M in container.available_events)
			if(M.event_type == /datum/event/meteor_wave)
				M.weight_mod *= mod

/obj/machinery/satellite/meteor_shield/Initialize(mapload)
	. = ..()
	GLOB.meteor_shields += src

/obj/machinery/satellite/meteor_shield/Destroy()
	. = ..()
	if(active && emagged)
		change_meteor_chance(0.5)
	GLOB.meteor_shields -= src
	var/datum/station_goal/station_shield/shield_goal = locate() in SSticker.mode.station_goals
	if(shield_goal)
		shield_goal.update_coverage()

/obj/machinery/satellite/meteor_shield/emag_act(mob/user)
	if(emagged)
		return
	add_attack_logs(user, src, "emagged")
	if(user)
		to_chat(user, span_danger("Вы переписали схемы метеорного щита, заставив его привлекать метеоры, а не уничтожать их."))
	emagged = TRUE
	if(active)
		change_meteor_chance(2)
