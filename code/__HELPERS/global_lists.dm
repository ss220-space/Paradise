/proc/makeDatumRefLists()
	// Markings
	init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, GLOB.marking_styles_list)
	// Head accessory
	init_sprite_accessory_subtypes(/datum/sprite_accessory/head_accessory, GLOB.head_accessory_styles_list)
	// Hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair, GLOB.hair_styles_public_list, GLOB.hair_styles_male_list, GLOB.hair_styles_female_list, GLOB.hair_styles_full_list)
	// Hair gradients
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair_gradient, GLOB.hair_gradients_list)
	// Facial hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, GLOB.facial_hair_styles_list, GLOB.facial_hair_styles_male_list, GLOB.facial_hair_styles_female_list)
	// Underwear
	init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, GLOB.underwear_list, GLOB.underwear_m, GLOB.underwear_f)
	// Undershirt
	init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, GLOB.undershirt_list, GLOB.undershirt_m, GLOB.undershirt_f)
	// Socks
	init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, GLOB.socks_list, GLOB.socks_m, GLOB.socks_f)
	// Alt heads
	init_sprite_accessory_subtypes(/datum/sprite_accessory/alt_heads, GLOB.alt_heads_list)

	init_datum_subtypes(/datum/wryn_building, GLOB.wryn_structures, null, "name")

	init_datum_subtypes(/datum/robot_skin, GLOB.robot_skins, null, "type")

	init_datum_subtypes(/datum/fake_administrator, GLOB.cached_fake_admins, null, "type")

	init_subtypes(/datum/surgery_step, GLOB.surgery_steps)
	init_subtypes(/obj/item/slimepotion, GLOB.slime_potions)
	init_subtypes(/datum/preference_info, GLOB.preferences_info)
	// Different bodies
	__init_body_accessory(/datum/body_accessory/body)
	// Different tails
	__init_body_accessory(/datum/body_accessory/tail)
	// Different wings
	__init_body_accessory(/datum/body_accessory/wing)

	// Setup species:accessory relations
	initialize_body_accessory_by_species()

	for(var/surgery_path in (subtypesof(/datum/surgery)))
		GLOB.surgeries_list += new surgery_path()

	init_datum_subtypes(/datum/job, GLOB.joblist, list(/datum/job/ai, /datum/job/cyborg), "title")
	init_datum_subtypes(/datum/superheroes, GLOB.all_superheroes, null, "name")
	init_datum_subtypes(/datum/language, GLOB.all_languages, null, "name")
	init_datum_subtypes(/datum/secspear_mode, GLOB.secspear_modes, null, "name")

	init_datum_subtypes(/datum/devil_contract, GLOB.devil_contracts, list(/datum/devil_contract), "contract_type")

	// Setup languages
	for(var/language_name in GLOB.all_languages)
		var/datum/language/language = GLOB.all_languages[language_name]
		if(!(language.flags & NONGLOBAL))
			GLOB.language_keys[":[lowertext(language.key)]"] = language
			GLOB.language_keys[".[lowertext(language.key)]"] = language
			GLOB.language_keys["#[lowertext(language.key)]"] = language
			GLOB.language_keys[":[sanitize_english_string_to_russian(language.key)]"] = language
			GLOB.language_keys[".[sanitize_english_string_to_russian(language.key)]"] = language
			GLOB.language_keys["#[sanitize_english_string_to_russian(language.key)]"] = language

	var/race_key_counter = 0
	for(var/species_path in subtypesof(/datum/species))
		var/datum/species/species_instance = new species_path()
		species_instance.race_key = ++race_key_counter // Used in mob icon caching.
		GLOB.all_species[species_instance.name] = species_instance

	for(var/nuke_path in typesof(/obj/machinery/nuclearbomb))
		GLOB.nuke_codes[nuke_path] = rand(10000, 99999)

	init_subtypes(/datum/crafting_recipe, GLOB.crafting_recipes)

	// Pipe list building
	init_subtypes(/datum/pipes, GLOB.construction_pipe_list)
	for(var/pipe_datum in GLOB.construction_pipe_list)
		var/datum/pipes/pipe_instance = pipe_datum
		if(pipe_instance.rpd_dispensable)
			GLOB.rpd_pipe_list += list(list("pipe_name" = pipe_instance.pipe_name, "pipe_id" = pipe_instance.pipe_id, "pipe_type" = pipe_instance.pipe_type, "pipe_category" = pipe_instance.pipe_category, "orientations" = pipe_instance.orientations, "pipe_icon" = pipe_instance.pipe_icon, "bendy" = pipe_instance.bendy))

	// Setup PAI software
	for(var/software_type in subtypesof(/datum/pai_software))
		var/datum/pai_software/software_instance = new software_type()
		if(GLOB.pai_software_by_key[software_instance.id])
			var/datum/pai_software/existing_software = GLOB.pai_software_by_key[software_instance.id]
			to_chat(world, span_warning("pAI software module [software_instance.name] has the same key as [existing_software.name]!"))
			continue
		GLOB.pai_software_by_key[software_instance.id] = software_instance

	// Setup loadout gear
	for(var/datum/gear/gear_type as anything in subtypesof(/datum/gear))
		if(gear_type == gear_type.path)
			continue

		if(gear_type == gear_type.subtype_path)
			continue

		if(!gear_type.index_name)
			stack_trace("Loadout - Missing index name: [gear_type]")
			continue
		if(!gear_type.cost)
			stack_trace("Loadout - Missing cost: [gear_type]")
			continue
		if(!gear_type.path)
			stack_trace("Loadout - Missing path definition: [gear_type]")
			continue
		gear_type = new gear_type
		var/obj/gear_item = gear_type.path
		var/list/gear_tweaks = list()
		for(var/datum/gear_tweak/tweak_type as anything in gear_type.gear_tweaks)
			gear_tweaks[tweak_type.type] += list(list(
				"name" = tweak_type.display_type,
				"icon" = tweak_type.fa_icon,
				"tooltip" = tweak_type.info,
			))

		GLOB.gear_tgui_info[gear_type.sort_category] += list(
			"[gear_type]" = list(
				"name" = gear_type.get_display_name(),
				"index_name" = gear_type.index_name,
				"desc" = gear_type.description,
				"icon" = gear_item.icon,
				"icon_state" = gear_item.icon_state,
				"cost" = gear_type.cost,
				"gear_tier" = gear_type.donator_tier,
				"allowed_roles" = gear_type.allowed_roles,
				"tweaks" = gear_tweaks,
			)
		)

		GLOB.gear_datums[gear_type.index_name] = gear_type

	// Setup a list of robolimbs
	GLOB.basic_robolimb = new()
	for(var/limb_type in typesof(/datum/robolimb))
		var/datum/robolimb/robolimb_instance = new limb_type()
		GLOB.all_robolimbs[robolimb_instance.company] = robolimb_instance
		if(!robolimb_instance.unavailable_at_chargen)
			if(robolimb_instance != BODY_ZONE_HEAD && robolimb_instance != BODY_ZONE_CHEST && robolimb_instance != BODY_ZONE_PRECISE_GROIN) // Part of the method that ensures only IPCs can access head, chest and groin prosthetics.
				if(robolimb_instance.has_subtypes) // Ensures solos get added to the list as well be incorporating has_subtypes == 1 and has_subtypes == 2.
					GLOB.chargen_robolimbs[robolimb_instance.company] = robolimb_instance // List only main brands and solo parts.
		if(robolimb_instance.selectable)
			GLOB.selectable_robolimbs[robolimb_instance.company] = robolimb_instance

	// Setup world topic handlers
	for(var/topic_handler_type in subtypesof(/datum/world_topic_handler))
		var/datum/world_topic_handler/topic_handler_instance = new topic_handler_type()
		if(!topic_handler_instance.topic_key)
			stack_trace("[topic_handler_instance.type] has no topic key!")
			continue
		if(GLOB.world_topic_handlers[topic_handler_instance.topic_key])
			stack_trace("[topic_handler_instance.type] has the same topic key as [GLOB.world_topic_handlers[topic_handler_instance.topic_key]]! ([topic_handler_instance.topic_key])")
			continue
		GLOB.world_topic_handlers[topic_handler_instance.topic_key] = topic_handler_type

	GLOB.emote_list = init_emote_list()
	GLOB.uplink_items = init_uplink_items_list()
	GLOB.mining_vendor_items = init_mining_vendor_items_list()

	GLOB.slotmachine_prizes = init_slotmachine_prizes(GLOB.uplink_items)

	GLOB.item_skins = init_item_skins()

	init_keybindings()

	// Preference toggles
	for(var/datum/preference_toggle/preference_toggle_type as anything in subtypesof(/datum/preference_toggle))
		if(!preference_toggle_type.name)
			continue

		GLOB.preference_toggles[preference_toggle_type] = new preference_toggle_type()

	// Init chemical reagents
	init_datum_subtypes(/datum/reagent, GLOB.chemical_reagents_list, null, "id")

	// Chemical Reactions - Initialises all /datum/chemical_reaction into an assoc list of: reagent -> list of chemical reactions
	// For example:
	// chemical_reaction_list["plasma"] is a list of all reactions relating to plasma
	for(var/reaction_path in subtypesof(/datum/chemical_reaction))
		var/datum/chemical_reaction/reaction_instance = new reaction_path()
		if(!length(reaction_instance?.required_reagents))
			continue

		for(var/reagent in reaction_instance.required_reagents)
			if(!GLOB.chemical_reactions_list[reagent])
				GLOB.chemical_reactions_list[reagent] = list()
			GLOB.chemical_reactions_list[reagent] += reaction_instance

	// Init disease archive
	GLOB.archive_diseases += list(
		"sneeze" = new /datum/disease/virus/advance/preset/sneezing(),
		"cough" = new /datum/disease/virus/advance/preset/cough(),
		"voice_change" = new /datum/disease/virus/advance/preset/voice_change(),
		"heal" = new /datum/disease/virus/advance/preset/heal(),
		"hallucigen" = new /datum/disease/virus/advance/preset/hullucigen(),
		"sensory_restoration" = new /datum/disease/virus/advance/preset/sensory_restoration(),
		"mind_restoration" = new /datum/disease/virus/advance/preset/mind_restoration(),
		"damage_converter:heal:viralevolution" = new /datum/disease/virus/advance/preset/advanced_regeneration(),
		"dizzy:flesh_eating:viraladaptation:youth" = new /datum/disease/virus/advance/preset/stealth_necrosis(),
		"beard:itching:voice_change" = new /datum/disease/virus/advance/preset/pre_kingstons(),
		"love" = new /datum/disease/virus/advance/preset/love(),
		"aggression" = new /datum/disease/virus/advance/preset/aggression(),
		"obsession" = new /datum/disease/virus/advance/preset/obsession(),
		"confusion" = new /datum/disease/virus/advance/preset/confusion(),
		"bones" = new /datum/disease/virus/advance/preset/bones(),
		"laugh" = new /datum/disease/virus/advance/preset/laugh(),
		"moan" = new /datum/disease/virus/advance/preset/moan(),
		"infection" = new /datum/disease/virus/advance/preset/infection(),
		"hallucigen:laugh:moan" = new /datum/disease/virus/advance/preset/pre_loyalty(),
	)

	// Init BSA fire modes list
	init_datum_subtypes(/datum/bluespace_cannon_fire_mode, GLOB.BSA_modes_list, null, "name")

	// Init list of all nutrition levels
	init_datum_subtypes(/datum/nutrition_level, GLOB.nutrition_levels, null, "type")

	// Init list for slime actions
	init_datum_subtypes(/datum/slime_action, GLOB.slime_actions, null, "name")

	var/exoframe_type = /obj/item/organ/internal/cyberimp/chest/exoframe
	for(var/obj/item/organ/internal/cyberimp/chest/exoframe/exoframe_instance as anything in subtypesof(exoframe_type))
		GLOB.exoframe_types[exoframe_instance.id] = exoframe_instance

