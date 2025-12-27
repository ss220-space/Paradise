/////////////////////////////////////////
///////////////////MOD///////////////////
/////////////////////////////////////////

/datum/design/mod_shell
	id = "mod_shell"
	build_type = MECHFAB
	materials = list(MAT_METAL = 10000, MAT_PLASMA = 5000)
	construction_time = 25 SECONDS
	build_path = /obj/item/mod/construction/shell
	category = list(MECH_FAB_CATEGORY_MODSUIT_CONSTRUCTION)

/datum/design/mod_helmet
	id = "mod_helmet"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/helmet
	category = list(MECH_FAB_CATEGORY_MODSUIT_CONSTRUCTION)

/datum/design/mod_chestplate
	id = "mod_chestplate"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/chestplate
	category = list(MECH_FAB_CATEGORY_MODSUIT_CONSTRUCTION)

/datum/design/mod_gauntlets
	id = "mod_gauntlets"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/gauntlets
	category = list(MECH_FAB_CATEGORY_MODSUIT_CONSTRUCTION)

/datum/design/mod_boots
	id = "mod_boots"
	build_type = MECHFAB
	materials = list(MAT_METAL = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/boots
	category = list(MECH_FAB_CATEGORY_MODSUIT_CONSTRUCTION)

/datum/design/mod_plating
	id = "mod_plating_standard"
	build_type = MECHFAB
	materials = list(MAT_METAL = 6000, MAT_GLASS = 3000, MAT_PLASMA = 1000)
	construction_time = 15 SECONDS
	build_path = /obj/item/mod/construction/plating
	category = list(MECH_FAB_CATEGORY_MODSUIT_CONSTRUCTION)

/datum/design/mod_plating/engineering
	id = "mod_plating_engineering"
	build_path = /obj/item/mod/construction/plating/engineering
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_GOLD = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_ENGINE)

/datum/design/mod_plating/atmospheric
	id = "mod_plating_atmospheric"
	build_path = /obj/item/mod/construction/plating/atmospheric
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_TITANIUM = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_ATMOSPHERICS)

/datum/design/mod_plating/medical
	id = "mod_plating_medical"
	build_path = /obj/item/mod/construction/plating/medical
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_SILVER = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_MEDICAL)

/datum/design/mod_plating/security
	id = "mod_plating_security"
	build_path = /obj/item/mod/construction/plating/security
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_URANIUM = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_ARMORY)

/datum/design/mod_plating/brig_pilot
	id = "mod_plating_brig_pilot"
	build_path = /obj/item/mod/construction/plating/brig_pilot
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_TOXINS = 3)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 4000, MAT_TITANIUM = 6000, MAT_DIAMOND = 4000, MAT_URANIUM = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_ARMORY)

/datum/design/mod_plating/rescue
	id = "mod_plating_rescue"
	build_path = /obj/item/mod/construction/plating/rescue
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_BIOTECH = 6, RESEARCH_TREE_TOXINS = 3)
	materials = list(MAT_METAL = 6000, MAT_GLASS = 4000, MAT_TITANIUM = 6000, MAT_URANIUM = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_PARAMEDIC)

/datum/design/mod_plating/security_medical
	id = "mod_plating_security_medical"
	build_path = /obj/item/mod/construction/plating/security_medical
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_TOXINS = 5)
	materials = list(MAT_METAL = 8000, MAT_GLASS = 4000, MAT_TITANIUM = 6000, MAT_URANIUM = 4000, MAT_PLASMA = 3000)
	locked = TRUE
	access_requirement = list(ACCESS_MEDICAL)

/datum/design/mod_plating/cosmohonk
	id = "mod_plating_cosmohonk"
	build_path = /obj/item/mod/construction/plating/cosmohonk
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_BANANIUM = 2000, MAT_PLASMA = 1000)
	locked = TRUE
	access_requirement = list(ACCESS_CLOWN)

/datum/design/mod_skin
	id = "mod_skin_civilian"
	build_type = MECHFAB
	materials = list(MAT_METAL = 6000, MAT_GLASS = 3000, MAT_PLASMA = 1000)
	construction_time = 5 SECONDS
	build_path = /obj/item/mod/universal_modkit
	category = list(MECH_FAB_CATEGORY_MODSUIT_CONSTRUCTION)

