/datum/quest_mech
	var/name
	var/mech_type
	var/list/wanted_modules

/datum/quest_mech/ripley
	name = "APLU MK-II \"Ripley\""
	mech_type = /obj/mecha/working/ripley
	wanted_modules = list(
		/obj/item/mecha_parts/mecha_equipment/drill,
		/obj/item/mecha_parts/mecha_equipment/mining_scanner,
		/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp,
		/obj/item/mecha_parts/mecha_equipment/rcd,
		/obj/item/mecha_parts/mecha_equipment/multimodule/atmos_module,
		/obj/item/mecha_parts/mecha_equipment/cable_layer,
		/obj/item/mecha_parts/mecha_equipment/extinguisher,
		/obj/item/mecha_parts/mecha_equipment/holowall,
		/obj/item/mecha_parts/mecha_equipment/eng_toolset,
	)

/datum/quest_mech/firefighter
	name = "APLU \"Firefighter\""
	mech_type = /obj/mecha/working/ripley/firefighter
	wanted_modules = list(
		/obj/item/mecha_parts/mecha_equipment/drill,
		/obj/item/mecha_parts/mecha_equipment/mining_scanner,
		/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp,
		/obj/item/mecha_parts/mecha_equipment/rcd,
		/obj/item/mecha_parts/mecha_equipment/multimodule/atmos_module,
		/obj/item/mecha_parts/mecha_equipment/cable_layer,
		/obj/item/mecha_parts/mecha_equipment/extinguisher,
		/obj/item/mecha_parts/mecha_equipment/holowall,
		/obj/item/mecha_parts/mecha_equipment/eng_toolset,
	)

/datum/quest_mech/clarke
	name =  "APLU \"Clarke\""
	mech_type = /obj/mecha/working/clarke
	wanted_modules = list(
		/obj/item/mecha_parts/mecha_equipment/drill,
		/obj/item/mecha_parts/mecha_equipment/mining_scanner,
		/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp,
		/obj/item/mecha_parts/mecha_equipment/rcd,
		/obj/item/mecha_parts/mecha_equipment/multimodule/atmos_module,
		/obj/item/mecha_parts/mecha_equipment/cable_layer,
		/obj/item/mecha_parts/mecha_equipment/extinguisher,
		/obj/item/mecha_parts/mecha_equipment/holowall,
		/obj/item/mecha_parts/mecha_equipment/eng_toolset,

	)

/datum/quest_mech/odysseus
	name = "Odysseus"
	mech_type = /obj/mecha/medical/odysseus
	wanted_modules = list(
		/obj/item/mecha_parts/mecha_equipment/medical/sleeper,
		/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun,
		/obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw,
		/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun_upgrade,
	)

/datum/quest_mech/gygax
	name = "Gygax"
	//difficulty = hard. пока так. Это нужно будет если будет возможность выбирать из трёх.
	mech_type = /obj/mecha/combat/gygax
	wanted_modules = list(
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/disabler,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/immolator,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/amlg,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang,
	)

/datum/quest_mech/durand
	name = "Durand Mk. II"
	mech_type = /obj/mecha/combat/durand
	wanted_modules = list(
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/disabler,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/immolator,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/amlg,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang,
	)
