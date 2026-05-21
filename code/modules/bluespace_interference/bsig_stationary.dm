#define BSIG_S_MIN_RANGE 5
#define BSIG_S_MAX_RANGE 10
#define BSIG_S_REQUIRED_CAPACITORS 3
#define BSIG_S_CAPACITOR_BASE_LOAD 200
#define BSIG_S_CAPACITOR_RATING_LOAD_REDUCTION 25
#define BSIG_S_FIELD_COLOR "#3aa6ff"
#define BSIG_S_DIAG_FIELD_ALPHA 150

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

/obj/effect/bsig_stationary_field
	name = "поле блюспейс-помех"
	desc = "Едва заметное синее искажение локального блюспейса."
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "blue"
	layer = ABOVE_OPEN_TURF_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	alpha = 0
	hud_possible = list(DIAG_HUD)
	var/obj/machinery/power/bluespace_interference_generator/stationary/generator

/obj/effect/bsig_stationary_field/Initialize(mapload, obj/machinery/power/bluespace_interference_generator/stationary/new_generator)
	. = ..()
	generator = new_generator
	prepare_huds()
	var/image/diag_field = hud_list[DIAG_HUD]
	diag_field.loc = get_turf(src)
	diag_field.icon = icon
	diag_field.icon_state = icon_state
	diag_field.layer = layer
	diag_field.alpha = BSIG_S_DIAG_FIELD_ALPHA
	diag_field.color = BSIG_S_FIELD_COLOR
	var/datum/atom_hud/data/diagnostic/basic_diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC]
	basic_diag_hud?.add_atom_to_hud(src)
	var/datum/atom_hud/data/diagnostic/advanced_diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
	advanced_diag_hud?.add_atom_to_hud(src)

/obj/effect/bsig_stationary_field/Destroy()
	var/datum/atom_hud/data/diagnostic/basic_diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC]
	basic_diag_hud?.remove_atom_from_hud(src)
	var/datum/atom_hud/data/diagnostic/advanced_diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
	advanced_diag_hud?.remove_atom_from_hud(src)
	return ..()

/obj/machinery/power/bluespace_interference_generator/stationary
	name = "BSIG-S"
	desc = "Стационарный генератор блюспейс-помех. Предотвращает блюспейс-перемещение в небольшом радиусе при подключении к запитанному АПЦ и рабочему узлу электросети."
	icon = 'icons/obj/machines/BSIG-S.dmi'
	icon_state = "BSIS_G_static"
	dir = SOUTH
	pixel_x = -16
	pixel_y = 0
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

/obj/machinery/power/bluespace_interference_generator/stationary/Initialize(mapload)
	. = ..()
	GLOB.poi_list |= src
	new_component_parts()
	connect_to_network()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/power/bluespace_interference_generator/stationary/Destroy()
	set_field_active(FALSE)
	GLOB.poi_list -= src
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

	for(var/obj/item/stock_parts/capacitor/capacitor in component_parts)
		capacitor_count++
		power_usage += max(0, BSIG_S_CAPACITOR_BASE_LOAD - (BSIG_S_CAPACITOR_RATING_LOAD_REDUCTION * capacitor.rating))
		total_range_rating += capacitor.rating
		range_part_count++

	for(var/obj/item/stock_parts/manipulator/manipulator in component_parts)
		total_range_rating += manipulator.rating
		range_part_count++

	if(capacitor_count < BSIG_S_REQUIRED_CAPACITORS)
		power_usage += (BSIG_S_REQUIRED_CAPACITORS - capacitor_count) * BSIG_S_CAPACITOR_BASE_LOAD

	if(range_part_count)
		var/average_rating = total_range_rating / range_part_count
		field_range = clamp(BSIG_S_MIN_RANGE + round((average_rating - 1) * ((BSIG_S_MAX_RANGE - BSIG_S_MIN_RANGE) / 4)), BSIG_S_MIN_RANGE, BSIG_S_MAX_RANGE)
	else
		field_range = BSIG_S_MIN_RANGE

	if(field_active)
		refresh_field_visuals()

