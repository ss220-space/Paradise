/* Glass stack types
 * Contains:
 *		Glass sheets
 *		Reinforced glass sheets
 *		Glass shards - TODO: Move this into code/game/object/item/weapons
 *		Plasma Glass Sheets
 *		Reinforced Plasma Glass Sheets (AKA Holy fuck strong windows)

 Todo: Create a unified construct_window(sheet, user, created_window, full_window)

 */

/*
 * Glass sheets
 */

GLOBAL_LIST_INIT(glass_recipes, list(
	new /datum/stack_recipe/window("directional window", /obj/structure/window/basic, on_floor = TRUE, check_direction = TRUE),
	new /datum/stack_recipe/window("fulltile window", /obj/structure/window/full/basic, 2, on_floor = TRUE, is_fulltile = TRUE),
	null,
	new /datum/stack_recipe("fishbowl", /obj/machinery/fishtank/bowl, time = 10),
	new /datum/stack_recipe("fish tank", /obj/machinery/fishtank/tank, 3, time = 20, on_floor = TRUE),
	new /datum/stack_recipe("wall aquariam", /obj/machinery/fishtank/wall, 4, time = 40, on_floor = TRUE),
	null,
	new /datum/stack_recipe("glass ashtray", /obj/item/storage/ashtray/glass, 2, one_per_turf = TRUE, on_floor = TRUE),
))

/obj/item/stack/sheet/glass
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100)
	resistance_flags = ACID_PROOF
	origin_tech = "materials=1"
	created_window = /obj/structure/window/basic
	full_window = /obj/structure/window/full/basic
	merge_type = /obj/item/stack/sheet/glass
	point_value = 1

/obj/item/stack/sheet/glass/fifty
	amount = 50

/obj/item/stack/sheet/glass/cyborg
	materials = list()
	is_cyborg = 1
	cyborg_construction_stack = /obj/item/stack/sheet/glass

/obj/item/stack/sheet/glass/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.glass_recipes


/obj/item/stack/sheet/glass/attackby(obj/item/I, mob/user, params)
	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(coil.get_amount() < 5)
			to_chat(user, span_warning("There is not enough wire in this coil. You need five lengths."))
			return ATTACK_CHAIN_PROCEED
		if(get_amount() < 1)
			to_chat(user, span_warning("There is not enough [name] sheets."))
			return ATTACK_CHAIN_PROCEED
		coil.use(5)
		to_chat(user, span_notice("You attach wire to [src]."))
		var/obj/item/stack/light_w/light = new(drop_location())
		light.add_fingerprint(user)
		use(1)
		user.put_in_hands(light, ignore_anim = FALSE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/stack/rods))
		add_fingerprint(user)
		var/obj/item/stack/rods/rods = I
		if(rods.get_amount() < 1)
			to_chat(user, span_warning("There is not enough rods."))
			return ATTACK_CHAIN_PROCEED
		if(get_amount() < 1)
			to_chat(user, span_warning("There is not enough glass sheets."))
			return ATTACK_CHAIN_PROCEED
		rods.use(1)
		to_chat(user, span_notice("You attach rods to [src]."))
		var/obj/item/stack/sheet/rglass/rglass = new(drop_location())
		rglass.add_fingerprint(user)
		use(1)
		user.put_in_hands(rglass, ignore_anim = FALSE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/*
 * Reinforced glass sheets
 */

GLOBAL_LIST_INIT(reinforced_glass_recipes, list ( \
	new/datum/stack_recipe/window("windoor frame", /obj/structure/windoor_assembly, 5, time = 0, on_floor = TRUE, check_direction = TRUE), \
	null, \
	new/datum/stack_recipe/window("directional reinforced window", /obj/structure/window/reinforced, time = 0, on_floor = TRUE, check_direction = TRUE), \
	new/datum/stack_recipe/window("fulltile reinforced window", /obj/structure/window/full/reinforced, 2, time = 0, on_floor = TRUE, is_fulltile = TRUE) \
))

/obj/item/stack/sheet/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT/2, MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 100)
	resistance_flags = ACID_PROOF
	origin_tech = "materials=2"
	created_window = /obj/structure/window/reinforced
	full_window = /obj/structure/window/full/reinforced
	merge_type = /obj/item/stack/sheet/rglass
	point_value = 4

/obj/item/stack/sheet/rglass/cyborg
	materials = list()
	is_cyborg = 1
	var/datum/robot_energy_storage/glasource
	var/metcost = 2
	var/glacost = 1

/obj/item/stack/sheet/rglass/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.reinforced_glass_recipes

/obj/item/stack/sheet/rglass/cyborg/get_amount()
	return min(round(source.energy / metcost), round(glasource.energy / glacost))

/obj/item/stack/sheet/rglass/cyborg/use(used, transfer = FALSE, check = TRUE) // Requires special checks, because it uses two storages
	if(get_amount(used)) //ensure we still have enough energy if called in a do_after chain
		source.use_charge(used * metcost)
		glasource.use_charge(used * glacost)
		return TRUE

/obj/item/stack/sheet/rglass/cyborg/add(amount)
	source.add_charge(amount * metcost)
	glasource.add_charge(amount * glacost)


