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
				"Spy" = list(	"Name" = "\improper 'Spy' Bundle",
								"Desc" = "Complete your objectives quietly with this compilation of stealthy items.",
								/obj/item/storage/box/syndie_kit/chameleon = 1,
								/obj/item/door_remote/omni/access_tuner = 1,
								/obj/item/implanter/storage = 1,
								/obj/item/pen/edagger = 1,
								/obj/item/card/id/syndicate = 1,
								/obj/item/clothing/shoes/chameleon/noslip = 1,
								/obj/item/camera_bug = 1,
								/obj/item/multitool/ai_detect = 1,
								/obj/item/encryptionkey/syndicate = 1,
								/obj/item/twohanded/garrote = 1,
								/obj/item/pinpointer/advpinpointer = 1,
								/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
								/obj/item/flashlight/emp = 1,
								/obj/item/clothing/glasses/hud/security/chameleon = 1,
								/obj/item/chameleon = 1),
				"Thief" = list(	"Name" = "\improper 'Thief' bundle",
								"Desc" = "Steal from friends, enemies, and interstellar megacorporations alike!",
								/obj/item/storage/box/syndie_kit/counterfeiter_bundle = 1,
								/obj/item/gun/energy/kinetic_accelerator/crossbow = 1,
								/obj/item/chameleon = 1,
								/obj/item/clothing/glasses/chameleon/thermal = 1,
								/obj/item/clothing/gloves/color/black/thief = 1,
								/obj/item/card/id/syndicate = 1,
								/obj/item/clothing/shoes/chameleon/noslip = 1,
								/obj/item/storage/backpack/satchel_flat = 1,
								/obj/item/encryptionkey/syndicate = 1),
			"Agent 007" = list(	"Name" = "\improper 'Agent 007' bundle",
								"Desc" = "Find and eliminate your targets quietly and effectively with this kit.",
								/obj/item/clothing/glasses/hud/security/chameleon = 1,
								/obj/item/grenade/syndieminibomb = 1, // Скин ручки бы.
								/obj/item/gun/projectile/automatic/pistol = 1,
								/obj/item/suppressor = 1,
								/obj/item/ammo_box/magazine/m10mm = 1,
								/obj/item/ammo_box/magazine/m10mm/hp = 1,
								/obj/item/ammo_box/magazine/m10mm/ap = 2,
								/obj/item/clothing/under/suit_jacket/really_black = 1,
								/obj/item/card/id/syndicate = 1,
								/obj/item/clothing/suit/storage/lawyer/blackjacket/armored = 1,
								/obj/item/encryptionkey/syndicate = 1,
								/obj/item/reagent_containers/food/drinks/drinkingglass/alliescocktail = 1,
								/obj/item/storage/box/syndie_kit/emp = 1,
								/obj/item/CQC_manual = 1),
			"Sabotager" = list(	"Name" = "\improper 'Sabotage' bundle",
								"Desc" = "Wreak havoc and destruction on the station with this kit.",
								/obj/item/grenade/plastic/c4 = 2,
								/obj/item/camera_bug = 1,
								/obj/item/powersink = 1,
								/obj/item/cartridge/syndicate = 1,
								/obj/item/rcd/preloaded = 1,
								/obj/item/card/emag = 1,
								/obj/item/clothing/gloves/color/yellow = 1,
								/obj/item/grenade/syndieminibomb = 1,
								/obj/item/grenade/clusterbuster/n2o = 1,
								/obj/item/storage/box/syndie_kit/space = 1,
								/obj/item/encryptionkey/syndicate = 1),
		"Bank Robber" = list(	"Name" = "\improper 'Heist' bundle",
								"Desc" = "Alright guys, today we're performing a heist on a space station owned by a greedy corporation.",
								/obj/item/implanter/freedom = 1, // Сделать однозарядный.
								/obj/item/gun/projectile/revolver = 1,
								/obj/item/ammo_box/speedloader/a357 = 2,
								/obj/item/card/emag = 1,
								/obj/item/jammer = 1,
								/obj/item/card/id/syndicate = 1,
								/obj/item/clothing/under/suit_jacket/really_black = 1,
								/obj/item/clothing/suit/storage/lawyer/blackjacket/armored = 1,
								/obj/item/clothing/gloves/color/latex/nitril = e1,
								/obj/item/clothing/mask/gas/clown_hat = 1,
								/obj/item/thermal_drill/diamond_drill = 1, // Сделать порт с оффов.
								/obj/item/encryptionkey/syndicate = 1),
			"Implanter" = list(	"Name" = "\improper 'Bio-chip' bundle",
								"Desc" = "A few useful bio-chips to give you some options for when you inevitably get captured by the Security.",
								/obj/item/implanter/stealth = 1,
								/obj/item/implanter/freedom = 1,
								/obj/item/implanter/emp = 1,
								/obj/item/implanter/adrenalin = 1,
								/obj/item/implanter/explosive = 1,
								/obj/item/implanter/storage = 1,
								/obj/item/encryptionkey/syndicate = 1),
				"Hacker" = list("Name" = "\improper 'Hacker' bundle",
								"Desc" = "A kit with everything you need to hack into and disrupt the Station, AI, its cyborgs and the Security team.",
								/obj/item/melee/energy/sword/saber = 1,
								/obj/item/card/id/syndicate = 1,
								/obj/item/storage/box/syndie_kit/emp = 1,
								/obj/item/camera_bug = 1,
								/obj/item/door_remote/omni/access_tuner = 1,
								/obj/item/implanter/freedom = 1, // Сделать однозарядный.
								/obj/item/aiModule/syndicate = 1,
								/obj/item/card/emag = 1,
								/obj/item/encryptionkey/syndicate = 1,
								/obj/item/encryptionkey/binary = 1,
								/obj/item/aiModule/toyAI = 1,
								/obj/item/storage/belt/military/traitor/hacker = 1,
								/obj/item/clothing/gloves/combat = 1,
								/obj/item/flashlight/emp = 1),
			"Dark Lord" = list(	"Name" = "\improper 'Darklord' bundle",
								"Desc" = "Turn your anger into hate and your hate into suffering with a mix of energy swords and magical powers. DO IT.",
/*								/obj/item/t_scanner = 1,
								/obj/item/clothing/gloves/color/yellow/power = 1, */	// Для Потрошельного.
								/obj/item/melee/energy/sword/saber/red = 2,
								/obj/item/dnainjector/telemut/darkbundle = 1,
								/obj/item/clothing/suit/hooded/chaplain_hoodie = 1,
								/obj/item/card/id/syndicate = 1,
								/obj/item/clothing/shoes/chameleon/noslip = 1,
								/obj/item/clothing/mask/chameleon = 1,
								/obj/item/encryptionkey/syndicate = 1),
				"Sniper" = list("Name" = "\improper 'Sniper' Bundle",
								"Desc" = "Suit up and handle yourself like a professional with a long-distance sniper rifle, additional .50 standard and penetrator rounds and thermal glasses to easily scope out your target.",
								/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator = 1,
								/obj/item/projectile/bullet/sniper/compact = 1,
								/obj/item/ammo_box/magazine/sniper_rounds/compact/penetrator = 2,
								/obj/item/ammo_box/magazine/sniper_rounds/compact/soporific = 1,
								/obj/item/clothing/glasses/chameleon/thermal = 1,
								/obj/item/clothing/gloves/combat = 1,
								/obj/item/clothing/under/suit_jacket/really_black = 1,
								/obj/item/clothing/suit/storage/lawyer/blackjacket/armored = 1,
								/obj/item/pen/edagger = 1,
								/obj/item/encryptionkey/syndicate = 1),
			"Officer" = list(	"Name" = "\improper 'Officer' bundle",
								"Desc" = "Disguise yourself in plain sight as a Security officer.",
								/obj/item/security_voucher = 1,
								/obj/item/encryptionkey/syndicate = 1,
								/obj/item/card/id/syndicate = 1,
								/obj/item/clothing/glasses/hud/security/chameleon = 1,
								/obj/item/clothing/mask/chameleon = 1,
								/obj/item/clothing/accessory/holster = 1,
								/obj/item/storage/belt/military/traitor/sec = 1,
								/obj/item/pinpointer/advpinpointer = 1,
								/obj/item/gun/projectile/automatic/pistol = 1,
								/obj/item/ammo_box/magazine/m10mm = 1,
								/obj/item/ammo_box/magazine/m10mm/ap = 1,
								/obj/item/ammo_box/magazine/m10mm/fire = 1,
								/obj/item/ammo_box/magazine/m10mm/hp = 1,
								/obj/item/storage/box/sec = 1,
								/obj/item/restraints/handcuffs = 1,
								/obj/item/flash = 1,
								/obj/item/implanter/mindshield = 1,
								/obj/item/clothing/suit/armor/vest/security = 1),
			"Operative" = list(	"Name" = "\improper 'Metaops' bundle",
								"Desc" = "Wreak chaos and disguise yourself as a nuclear operative.",
								/obj/item/clothing/suit/space/hardsuit/syndi/elite = 1,
								/obj/item/gun/projectile/automatic/shotgun/bulldog/standart = 1,
								/obj/item/implanter/explosive = 1,
								/obj/item/ammo_box/magazine/m12g/standart = 2,
								/obj/item/grenade/plastic/c4 = 2,
								/obj/item/card/emag = 1,
								/obj/item/encryptionkey/syndicate = 1)
		"Infiltrator" = list(	"Name" = "\improper 'Infiltrator' bundle",
								"Desc" = "Use your teleporter and other support tools to jump right into your desired location, quickly leaving as though you were never there.",
								/obj/item/storage/box/syndie_kit/teleporter = 1,
								/obj/item/clothing/gloves/color/black/krav_maga = 1,
								/obj/item/clothing/glasses/thermal = 1,
								/obj/item/pinpointer/advpinpointer = 1,
								/obj/item/rcd/preloaded = 1,
								/obj/item/storage/box/syndie_kit/space = 1,
								/obj/item/autoimplanter/oneuse = 1, //Сделать с мезонами.
								/obj/item/encryptionkey/syndicate = 1),
			"Grenadier" = list(	"Name" = "\improper 'Grenadier' bundle",
								"Desc" = "A variety of grenades and pyrotechnics to ensure you can blast your way through any situation.",
								/obj/item/storage/belt/grenade/demolitionist = 1,
								/obj/item/gun/projectile/automatic/pistol = 1,
								/obj/item/ammo_box/magazine/m10mm = 2,
								/obj/item/ammo_box/magazine/m10mm/fire = 2,
								/obj/item/clothing/shoes/chameleon/noslip = 1,
								/obj/item/storage/box/syndie_kit/hardsuit = 1,
								/obj/item/clothing/gloves/combat = 1,
								/obj/item/card/id/syndicate = 1,
								/obj/item/encryptionkey/syndicate = 1),
	)

/obj/item/radio/beacon/syndicate/bundle/Initialize()
	. = ..()
	unselected = bundles.Copy()
	while(lenght(selected) < 3)
		selected |= pick_n_take(unselected)
	selected += "Random"

/obj/item/radio/beacon/syndicate/bundle/attack_self(mob/user)
	if(!user)
		return
	var/bundle_name  = tgui_input_list(user, "Available Bundles", "Bundle Selection", selected)
	used = TRUE
	if(!bundle_name)
		return
	if(bundle_name == "Random")
		bundle_name = pick(unselected)
	var/your_bundle = new /obj/item/storage/box/syndicate(user.loc, bundles[bundle_name])
	to_chat(user, span_notice("Welcome to [station_name()], [bundle_name]."))
	user.drop_item()
	qdel(src)
	user.put_in_hands(your_bundle)

/obj/item/radio/beacon/syndicate/bundle/check_uplink_validity()
	return !used

/obj/item/radio/beacon/engine
	desc = "A label on it reads: <i>Warning: This device is used for transportation of high-density objects used for high-yield power generation. Stay away!</i>."
	anchored = 1		//Let's not move these around. Some folk might get the idea to use these for assassinations
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
