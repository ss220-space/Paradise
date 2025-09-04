//Station Shield
// A chain of satellites encircles the station
// Satellites be actived to generate a shield that will block unorganic matter from passing it.
/datum/station_goal/station_shield
	name = "Station Shield"
	var/max_meteor = 100
	var/coverage_goal = 75
	var/last_coverage = 0
	var/is_testing = FALSE
	var/thrown = 0
	var/goal_completed = FALSE
	var/list/defended = list()
	var/list/collisions = list()

/datum/station_goal/station_shield/get_report()
	return {"<b>Сооружение щитов станции</b><br>
	В области вокруг станции большое количество космического мусора. У нас есть прототип щитовой системы, которую вы должны установить для уменьшения числа происшествий, связанных со столкновениями.
	<br><br>
	Вы можете заказать доставку спутников и системы их управления через шаттл отдела снабжения."}

/datum/station_goal/station_shield/on_report()
	//Unlock
	var/datum/supply_packs/pack = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/shield_sat]"]
	pack.special_enabled = TRUE
	supply_list.Add(pack)

	pack = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/shield_sat_control]"]
	pack.special_enabled = TRUE
	supply_list.Add(pack)
	//Changes
	var/list/station_levels = levels_by_trait(STATION_LEVEL)
	max_meteor = max_meteor * station_levels.len
	coverage_goal = max_meteor - 25 //225 to 300 or 150 to 200 feels weird

/datum/station_goal/station_shield/check_completion()
	if(..())
		return TRUE
	return goal_completed

/datum/station_goal/station_shield/proc/update_coverage(success, turf/where)
	if(success)
		defended += list(list("x" = where.x, "y" = where.y, "z" = where.z))
	else
		collisions += list(list("x" = where.x, "y" = where.y, "z" = where.z))
	if(length(defended) > last_coverage)
		last_coverage = length(defended)
	if(length(defended) + length(collisions) >= max_meteor)
		last_coverage = length(defended)
		is_testing = FALSE

/datum/station_goal/station_shield/proc/simulate_meteors()
	if(is_testing)
		return FALSE
	if(last_coverage >= coverage_goal)
		goal_completed = TRUE
	last_coverage = 0
	is_testing = TRUE
	thrown = 0
	defended = list()
	collisions = list()
	START_PROCESSING(SSprocessing, src)

/datum/station_goal/station_shield/process()
	spawn_meteor(list(/obj/effect/meteor/fake = 1))
	thrown++
	if(thrown < max_meteor)
		return

	if(last_coverage >= coverage_goal)
		goal_completed = TRUE
	return PROCESS_KILL

/obj/item/circuitboard/computer/sat_control
	board_name = "Контроллер сети спутников"
	build_path = /obj/machinery/computer/sat_control
	origin_tech = "engineering=3"

/obj/machinery/computer/sat_control
	name = "Управление спутниками"
	desc = "Используется для управления спутниковой сетью."
	circuit = /obj/item/circuitboard/computer/sat_control
	icon_screen = "accelerator"
	icon_keyboard = "rd_key"
	var/datum/ui_module/sat_control/sat_control

/obj/machinery/computer/sat_control/New()
	sat_control = new(src)
	sat_control.object = src
	..()

/obj/machinery/computer/sat_control/Destroy()
	QDEL_NULL(sat_control)
	return ..()

/obj/machinery/computer/sat_control/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/sat_control/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/sat_control/ui_interact(mob/user, datum/tgui/ui = null)
	sat_control.ui_interact(user, ui)

/obj/machinery/computer/sat_control/interact(mob/user)
	sat_control.ui_interact(user)

/obj/machinery/satellite
	name = "inactive satellite"
	desc = ""
	icon = 'icons/obj/machines/satellite.dmi'
	icon_state = "sat_inactive"
	var/mode = "NTPROBEV0.8"
	var/active = FALSE
	density = TRUE
	use_power = FALSE
	var/static/gid = 0
	var/id = 0

/obj/machinery/satellite/Initialize(mapload)
	. = ..()
	id = gid++

/obj/machinery/satellite/attack_hand(mob/user)
	if(..())
		return TRUE
	interact(user)

/obj/machinery/satellite/interact(mob/user)
	toggle(user)

