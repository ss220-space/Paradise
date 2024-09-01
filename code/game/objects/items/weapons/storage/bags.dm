/*
 *	These absorb the functionality of the plant bag, ore satchel, etc.
 *	They use the use_to_pickup, quick_gather, and quick_empty functions
 *	that were already defined in weapon/storage, but which had been
 *	re-implemented in other classes.
 *
 *	Contains:
 *		Trash Bag
 *		Mining Satchel
 *		Plant Bag
 *		Sheet Snatcher
 *		Book Bag
 *      Construction bag
 *		Tray
 *
 *	-Sayu
 */

//  Generic non-item
/obj/item/storage/bag
	allow_quick_gather = 1
	allow_quick_empty = 1
	display_contents_with_number = 1 // should work fine now
	use_to_pickup = 1
	slot_flags = ITEM_SLOT_BELT
	pickup_sound = 'sound/items/handling/backpack_pickup.ogg'
	equip_sound = 'sound/items/handling/backpack_equip.ogg'
	drop_sound = 'sound/items/handling/backpack_drop.ogg'

// -----------------------------
//          Trash bag
// -----------------------------
/obj/item/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag"

	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_SMALL
	slot_flags = NONE
	storage_slots = 30
	max_combined_w_class = 30
	can_hold = list() // any
	cant_hold = list(/obj/item/disk/nuclear)

/obj/item/storage/bag/trash/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] puts the [name] over [user.p_their()] head and starts chomping at the insides! Disgusting!</span>")
	playsound(loc, 'sound/items/eatfood.ogg', 50, 1, -1)
	return TOXLOSS


/obj/item/storage/bag/trash/update_icon_state()
	switch(length(contents))
		if(21 to INFINITY)
			icon_state = "[initial(icon_state)]3"
		if(11 to 20)
			icon_state = "[initial(icon_state)]2"
		if(1 to 10)
			icon_state = "[initial(icon_state)]1"
		else
			icon_state = "[initial(icon_state)]"
	update_equipped_item(update_speedmods = FALSE)


/obj/item/storage/bag/trash/cyborg


/obj/item/storage/bag/trash/bluespace
	name = "trash bag of holding"
	desc = "The latest and greatest in custodial convenience, a trashbag that is capable of holding vast quantities of garbage."
	icon_state = "bluetrashbag"
	origin_tech = "materials=4;bluespace=4;engineering=4;plasmatech=3"
	max_combined_w_class = 60
	storage_slots = 60
	item_flags = NO_MAT_REDEMPTION

// -----------------------------
//        Plastic Bag
// -----------------------------

/obj/item/storage/bag/plasticbag
	name = "plastic bag"
	desc = "It's a very flimsy, very noisy alternative to a bag."
	icon = 'icons/obj/trash.dmi'
	icon_state = "plasticbag"
	item_state = "plasticbag"
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_SMALL
	storage_slots = 7
	display_contents_with_number = 0 //or else this will lead to stupid behavior.
	can_hold = list() // any
	cant_hold = list(/obj/item/disk/nuclear)


/obj/item/storage/bag/plasticbag/mob_can_equip(mob/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE, bypass_incapacitated = FALSE)
	if(slot == ITEM_SLOT_HEAD && length(contents))
		if(!disable_warning)
			to_chat(M, "<span class='warning'>You need to empty the bag first!</span>")
		return FALSE
	return ..()


/obj/item/storage/bag/plasticbag/equipped(mob/user, slot, initial)
	. = ..()

	if(slot==ITEM_SLOT_HEAD)
		storage_slots = 0
		START_PROCESSING(SSobj, src)
	return

/obj/item/storage/bag/plasticbag/process()
	if(is_equipped())
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if(H.get_item_by_slot(ITEM_SLOT_HEAD) == src)
				if(H.internal)
					return
				H.AdjustLoseBreath(2 SECONDS)
	else
		storage_slots = 7
		STOP_PROCESSING(SSobj, src)
	return

