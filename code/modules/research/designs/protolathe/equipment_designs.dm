/////////////////////////////////////////
/////////////////Equipment///////////////
/////////////////////////////////////////
/datum/design/exwelder
	id = "exwelder"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_BLUESPACE = 3, RESEARCH_TREE_PLASMA = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_PLASMA = 1500, MAT_URANIUM = 200)
	build_path = /obj/item/weldingtool/experimental
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/rcd
	id = "rcd"
	req_tech = list(RESEARCH_TREE_MATERIALS = 1, RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_PROGRAMMING = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30000)
	build_path = /obj/item/rcd
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/health_hud
	id = "health_hud"
	req_tech = list(RESEARCH_TREE_BIOTECH = 2, RESEARCH_TREE_MAGNETS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/health
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/health_hud_night
	id = "health_hud_night"
	req_tech = list(RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_PLASMA = 4, RESEARCH_TREE_ENGINEERING = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_SILVER = 350)
	build_path = /obj/item/clothing/glasses/hud/health/night
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/magboots
	id = "magboots"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_ENGINEERING = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/clothing/shoes/magboots
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/night_vision_goggles
	id = "night_vision_goggles"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_PLASMA = 4, RESEARCH_TREE_ENGINEERING = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_PLASMA = 350, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/night
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/security_hud
	id = "security_hud"
	req_tech = list(RESEARCH_TREE_MAGNETS = 3, RESEARCH_TREE_COMBAT = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/security
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/security_hud_night
	id = "security_hud_night"
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_PLASMA = 4, RESEARCH_TREE_ENGINEERING = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_GOLD = 350)
	build_path = /obj/item/clothing/glasses/hud/security/night
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/skills_hud
	id = "skills_hud"
	req_tech = list(RESEARCH_TREE_MAGNETS = 3, RESEARCH_TREE_COMBAT = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/skills
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/mesons
	id = "mesons"
	req_tech = list(RESEARCH_TREE_MAGNETS = 2, RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_PLASMA = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/meson
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/nvgmesons
	id = "nvgmesons"
	req_tech = list(RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_PLASMA = 5, RESEARCH_TREE_ENGINEERING = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_PLASMA = 350, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/meson/night
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/air_horn
	id = "air_horn"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_ENGINEERING = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_BANANIUM = 1000)
	build_path = /obj/item/bikehorn/airhorn
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/breath_mask
	id = "breathmask"
	req_tech = list(RESEARCH_TREE_TOXINS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 200)
	build_path = /obj/item/clothing/mask/breath
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/welding_mask
	id = "weldingmask"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_TOXINS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 2000)
	build_path = /obj/item/clothing/mask/gas/welding
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/portaseeder
	build_type = PROTOLATHE
	id = "portaseeder"
	req_tech = list(RESEARCH_TREE_BIOTECH = 3, RESEARCH_TREE_ENGINEERING = 2)
	materials = list(MAT_METAL = 1000, MAT_GLASS = 400)
	build_path = /obj/item/storage/bag/plants/portaseeder
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/sci_goggles
	id = "scigoggles"
	req_tech = list(RESEARCH_TREE_MAGNETS = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/science
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/nv_sci_goggles
	id = "nvscigoggles"
	req_tech = list(RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_PLASMA = 4, RESEARCH_TREE_ENGINEERING = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 250, MAT_GLASS = 300, MAT_PLASMA = 250, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/science/night
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/diagnostic_hud
	id = "dianostic_hud"
	req_tech = list(RESEARCH_TREE_MAGNETS = 3, RESEARCH_TREE_ENGINEERING = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/diagnostic
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/diagnostic_hud_night
	id = "dianostic_hud_night"
	req_tech = list(RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_PLASMA = 4, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_POWERSTORAGE = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_PLASMA = 300)
	build_path = /obj/item/clothing/glasses/hud/diagnostic/night
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/hydroponic_hud
	id = "hydroponic_hud"
	req_tech = list(RESEARCH_TREE_MAGNETS = 3, RESEARCH_TREE_BIOTECH = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 250)
	build_path = /obj/item/clothing/glasses/hud/hydroponic
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/hydroponic_hud_night
	id = "hydroponic_hud_night"
	req_tech = list(RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_PLASMA = 4, RESEARCH_TREE_ENGINEERING = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 250, MAT_URANIUM = 1000, MAT_PLASMA = 200)
	build_path = /obj/item/clothing/glasses/hud/hydroponic/night
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/small_crowbar
	id = "small_crowbar"
	req_tech = list(RESEARCH_TREE_MATERIALS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_TITANIUM = 1000)
	build_path = /obj/item/crowbar/small
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/handdrill
	id = "handdrill"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_ENGINEERING = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3500, MAT_SILVER = 1500, MAT_TITANIUM = 2500)
	build_path = /obj/item/screwdriver/power
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/jawsoflife
	id = "jawsoflife"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MAGNETS = 6) // added one more requirment since the Jaws of Life are a bit OP
	build_path = /obj/item/crowbar/power
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 2500, MAT_TITANIUM = 3500)
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/alienwrench
	id = "alien_wrench"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ALIEN = 4)
	build_path = /obj/item/wrench/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/alienwirecutters
	id = "alien_wirecutters"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ALIEN = 4)
	build_path = /obj/item/wirecutters/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/alienscrewdriver
	id = "alien_screwdriver"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ALIEN = 4)
	build_path = /obj/item/screwdriver/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/aliencrowbar
	id = "alien_crowbar"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ALIEN = 4)
	build_path = /obj/item/crowbar/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/alienwelder
	id = "alien_welder"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_PLASMA = 5, RESEARCH_TREE_ALIEN = 4)
	build_path = /obj/item/weldingtool/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 5000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/alienmultitool
	id = "alien_multitool"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_ALIEN = 4)
	build_path = /obj/item/multitool/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 5000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/bluespace_closet
	id = "bluespace_closet"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_BLUESPACE = 5, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_PLASMA = 3)
	build_path = /obj/structure/closet/bluespace
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_PLASMA = 2500, MAT_TITANIUM = 500, MAT_BLUESPACE = 500)
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/atmos_holofan
	id = "signmaker_atmos"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 7, RESEARCH_TREE_PROGRAMMING = 6, RESEARCH_TREE_BLUESPACE = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/holosign_creator/atmos
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/sec_tray_scanner
	id = "sec_tray"
	req_tech = list(RESEARCH_TREE_MAGNETS = 7, RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_ENGINEERING = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_DIAMOND = 500)
	build_path = /obj/item/t_scanner/security
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/gravboots
	id = "gravboots"
	req_tech = list(RESEARCH_TREE_MAGNETS = 7,RESEARCH_TREE_ENGINEERING = 7, RESEARCH_TREE_MATERIALS = 7)
	build_type = PROTOLATHE
	materials = list(MAT_PLASMA = 4000, MAT_SILVER = 4000, MAT_TITANIUM = 6000, MAT_URANIUM = 4000)
	build_path = /obj/item/clothing/shoes/magboots/gravity