/datum/design/module
	id = "mod_storage"
	build_type = MECHFAB
	construction_time = 5 SECONDS
	materials = list(MAT_METAL = 2500, MAT_GLASS = 10000)
	build_path = /obj/item/mod/module/storage
	category = list(MECH_FAB_CATEGORY_MODSUIT_MODULES)

/datum/design/module/mod_storage_expanded
	id = "mod_storage_expanded"
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_POWERSTORAGE = 6, RESEARCH_TREE_ENGINEERING = 6)
	materials = list(MAT_METAL = 2500, MAT_URANIUM = 10000)
	build_path = /obj/item/mod/module/storage/large_capacity

/datum/design/module/mod_storage_syndicate
	id = "mod_storage_syndicate"
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_POWERSTORAGE = 7, RESEARCH_TREE_ENGINEERING = 7, RESEARCH_TREE_ILLEGAL = 3)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Evidence Raid  to function.
	build_path = /obj/item/mod/module/storage/syndicate

/datum/design/module/mod_visor_medhud
	id = "mod_visor_medhud"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_BIOTECH = 4)
	materials = list(MAT_SILVER = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/visor/medhud

/datum/design/module/mod_visor_diaghud
	id = "mod_visor_diaghud"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_BIOTECH = 4)
	materials = list(MAT_GOLD = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/visor/diaghud

/datum/design/module/mod_visor_sechud
	id = "mod_visor_sechud"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_COMBAT = 3)
	materials = list(MAT_TITANIUM = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/visor/sechud

/datum/design/module/mod_visor_meson
	id = "mod_visor_meson"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_ENGINEERING = 4)
	materials = list(MAT_URANIUM = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/visor/meson

/datum/design/module/mod_visor_welding
	id = "mod_welding"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_PLASMA = 4)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/welding

/datum/design/module/mod_visor_night
	id = "mod_night_visor"
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_PLASMA = 6)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000)
	build_path = /obj/item/mod/module/visor/night

/datum/design/module/mod_t_ray
	id = "mod_t_ray"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_ENGINEERING = 2)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/t_ray

/datum/design/module/mod_stealth
	id = "mod_stealth"
	req_tech = list(RESEARCH_TREE_COMBAT = 7, RESEARCH_TREE_MAGNETS = 6, RESEARCH_TREE_ILLEGAL = 3)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //It's a cloaking device, while not foolproof I am making it expencive
	build_path = /obj/item/mod/module/stealth

/datum/design/module/mod_jetpack
	id = "mod_jetpack"
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_MAGNETS = 6, RESEARCH_TREE_ENGINEERING = 6)
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000) //Jetpacks are rare, so might as well make it... sorta expencive, I guess.
	build_path = /obj/item/mod/module/jetpack

/datum/design/module/mod_magboot
	id = "mod_magboot"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_ENGINEERING = 5)
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/mod/module/magboot

/datum/design/module/mod_adv_magboot
	id = "mod_adv_magboot"
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_MAGNETS = 7, RESEARCH_TREE_ENGINEERING = 7)
	materials = list(MAT_METAL = 15000, MAT_SILVER = 5500, MAT_GOLD = 6500, MAT_TITANIUM = 6500)
	build_path = /obj/item/mod/module/magboot/advanced

/datum/design/module/mod_rad_protection
	id = "mod_rad_protection"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_COMBAT = 2)
	materials = list(MAT_URANIUM = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/rad_protection

/datum/design/module/mod_emp_shield
	id = "mod_emp_shield"
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_MAGNETS = 6, RESEARCH_TREE_ILLEGAL = 2)
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000) //While you are not EMP proof with this, your modules / cell are, and that is quite strong.
	build_path = /obj/item/mod/module/emp_shield

/datum/design/module/mod_flashlight
	id = "mod_flashlight"
	req_tech = list(RESEARCH_TREE_MAGNETS = 2, RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_PLASMA = 2)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/flashlight

/datum/design/module/mod_flashdark
	id = "mod_flashdark"
	req_tech = list(RESEARCH_TREE_MAGNETS = 2, RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_PLASMA = 2)
	materials = list(MAT_METAL = 400, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/flashlight/darkness

/datum/design/module/mod_tether
	id = "mod_tether"
	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_MAGNETS = 2, RESEARCH_TREE_ENGINEERING = 3)
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/mod/module/grappling_hook

/datum/design/module/mod_reagent_scanner
	id = "mod_reagent_scanner"
	req_tech = list(RESEARCH_TREE_MAGNETS = 2, RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_PLASMA = 2)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/reagent_scanner