/**
 * Creates every subtype of a given prototype (excluding the prototype itself) and adds them to a list
 *
 * Arguments:
 * * prototype - The prototype type to create subtypes of
 * * output_list - The list to add the created instances to. If not provided, a new list is created.
 */
/proc/init_subtypes(prototype, list/output_list)
	if(!istype(output_list))
		output_list = list()
	for(var/subtype_path in subtypesof(prototype))
		output_list += new subtype_path()
	return output_list

/**
 * Creates every subtype of a given prototype (excluding the prototype itself and specified exceptions)
 * and adds them to an associative list using a specified variable as the key
 *
 * Arguments:
 * * prototype - The prototype type to create subtypes of
 * * output_list - The list to add the created instances to. If not provided, a new list is created.
 * * excluded_types - List of types to exclude from creation
 * * association_variable - The name of the variable to use as the key in the associative list
 */
/proc/init_datum_subtypes(prototype, list/output_list, list/excluded_types, association_variable)
	if(!istype(output_list))
		output_list = list()
	for(var/subtype_path in subtypesof(prototype) - excluded_types)
		var/datum/new_datum = new subtype_path()
		if(istype(new_datum))
			var/association_value
			if(new_datum.vars["[association_variable]"]) // Check if the variable exists
				association_value = new_datum.vars["[association_variable]"] // Access value of variable
			if(association_value) // Value successfully retrieved
				output_list["[association_value]"] = new_datum // Add to associative list
	return output_list

