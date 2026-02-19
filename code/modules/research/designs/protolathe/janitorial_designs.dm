/////////////////////////////////////////
///////////Janitorial Designs////////////
/////////////////////////////////////////
/datum/design/advmop
	id = "advmop"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_ENGINEERING = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500, MAT_GLASS = 200)
	build_path = /obj/item/mop/advanced
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)

/datum/design/bluespace_cleaner
	id = "bluespace_cleaner"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_BLUESPACE = 5,RESEARCH_TREE_PLASMA = 3)
	build_type = PROTOLATHE
	materials = list(MAT_PLASMA = 1300, MAT_GLASS = 1400, MAT_DIAMOND = 100, MAT_BLUESPACE = 100)
	build_path = /obj/item/reagent_containers/spray/blue_cleaner
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)

/datum/design/blutrash
	id = "blutrash"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_BLUESPACE = 4, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_PLASMA = 3)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_URANIUM = 250, MAT_PLASMA = 1500, MAT_BLUESPACE = 50)
	build_path = /obj/item/storage/bag/trash/bluespace
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)

/datum/design/buffer
	id = "buffer"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_ENGINEERING = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 200)
	build_path = /obj/item/janiupgrade
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)

/datum/design/holosign
	id = "holosign"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/holosign_creator/janitor
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)

/datum/design/light_replacer
	id = "light_replacer"
	req_tech = list(RESEARCH_TREE_MAGNETS = 3, RESEARCH_TREE_ENGINEERING = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_GLASS = 3000)
	build_path = /obj/item/lightreplacer
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)

/datum/design/light_replacer_bluespace
	id = "light_replacer_bluespace"
	req_tech = list(RESEARCH_TREE_BLUESPACE = 7, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_PLASMA = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_GLASS = 6000, MAT_BLUESPACE = 300)
	build_path = /obj/item/lightreplacer/bluespace
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)