// -----------------------------
//        Mining Satchel
// -----------------------------

/obj/item/storage/bag/ore
	name = "mining satchel"
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	origin_tech = "engineering=2"
	slot_flags = ITEM_SLOT_BELT
	slot_flags_2 = ITEM_FLAG_POCKET_LARGE
	w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 10
	max_combined_w_class = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * ore.w_class
	max_w_class = WEIGHT_CLASS_BULKY
	can_hold = list(/obj/item/stack/ore)

/obj/item/storage/bag/ore/bigger
	name = "industrial mining satchel"
	desc = "This bugger can be used to store and transport ores. This one has additional utility pockets for ore."
	icon_state = "satchel_better"
	storage_slots = 16 //little better

/obj/item/storage/bag/ore/cyborg
	name = "cyborg mining satchel"


/obj/item/storage/bag/ore/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)


/obj/item/storage/bag/ore/holding //miners, your messiah has arrived
	name = "mining satchel of holding"
	desc = "A revolution in convenience, this satchel allows for infinite ore storage. It's been outfitted with anti-malfunction safety measures."
	storage_slots = INFINITY
	max_combined_w_class = INFINITY
	origin_tech = "bluespace=4;materials=3;engineering=3"
	icon_state = "satchel_bspace"

/obj/item/storage/bag/ore/holding/cyborg
	name = "cyborg mining satchel of holding"


/obj/item/storage/bag/ore/holding/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)


/obj/item/storage/bag/gem
	name = "gem satchel"
	desc = "You thought it would be more like what those cartoon robbers wear."
	icon = 'icons/obj/mining.dmi'
	icon_state = "gem_satchel"
	slot_flags = ITEM_SLOT_BELT
	slot_flags_2 = ITEM_FLAG_POCKET_LARGE
	w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 48
	max_combined_w_class = 48
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(/obj/item/gem)


/obj/item/storage/bag/gem/cyborg
	name = "cyborg gem satchel"


/obj/item/storage/bag/gem/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)


// -----------------------------
//          Plant bag
// -----------------------------

/obj/item/storage/bag/plants
	name = "plant bag"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbag"
	storage_slots = 100 //the number of plant pieces it can carry.
	max_combined_w_class = 100 //Doesn't matter what this is, so long as it's more or equal to storage_slots * plants.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/reagent_containers/food/snacks/grown,/obj/item/seeds,/obj/item/grown,/obj/item/reagent_containers/food/snacks/grown/ash_flora)
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/plants/portaseeder
	name = "portable seed extractor"
	desc = "For the enterprising botanist on the go. Less efficient than the stationary model, it creates one seed per plant."
	icon_state = "portaseeder"
	origin_tech = "biotech=3;engineering=2"

/obj/item/storage/bag/plants/portaseeder/verb/dissolve_contents()
	set name = "Activate Seed Extraction"
	set category = "Object"
	set desc = "Activate to convert your plants into plantable seeds."

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	for(var/obj/item/O in contents)
		seedify(O, 1)
	for(var/mob/M in range(1))
		if(M.s_active == src)
			close(M)


// -----------------------------
//        Sheet Snatcher
// -----------------------------
// Because it stacks stacks, this doesn't operate normally.
// However, making it a storage/bag allows us to reuse existing code in some places. -Sayu

/obj/item/storage/bag/sheetsnatcher
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"
	name = "Sheet Snatcher"
	desc = "A patented Nanotrasen storage system designed for any kind of mineral sheet."

	var/capacity = 300; //the number of sheets it can carry.
	w_class = WEIGHT_CLASS_NORMAL

	allow_quick_empty = TRUE// this function is superceded

