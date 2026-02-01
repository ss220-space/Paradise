/obj/item/beacon
	name = "tracking beacon"
	desc = "A beacon used by a teleporter."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"
	origin_tech = "bluespace=1"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throw_range = 9
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 200, MAT_GLASS = 100)

	var/syndicate = FALSE
	var/area_bypass = FALSE
	/// Set if allowed to teleport to even if on zlevel2
	var/cc_beacon = FALSE

/obj/item/beacon/Initialize(mapload)
	. = ..()
	GLOB.beacons |= src

/obj/item/beacon/Destroy()
	GLOB.beacons -= src
	return ..()

/obj/item/beacon/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		syndicate = TRUE
		if(user)
			to_chat(user, span_notice("The This beacon now only be locked on to by emagged teleporters!"))

/// Probably a better way of doing this, I'm lazy.
/obj/item/beacon/bacon

/obj/item/beacon/bacon/proc/digest_delay()
	QDEL_IN(src, 60 SECONDS)

// SINGULO BEACON SPAWNER
/obj/item/beacon/syndicate
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Activate to have a singularity beacon teleported to your location</i>."
	origin_tech = "bluespace=6;syndicate=5"
	syndicate = TRUE
	var/obj/machinery/computer/syndicate_depot/teleporter/mycomputer

/obj/item/beacon/syndicate/Destroy()
	if(mycomputer)
		mycomputer.mybeacon = null
	return ..()

/obj/item/beacon/syndicate/attack_self(mob/user)
	if(!user)
		return
	if(!isturf(user.loc))
		to_chat(user, span_warning("You need space to call in!"))
		return
	to_chat(user, span_notice("Locked In"))
	new /obj/machinery/power/singularity_beacon/syndicate( user.loc )
	playsound(src, 'sound/effects/pop.ogg', 100, TRUE, 1)
	user.temporarily_remove_item_from_inventory(src)
	qdel(src)

/obj/item/beacon/syndicate/bomb
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	origin_tech = "bluespace=5;syndicate=5"
	var/bomb = /obj/machinery/syndicatebomb

/obj/item/beacon/syndicate/bomb/attack_self(mob/user)
	if(!user)
		return
	if(!isturf(user.loc))
		to_chat(user, span_warning("You need space to call in!"))
		return
	to_chat(user, span_notice("Locked In"))
	new bomb(user.loc)
	playsound(src, 'sound/effects/pop.ogg', 100, TRUE, 1)
	user.temporarily_remove_item_from_inventory(src)
	qdel(src)

/obj/item/beacon/syndicate/bomb/emp
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance EMP explosive to your location</i>."
	bomb = /obj/machinery/syndicatebomb/emp

