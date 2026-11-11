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