/obj/item/storage/bag/sheetsnatcher/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	if(!istype(W,/obj/item/stack/sheet) || istype(W,/obj/item/stack/sheet/mineral/sandstone) || istype(W,/obj/item/stack/sheet/wood))
		if(!stop_messages)
			to_chat(usr, "The snatcher does not accept [W].")
		return 0 //I don't care, but the existing code rejects them for not being "sheets" *shrug* -Sayu
	var/current = 0
	for(var/obj/item/stack/sheet/S in contents)
		current += S.amount
	if(capacity == current)//If it's full, you're done
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>The snatcher is full.</span>")
		return 0
	return 1


// Modified handle_item_insertion.  Would prefer not to, but...
/obj/item/storage/bag/sheetsnatcher/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	var/obj/item/stack/sheet/S = W
	if(!istype(S)) return 0

	var/amount
	var/inserted = 0
	var/current = 0
	for(var/obj/item/stack/sheet/S2 in contents)
		current += S2.amount
	if(capacity < current + S.amount)//If the stack will fill it up
		amount = capacity - current
	else
		amount = S.amount

	for(var/obj/item/stack/sheet/sheet in contents)
		if(S.type == sheet.type) // we are violating the amount limitation because these are not sane objects
			sheet.amount += amount	// they should only be removed through procs in this file, which split them up.
			S.amount -= amount
			inserted = 1
			break

	if(!inserted || !S.amount)
		usr.drop_transfer_item_to_loc(S, src)
		usr.update_icons()	//update our overlays
		if(usr.client && usr.s_active != src)
			usr.client.screen -= S
		if(!S.amount)
			qdel(S)

	if(usr.s_active)
		usr.s_active.show_to(usr)
	update_icon()
	return 1


// Sets up numbered display to show the stack size of each stored mineral
// NOTE: numbered display is turned off currently because it's broken
/obj/item/storage/bag/sheetsnatcher/orient2hud(mob/user as mob)
	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(display_contents_with_number)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/obj/item/stack/sheet/I in contents)
			adjusted_contents++
			var/datum/numbered_display/D = new/datum/numbered_display(I)
			D.number = I.amount
			numbered_contents.Add( D )

	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if(adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	src.standard_orient_objs(row_num, col_count, numbered_contents)
	return


// Modified quick_empty verb drops appropriate sized stacks
/obj/item/storage/bag/sheetsnatcher/quick_empty()
	var/location = get_turf(src)
	for(var/obj/item/stack/sheet/S in contents)
		while(S.amount)
			var/obj/item/stack/sheet/N = new S.type(location)
			var/stacksize = min(S.amount,N.max_amount)
			N.amount = stacksize
			S.amount -= stacksize
		if(!S.amount)
			qdel(S) // todo: there's probably something missing here
	if(usr.s_active)
		usr.s_active.show_to(usr)
	update_icon()

// Instead of removing
/obj/item/storage/bag/sheetsnatcher/remove_from_storage(obj/item/W, atom/new_location)
	var/obj/item/stack/sheet/S = W
	if(!istype(S)) return 0

	//I would prefer to drop a new stack, but the item/attack_hand code
	// that calls this can't recieve a different object than you clicked on.
	//Therefore, make a new stack internally that has the remainder.
	// -Sayu

	if(S.amount > S.max_amount)

		new S.type(src, S.amount - S.max_amount)

		S.amount = S.max_amount

	return ..(S,new_location)

// -----------------------------
//    Sheet Snatcher (Cyborg)
// -----------------------------

/obj/item/storage/bag/sheetsnatcher/borg
	name = "Sheet Snatcher 9000"
	desc = ""
	capacity = 500//Borgs get more because >specialization


// -----------------------------
//           Cash Bag
// -----------------------------

/obj/item/storage/bag/cash
	icon = 'icons/obj/storage.dmi'
	icon_state = "cashbag"
	name = "Cash bag"
	desc = "A bag for carrying lots of cash. It's got a big dollar sign printed on the front."
	storage_slots = 50; //the number of cash pieces it can carry.
	max_combined_w_class = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * cash.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/coin,/obj/item/stack/spacecash)

