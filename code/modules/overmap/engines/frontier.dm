/obj/machinery/ship_engine/frontier
	omnidirectional = FALSE
	generated_thrust = OVERMAP_ENGINE_SMALL_THRUST
	active_power_usage = 0
	idle_power_usage = 0
	side_thrust_fraction = 0
	integrated_exhaust = TRUE
	fuel_rate = 2
	plasma_boost = 4

/obj/machinery/ship_engine/frontier_large
	parent_type = /obj/machinery/ship_engine/frontier
	name = "Frontier large thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thruster_large.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	engine_size = 2
	fuel_rate = 6
	generated_thrust = 8
	max_integrity = 650
	engine_board = /obj/item/circuitboard/ship_engine_ion/frontier_large

/obj/machinery/ship_engine/frontier_large/get_ru_names()
	return alist(
		NOMINATIVE = "большой двигатель Frontier",
		GENITIVE = "большого двигателя Frontier",
		DATIVE = "большому двигателю Frontier",
		ACCUSATIVE = "большой двигатель Frontier",
		INSTRUMENTAL = "большим двигателем Frontier",
		PREPOSITIONAL = "большом двигателе Frontier",
	)

/obj/machinery/ship_engine/nfsd_large
	parent_type = /obj/machinery/ship_engine/frontier
	name = "NFSD large thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thrusternfsd_large.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	engine_size = 2
	fuel_rate = 6
	generated_thrust = 9
	max_integrity = 900
	engine_board = /obj/item/circuitboard/ship_engine_ion/nfsd_large

/obj/machinery/ship_engine/nfsd_large/get_ru_names()
	return alist(
		NOMINATIVE = "большой двигатель NFSD",
		GENITIVE = "большого двигателя NFSD",
		DATIVE = "большому двигателю NFSD",
		ACCUSATIVE = "большой двигатель NFSD",
		INSTRUMENTAL = "большим двигателем NFSD",
		PREPOSITIONAL = "большом двигателе NFSD",
	)

/obj/machinery/ship_engine/rogue
	parent_type = /obj/machinery/ship_engine/frontier
	name = "Rogue thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thrusterrogue.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	generated_thrust = 3
	max_integrity = 350
	engine_board = /obj/item/circuitboard/ship_engine_ion/rogue

/obj/machinery/ship_engine/rogue/get_ru_names()
	return alist(
		NOMINATIVE = "двигатель Rogue",
		GENITIVE = "двигателя Rogue",
		DATIVE = "двигателю Rogue",
		ACCUSATIVE = "двигатель Rogue",
		INSTRUMENTAL = "двигателем Rogue",
		PREPOSITIONAL = "двигателе Rogue",
	)

/obj/machinery/ship_engine/rogue_large
	parent_type = /obj/machinery/ship_engine/frontier
	name = "Rogue large thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thrusterrogue_large.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	engine_size = 2
	fuel_rate = 6
	generated_thrust = 10
	max_integrity = 700
	engine_board = /obj/item/circuitboard/ship_engine_ion/rogue_large

/obj/machinery/ship_engine/rogue_large/get_ru_names()
	return alist(
		NOMINATIVE = "большой двигатель Rogue",
		GENITIVE = "большого двигателя Rogue",
		DATIVE = "большому двигателю Rogue",
		ACCUSATIVE = "большой двигатель Rogue",
		INSTRUMENTAL = "большим двигателем Rogue",
		PREPOSITIONAL = "большом двигателе Rogue",
	)

/obj/machinery/ship_engine/ussp
	parent_type = /obj/machinery/ship_engine/frontier
	name = "USSP thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thrusterussp.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	generated_thrust = 2.5
	max_integrity = 500
	engine_board = /obj/item/circuitboard/ship_engine_ion/ussp

/obj/machinery/ship_engine/ussp/get_ru_names()
	return alist(
		NOMINATIVE = "двигатель USSP",
		GENITIVE = "двигателя USSP",
		DATIVE = "двигателю USSP",
		ACCUSATIVE = "двигатель USSP",
		INSTRUMENTAL = "двигателем USSP",
		PREPOSITIONAL = "двигателе USSP",
	)

/obj/machinery/ship_engine/ussp_large
	parent_type = /obj/machinery/ship_engine/frontier
	name = "USSP large thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thrusterussp_large.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	engine_size = 2
	fuel_rate = 6
	generated_thrust = 9
	max_integrity = 1100
	engine_board = /obj/item/circuitboard/ship_engine_ion/ussp_large

/obj/machinery/ship_engine/ussp_large/get_ru_names()
	return alist(
		NOMINATIVE = "большой двигатель USSP",
		GENITIVE = "большого двигателя USSP",
		DATIVE = "большому двигателю USSP",
		ACCUSATIVE = "большой двигатель USSP",
		INSTRUMENTAL = "большим двигателем USSP",
		PREPOSITIONAL = "большом двигателе USSP",
	)