/**
 * Initializes and returns an associative list of emote keys to their corresponding emote datums
 *
 * The list is structured as: key -> list of emotes with that key
 * Also includes third-person keys if defined
 */
/proc/init_emote_list()
	. = list()
	for(var/emote_path in subtypesof(/datum/emote))
		var/datum/emote/emote_instance = new emote_path()
		if(emote_instance.key)
			if(!.[emote_instance.key])
				.[emote_instance.key] = list(emote_instance)
			else
				.[emote_instance.key] += emote_instance
		else if(emote_instance.message) // Assuming all non-base emotes have this
			stack_trace("Keyless emote: [emote_instance.type]")

		if(emote_instance.additional_keys)
			for(var/a_key in emote_instance.additional_keys)
				if(!.[a_key])
					.[a_key] = list(emote_instance)
				else
					.[a_key] += emote_instance

		if(emote_instance.key_third_person) // This one is optional
			if(!.[emote_instance.key_third_person])
				.[emote_instance.key_third_person] = list(emote_instance)
			else
				.[emote_instance.key_third_person] |= emote_instance


/// Initializes and returns a list of all uplink items by creating instances of each uplink item subtype that has a defined initial item.
/proc/init_uplink_items_list()
	. = list()
	for(var/datum/uplink_item/uplink_item_type as anything in subtypesof(/datum/uplink_item))
		if(!initial(uplink_item_type.item))
			continue
		var/datum/uplink_item/uplink_item_instance = new uplink_item_type
		. += uplink_item_instance

