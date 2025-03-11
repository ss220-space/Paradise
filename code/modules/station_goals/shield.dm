GLOBAL_LIST_INIT(meteor_shields, list())
GLOBAL_LIST_EMPTY_TYPED(meteor_shielded_turfs, /turf)

// Щиты станции
// Цепь спутников, окружающих станцию
// Спутники активируются, создавая щит, который будет препятствовать прохождению неорганической материи.
/datum/station_goal/station_shield
	name = "Station Shield"
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
	//Changes
	var/list/station_levels = levels_by_trait(STATION_LEVEL)
	coverage_goal = coverage_goal * station_levels.len

/datum/station_goal/station_shield/check_completion()
	if(..())
		return TRUE
	update_coverage()
	if(length(GLOB.meteor_shielded_turfs) >= coverage_goal)
		return TRUE
	return FALSE

/datum/station_goal/station_shield/proc/update_coverage()
	var/list/coverage = list()
	for(var/obj/machinery/satellite/meteor_shield/shield_satt as anything in GLOB.meteor_shields)
		if(!shield_satt.active || !is_station_level(shield_satt.z))
			continue
		for(var/obj/effect/abstract/meteor_shield_proxy/proxy in shield_satt.proxies)
			for(var/turf/covered in view(shield_satt.kill_range, proxy))
				coverage |= covered
		for(var/turf/covered in view(shield_satt.kill_range, shield_satt))
			coverage |= covered
	GLOB.meteor_shielded_turfs = coverage

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

/obj/machinery/computer/sat_control/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SatelliteControl", name)
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
		data["meteor_shield_coverage"] = length(GLOB.meteor_shielded_turfs)
		data["meteor_shield_coverage_max"] = G.coverage_goal
		data["meteor_shield_coverage_percentage"] = (length(GLOB.meteor_shielded_turfs) / G.coverage_goal) * 100
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
		if(S.id == id && are_zs_connected(src, S))
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
		set_anchored(TRUE)
		pulledby?.stop_pulling()
		animate(src, pixel_y = 2, time = 10, loop = -1)
	else
		animate(src, pixel_y = 0, time = 10)
		set_anchored(FALSE)
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
	/// A list of "proxy" objects used for multi-z coverage.
	var/list/obj/effect/abstract/meteor_shield_proxy/proxies = list()

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

/obj/machinery/satellite/meteor_shield/Initialize(mapload)
	. = ..()
	GLOB.meteor_shields += src
	AddComponent(/datum/component/proximity_monitor, kill_range)
	setup_proxies()

/obj/machinery/satellite/meteor_shield/Destroy()
	. = ..()
	if(active && emagged)
		change_meteor_chance(0.5)
	GLOB.meteor_shields -= src
	var/datum/station_goal/station_shield/shield_goal = locate() in SSticker.mode.station_goals
	if(shield_goal)
		shield_goal.update_coverage()

/obj/machinery/satellite/meteor_shield/HasProximity(atom/movable/AM)
	shoot_meteor(AM)

/obj/machinery/satellite/meteor_shield/proc/shoot_meteor(atom/movable/possible_danger)
	if(!active || emagged)
		return
	if(istype(possible_danger, /obj/effect/meteor))
		var/obj/effect/meteor/meteor_to_destroy = possible_danger
		if(meteor_to_destroy.z != z)
			return
		if(!space_los(meteor_to_destroy))
			return
		Beam(get_turf(meteor_to_destroy), icon_state = "sat_beam", time = 5, maxdistance = kill_range)
		if(meteor_to_destroy.shield_defense(src))
			new /obj/effect/temp_visual/explosion(meteor_to_destroy)
			// INVOKE_ASYNC(src, PROC_REF(play_zap_sound), meteor_turf)
			qdel(meteor_to_destroy)


/obj/machinery/satellite/meteor_shield/proc/space_los(meteor)
	for(var/turf/T as anything in get_line(src, meteor))
		if(!isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/satellite/meteor_shield/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	setup_proxies()

/obj/machinery/satellite/meteor_shield/proc/setup_proxies()
	for(var/stacked_z in SSmapping.get_connected_levels(get_turf(src)))
		setup_proxy_for_z(stacked_z)

/obj/machinery/satellite/meteor_shield/proc/setup_proxy_for_z(target_z)
	if(target_z == z)
		return
	// don't setup a proxy if there already is one.
	if(!QDELETED(proxies["[target_z]"]))
		return
	var/turf/our_loc = get_turf(src)
	var/turf/target_loc = locate(our_loc.x, our_loc.y, target_z)
	if(QDELETED(target_loc))
		return
	var/obj/effect/abstract/meteor_shield_proxy/new_proxy = new(target_loc, src)
	proxies["[target_z]"] = new_proxy

/obj/machinery/satellite/meteor_shield/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	if(active)
		return TRUE
	return ..()

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

/obj/machinery/satellite/meteor_shield/proc/change_meteor_chance(mod = 1)
	var/static/list/meteor_event_typecache
	if(!meteor_event_typecache)
		meteor_event_typecache = typecacheof(list(
			/datum/event/meteor_wave,
			/datum/event/dust/meaty,
			/datum/event/dust,
		))
	for(var/datum/event_container/container in SSevents.event_containers)
		for(var/datum/event_meta/M in container.available_events)
			if(is_type_in_typecache(M.event_type, meteor_event_typecache))
				M.weight_mod *= mod

/obj/machinery/satellite/meteor_shield/emag_act(mob/user)
	if(emagged)
		return
	add_attack_logs(user, src, "emagged")
	if(user)
		to_chat(user, span_danger("Вы переписали схемы метеорного щита, заставив его привлекать метеоры, а не уничтожать их."))
	emagged = TRUE
	if(active)
		change_meteor_chance(2)

/obj/effect/abstract/meteor_shield_proxy
	name = "Proxy Detector For Meteor Shield"
	/// The meteor shield sat this is proxying - any HasProximity calls will be forwarded to it.
	var/obj/machinery/satellite/meteor_shield/parent

/obj/effect/abstract/meteor_shield_proxy/Initialize(mapload, obj/machinery/satellite/meteor_shield/parent)
	. = ..()
	if(QDELETED(parent))
		return INITIALIZE_HINT_QDEL
	src.parent = parent
	AddComponent(/datum/component/proximity_monitor, parent.kill_range)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_parent_deleted))
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_parent_z_changed))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_parent_moved))

/obj/effect/abstract/meteor_shield_proxy/HasProximity(atom/movable/AM)
	parent.shoot_meteor(AM)

/obj/effect/abstract/meteor_shield_proxy/proc/on_parent_moved()
	SIGNAL_HANDLER
	var/turf/parent_loc = get_turf(parent)
	var/turf/new_loc = locate(parent_loc.x, parent_loc.y, z)
	abstract_move(new_loc)

/obj/effect/abstract/meteor_shield_proxy/proc/on_parent_z_changed()
	SIGNAL_HANDLER
	if(z == parent.z || !are_zs_connected(parent, src))
		qdel(src)

/obj/effect/abstract/meteor_shield_proxy/proc/on_parent_deleted()
	SIGNAL_HANDLER
	qdel(src)
