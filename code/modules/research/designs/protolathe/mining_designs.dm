/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////
/datum/design/drill
	id = "drill"
	req_tech = list("materials" = 2, "powerstorage" = 2, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000)
	build_path = /obj/item/pickaxe/drill
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/drill_diamond
	id = "drill_diamond"
	req_tech = list("materials" = 6, "powerstorage" = 5, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000, MAT_DIAMOND = 2000) //Yes, a whole diamond is needed.
	build_path = /obj/item/pickaxe/drill/diamonddrill
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/plasmacutter_adv
	id = "plasmacutter_adv"
	req_tech = list("materials" = 5, "plasmatech" = 6, "engineering" = 6, "combat" = 3, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000, MAT_PLASMA = 2000, MAT_GOLD = 500)
	build_path = /obj/item/gun/energy/plasmacutter/adv
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/plasmacutter_shotgun
	id = "plasmacutter_shotgun"
	req_tech = list("materials" = 7, "powerstorage" = 5, "plasmatech" = 7, "engineering" = 7, "combat" = 6, "magnets" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 2000, MAT_PLASMA = 2000, MAT_GOLD = 2000, MAT_DIAMOND = 3000)
	build_path = /obj/item/gun/energy/plasmacutter/shotgun
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/jackhammer
	id = "jackhammer"
	req_tech = list("materials" = 7, "powerstorage" = 5, "engineering" = 6, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 2000, MAT_SILVER = 2000, MAT_DIAMOND = 6000)
	build_path = /obj/item/pickaxe/drill/jackhammer
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/superresonator
	id = "superresonator"
	req_tech = list("materials" = 4, "powerstorage" = 3, "engineering" = 3, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1500, MAT_SILVER = 1000, MAT_URANIUM = 1000)
	build_path = /obj/item/resonator/upgraded
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/trigger_guard_mod
	id = "triggermod"
	req_tech = list("materials" = 5, "powerstorage" = 4, "engineering" = 4, "magnets" = 4, "combat" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_GOLD = 1500, MAT_URANIUM = 1000)
	build_path = /obj/item/borg/upgrade/modkit/trigger_guard
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/aoe_turf_mod
	id = "hypermod"
	req_tech = list("materials" = 7, "powerstorage" = 5, "engineering" = 5, "magnets" = 5, "combat" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_GLASS = 1500, MAT_SILVER = 2000, MAT_GOLD = 2000, MAT_DIAMOND = 2000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/kineticexperimental
	id = "expkinac"
	req_tech = list("materials" = 4, "powerstorage" = 4, "engineering" = 6, "combat" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_TITANIUM = 8000, MAT_BLUESPACE = 1000, MAT_DIAMOND = 2000, )
	build_path = /obj/item/gun/energy/kinetic_accelerator/experimental
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/f_rods
	id = "f_rods"
	req_tech = list("materials" = 6, "engineering" = 3, "plasmatech" = 4)
	build_type = PROTOLATHE | SMELTER
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 500, MAT_TITANIUM = 1000)
	build_path = /obj/item/stack/fireproof_rods
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/mining_charge
	id = "megacharge"
	req_tech = list("materials" = 5, "engineering" = 5, "plasmatech" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 6000, MAT_URANIUM = 1000)
	build_path = /obj/item/grenade/plastic/miningcharge/mega
	category = list(PROTOLATHE_CATEGORY_MINING)

/datum/design/fishingrod
	id = "fishingrod"
	req_tech = list("materials" = 5, "engineering" = 4, "plasmatech" = 5, "biotech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_TITANIUM = 6000)
	build_path = /obj/item/twohanded/fishing_rod
	category = list(PROTOLATHE_CATEGORY_MINING)
