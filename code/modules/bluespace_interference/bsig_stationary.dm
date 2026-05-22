#define BSIG_S_MIN_RANGE 5
#define BSIG_S_MAX_RANGE 10
#define BSIG_S_REQUIRED_CAPACITORS 3
#define BSIG_S_CAPACITOR_BASE_LOAD 200
#define BSIG_S_CAPACITOR_RATING_LOAD_REDUCTION 25
#define BSIG_S_FIELD_COLOR "#3aa6ff"
#define BSIG_S_DIAG_FIELD_ALPHA 150
#define BSIG_S_TOGGLE_COOLDOWN (2 SECONDS)
#define BSIG_S_SHUNT_MARGIN 2
#define DECL_BSIG_S_TILE(num) declension_ru(num, "", "а", "ов")

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
	var/turf/cached_center_turf
	var/cached_field_radius_squared = 0
	var/next_toggle_time = 0

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
		field_range = clamp(BSIG_S_MIN_RANGE + round((average_rating - 1) * ((BSIG_S_MAX_RANGE - BSIG_S_MIN_RANGE) / 3)), BSIG_S_MIN_RANGE, BSIG_S_MAX_RANGE)
	else
		field_range = BSIG_S_MIN_RANGE

	update_cached_field_data()
	if(field_active)
		refresh_field_visuals()

/obj/machinery/power/bluespace_interference_generator/stationary/process(seconds_per_tick)
	if(!can_operate())
		set_cable_powered(FALSE)
		set_field_active(FALSE)
		return

	var/current_power_need = power_usage * seconds_per_tick
	if(surplus() < current_power_need)
		set_cable_powered(FALSE)
		set_field_active(FALSE)
		return

	add_load(current_power_need)
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
		GLOB.active_bluespace_interference_generators |= list(src)
		update_cached_field_data()
		refresh_field_visuals()
		set_light(2, 0.6, BSIG_S_FIELD_COLOR, l_on = TRUE)
	else
		GLOB.active_bluespace_interference_generators -= src
		cached_center_turf = null
		clear_field_visuals()
		set_light(0, 0)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/update_cached_field_data()
	cached_center_turf = get_turf(src)
	cached_field_radius_squared = field_range * (field_range + 0.5)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/clear_field_visuals()
	var/datum/atom_hud/data/diagnostic/basic_diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC]
	basic_diag_hud?.remove_atom_from_hud(src)
	var/datum/atom_hud/data/diagnostic/advanced_diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
	advanced_diag_hud?.remove_atom_from_hud(src)
	field_visuals = list()
	LAZYREMOVE(active_hud_list, DIAG_HUD)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/refresh_field_visuals()
	clear_field_visuals()
	if(!field_active)
		return
	var/range = field_range
	for(var/turf/current_turf as anything in circle_range_turfs(src, range))
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
	if(!field_active || !target_turf)
		return FALSE
	var/turf/center_turf = cached_center_turf
	if(!center_turf || target_turf.z != center_turf.z)
		return FALSE
	var/dx = target_turf.x - center_turf.x
	var/dy = target_turf.y - center_turf.y
	return (dx * dx + dy * dy) <= cached_field_radius_squared

/obj/machinery/power/bluespace_interference_generator/stationary/proc/get_edge_turf(turf/origin, turf/intended_destination)
	if(!blocks_turf(intended_destination))
		return intended_destination

	if(origin && origin.z == intended_destination.z)
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
	var/list/edge_turfs = turf_peel(field_range + 1, max(field_range - 1, 0), src)
	var/turf/best_turf
	var/best_distance

	for(var/turf/current_turf as anything in edge_turfs)
		if(!current_turf || current_turf.z != from_turf.z || blocks_turf(current_turf))
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
	. += span_notice("Дисплей показывает радиус помех в [field_range] тайл[DECL_BSIG_S_TILE(field_range)] и потребление [power_usage] Вт.")
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
	if(world.time < next_toggle_time)
		to_chat(user, span_warning("[src] ещё стабилизирует блюспейс-поле."))
		return TRUE

	next_toggle_time = world.time + BSIG_S_TOGGLE_COOLDOWN
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

/proc/get_bluespace_interference_generator(turf/target_turf)
	var/list/generators = GLOB.active_bluespace_interference_generators
	if(!target_turf || !length(generators))
		return null

	var/target_z = target_turf.z
	for(var/obj/machinery/power/bluespace_interference_generator/stationary/generator in generators)
		if(!generator || QDELETED(generator) || !generator.field_active || generator.z != target_z)
			continue
		if(generator.blocks_turf(target_turf))
			return generator

	return null

#undef BSIG_S_MIN_RANGE
#undef BSIG_S_MAX_RANGE
#undef BSIG_S_REQUIRED_CAPACITORS
#undef BSIG_S_CAPACITOR_BASE_LOAD
#undef BSIG_S_CAPACITOR_RATING_LOAD_REDUCTION
#undef BSIG_S_FIELD_COLOR
#undef BSIG_S_DIAG_FIELD_ALPHA
#undef BSIG_S_TOGGLE_COOLDOWN
#undef BSIG_S_SHUNT_MARGIN
#undef DECL_BSIG_S_TILE
