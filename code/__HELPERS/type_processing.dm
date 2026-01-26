/proc/make_types_fancy(list/types)
	if(ispath(types))
		types = list(types)
	. = list()
	for(var/type in types)
		var/typename = "[type]"
		var/static/list/TYPES_SHORTCUTS = list(
			//longest paths comes first - otherwise they get shadowed by the more generic ones
			/obj/effect/decal/cleanable = "CLEANABLE",
			/obj/effect = "EFFECT",
			/obj/item/ammo_casing = "AMMO",
			/obj/item/book/manual = "MANUAL",
			/obj/item/borg/upgrade = "BORG_UPGRADE",
			/obj/item/cartridge = "PDA_CART",
			/obj/item/clothing/head/helmet/space = "SPESSHELMET",
			/obj/item/clothing/head = "HEAD",
			/obj/item/clothing/under = "UNIFORM",
			/obj/item/clothing/shoes = "SHOES",
			/obj/item/clothing/suit = "SUIT",
			/obj/item/clothing/gloves = "GLOVES",
			/obj/item/clothing/mask/cigarette = "CIGARRETE", // oof
			/obj/item/clothing/mask = "MASK",
			/obj/item/clothing/glasses = "GLASSES",
			/obj/item/clothing = "CLOTHING",
			/obj/item/grenade/clusterbuster = "CLUSTERBUSTER",
			/obj/item/grenade = "GRENADE",
			/obj/item/gun = "GUN",
			/obj/item/implant = "IMPLANT",
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack = "MECHA_MISSILE_RACK",
			/obj/item/mecha_parts/mecha_equipment/weapon = "MECHA_WEAPON",
			/obj/item/mecha_parts/mecha_equipment = "MECHA_EQUIP",
			/obj/item/melee = "MELEE",
			/obj/item/mmi = "MMI",
			/obj/item/nullrod = "NULLROD",
			/obj/item/organ/external = "EXT_ORG",
			/obj/item/organ/internal/cyberimp = "CYBERIMP",
			/obj/item/organ/internal = "INT_ORG",
			/obj/item/organ = "ORGAN",
			/obj/item/pda = "PDA",
			/obj/projectile = "PROJ",
			/obj/item/radio/headset = "HEADSET",
			/obj/item/reagent_containers/glass/beaker = "BEAKER",
			/obj/item/reagent_containers/glass/bottle = "BOTTLE",
			/obj/item/reagent_containers/food/pill/patch = "PATCH",
			/obj/item/reagent_containers/food/pill = "PILL",
			/obj/item/reagent_containers/food/drinks = "DRINK",
			/obj/item/reagent_containers/food = "FOOD",
			/obj/item/reagent_containers/syringe = "SYRINGE",
			/obj/item/reagent_containers = "REAGENT_CONTAINERS",
			/obj/item/robot_parts = "ROBOT_PARTS",
			/obj/item/seeds = "SEED",
			/obj/item/slime_extract = "SLIME_CORE",
			/obj/item/spacepod_equipment/weaponry = "POD_WEAPON",
			/obj/item/spacepod_equipment = "POD_EQUIP",
			/obj/item/stack/sheet/mineral = "MINERAL",
			/obj/item/stack/sheet = "SHEET",
			/obj/item/stack/tile = "TILE",
			/obj/item/stack = "STACK",
			/obj/item/stock_parts/cell = "POWERCELL",
			/obj/item/stock_parts = "STOCK_PARTS",
			/obj/item/storage/firstaid = "FIRSTAID",
			/obj/item/storage = "STORAGE",
			/obj/item/tank = "GAS_TANK",
			/obj/item/toy/crayon = "CRAYON",
			/obj/item/toy = "TOY",
			/obj/item = "ITEM",
			/obj/machinery/atmospherics = "ATMOS_MACH",
			/obj/machinery/computer = "CONSOLE",
			/obj/machinery/door/airlock = "AIRLOCK",
			/obj/machinery/door = "DOOR",
			/obj/machinery/kitchen_machine = "KITCHEN",
			/obj/machinery/portable_atmospherics/canister = "CANISTER",
			/obj/machinery/portable_atmospherics = "PORT_ATMOS",
			/obj/machinery/power = "POWER",
			/obj/machinery = "MACHINERY",
			/obj/mecha = "MECHA",
			/obj/structure/closet/crate = "CRATE",
			/obj/structure/closet = "CLOSET",
			/obj/structure/statue = "STATUE",
			/obj/structure/chair = "CHAIR", // oh no
			/obj/structure/bed = "BED",
			/obj/structure/chair/stool = "STOOL",
			/obj/structure/table = "TABLE",
			/obj/structure = "STRUCTURE",
			/obj/vehicle = "VEHICLE",
			/obj = "O",
			/datum = "D",
			/turf/simulated/floor = "FLOOR",
			/turf/simulated/wall = "WALL",
			/turf = "T",
			/mob/living/carbon/alien = "XENO",
			/mob/living/carbon/human = "HUMAN",
			/mob/living/carbon = "CARBON",
			/mob/living/silicon/robot = "CYBORG",
			/mob/living/silicon/ai = "AI",
			/mob/living/silicon = "SILICON",
			/mob/living/simple_animal/bot = "BOT",
			/mob/living/simple_animal = "SIMPLE",
			/mob/living = "LIVING",
			/mob = "M"
		)
		for(var/tn in TYPES_SHORTCUTS)
			if(copytext(typename, 1, length("[tn]/") + 1) == "[tn]/")
				typename = TYPES_SHORTCUTS[tn]+copytext(typename,length("[tn]/"))
				break
		.[typename] = type

/// Returns a pre-generated fancy list of all atom types
/proc/get_fancy_list_of_atom_types()
	var/static/list/pre_generated_atom_list
	if(!pre_generated_atom_list) // Initialize on first call
		pre_generated_atom_list = make_types_fancy(typesof(/atom))
	return pre_generated_atom_list

/// Returns a pre-generated fancy list of all datum types (excluding atoms)
/proc/get_fancy_list_of_datum_types()
	var/static/list/pre_generated_datum_list
	if(!pre_generated_datum_list) // Initialize on first call
		pre_generated_datum_list = make_types_fancy(sortList(typesof(/datum) - typesof(/atom)))
	return pre_generated_datum_list

/**
 * Filters a fancy list by a given search term
 *
 * Arguments:
 * * source_list - The list to filter
 * * filter_text - The text to search for in keys and values
 */
/proc/filter_fancy_list(list/source_list, filter_text)
	var/list/filtered_matches = new
	for(var/list_key in source_list)
		var/list_value = source_list[list_key]
		if(findtext("[list_key]", filter_text) || findtext("[list_value]", filter_text))
			filtered_matches[list_key] = list_value
	return filtered_matches

/// Splits a type path into its component names
/proc/return_typenames(type_path)
	return splittext("[type_path]", "/")
