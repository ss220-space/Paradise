/////////////////////////////////////////
///////////Janitorial Designs////////////
/////////////////////////////////////////
/datum/design/advmop
	id = "advmop"
	req_tech = list("materials" = 4, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500, MAT_GLASS = 200)
	build_path = /obj/item/mop/advanced
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)

/datum/design/bluespace_cleaner
	id = "bluespace_cleaner"
	req_tech = list("materials" = 5, "bluespace" = 5,"plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_PLASMA = 1300, MAT_GLASS = 1400, MAT_DIAMOND = 100, MAT_BLUESPACE = 100)
	build_path = /obj/item/reagent_containers/spray/blue_cleaner
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)

/datum/design/blutrash
	id = "blutrash"
	req_tech = list("materials" = 5, "bluespace" = 4, "engineering" = 4, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_URANIUM = 250, MAT_PLASMA = 1500, MAT_BLUESPACE = 50)
	build_path = /obj/item/storage/bag/trash/bluespace
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)

/datum/design/buffer
	id = "buffer"
	req_tech = list("materials" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 200)
	build_path = /obj/item/janiupgrade
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)

/datum/design/holosign
	id = "holosign"
	req_tech = list("programming" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/holosign_creator/janitor
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)

/datum/design/light_replacer
	id = "light_replacer"
	req_tech = list("magnets" = 3, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_GLASS = 3000)
	build_path = /obj/item/lightreplacer
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)

/datum/design/light_replacer_bluespace
	id = "light_replacer_bluespace"
	req_tech = list("bluespace" = 7, "materials" = 5, "engineering" = 6, "plasmatech" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_GLASS = 6000, MAT_BLUESPACE = 300)
	build_path = /obj/item/lightreplacer/bluespace
	category = list(PROTOLATHE_CATEGORY_JANITORIAL)
