/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

/datum/design/nuclear_gun
	id = "nuclear_gun"
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_POWERSTORAGE = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2000, MAT_URANIUM = 3000, MAT_TITANIUM = 1000)
	build_path = /obj/item/gun/energy/gun/nuclear
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/decloner
	id = "decloner"
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_BIOTECH = 6, RESEARCH_TREE_PLASMA = 7)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000,MAT_URANIUM = 10000)
	reagents_list = list("mutagen" = 40)
	build_path = /obj/item/gun/energy/decloner
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/flora_gun
	id = "flora_gun"
	req_tech = list(RESEARCH_TREE_POWERSTORAGE = 7, RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MATERIALS = 5)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 2000, MAT_BLUESPACE = 1500, MAT_DIAMOND = 800, MAT_URANIUM = 500, MAT_GLASS = 500)
	build_path = /obj/item/gun/energy/floragun
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/ioncarbine
	id = "ioncarbine"
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_MAGNETS = 4)
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 6000, MAT_METAL = 8000, MAT_URANIUM = 2000)
	build_path = /obj/item/gun/energy/ionrifle/carbine
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/wormhole_projector
	id = "wormholeprojector"
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_BLUESPACE = 7, RESEARCH_TREE_PLASMA = 6)
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 2000, MAT_METAL = 5000, MAT_DIAMOND = 2000, MAT_BLUESPACE = 3000)
	build_path = /obj/item/gun/energy/wormhole_projector
	locked = TRUE
	access_requirement = list(ACCESS_RD) //screw you, HoS, this aint yours; this is only for a man of science---and trouble.
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/large_grenade
	id = "large_Grenade"
	req_tech = list(RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/grenade/chem_grenade/large
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/pyro_grenade
	id = "pyro_Grenade"
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_ENGINEERING = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 500)
	build_path = /obj/item/grenade/chem_grenade/pyro
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/cryo_grenade
	id = "cryo_Grenade"
	req_tech = list(RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_MATERIALS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 500)
	build_path = /obj/item/grenade/chem_grenade/cryo
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/adv_grenade
	id = "adv_Grenade"
	req_tech = list(RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_ENGINEERING = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 500)
	build_path = /obj/item/grenade/chem_grenade/adv_release
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/tele_shield
	id = "tele_shield"
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_ENGINEERING = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 7500, MAT_SILVER = 300, MAT_TITANIUM = 200)
	build_path = /obj/item/shield/riot/tele
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/lasercannon
	id = "lasercannon"
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_POWERSTORAGE = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 3000, MAT_DIAMOND = 3000)
	build_path = /obj/item/gun/energy/lasercannon
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/plasmapistol
	id = "ppistol"
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_POWERSTORAGE = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_PLASMA = 3000)
	build_path = /obj/item/gun/energy/toxgun
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_WEAPON)

//WT550 Mags