/obj/machinery/power/bluespace_interference_generator/stationary/process(seconds_per_tick)
	if(stat & BROKEN)
		set_cable_powered(FALSE)
		set_field_active(FALSE)
		return

	power_change()
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
	if(!enabled || panel_open || !anchored || (stat & (BROKEN|NOPOWER)))
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
		GLOB.active_bluespace_interference_generators |= src
		refresh_field_visuals()
		set_light(2, 0.6, BSIG_S_FIELD_COLOR, l_on = TRUE)
	else
		GLOB.active_bluespace_interference_generators -= src
		clear_field_visuals()
		set_light(0, 0)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/clear_field_visuals()
	QDEL_LIST(field_visuals)
	field_visuals = list()

/obj/machinery/power/bluespace_interference_generator/stationary/proc/refresh_field_visuals()
	clear_field_visuals()
	if(!field_active)
		return
	for(var/turf/current_turf as anything in circle_range_turfs(src, field_range))
		var/obj/effect/bsig_stationary_field/field_visual = new(current_turf, src)
		field_visuals += field_visual

/obj/machinery/power/bluespace_interference_generator/stationary/proc/blocks_turf(turf/target_turf)
	if(!field_active || !target_turf)
		return FALSE
	var/turf/center_turf = get_turf(src)
	if(!center_turf || target_turf.z != center_turf.z)
		return FALSE
	var/dx = target_turf.x - center_turf.x
	var/dy = target_turf.y - center_turf.y
	return (dx * dx + dy * dy) <= field_range * (field_range + 0.5)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/get_edge_turf(turf/origin, turf/intended_destination)
	if(!blocks_turf(intended_destination))
		return intended_destination

	if(origin && origin.z == intended_destination.z)
		var/turf/current_turf = intended_destination
		for(var/i in 1 to BSIG_S_MAX_RANGE + 2)
			current_turf = get_step_towards(current_turf, origin)
			if(!current_turf)
				break
			if(!blocks_turf(current_turf) && !current_turf.density)
				return current_turf

	return get_nearest_edge_turf(intended_destination)

/obj/machinery/power/bluespace_interference_generator/stationary/proc/get_nearest_edge_turf(turf/from_turf)
	if(!from_turf)
		return null
	var/list/edge_turfs = turf_peel(field_range + 1, max(field_range - 1, 0), src)
	var/turf/best_turf
	var/best_distance
	var/turf/fallback_turf
	var/fallback_distance

	for(var/turf/current_turf as anything in edge_turfs)
		if(!current_turf || current_turf.z != from_turf.z || blocks_turf(current_turf))
			continue

		var/current_distance = get_dist(current_turf, from_turf)
		if(!fallback_turf || current_distance < fallback_distance)
			fallback_turf = current_turf
			fallback_distance = current_distance

		if(current_turf.density)
			continue
		if(!best_turf || current_distance < best_distance)
			best_turf = current_turf
			best_distance = current_distance

	return best_turf ? best_turf : fallback_turf

/obj/machinery/power/bluespace_interference_generator/stationary/update_icon_state()
	if(field_active)
		icon_state = "BSIS_G_dynamic"
	else
		icon_state = "BSIS_G_static"

/obj/machinery/power/bluespace_interference_generator/stationary/examine(mob/user)
	. = ..()
	. += span_notice("Дисплей показывает радиус помех в [field_range] тайл[declension_ru(field_range, "", "а", "ов")] и потребление [power_usage] Вт.")
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
	if(!target_turf || !length(GLOB.active_bluespace_interference_generators))
		return null

	for(var/obj/machinery/power/bluespace_interference_generator/stationary/generator as anything in GLOB.active_bluespace_interference_generators)
		if(QDELETED(generator) || !generator.field_active)
			GLOB.active_bluespace_interference_generators -= generator
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
