/obj/item/radio/beacon
	name = "Tracking Beacon"
	desc = "A beacon used by a teleporter."
	icon_state = "beacon"
	item_state = "signaler"
	var/code = "Beacon"
	origin_tech = "bluespace=1"
	var/emagged = 0
	var/syndicate = 0
	var/area_bypass = FALSE
	var/cc_beacon = FALSE //set if allowed to teleport to even if on zlevel2

/obj/item/radio/beacon/New()
	..()
	code = "[code] ([GLOB.beacons.len + 1])"
	GLOB.beacons += src

/obj/item/radio/beacon/Destroy()
	GLOB.beacons -= src
	return ..()

/obj/item/radio/beacon/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		syndicate = 1
		if(user)
			to_chat(user, "<span class='notice'>The This beacon now only be locked on to by emagged teleporters!</span>")

/obj/item/radio/beacon/hear_talk()
	return

/obj/item/radio/beacon/talk_into()
	return FALSE

/obj/item/radio/beacon/send_hear()
	return null

/obj/item/radio/beacon/verb/alter_signal(t as text)
	set name = "Alter Beacon's Signal"
	set category = "Object"
	set src in usr

	if(usr.stat || usr.restrained())
		return

	code = t
	if(isnull(code))
		code = initial(code)
	src.add_fingerprint(usr)
	return

/obj/item/radio/beacon/bacon //Probably a better way of doing this, I'm lazy.

/obj/item/radio/beacon/bacon/proc/digest_delay()
	QDEL_IN(src, 600)

// SINGULO BEACON SPAWNER
/obj/item/radio/beacon/syndicate
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Activate to have a singularity beacon teleported to your location</i>."
	origin_tech = "bluespace=6;syndicate=5"
	syndicate = TRUE
	var/obj/machinery/computer/syndicate_depot/teleporter/mycomputer

/obj/item/radio/beacon/syndicate/Destroy()
	if(mycomputer)
		mycomputer.mybeacon = null
	return ..()

/obj/item/radio/beacon/syndicate/attack_self(mob/user)
	if(!user)
		return
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You need space to call in!</span>")
		return
	to_chat(user, "<span class='notice'>Locked In</span>")
	new /obj/machinery/power/singularity_beacon/syndicate( user.loc )
	playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
	user.temporarily_remove_item_from_inventory(src)
	qdel(src)

/obj/item/radio/beacon/syndicate/bomb
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	origin_tech = "bluespace=5;syndicate=5"
	var/bomb = /obj/machinery/syndicatebomb

/obj/item/radio/beacon/syndicate/bomb/attack_self(mob/user)
	if(!user)
		return
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You need space to call in!</span>")
		return
	to_chat(user, "<span class='notice'>Locked In</span>")
	new bomb(user.loc)
	playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
	user.temporarily_remove_item_from_inventory(src)
	qdel(src)

/obj/item/radio/beacon/syndicate/bomb/emp
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance EMP explosive to your location</i>."
	bomb = /obj/machinery/syndicatebomb/emp