/**
 * Use this define to register something as a purchasable!
 *
 * Arguments:
 * * equipment_name - The proper name of the purchasable
 * * object_type - The object type path of the purchasable to spawn
 * * price - The price of the purchasable in mining points
 */
#define EQUIPMENT(equipment_name, object_type, price) equipment_name = new /datum/data/mining_equipment(equipment_name, object_type, price)

/proc/init_mining_vendor_items_list()
	var/prize_list = list()
	prize_list["Gear"] = list(
		EQUIPMENT("Automatic Scanner", /obj/item/t_scanner/adv_mining_scanner/lesser, 800),
		EQUIPMENT("Advanced Scanner", /obj/item/t_scanner/adv_mining_scanner, 3000),
		EQUIPMENT("Explorer's Webbing", /obj/item/storage/belt/mining, 700),
		EQUIPMENT("Mining Weather Radio", /obj/item/radio/weather_monitor, 700),
		EQUIPMENT("Fulton Beacon", /obj/item/fulton_core, 500),
		EQUIPMENT("Mining Conscription Kit", /obj/item/storage/backpack/duffel/mining_conscript, 2000),
		EQUIPMENT("Jump Boots", /obj/item/clothing/shoes/bhop, 3000),
		EQUIPMENT("Jump Boots Implants", /obj/item/storage/box/jumpbootimplant, 7000),
		EQUIPMENT("Lazarus Capsule", /obj/item/mobcapsule, 300),
		EQUIPMENT("Lazarus Capsule belt", /obj/item/storage/belt/lazarus, 400),
		EQUIPMENT("Mining Hardsuit", /obj/item/clothing/suit/space/hardsuit/mining, 2500),
		EQUIPMENT("Tracking Implant Kit", /obj/item/storage/box/minertracker, 800),
		EQUIPMENT("Industrial Mining Satchel", /obj/item/storage/bag/ore/bigger, 500),
		EQUIPMENT("Meson Health Scanner HUD", /obj/item/clothing/glasses/hud/health/meson, 1500),
		EQUIPMENT("Mining Charge Detonator", /obj/item/detonator, 150),
	)
	prize_list["Consumables"] = list(
		EQUIPMENT("Marker Beacons (10)", /obj/item/stack/marker_beacon/ten, 100),
		EQUIPMENT("Marker Beacons (30)", /obj/item/stack/marker_beacon/thirty, 300),
		EQUIPMENT("Pocket Fire Extinguisher", /obj/item/extinguisher/mini, 400),
		EQUIPMENT("Brute First-Aid Kit", /obj/item/storage/firstaid/brute, 800),
		EQUIPMENT("Fire First-Aid Kit", /obj/item/storage/firstaid/fire, 800),
		EQUIPMENT("Emergency Charcoal Injector", /obj/item/reagent_containers/hypospray/autoinjector/charcoal, 400),
		EQUIPMENT("Mining Charge", /obj/item/grenade/plastic/miningcharge/lesser, 150),
		EQUIPMENT("Industrial Mining Charge", /obj/item/grenade/plastic/miningcharge, 500),
		EQUIPMENT("Whetstone", /obj/item/whetstone, 500),
		EQUIPMENT("Fulton Pack", /obj/item/extraction_pack, 1500),
		EQUIPMENT("Jaunter", /obj/item/wormhole_jaunter, 900),
		EQUIPMENT("Chasm Jaunter Recovery Grenade", /obj/item/grenade/jaunter_grenade, 3000), // fishing rod supremacy
		EQUIPMENT("Lazarus Injector", /obj/item/lazarus_injector, 600),
		EQUIPMENT("Point Transfer Card (500)", /obj/item/card/mining_point_card, 500),
		EQUIPMENT("Point Transfer Card (1000)", /obj/item/card/mining_point_card/thousand, 1000),
		EQUIPMENT("Point Transfer Card (5000)", /obj/item/card/mining_point_card/fivethousand, 5000),
		EQUIPMENT("Shelter Capsule", /obj/item/survivalcapsule, 700),
		EQUIPMENT("Stabilizing Serum", /obj/item/hivelordstabilizer, 600),
		EQUIPMENT("Survival Medipen", /obj/item/reagent_containers/hypospray/autoinjector/survival, 800),
		EQUIPMENT("Luxury Medipen", /obj/item/reagent_containers/hypospray/autoinjector/survival/luxury, 1500),
	)
	prize_list["Kinetic Accelerator"] = list(
		EQUIPMENT("Kinetic Accelerator", /obj/item/gun/energy/kinetic_accelerator, 1000),
		EQUIPMENT("KA Adjustable Tracer Rounds", /obj/item/borg/upgrade/modkit/tracer/adjustable, 200),
		EQUIPMENT("KA AoE Damage", /obj/item/borg/upgrade/modkit/aoe/mobs, 2500),
		EQUIPMENT("KA Cooldown Decrease", /obj/item/borg/upgrade/modkit/cooldown/haste, 1500),
		EQUIPMENT("KA Damage Increase", /obj/item/borg/upgrade/modkit/damage, 1500),
		EQUIPMENT("KA Range Increase", /obj/item/borg/upgrade/modkit/range, 1500),
		EQUIPMENT("KA Hardness Increase", /obj/item/borg/upgrade/modkit/hardness, 2500),
		EQUIPMENT("KA Offensive Mining Explosion", /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs, 3000),
		EQUIPMENT("KA Rapid Repeater", /obj/item/borg/upgrade/modkit/cooldown/repeater, 2000),
		EQUIPMENT("KA Resonator Blast", /obj/item/borg/upgrade/modkit/resonator_blasts, 2000),
		EQUIPMENT("KA Minebot Passthrough", /obj/item/borg/upgrade/modkit/minebot_passthrough, 300),
		EQUIPMENT("KA Super Chassis", /obj/item/borg/upgrade/modkit/chassis_mod, 300),
		EQUIPMENT("KA Hyper Chassis", /obj/item/borg/upgrade/modkit/chassis_mod/orange, 500),
		EQUIPMENT("KA White Tracer Rounds", /obj/item/borg/upgrade/modkit/tracer, 250),
	)
	prize_list["Digging Tools"] = list(
		EQUIPMENT("Diamond Pickaxe", /obj/item/pickaxe/diamond, 1500),
		EQUIPMENT("Kinetic Accelerator", /obj/item/gun/energy/kinetic_accelerator, 1000),
		EQUIPMENT("Kinetic Crusher", /obj/item/twohanded/kinetic_crusher, 1000),
		EQUIPMENT("Resonator", /obj/item/resonator, 400),
		EQUIPMENT("Silver Pickaxe", /obj/item/pickaxe/silver, 800),
		EQUIPMENT("Super Resonator", /obj/item/resonator/upgraded, 1200),
		EQUIPMENT("Plasma Cutter", /obj/item/gun/energy/plasmacutter, 1500),
	)
	prize_list["Minebot"] = list(
		EQUIPMENT("Nanotrasen Minebot", /obj/item/mining_drone_cube, 800),
		EQUIPMENT("Minebot AI Upgrade", /obj/item/slimepotion/sentience/mining, 1000),
		EQUIPMENT("Minebot Armor Upgrade", /obj/item/mine_bot_upgrade/health, 400),
		EQUIPMENT("Minebot Cooldown Upgrade", /obj/item/borg/upgrade/modkit/cooldown/haste/minebot, 600),
		EQUIPMENT("Minebot Melee Upgrade", /obj/item/mine_bot_upgrade, 400),
	)
	prize_list["Miscellaneous"] = list(
		EQUIPMENT("Absinthe", /obj/item/reagent_containers/food/drinks/bottle/absinthe/premium, 500),
		EQUIPMENT("Alien Toy", /obj/item/clothing/mask/facehugger/toy, 300),
		EQUIPMENT("Richard & Co cigarettes", /obj/item/storage/fancy/cigarettes/cigpack_richard, 400),
		EQUIPMENT("Cigar", /obj/item/clothing/mask/cigarette/cigar/havana, 300),
		EQUIPMENT("GAR Meson Scanners", /obj/item/clothing/glasses/meson/gar, 800),
		EQUIPMENT("GPS upgrade", /obj/item/gpsupgrade, 1500),
		EQUIPMENT("Laser Pointer", /obj/item/laser_pointer, 500),
		EQUIPMENT("Luxury Shelter Capsule", /obj/item/survivalcapsule/luxury, 5000),
		EQUIPMENT("Luxury Elite Bar Capsule", /obj/item/survivalcapsule/luxuryelite, 10000),
		EQUIPMENT("Soap", /obj/item/soap/nanotrasen, 400),
		EQUIPMENT("Space Cash", /obj/item/stack/spacecash/magic_linked, 2500),
		EQUIPMENT("Whiskey", /obj/item/reagent_containers/food/drinks/bottle/whiskey, 500),
		EQUIPMENT("HRD-MDE Project Box", /obj/item/storage/box/hardmode_box, 2500),
	)
	prize_list["Extra"] = list(
		EQUIPMENT("Extra ID", /obj/item/card/id/golem, 250),
		EQUIPMENT("Science Backpack", /obj/item/storage/backpack/science, 250),
		EQUIPMENT("Full Toolbelt", /obj/item/storage/belt/utility/full/multitool, 250),
		EQUIPMENT("Monkey Cube", /obj/item/reagent_containers/food/snacks/monkeycube, 250),
		EQUIPMENT("Royal Cape of the Liberator", /obj/item/bedsheet/rd/royal_cape, 500),
		EQUIPMENT("Grey Slime Extract", /obj/item/slime_extract/grey, 1000),
		EQUIPMENT("KA Trigger Modification Kit", /obj/item/borg/upgrade/modkit/trigger_guard, 1000),
		EQUIPMENT("Shuttle Console Board", /obj/item/circuitboard/shuttle/golem_ship, 2000),
		EQUIPMENT("The Liberator's Legacy", /obj/item/storage/box/rndboards, 2000),
	)
	prize_list["Scum"] = list(
		EQUIPMENT("Trauma Kit", /obj/item/stack/medical/bruise_pack/advanced, 150),
		EQUIPMENT("Whisky", /obj/item/reagent_containers/food/drinks/bottle/whiskey, 100),
		EQUIPMENT("Beer", /obj/item/reagent_containers/food/drinks/cans/beer, 50),
		EQUIPMENT("Absinthe", /obj/item/reagent_containers/food/drinks/bottle/absinthe/premium, 250),
		EQUIPMENT("Cigarettes", /obj/item/storage/fancy/cigarettes, 100),
		EQUIPMENT("Medical Marijuana", /obj/item/storage/fancy/cigarettes/cigpack_med, 250),
		EQUIPMENT("Richard & Co cigarettes", /obj/item/storage/fancy/cigarettes/cigpack_richard, 400),
		EQUIPMENT("Cigar", /obj/item/clothing/mask/cigarette/cigar/havana, 150),
		EQUIPMENT("Box of matches", /obj/item/storage/box/matches, 50),
		EQUIPMENT("Cheeseburger", /obj/item/reagent_containers/food/snacks/cheeseburger, 150),
		EQUIPMENT("Big Burger", /obj/item/reagent_containers/food/snacks/bigbiteburger, 250),
		EQUIPMENT("Recycled Prisoner", /obj/item/reagent_containers/food/snacks/soylentgreen, 500),
		EQUIPMENT("Crayons", /obj/item/storage/fancy/crayons, 350),
		EQUIPMENT("Plushie", /obj/random/plushie, 750),
		EQUIPMENT("Dnd set", /obj/item/storage/box/characters, 500),
		EQUIPMENT("Dice set", /obj/item/storage/box/dice, 250),
		EQUIPMENT("Cards", /obj/item/deck/cards, 150),
		EQUIPMENT("Guitar", /obj/item/instrument/guitar, 750),
		EQUIPMENT("Synthesizer", /obj/item/instrument/piano_synth, 1500),
		EQUIPMENT("Diamond Pickaxe", /obj/item/pickaxe/diamond, 2000)
	)
	return prize_list