/datum/design/tray_scanner_range
	id = "tray_range"
	req_tech = list(RESEARCH_TREE_MAGNETS = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500, MAT_DIAMOND = 200)
	build_path = /obj/item/t_scanner/extended_range
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/tray_scanner_pulse
	id = "tray_pulse"
	req_tech = list(RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_ENGINEERING = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500, MAT_DIAMOND = 200)
	build_path = /obj/item/t_scanner/longer_pulse
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/tray_scanner_advanced
	id = "tray_advanced"
	req_tech = list(RESEARCH_TREE_MAGNETS = 7, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_ENGINEERING = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 1000, MAT_DIAMOND = 500)
	build_path = /obj/item/t_scanner/advanced
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/tray_scanner_science
	id = "tray_science"
	req_tech = list(RESEARCH_TREE_MAGNETS = 8, RESEARCH_TREE_PROGRAMMING = 7, RESEARCH_TREE_ENGINEERING = 7) // придется постараться чтобы найти 8-й уровень технологий
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 2000, MAT_DIAMOND = 1500)
	build_path = /obj/item/t_scanner/science
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/holotool
	id = "holotool"
	req_tech = null //only from disks
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 2000, MAT_TITANIUM = 4000, MAT_DIAMOND = 2000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/holotool
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)

/datum/design/atmos_goggles
	id = "atmos_goggles"
	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_MAGNETS = 2, RESEARCH_TREE_ENGINEERING = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/meson/atmos
	category = list(PROTOLATHE_CATEGORY_EQUIPMENT)
