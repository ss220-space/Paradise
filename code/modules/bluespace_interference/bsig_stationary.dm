#define BSIG_S_MIN_RANGE 5
#define BSIG_S_MAX_RANGE 10
#define BSIG_S_REQUIRED_CAPACITORS 3
#define BSIG_S_CAPACITOR_BASE_LOAD 200
#define BSIG_S_CAPACITOR_RATING_LOAD_REDUCTION 25
#define BSIG_S_FIELD_COLOR "#3aa6ff"
#define BSIG_S_DIAG_FIELD_ALPHA 150
#define BSIG_S_TOGGLE_COOLDOWN (2 SECONDS)
#define BSIG_S_SHUNT_MARGIN 2
#define BSIG_S_MAX_RATING_OFFSET 3
#define BSIG_S_FIELD_TURFS_KEY "field_turfs"
#define BSIG_S_EDGE_TURFS_KEY "edge_turfs"

/obj/item/circuitboard/machine/bsig_stationary
	board_name = "BSIG-S"
	desc = "Печатная плата стационарного генератора блюспейс-помех."
	build_path = /obj/machinery/power/bluespace_interference_generator/stationary
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	origin_tech = "bluespace=6;materials=6"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 3,
		/obj/item/stack/ore/bluespace_crystal = 5,
	)

/obj/item/circuitboard/machine/bsig_stationary/get_ru_names()
	return alist(
		NOMINATIVE = "плата BSIG-S",
		GENITIVE = "платы BSIG-S",
		DATIVE = "плате BSIG-S",
		ACCUSATIVE = "плату BSIG-S",
		INSTRUMENTAL = "платой BSIG-S",
		PREPOSITIONAL = "плате BSIG-S",
	)

/datum/proximity_monitor/advanced/bsig_stationary
	var/obj/machinery/power/bluespace_interference_generator/stationary/generator
	var/list/interfered_movables
	/// Ассоциативные turf -> TRUE зеркала field_turfs/edge_turfs для O(1) проверки принадлежности
	/// на горячем пути (родитель хранит их плоскими списками, а `turf in list` по кругу из ~300
	/// тайлов слишком медленно для вызовов на каждое движение/телепорт). Перестраиваются в recalculate_field.
	var/list/field_turf_lookup
	var/list/edge_turf_lookup
	var/static/list/bsig_loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_uncrossed),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(on_initialized),
		COMSIG_ATOM_INTERCEPT_TELEPORTING = PROC_REF(intercept_teleporting),
	)

/datum/proximity_monitor/advanced/bsig_stationary/New(atom/_host, range, works_when_not_on_turf = FALSE, obj/machinery/power/bluespace_interference_generator/stationary/new_generator)
	generator = new_generator
	interfered_movables = list()
	..(_host, range, works_when_not_on_turf)

/datum/proximity_monitor/advanced/bsig_stationary/Destroy()
	clear_interfered_movables()
	generator = null
	return ..()

/datum/proximity_monitor/advanced/bsig_stationary/set_range(range, force_rebuild = FALSE)
	if(!force_rebuild && range == current_range)
		return FALSE
	. = TRUE
	current_range = range
	AddComponent(/datum/component/connect_range, host, bsig_loc_connections, range, works_when_not_on_turf)
	recalculate_field(full_recalc = force_rebuild)

/datum/proximity_monitor/advanced/bsig_stationary/recalculate_field(full_recalc = FALSE)
	. = ..()
	build_turf_lookups()
	generator?.refresh_field_visuals()

/datum/proximity_monitor/advanced/bsig_stationary/proc/build_turf_lookups()
	field_turf_lookup = list()
	for(var/turf/field_turf as anything in field_turfs)
		field_turf_lookup[field_turf] = TRUE
	edge_turf_lookup = list()
	for(var/turf/edge_turf as anything in edge_turfs)
		edge_turf_lookup[edge_turf] = TRUE