/obj/item/beacon/syndicate/bundle
	desc = "A label on it reads: <i>Activate to select a bundle</i>."
	var/used = FALSE
	var/list/selected = list()
	var/list/unselected = list()
	var/static/list/bundles = list(
			"Bloody Spy" = list("Name" = "'Bloody Spy' Bundle",	// 220-222 TK
								"Desc" = "Complete your objectives quietly with this compilation of stealthy items.",
								/obj/item/storage/box/syndie_kit/chameleon = 1,								// 20 TK
								/obj/item/door_remote/omni/access_tuner = 1,								// 30 TK
								/obj/item/implanter/storage = 1,											// 30 TK
								/obj/item/pen/edagger = 1,													// 10 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/clothing/shoes/chameleon/noslip = 1,								// 10 TK
								/obj/item/camera_bug = 1,													// 5 TK
								/obj/item/multitool/ai_detect = 1,											// 5 TK
								/obj/item/encryptionkey/syndicate = 1,										// 0-2 TK
								/obj/item/twohanded/garrote = 1,											// 20 TK
								/obj/item/pinpointer/advpinpointer = 1,										// 20 TK
								/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,					// 5 TK
								/obj/item/flashlight/emp = 1,												// 20 TK
								/obj/item/clothing/glasses/hud/security/chameleon = 1,						// 10 TK
								/obj/item/chameleon = 1),													// 25 TK
			"Thief" = list("Name" = "'Thief' bundle",	// 155-157 TK
								"Desc" = "Steal from friends, enemies, and interstellar megacorporations alike!",
								/obj/item/storage/box/syndie_kit/counterfeiter_bundle = 1,					// 5 TK
								/obj/item/gun/energy/kinetic_accelerator/crossbow = 1,						// 45 TK
								/obj/item/chameleon = 1,													// 25 TK
								/obj/item/clothing/glasses/chameleon/thermal = 1,							// 20 TK
								/obj/item/clothing/gloves/color/black/thief = 1,							// 30 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/clothing/shoes/chameleon/noslip = 1,								// 10 TK
								/obj/item/storage/backpack/satchel_flat = 1,								// 10 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-2 TK
			"Agent 007" = list("Name" = "'Agent 007' bundle",	// 152.5-154.5 TK
								"Desc" = "Find and eliminate your targets quietly and effectively with this kit.",
								/obj/item/clothing/glasses/hud/security/chameleon = 1,						// 10 TK
								/obj/item/pen/fancy/bomb = 1,												// 30 TK
								/obj/item/gun/projectile/automatic/pistol = 1,								// 20 TK
								/obj/item/gun_module/muzzle/suppressor = 1,													// 5 TK
								/obj/item/ammo_box/magazine/m10mm = 1,										// 2.5 TK
								/obj/item/ammo_box/magazine/m10mm/hp = 1,									// 5 TK
								/obj/item/ammo_box/magazine/m10mm/ap = 2,									// 10 TK
								/obj/item/clothing/under/suit_jacket/really_black = 1,						// 0 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/clothing/suit/storage/lawyer/blackjacket/armored = 1,				// 0 TK
								/obj/item/encryptionkey/syndicate = 1,										// 0-2 TK
								/obj/item/reagent_containers/food/drinks/drinkingglass/alliescocktail = 1,	// 0 TK
								/obj/item/storage/box/syndie_kit/emp = 1,									// 10 TK
								/obj/item/CQC_manual = 1),													// 50 TK
			"Sabotage" = list("Name" = "'Sabotage' bundle",	// 195-197 TK
								"Desc" = "Wreak havoc and destruction on the station with this kit.",
								/obj/item/grenade/plastic/c4 = 2,											// 10 TK
								/obj/item/camera_bug = 1,													// 5 TK
								/obj/item/powersink = 1,													// 40 TK
								/obj/item/cartridge/syndicate = 1,											// 30 TK
								/obj/item/rcd/preloaded = 1,												// 0 TK
								/obj/item/card/emag = 1,													// 50 TK
								/obj/item/clothing/gloves/color/yellow = 1,									// 0 TK
								/obj/item/grenade/syndieminibomb = 1,										// 30 TK
								/obj/item/grenade/clusterbuster/n2o = 1,									// 10 TK
								/obj/item/storage/box/syndie_kit/space = 1,									// 20 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-2 TK
			"PayDay" = list("Name" = "'PayDay' bundle",	// 161.6-163.6 TK
								"Desc" = "Alright guys, today we're performing a heist on a space station owned by a greedy corporation.",
								/obj/item/implanter/freedom/prototype = 1,									// 6.6 TK
								/obj/item/gun/projectile/automatic/mini_uzi = 1,							// 60 TK
								/obj/item/ammo_box/magazine/uzim9mm = 2,									// 20 TK
								/obj/item/card/emag = 1,													// 50 TK
								/obj/item/jammer = 1,														// 10 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/clothing/under/suit_jacket/really_black = 1,						// 0 TK
								/obj/item/clothing/suit/storage/lawyer/blackjacket/armored = 1,				// 0 TK
								/obj/item/clothing/gloves/color/latex/nitrile = 1,							// 0 TK
								/obj/item/clothing/mask/gas/clown_hat = 1,									// 0 TK
								/obj/item/thermal_drill/diamond_drill/syndicate = 1,						// 5 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-2 TK
			"Bio-сhip" = list("Name" = "'Bio-chip' bundle",	// 140-152 TK
								"Desc" = "A few useful bio-chips to give you some options for when you inevitably get captured by the Security.",
								/obj/item/implanter/stealth = 1,											// 40 TK
								/obj/item/implanter/freedom = 1,											// 20 TK
								/obj/item/implanter/emp = 1,												// 0-10 TK
								/obj/item/implanter/adrenalin = 1,											// 28 TK
								/obj/item/implanter/heal = 1,												// 24 TK
								/obj/item/implanter/explosive = 1,											// 10 TK
								/obj/item/implanter/storage = 1,											// 30 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-2 TK

			"Hacker" = list("Name" = "'Hacker' bundle",	// 242.6-249.6 TK
								"Desc" = "A kit with everything you need to hack into and disrupt the Station, AI, its cyborgs and the Security team.",
								/obj/item/melee/energy/sword/saber = 1,										// 40 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/storage/box/syndie_kit/emp = 1,									// 10 TK
								/obj/item/camera_bug = 1,													// 5 TK
								/obj/item/door_remote/omni/access_tuner = 1,								// 30 TK
								/obj/item/implanter/freedom/prototype = 1,									// 6.6 TK
								/obj/item/ai_module/syndicate = 1,											// 40 TK
								/obj/item/card/emag = 1,													// 50 TK
								/obj/item/encryptionkey/syndicate = 1,										// 0-2 TK
								/obj/item/encryptionkey/binary = 1,											// 21 TK
								/obj/item/ai_module/toy_ai = 1,												// 0 TK
								/obj/item/storage/belt/military/traitor/hacker = 1,							// 10 TK
								/obj/item/clothing/gloves/combat = 1,										// 0-5 TK
								/obj/item/flashlight/emp = 1),												// 20 TK
			"Darklord" = list("Name" = "'Darklord' bundle",	// 100-122 TK
								"Desc" = "Turn your anger into hate and your hate into suffering with a mix of energy swords and magical powers. DO IT.",
/*								/obj/item/t_scanner = 1,
								/obj/item/clothing/gloves/color/yellow/power = 1, */	// Plan B fot 'coming soon' Martial Art.
								/obj/item/melee/energy/sword/saber/red = 2,									// 80 TK
								/obj/item/dnainjector/telemut/darkbundle = 1,								// 0 TK
								/obj/item/clothing/suit/hooded/chaplain_hoodie = 1,							// 0 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/clothing/shoes/chameleon/noslip = 1,								// 10 TK
								/obj/item/clothing/mask/chameleon = 1,										// 0-20 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-2 TK

			"Professional" = list("Name" = "'Professional' Bundle",	// 180-187 TK
								"Desc" = "Suit up and handle yourself like a professional with a long-distance sniper rifle, additional .50 standard and penetrator rounds and thermal glasses to easily scope out your target.",
								/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator = 1,   // 100 TK
								/obj/item/gun_module/rail/scope/x8 = 1,										// 0 TK
								/obj/item/ammo_box/magazine/sniper_rounds/compact = 1,						// 10 TK
								/obj/item/ammo_box/magazine/sniper_rounds/compact/penetrator = 2,			// 25 TK
								/obj/item/ammo_box/magazine/sniper_rounds/compact/soporific = 1,			// 15 TK
								/obj/item/clothing/glasses/chameleon/thermal = 1,							// 20 TK
								/obj/item/clothing/gloves/combat = 1,										// 0-5 TK
								/obj/item/clothing/under/suit_jacket/really_black = 1,						// 0 TK
								/obj/item/clothing/suit/storage/lawyer/blackjacket/armored = 1,				// 0 TK
								/obj/item/pen/edagger = 1,													// 10 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-2 TK
			"Officer" = list("Name" = "'Officer' bundle",	// 82.5-104.5 TK
								"Desc" = "Disguise yourself in plain sight as a Security officer.",
								/obj/item/encryptionkey/syndicate = 1,										// 0-2 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/clothing/glasses/hud/security/chameleon = 1,						// 10 TK
								/obj/item/clothing/mask/chameleon = 1,										// 0-20 TK
								/obj/item/storage/belt/military/traitor/sec = 1,							// 5 TK
								/obj/item/pinpointer/advpinpointer = 1,										// 20 TK
								/obj/item/gun/projectile/automatic/pistol = 1,								// 20 TK
								/obj/item/ammo_box/magazine/m10mm = 1,										// 2.5 TK
								/obj/item/ammo_box/magazine/m10mm/ap = 1,									// 5 TK
								/obj/item/ammo_box/magazine/m10mm/fire = 1,									// 5 TK
								/obj/item/ammo_box/magazine/m10mm/hp = 1,									// 5 TK
								/obj/item/storage/box/sec = 1),												// 0 TK
			"MetaOps" = list("Name" = "'MetaOps' bundle",	// 140-187 TK
								"Desc" = "Wreak chaos and disguise yourself as a nuclear operative.",
								/obj/item/mod/control/pre_equipped/traitor_elite = 1,						// 50 TK
								/obj/item/gun/projectile/automatic/shotgun/bulldog/mastiff = 1,			// 0-45 TK
								/obj/item/implanter/explosive = 1,											// 10 TK
								/obj/item/ammo_box/magazine/cheap_m12g = 2,								// 20 TK
								/obj/item/grenade/plastic/c4 = 2,											// 10 TK
								/obj/item/card/emag = 1,													// 50 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-2 TK
			"Infiltrator" = list("Name" = "'Infiltrator' bundle",	// 80-102 TK
								"Desc" = "Use your teleporter and other support tools to jump right into your desired location, quickly leaving as though you were never there.",
								/obj/item/storage/box/syndie_kit/teleporter = 1,							// 40 TK
								/obj/item/clothing/gloves/color/black/krav_maga = 1,						// 0 TK
								/obj/item/clothing/glasses/thermal = 1,										// 0-20 TK
								/obj/item/pinpointer/advpinpointer = 1,										// 20 TK
								/obj/item/rcd/preloaded = 1,												// 0 TK
								/obj/item/storage/box/syndie_kit/space = 1,									// 20 TK
								/obj/item/autoimplanter/oneuse/meson = 1,									// 0 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-2 TK
			"Grenadier" = list("Name" = "'Grenadier' bundle",	// 95-227 TK
								"Desc" = "A variety of grenades and pyrotechnics to ensure you can blast your way through any situation.",
								/obj/item/storage/belt/grenade/demolitionist = 1,							// 10-125TK
								/obj/item/gun/projectile/automatic/pistol = 1,								// 20 TK
								/obj/item/ammo_box/magazine/m10mm = 2,										// 5 TK
								/obj/item/ammo_box/magazine/m10mm/fire = 2,									// 10 TK
								/obj/item/clothing/shoes/chameleon/noslip = 1,								// 10 TK
								/obj/item/mod/control/pre_equipped/traitor = 1,								// 30 TK
								/obj/item/clothing/gloves/combat = 1,										// 0-5 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-2 TK
			"Ocelot" = list("Name" = "'Ocelot' bundle",	// 95-227 TK
								"Desc" = "It does not feel right to shoot an unarmed man… but I will get over it.",
								/obj/item/kitchen/knife/combat = 1,											// 0 TK
								/obj/item/gun/projectile/revolver = 2,                                      // 100 TK
								/obj/item/ammo_box/a357 = 2,												// 0 TK
								/obj/item/ammo_box/speedloader/a357 = 2,                                    // 5 TK
								/obj/item/clothing/under/syndicate/tacticool = 1,                           // 0 TK
								/obj/item/clothing/gloves/combat = 1,                                       // 0 TK
								/obj/item/clothing/shoes/combat = 1,                                        // 0 TK
								/obj/item/clothing/accessory/holster = 1,                                   // 5 TK
								/obj/item/clothing/head/beret = 1,                                          // 0 TK
								/obj/item/clothing/accessory/scarf/red = 1,                               	// 0 TK
								/obj/item/encryptionkey/syndicate = 1,										// 0-2 TK
								/obj/item/clothing/mask/holo_cigar = 1),                                    //20 TK

			"Metroid" = list("Name" = "Набор \"Метроид\"",	//  210 + modules + laser gun
								"Desc" = "Получите снаряжение элитного оперативника Синдиката и с боем пробейтесь через станцию!",
								/obj/item/mod/control/pre_equipped/traitor_elite = 1,
								/obj/item/mod/module/visor/thermal = 1,
								/obj/item/mod/module/stealth = 1,
								/obj/item/mod/module/power_kick = 1,
								/obj/item/mod/module/sphere_transform = 1,
								/obj/item/autoimplanter = 1,
								/obj/item/pinpointer/advpinpointer = 1,
								/obj/item/storage/box/syndidonkpockets = 1,
								/obj/item/storage/belt/utility/full/multitool = 1,
								/obj/item/clothing/head/collectable/slime = 1,
								/obj/item/encryptionkey/syndicate = 1),

			"Griefsky" = list("Name" = "Набор \"Грифски\"", // 130-220 ТК
								"Desc" = "Набор, содержащий детали для сборки Грифски.",
								/obj/item/encryptionkey/syndicate = 1,										// 0-2 TK
								/obj/item/melee/energy/sword = 4,											// 160 ТК
								/obj/item/card/id/syndicate = 1,											// 10 ТК
								/obj/item/paicard/syndicate = 1,										    // 37 TK
								/obj/item/storage/belt/military/traitor = 1,                                // 2 TK
								/obj/item/storage/toolbox/syndisuper = 1,)                                  // 8 TK
	)

/obj/item/beacon/syndicate/bundle/magical //for d20 dice of fate
	used = TRUE
	name = "suspicious 'magical' beacon"
	desc = "It looks battered and old, as if someone tried to crack it with brute force."

/obj/item/beacon/syndicate/bundle/Initialize(mapload)
	. = ..()
	unselected = bundles.Copy()
	while(length(selected) < 3)
		selected |= pick_n_take(unselected)
	selected += "Random"

/obj/item/beacon/syndicate/bundle/attack_self(mob/user)
	if(!user)
		return
	used = TRUE
	var/bundle_name = tgui_input_list(user, "Available Bundles", "Bundle Selection", selected)
	if(!bundle_name || QDELING(user) || QDELING(src))
		return
	if(bundle_name == "Random")
		bundle_name = pick(unselected)
	var/your_bundle = new /obj/item/storage/box/syndicate(user.loc, bundles[bundle_name])
	to_chat(user, span_notice("Welcome to [station_name()], [bundle_name]."))
	user.drop_item_ground(src)
	qdel(src)
	user.put_in_hands(your_bundle)

/obj/item/beacon/syndicate/bundle/check_uplink_validity()
	return !used

/obj/item/beacon/engine
	desc = "A label on it reads: <i>Warning: This device is used for transportation of high-density objects used for high-yield power generation. Stay away!</i>."
	anchored = TRUE //Let's not move these around. Some folk might get the idea to use these for assassinations
	var/list/enginetype = list()

/obj/item/beacon/engine/Initialize(mapload)
	LAZYADD(GLOB.engine_beacon_list, src)
	return ..()

/obj/item/beacon/engine/Destroy()
	GLOB.engine_beacon_list -= src
	return ..()

/obj/item/beacon/engine/tesling
	name = "Engine Beacon for Tesla and Singularity"
	enginetype = list(ENGTYPE_TESLA, ENGTYPE_SING)

/obj/item/beacon/engine/tesla
	name = "Engine Beacon for Tesla"
	enginetype = list(ENGTYPE_TESLA)

/obj/item/beacon/engine/sing
	name = "Engine Beacon for Singularity"
	enginetype = list(ENGTYPE_SING)
