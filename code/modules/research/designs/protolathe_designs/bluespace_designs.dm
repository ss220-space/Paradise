/////////////////////////////////////////
//////////////Bluespace//////////////////
/////////////////////////////////////////
/datum/design/bluespace_crystal
	id = "bluespace_crystal"
	req_tech = list("bluespace" = 3, "materials" = 6, "plasmatech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 1500, MAT_PLASMA = 1500)
	build_path = /obj/item/stack/ore/bluespace_crystal/artificial
	category = list(PROTOLATHE_CATEGORY_BLUESPACE)

/datum/design/bag_holding
	id = "bag_holding"
	req_tech = list("bluespace" = 6, "materials" = 5, "engineering" = 5, "plasmatech" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 3000, MAT_DIAMOND = 1500, MAT_URANIUM = 250, MAT_BLUESPACE = 2000)
	build_path = /obj/item/storage/backpack/holding
	category = list(PROTOLATHE_CATEGORY_BLUESPACE)

/datum/design/sat_holding
	id = "sat_holding"
	req_tech = list("bluespace" = 6, "materials" = 5, "engineering" = 5, "plasmatech" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 3000, MAT_DIAMOND = 1500, MAT_URANIUM = 250, MAT_BLUESPACE = 2000)
	build_path = /obj/item/storage/backpack/holding/satchel
	category = list(PROTOLATHE_CATEGORY_BLUESPACE)

/datum/design/bluespace_belt
	id = "bluespace_belt"
	req_tech = list("bluespace" = 6, "materials" = 5, "engineering" = 5, "plasmatech" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_DIAMOND = 3000, MAT_URANIUM = 1000, MAT_BLUESPACE = 400)
	build_path = /obj/item/storage/belt/bluespace
	category = list(PROTOLATHE_CATEGORY_BLUESPACE)

/datum/design/telesci_gps
	id = "telesci_Gps"
	req_tech = list("materials" = 2, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 1000)
	build_path = /obj/item/gps
	category = list(PROTOLATHE_CATEGORY_BLUESPACE)

/datum/design/miningsatchel_holding
	id = "minerbag_holding"
	req_tech = list("bluespace" = 4, "materials" = 3, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 250, MAT_URANIUM = 500, MAT_BLUESPACE = 150) //quite cheap, for more convenience
	build_path = /obj/item/storage/bag/ore/holding
	category = list(PROTOLATHE_CATEGORY_BLUESPACE)

/datum/design/bluespace_belt_holder
	id = "bluespace_belt_holder"
	req_tech = list("materials" = 1, "engineering" = 3, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_SILVER = 500) //Costs similar materials to the basic one, but this one needs silver
	build_path = /obj/item/storage/conveyor/bluespace
	category = list(PROTOLATHE_CATEGORY_BLUESPACE)

/datum/design/telepad_beacon
	id = "telepad_beacon"
	req_tech = list("programming" = 5, "bluespace" = 4, "engineering" = 4, "plasmatech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1750, MAT_SILVER = 500)
	build_path = /obj/item/telepad_beacon
	category = list(PROTOLATHE_CATEGORY_BLUESPACE)

/datum/design/beacon
	id = "beacon"
	req_tech = list("bluespace" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 100)
	build_path = /obj/item/beacon
	category = list(PROTOLATHE_CATEGORY_BLUESPACE)

/datum/design/brpd
	req_tech = list("bluespace" = 3, "toxins" = 6)
	id = "brpd"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 75000, MAT_GLASS = 37500, MAT_SILVER = 3000)
	build_path = /obj/item/rpd/bluespace
	category = list(PROTOLATHE_CATEGORY_BLUESPACE)