#undef EQUIPMENT

/**
 * Updates the global mob type to movespeed multiplier lookup table from configuration
 * and optionally updates all existing mobs with the new movespeeds
 *
 * Arguments:
 * * update_mobs - If TRUE, updates all existing mobs with the new movespeeds
 */
/proc/update_config_movespeed_type_lookup(update_mobs = TRUE)
	var/list/mob_type_movespeeds = list()
	var/list/config_entries = CONFIG_GET(keyed_list/multiplicative_movespeed)
	for(var/type_path in config_entries)
		var/movespeed_multiplier = config_entries[type_path]
		if(!movespeed_multiplier)
			continue
		for(var/subtype_path in typesof(type_path))
			mob_type_movespeeds[subtype_path] = movespeed_multiplier
	GLOB.mob_config_movespeed_type_lookup = mob_type_movespeeds
	if(update_mobs)
		update_mob_config_movespeeds()

/// Updates the movement speed for all mobs in the game based on current configuration settings.
/// This iterates through all mobs in the mob list and updates their movement speed.
/proc/update_mob_config_movespeeds()
	for(var/mob/mob_instance as anything in GLOB.mob_list)
		mob_instance.update_config_movespeed()

/**
 * Initializes the list of slot machine prizes by filtering uplink items and creating prize datums
 *
 * Arguments:
 * * uplink_items - List of uplink items to consider for slot machine prizes
 */
