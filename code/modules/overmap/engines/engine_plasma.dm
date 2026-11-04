/obj/machinery/ship_engine/plasma
	omnidirectional = FALSE
	name = "small plasma engine"
	desc = "Малый плазменный двигатель. Подключите трубу к стороне, противоположной выхлопу. Восемь процентов основной тяги доступны боковым соплам."
	icon = 'icons/obj/machines/ship_engine.dmi'
	icon_state = "nozzle"
	color = "#ffb677"
	opacity = FALSE
	generated_thrust = OVERMAP_ENGINE_SMALL_THRUST * 3
	active_power_usage = 0
	var/fuel_rate = 1
	var/obj/machinery/atmospherics/unary/ship_engine_feed/fuel_port
	engine_board = /obj/item/circuitboard/ship_engine_plasma

/obj/machinery/ship_engine/plasma/Initialize(mapload)
	. = ..()
	fuel_port = new(get_turf(src), src)

/obj/machinery/ship_engine/plasma/Destroy()
	QDEL_NULL(fuel_port)
	return ..()

/obj/machinery/ship_engine/plasma/fuel_available()
	return fuel_port?.node && fuel_port.air_contents?.toxins() > 0

/obj/machinery/ship_engine/plasma/resource_fraction(elapsed)
	var/cost = fuel_rate * thrust_limit * elapsed / (1 SECONDS)
	return clamp(fuel_port?.air_contents?.toxins() / max(cost, 0.001), 0, 1)

/obj/machinery/ship_engine/plasma/consume_fuel(elapsed)
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
	. += span_notice("Плазма: [round(fuel_port?.air_contents?.toxins() || 0, 0.01)] моль. Расход: [fuel_rate] моль/с при полной тяге. Подача трубы: [dir2text(REVERSE_DIR(dir))].")

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
	var/obj/machinery/ship_engine/plasma/engine

/obj/machinery/atmospherics/unary/ship_engine_feed/Initialize(mapload, obj/machinery/ship_engine/plasma/engine)
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