/datum/proximity_monitor/advanced/bsig_stationary/update_new_turfs()
	if(!host)
		return list(BSIG_S_FIELD_TURFS_KEY = list(), BSIG_S_EDGE_TURFS_KEY = list())
	if(!works_when_not_on_turf && !isturf(host.loc))
		return list(BSIG_S_FIELD_TURFS_KEY = list(), BSIG_S_EDGE_TURFS_KEY = list())

	var/turf/center_turf = get_turf(host)
	if(!center_turf)
		return list(BSIG_S_FIELD_TURFS_KEY = list(), BSIG_S_EDGE_TURFS_KEY = list())

	var/list/local_field_turfs = circle_range_turfs(center_turf, current_range)
	// Помечаем тайлы поля в ассоциативном списке, чтобы исключить их из внешнего кольца за O(1)
	// вместо вычитания списков (list - list — это O(n*m)).
	var/list/field_lookup = list()
	for(var/turf/field_turf as anything in local_field_turfs)
		field_lookup[field_turf] = TRUE
	var/list/local_edge_turfs = list()
	for(var/turf/candidate_turf as anything in circle_range_turfs(center_turf, current_range + BSIG_S_SHUNT_MARGIN))
		if(field_lookup[candidate_turf])
			continue
		local_edge_turfs += candidate_turf
	return list(BSIG_S_FIELD_TURFS_KEY = local_field_turfs, BSIG_S_EDGE_TURFS_KEY = local_edge_turfs)

/datum/proximity_monitor/advanced/bsig_stationary/proc/blocks_turf(turf/target_turf)
	return generator?.field_active && target_turf && LAZYACCESS(field_turf_lookup, target_turf)

/datum/proximity_monitor/advanced/bsig_stationary/on_initialized(turf/location, atom/created, init_flags)
	if(!ismovable(created))
		return
	var/atom/movable/created_movable = created
	on_entered(location, created_movable, null)

/datum/proximity_monitor/advanced/bsig_stationary/on_entered(turf/source, atom/movable/entered, turf/old_loc)
	if(LAZYACCESS(field_turf_lookup, source))
		field_turf_crossed(entered, old_loc, source)
	else if(LAZYACCESS(edge_turf_lookup, source))
		field_edge_crossed(entered, old_loc, source)

/datum/proximity_monitor/advanced/bsig_stationary/on_uncrossed(turf/source, atom/movable/gone, direction)
	if(LAZYACCESS(field_turf_lookup, source))
		field_turf_uncrossed(gone, source, get_turf(gone))
	else if(LAZYACCESS(edge_turf_lookup, source))
		field_edge_uncrossed(gone, source, get_turf(gone))

/datum/proximity_monitor/advanced/bsig_stationary/setup_field_turf(turf/target)
	for(var/atom/movable/movable as anything in target)
		register_interfered_movable(movable)

/datum/proximity_monitor/advanced/bsig_stationary/cleanup_field_turf(turf/target)
	for(var/atom/movable/movable as anything in target)
		unregister_interfered_movable(movable)

/datum/proximity_monitor/advanced/bsig_stationary/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	register_interfered_movable(movable)

/datum/proximity_monitor/advanced/bsig_stationary/field_turf_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(blocks_turf(new_location))
		return
	unregister_interfered_movable(movable)

/datum/proximity_monitor/advanced/bsig_stationary/field_edge_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	return

/datum/proximity_monitor/advanced/bsig_stationary/field_edge_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	return

/datum/proximity_monitor/advanced/bsig_stationary/proc/register_interfered_movable(atom/movable/movable)
	if(!movable || QDELETED(movable))
		return
	if(interfered_movables[movable])
		return
	interfered_movables[movable] = TRUE
	RegisterSignal(movable, COMSIG_MOVABLE_TELEPORTING, PROC_REF(block_movable_teleport))
	RegisterSignal(movable, COMSIG_QDELETING, PROC_REF(on_interfered_movable_deleted))

/datum/proximity_monitor/advanced/bsig_stationary/proc/unregister_interfered_movable(atom/movable/movable)
	if(!interfered_movables[movable])
		return
	interfered_movables -= movable
	UnregisterSignal(movable, list(COMSIG_MOVABLE_TELEPORTING, COMSIG_QDELETING))

/datum/proximity_monitor/advanced/bsig_stationary/proc/clear_interfered_movables()
	if(!length(interfered_movables))
		return
	for(var/atom/movable/movable as anything in interfered_movables.Copy())
		unregister_interfered_movable(movable)

/datum/proximity_monitor/advanced/bsig_stationary/proc/on_interfered_movable_deleted(atom/movable/movable)
	SIGNAL_HANDLER

	unregister_interfered_movable(movable)

/datum/proximity_monitor/advanced/bsig_stationary/proc/block_movable_teleport(atom/movable/movable, turf/origin, turf/destination, list/teleport_data)
	SIGNAL_HANDLER

	if(!generator?.field_active || !blocks_turf(get_turf(movable)))
		return
	if(teleport_data && teleport_data[TELEPORT_INTERCEPT_IGNORE_BLUESPACE])
		return
	if(teleport_data)
		teleport_data[TELEPORT_INTERCEPT_BLUESPACE_BLOCKED] = TRUE
	return COMPONENT_BLOCK_TELEPORT