/proc/init_slotmachine_prizes(list/uplink_items)
	var/list/allowed_uplink_items = list()
	for(var/datum/uplink_item/uplink_item as anything in uplink_items)
		if(istype(uplink_item, /datum/uplink_item/racial) || uplink_item.hijack_only)
			continue // Exclude racial and hijack-only items
		allowed_uplink_items += uplink_item

	var/list/slotmachine_prizes = list()
	for(var/datum/slotmachine_prize/prize_type as anything in subtypesof(/datum/slotmachine_prize))
		var/datum/slotmachine_prize/prize_instance = new prize_type(allowed_uplink_items)
		if(!prize_instance.id)
			continue
		slotmachine_prizes[prize_instance.id] = prize_instance

	return slotmachine_prizes


/// Initializes and returns a list of all item skins by creating instances of each item skin subtype that has a defined name.
/proc/init_item_skins()
	var/list/item_skins = list()
	for(var/datum/item_skin_data/skin_type as anything in subtypesof(/datum/item_skin_data))
		if(!initial(skin_type.name))
			continue
		var/datum/item_skin_data/skin_instance = new skin_type
		add_item_skin(item_skins, skin_instance)
	return item_skins

/**
 * Adds an item skin to the skins list, organizing by item path
 *
 * Arguments:
 * * skin_list - The list to add the skin to
 * * skin_data - The item skin datum to add
 */