/datum/design/mag_oldsmg
	id = "mag_oldsmg"
	req_tech = list(RESEARCH_TREE_COMBAT = 1, RESEARCH_TREE_MATERIALS = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 2000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/empty
	category = list(PROTOLATHE_CATEGORY_WEAPON, PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/box_oldsmg
	id = "box_oldsmg"
	req_tech = list(RESEARCH_TREE_COMBAT = 2, RESEARCH_TREE_MATERIALS = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 36000)
	build_path = /obj/item/ammo_box/c46x30mm
	category = list(PROTOLATHE_CATEGORY_WEAPON, PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/box_oldsmg/ap_box
	id = "box_oldsmg_ap"
	materials = list(MAT_METAL = 42500, MAT_SILVER = 3000)
	build_path = /obj/item/ammo_box/ap46x30mm

/datum/design/box_oldsmg/ic_box
	id = "box_oldsmg_ic"
	materials = list(MAT_METAL = 42500, MAT_SILVER = 3000, MAT_PLASMA = 4000)
	build_path = /obj/item/ammo_box/inc46x30mm

/datum/design/box_oldsmg/tx_box
	id = "box_oldsmg_tx"
	materials = list(MAT_METAL = 42500, MAT_SILVER = 3000, MAT_URANIUM = 3000)
	build_path = /obj/item/ammo_box/tox46x30mm

/datum/design/hp45colt
	id = "hp45colt"
	req_tech = list(RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_MATERIALS = 3)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 44500, MAT_SILVER = 3000)
	build_path = /obj/item/ammo_box/expansive45colt
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/lmag
	id = "lmag"
	build_type = PROTOLATHE | AUTOLATHE
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_POWERSTORAGE = 4)
	materials = list(MAT_METAL = 2000)
	build_path = /obj/item/ammo_box/magazine/lr30mag/empty
	category = list(PROTOLATHE_CATEGORY_WEAPON, PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/lmag_box
	id = "lmag_box"
	build_type = PROTOLATHE | AUTOLATHE
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_POWERSTORAGE = 4)
	materials = list(MAT_METAL = 36500)
	build_path = /obj/item/ammo_box/laserammobox
	category = list(PROTOLATHE_CATEGORY_WEAPON, PRINTER_CATEGORY_HACKED, AUTOLATHE_CATEGORY_SECURITY)

/datum/design/rapidsyringe
	id = "rapidsyringe"
	req_tech = list(RESEARCH_TREE_COMBAT = 2, RESEARCH_TREE_BIOTECH = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000)
	build_path = /obj/item/gun/syringe/rapidsyringe
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/stunshell
	id = "stunshell"
	req_tech = list(RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_MATERIALS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 250)
	build_path = /obj/item/ammo_casing/shotgun/stunslug
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/stunrevolver
	id = "stunrevolver"
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_POWERSTORAGE = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 10000, MAT_SILVER = 10000)
	build_path = /obj/item/gun/energy/shock_revolver
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/temp_gun
	id = "temp_gun"
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_POWERSTORAGE = 3, RESEARCH_TREE_MAGNETS = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 500, MAT_SILVER = 3000)
	build_path = /obj/item/gun/energy/temperature
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/techshell
	id = "techshotshell"
	req_tech = list(RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_MAGNETS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 200)
	build_path = /obj/item/ammo_casing/shotgun/techshell
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/xray
	id = "xray"
	req_tech = list(RESEARCH_TREE_COMBAT = 7, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_BIOTECH = 5, RESEARCH_TREE_POWERSTORAGE = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000, MAT_URANIUM = 4000, MAT_METAL = 5000, MAT_TITANIUM = 2000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/gun/energy/xray
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/immolator
	id = "immolator"
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_POWERSTORAGE = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000, MAT_SILVER = 3000, MAT_PLASMA = 2000)
	build_path = /obj/item/gun/energy/immolator
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/bsg
	id = "bsg"
	req_tech = list(RESEARCH_TREE_COMBAT = 7, RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_MAGNETS = 7, RESEARCH_TREE_POWERSTORAGE = 7, RESEARCH_TREE_BLUESPACE = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000,  MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) // Big gun, big cost
	build_path = /obj/item/gun/energy/bsg
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/ipc_combat_upgrade
	materials = list(MAT_METAL=800, MAT_GLASS=1000, MAT_GOLD=2800, MAT_DIAMOND=1650)
	id = "ipccombatupgrade"
	build_type = PROTOLATHE
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 4,RESEARCH_TREE_PROGRAMMING = 5)
	build_path = /obj/item/ipc_combat_upgrade
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/laser_arm
	id = "laser_arm_imp"
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_MAGNETS = 7, RESEARCH_TREE_POWERSTORAGE = 7, RESEARCH_TREE_PLASMA = 7, RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_COMBAT = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 15000, MAT_URANIUM = 10000, MAT_TITANIUM = 6000, MAT_GOLD = 4500, MAT_DIAMOND = 3500)
	build_path = /obj/item/organ/internal/cyberimp/arm/gun/laser
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_WEAPON)

