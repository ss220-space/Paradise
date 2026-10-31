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

/datum/design/ship_engine_ion
	id = "ship_engine_ion"
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/ship_engine_ion
	materials = list(MAT_GLASS = 1000)
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 2, RESEARCH_TREE_POWERSTORAGE = 2)
	category = list(CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING)

/datum/design/ship_engine_ion/large
	id = "ship_engine_ion_large"
	build_path = /obj/item/circuitboard/ship_engine_ion/large

/datum/design/ship_engine_plasma
	id = "ship_engine_plasma"
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/ship_engine_plasma
	materials = list(MAT_GLASS = 1000)
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 2, RESEARCH_TREE_PLASMA = 3)
	category = list(CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING)

/datum/design/ship_engine_plasma/large
	id = "ship_engine_plasma_large"
	build_path = /obj/item/circuitboard/ship_engine_plasma/large

/datum/design/ship_engine_mount
	id = "ship_engine_mount"
	build_type = PROTOLATHE
	build_path = /obj/item/ship_engine_mount
	materials = list(MAT_METAL = 2000, MAT_GLASS = 500)
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_POWERSTORAGE = 2)
	category = list(PROTOLATHE_CATEGORY_POWER)

/datum/design/ship_engine_mount/rcs
	id = "ship_engine_mount_rcs"
	build_path = /obj/item/ship_engine_mount/rcs
