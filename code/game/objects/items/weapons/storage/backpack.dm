
/*
 * Backpack
 */

/obj/item/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	item_state = "backpack"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK	//ERROOOOO
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	storage_slots = 21
	resistance_flags = NONE
	max_integrity = 300
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/back.dmi',
		SPECIES_VOX_ARMALIS = 'icons/mob/clothing/species/armalis/back.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/back.dmi'
		) //For Armalis anything but this and the nitrogen tank will use the default backpack icon.
	equip_sound = 'sound/items/handling/backpack_equip.ogg'
	pickup_sound = 'sound/items/handling/backpack_pickup.ogg'
	drop_sound = 'sound/items/handling/backpack_drop.ogg'


/obj/item/storage/backpack/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!ATTACK_CHAIN_CANCEL_CHECK(.))
		playsound(loc, "rustle", 50, TRUE, -5)


/obj/item/storage/backpack/examine(mob/user)
	var/space_used = 0
	. = ..()
	if(in_range(user, src))
		for(var/obj/item/I in contents)
			space_used += I.w_class
		if(!space_used)
			. += "<span class='notice'> [src] is empty.</span>"
		else if(space_used <= max_combined_w_class*0.6)
			. += "<span class='notice'> [src] still has plenty of remaining space.</span>"
		else if(space_used <= max_combined_w_class*0.8)
			. += "<span class='notice'> [src] is beginning to run out of space.</span>"
		else if(space_used < max_combined_w_class)
			. += "<span class='notice'> [src] doesn't have much space left.</span>"
		else
			. += "<span class='notice'> [src] is full.</span>"

/*
 * Backpack Types
 */

/obj/item/storage/backpack/holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	origin_tech = "bluespace=5;materials=4;engineering=4;plasmatech=5"
	icon_state = "holdingpack"
	item_state = "holdingpack"
	max_w_class = WEIGHT_CLASS_HUGE
	max_combined_w_class = 35
	resistance_flags = FIRE_PROOF
	item_flags = NO_MAT_REDEMPTION
	cant_hold = list(/obj/item/storage/backpack/holding)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 50)


/obj/item/storage/backpack/holding/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/storage/backpack/holding))
		return ..()

	. = ATTACK_CHAIN_BLOCKED_ALL
	add_fingerprint(user)
	var/response = tgui_alert(user, "This creates a singularity, destroying you and much of the station. Are you SURE?", "IMMINENT DEATH!", list("No", "Yes"))
	if(response != "Yes")
		return .

	user.visible_message(
		span_warning("[user] grins as [user.p_they()] begin[user.p_s()] to put a Bag of Holding into a Bag of Holding!"),
		span_warning("You begin to put the Bag of Holding into the Bag of Holding!"),
	)
	var/list/play_records = params2list(user.client.prefs.exp)
	var/livingtime = text2num(play_records[EXP_TYPE_LIVING])
	if(!user.mind.special_role && !check_rights(R_ADMIN, FALSE, user) && livingtime < 9000)
		user.visible_message(
			span_notice("After careful consideration, [user] has decided that putting a Bag of Holding inside another Bag of Holding would not yield the ideal outcome."),
			span_notice("You come to the realization that this might not be the greatest idea."),
		)
		message_admins("[ADMIN_LOOKUPFLW(user)] tried to create a singularity with bag of holding (feature disabled for non-special roles)")
		add_game_logs("tried to create a singularity with bag of holding (feature disabled for non-special roles)", user)
		return .

	if(!do_after(user, 3 SECONDS, src))
		user.visible_message(
			span_notice("After careful consideration, [user] has decided that putting a Bag of Holding inside another Bag of Holding would not yield the ideal outcome."),
			span_notice("You come to the realization that this might not be the greatest idea."),
		)
		return .

	investigate_log("has become a singularity. Caused by [key_name_log(user)]", INVESTIGATE_ENGINE)
	user.visible_message(
		span_warning("[user] erupts in evil laughter as [user.p_they()] put[user.p_s()] the Bag of Holding into another Bag of Holding!"),
		span_warning("You can't help but laugh wildly as you put the Bag of Holding into another Bag of Holding, complete darkness surrounding you."),
		span_italics("You hear the sound of scientific evil brewing!"),
	)
	qdel(I)
	var/obj/singularity/singulo = new(get_turf(user))
	singulo.energy = 300 //To give it a small boost
	message_admins("[ADMIN_FULLMONTY(user)] created singularity using two bag of holding at [ADMIN_COORDJMP(singulo)]!")
	add_game_logs("created singularity using two bag of holding!", user)
	qdel(src)


