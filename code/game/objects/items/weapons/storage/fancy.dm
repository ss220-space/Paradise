/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * WARNING: var/icon_type is used for both examine text and sprite name. Please look at the procs below and adjust your sprite names accordingly
 *		TODO: Cigarette boxes should be ported to this standard
 *
 * Contains:
 *		Donut Box
 *		Egg Box
 *		Candle Box
 *		Crayon Box
 *		Cigarette Box
 */

/obj/item/storage/fancy
	icon = 'icons/obj/food/containers.dmi'
	resistance_flags = FLAMMABLE
	var/icon_type


/obj/item/storage/fancy/update_icon_state()
	icon_state = "[icon_type]box[length(contents)]"


/obj/item/storage/fancy/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		var/len = LAZYLEN(contents)
		if(len <= 0)
			. += "<span class='notice'>There are no [src.icon_type]s left in the box.</span>"
		else if(len == 1)
			. += "<span class='notice'>There is one [src.icon_type] left in the box.</span>"
		else
			. += "<span class='notice'>There are [src.contents.len] [src.icon_type]s in the box.</span>"
/*
 * Donut Box
 */

/obj/item/storage/fancy/donut_box
	name = "donut box"
	icon_type = "donut"
	icon_state = "donutbox_back"
	storage_slots = 6
	can_hold = list(/obj/item/reagent_containers/food/snacks/donut)
	icon_type = "donut"
	foldable = /obj/item/stack/sheet/cardboard
	foldable_amt = 1


/obj/item/storage/fancy/donut_box/update_icon_state()
	return


/obj/item/storage/fancy/donut_box/update_overlays()
	. = ..()
	for(var/I = 1 to length(contents))
		var/obj/item/reagent_containers/food/snacks/donut/donut = contents[I]
		var/icon/new_donut_icon = icon(icon, "donut_[donut.donut_sprite_type]")
		new_donut_icon.Shift(EAST, 3 * (I - 1))
		. += new_donut_icon
	. += "donutbox_front"


/obj/item/storage/fancy/donut_box/populate_contents()
	for(var/i = 1 to storage_slots)
		new /obj/item/reagent_containers/food/snacks/donut(src)
	update_icon(UPDATE_OVERLAYS)


/obj/item/storage/fancy/donut_box/empty/populate_contents()
	update_icon(UPDATE_OVERLAYS)
	return

/*
 * Glowsticks Box
 */

/obj/item/storage/fancy/glowsticks_box
	name = "glowstick box"
	icon = 'icons/obj/chemglow_box.dmi'
	icon_type = "glowstick"
	icon_state = "chemglow_box_opened"
	item_state = "glowstick_box"
	storage_slots = 6
	can_hold = list(/obj/item/flashlight/flare/glowstick)
	icon_type = "chemglow"
	foldable = /obj/item/stack/sheet/cardboard
	foldable_amt = 2

/obj/item/storage/fancy/glowsticks_box/update_icon_state()
	if(length(contents) == 6)
		icon_state = "chemglow_box_closed"
	else
		icon_state = "chemglow_box_opened"

/obj/item/storage/fancy/glowsticks_box/update_overlays()
	. = ..()
	for(var/I = 1 to length(contents))
		var/obj/item/flashlight/flare/glowstick/chemglow = contents[I]
		var/icon/new_chemglow_icon = icon(icon, "chemglow_[chemglow.chemglow_sprite_type]")
		new_chemglow_icon.Shift(EAST, 2 * (I - 1))
		. += new_chemglow_icon

/obj/item/storage/fancy/glowsticks_box/populate_contents()
	for(var/i = 1 to storage_slots)
		new /obj/item/flashlight/flare/glowstick/random(src)
	update_icon(UPDATE_OVERLAYS)


/obj/item/storage/fancy/glowsticks_box/empty/populate_contents()
	update_icon(UPDATE_OVERLAYS)
	return
/*
 * Egg Box
 */