/datum/proximity_monitor/advanced/bsig_stationary/proc/intercept_teleporting(turf/target_turf, turf/origin, list/teleport_data)
	SIGNAL_HANDLER

	if(!generator?.field_active || !LAZYACCESS(field_turf_lookup, target_turf))
		return
	if(teleport_data && teleport_data[TELEPORT_INTERCEPT_IGNORE_BLUESPACE])
		return
	if(teleport_data && teleport_data[TELEPORT_INTERCEPT_BLOCK_BLUESPACE])
		teleport_data[TELEPORT_INTERCEPT_BLUESPACE_BLOCKED] = TRUE
		return COMPONENT_BLOCK_TELEPORT

	var/turf/interference_edge = generator.get_edge_turf(origin, target_turf)
	if(!interference_edge || interference_edge == target_turf)
		if(teleport_data)
			teleport_data[TELEPORT_INTERCEPT_BLUESPACE_BLOCKED] = TRUE
		return COMPONENT_BLOCK_TELEPORT
	if(teleport_data)
		teleport_data[TELEPORT_INTERCEPT_DESTINATION] = interference_edge
		teleport_data[TELEPORT_INTERCEPT_BLUESPACE_SHUNTED] = TRUE

/obj/machinery/power/bluespace_interference_generator/stationary
	name = "BSIG-S"
	desc = "Стационарный генератор блюспейс-помех. Предотвращает блюспейс-перемещение в небольшом радиусе при подключении к запитанному АПЦ и рабочему узлу электросети."
	icon = 'icons/obj/machines/BSIG-S.dmi'
	icon_state = "BSIS_G_static"
	pixel_x = -16
	density = TRUE
	max_integrity = 300
	integrity_failure = 100
	interact_offline = TRUE

	var/enabled = FALSE
	var/field_active = FALSE
	var/cable_powered = FALSE
	var/field_range = BSIG_S_MIN_RANGE
	var/power_usage = BSIG_S_REQUIRED_CAPACITORS * BSIG_S_CAPACITOR_BASE_LOAD
	var/list/field_visuals = list()
	var/datum/proximity_monitor/advanced/bsig_stationary/interference_field
	COOLDOWN_DECLARE(toggle_cooldown)

/obj/machinery/power/bluespace_interference_generator/stationary/get_ru_names()
	return alist(
		NOMINATIVE = "BSIG-S",
		GENITIVE = "BSIG-S",
		DATIVE = "BSIG-S",
		ACCUSATIVE = "BSIG-S",
		INSTRUMENTAL = "BSIG-S",
		PREPOSITIONAL = "BSIG-S",
	)

/obj/machinery/power/bluespace_interference_generator/stationary/Initialize(mapload)
	. = ..()
	if(!LAZYLEN(component_parts))
		new_component_parts()
	else
		RefreshParts()
	connect_to_network()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/power/bluespace_interference_generator/stationary/Destroy()
	set_field_active(FALSE)
	return ..()

/obj/machinery/power/bluespace_interference_generator/stationary/on_construction()
	connect_to_network()

/obj/machinery/power/bluespace_interference_generator/stationary/proc/new_component_parts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/bsig_stationary(null)
	for(var/i in 1 to 2)
		component_parts += new /obj/item/stock_parts/manipulator(null)
	for(var/i in 1 to BSIG_S_REQUIRED_CAPACITORS)
		component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal(null, 5)
	RefreshParts()

/obj/machinery/power/bluespace_interference_generator/stationary/RefreshParts()
	. = ..()
	var/capacitor_count = 0
	var/range_part_count = 0
	var/total_range_rating = 0
	power_usage = 0
	var/list/parts = component_parts

	for(var/obj/item/part as anything in parts)
		if(istype(part, /obj/item/stock_parts/capacitor))
			var/obj/item/stock_parts/capacitor/capacitor = part
			capacitor_count++
			var/capacitor_rating = capacitor.rating
			power_usage += max(0, BSIG_S_CAPACITOR_BASE_LOAD - (BSIG_S_CAPACITOR_RATING_LOAD_REDUCTION * capacitor_rating))
			total_range_rating += capacitor_rating
			range_part_count++
		else if(istype(part, /obj/item/stock_parts/manipulator))
			var/obj/item/stock_parts/manipulator/manipulator = part
			var/manipulator_rating = manipulator.rating
			total_range_rating += manipulator_rating
			range_part_count++

	if(capacitor_count < BSIG_S_REQUIRED_CAPACITORS)
		power_usage += (BSIG_S_REQUIRED_CAPACITORS - capacitor_count) * BSIG_S_CAPACITOR_BASE_LOAD

	if(range_part_count)
		var/average_rating = total_range_rating / range_part_count
		field_range = clamp(BSIG_S_MIN_RANGE + round((average_rating - 1) * (BSIG_S_MAX_RANGE - BSIG_S_MIN_RANGE) / BSIG_S_MAX_RATING_OFFSET), BSIG_S_MIN_RANGE, BSIG_S_MAX_RANGE)
	else
		field_range = BSIG_S_MIN_RANGE

	if(field_active)
		interference_field?.set_range(field_range, TRUE)

