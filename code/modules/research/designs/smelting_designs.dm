///////SMELTABLE ALLOYS///////

/datum/design/smelter
	build_type = SMELTER

/datum/design/smelter/plasteel_alloy
	desc = "Плазма + Сталь"
	id = "plasteel"
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasteel
	category = list(PRINTER_CATEGORY_INITIAL)

/datum/design/smelter/plastitanium_alloy
	desc = "Плазма + Титан"
	id = "plastitanium"
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/plastitanium
	category = list(PRINTER_CATEGORY_INITIAL)

/datum/design/smelter/plaglass_alloy
	desc = "Плазма + Стекло"
	id = "plasmaglass"
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasmaglass
	category = list(PRINTER_CATEGORY_INITIAL)

/datum/design/smelter/titaniumglass_alloy
	desc = "Титан + Стекло"
	id = "titaniumglass"
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/titaniumglass
	category = list(PRINTER_CATEGORY_INITIAL)

/datum/design/smelter/plastitaniumglass_alloy
	desc = "Плазма + Титан + Стекло"
	id = "plastitaniumglass"
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT, MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plastitaniumglass
	category = list(PRINTER_CATEGORY_INITIAL)

/datum/design/smelter/alienalloy
	id = "alienalloy"
	req_tech = list(RESEARCH_TREE_ALIEN = 1, RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_PLASMA = 2)
	build_type = PROTOLATHE | SMELTER
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 4000)
	build_path = /obj/item/stack/sheet/mineral/abductor
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 5

/datum/design/smelter/alienglass
	id = "alienglass"
	req_tech = list(RESEARCH_TREE_ALIEN = 1, RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_PLASMA = 2)
	build_type = PROTOLATHE | SMELTER
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 4000, MAT_GLASS = 4000)
	build_path = /obj/item/stack/sheet/abductorglass
	category = list(PROTOLATHE_CATEGORY_STOCK_PARTS)
	lathe_time_factor = 5