/obj/item/storage/fancy/egg_box
	icon_state = "eggbox"
	icon_type = "egg"
	item_state = "eggbox"
	name = "egg box"
	storage_slots = 12
	can_hold = list(/obj/item/reagent_containers/food/snacks/egg)

/obj/item/storage/fancy/egg_box/populate_contents()
	for(var/I = 1 to storage_slots)
		new /obj/item/reagent_containers/food/snacks/egg(src)

/*
 * Candle Box
 */

/obj/item/storage/fancy/candle_box
	name = "Candle pack"
	desc = "A pack of red candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox5"
	icon_type = "candle"
	item_state = "candlebox5"
	storage_slots = 5
	throwforce = 2
	slot_flags = ITEM_SLOT_BELT


/obj/item/storage/fancy/candle_box/full/populate_contents()
	for(var/I = 1 to storage_slots)
		new /obj/item/candle(src)

/obj/item/storage/fancy/candle_box/eternal
	name = "Eternal Candle pack"
	desc = "A pack of red candles made with a special wax."

/obj/item/storage/fancy/candle_box/eternal/populate_contents()
	for(var/I = 1 to storage_slots)
		new /obj/item/candle/eternal(src)

/*
 * Crayon Box
 */

/obj/item/storage/fancy/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox"
	w_class = WEIGHT_CLASS_SMALL
	storage_slots = 8
	icon_type = "crayon"
	can_hold = list(
		/obj/item/toy/crayon
	)

/obj/item/storage/fancy/crayons/populate_contents()
	new /obj/item/toy/crayon/white(src)
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	new /obj/item/toy/crayon/black(src)
	update_icon(UPDATE_OVERLAYS)


/obj/item/storage/fancy/crayons/update_icon_state()
	return


/obj/item/storage/fancy/crayons/update_overlays()
	. = ..()
	for(var/obj/item/toy/crayon/crayon in contents)
		. += crayon.colourName


/obj/item/storage/fancy/crayons/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/crayon = I
		switch(crayon.colourName)
			if("mime")
				add_fingerprint(user)
				to_chat(user, span_notice("This crayon is too sad to be contained in this box."))
				return ATTACK_CHAIN_PROCEED
			if("rainbow")
				add_fingerprint(user)
				to_chat(user, span_notice("This crayon is too powerful to be contained in this box."))
				return ATTACK_CHAIN_PROCEED
	return ..()


////////////
//CIG PACK//
////////////
/obj/item/storage/fancy/cigarettes
	name = "cigarette packet"
	desc = "The most popular brand of Space Cigarettes, sponsors of the Space Olympics."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigpacket"
	item_state = "cigpacket"
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 2
	slot_flags = ITEM_SLOT_BELT
	storage_slots = 20
	max_combined_w_class = 20
	display_contents_with_number = 1
	can_hold = list(/obj/item/clothing/mask/cigarette,
		/obj/item/lighter,
		/obj/item/match)
	cant_hold = list(/obj/item/clothing/mask/cigarette/cigar,
		/obj/item/clothing/mask/cigarette/pipe,
		/obj/item/lighter/zippo)
	icon_type = "cigarette"
	var/cigarette_type = /obj/item/clothing/mask/cigarette

/obj/item/storage/fancy/cigarettes/populate_contents()
	for(var/i = 1 to storage_slots)
		new cigarette_type(src)

/obj/item/storage/fancy/cigarettes/update_icon_state()
	var/init_state = initial(icon_state)
	switch(length(contents))
		if(17 to INFINITY)
			icon_state = "[init_state]6"
		if(14 to 16)
			icon_state = "[init_state]5"
		if(11 to 13)
			icon_state = "[init_state]4"
		if(7 to 10)
			icon_state = "[init_state]3"
		if(4 to 6)
			icon_state = "[init_state]2"
		if(1 to 3)
			icon_state = "[init_state]1"
		else
			icon_state = "[init_state]0"


