/////////////////////////////////////////
////////////Power Designs////////////////
/////////////////////////////////////////

/datum/design/basic_cell
	id = "basic_cell"
	req_tech = list(RESEARCH_TREE_POWERSTORAGE = 1)
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB | PODFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 50)
	construction_time = 100
	build_path = /obj/item/stock_parts/cell
	category = list(AUTOLATHE_CATEGORY_MISC, PROTOLATHE_CATEGORY_POWER, AUTOLATHE_CATEGORY_MACHINERY, PRINTER_CATEGORY_INITIAL)

/datum/design/high_cell
	id = "high_cell"
	req_tech = list(RESEARCH_TREE_POWERSTORAGE = 2)
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB | PODFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 60)
	construction_time = 100
	build_path = /obj/item/stock_parts/cell/high
	category = list(AUTOLATHE_CATEGORY_MISC, PROTOLATHE_CATEGORY_POWER)

/datum/design/hyper_cell
	id = "hyper_cell"
	req_tech = list(RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ENGINEERING = 5)
	build_type = PROTOLATHE | MECHFAB | PODFAB
	materials = list(MAT_METAL = 700, MAT_GOLD = 150, MAT_SILVER = 150, MAT_GLASS = 400)
	construction_time = 100
	build_path = /obj/item/stock_parts/cell/hyper
	category = list(AUTOLATHE_CATEGORY_MISC, PROTOLATHE_CATEGORY_POWER)

/datum/design/super_cell
	id = "super_cell"
	req_tech = list(RESEARCH_TREE_POWERSTORAGE = 3, RESEARCH_TREE_MATERIALS = 3)
	build_type = PROTOLATHE | MECHFAB | PODFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 300)
	construction_time = 100
	build_path = /obj/item/stock_parts/cell/super
	category = list(AUTOLATHE_CATEGORY_MISC, PROTOLATHE_CATEGORY_POWER)

/datum/design/bluespace_cell
	id = "bluespace_cell"
	req_tech = list(RESEARCH_TREE_POWERSTORAGE = 6, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_BLUESPACE = 5)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 800, MAT_GOLD = 120, MAT_GLASS = 600, MAT_DIAMOND = 160, MAT_TITANIUM = 300, MAT_BLUESPACE = 100)
	construction_time = 100
	build_path = /obj/item/stock_parts/cell/bluespace
	category = list(AUTOLATHE_CATEGORY_MISC, PROTOLATHE_CATEGORY_POWER)

/datum/design/pacman
	id = "pacman"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 2, RESEARCH_TREE_PLASMA = 3, RESEARCH_TREE_POWERSTORAGE = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/pacman
	category = list(CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING)

/datum/design/mrspacman
	id = "mrspacman"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_PLASMA = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/pacman/mrs
	category = list(CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING)

/datum/design/superpacman
	id = "superpacman"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_ENGINEERING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/pacman/super
	category = list(CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING)

/datum/design/tesla_coil
	id = "tesla_coil"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_POWERSTORAGE = 3, RESEARCH_TREE_MAGNETS = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/tesla_coil
	category = list(CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING)

/datum/design/grounding_rod
	id = "grounding_rod"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_POWERSTORAGE = 3, RESEARCH_TREE_MAGNETS = 3, RESEARCH_TREE_PLASMA = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/grounding_rod
	category = list(
		CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING,
	)

/datum/design/diode_disk_stamina
	id = "diode_disk_stamina"
	build_type = PROTOLATHE
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_PLASMA = 5)
	materials = list(MAT_METAL = SMALL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = SMALL_MATERIAL_AMOUNT, MAT_GOLD = SMALL_MATERIAL_AMOUNT)
	construction_time = 0.5 SECONDS
	build_path = /obj/item/emitter_disk/stamina
	category = list(
		PROTOLATHE_CATEGORY_EQUIPMENT,
	)

/datum/design/diode_disk_healing
	id = "diode_disk_healing"
	build_type = PROTOLATHE
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_BIOTECH = 5)
	materials = list(MAT_METAL = SMALL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = SMALL_MATERIAL_AMOUNT, MAT_SILVER = SMALL_MATERIAL_AMOUNT) //silver is medical metal. Why? who knows.
	construction_time = 0.5 SECONDS
	build_path = /obj/item/emitter_disk/healing
	category = list(
		PROTOLATHE_CATEGORY_EQUIPMENT,
	)

/datum/design/diode_disk_incendiary
	id = "diode_disk_incendiary"
	build_type = PROTOLATHE
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_POWERSTORAGE = 5)
	materials = list(MAT_METAL = SMALL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = SMALL_MATERIAL_AMOUNT, MAT_DIAMOND = SMALL_MATERIAL_AMOUNT * 0.5, MAT_PLASMA = SMALL_MATERIAL_AMOUNT * 2)
	construction_time = 0.5 SECONDS
	build_path = /obj/item/emitter_disk/incendiary
	category = list(
		PROTOLATHE_CATEGORY_EQUIPMENT,
	)

/datum/design/diode_disk_sanity
	id = "diode_disk_sanity"
	build_type = PROTOLATHE
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_ENGINEERING = 5)
	materials = list(MAT_METAL = SMALL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = SMALL_MATERIAL_AMOUNT, MAT_URANIUM = SMALL_MATERIAL_AMOUNT * 0.5) //Uranium, the metal of love and warmth (from decay heat).
	construction_time = 0.5 SECONDS
	build_path = /obj/item/emitter_disk/sanity
	category = list(
		PROTOLATHE_CATEGORY_EQUIPMENT,
	)

/datum/design/diode_disk_magnetic
	id = "diode_disk_magnetic"
	build_type = PROTOLATHE
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_MAGNETS = 5)
	materials = list(MAT_METAL = SMALL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = SMALL_MATERIAL_AMOUNT, MAT_TITANIUM = SMALL_MATERIAL_AMOUNT * 0.5)
	construction_time = 0.5 SECONDS
	build_path = /obj/item/emitter_disk/magnetic
	category = list(
		PROTOLATHE_CATEGORY_EQUIPMENT,
	)

/datum/design/diode_disk_blast
	id = "diode_disk_blast"
	build_type = PROTOLATHE
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_ILLEGAL = 5, RESEARCH_TREE_ENGINEERING = 5)
	materials = list(
		MAT_METAL = SMALL_MATERIAL_AMOUNT * 0.5,
		MAT_GLASS = SMALL_MATERIAL_AMOUNT,
		MAT_TITANIUM = SMALL_MATERIAL_AMOUNT * 0.5,
		MAT_URANIUM = SMALL_MATERIAL_AMOUNT * 0.5,
		MAT_GOLD = SMALL_MATERIAL_AMOUNT,
	)
	construction_time = 0.5 SECONDS
	build_path = /obj/item/emitter_disk/blast
	category = list(
		PROTOLATHE_CATEGORY_ILLEGAL,
	)