/datum/design/module/mod_gps
	id = "mod_gps"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_BLUESPACE = 2)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/gps

/datum/design/module/mod_thermal_regulator
	id = "mod_thermal_regulator"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PLASMA = 4, RESEARCH_TREE_MAGNETS = 4)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000, MAT_GOLD = 2500, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/thermal_regulator

/datum/design/module/mod_injector
	id = "mod_injector"
	req_tech = list(RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_MAGNETS = 5)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/injector

/datum/design/module/mod_monitor
	id = "mod_monitor"
	req_tech = list(RESEARCH_TREE_BIOTECH = 3, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_MAGNETS = 4)
	materials = list(MAT_METAL = 1500, MAT_GLASS = 3000)
	build_path = /obj/item/mod/module/monitor

/datum/design/module/defibrillator
	id = "mod_defib"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_BIOTECH = 6, RESEARCH_TREE_POWERSTORAGE = 6)
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000, MAT_SILVER = 2000)
	build_path = /obj/item/mod/module/defibrillator

/datum/design/module/mod_bikehorn
	id = "mod_bikehorn"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_MATERIALS = 3)
	materials = list(MAT_METAL = 2500, MAT_BANANIUM = 2000)
	build_path = /obj/item/mod/module/bikehorn

/datum/design/module/mod_waddle
	id = "mod_waddle"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_MATERIALS = 3)
	materials = list(MAT_METAL = 2500, MAT_BANANIUM = 2000)
	build_path = /obj/item/mod/module/waddle

/datum/design/module/mod_clamp
	id = "mod_clamp"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_MATERIALS = 3)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/clamp

/datum/design/module/mod_drill
	id = "mod_drill"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 5)
	materials = list(MAT_METAL = 12500, MAT_DIAMOND = 4000) //This drills **really** fast
	build_path = /obj/item/mod/module/drill

/datum/design/module/mod_orebag
	id = "mod_orebag"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_POWERSTORAGE = 2, RESEARCH_TREE_ENGINEERING = 3)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/orebag

/datum/design/module/mod_dna_lock
	id = "mod_dna_lock"
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 6)
	materials = list(MAT_METAL = 12500, MAT_DIAMOND = 4000) //EMP beats it, but still, anti theft is a premium price in these here parts partner
	build_path = /obj/item/mod/module/dna_lock

/datum/design/module/mod_holster
	id = "mod_holster"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_POWERSTORAGE = 2, RESEARCH_TREE_ENGINEERING = 3)
	materials = list(MAT_METAL = 2500, MAT_GLASS = 5000)
	build_path = /obj/item/mod/module/holster

/datum/design/module/mod_sonar
	id = "mod_sonar"
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 5)
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/active_sonar

/datum/design/module/pathfinder
	id = "mod_pathfinder"
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 5)
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/pathfinder

/datum/design/module/plasma_stabilizer
	id = "mod_plasmastable"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_POWERSTORAGE = 2, RESEARCH_TREE_ENGINEERING = 3)
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000, MAT_SILVER = 2000)
	build_path = /obj/item/mod/module/plasma_stabilizer

/datum/design/module/plate_compression
	id = "mod_compression"
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_ILLEGAL = 2)
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/plate_compression

/datum/design/module/status_readout
	id = "mod_status_readout"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_BIOTECH = 6)
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000, MAT_SILVER = 2000)
	build_path = /obj/item/mod/module/status_readout

/datum/design/module/mod_teleporter
	id = "mod_teleporter"
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_BLUESPACE = 7, RESEARCH_TREE_PLASMA = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires bluespace anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/teleporter

/datum/design/module/mod_kinesis
	id = "mod_kinesis"
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_BLUESPACE = 7, RESEARCH_TREE_PLASMA = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Gravitational anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/kinesis

/datum/design/module/mod_firewall
	id = "mod_firewall"
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_BLUESPACE = 7, RESEARCH_TREE_PLASMA = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Pyroclastic anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/firewall

/datum/design/module/mod_arcshield
	id = "mod_arcshield"
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_BLUESPACE = 7, RESEARCH_TREE_PLASMA = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Flux anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/teslawall

/datum/design/module/mod_vortex
	id = "mod_vortex"
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_BLUESPACE = 7, RESEARCH_TREE_PLASMA = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) //Requires Vortex anomaly core to function.
	build_path = /obj/item/mod/module/anomaly_locked/vortex_shotgun