/proc/add_item_skin(list/skin_list, datum/item_skin_data/skin_data)
	if(!(skin_data.item_path in skin_list))
		skin_list[skin_data.item_path] = list()
	skin_list[skin_data.item_path] += skin_data

/**
 * Checks if that loc and dir has an item on the wall
**/
// Wall mounted machinery which are visually on the wall.
GLOBAL_LIST_INIT(wallitems_interior, typecacheof(list(
	/obj/item/radio/intercom,
	/obj/item/storage/secure/safe,
	/obj/machinery/alarm,
	/obj/machinery/computer/security/telescreen,
	/obj/machinery/computer/security/telescreen/entertainment,
	/obj/machinery/defibrillator_mount,
	/obj/machinery/door_control,
	/obj/machinery/door_timer,
	/obj/machinery/embedded_controller/radio/airlock,
	/obj/machinery/firealarm,
	/obj/machinery/flasher,
	/obj/machinery/keycard_auth,
	/obj/machinery/light_switch,
	/obj/machinery/newscaster,
	/obj/machinery/power/apc,
	/obj/machinery/requests_console,
	/obj/machinery/status_display,
	/obj/structure/closet/fireaxecabinet,
	/obj/structure/extinguisher_cabinet,
	/obj/structure/mirror,
	/obj/structure/noticeboard,
	/obj/structure/reagent_dispensers/peppertank,
	/obj/structure/sign,
)))

// Wall mounted machinery which are visually coming out of the wall.
// These do not conflict with machinery which are visually placed on the wall.
GLOBAL_LIST_INIT(wallitems_exterior, typecacheof(list(
	/obj/machinery/light,
)))

