//TG style Janicart

/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "This is the alpha and omega of sanitation."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	anchored = FALSE
	density = TRUE
	container_type = OPENCONTAINER
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/storage/bag/trash/mybag	= null
	var/obj/item/mop/mymop = null
	var/obj/item/reagent_containers/spray/cleaner/myspray = null
	var/obj/item/lightreplacer/myreplacer = null
	var/signs = 0
	var/const/max_signs = 4


/obj/structure/janitorialcart/Initialize(mapload)
	. = ..()
	create_reagents(100)
	GLOB.janitorial_equipment += src

/obj/structure/janitorialcart/Destroy()
	GLOB.janitorial_equipment -= src
	QDEL_NULL(mybag)
	QDEL_NULL(mymop)
	QDEL_NULL(myspray)
	QDEL_NULL(myreplacer)
	return ..()


/obj/structure/janitorialcart/proc/put_in_cart(obj/item/I, mob/user)
	. = user.drop_transfer_item_to_loc(I, src)
	if(.)
		to_chat(user, span_notice("You put [I] into [src]."))


/obj/structure/janitorialcart/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)


/obj/structure/janitorialcart/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || I.is_robot_module())
		return ..()

	var/fail_msg = span_notice("There is already one of those in [src].")

	if(istype(I, /obj/item/mop))
		add_fingerprint(user)
		var/obj/item/mop/mop = I
		mop.wet_mop(src, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/storage/bag/trash))
		add_fingerprint(user)
		if(mybag)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		mybag = I
		updateUsrDialog()
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/lightreplacer))
		add_fingerprint(user)
		if(myreplacer)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		myreplacer = I
		updateUsrDialog()
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/reagent_containers/spray/cleaner))
		add_fingerprint(user)
		if(myspray)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		myspray = I
		updateUsrDialog()
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/caution))
		add_fingerprint(user)
		if(signs >= max_signs)
			to_chat(user, span_notice("The [name] cannot hold any more signs."))
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		signs++
		updateUsrDialog()
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(mybag?.can_be_inserted(I, stop_messages = TRUE))
		mybag.handle_item_insertion(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/janitorialcart/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("The [name]'s bucket is empty."))
		return .
	user.visible_message(
		span_notice("[user] starts to empty the contents of [src]'s bucket."),
		span_notice("You start to empty the contents of [src]'s bucket..."),
	)
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || !reagents || !reagents.total_volume)
		return .
	user.visible_message(
		span_notice("[user] empties the contents of [src]'s bucket onto the floor."),
		span_notice("You have emptied the contents of [src]'s bucket onto the floor."),
	)
	reagents.reaction(loc)
	reagents.clear_reagents()


/obj/structure/janitorialcart/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(isinspace())
		to_chat(user, span_warning("That was a dumb idea."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	set_anchored(!anchored)
	if(anchored)
		user.visible_message(
			span_notice("[user] tightens [name]'s casters."),
			span_notice("You have tightened [name]'s casters."),
			span_italics("You hear ratchet."),
		)
	else
		user.visible_message(
			span_notice("[user] loosens [name]'s casters."),
			span_notice("You have loosened [name]'s casters."),
			span_italics("You hear ratchet."),
		)


/obj/structure/janitorialcart/attack_hand(mob/user)
	add_fingerprint(user)
	user.set_machine(src)
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	if(mybag)
		dat += "<a href='byond://?src=[UID()];garbage=1'>[mybag.name]</a><br>"
	if(mymop)
		dat += "<a href='byond://?src=[UID()];mop=1'>[mymop.name]</a><br>"
	if(myspray)
		dat += "<a href='byond://?src=[UID()];spray=1'>[myspray.name]</a><br>"
	if(myreplacer)
		dat += "<a href='byond://?src=[UID()];replacer=1'>[myreplacer.name]</a><br>"
	if(signs)
		dat += "<a href='byond://?src=[UID()];sign=1'>[signs] sign\s</a><br>"
	var/datum/browser/popup = new(user, "janicart", name, 240, 160)
	popup.set_content(dat)
	popup.open()


/obj/structure/janitorialcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	if(href_list["garbage"])
		if(mybag)
			mybag.forceMove_turf()
			user.put_in_hands(mybag, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [mybag] from [src].</span>")
			mybag = null
	if(href_list["mop"])
		if(mymop)
			mymop.forceMove_turf()
			user.put_in_hands(mymop, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [mymop] from [src].</span>")
			mymop = null
	if(href_list["spray"])
		if(myspray)
			myspray.forceMove_turf()
			user.put_in_hands(myspray, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [myspray] from [src].</span>")
			myspray = null
	if(href_list["replacer"])
		if(myreplacer)
			myreplacer.forceMove_turf()
			user.put_in_hands(myreplacer, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [myreplacer] from [src].</span>")
			myreplacer = null
	if(href_list["sign"])
		if(signs)
			var/obj/item/caution/Sign = locate() in src
			if(Sign)
				Sign.forceMove_turf()
				user.put_in_hands(Sign, ignore_anim = FALSE)
				to_chat(user, "<span class='notice'>You take \a [Sign] from [src].</span>")
				signs--
			else
				WARNING("Signs ([signs]) didn't match contents")
				signs = 0

	update_icon(UPDATE_OVERLAYS)
	updateUsrDialog()


/obj/structure/janitorialcart/update_overlays()
	. = ..()
	if(mybag)
		. += "cart_garbage"
	if(mymop)
		. += "cart_mop"
	if(myspray)
		. += "cart_spray"
	if(myreplacer)
		. += "cart_replacer"
	if(signs)
		. += "cart_sign[signs]"
	if(reagents.total_volume > 0)
		var/image/reagentsImage = image(icon,src,"cart_reagents0")
		reagentsImage.alpha = 150
		switch((reagents.total_volume / reagents.maximum_volume) * 100)
			if(1 to 25)
				reagentsImage.icon_state = "cart_reagents1"
			if(26 to 50)
				reagentsImage.icon_state = "cart_reagents2"
			if(51 to 75)
				reagentsImage.icon_state = "cart_reagents3"
			if(76 to 100)
				reagentsImage.icon_state = "cart_reagents4"
		reagentsImage.icon += mix_color_from_reagents(reagents.reagent_list)
		. += reagentsImage

