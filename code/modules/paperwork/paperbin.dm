/obj/item/paper_bin
	name = "paper bin"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin"
	righthand_file = 'icons/mob/inhands/storage_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/storage_lefthand.dmi'
	item_state = "paper_bin"
	throwforce = 1
	throw_speed = 3
	pressure_resistance = 8
	var/amount = 30					//How much paper is in the bin.
	var/list/papers = list()	//List of papers put in the bin for reference.
	var/letterhead_type
	var/purple_bin = FALSE

/obj/item/paper_bin/fire_act(exposed_temperature, exposed_volume)
	if(amount)
		amount = 0
		update_icon(UPDATE_ICON_STATE)
	..()

/obj/item/paper_bin/Destroy()
	QDEL_LIST(papers)
	return ..()

/obj/item/paper_bin/burn()
	amount = 0
	extinguish()
	update_icon(UPDATE_ICON_STATE)

/obj/item/paper_bin/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(over_object != user || !ishuman(user))
		return

	if(!user.put_in_hands(src, ignore_anim = FALSE))
		return

	add_fingerprint(user)
	user.visible_message(span_notice("[user] picks up [src]."))

/obj/item/paper_bin/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.bodyparts_by_name[BODY_ZONE_PRECISE_R_HAND]
		if(H.hand)
			temp = H.bodyparts_by_name[BODY_ZONE_PRECISE_L_HAND]
		if(temp && !temp.is_usable())
			to_chat(H, "<span class='notice'>You try to move your [temp.name], but cannot!")
			return
	if(amount >= 1)
		amount--
		if(amount==0)
			update_icon(UPDATE_ICON_STATE)

		var/obj/item/paper/P
		if(length(papers) > 0)	//If there's any custom paper on the stack, use that instead of creating a new paper.
			P = papers[length(papers)]
			papers.Remove(P)
			P.forceMove_turf()
		else
			if(letterhead_type && alert("Choose a style",,"Letterhead","Blank")=="Letterhead")
				P = new letterhead_type(drop_location())
			else
				P = new /obj/item/paper(drop_location())
			if(SSholiday.holidays && SSholiday.holidays[APRIL_FOOLS])
				if(prob(30))
					P.info = "<font face=\"[P.crayonfont]\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
					P.rigged = 1
					P.updateinfolinks()
		if(in_range(user, src))
			user.put_in_hands(P, ignore_anim = FALSE)
			P.add_fingerprint(user)
			to_chat(user, span_notice("You take [P] out of the [src]."))
	else
		to_chat(user, span_notice("[src] is empty!"))

	add_fingerprint(user)
	return

/obj/item/paper_bin/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/paper))
		add_fingerprint(user)
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You have put [I] into [src]."))
		papers.Add(I)
		var/do_update = FALSE
		if(amount == 0)
			do_update = TRUE

		amount++
		if(do_update)
			update_icon(UPDATE_ICON_STATE)

		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/paper_bin/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(amount)
			. += span_notice("There " + (amount > 1 ? "are [amount] papers" : "is one paper") + " in the bin.")
		else
			. += span_notice("There are no papers in the bin.")

/obj/item/paper_bin/update_icon_state()
	icon_state = "paper_bin"
	if(amount < 1)
		icon_state += "_empty"
	else
		icon_state += "[purple_bin ? "_carbon" : ""]"
	item_state = icon_state

/obj/item/paper_bin/carbon
	name = "carbonless paper bin"
	icon_state = "paper_bin_carbon"
	item_state = "paper_bin_carbon"
	purple_bin = TRUE

/obj/item/paper_bin/carbon/attack_hand(mob/user)
	if(amount >= 1)
		amount--
		if(amount==0)
			update_icon(UPDATE_ICON_STATE)

		var/obj/item/paper/carbon/P
		if(length(papers) > 0)	//If there's any custom paper on the stack, use that instead of creating a new paper.
			P = papers[length(papers)]
			papers.Remove(P)
		else
			P = new /obj/item/paper/carbon(drop_location())
		user.put_in_hands(P, ignore_anim = FALSE)
		to_chat(user, span_notice("You take [P] out of the [src]."))
	else
		to_chat(user, span_notice("[src] is empty!"))

	add_fingerprint(user)
	return

/obj/item/paper_bin/nanotrasen
	name = "nanotrasen paper bin"
	letterhead_type = /obj/item/paper/nanotrasen

/obj/item/paper_bin/syndicate
	name = "syndicate paper bin"
	letterhead_type = /obj/item/paper/syndicate

/obj/item/paper_bin/ussp
	name = "ussp paper bin"
	letterhead_type = /obj/item/paper/ussp

/obj/item/paper_bin/solgov
	name = "solgov paper bin"
	letterhead_type = /obj/item/paper/solgov

/obj/item/paper_bin/human
	name = "nanotrasen paper bin"
	letterhead_type = /obj/item/paper/human
