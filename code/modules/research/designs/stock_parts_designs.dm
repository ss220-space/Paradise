////////////////////////////////////////
/////////////Stock Parts////////////////
////////////////////////////////////////

//Tier 1 Parts

/datum/design/basic_capacitor
	id = "basic_capacitor"
	req_tech = list("powerstorage" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/stock_parts/capacitor
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS, AUTOLATHE_CATEGORY_MACHINERY, PRINTER_CATEGORY_INITIAL)
	lathe_time_factor = 0.2

/datum/design/basic_sensor
	id = "basic_sensor"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 50)
	build_path = /obj/item/stock_parts/scanning_module
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS, AUTOLATHE_CATEGORY_MACHINERY, PRINTER_CATEGORY_INITIAL)
	lathe_time_factor = 0.2

/datum/design/micro_mani
	id = "micro_mani"
	req_tech = list("materials" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 100)
	build_path = /obj/item/stock_parts/manipulator
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS, AUTOLATHE_CATEGORY_MACHINERY, PRINTER_CATEGORY_INITIAL)
	lathe_time_factor = 0.2

/datum/design/basic_micro_laser
	id = "basic_micro_laser"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 50)
	build_path = /obj/item/stock_parts/micro_laser
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS, AUTOLATHE_CATEGORY_MACHINERY, PRINTER_CATEGORY_INITIAL)
	lathe_time_factor = 0.2

/datum/design/basic_matter_bin
	id = "basic_matter_bin"
	req_tech = list("materials" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 100)
	build_path = /obj/item/stock_parts/matter_bin
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS, AUTOLATHE_CATEGORY_MACHINERY, PRINTER_CATEGORY_INITIAL)
	lathe_time_factor = 0.2

// Tier 2 Parts

/datum/design/adv_capacitor
	id = "adv_capacitor"
	req_tech = list("powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 150)
	build_path = /obj/item/stock_parts/capacitor/adv
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

/datum/design/adv_sensor
	id = "adv_sensor"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 100)
	build_path = /obj/item/stock_parts/scanning_module/adv
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

/datum/design/nano_mani
	id = "nano_mani"
	req_tech = list("materials" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 150)
	build_path = /obj/item/stock_parts/manipulator/nano
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

/datum/design/high_micro_laser
	id = "high_micro_laser"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 100)
	build_path = /obj/item/stock_parts/micro_laser/high
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

/datum/design/adv_matter_bin
	id = "adv_matter_bin"
	req_tech = list("materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 150)
	build_path = /obj/item/stock_parts/matter_bin/adv
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

// Tier 3 Parts

/datum/design/super_capacitor
	id = "super_capacitor"
	req_tech = list("powerstorage" = 5, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_GOLD = 100)
	build_path = /obj/item/stock_parts/capacitor/super
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

/datum/design/phasic_sensor
	id = "phasic_sensor"
	req_tech = list("magnets" = 5, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 150, MAT_SILVER = 60)
	build_path = /obj/item/stock_parts/scanning_module/phasic
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

/datum/design/pico_mani
	id = "pico_mani"
	req_tech = list("materials" = 5, "programming" = 4, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200)
	build_path = /obj/item/stock_parts/manipulator/pico
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

/datum/design/ultra_micro_laser
	id = "ultra_micro_laser"
	req_tech = list("magnets" = 5, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 150, MAT_URANIUM = 60)
	build_path = /obj/item/stock_parts/micro_laser/ultra
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

/datum/design/super_matter_bin
	id = "super_matter_bin"
	req_tech = list("materials" = 5, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200)
	build_path = /obj/item/stock_parts/matter_bin/super
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

//Tier 4 Parts

/datum/design/quadratic_capacitor
	id = "quadratic_capacitor"
	req_tech = list("powerstorage" = 6, "engineering" = 5, "materials" = 5, "bluespace" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_GOLD = 100, MAT_DIAMOND = 100)
	build_path = /obj/item/stock_parts/capacitor/quadratic
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

/datum/design/triphasic_scanning
	id = "triphasic_scanning"
	req_tech = list("magnets" = 6, "materials" = 5, "engineering" = 5, "bluespace" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_DIAMOND = 30, MAT_BLUESPACE = 30)
	build_path = /obj/item/stock_parts/scanning_module/triphasic
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

/datum/design/femto_mani
	id = "femto_mani"
	req_tech = list("materials" = 7, "programming" = 5, "engineering" = 5, "bluespace" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_DIAMOND = 30, MAT_TITANIUM = 30)
	build_path = /obj/item/stock_parts/manipulator/femto
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

/datum/design/quadultra_micro_laser
	id = "quadultra_micro_laser"
	req_tech = list("magnets" = 6, "materials" = 5, "engineering" = 5, "bluespace" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_URANIUM = 100, MAT_DIAMOND = 60)
	build_path = /obj/item/stock_parts/micro_laser/quadultra
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

/datum/design/bluespace_matter_bin
	id = "bluespace_matter_bin"
	req_tech = list("materials" = 7, "engineering" = 5, "bluespace" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 250, MAT_DIAMOND = 100, MAT_BLUESPACE = 100)
	build_path = /obj/item/stock_parts/matter_bin/bluespace
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 0.2

/datum/design/RPED
	id = "rped"
	req_tech = list("engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000)
	build_path = /obj/item/storage/part_replacer
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)

/datum/design/BS_RPED
	id = "bs_rped"
	req_tech = list("engineering" = 4, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 15000, MAT_GLASS = 5000, MAT_SILVER = 2500)
	build_path = /obj/item/storage/part_replacer/bluespace
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