/datum/design/module/mod_antigrav
	id = "mod_antigrav"
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_BLUESPACE = 7, RESEARCH_TREE_PLASMA = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000)
	build_path = /obj/item/mod/module/anomaly_locked/antigrav

/datum/design/module/mod_flamethrower
	id = "mod_flamethrower"
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_PLASMA = 4)
	materials = list(MAT_METAL = 5000, MAT_GLASS = 4000, MAT_PLASMA = 6000)
	build_path = /obj/item/mod/module/flamethrower

/datum/design/module/mod_medbeam
	id = "mod_medbeam"
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_ENGINEERING = 7, RESEARCH_TREE_POWERSTORAGE = 7, RESEARCH_TREE_BIOTECH = 7)
	materials = list(MAT_METAL = 12500, MAT_SILVER = 12000, MAT_GOLD = 2500, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/medbeam

/datum/design/module/mod_jumpjet
	id = "mod_jumpjet"
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_BLUESPACE = 5, RESEARCH_TREE_PLASMA = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/jump_jet

/datum/design/module/mod_mouthhole
	id = "mod_mouthhole"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_POWERSTORAGE = 2, RESEARCH_TREE_ENGINEERING = 3)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000)
	build_path = /obj/item/mod/module/mouthhole

/datum/design/module/mod_longfall
	id = "mod_longfall"
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_BLUESPACE = 5, RESEARCH_TREE_PLASMA = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/longfall

/datum/design/module/mod_health_analyzer
	id = "mod_health_analyzer"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_POWERSTORAGE = 2, RESEARCH_TREE_BIOTECH = 3)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000)
	build_path = /obj/item/mod/module/health_analyzer

/datum/design/module/mod_quick_carry
	id = "mod_quick_carry"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_BIOTECH = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/quick_carry

/datum/design/module/mod_patienttransport
	id = "mod_patienttransport"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_BIOTECH = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000, MAT_PLASMA = 5000)
	build_path = /obj/item/mod/module/criminalcapture/patienttransport

/datum/design/module/mod_criminalcapture
	id = "mod_criminalcapture"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_BIOTECH = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000)
	build_path = /obj/item/mod/module/criminalcapture

/datum/design/module/mod_magnetic_harness
	id = "mod_magnetic_harness"
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_BIOTECH = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000, MAT_SILVER = 4000)
	build_path = /obj/item/mod/module/magnetic_harness

/datum/design/module/mod_pepper_shoulders
	id = "mod_pepper_shoulders"
	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_POWERSTORAGE = 2, RESEARCH_TREE_BIOTECH = 3)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000)
	build_path = /obj/item/mod/module/pepper_shoulders

/datum/design/module/mod_megaphone
	id = "mod_megaphone"
	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_BIOTECH = 6)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000)
	build_path = /obj/item/mod/module/megaphone

/datum/design/module/mod_quick_cuff
	id = "mod_quick_cuff"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 4)
	materials = list(MAT_METAL = 4200, MAT_GLASS = 4000)
	build_path = /obj/item/mod/module/quick_cuff

/datum/design/module/activation_upgrade
	id = "mod_activation_upgrade"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_BIOTECH = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000)
	build_path = /obj/item/mod/module/activation_upgrade

/datum/design/module/deployed_upgrade
	id = "mod_speed_upgrade"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_BIOTECH = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000)
	build_path = /obj/item/mod/module/deployed_upgrade

/datum/design/module/organizer
	id = "mod_organizer"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_BIOTECH = 6)
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000)
	build_path = /obj/item/mod/module/organizer

/datum/design/module/mirage
	id = "mod_mirage_grenade"
	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_POWERSTORAGE = 2, RESEARCH_TREE_BIOTECH = 2)
	materials = list(MAT_METAL = 6000, MAT_GLASS = 2000)
	build_path = /obj/item/mod/module/dispenser/mirage

/datum/design/module/dropwall_module
	id = "mod_dropwall_module"
	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_PLASMA = 5, RESEARCH_TREE_POWERSTORAGE = 3)
	materials = list(MAT_METAL = 6000, MAT_SILVER = 4000, MAT_PLASMA = 4000, MAT_GLASS = 2000)
	build_path = /obj/item/mod/module/dispenser/dropwall_module