// -----------------------------
//           Book bag
// -----------------------------

/obj/item/storage/bag/books
	name = "book bag"
	desc = "A bag for books."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookbag"
	display_contents_with_number = 0 //This would look really stupid otherwise
	storage_slots = 7
	max_combined_w_class = 21
	max_w_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_BULKY //Bigger than a book because physics
	can_hold = list(/obj/item/book, /obj/item/storage/bible, /obj/item/tome, /obj/item/spellbook)
	resistance_flags = FLAMMABLE

// ------------------------------------------
//           Construction bag
// ------------------------------------------

/obj/item/storage/bag/construction
	name = "construction bag"
	desc = "A bag for construction stuff."
	icon = 'icons/obj/tools.dmi'
	icon_state = "construction_bag"
	storage_slots = 50
	max_combined_w_class = 100
	max_w_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(
		/obj/item/assembly,
		/obj/item/circuitboard,
		/obj/item/intercom_electronics,
		/obj/item/airlock_electronics,
		/obj/item/firelock_electronics,
		/obj/item/tracker_electronics,
		/obj/item/firealarm_electronics,
		/obj/item/airalarm_electronics,
		/obj/item/apc_electronics,
		/obj/item/stock_parts/cell,
		/obj/item/stock_parts,
		/obj/item/camera_assembly,
		/obj/item/access_control
	)
	resistance_flags = FLAMMABLE

/*
 * Trays - Agouri
 */
/obj/item/storage/bag/tray
	name = "tray"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "tray"
	desc = "A metal tray to lay food on."
	force = 5
	throwforce = 10.0
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_BULKY
	flags = CONDUCT
	materials = list(MAT_METAL=3000)
	cant_hold = list(/obj/item/disk/nuclear) // Prevents some cheesing


/obj/item/storage/bag/tray/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .

	playsound(target, pick('sound/items/trayhit1.ogg', 'sound/items/trayhit2.ogg'), 50, TRUE)
	if(ishuman(target) && prob(10))
		target.Knockdown(4 SECONDS)

	// Drop all the things. All of them.
	var/list/obj/item/oldContents = contents.Copy()
	drop_inventory(user)

	// Make each item scatter a bit
	for(var/obj/item/I in oldContents)
		spawn()
			for(var/i = 1, i <= rand(1,2), i++)
				if(I)
					step(I, pick(NORTH,SOUTH,EAST,WEST))
					sleep(rand(2,4))


/obj/item/storage/bag/tray/update_overlays()
	. = ..()
	for(var/obj/item/item in contents)
		. += image(icon = item.icon, icon_state = item.icon_state, layer = -1, pixel_x = rand(-4,4), pixel_y = rand(-4,4))


/obj/item/storage/bag/tray/cyborg
	var/placement_radius = 12

/obj/item/storage/bag/tray/cyborg/verb/select_placement_radius()
	set name = "Select Placement Radius"
	set category = "Object"
	set src in usr

	var/new_radius = input(usr, "Select placement radius between 0 and 16 (in pixels)", "Placement radius", 12) as num
	new_radius = clamp(new_radius, 0, 16)
	placement_radius = new_radius

/obj/item/storage/bag/tray/cyborg/afterattack(atom/target, mob/user, proximity, params)
	if(!target || !proximity)
		return

	var/obj/structure/table/table = locate() in get_turf(target)

	if(isturf(target) || table)
		var/droppedSomething = FALSE
		var/list/fancy_items
		for(var/obj/item/I in contents)
			remove_from_storage(I, get_turf(target))
			LAZYADD(fancy_items, I)
			droppedSomething = TRUE

		if(fancy_items)
			var/fancy_items_count = length(fancy_items)
			var/iteration = 0
			var/delta_phi = 2 * PI / fancy_items_count
			for(var/obj/item/I as anything in fancy_items)
				I.pixel_x = placement_radius * sin(180 * delta_phi * iteration / PI)
				I.pixel_y = placement_radius * cos(180 * delta_phi * iteration / PI)
				iteration += 1

		if(droppedSomething)
			if(table)
				user.visible_message(span_notice("[user] unloads [user.p_their()] service tray."))
			else
				user.visible_message(span_notice("[user] drops all the items on [user.p_their()] tray."))
		update_icon(UPDATE_OVERLAYS)

	return ..()


