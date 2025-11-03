/////////////////////////////////////////
/////////////////Misc Designs////////////
/////////////////////////////////////////
/datum/design/design_disk
	id = "design_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/design_disk
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/diskplantgene
	id = "diskplantgene"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL=200, MAT_GLASS=100)
	build_path = /obj/item/disk/plantgene
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/intellicard
	id = "intellicard"
	req_tech = list("programming" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 200)
	build_path = /obj/item/aicard
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/paicard
	id = "paicard"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500, MAT_METAL = 500)
	build_path = /obj/item/paicard
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/tech_disk
	id = "tech_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/tech_disk
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/digital_camera
	id = "digitalcamera"
	req_tech = list("programming" = 2, "materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/camera/digital
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/safety_muzzle
	id = "safetymuzzle"
	req_tech = list("materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	build_path = /obj/item/clothing/mask/muzzle/safety
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/shock_muzzle
	id = "shockmuzzle"
	req_tech = list("materials" = 1, "engineering" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	build_path = /obj/item/clothing/mask/muzzle/safety/shock
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/data_disk
	id = "datadisk"
	req_tech = list("programming" = 3, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL=300, MAT_GLASS=100)
	build_path = /obj/item/disk/data
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/emergency_oxygen
	id = "emergencyoxygen"
	req_tech = list("toxins" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL=500, MAT_GLASS=100)
	build_path = /obj/item/tank/internals/emergency_oxygen/empty
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/extended_oxygen
	id = "extendedoxygen"
	req_tech = list("toxins" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL=800, MAT_GLASS=100)
	build_path = /obj/item/tank/internals/emergency_oxygen/engi/empty
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/double_oxygen
	id = "doubleoxygen"
	req_tech = list("toxins" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL=1500, MAT_GLASS=200)
	build_path = /obj/item/tank/internals/emergency_oxygen/double/empty
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/oxygen_tank
	id = "oxygentank"
	req_tech = list("toxins" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL=3000, MAT_GLASS=500)
	build_path = /obj/item/tank/internals/oxygen/empty
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/extinguisher_cartridge
	id = "extinguishercartridge"
	req_tech = list("materials" = 5, "toxins" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL=3000, MAT_GLASS=500)
	reagents_list = list("firefighting_foam" = 1)
	build_path = /obj/item/extinguisher_refill
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/customat_canister
	id = "customat_canister"
	req_tech = list("programming" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 600)
	build_path = /obj/item/vending_refill/custom
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/translator_chip
	id = "pvr_language_chip"
	req_tech = list("materials" = 3, "programming" = 5, "abductor" = 1)
	build_type = PROTOLATHE
	build_path = /obj/item/translator_chip
	materials = list(MAT_METAL = 1000, MAT_GLASS = 100, MAT_TITANIUM = 500, MAT_PLASMA = 500, MAT_DIAMOND = 100)
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/retranslator_upgrade
	id = "pvr_storage_upgrade"
	req_tech = list("materials" = 5, "programming" = 6, "bluespace" = 6, "abductor" = 2)
	build_type = PROTOLATHE
	build_path = /obj/item/translator_upgrade/grey_retraslator
	materials = list(MAT_METAL = 1000, MAT_GLASS = 100, MAT_TITANIUM = 500, MAT_PLASMA = 500, MAT_DIAMOND = 100)
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/anomaly_stabilizer
	id = "anomaly_stabilizer"
	req_tech = list("powerstorage" = 2, "programming" = 4, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL=3000, MAT_GLASS=2000)
	build_path = /obj/item/gun/energy/anomaly_stabilizer
	category = list(PROTOLATHE_CATEGORY_MISC)

/datum/design/anomaly_analyzer
	id = "anomaly_analyzer"
	req_tech = list("programming" = 4, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL=1000, MAT_GLASS=500)
	build_path = /obj/item/anomaly_analyzer
	category = list(PROTOLATHE_CATEGORY_MISC)