GLOBAL_LIST_INIT(pglass_recipes, list ( \
	new/datum/stack_recipe/window("directional window", /obj/structure/window/plasmabasic, time = 0, on_floor = TRUE, check_direction = TRUE), \
	new/datum/stack_recipe/window("fulltile window", /obj/structure/window/full/plasmabasic, 2, time = 0, on_floor = TRUE, is_fulltile = TRUE) \
))

/obj/item/stack/sheet/plasmaglass
	name = "plasma glass"
	desc = "A very strong and very resistant sheet of a plasma-glass alloy."
	singular_name = "glass sheet"
	icon_state = "sheet-plasmaglass"
	item_state = "sheet-pglass"
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 75, "acid" = 100)
	resistance_flags = ACID_PROOF
	origin_tech = "plasmatech=2;materials=2"
	created_window = /obj/structure/window/plasmabasic
	full_window = /obj/structure/window/full/plasmabasic
	point_value = 19

/obj/item/stack/sheet/plasmaglass/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.pglass_recipes


/obj/item/stack/sheet/plasmaglass/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/rods))
		add_fingerprint(user)
		var/obj/item/stack/rods/rods = I
		if(rods.get_amount() < 1)
			to_chat(user, span_warning("There is not enough rods."))
			return ATTACK_CHAIN_PROCEED
		if(get_amount() < 1)
			to_chat(user, span_warning("There is not enough [name] sheets."))
			return ATTACK_CHAIN_PROCEED
		rods.use(1)
		to_chat(user, span_notice("You attach rods to [src]."))
		var/obj/item/stack/sheet/plasmarglass/rglass = new(drop_location())
		rglass.add_fingerprint(user)
		use(1)
		user.put_in_hands(rglass, ignore_anim = FALSE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/*
 * Reinforced plasma glass sheets
 */

GLOBAL_LIST_INIT(prglass_recipes, list ( \
	new/datum/stack_recipe/window("directional reinforced window", /obj/structure/window/plasmareinforced, time = 0, on_floor = TRUE, check_direction = TRUE), \
	new/datum/stack_recipe/window("fulltile reinforced window", /obj/structure/window/full/plasmareinforced, 2, time = 0, on_floor = TRUE, is_fulltile = TRUE) \
))

/obj/item/stack/sheet/plasmarglass
	name = "reinforced plasma glass"
	desc = "Plasma glass which seems to have rods or something stuck in them."
	singular_name = "reinforced plasma glass sheet"
	icon_state = "sheet-plasmarglass"
	item_state = "sheet-prglass"
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT/2, MAT_GLASS=MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	armor = list("melee" = 20, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	resistance_flags = ACID_PROOF
	origin_tech = "plasmatech=2;materials=2"
	created_window = /obj/structure/window/plasmareinforced
	full_window = /obj/structure/window/full/plasmareinforced
	point_value = 23

/obj/item/stack/sheet/plasmarglass/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.prglass_recipes

GLOBAL_LIST_INIT(titaniumglass_recipes, list(
	new/datum/stack_recipe/window("shuttle window", /obj/structure/window/full/shuttle, 2, time = 0, on_floor = TRUE, is_fulltile = TRUE)
	))

/obj/item/stack/sheet/titaniumglass
	name = "titanium glass"
	desc = "A glass sheet made out of a titanium-silicate alloy."
	singular_name = "titanium glass sheet"
	icon_state = "sheet-titaniumglass"
	item_state = "sheet-rglass"
	materials = list(MAT_TITANIUM=MINERAL_MATERIAL_AMOUNT, MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/titaniumglass
	full_window = /obj/structure/window/full/shuttle

/obj/item/stack/sheet/titaniumglass/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.titaniumglass_recipes

GLOBAL_LIST_INIT(plastitaniumglass_recipes, list(
	new/datum/stack_recipe/window("plastitanium window", /obj/structure/window/plastitanium, 2, time = 0, on_floor = TRUE, is_fulltile = TRUE)
	))

/obj/item/stack/sheet/plastitaniumglass
	name = "plastitanium glass"
	desc = "A glass sheet made out of a plasma-titanium-silicate alloy."
	singular_name = "plastitanium glass sheet"
	icon_state = "sheet-plastitaniumglass"
	item_state = "sheet-rglass"
	materials = list(MAT_TITANIUM=MINERAL_MATERIAL_AMOUNT, MAT_PLASMA=MINERAL_MATERIAL_AMOUNT, MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/plastitaniumglass
	full_window = /obj/structure/window/plastitanium

/obj/item/stack/sheet/plastitaniumglass/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.plastitaniumglass_recipes

GLOBAL_LIST_INIT(alglass_recipes, list ( \
	new/datum/stack_recipe/window("directional window", /obj/structure/window/abductor, time = 0, on_floor = TRUE, check_direction = TRUE), \
	new/datum/stack_recipe/window("fulltile window", /obj/structure/window/full/abductor, 2, time = 0, on_floor = TRUE, is_fulltile = TRUE) \
))

/obj/item/stack/sheet/abductorglass
	name = "alien glass"
	desc = "Alien glass which seems to vibrate every second."
	singular_name = "alien plasma glass sheet"
	icon_state = "sheet-alienglass"
	item_state = "sheet-alienglass"
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT/2, MAT_GLASS=MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	armor = list("melee" = 20, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 100)
	resistance_flags = ACID_PROOF
	created_window = /obj/structure/window/abductor
	full_window = /obj/structure/window/full/abductor

/obj/item/stack/sheet/abductorglass/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.alglass_recipes
