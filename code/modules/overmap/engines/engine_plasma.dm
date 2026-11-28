/obj/machinery/ship_engine/plasma
	engine_board = /obj/item/circuitboard/ship_engine_plasma
	omnidirectional = FALSE
	name = "small plasma engine"
	desc = "Малый плазменный двигатель. Подключите трубу к стороне, противоположной выхлопу. Восемь процентов основной тяги доступны боковым соплам."
	icon = 'icons/obj/machines/ship_engine.dmi'
	icon_state = "nozzle"
	color = "#ffb677"
	opacity = FALSE
	generated_thrust = OVERMAP_ENGINE_SMALL_THRUST * 3
	active_power_usage = 0
	fuel_rate = 1
	requires_plasma = TRUE

/obj/machinery/ship_engine/proc/fuel_available()
	return !requires_plasma || (fuel_port?.node && fuel_port.air_contents?.toxins() > 0)

/obj/machinery/ship_engine/proc/plasma_multiplier(elapsed)
	if(plasma_boost <= 1 || !fuel_port?.node || !thrust_limit)
		return 1
	var/cost = fuel_rate * thrust_limit * elapsed / (1 SECONDS)
	return fuel_port.air_contents.toxins() >= cost ? plasma_boost : 1

/obj/machinery/ship_engine/proc/consume_fuel(elapsed)
	if(!requires_plasma && plasma_multiplier(elapsed) == 1)
		return TRUE
	if(!fuel_port?.node)
		return FALSE
	var/cost = fuel_rate * thrust_limit * elapsed / (1 SECONDS)
	if(fuel_port.air_contents.toxins() < cost)
		return FALSE
	fuel_port.air_contents.set_toxins(fuel_port.air_contents.toxins() - cost)
	if(fuel_port.parent)
		fuel_port.parent.update = TRUE
	return TRUE

/obj/machinery/ship_engine/plasma/examine(mob/user)
	. = ..()
	. += plasma_supply_description()

/obj/machinery/ship_engine/frontier/examine(mob/user)
	. = ..()
	. += plasma_supply_description()

/obj/machinery/ship_engine/proc/plasma_supply_description()
	return span_notice("??????: [round(fuel_port?.air_contents?.toxins() || 0, 0.01)] ????. ??????: [fuel_rate] ????/? ??? ?????? ????. ?????? ?????: [dir2text(REVERSE_DIR(dir))].")

/obj/machinery/ship_engine/plasma/large
	name = "large plasma engine"
	desc = "Большой плазменный двигатель. Трубная подача плазмы с противоположной от выхлопа стороны."
	icon = 'icons/obj/2x2.dmi'
	icon_state = "large_engine"
	engine_size = 2
	max_integrity = 800
	generated_thrust = OVERMAP_ENGINE_LARGE_THRUST * 3
	fuel_rate = 3
	side_thrust_fraction = 0
	engine_board = /obj/item/circuitboard/ship_engine_plasma/large

/obj/machinery/atmospherics/unary/ship_engine_feed
	name = "engine plasma inlet"
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_HIDE
	use_power = NO_POWER_USE
	vent_movement = NONE
	var/obj/machinery/ship_engine/engine

/obj/machinery/atmospherics/unary/ship_engine_feed/Initialize(mapload, obj/machinery/ship_engine/engine)
	src.engine = engine
	dir = REVERSE_DIR(engine.dir)
	. = ..()
	if(SSair.initialized)
		connect_supply()

/obj/machinery/atmospherics/unary/ship_engine_feed/Destroy()
	if(engine?.fuel_port == src)
		engine.fuel_port = null
	engine = null
	return ..()

/obj/machinery/atmospherics/unary/ship_engine_feed/shuttleRotate(rotation, params)
	. = ..()
	set_inlet_direction(REVERSE_DIR(engine.dir))
	initialize_directions = dir

/obj/machinery/atmospherics/unary/ship_engine_feed/proc/set_inlet_direction(new_direction)
	if(dir == new_direction)
		return
	if(node)
		node.disconnect(src)
	node = null
	nullifyPipenet(parent)
	setDir(new_direction)
	initialize_directions = dir
	connect_supply()

/obj/machinery/atmospherics/unary/ship_engine_feed/proc/connect_supply()
	atmos_init()
	if(node)
		node.atmos_init()
		node.build_network(TRUE)
		var/datum/pipeline/network = node.returnPipenet(src)
		if(network)
			network.addMember(src, node)
	build_network(TRUE)