/obj/item/storage/bag/tray/cookies_tray
	var/cookie = /obj/item/reagent_containers/food/snacks/cookie


/obj/item/storage/bag/tray/cookies_tray/populate_contents() /// By Azule Utama, thank you a lot!
	for(var/i in 1 to 6)
		var/obj/item/C = new cookie(src)
		handle_item_insertion(C)    // Done this way so the tray actually has the cookies visible when spawned


/obj/item/storage/bag/tray/cookies_tray/sugarcookie
	cookie = /obj/item/reagent_containers/food/snacks/sugarcookie

/obj/item/storage/bag/tray/cookies_tray/cocochips
	cookie = /obj/item/reagent_containers/food/snacks/cocochips

/*
 *	Antag Tray
 */
/obj/item/storage/bag/dangertray
	name = "tray"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "dangertray"
	desc = "A metal tray to lay food on. The edges are razor sharp"
	force = 25
	throwforce = 25.0
	throw_speed = 3
	throw_range = 7
	armour_penetration = 15
	sharp = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	flags = CONDUCT
	materials = list(MAT_METAL=3000)


/obj/item/storage/bag/dangertray/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .

	playsound(target, pick('sound/items/trayhit1.ogg', 'sound/items/trayhit2.ogg'), 50, TRUE)
	if(ishuman(target) && prob(10))
		target.Knockdown(4 SECONDS)

	// Drop all the things. All of them.
	var/list/obj/item/oldContents = contents.Copy()
	drop_inventory(user)

	// Make each item scatter a bit
	for(var/obj/item/I in oldContents)
		spawn()
			for(var/i = 1, i <= rand(1,2), i++)
				if(I)
					step(I, pick(NORTH,SOUTH,EAST,WEST))
					sleep(rand(2,4))


/obj/item/storage/bag/dangertray/update_overlays()
	. = ..()
	for(var/obj/item/item in contents)
		. += image(icon = item.icon, icon_state = item.icon_state, layer = -1, pixel_x = rand(-4,4), pixel_y = rand(-4,4))


/*
 *	Chemistry bag
 */

/obj/item/storage/bag/chemistry
	name = "chemistry bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bag"
	item_state = "chembag"
	desc = "A bag for storing pills, patches, and bottles."
	storage_slots = 50
	max_combined_w_class = 200
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/reagent_containers/food/pill,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/glass/bottle)
	resistance_flags = FLAMMABLE
/*
 *  Biowaste bag (mostly for xenobiologists)
 */

/obj/item/storage/bag/bio
	name = "bio bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "biobag"
	desc = "A bag for the safe transportation and disposal of biowaste and other biological materials."
	storage_slots = 25
	max_combined_w_class = 200
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/slime_extract,/obj/item/reagent_containers/food/snacks/monkeycube,/obj/item/reagent_containers/syringe,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/glass/bottle,/obj/item/reagent_containers/iv_bag,/obj/item/reagent_containers/hypospray/autoinjector)
	resistance_flags = FLAMMABLE

/*
 *  Medicinal Pouch (mostly for ashwalkers)
 */

/obj/item/storage/bag/medpouch
	name = "medicinal pouch"
	icon = 'icons/obj/storage.dmi'
	icon_state = "pouch_ash"
	desc = "A small pouch for holding plants, poultices, resin, and pestles."
	storage_slots = 40
	max_combined_w_class = 200
	can_hold = list(/obj/item/reagent_containers/food/snacks/grown, /obj/item/stack/medical)