// Gun modules

/datum/design/gun_mod/coll_med
	id = "mod_medhud"
	req_tech = list(RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_PROGRAMMING = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 420, MAT_GLASS = 250, MAT_GOLD = 150, MAT_URANIUM = 200)
	build_path = /obj/item/gun_module/rail/hud/medical
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/gun_mod/coll_sec
	id = "mod_sechud"
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_MATERIALS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 520, MAT_GLASS = 300, MAT_GOLD = 150, MAT_URANIUM = 200)
	build_path = /obj/item/gun_module/rail/hud/security
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/gun_mod/scope_x8
	id = "mod_scope_x8"
	req_tech = list(RESEARCH_TREE_COMBAT = 8, RESEARCH_TREE_MAGNETS = 6, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_MATERIALS = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 500, MAT_GOLD = 750, MAT_URANIUM = 500)
	build_path = /obj/item/gun_module/rail/scope/x8
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/////////////////////////////////////////
////////////////ILLEGAL//////////////////
/////////////////////////////////////////

/datum/design/antimov_module
	id = "antimov_module"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_ILLEGAL = 2, RESEARCH_TREE_MATERIALS = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/ai_module/antimov
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/tyrant_module
	id = "tyrant_module"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_ILLEGAL = 2, RESEARCH_TREE_MATERIALS = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/ai_module/tyrant
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/largecrossbow
	id = "largecrossbow"
	req_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_ILLEGAL = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1500, MAT_URANIUM = 1500, MAT_SILVER = 1500)
	build_path = /obj/item/gun/energy/kinetic_accelerator/crossbow/large
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/suppressor
	id = "suppressor"
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_ILLEGAL = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 500)
	build_path = /obj/item/gun_module/muzzle/suppressor
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/stechkin
	id = "stechkin"
	req_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_ILLEGAL = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_TITANIUM = 5000)
	build_path = /obj/item/gun/projectile/automatic/pistol
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/chameleon_kit
	id = "chameleon_kit"
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_ILLEGAL = 3, RESEARCH_TREE_MAGNETS = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_GLASS = 3000, MAT_SILVER = 2000, MAT_DIAMOND = 1000)
	build_path = /obj/item/storage/box/syndie_kit/chameleon
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/chameleon_hud
	id = "chameleon_hud"
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_ILLEGAL = 3, RESEARCH_TREE_MAGNETS = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 500)
	build_path = /obj/item/clothing/glasses/hud/security/chameleon
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/e_dagger
	id = "e_dagger"
	req_tech = list(RESEARCH_TREE_COMBAT = 7, RESEARCH_TREE_PROGRAMMING = 7, RESEARCH_TREE_ILLEGAL = 2, RESEARCH_TREE_MATERIALS = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 15000, MAT_DIAMOND = 3000, MAT_TITANIUM = 3000)
	build_path = /obj/item/pen/edagger
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/a_tuner
	id = "a_tuner"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 7, RESEARCH_TREE_ILLEGAL = 4, RESEARCH_TREE_MATERIALS = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 9000, MAT_DIAMOND = 2500, MAT_SILVER = 2000)
	build_path = /obj/item/door_remote/omni/access_tuner
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/c_flash
	id = "c_flash"
	req_tech = list(RESEARCH_TREE_COMBAT = 7, RESEARCH_TREE_PROGRAMMING = 6, RESEARCH_TREE_ILLEGAL = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_DIAMOND = 1000, MAT_TITANIUM = 1500)
	build_path = /obj/item/flash/cameraflash
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/dna_scrambler
	id = "dna_scrambler"
	req_tech = list(RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_PROGRAMMING = 7, RESEARCH_TREE_ILLEGAL = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_DIAMOND = 1500)
	reagents_list = list("stable_mutagen" = 20)
	build_path = /obj/item/dnascrambler
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/c_bug
	id = "c_bug"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 7, RESEARCH_TREE_ILLEGAL = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 3000)
	build_path = /obj/item/camera_bug
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/ai_detector
	id = "ai_detector"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PROGRAMMING = 7, RESEARCH_TREE_ILLEGAL = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 3000, MAT_SILVER = 1500)
	build_path = /obj/item/multitool/ai_detect
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/adv_pointer
	id = "adv_pointer"
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_PROGRAMMING = 7, RESEARCH_TREE_ILLEGAL = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20000, MAT_TITANIUM = 4000, MAT_DIAMOND = 5000)
	build_path = /obj/item/pinpointer/advpinpointer
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/encryptionkey_binary
	id = "binarykey"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_ILLEGAL = 3, RESEARCH_TREE_PROGRAMMING = 4,RESEARCH_TREE_MATERIALS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000,)
	build_path = /obj/item/encryptionkey/binary
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/encryptionkey_syndicate
	id = "syndicatekey"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_ILLEGAL = 3, RESEARCH_TREE_PROGRAMMING = 4,RESEARCH_TREE_MATERIALS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000,)
	build_path = /obj/item/encryptionkey/syndicate
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/ai_module_syndicate
	id = "syndiaimodule"
	req_tech = list(RESEARCH_TREE_ILLEGAL = 6, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_MATERIALS = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/ai_module/syndicate
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/incendiary_10mm
	id = "10mminc"
	req_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_ILLEGAL = 2, RESEARCH_TREE_MATERIALS = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 9000, MAT_SILVER = 800, MAT_PLASMA = 1200)
	build_path = /obj/item/ammo_box/magazine/m10mm/fire
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/radio_jammer
	id = "jammer"
	req_tech = list(RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_ILLEGAL = 3, RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_MATERIALS = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000, MAT_SILVER = 500)
	build_path = /obj/item/jammer
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/syndie_rcd
	id = "syndie_rcd"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_ILLEGAL = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20000, MAT_GLASS=8000, MAT_PLASMA = 10000, MAT_TITANIUM = 10000)
	build_path = /obj/item/rcd/syndicate
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/syndie_rcd_ammo
	id = "syndie_rcd_ammo"
	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_ILLEGAL = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_GLASS = 4000, MAT_TITANIUM = 4000, MAT_PLASMA = 4000)
	build_path = /obj/item/rcd_ammo/syndicate
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/syndie_rcd_ammo_large
	id = "syndie_rcd_ammo_large"
	req_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_ILLEGAL = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 40000, MAT_GLASS = 20000, MAT_TITANIUM = 20000, MAT_PLASMA = 20000)
	build_path = /obj/item/rcd_ammo/syndicate/large
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/paicard_cartridge
	id = "paicardcartridge"
	req_tech = list(RESEARCH_TREE_ILLEGAL = 3, RESEARCH_TREE_PROGRAMMING = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 8000, MAT_GOLD = 6000, MAT_DIAMOND = 5000)
	build_path = /obj/item/paicard_upgrade/protolate
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_ILLEGAL)

/datum/design/pyroclaw
	id = "pyro_gloves"
	req_tech = list(RESEARCH_TREE_COMBAT = 7, RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_ENGINEERING = 7, RESEARCH_TREE_PLASMA = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000, MAT_SILVER = 4000, MAT_TITANIUM = 4000, MAT_PLASMA = 8000)
	build_path = /obj/item/clothing/gloves/color/black/pyro_claws
	category = list(PROTOLATHE_CATEGORY_WEAPON)

/datum/design/real_plasma_pistol
	id = "real_plasma_pistol"
	req_tech = null
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 6000, MAT_TITANIUM = 4000, MAT_PLASMA = 4000)
	build_path = /obj/item/gun/energy/plasma_pistol
	locked = TRUE
	category = list(PROTOLATHE_CATEGORY_WEAPON)