/obj/machinery/power/bluespace_interference_generator/stationary/process(seconds_per_tick)
	if(!can_operate())
		set_cable_powered(FALSE)
		set_field_active(FALSE)
		return

	if(surplus() < power_usage)
		set_cable_powered(FALSE)
		set_field_active(FALSE)
		return

	add_load(power_usage)
	set_cable_powered(TRUE)
	set_field_active(TRUE)

/obj/machinery/power/bluespace_interference_generator/stationary/power_change(forced = FALSE)
	var/old_stat = stat
	if(has_active_apc())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	if(stat & NOPOWER)
		set_cable_powered(FALSE)
		set_field_active(FALSE)
	. = (old_stat != stat) || forced
	if(.)
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/has_active_apc()
	var/area/current_area = get_area(src)
	if(!current_area)
		return FALSE
	var/obj/machinery/power/apc/apc = current_area.get_apc()
	if(!apc || (apc.stat & (BROKEN|NOPOWER)))
		return FALSE
	return current_area.powered(EQUIP)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/has_powernet_node()
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return FALSE
	if(!current_turf.get_cable_node())
		if(powernet)
			disconnect_from_network()
		return FALSE
	if(!powernet)
		connect_to_network()
	return powernet ? TRUE : FALSE

/obj/machinery/power/bluespace_interference_generator/stationary/proc/can_operate()
	if(!enabled || !anchored || !is_operational())
		return FALSE
	return has_powernet_node()

/obj/machinery/power/bluespace_interference_generator/stationary/proc/set_cable_powered(new_cable_powered)
	if(cable_powered == new_cable_powered)
		return
	cable_powered = new_cable_powered
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/set_field_active(new_field_active)
	if(field_active == new_field_active)
		return
	field_active = new_field_active
	if(field_active)
		interference_field = new /datum/proximity_monitor/advanced/bsig_stationary(src, field_range, FALSE, src)
		refresh_field_visuals()
		set_light(2, 0.6, BSIG_S_FIELD_COLOR, l_on = TRUE)
	else
		QDEL_NULL(interference_field)
		clear_field_visuals()
		set_light(0, 0)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/clear_field_visuals()
	var/datum/atom_hud/data/diagnostic/basic_diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC]
	basic_diag_hud?.remove_atom_from_hud(src)
	var/datum/atom_hud/data/diagnostic/advanced_diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
	advanced_diag_hud?.remove_atom_from_hud(src)
	field_visuals = list()
	LAZYREMOVE(active_hud_list, DIAG_HUD)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/refresh_field_visuals()
	clear_field_visuals()
	if(!field_active || !interference_field)
		return
	var/list/current_field_turfs = interference_field.field_turfs
	for(var/turf/current_turf as anything in current_field_turfs)
		var/image/field_visual = image('icons/effects/alphacolors.dmi', current_turf, "blue", ABOVE_OPEN_TURF_LAYER)
		field_visual.alpha = BSIG_S_DIAG_FIELD_ALPHA
		field_visual.color = BSIG_S_FIELD_COLOR
		field_visuals += field_visual
	LAZYSET(active_hud_list, DIAG_HUD, field_visuals)
	var/datum/atom_hud/data/diagnostic/basic_diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC]
	basic_diag_hud?.add_atom_to_hud(src)
	var/datum/atom_hud/data/diagnostic/advanced_diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
	advanced_diag_hud?.add_atom_to_hud(src)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/blocks_turf(turf/target_turf)
	return interference_field?.blocks_turf(target_turf)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/get_edge_turf(turf/origin, turf/intended_destination)
	if(!blocks_turf(intended_destination))
		return intended_destination

	if(origin && origin != intended_destination && origin.z == intended_destination.z)
		var/turf/current_turf = intended_destination
		for(var/i in 1 to BSIG_S_MAX_RANGE + BSIG_S_SHUNT_MARGIN)
			current_turf = get_step_towards(current_turf, origin)
			if(!current_turf)
				break
			if(!blocks_turf(current_turf) && !current_turf.is_blocked_turf(exclude_mobs = TRUE))
				return current_turf

	return get_nearest_edge_turf(intended_destination)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/get_nearest_edge_turf(turf/from_turf)
	if(!from_turf)
		return null
	if(!interference_field)
		return null
	var/target_z = from_turf.z
	var/turf/best_turf
	var/best_distance
	var/list/current_edge_turfs = interference_field.edge_turfs

	for(var/turf/current_turf as anything in current_edge_turfs)
		if(!current_turf || current_turf.z != target_z)
			continue
		if(current_turf.is_blocked_turf(exclude_mobs = TRUE))
			continue

		var/current_distance = get_dist(current_turf, from_turf)
		if(!best_turf || current_distance < best_distance)
			best_turf = current_turf
			best_distance = current_distance

	return best_turf

