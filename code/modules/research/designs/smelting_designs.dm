///////SMELTABLE ALLOYS///////

/datum/design/smelter
	build_type = SMELTER

/datum/design/smelter/plasteel_alloy
	id = "plasteel"
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasteel
	category = list(PRINTER_CATEGORY_INITIAL)

/datum/design/smelter/plastitanium_alloy
	id = "plastitanium"
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/plastitanium
	category = list(PRINTER_CATEGORY_INITIAL)

/datum/design/smelter/plaglass_alloy
	id = "plasmaglass"
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasmaglass
	category = list(PRINTER_CATEGORY_INITIAL)

/datum/design/smelter/titaniumglass_alloy
	id = "titaniumglass"
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/titaniumglass
	category = list(PRINTER_CATEGORY_INITIAL)

/datum/design/smelter/plastitaniumglass_alloy
	id = "plastitaniumglass"
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT, MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plastitaniumglass
	category = list(PRINTER_CATEGORY_INITIAL)

/datum/design/smelter/alienalloy
	id = "alienalloy"
	req_tech = list("abductor" = 1, "materials" = 7, "plasmatech" = 2)
	build_type = PROTOLATHE | SMELTER
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 4000)
	build_path = /obj/item/stack/sheet/mineral/abductor
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 5

/datum/design/smelter/alienglass
	id = "alienglass"
	req_tech = list("abductor" = 1, "materials" = 7, "plasmatech" = 2)
	build_type = PROTOLATHE | SMELTER
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 4000, MAT_GLASS = 4000)
	build_path = /obj/item/stack/sheet/abductorglass
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 5
