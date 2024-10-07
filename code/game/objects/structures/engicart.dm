/obj/structure/engineeringcart
	name = "engineering cart"
	desc = "A cart for storing engineering items."
	icon = 'icons/obj/engicart.dmi'
	icon_state = "cart"
	anchored = FALSE
	density = TRUE
	pull_push_slowdown = 1
	var/obj/item/stack/sheet/glass/myglass = null
	var/obj/item/stack/sheet/metal/mymetal = null
	var/obj/item/stack/sheet/plasteel/myplasteel = null
	var/obj/item/flashlight/myflashlight = null
	var/obj/item/storage/toolbox/mechanical/mybluetoolbox = null
	var/obj/item/storage/toolbox/electrical/myyellowtoolbox = null
	var/obj/item/storage/toolbox/emergency/myredtoolbox = null

/obj/structure/engineeringcart/Destroy()
	QDEL_NULL(myglass)
	QDEL_NULL(mymetal)
	QDEL_NULL(myplasteel)
	QDEL_NULL(myflashlight)
	QDEL_NULL(mybluetoolbox)
	QDEL_NULL(myyellowtoolbox)
	QDEL_NULL(myredtoolbox)
	return ..()


/obj/structure/engineeringcart/proc/put_in_cart(obj/item/I, mob/user)
	. = user.drop_transfer_item_to_loc(I, src)
	if(.)
		to_chat(user, span_notice("You put [I] into [src]."))


/obj/structure/engineeringcart/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || I.is_robot_module())
		return ..()

	var/fail_msg = span_notice("There is already one of those in [src].")

	if(istype(I, /obj/item/stack/sheet/glass))
		add_fingerprint(user)
		if(myglass)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		myglass = I
		updateUsrDialog()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/sheet/metal))
		add_fingerprint(user)
		if(mymetal)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		mymetal = I
		updateUsrDialog()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/sheet/plasteel))
		add_fingerprint(user)
		if(myplasteel)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		myplasteel = I
		updateUsrDialog()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/flashlight))
		add_fingerprint(user)
		if(myflashlight)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		myflashlight = I
		updateUsrDialog()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/storage/toolbox/mechanical))
		add_fingerprint(user)
		if(mybluetoolbox)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		mybluetoolbox = I
		updateUsrDialog()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/storage/toolbox/electrical))
		add_fingerprint(user)
		if(myyellowtoolbox)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		myyellowtoolbox = I
		updateUsrDialog()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/storage/toolbox))
		add_fingerprint(user)
		if(myredtoolbox)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		myredtoolbox = I
		updateUsrDialog()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/storage/toolbox))
		add_fingerprint(user)
		if(myredtoolbox)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		myredtoolbox = I
		updateUsrDialog()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/engineeringcart/wrench_act(mob/living/user, obj/item/I)
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


/obj/structure/engineeringcart/attack_hand(mob/user)
	add_fingerprint(user)
	user.set_machine(src)
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	if(myglass)
		dat += "<a href='byond://?src=[UID()];glass=1'>[myglass.name]</a><br>"
	if(mymetal)
		dat += "<a href='byond://?src=[UID()];metal=1'>[mymetal.name]</a><br>"
	if(myplasteel)
		dat += "<a href='byond://?src=[UID()];plasteel=1'>[myplasteel.name]</a><br>"
	if(myflashlight)
		dat += "<a href='byond://?src=[UID()];flashlight=1'>[myflashlight.name]</a><br>"
	if(mybluetoolbox)
		dat += "<a href='byond://?src=[UID()];bluetoolbox=1'>[mybluetoolbox.name]</a><br>"
	if(myredtoolbox)
		dat += "<a href='byond://?src=[UID()];redtoolbox=1'>[myredtoolbox.name]</a><br>"
	if(myyellowtoolbox)
		dat += "<a href='byond://?src=[UID()];yellowtoolbox=1'>[myyellowtoolbox.name]</a><br>"
	var/datum/browser/popup = new(user, "engicart", name, 240, 160)
	popup.set_content(dat)
	popup.open()
/obj/structure/engineeringcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	if(href_list["glass"])
		if(myglass)
			myglass.forceMove_turf()
			user.put_in_hands(myglass, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [myglass] from [src].</span>")
			myglass = null
	if(href_list["metal"])
		if(mymetal)
			mymetal.forceMove_turf()
			user.put_in_hands(mymetal, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [mymetal] from [src].</span>")
			mymetal = null
	if(href_list["plasteel"])
		if(myplasteel)
			myplasteel.forceMove_turf()
			user.put_in_hands(myplasteel, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [myplasteel] from [src].</span>")
			myplasteel = null
	if(href_list["flashlight"])
		if(myflashlight)
			myflashlight.forceMove_turf()
			user.put_in_hands(myflashlight, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [myflashlight] from [src].</span>")
			myflashlight = null
	if(href_list["bluetoolbox"])
		if(mybluetoolbox)
			mybluetoolbox.forceMove_turf()
			user.put_in_hands(mybluetoolbox, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [mybluetoolbox] from [src].</span>")
			mybluetoolbox = null
	if(href_list["redtoolbox"])
		if(myredtoolbox)
			myredtoolbox.forceMove_turf()
			user.put_in_hands(myredtoolbox, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [myredtoolbox] from [src].</span>")
			myredtoolbox = null
	if(href_list["yellowtoolbox"])
		if(myyellowtoolbox)
			myyellowtoolbox.forceMove_turf()
			user.put_in_hands(myyellowtoolbox, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [myyellowtoolbox] from [src].</span>")
			myyellowtoolbox = null

	update_icon(UPDATE_OVERLAYS)
	updateUsrDialog()


/obj/structure/engineeringcart/update_overlays()
	. = ..()
	if(myglass)
		. += "cart_glass"
	if(mymetal)
		. += "cart_metal"
	if(myplasteel)
		. += "cart_plasteel"
	if(myflashlight)
		. += "cart_flashlight"
	if(mybluetoolbox)
		. += "cart_bluetoolbox"
	if(myredtoolbox)
		. += "cart_redtoolbox"
	if(myyellowtoolbox)
		. += "cart_yellowtoolbox"

