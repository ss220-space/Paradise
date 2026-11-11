/obj/machinery/ship_engine/frontier_large
	parent_type = /obj/machinery/ship_engine/ion
	name = "Frontier large thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thruster_large.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	engine_size = 2
	generated_thrust = 8
	active_power_usage = 8000
	idle_power_usage = 1500
	max_integrity = 650
	side_thrust_fraction = 0
	integrated_exhaust = TRUE
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

/obj/item/circuitboard/ship_engine_ion/frontier_large
	desc = "TEMP123TEMP"
	board_name = "Frontier large thruster"
	build_path = /obj/machinery/ship_engine/frontier_large
	req_components = list(/obj/item/stock_parts/capacitor = 4, /obj/item/stock_parts/micro_laser = 2, /obj/item/stack/cable_coil = 10)

/obj/machinery/ship_engine/nfsd_stealth
	parent_type = /obj/machinery/ship_engine/ion
	name = "NFSD stealth thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thruster_stealth.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	generated_thrust = 1.5
	active_power_usage = 1200
	idle_power_usage = 200
	max_integrity = 250
	side_thrust_fraction = 0
	integrated_exhaust = TRUE
	engine_board = /obj/item/circuitboard/ship_engine_ion/nfsd_stealth
	burn_sound_type = /datum/looping_sound/ship_engine/stealth

/obj/machinery/ship_engine/nfsd_stealth/get_ru_names()
	return alist(
		NOMINATIVE = "малозаметный двигатель NFSD",
		GENITIVE = "малозаметного двигателя NFSD",
		DATIVE = "малозаметному двигателю NFSD",
		ACCUSATIVE = "малозаметный двигатель NFSD",
		INSTRUMENTAL = "малозаметным двигателем NFSD",
		PREPOSITIONAL = "малозаметном двигателе NFSD",
	)

/obj/item/circuitboard/ship_engine_ion/nfsd_stealth
	desc = "TEMP123TEMP"
	board_name = "NFSD stealth thruster"
	build_path = /obj/machinery/ship_engine/nfsd_stealth
	req_components = list(/obj/item/stock_parts/capacitor = 3, /obj/item/stock_parts/micro_laser = 2, /obj/item/stack/cable_coil = 5)

/obj/machinery/ship_engine/nfsd_large
	parent_type = /obj/machinery/ship_engine/ion
	name = "NFSD large thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thrusternfsd_large.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	engine_size = 2
	generated_thrust = 9
	active_power_usage = 10000
	idle_power_usage = 1500
	max_integrity = 900
	side_thrust_fraction = 0
	integrated_exhaust = TRUE
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

/obj/item/circuitboard/ship_engine_ion/nfsd_large
	desc = "TEMP123TEMP"
	board_name = "NFSD large thruster"
	build_path = /obj/machinery/ship_engine/nfsd_large
	req_components = list(/obj/item/stock_parts/capacitor = 4, /obj/item/stock_parts/micro_laser = 2, /obj/item/stack/cable_coil = 10)

/obj/machinery/ship_engine/rogue
	parent_type = /obj/machinery/ship_engine/ion
	name = "Rogue thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thrusterrogue.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	generated_thrust = 3
	active_power_usage = 2600
	max_integrity = 350
	side_thrust_fraction = 0
	integrated_exhaust = TRUE
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

/obj/item/circuitboard/ship_engine_ion/rogue
	desc = "TEMP123TEMP"
	board_name = "Rogue thruster"
	build_path = /obj/machinery/ship_engine/rogue
	req_components = list(/obj/item/stock_parts/capacitor = 2, /obj/item/stock_parts/micro_laser = 1, /obj/item/stack/cable_coil = 5)

/obj/machinery/ship_engine/rogue_large
	parent_type = /obj/machinery/ship_engine/ion
	name = "Rogue large thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thrusterrogue_large.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	engine_size = 2
	generated_thrust = 10
	active_power_usage = 13000
	idle_power_usage = 1500
	max_integrity = 700
	side_thrust_fraction = 0
	integrated_exhaust = TRUE
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

/obj/item/circuitboard/ship_engine_ion/rogue_large
	desc = "TEMP123TEMP"
	board_name = "Rogue large thruster"
	build_path = /obj/machinery/ship_engine/rogue_large
	req_components = list(/obj/item/stock_parts/capacitor = 4, /obj/item/stock_parts/micro_laser = 2, /obj/item/stack/cable_coil = 10)

/obj/machinery/ship_engine/rogue_stealth
	parent_type = /obj/machinery/ship_engine/ion
	name = "Rogue stealth thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thrusterrogue_stealth.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	active_power_usage = 1700
	idle_power_usage = 200
	side_thrust_fraction = 0
	integrated_exhaust = TRUE
	engine_board = /obj/item/circuitboard/ship_engine_ion/rogue_stealth
	burn_sound_type = /datum/looping_sound/ship_engine/stealth

/obj/machinery/ship_engine/rogue_stealth/get_ru_names()
	return alist(
		NOMINATIVE = "малозаметный двигатель Rogue",
		GENITIVE = "малозаметного двигателя Rogue",
		DATIVE = "малозаметному двигателю Rogue",
		ACCUSATIVE = "малозаметный двигатель Rogue",
		INSTRUMENTAL = "малозаметным двигателем Rogue",
		PREPOSITIONAL = "малозаметном двигателе Rogue",
	)

/obj/item/circuitboard/ship_engine_ion/rogue_stealth
	desc = "TEMP123TEMP"
	board_name = "Rogue stealth thruster"
	build_path = /obj/machinery/ship_engine/rogue_stealth
	req_components = list(/obj/item/stock_parts/capacitor = 3, /obj/item/stock_parts/micro_laser = 2, /obj/item/stack/cable_coil = 5)

/obj/machinery/ship_engine/ussp
	parent_type = /obj/machinery/ship_engine/ion
	name = "USSP thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thrusterussp.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	generated_thrust = 2.5
	active_power_usage = 2200
	max_integrity = 500
	side_thrust_fraction = 0
	integrated_exhaust = TRUE
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

/obj/item/circuitboard/ship_engine_ion/ussp
	desc = "TEMP123TEMP"
	board_name = "USSP thruster"
	build_path = /obj/machinery/ship_engine/ussp
	req_components = list(/obj/item/stock_parts/capacitor = 2, /obj/item/stock_parts/micro_laser = 1, /obj/item/stack/cable_coil = 5)

/obj/machinery/ship_engine/ussp_large
	parent_type = /obj/machinery/ship_engine/ion
	name = "USSP large thruster"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/ship_engines/frontier/thrusterussp_large.dmi'
	icon_state = "base"
	color = null
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	engine_size = 2
	generated_thrust = 9
	active_power_usage = 11000
	idle_power_usage = 1500
	max_integrity = 1100
	side_thrust_fraction = 0
	integrated_exhaust = TRUE
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

/obj/item/circuitboard/ship_engine_ion/ussp_large
	desc = "TEMP123TEMP"
	board_name = "USSP large thruster"
	build_path = /obj/machinery/ship_engine/ussp_large
	req_components = list(/obj/item/stock_parts/capacitor = 4, /obj/item/stock_parts/micro_laser = 2, /obj/item/stack/cable_coil = 10)
