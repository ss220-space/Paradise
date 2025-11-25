/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////
/datum/design/drill
	id = "drill"
	req_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_POWERSTORAGE = 2, RESEARCH_TREE_ENGINEERING = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000)
	build_path = /obj/item/pickaxe/drill
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/drill_diamond
	id = "drill_diamond"
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000, MAT_DIAMOND = 2000) //Yes, a whole diamond is needed.
	build_path = /obj/item/pickaxe/drill/diamonddrill
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/plasmacutter_adv
	id = "plasmacutter_adv"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_PLASMA = 6, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_MAGNETS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000, MAT_PLASMA = 2000, MAT_GOLD = 500)
	build_path = /obj/item/gun/energy/plasmacutter/adv
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/plasmacutter_shotgun
	id = "plasmacutter_shotgun"
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_PLASMA = 7, RESEARCH_TREE_ENGINEERING = 7, RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_MAGNETS = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 2000, MAT_PLASMA = 2000, MAT_GOLD = 2000, MAT_DIAMOND = 3000)
	build_path = /obj/item/gun/energy/plasmacutter/shotgun
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/jackhammer
	id = "jackhammer"
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_MAGNETS = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 2000, MAT_SILVER = 2000, MAT_DIAMOND = 6000)
	build_path = /obj/item/pickaxe/drill/jackhammer
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/superresonator
	id = "superresonator"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_POWERSTORAGE = 3, RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_MAGNETS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1500, MAT_SILVER = 1000, MAT_URANIUM = 1000)
	build_path = /obj/item/resonator/upgraded
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/trigger_guard_mod
	id = "triggermod"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_COMBAT = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_GOLD = 1500, MAT_URANIUM = 1000)
	build_path = /obj/item/borg/upgrade/modkit/trigger_guard
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/aoe_turf_mod
	id = "hypermod"
	req_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_COMBAT = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_GLASS = 1500, MAT_SILVER = 2000, MAT_GOLD = 2000, MAT_DIAMOND = 2000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/kineticexperimental
	id = "expkinac"
	req_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_COMBAT = 5)
	build_type = PROTOLATHE
	materials = list(MAT_TITANIUM = 8000, MAT_BLUESPACE = 1000, MAT_DIAMOND = 2000, )
	build_path = /obj/item/gun/energy/kinetic_accelerator/experimental
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/f_rods
	id = "f_rods"
	req_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_PLASMA = 4)
	build_type = PROTOLATHE | SMELTER
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 500, MAT_TITANIUM = 1000)
	build_path = /obj/item/stack/fireproof_rods
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/mining_charge
	id = "megacharge"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_PLASMA = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 6000, MAT_URANIUM = 1000)
	build_path = /obj/item/grenade/plastic/miningcharge/mega
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/fishingrod
	id = "fishingrod"
	req_tech = list(RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_PLASMA = 5, RESEARCH_TREE_BIOTECH = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_TITANIUM = 6000)
	build_path = /obj/item/twohanded/fishing_rod
	category = list(PROTOLATHE_CATEGORY_MINING)
