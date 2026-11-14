/obj/item/circuitboard/ship_engine_ion
	board_name = "Small ion engine"
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/ship_engine/ion
	req_components = list(/obj/item/stock_parts/capacitor = 2, /obj/item/stock_parts/micro_laser = 1, /obj/item/stack/cable_coil = 5)

/obj/item/circuitboard/ship_engine_ion/large
	board_name = "Large ion engine"
	build_path = /obj/machinery/ship_engine/ion/large
	req_components = list(/obj/item/stock_parts/capacitor = 4, /obj/item/stock_parts/micro_laser = 2, /obj/item/stack/cable_coil = 10)

/obj/item/circuitboard/ship_engine_plasma
	board_name = "Small plasma engine"
	board_type = "machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/ship_engine/plasma
	req_components = list(/obj/item/stock_parts/matter_bin = 2, /obj/item/stock_parts/micro_laser = 2, /obj/item/stack/cable_coil = 5)

/obj/item/circuitboard/ship_engine_plasma/large
	board_name = "Large plasma engine"
	build_path = /obj/machinery/ship_engine/plasma/large
	req_components = list(/obj/item/stock_parts/matter_bin = 4, /obj/item/stock_parts/micro_laser = 4, /obj/item/stack/cable_coil = 10)

/obj/item/ship_engine_mount
	name = "ion maneuvering thruster assembly"
	desc = "Установите снаружи на стену корабля. Сопло будет направлено от стены к вам."
	icon = 'icons/obj/machines/ship_thruster.dmi'
	icon_state = "thruster"
	w_class = WEIGHT_CLASS_BULKY
	var/engine_type = /obj/machinery/ship_engine/thruster

/obj/item/ship_engine_mount/rcs
	name = "RCS thruster assembly"
	engine_type = /obj/machinery/ship_engine/thruster/rcs
	color = "#a7dfff"

/obj/item/ship_engine_mount/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!iswallturf(target) || !proximity_flag)
		return
	var/turf/wall = target
	var/turf/standing = SSovermap.mirror_turf(get_turf(user), wall) || get_turf(user)
	var/exhaust_dir = get_dir(wall, standing)
	if(!(exhaust_dir in GLOB.cardinal) || !isspaceturf(get_step(wall, exhaust_dir)))
		to_chat(user, span_warning("Встаньте снаружи напротив стены."))
		return
	if(locate(/obj/machinery/ship_engine/thruster) in wall)
		return
	if(!do_after(user, 2 SECONDS, target = wall))
		return
	if(!iswallturf(wall) || !isspaceturf(get_step(wall, exhaust_dir)))
		return
	if(locate(/obj/machinery/ship_engine/thruster) in wall)
		return
	var/obj/machinery/ship_engine/engine = new engine_type(wall)
	engine.setDir(exhaust_dir)
	qdel(src)

/obj/machinery/ship_engine/thruster/wrench_act(mob/living/user, obj/item/tool)
	if(firing || !tool.use_tool(src, user, 2 SECONDS, volume = tool.tool_volume))
		return TRUE
	if(istype(src, /obj/machinery/ship_engine/thruster/rcs))
		new /obj/item/ship_engine_mount/rcs(get_turf(user))
	else
		new /obj/item/ship_engine_mount(get_turf(user))
	qdel(src)
	return TRUE

/obj/item/circuitboard/ship_engine_ion/frontier_large
	desc = "TEMP123TEMP"
	board_name = "Frontier large thruster"
	build_path = /obj/machinery/ship_engine/frontier_large
	req_components = list(/obj/item/stock_parts/capacitor = 4, /obj/item/stock_parts/micro_laser = 2, /obj/item/stack/cable_coil = 10)

/obj/item/circuitboard/ship_engine_ion/nfsd_large
	desc = "TEMP123TEMP"
	board_name = "NFSD large thruster"
	build_path = /obj/machinery/ship_engine/nfsd_large
	req_components = list(/obj/item/stock_parts/capacitor = 4, /obj/item/stock_parts/micro_laser = 2, /obj/item/stack/cable_coil = 10)

/obj/item/circuitboard/ship_engine_ion/rogue
	desc = "TEMP123TEMP"
	board_name = "Rogue thruster"
	build_path = /obj/machinery/ship_engine/rogue
	req_components = list(/obj/item/stock_parts/capacitor = 2, /obj/item/stock_parts/micro_laser = 1, /obj/item/stack/cable_coil = 5)

/obj/item/circuitboard/ship_engine_ion/rogue_large
	desc = "TEMP123TEMP"
	board_name = "Rogue large thruster"
	build_path = /obj/machinery/ship_engine/rogue_large
	req_components = list(/obj/item/stock_parts/capacitor = 4, /obj/item/stock_parts/micro_laser = 2, /obj/item/stack/cable_coil = 10)

/obj/item/circuitboard/ship_engine_ion/ussp
	desc = "TEMP123TEMP"
	board_name = "USSP thruster"
	build_path = /obj/machinery/ship_engine/ussp
	req_components = list(/obj/item/stock_parts/capacitor = 2, /obj/item/stock_parts/micro_laser = 1, /obj/item/stack/cable_coil = 5)

/obj/item/circuitboard/ship_engine_ion/ussp_large
	desc = "TEMP123TEMP"
	board_name = "USSP large thruster"
	build_path = /obj/machinery/ship_engine/ussp_large
	req_components = list(/obj/item/stock_parts/capacitor = 4, /obj/item/stock_parts/micro_laser = 2, /obj/item/stack/cable_coil = 10)