/obj/item/storage/backpack/holding/satchel
	name = "Satchel of holding"
	desc = "A satchel that opens into a localized pocket of Blue Space."
	icon_state = "holdingsat"
	item_state = "holdingsat"

/obj/item/storage/backpack/holding/singularity_act(current_size)
	var/dist = max((current_size - 2),1)
	explosion(src.loc,(dist),(dist*2),(dist*4), cause = "into singularity")

/obj/item/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space on Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 400 // can store a ton of shit!


/obj/item/storage/backpack/santabag/update_icon_state()
	var/items_count = length(contents)
	switch(items_count)
		if(1 to 10)
			icon_state = "giftbag0"
		if(11 to 20)
			icon_state = "giftbag1"
		if(21 to INFINITY)
			icon_state = "giftbag2"

	update_equipped_item(update_speedmods = FALSE)


/obj/item/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity."
	icon_state = "cultpack"

/obj/item/storage/backpack/clown
	name = "Giggles Von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "clownpack"
	item_state = "clownpack"

/obj/item/storage/backpack/clown/syndie/populate_contents()
	new /obj/item/clothing/under/rank/clown(src)
	new /obj/item/clothing/shoes/magboots/clown(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/pda/clown(src)
	new /obj/item/storage/box/survival(src)
	new /obj/item/reagent_containers/food/snacks/grown/banana(src)
	new /obj/item/stamp/clown(src)
	new /obj/item/toy/crayon/rainbow(src)
	new /obj/item/storage/fancy/crayons(src)
	new /obj/item/reagent_containers/spray/waterflower(src)
	new /obj/item/reagent_containers/food/drinks/bottle/bottleofbanana(src)
	new /obj/item/instrument/bikehorn(src)
	new /obj/item/bikehorn(src)
	new /obj/item/clown_recorder(src)
	new /obj/item/dnainjector/comic(src)
	new /obj/item/implanter/sad_trombone(src)

/obj/item/storage/backpack/mime
	name = "Parcel Parceaux"
	desc = "A silent backpack made for those silent workers. Silence Co."
	icon_state = "mimepack"
	item_state = "mimepack"

/obj/item/storage/backpack/medic
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "medicalpack"
	item_state = "medicalpack"

/obj/item/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "securitypack"
	item_state = "securitypack"

/obj/item/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a special backpack made exclusively for Nanotrasen officers."
	icon_state = "captainpack"
	item_state = "captainpack"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of station life."
	icon_state = "engiepack"
	item_state = "engiepack"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/cargo
	name = "Cargo backpack"
	desc = "It's a huge backpack for daily looting of station's stashes."
	icon_state = "cargopack"
	item_state = "cargopack"

/obj/item/storage/backpack/explorer
	name = "explorer bag"
	desc = "A robust backpack for stashing your loot."
	icon_state = "explorerpack"
	item_state = "explorerpack"

/obj/item/storage/backpack/botany
	name = "botany backpack"
	desc = "It's a backpack made of all-natural fibers."
	icon_state = "botpack"
	item_state = "botpack"

/obj/item/storage/backpack/lizard
	name = "lizard skin backpack"
	desc = "A backpack made out of what appears to be supple green Unathi skin. A face can be vaguely seen on the front."
	icon_state = "lizardpack"
	item_state = "lizardpack"

/obj/item/storage/backpack/chemistry
	name = "chemistry backpack"
	desc = "A backpack specially designed to repel stains and hazardous liquids."
	icon_state = "chempack"
	item_state = "chempack"

/obj/item/storage/backpack/genetics
	name = "genetics backpack"
	desc = "A bag designed to be super tough, just in case someone hulks out on you."
	icon_state = "genepack"
	item_state = "genepack"

/obj/item/storage/backpack/science
	name = "science backpack"
	desc = "A specially designed backpack. It's fire resistant and smells vaguely of plasma."
	icon_state = "toxpack"
	item_state = "toxpack"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/virology
	name = "virology backpack"
	desc = "A backpack made of hypo-allergenic fibers. It's designed to help prevent the spread of disease. Smells like monkey."
	icon_state = "viropack"
	item_state = "viropack"

/obj/item/storage/backpack/blueshield
	name = "blueshield backpack"
	desc = "A robust backpack issued to Nanotrasen's finest."
	icon_state = "blueshieldpack"
	item_state = "blueshieldpack"

/*
*	Syndicate backpacks. Sprites by ElGood
*/
/obj/item/storage/backpack/syndicate
	name = "Рюкзак синдиката"
	desc = "Крайне подозрительный рюкзак, для подозрительных вещей. Не собственность НТ!"
	icon_state = "syndi_backpack"
	item_state = "syndi_backpack"

/obj/item/storage/backpack/syndicate/science
	name = "Рюкзак учёных синдиката"
	desc = "Крайне подозрительный рюкзак, для подозрительных колбочек. Не собственность НТ!"
	icon_state = "syndi_sci_backpack"
	item_state = "syndi_sci_backpack"

/obj/item/storage/backpack/syndicate/engineer
	name = "Рюкзак инженеров синдиката"
	icon_state = "syndi_eng_backpack"
	item_state = "syndi_eng_backpack"

/obj/item/storage/backpack/syndicate/cargo
	name = "Рюкзак грузчиков синдиката"
	desc = "Крайне подозрительный рюкзак, для подозрительных грузов. Не собственность НТ!"
	icon_state = "syndi_cargo_backpack"
	item_state = "syndi_cargo_backpack"

/obj/item/storage/backpack/syndicate/med
	name = "Рюкзак медиков синдиката"
	desc = "Крайне подозрительный рюкзак, для подозрительных лекарств. Не собственность НТ!"
	icon_state = "syndi_med_backpack"
	item_state = "syndi_med_backpack"

/obj/item/storage/backpack/syndicate/command
	name = "Рюкзак командования синдиката"
	desc = "Крайне подозрительный рюкзак, для крайне подозрительных личностей. Не собственность НТ!"
	icon_state = "syndi_com_backpack"
	item_state = "syndi_com_backpack"

/*
 * Satchel Types
 */

/obj/item/storage/backpack/satchel_norm
	name = "satchel"
	desc = "A deluxe NT Satchel, made of the highest quality leather."
	icon_state = "satchel-norm"

/obj/item/storage/backpack/satcheldeluxe
	name = "leather satchel"
	desc = "An NT Deluxe satchel, with the finest quality leather and the company logo in a thin gold stitch"
	icon_state = "nt_deluxe"
	item_state = "nt_deluxe"

/obj/item/storage/backpack/satchel_lizard
	name = "lizard skin handbag"
	desc = "A handbag made out of what appears to be supple green Unathi skin. A face can be vaguely seen on the front."
	icon_state = "satchel-lizard"

/obj/item/storage/backpack/satchel_clown
	name = "Giggles Von Robuston"
	desc = "It's a satchel made by Honk! Co."
	icon_state = "satchel-clown"

/obj/item/storage/backpack/satchel_mime
	name = "Parcel Parobust"
	desc = "A silent satchel made for those silent workers. Silence Co."
	icon_state = "satchel-mime"

/obj/item/storage/backpack/satchel_eng
	name = "industrial satchel"
	desc = "A tough satchel with extra pockets."
	icon_state = "satchel-eng"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/satchel_explorer
	name = "explorer satchel"
	desc = "A robust satchel for stashing your loot."
	icon_state = "satchel-explorer"
	item_state = "securitypack"

/obj/item/storage/backpack/satchel_med
	name = "medical satchel"
	desc = "A sterile satchel used in medical departments."
	icon_state = "satchel-med"

/obj/item/storage/backpack/satchel_vir
	name = "virologist satchel"
	desc = "A sterile satchel with virologist colours."
	icon_state = "satchel-vir"

/obj/item/storage/backpack/satchel_chem
	name = "chemist satchel"
	desc = "A sterile satchel with chemist colours."
	icon_state = "satchel-chem"

/obj/item/storage/backpack/satchel_gen
	name = "geneticist satchel"
	desc = "A sterile satchel with geneticist colours."
	icon_state = "satchel-gen"

/obj/item/storage/backpack/satchel_tox
	name = "scientist satchel"
	desc = "Useful for holding research materials."
	icon_state = "satchel-tox"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/satchel_sec
	name = "security satchel"
	desc = "A robust satchel for security related needs."
	icon_state = "satchel-sec"


/obj/item/storage/backpack/satchel_detective
	name = "forensic satchel"
	desc = "For every man, who at the bottom of his heart believes that he is a born detective."
	icon_state = "satchel-detective"

/obj/item/storage/backpack/satchel_hyd
	name = "hydroponics satchel"
	desc = "A green satchel for plant related work."
	icon_state = "satchel-hyd"

/obj/item/storage/backpack/satchel_cap
	name = "captain's satchel"
	desc = "An exclusive satchel for Nanotrasen officers."
	icon_state = "satchel-cap"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/satchel_blueshield
	name = "blueshield satchel"
	desc = "A robust satchel issued to Nanotrasen's finest."
	icon_state = "satchel-blueshield"

/obj/item/storage/backpack/satchel_blueshield/srt
	name = "SRT satchel"
	desc = "A robust satchel issued to Nanotrasen's special force."
	max_combined_w_class = 30

//make sure to not inherit backpack/satchel if you want to create a new satchel
/obj/item/storage/backpack/satchel
	name = "leather satchel"
	desc = "It's a very fancy satchel made with fine leather."
	icon_state = "satchel"
	item_state = "leather_satchel"
	resistance_flags = FIRE_PROOF
	var/strap_side_straight = FALSE

/obj/item/storage/backpack/satchel/verb/switch_strap()
	set name = "Switch Strap Side"
	set category = "Object"
	set src in usr

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	strap_side_straight = !strap_side_straight
	icon_state = strap_side_straight ? "satchel-flipped" : "satchel"
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_back()


/obj/item/storage/backpack/satchel/withwallet/populate_contents()
	new /obj/item/storage/wallet/random(src)

/obj/item/storage/backpack/satchel_flat
	name = "smuggler's satchel"
	desc = "A very slim satchel that can easily fit into tight spaces."
	icon_state = "satchel-flat"
	w_class = WEIGHT_CLASS_NORMAL //Can fit in backpacks itself.
	max_combined_w_class = 15
	level = 1
	cant_hold = list(/obj/item/storage/backpack/satchel_flat) //muh recursive backpacks

/obj/item/storage/backpack/satchel_flat/hide(intact)
	if(intact)
		invisibility = INVISIBILITY_MAXIMUM
		set_anchored(TRUE) //otherwise you can start pulling, cover it, and drag around an invisible backpack.
		icon_state = "[initial(icon_state)]2"
	else
		invisibility = initial(invisibility)
		set_anchored(FALSE)
		icon_state = initial(icon_state)

/obj/item/storage/backpack/satchel_flat/populate_contents()
	new /obj/item/stack/tile/plasteel(src)
	new /obj/item/crowbar(src)

/*
 * Duffelbags - My thanks to MrSnapWalk for the original icon and Neinhaus for the job variants - Dave.
 */

/obj/item/storage/backpack/duffel
	name = "duffelbag"
	desc = "A large grey duffelbag designed to hold more items than a regular bag."
	icon_state = "duffel"
	item_state = "duffel"
	max_combined_w_class = 30
	slowdown = 1

/obj/item/storage/backpack/duffel/durathread
	name = "durathread duffelbag"
	desc = "A large durathread duffelbag"
	icon_state = "duffel-durathread"
	item_state = "duffel-durathread"
	slowdown = 0

/obj/item/storage/backpack/duffel/syndie
	name = "suspicious looking duffelbag"
	desc = "A large duffelbag for holding extra tactical supplies."
	icon_state = "duffel-syndie"
	item_state = "duffel-syndie"
	origin_tech = "syndicate=1"
	silent = 1
	slowdown = 0
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffel/syndie/med
	name = "suspicious duffelbag"
	desc = "A black and red duffelbag with a red and white cross sewn onto it."
	icon_state = "duffel-syndimed"
	item_state = "duffel-syndimed"

/obj/item/storage/backpack/duffel/syndie/ammo
	name = "suspicious duffelbag"
	desc = "A black and red duffelbag with a patch depicting shotgun shells sewn onto it."
	icon_state = "duffel-syndiammo"
	item_state = "duffel-syndiammo"

/obj/item/storage/backpack/duffel/syndie/ammo/shotgun
	desc = "A large duffelbag, packed to the brim with auto shotguns ammo."

/obj/item/storage/backpack/duffel/syndie/ammo/shotgun/populate_contents()
	for(var/i in 1 to 8)
		new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g/dragon(src)

/obj/item/storage/backpack/duffel/syndie/ammo/shotgunXLmags
	desc = "A large duffelbag, containing three types of extended drum magazines."

/obj/item/storage/backpack/duffel/syndie/ammo/shotgunXLmags/populate_contents()
	new /obj/item/ammo_box/magazine/m12g/XtrLrg(src)
	new /obj/item/ammo_box/magazine/m12g/XtrLrg/flechette(src)
	new /obj/item/ammo_box/magazine/m12g/XtrLrg/dragon(src)

/obj/item/storage/backpack/duffel/syndie/ammo/lmg
    desc = "A large duffel bag containing 5 LMG box magazines"

/obj/item/storage/backpack/duffel/syndie/ammo/lmg/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/ammo_box/magazine/mm556x45(src)

/obj/item/storage/backpack/duffel/syndie/ammo/carbine
    desc = "A large duffel bag containing a lot of 5.56 toploader magazines, and a 40mm Grenade Ammo Box"

/obj/item/storage/backpack/duffel/syndie/ammo/carbine/populate_contents()
	new /obj/item/ammo_box/a40mm(src)
	for(var/i in 1 to 9)
		new /obj/item/ammo_box/magazine/m556(src)

/obj/item/storage/backpack/duffel/syndie/ammo/uzi
    desc = "A large duffel bag, packed to the brim with Type U3 Uzi magazines"

/obj/item/storage/backpack/duffel/syndie/ammo/uzi/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/ammo_box/magazine/uzim9mm(src)

/obj/item/storage/backpack/duffel/mining_conscript
	name = "mining conscription kit"
	desc = "A kit containing everything a crewmember needs to support a shaft miner in the field."

/obj/item/storage/backpack/duffel/mining_conscript/populate_contents()
	new /obj/item/pickaxe/mini(src)
	new /obj/item/card/mining_access_card(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/mining_scanner(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/encryptionkey/headset_cargo(src)
	new /obj/item/clothing/mask/gas/explorer(src)
	new /obj/item/gun/energy/kinetic_accelerator(src)
	new /obj/item/kitchen/knife/combat/survival(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/clothing/suit/hooded/explorer(src)
	new /obj/item/storage/bag/gem(src)
	new /obj/item/wormhole_jaunter(src)

/obj/item/storage/backpack/duffel/minebot_kit
	name = "minebot Kit"
	desc = "A kit containing everything to set up your new minebot friend."

/obj/item/storage/backpack/duffel/minebot_kit/populate_contents()
	new /obj/item/mining_drone_cube(src)
	new /obj/item/borg/upgrade/modkit/minebot_passthrough(src)
	new /obj/item/slimepotion/sentience/mining(src)
	new /obj/item/weldingtool/hugetank(src)
	new /obj/item/clothing/head/welding(src)

/obj/item/storage/backpack/duffel/vendor_ext
	name = "extraction and rescue kit"
	desc = "A kit containing everything to save your fellow miners from imminent death."

/obj/item/storage/backpack/duffel/vendor_ext/populate_contents()
	new /obj/item/extraction_pack(src)
	new /obj/item/radio/weather_monitor(src)
	new /obj/item/fulton_core(src)
	new /obj/item/stack/marker_beacon/thirty(src)
	new /obj/item/storage/box/minertracker(src)

/obj/item/storage/backpack/duffel/syndie/ammo/smg
	desc = "A large duffel bag, packed to the brim with C-20r magazines."

/obj/item/storage/backpack/duffel/syndie/ammo/smg/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/ammo_box/magazine/smgm45(src)

/obj/item/storage/backpack/duffel/syndie/c20rbundle
	desc = "A large duffel bag containing a C-20r, some magazines, and a cheap looking suppressor."

/obj/item/storage/backpack/duffel/syndie/c20rbundle/populate_contents()
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/gun/projectile/automatic/c20r(src)
	new /obj/item/suppressor/specialoffer(src)

/obj/item/storage/backpack/duffel/syndie/bulldogbundle
	desc = "A large duffel bag containing a Bulldog, some drums, and a pair of thermal imaging glasses."

/obj/item/storage/backpack/duffel/syndie/bulldogbundle/populate_contents()
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/clothing/glasses/chameleon/thermal(src)

/obj/item/storage/backpack/duffel/syndie/med/medicalbundle
	desc = "A large duffel bag containing a tactical medkit, a medical beam,  gun and a pair of syndicate magboots."

/obj/item/storage/backpack/duffel/syndie/med/medicalbundle/populate_contents()
	new /obj/item/storage/firstaid/syndie(src)
	new /obj/item/reagent_containers/applicator/dual/syndi(src)
	new /obj/item/reagent_containers/hypospray/combat(src)
	new /obj/item/defibrillator/compact/combat/loaded(src)
	new /obj/item/handheld_defibrillator/syndie(src)
	new /obj/item/organ/internal/cyberimp/arm/medibeam(src)
	new /obj/item/organ/internal/cyberimp/arm/surgery(src)
	new /obj/item/screwdriver(src)
	new /obj/item/autoimplanter(src)
	new /obj/item/clothing/suit/space/hardsuit/syndi/elite/med(src)
	new /obj/item/bodyanalyzer/advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/nanocalcium(src)
	new /obj/item/stack/medical/splint(src)

/obj/item/storage/backpack/duffel/syndie/c4/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/grenade/plastic/c4(src)

/obj/item/storage/backpack/duffel/syndie/x4/populate_contents()
	for(var/i in 1 to 3)
		new /obj/item/grenade/plastic/x4(src)

/obj/item/storage/backpack/duffel/syndie/surgery
	name = "surgery duffelbag"
	desc = "A suspicious looking duffelbag for holding surgery tools."
	icon_state = "duffel-syndimed"
	item_state = "duffel-syndimed"

/obj/item/storage/backpack/duffel/syndie/surgery/populate_contents()
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/scalpel/laser/laser2(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/circular_saw(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/bonegel(src)
	new /obj/item/bonesetter(src)
	new /obj/item/FixOVein(src)
	new /obj/item/reagent_containers/glass/bottle/morphine(src)
	new /obj/item/reagent_containers/syringe/antiviral(src)
	new /obj/item/clothing/suit/straight_jacket(src)
	new /obj/item/clothing/mask/muzzle(src)
	new /obj/item/stack/sheet/plasteel(src, 5)

/obj/item/storage/backpack/duffel/syndie/surgery_fake //for maint spawns
	name = "surgery duffelbag"
	desc = "A suspicious looking duffelbag for holding surgery tools."
	icon_state = "duffel-syndimed"
	item_state = "duffel-syndimed"

/obj/item/storage/backpack/duffel/syndie/surgery_fake/populate_contents()
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/cautery(src)
	new /obj/item/bonegel(src)
	new /obj/item/bonesetter(src)
	new /obj/item/FixOVein(src)
	if(prob(50))
		new /obj/item/circular_saw(src)
		new /obj/item/surgicaldrill(src)

/obj/item/storage/backpack/duffel/captain
	name = "captain's duffelbag"
	desc = "A duffelbag designed to hold large quantities of condoms."
	icon_state = "duffel-captain"
	item_state = "duffel-captain"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffel/security
	name = "security duffelbag"
	desc = "A duffelbag built with robust fabric!"
	icon_state = "duffel-security"
	item_state = "duffel-security"

/obj/item/storage/backpack/duffel/security/blob
	name = "Level 5 Biohazard Emergency kit"

/obj/item/storage/backpack/duffel/security/blob/populate_contents()
	new /obj/item/gun/energy/xray (src)
	new /obj/item/weldingtool/largetank (src)
	new /obj/item/clothing/glasses/sunglasses (src)
	new /obj/item/clothing/ears/earmuffs (src)
	new /obj/item/storage/box/flashbangs (src)

/obj/item/storage/backpack/duffel/security/spiders
	name = "Level 3 Biohazard Emergency kit"

/obj/item/storage/backpack/duffel/security/spiders/populate_contents()
	new /obj/item/gun/projectile/shotgun/automatic/combat (src)
	new /obj/item/ammo_box/shotgun/dragonsbreath (src)
	new /obj/item/ammo_box/shotgun/dragonsbreath (src)
	new /obj/item/clothing/mask/gas/sechailer/swat (src)
	new /obj/item/clothing/suit/armor/heavy (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/shoes/combat/swat (src)
	new /obj/item/grenade/gas/plasma (src)
	new /obj/item/grenade/gas/plasma (src)
	new /obj/item/grenade/gas/plasma (src)

/obj/item/storage/backpack/duffel/security/riot
	name = "Riot Supply Kit"

/obj/item/storage/backpack/duffel/security/riot/populate_contents()
	new /obj/item/clothing/head/helmet/riot (src)
	new /obj/item/clothing/suit/armor/riot (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/shoes/combat/swat (src)
	new /obj/item/melee/baton (src)
	new /obj/item/shield/riot/tele (src)
	new /obj/item/gun/energy/gun/pdw9 (src)
	new /obj/item/grenade/flashbang (src)
	new /obj/item/grenade/flashbang (src)
	new /obj/item/storage/box/zipties (src)
	new /obj/item/storage/box/bola (src)

/obj/item/storage/backpack/duffel/security/war
	name = "Wartime Emergency Kit"

/obj/item/storage/backpack/duffel/security/war/populate_contents()
	new /obj/item/gun/projectile/automatic/ar (src)
	new /obj/item/ammo_box/magazine/m556 (src)
	new /obj/item/ammo_box/magazine/m556 (src)
	new /obj/item/clothing/mask/gas/sechailer/swat (src)
	new /obj/item/clothing/suit/armor/heavy (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/shoes/combat/swat (src)
	new /obj/item/grenade/frag (src)

/obj/item/storage/backpack/duffel/virology
	name = "virology duffelbag"
	desc = "A white duffelbag designed to contain biohazards."
	icon_state = "duffel-viro"
	item_state = "duffel-viro"

/obj/item/storage/backpack/duffel/science
	name = "scientist duffelbag"
	desc = "A duffelbag designed to hold the secrets of space."
	icon_state = "duffel-toxins"
	item_state = "duffel-toxins"

/obj/item/storage/backpack/duffel/genetics
	name = "geneticist duffelbag"
	desc = "A duffelbag designed to hold gibbering monkies."
	icon_state = "duffel-gene"
	item_state = "duffel-gene"

/obj/item/storage/backpack/duffel/chemistry
	name = "chemist duffelbag"
	desc = "A duffelbag designed to hold corrosive substances."
	icon_state = "duffel-chemistry"
	item_state = "duffel-chemistry"

/obj/item/storage/backpack/duffel/medical
	name = "medical duffelbag"
	desc = "A duffelbag designed to hold medicine."
	icon_state = "duffel-med"
	item_state = "duffel-med"

/obj/item/storage/backpack/duffel/engineering
	name = "industrial duffelbag"
	desc = "A duffelbag designed to hold tools."
	icon_state = "duffel-eng"
	item_state = "duffel-eng"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffel/engineering/building_event
	name = "Event Building kit"

/obj/item/storage/backpack/duffel/engineering/building_event/populate_contents()
	new /obj/item/clothing/glasses/meson/sunglasses (src)
	new /obj/item/clothing/gloves/color/yellow (src)
	new /obj/item/storage/belt/utility/chief/full (src)
	new /obj/item/rcd/preloaded (src)
	new /obj/item/rcd_ammo/large (src)
	new /obj/item/rcd_ammo/large (src)

/obj/item/storage/backpack/duffel/atmos
	name = "atmospherics duffelbag"
	desc = "A duffelbag designed to hold tools. This one is specially designed for atmospherics."
	icon_state = "duffel-atmos"
	item_state = "duffel-atmos"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffel/hydro
	name = "hydroponics duffelbag"
	desc = "A duffelbag designed to hold seeds and fauna."
	icon_state = "duffel-hydro"
	item_state = "duffel-hydro"

/obj/item/storage/backpack/duffel/hydro/weed
	name = "Space Weed Emergency kit"

/obj/item/storage/backpack/duffel/hydro/weed/populate_contents()
	new /obj/item/clothing/mask/gas (src)
	new /obj/item/scythe/tele (src)
	new /obj/item/grenade/chem_grenade/antiweed (src)
	new /obj/item/grenade/chem_grenade/antiweed (src)
	new /obj/item/grenade/chem_grenade/antiweed (src)

/obj/item/storage/backpack/duffel/clown
	name = "smiles von wiggleton"
	desc = "A duffelbag designed to hold bananas and bike horns."
	icon_state = "duffel-clown"
	item_state = "duffel-clown"

/obj/item/storage/backpack/duffel/blueshield
	name = "blueshield duffelbag"
	desc = "A robust duffelbag issued to Nanotrasen's finest."
	icon_state = "duffel-blueshield"
	item_state = "duffel-blueshield"

//ERT backpacks.
/obj/item/storage/backpack/ert
	name = "emergency response team backpack"
	desc = "A spacious backpack with lots of pockets, used by members of the Nanotrasen Emergency Response Team."
	icon_state = "ert_commander"
	item_state = "backpack"
	max_combined_w_class = 30
	resistance_flags = FIRE_PROOF

//Commander
/obj/item/storage/backpack/ert/commander
	name = "emergency response team commander backpack"
	desc = "A spacious backpack with lots of pockets, worn by the commander of a Nanotrasen Emergency Response Team."

//Security
/obj/item/storage/backpack/ert/security
	name = "emergency response team security backpack"
	desc = "A spacious backpack with lots of pockets, worn by security members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_security"

//Engineering
/obj/item/storage/backpack/ert/engineer
	name = "emergency response team engineer backpack"
	desc = "A spacious backpack with lots of pockets, worn by engineering members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_engineering"

//Medical
/obj/item/storage/backpack/ert/medical
	name = "emergency response team medical backpack"
	desc = "A spacious backpack with lots of pockets, worn by medical members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_medical"

//Janitorial
/obj/item/storage/backpack/ert/janitor
	name = "emergency response team janitor backpack"
	desc = "A spacious backpack with lots of pockets, worn by janitorial members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_janitor"

//Solgov
/obj/item/storage/backpack/ert/solgov
	name = "\improper TSF marine backpack"
	desc = "A spacious backpack with lots of pockets, worn by marines of the Trans-Solar Federation."
	icon_state = "ert_solgov"

/obj/item/storage/backpack/guitarbag
	name = "Guitar bag"
	desc = "Bag for comfortable carrying your favorite guitar."
	icon_state = "guitarbag"
	item_state = "guitarbag"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_BULKY
	min_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 4
	storage_slots = 1
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/back.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/back.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/back.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/back.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/back.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/back.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/back.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/back.dmi'
		)
	can_hold = list(/obj/item/instrument, /obj/item/gun)
	cant_hold = list(/obj/item/instrument/accordion, /obj/item/instrument/harmonica)

/obj/item/storage/backpack/guitarbag/handle_item_insertion(obj/item/W, prevent_warning)
	if(!..())
		return
	playsound(src, 'sound/items/zip.ogg', 20)

/obj/item/storage/backpack/guitarbag/remove_from_storage(obj/item/W, atom/new_location)
	if(!..())
		return
	playsound(src, 'sound/items/zip.ogg', 20)

/obj/item/storage/backpack/guitarbag/with_guitar/populate_contents()
	new /obj/item/instrument/guitar(src)

/obj/item/storage/backpack/detective
	name = "forensic backpack"
	desc = "For every man, who at the bottom of his heart believes that he is a born detective."
	icon_state = "backpack_detective"
	item_state = "backpack_detective"

/obj/item/storage/backpack/duffel/detective
	name = "forensic duffelbag"
	desc = "For every man, who at the bottom of his heart believes that he is a born detective."
	icon_state = "duffel_detective"
	item_state = "duffel_detective"
