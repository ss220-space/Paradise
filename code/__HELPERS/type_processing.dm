/// Turns a list of typepaths into 'fancy' titles for admins.
/proc/make_types_fancy(var/list/types)
	if(ispath(types))
		types = list(types)
	. = list()
	for(var/type in types)
		var/typename = "[type]"
		var/static/list/TYPES_SHORTCUTS = list(
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
			/obj/item/clothing/mask/cigarette = "CIGARRETE",
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
			/obj/structure/chair = "CHAIR",
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

///Generates a static list of 'fancy' atom types, or returns that if its already been generated.
/proc/get_fancy_list_of_atom_types()
	var/static/list/pre_generated_list
	if(!pre_generated_list) //init
		pre_generated_list = make_types_fancy(typesof(/atom))
	return pre_generated_list

///Generates a static list of 'fancy' datum types, excluding everything atom, or returns that if its already been generated.
/proc/get_fancy_list_of_datum_types()
	var/static/list/pre_generated_list
	if(!pre_generated_list) //init
		pre_generated_list = make_types_fancy(sort_list(typesof(/datum) - typesof(/atom)))
	return pre_generated_list

/**
 * Takes a given fancy list and filters out a given filter text.
 * Args:
 * fancy_list - The list provided we filter.
 * filter - the text we use to filter fancy_list
 */
/proc/filter_fancy_list(list/fancy_list, filter as text)
	var/list/matches = new
	var/end_len = -1
	var/list/endcheck = splittext(filter, "!")
	if(endcheck.len > 1)
		filter = endcheck[1]
		end_len = length_char(filter)

	for(var/key in fancy_list)
		var/value = fancy_list[key]
		if(findtext("[key]", filter, -end_len) || findtext("[value]", filter, -end_len))
			matches[key] = value
	return matches

///Splits the type with parenthesis between each word so admins visually tell it is a typepath.
/proc/return_typenames(type)
	return splittext("[type]", "/")