/**
 * Global list of body zone constants to Russian names in all grammatical cases
 *
 * Used for getting declined body part names in messages.
 * Example: [GLOB.body_zone[limb_zone][ACCUSATIVE]] returns "голову" for BODY_ZONE_HEAD
 */
GLOBAL_LIST_INIT(body_zone, list(
	BODY_ZONE_HEAD = list(NOMINATIVE = "голова", GENITIVE = "головы", DATIVE = "голове", ACCUSATIVE = "голову", INSTRUMENTAL = "головой", PREPOSITIONAL = "голове"),
	BODY_ZONE_CHEST = list(NOMINATIVE = "грудь", GENITIVE = "груди", DATIVE = "груди", ACCUSATIVE = "грудь", INSTRUMENTAL = "грудью", PREPOSITIONAL = "груди"),
	BODY_ZONE_L_ARM = list(NOMINATIVE = "левая рука", GENITIVE = "левой руки", DATIVE = "левой руке", ACCUSATIVE = "левую руку", INSTRUMENTAL = "левой рукой", PREPOSITIONAL = "левой руке"),
	BODY_ZONE_R_ARM = list(NOMINATIVE = "правая рука", GENITIVE = "правой руки", DATIVE = "правой руке", ACCUSATIVE = "правую руку", INSTRUMENTAL = "правой рукой", PREPOSITIONAL = "правой руке"),
	BODY_ZONE_L_LEG = list(NOMINATIVE = "левая нога", GENITIVE = "левой ноги", DATIVE = "левой ноге", ACCUSATIVE = "левую ногу", INSTRUMENTAL = "левой ногой", PREPOSITIONAL = "левой ноге"),
	BODY_ZONE_R_LEG = list(NOMINATIVE = "правая нога", GENITIVE = "правой ноги", DATIVE = "правой ноге", ACCUSATIVE = "правую ногу", INSTRUMENTAL = "правой ногой", PREPOSITIONAL = "правой ноге"),
	BODY_ZONE_TAIL = list(NOMINATIVE = "хвост", GENITIVE = "хвоста", DATIVE = "хвосту", ACCUSATIVE = "хвост", INSTRUMENTAL = "хвостом", PREPOSITIONAL = "хвосте"),
	BODY_ZONE_WING = list(NOMINATIVE = "крылья", GENITIVE = "крыльев", DATIVE = "крыльям", ACCUSATIVE = "крылья", INSTRUMENTAL = "крыльями", PREPOSITIONAL = "крыльях"),
	BODY_ZONE_PRECISE_EYES = list(NOMINATIVE = "глаза", GENITIVE = "глаз", DATIVE = "глазам", ACCUSATIVE = "глаза", INSTRUMENTAL = "глазами", PREPOSITIONAL = "глазах"),
	BODY_ZONE_PRECISE_MOUTH = list(NOMINATIVE = "рот", GENITIVE = "рта", DATIVE = "рту", ACCUSATIVE = "рот", INSTRUMENTAL = "ртом", PREPOSITIONAL = "рте"),
	BODY_ZONE_PRECISE_GROIN = list(NOMINATIVE = "живот", GENITIVE = "живота", DATIVE = "животу", ACCUSATIVE = "живот", INSTRUMENTAL = "животом", PREPOSITIONAL = "животе"),
	BODY_ZONE_PRECISE_L_HAND = list(NOMINATIVE = "левая кисть", GENITIVE = "левой кисти", DATIVE = "левой кисти", ACCUSATIVE = "левую кисть", INSTRUMENTAL = "левой кистью", PREPOSITIONAL = "левой кисти"),
	BODY_ZONE_PRECISE_R_HAND = list(NOMINATIVE = "правая кисть", GENITIVE = "правой кисти", DATIVE = "правой кисти", ACCUSATIVE = "правую кисть", INSTRUMENTAL = "правой кистью", PREPOSITIONAL = "правой кисти"),
	BODY_ZONE_PRECISE_L_FOOT = list(NOMINATIVE = "левая ступня", GENITIVE = "левой ступни", DATIVE = "левой ступне", ACCUSATIVE = "левую ступню", INSTRUMENTAL = "левой ступнёй", PREPOSITIONAL = "левой ступне"),
	BODY_ZONE_PRECISE_R_FOOT = list(NOMINATIVE = "правая ступня", GENITIVE = "правой ступни", DATIVE = "правой ступне", ACCUSATIVE = "правую ступню", INSTRUMENTAL = "правой ступнёй", PREPOSITIONAL = "правой ступне"),
))