/obj/item/radio/beacon/syndicate/bundle
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Activate to select a bundle</i>."
	var/used = FALSE
	var/list/selected = list()
	var/list/unselected = list()
	var/list/static/bundles = list(
				"Spy" = list(	"Name" = "\improper 'Bloody Spy' Bundle",	// 220-225 TK
								"Desc" = "Complete your objectives quietly with this compilation of stealthy items.",
								/obj/item/storage/box/syndie_kit/chameleon = 1,								// 20 TK
								/obj/item/door_remote/omni/access_tuner = 1,								// 30 TK
								/obj/item/implanter/storage = 1,											// 30 TK
								/obj/item/pen/edagger = 1,													// 10 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/clothing/shoes/chameleon/noslip = 1,								// 10 TK
								/obj/item/camera_bug = 1,													// 5 TK
								/obj/item/multitool/ai_detect = 1,											// 5 TK
								/obj/item/encryptionkey/syndicate = 1,										// 0-5 TK
								/obj/item/twohanded/garrote = 1,											// 20 TK
								/obj/item/pinpointer/advpinpointer = 1,										// 20 TK
								/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,					// 5 TK
								/obj/item/flashlight/emp = 1,												// 20 TK
								/obj/item/clothing/glasses/hud/security/chameleon = 1,						// 10 TK
								/obj/item/chameleon = 1),													// 25 TK
				"Thief" = list(	"Name" = "\improper 'Thief' bundle",	// 155-160 TK
								"Desc" = "Steal from friends, enemies, and interstellar megacorporations alike!",
								/obj/item/storage/box/syndie_kit/counterfeiter_bundle = 1,					// 5 TK
								/obj/item/gun/energy/kinetic_accelerator/crossbow = 1,						// 45 TK
								/obj/item/chameleon = 1,													// 25 TK
								/obj/item/clothing/glasses/chameleon/thermal = 1,							// 20 TK
								/obj/item/clothing/gloves/color/black/thief = 1,							// 30 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/clothing/shoes/chameleon/noslip = 1,								// 10 TK
								/obj/item/storage/backpack/satchel_flat = 1,								// 10 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-5 TK
			"Agent 007" = list(	"Name" = "\improper 'Agent 007' bundle",	// 152.5-157.5 TK
								"Desc" = "Find and eliminate your targets quietly and effectively with this kit.",
								/obj/item/clothing/glasses/hud/security/chameleon = 1,						// 10 TK
								/obj/item/pen/fancy/bomb = 1,												// 30 TK
								/obj/item/gun/projectile/automatic/pistol = 1,								// 20 TK
								/obj/item/suppressor = 1,													// 5 TK
								/obj/item/ammo_box/magazine/m10mm = 1,										// 2.5 TK
								/obj/item/ammo_box/magazine/m10mm/hp = 1,									// 5 TK
								/obj/item/ammo_box/magazine/m10mm/ap = 2,									// 10 TK
								/obj/item/clothing/under/suit_jacket/really_black = 1,						// 0 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/clothing/suit/storage/lawyer/blackjacket/armored = 1,				// 0 TK
								/obj/item/encryptionkey/syndicate = 1,										// 0-5 TK
								/obj/item/reagent_containers/food/drinks/drinkingglass/alliescocktail = 1,	// 0 TK
								/obj/item/storage/box/syndie_kit/emp = 1,									// 10 TK
								/obj/item/CQC_manual = 1),													// 50 TK
			"Sabotager" = list(	"Name" = "\improper 'Sabotage' bundle",	// 195-200 TK
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
								/obj/item/encryptionkey/syndicate = 1),										// 0-5 TK
		"Bank Robber" = list(	"Name" = "\improper 'PayDay' bundle",	// 136.6-141.6 TK
								"Desc" = "Alright guys, today we're performing a heist on a space station owned by a greedy corporation.",
								/obj/item/implanter/freedom/prototype = 1,									// 6.6 TK
								/obj/item/gun/projectile/revolver = 1,										// 50 TK
								/obj/item/ammo_box/speedloader/a357 = 2,									// 5 TK
								/obj/item/card/emag = 1,													// 50 TK
								/obj/item/jammer = 1,														// 10 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/clothing/under/suit_jacket/really_black = 1,						// 0 TK
								/obj/item/clothing/suit/storage/lawyer/blackjacket/armored = 1,				// 0 TK
								/obj/item/clothing/gloves/color/latex/nitrile = 1,							// 0 TK
								/obj/item/clothing/mask/gas/clown_hat = 1,									// 0 TK
								/obj/item/thermal_drill/diamond_drill/syndicate = 1,						// 5 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-5 TK
			"Implanter" = list(	"Name" = "\improper 'Bio-chip' bundle",	// 140-155 TK
								"Desc" = "A few useful bio-chips to give you some options for when you inevitably get captured by the Security.",
								/obj/item/implanter/stealth = 1,											// 40 TK
								/obj/item/implanter/freedom = 1,											// 20 TK
								/obj/item/implanter/emp = 1,												// 0-10 TK
								/obj/item/implanter/adrenalin = 1,											// 40 TK
								/obj/item/implanter/explosive = 1,											// 10 TK
								/obj/item/implanter/storage = 1,											// 30 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-5 TK
				"Hacker" = list("Name" = "\improper 'Hacker' bundle",	// 246.6-256.6 TK
								"Desc" = "A kit with everything you need to hack into and disrupt the Station, AI, its cyborgs and the Security team.",
								/obj/item/melee/energy/sword/saber = 1,										// 40 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/storage/box/syndie_kit/emp = 1,									// 10 TK
								/obj/item/camera_bug = 1,													// 5 TK
								/obj/item/door_remote/omni/access_tuner = 1,								// 30 TK
								/obj/item/implanter/freedom/prototype = 1,									// 6.6 TK
								/obj/item/aiModule/syndicate = 1,											// 40 TK
								/obj/item/card/emag = 1,													// 50 TK
								/obj/item/encryptionkey/syndicate = 1,										// 0-5 TK
								/obj/item/encryptionkey/binary = 1,											// 25 TK
								/obj/item/aiModule/toyAI = 1,												// 0 TK
								/obj/item/storage/belt/military/traitor/hacker = 1,							// 10 TK
								/obj/item/clothing/gloves/combat = 1,										// 0-5 TK
								/obj/item/flashlight/emp = 1),												// 20 TK
			"Dark Lord" = list(	"Name" = "\improper 'Darklord' bundle",	// 100-125 TK
								"Desc" = "Turn your anger into hate and your hate into suffering with a mix of energy swords and magical powers. DO IT.",
/*								/obj/item/t_scanner = 1,
								/obj/item/clothing/gloves/color/yellow/power = 1, */	// Plan B fot 'coming soon' Martial Art.
								/obj/item/melee/energy/sword/saber/red = 2,									// 80 TK
								/obj/item/dnainjector/telemut/darkbundle = 1,								// 0 TK
								/obj/item/clothing/suit/hooded/chaplain_hoodie = 1,							// 0 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/clothing/shoes/chameleon/noslip = 1,								// 10 TK
								/obj/item/clothing/mask/chameleon = 1,										// 0-20 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-5 TK
				"Sniper" = list("Name" = "\improper 'Professional' Bundle",	// 180-190 TK
								"Desc" = "Suit up and handle yourself like a professional with a long-distance sniper rifle, additional .50 standard and penetrator rounds and thermal glasses to easily scope out your target.",
								/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator = 1,	// 100 TK
								/obj/item/ammo_box/magazine/sniper_rounds/compact = 1,						// 10 TK
								/obj/item/ammo_box/magazine/sniper_rounds/compact/penetrator = 2,			// 25 TK
								/obj/item/ammo_box/magazine/sniper_rounds/compact/soporific = 1,			// 15 TK
								/obj/item/clothing/glasses/chameleon/thermal = 1,							// 20 TK
								/obj/item/clothing/gloves/combat = 1,										// 0-5 TK
								/obj/item/clothing/under/suit_jacket/really_black = 1,						// 0 TK
								/obj/item/clothing/suit/storage/lawyer/blackjacket/armored = 1,				// 0 TK
								/obj/item/pen/edagger = 1,													// 10 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-5 TK
			"Officer" = list(	"Name" = "\improper 'Officer' bundle",	// 82.5-107.5 TK
								"Desc" = "Disguise yourself in plain sight as a Security officer.",
								/obj/item/encryptionkey/syndicate = 1,										// 0-5 TK
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
			"Operative" = list(	"Name" = "\improper 'MetaOps' bundle",	// 140-190 TK
								"Desc" = "Wreak chaos and disguise yourself as a nuclear operative.",
								/obj/item/clothing/suit/space/hardsuit/syndi/elite = 1,						// 50 TK
								/obj/item/gun/projectile/automatic/shotgun/bulldog/mastiff = 1,			// 0-45 TK
								/obj/item/implanter/explosive = 1,											// 10 TK
								/obj/item/ammo_box/magazine/cheap_m12g = 2,								// 20 TK
								/obj/item/grenade/plastic/c4 = 2,											// 10 TK
								/obj/item/card/emag = 1,													// 50 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-5 TK
		"Infiltrator" = list(	"Name" = "\improper 'Infiltrator' bundle",	// 80-105 TK
								"Desc" = "Use your teleporter and other support tools to jump right into your desired location, quickly leaving as though you were never there.",
								/obj/item/storage/box/syndie_kit/teleporter = 1,							// 40 TK
								/obj/item/clothing/gloves/color/black/krav_maga = 1,						// 0 TK
								/obj/item/clothing/glasses/thermal = 1,										// 0-20 TK
								/obj/item/pinpointer/advpinpointer = 1,										// 20 TK
								/obj/item/rcd/preloaded = 1,												// 0 TK
								/obj/item/storage/box/syndie_kit/space = 1,									// 20 TK
								/obj/item/autoimplanter/oneuse/meson = 1,									// 0 TK
								/obj/item/encryptionkey/syndicate = 1),										// 0-5 TK
			"Grenadier" = list(	"Name" = "\improper 'Grenadier' bundle",	// 95-230 TK
								"Desc" = "A variety of grenades and pyrotechnics to ensure you can blast your way through any situation.",
								/obj/item/storage/belt/grenade/demolitionist = 1,							// 10-125TK
								/obj/item/gun/projectile/automatic/pistol = 1,								// 20 TK
								/obj/item/ammo_box/magazine/m10mm = 2,										// 5 TK
								/obj/item/ammo_box/magazine/m10mm/fire = 2,									// 10 TK
								/obj/item/clothing/shoes/chameleon/noslip = 1,								// 10 TK
								/obj/item/storage/box/syndie_kit/hardsuit = 1,								// 30 TK
								/obj/item/clothing/gloves/combat = 1,										// 0-5 TK
								/obj/item/card/id/syndicate = 1,											// 10 TK
								/obj/item/encryptionkey/syndicate = 1)										// 0-5 TK
	)

/obj/item/radio/beacon/syndicate/bundle/magical //for d20 dice of fate
	used = TRUE
	name = "suspicious 'magical' beacon"
	desc = "It looks battered and old, as if someone tried to crack it with brute force."

/obj/item/radio/beacon/syndicate/bundle/Initialize()
	. = ..()
	unselected = bundles.Copy()
	while(length(selected) < 3)
		selected |= pick_n_take(unselected)
	selected += "Random"

/obj/item/radio/beacon/syndicate/bundle/attack_self(mob/user)
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

/obj/item/radio/beacon/syndicate/bundle/check_uplink_validity()
	return !used

/obj/item/radio/beacon/engine
	desc = "A label on it reads: <i>Warning: This device is used for transportation of high-density objects used for high-yield power generation. Stay away!</i>."
	anchored = TRUE		//Let's not move these around. Some folk might get the idea to use these for assassinations
	var/list/enginetype = list()

/obj/item/radio/beacon/engine/Initialize(mapload)
	LAZYADD(GLOB.engine_beacon_list, src)
	return ..()

/obj/item/radio/beacon/engine/Destroy()
	GLOB.engine_beacon_list -= src
	return ..()

/obj/item/radio/beacon/engine/tesling
	name = "Engine Beacon for Tesla and Singularity"
	enginetype = list(ENGTYPE_TESLA, ENGTYPE_SING)

/obj/item/radio/beacon/engine/tesla
	name = "Engine Beacon for Tesla"
	enginetype = list(ENGTYPE_TESLA)

/obj/item/radio/beacon/engine/sing
	name = "Engine Beacon for Singularity"
	enginetype = list(ENGTYPE_SING)
