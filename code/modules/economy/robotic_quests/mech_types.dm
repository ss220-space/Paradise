#define WORKING_MECH	1
#define MEDICAL_MECH	2
#define COMBAT_MECH 	3
/datum/quest_mech
	/// Original name of Mecha
	var/name
	/// Path to the actual mech in code
	var/mech_type
	/// List of all compatible modules with this kind of mecha
	var/icon/mech_icon = icon('icons/obj/mecha/mecha.dmi', "ripley-open", SOUTH, 1)
	var/list/wanted_modules
	/// Type of mech (combat | medical | working)
	var/mech_class

/datum/quest_mech/ripley
	name = "APLU MK-II \"Ripley\""
	mech_type = /obj/mecha/working/ripley
	mech_class = WORKING_MECH
	mech_icon = icon('icons/obj/mecha/mecha.dmi', "ripley-open", SOUTH, 1)

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
	mech_class = WORKING_MECH
	mech_icon = icon('icons/obj/mecha/mecha.dmi', "firefighter-open", SOUTH, 1)
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
	mech_class = WORKING_MECH
	mech_icon = icon('icons/obj/mecha/mecha.dmi', "clarke", SOUTH, 1, 0)
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
	mech_class = MEDICAL_MECH
	mech_icon = icon('icons/obj/mecha/mecha.dmi', "odysseus", SOUTH, 1)
	wanted_modules = list(
		/obj/item/mecha_parts/mecha_equipment/medical/sleeper,
		/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun,
		/obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw,
		/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun_upgrade,
	)

/datum/quest_mech/gygax
	name = "Gygax"
	mech_type = /obj/mecha/combat/gygax
	mech_class = COMBAT_MECH
	mech_icon = icon('icons/obj/mecha/mecha.dmi', "gygax", SOUTH, 1)
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
	mech_class = COMBAT_MECH
	mech_icon = icon('icons/obj/mecha/mecha.dmi', "durand", SOUTH, 1)
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