/obj/machinery/power/bluespace_interference_generator/stationary/update_icon_state()
	if(field_active)
		icon_state = "BSIS_G_dynamic"
	else
		icon_state = "BSIS_G_static"

/obj/machinery/power/bluespace_interference_generator/stationary/examine(mob/user)
	. = ..()
	. += span_notice("Дисплей показывает радиус помех в [field_range] [declension_ru(field_range, "тайл", "тайла", "тайлов")] и потребление [power_usage] Вт.")
	. += span_notice("[src] сейчас [enabled ? "включён" : "выключен"].")
	if(enabled && !field_active)
		if(stat & NOPOWER)
			. += span_warning("Локальный АПЦ не подаёт питание на оборудование.")
		else if(!has_powernet_node())
			. += span_warning("Под [src] нужен рабочий узел электросети.")
		else if(!cable_powered)
			. += span_warning("Электросеть не выдерживает текущее потребление.")

/obj/machinery/power/bluespace_interference_generator/stationary/attack_hand(mob/user)
	if(panel_open)
		return ..()
	if(..())
		return TRUE
	if(stat & BROKEN)
		to_chat(user, span_warning("[src] сломан."))
		return TRUE
	if(user.default_can_use_topic(src) != UI_INTERACTIVE)
		return TRUE
	if(!COOLDOWN_FINISHED(src, toggle_cooldown))
		to_chat(user, span_warning("[src] ещё стабилизирует блюспейс-поле."))
		return TRUE

	COOLDOWN_START(src, toggle_cooldown, BSIG_S_TOGGLE_COOLDOWN)
	enabled = !enabled
	if(!enabled)
		set_cable_powered(FALSE)
		set_field_active(FALSE)
	to_chat(user, span_notice("Вы [enabled ? "включаете" : "выключаете"] [src]."))
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/power/bluespace_interference_generator/stationary/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(field_active)
		to_chat(user, span_warning("Перед открытием панели нужно выключить [src]."))
		return

	default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/power/bluespace_interference_generator/stationary/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(enabled || field_active)
		to_chat(user, span_warning("Сначала нужно выключить [src]."))
		return

	default_deconstruction_crowbar(user, I)

/obj/machinery/power/bluespace_interference_generator/stationary/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(enabled || field_active)
		to_chat(user, span_warning("Сначала нужно выключить [src]."))
		return

	default_unfasten_wrench(user, I)

/obj/machinery/power/bluespace_interference_generator/stationary/welder_act(mob/user, obj/item/I)
	. = TRUE
	default_welder_repair(user, I)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/power/bluespace_interference_generator/stationary/obj_break(damage_flag)
	. = ..()
	set_cable_powered(FALSE)
	set_field_active(FALSE)

#undef BSIG_S_MIN_RANGE
#undef BSIG_S_MAX_RANGE
#undef BSIG_S_REQUIRED_CAPACITORS
#undef BSIG_S_CAPACITOR_BASE_LOAD
#undef BSIG_S_CAPACITOR_RATING_LOAD_REDUCTION
#undef BSIG_S_FIELD_COLOR
#undef BSIG_S_DIAG_FIELD_ALPHA
#undef BSIG_S_TOGGLE_COOLDOWN
#undef BSIG_S_SHUNT_MARGIN
#undef BSIG_S_MAX_RATING_OFFSET
#undef BSIG_S_FIELD_TURFS_KEY
#undef BSIG_S_EDGE_TURFS_KEY
