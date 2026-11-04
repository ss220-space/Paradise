/obj/machinery/ship_engine/proc/get_power_apc() as /obj/machinery/power/apc
	if(!QDELETED(power_apc) && (power_apc.area == get_area(src) || vessel?.shuttle?.shuttle_areas[power_apc.area]) && (!vessel?.shuttle || vessel.shuttle.overmap_is_hull_turf(get_turf(power_apc))))
		return power_apc
	power_apc = null
	var/list/areas = list(get_area(src))
	for(var/area/place as anything in vessel?.shuttle?.shuttle_areas)
		areas |= place
	for(var/area/place as anything in areas)
		for(var/obj/machinery/power/apc/candidate as anything in place?.apc)
			if(!QDELETED(candidate) && (!vessel?.shuttle || vessel.shuttle.overmap_is_hull_turf(get_turf(candidate))))
				power_apc = candidate
				return candidate

/obj/machinery/ship_engine/proc/requires_apc_power()
	var/area/place = get_area(src)
	return requires_apc && (!place || place.requires_power)

/obj/machinery/ship_engine/proc/valid_wall_mount()
	if(!iswallturf(loc))
		return FALSE
	var/turf/exhaust = get_step(src, dir)
	return isspaceturf(exhaust)

/obj/machinery/ship_engine/proc/thrust_origin_x()
	return x + (engine_size - 1) / 2 + (pixel_x + pixel_w) / ICON_SIZE_X

/obj/machinery/ship_engine/proc/thrust_origin_y()
	return y + (engine_size - 1) / 2 + (pixel_y + pixel_z) / ICON_SIZE_Y

/obj/machinery/ship_engine/proc/fuel_available()
	return TRUE

/obj/machinery/ship_engine/proc/consume_fuel(elapsed)
	return TRUE

/obj/machinery/ship_engine/proc/resource_fraction(elapsed)
	if(!requires_apc_power() || !active_power_usage || !thrust_limit)
		return 1
	var/cost = active_power_usage * thrust_limit * elapsed / (1 SECONDS) * GLOB.CELLRATE
	return clamp(get_power_apc()?.cell?.charge / max(cost, 0.001), 0, 1)

/obj/machinery/ship_engine/proc/push_directions()
	var/list/result = list()
	if(omnidirectional)
		for(var/push in GLOB.cardinal)
			result["[push]"] = 1
		return result
	if(!(dir in GLOB.cardinal))
		return result
	var/push = REVERSE_DIR(dir)
	result["[push]"] = 1
	if(side_thrust_fraction)
		result["[turn(push, 90)]"] = side_thrust_fraction
		result["[turn(push, -90)]"] = side_thrust_fraction
	return result

/obj/machinery/ship_engine/examine(mob/user)
	. = ..()
	. += span_notice("Состояние: [get_status()].")
	if(omnidirectional)
		. += span_notice("Продвинутая система сопел даёт полную тягу во все четыре стороны.")
	else
		. += span_notice("Выхлоп направлен [dir2text(dir)], тяга — в противоположную сторону.")
	if(requires_apc_power())
		var/obj/machinery/power/apc/apc = get_power_apc()
		. += span_notice("Потребление при полной тяге: [active_power_usage] Вт. APC: [apc ? "[apc.name], заряд [round(apc.cell?.percent() || 0)]%" : "не найден"].")
	if(side_thrust_fraction && !omnidirectional)
		. += span_notice("Боковые сопла: [round(side_thrust_fraction * 100)]% основной тяги в каждую сторону.")

/obj/machinery/ship_engine/ion
	omnidirectional = FALSE
	requires_apc = TRUE
	name = "small ion engine"
	desc = "Малый ионный двигатель. Питается от APC корабля; вспомогательные сопла дают слабую боковую тягу. dir задаёт направление выхлопа."
	icon = 'icons/obj/machines/ship_engine.dmi'
	icon_state = "nozzle"
	color = "#9ecfff"
	opacity = FALSE
	engine_board = /obj/item/circuitboard/ship_engine_ion

/obj/machinery/ship_engine/ion/large
	name = "large ion engine"
	desc = "Большой ионный двигатель. Питание от APC корабля. Боковых сопел нет."
	icon = 'icons/obj/2x2.dmi'
	icon_state = "large_engine"
	engine_size = 2
	max_integrity = 600
	generated_thrust = OVERMAP_ENGINE_LARGE_THRUST
	active_power_usage = 6000
	side_thrust_fraction = 0
	engine_board = /obj/item/circuitboard/ship_engine_ion/large

/obj/machinery/ship_engine/thruster/rcs
	name = "RCS ion thruster"
	desc = "Настенный ионный RCS. Три сопла дают тягу от стены и вдоль неё. Слабее обычного маневрового трастера."
	generated_thrust = OVERMAP_ENGINE_THRUSTER_THRUST * 0.7
	side_thrust_fraction = 1
	color = "#a7dfff"

/obj/machinery/ship_engine/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "[icon_state]", "[icon_state]", tool)

/obj/machinery/ship_engine/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(user, tool)

/obj/machinery/ship_engine/wrench_act(mob/living/user, obj/item/tool)
	if(firing || !tool.use_tool(src, user, 1 SECONDS, volume = tool.tool_volume))
		return TRUE
	setDir(turn(dir, 90))
	var/obj/machinery/ship_engine/plasma/plasma = src
	if(istype(plasma))
		plasma.fuel_port?.set_inlet_direction(REVERSE_DIR(dir))
	update_icon(UPDATE_OVERLAYS)
	return TRUE