/obj/item/storage/fancy/cigarettes/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ishuman(target) || user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		return ..()

	. = ATTACK_CHAIN_PROCEED
	var/obj/item/clothing/mask/cigarette/cigar = locate() in src
	if(!cigar)
		to_chat(user, span_warning("There are no smokables in the pack!"))
		return .

	if(target.equip_to_slot_if_possible(cigar, ITEM_SLOT_MASK, disable_warning = TRUE))
		. |= ATTACK_CHAIN_SUCCESS
		to_chat(user, span_notice("You took [cigar.name] out of the pack[target != user ? " and deftly place it in [target]'s mouth" : ""]."))
	else
		to_chat(user, span_warning("Something is blocking [target]'s mouth!"))


/obj/item/storage/fancy/cigarettes/can_be_inserted(obj/item/W , stop_messages = 0)
	if(istype(W, /obj/item/match))
		var/obj/item/match/match = W
		if(match.lit)
			if(!stop_messages)
				to_chat(usr, span_notice("Putting a lit [W] in [src] probably isn't a good idea."))
			return FALSE
	if(istype(W, /obj/item/lighter))
		var/obj/item/lighter/lighter = W
		if(lighter.lit)
			if(!stop_messages)
				to_chat(usr, span_notice("Putting [W] in [src] while lit probably isn't a good idea."))
			return FALSE
	return ..()


/obj/item/storage/fancy/cigarettes/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!length(contents))
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/storage/fancy/cigarettes/dromedaryco
	name = "\improper DromedaryCo packet"
	desc = "A packet of twenty imported DromedaryCo cancer sticks. A label on the packaging reads, \"Wouldn't a slow death make a change?\""
	icon_state = "Dpacket"
	item_state = "Dpacket"


/obj/item/storage/fancy/cigarettes/syndicate
	name = "\improper Syndicate Cigarettes"
	desc = "A packet of twenty evil-looking cigarettes, A label on the packaging reads, \"Donk Co\""
	icon_state = "robustpacket"
	item_state = "robustpacket"

/obj/item/storage/fancy/cigarettes/syndicate/New()
	..()
	var/new_name = pick("evil", "suspicious", "ominous", "donk-flavored", "robust", "sneaky")
	name = "[new_name] cigarette packet"

/obj/item/storage/fancy/cigarettes/cigpack_syndicate
	name = "cigarette packet"
	desc = "An obscure brand of cigarettes."
	icon_state = "syndiepacket"
	item_state = "syndiepacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/syndicate

/obj/item/storage/fancy/cigarettes/cigpack_med
	name = "Medical Marijuana Packet"
	desc = "A prescription packet containing twenty marijuana cigarettes."
	icon_state = "medpacket"
	item_state = "medpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/medical_marijuana


/obj/item/storage/fancy/cigarettes/cigpack_uplift
	name = "\improper Uplift Smooth packet"
	desc = "Your favorite brand, now menthol flavored."
	icon_state = "upliftpacket"
	item_state = "upliftpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/menthol

/obj/item/storage/fancy/cigarettes/cigpack_richard
	name = "\improper Richard & Co cigarettes"
	desc = "Курят только отчаянные."
	cigarette_type = /obj/item/clothing/mask/cigarette/richard

/obj/item/storage/fancy/cigarettes/cigpack_robust
	name = "\improper Robust packet"
	desc = "Smoked by the robust."
	icon_state = "robustpacket"
	item_state = "robustpacket"

/obj/item/storage/fancy/cigarettes/cigpack_robustgold
	name = "\improper Robust Gold packet"
	desc = "Smoked by the truly robust."
	icon_state = "robustgpacket"
	item_state = "robustgpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/robustgold

/obj/item/storage/fancy/cigarettes/cigpack_carp
	name = "\improper Carp Classic packet"
	desc = "Since 2313."
	icon_state = "carppacket"
	item_state = "carppacket"

/obj/item/storage/fancy/cigarettes/cigpack_midori
	name = "\improper Midori Tabako packet"
	desc = "You can't understand the runes, but the packet smells funny."
	icon_state = "midoripacket"
	item_state = "midoripacket"

/obj/item/storage/fancy/cigarettes/cigpack_shadyjims
	name ="\improper Shady Jim's Super Slims"
	desc = "Is your weight slowing you down? Having trouble running away from gravitational singularities? Can't stop stuffing your mouth? Smoke Shady Jim's Super Slims and watch all that fat burn away. Guaranteed results!"
	icon_state = "shadyjimpacket"
	item_state = "shadyjimpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/shadyjims

/obj/item/storage/fancy/cigarettes/cigpack_random
	name ="\improper Embellished Enigma packet"
	desc = "For the true connoisseur of exotic flavors."
	icon_state = "shadyjimpacket"
	item_state = "shadyjimpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/random

/obj/item/storage/fancy/rollingpapers
	name = "rolling paper pack"
	desc = "A pack of Nanotrasen brand rolling papers."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper_pack"
	item_state = "cig_paper_pack"
	storage_slots = 10
	icon_type = "rolling paper"
	can_hold = list(/obj/item/rollingpaper)


/obj/item/storage/fancy/rollingpapers/populate_contents()
	for(var/i in 1 to storage_slots)
		new /obj/item/rollingpaper(src)


/obj/item/storage/fancy/rollingpapers/update_icon_state()
	return


/obj/item/storage/fancy/rollingpapers/update_overlays()
	. = ..()
	if(!length(contents))
		. += "[icon_state]_empty"

/*
 * cigcase
 */

/obj/item/storage/fancy/cigcase
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigarcase"
	icon_type = "cigar"
	name = "Cigar Case"
	storage_slots = 7
	can_hold = list(/obj/item/clothing/mask/cigarette/cigar)


/obj/item/storage/fancy/cigcase/update_icon_state()
	icon_state = "[icon_type]case[length(contents)]"


/obj/item/storage/fancy/cigcase/populate_contents()
	for(var/I = 1 to storage_slots)
		new /obj/item/clothing/mask/cigarette/cigar(src)

/*
 * Vial Box
 */

/obj/item/storage/fancy/vials
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox6"
	icon_type = "vial"
	name = "vial storage box"
	storage_slots = 6
	can_hold = list(/obj/item/reagent_containers/glass/beaker/vial)

/obj/item/storage/fancy/vials/populate_contents()
	for(var/I = 1 to storage_slots)
		new /obj/item/reagent_containers/glass/beaker/vial(src)

/obj/item/storage/lockbox/vials
	name = "secure vial storage box"
	desc = "A locked box for keeping things away from children."
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox0"
	item_state = "syringe_kit"
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(/obj/item/reagent_containers/glass/beaker/vial)
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 6
	req_access = list(ACCESS_VIROLOGY)


/obj/item/storage/lockbox/vials/populate_contents()
	for(var/I = 1 to storage_slots)
		new /obj/item/reagent_containers/glass/beaker/vial(src)
	update_icon()


/obj/item/storage/lockbox/vials/update_icon_state()
	icon_state = "vialbox[length(contents)]"


/obj/item/storage/lockbox/vials/update_overlays()
	. = ..()
	if(!broken)
		. += "led[locked]"
		if(locked)
			. += "cover"
	else
		. += "ledb"


///Aquatic Starter Kit

/obj/item/storage/firstaid/aquatic_kit
	name = "aquatic starter kit"
	desc = "It's a starter kit box for an aquarium."
	icon_state = "AquaticKit"
	throw_speed = 2
	throw_range = 8
	med_bot_skin = "fish"

/obj/item/storage/firstaid/aquatic_kit/full
	desc = "It's a starter kit for an aquarium; includes 1 tank brush, 1 egg scoop, 1 fish net, 1 container of fish food and 1 fish bag."

/obj/item/storage/firstaid/aquatic_kit/full/populate_contents()
	new /obj/item/egg_scoop(src)
	new /obj/item/fish_net(src)
	new /obj/item/tank_brush(src)
	new /obj/item/fishfood(src)
	new /obj/item/storage/bag/fish(src)
