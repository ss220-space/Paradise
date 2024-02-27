// This file is for projectile weapon crafting. All parts and construction paths will be contained here.
// The weapons themselves are children of other weapons and should be contained in their respective files.

// PARTS //

/obj/item/weaponcrafting/receiver
	name = "modular receiver"
	desc = "A prototype modular receiver and trigger assembly for a firearm."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "receiver"

/obj/item/weaponcrafting/stock
	name = "rifle stock"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "riflestock"

/obj/item/weaponcrafting/revolverbarrel
	name = "improvised revolver barrel"
	desc = "A roughly made revolver barrel."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "rev_barrel"
	w_class = WEIGHT_CLASS_SMALL
	var/new_fire_sound = 'sound/weapons/gunshots/1rev257.ogg'

/obj/item/weaponcrafting/revolverbarrel/steel
	name = "steel revolver barrel"
	desc = "High quality heavy steel gun barrel to increase stability."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "s_rev_barrel"
	new_fire_sound = 'sound/weapons/gunshots/1rev257S.ogg'


// CRAFTING //

/obj/item/weaponcrafting/receiver/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/pipe))
		to_chat(user, "You attach the shotgun barrel to the receiver. The pins seem loose.")
		var/obj/item/weaponcrafting/ishotgunconstruction/I = new(drop_location())
		user.temporarily_remove_item_from_inventory(src)
		user.put_in_hands(I, ignore_anim = FALSE)
		qdel(W)
		qdel(src)
		return

// SHOTGUN //

/obj/item/weaponcrafting/ishotgunconstruction
	name = "slightly conspicuous metal construction"
	desc = "A long pipe attached to a firearm receiver. The pins seem loose."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunstep1"

/obj/item/weaponcrafting/ishotgunconstruction/attackby(obj/item/I, mob/user, params)
	..()
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		var/obj/item/weaponcrafting/ishotgunconstruction2/C = new(drop_location())
		user.temporarily_remove_item_from_inventory(src)
		user.put_in_hands(C, ignore_anim = FALSE)
		to_chat(user, span_notice("You screw the pins into place, securing the pipe to the receiver."))
		qdel(src)

/obj/item/weaponcrafting/ishotgunconstruction2
	name = "very conspicuous metal construction"
	desc = "A long pipe attached to a trigger assembly."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunstep1"

/obj/item/weaponcrafting/ishotgunconstruction2/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/weaponcrafting/stock))
		to_chat(user, "You attach the stock to the receiver-barrel assembly.")
		var/obj/item/weaponcrafting/ishotgunconstruction3/I = new(drop_location())
		user.temporarily_remove_item_from_inventory(src)
		user.put_in_hands(I, ignore_anim = FALSE)
		qdel(W)
		qdel(src)
		return

/obj/item/weaponcrafting/ishotgunconstruction3
	name = "extremely conspicuous metal construction"
	desc = "A receiver-barrel shotgun assembly with a loose wooden stock. There's no way you can fire it without the stock coming loose."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunstep2"

/obj/item/weaponcrafting/ishotgunconstruction3/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/stack/packageWrap))
		var/obj/item/stack/packageWrap/C = I
		if(C.use(5))
			var/obj/item/gun/projectile/revolver/doublebarrel/improvised/W = new(drop_location())
			investigate_log("[key_name_log(user)] crafted [W]", INVESTIGATE_CRAFTING)
			user.temporarily_remove_item_from_inventory(src)
			user.put_in_hands(W, ignore_anim = FALSE)
			to_chat(user, span_notice("You tie the wrapping paper around the stock and the barrel to secure it."))
			qdel(src)
		else
			to_chat(user, span_warning("You need at least five feet of wrapping paper to secure the stock."))
			return