/obj/machinery/satellite/proc/toggle(mob/user)
	if(!active && !isinspace())
		if(user)
			to_chat(user, span_warning("Вы можете активировать только спутники, находящиеся в космосе."))
		return FALSE
	if(user)
		to_chat(user, span_notice("Вы [active ? "деактивировали": "активировали"] [src]"))
	active = !active
	if(active)
		animate(src, pixel_y = 2, time = 10, loop = -1)
		set_anchored(TRUE)
		pulledby?.stop_pulling()
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
	name = "meteor shield satellite"
	desc = "Автономный модуль, синхронизированный с другими спутниками, формирует защитное поле вокруг станции, предназначенное для отражения ударов метеоров."
	mode = "M-SHIELD"
	speed_process = TRUE
	var/kill_range = 14
	/// A list of "proxy" objects used for multi-z coverage.
	var/list/obj/effect/abstract/meteor_shield_proxy/proxies = list()

/obj/machinery/satellite/meteor_shield/examine(mob/user)
	. = ..()
	if(active)
		. += span_notice("В настоящее время активно. Вы можете взаимодействовать с ним, чтобы отключить.")
		if(emagged)
			. += span_warning("Вместо обычных звуковых сигналов он издаёт странное постоянное шипение белого шума…")
		else
			. += span_notice("Он периодически издаёт звуковые сигналы, связываясь со спутниковой сетью.")
	else
		. += span_notice("В настоящее время отключено. Вы можете взаимодействовать с ним, чтобы активировать.")
		if(emagged)
			. += span_warning("Но что-то здесь не так…?")

/obj/machinery/satellite/meteor_shield/proc/space_los(meteor)
	for(var/turf/turf as anything in get_line(src, meteor))
		if(!isspaceturf(turf))
			return FALSE
	return TRUE

/obj/machinery/satellite/meteor_shield/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/proximity_monitor, kill_range)
	setup_proxies()

/obj/machinery/satellite/meteor_shield/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	setup_proxies()

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

/obj/machinery/satellite/meteor_shield/proc/setup_proxies()
	for(var/stacked_z in SSmapping.get_connected_levels(get_turf(src)))
		setup_proxy_for_z(stacked_z)

/obj/machinery/satellite/meteor_shield/HasProximity(atom/movable/AM)
	shoot_meteor(AM)

/obj/machinery/satellite/meteor_shield/proc/shoot_meteor(atom/movable/possible_danger)
	if(!active)
		return
	if(istype(possible_danger, /obj/effect/meteor))
		var/obj/effect/meteor/meteor_to_destroy = possible_danger
		if(!space_los(meteor_to_destroy))
			return

		if(emagged && !is_fake_meteor(meteor_to_destroy))
			return

		if(meteor_to_destroy.shield_defense(src))
			Beam(get_turf(meteor_to_destroy), icon_state = "sat_beam", time = 5, maxdistance = kill_range)
			new /obj/effect/temp_visual/pka_explosion(get_turf(meteor_to_destroy))

		qdel(meteor_to_destroy)

/obj/machinery/satellite/meteor_shield/toggle(user)
	if(..(user))
		return TRUE
	if(emagged)
		if(active)
			change_meteor_chance(2)
		else
			change_meteor_chance(0.5)

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

/obj/machinery/satellite/meteor_shield/Destroy()
	. = ..()
	if(!(active && emagged))
		return

	change_meteor_chance(0.5)

/obj/machinery/satellite/meteor_shield/emag_act(mob/user)
	if(emagged)
		return

	add_attack_logs(user, src, "emagged")
	to_chat(user, span_danger("Вы переписали схемы метеорного щита, заставив его привлекать метеоры, а не уничтожать их."))
	emagged = TRUE
	if(active)
		change_meteor_chance(2)
	return TRUE

/obj/effect/abstract/meteor_shield_proxy
	name = "Proxy Detector For Meteor Shield"
	/// The meteor shield sat this is proxying - any HasProximity calls will be forwarded to it..
	var/obj/machinery/satellite/meteor_shield/parent
	speed_process = TRUE

/obj/effect/abstract/meteor_shield_proxy/Initialize(mapload, obj/machinery/satellite/meteor_shield/parent)
	. = ..()
	if(QDELETED(parent))
		return INITIALIZE_HINT_QDEL
	src.parent = parent
	AddComponent(/datum/component/proximity_monitor, parent.kill_range)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_parent_moved))
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_parent_z_changed))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_parent_deleted))

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

