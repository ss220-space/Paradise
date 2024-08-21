#define PAPERWORK	1
#define PHOTO		2

/obj/item/clipboard
	name = "clipboard"
	desc = "It looks like you're writing a letter. Want some help?"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	var/obj/item/pen/containedpen
	var/obj/item/toppaper
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE

/obj/item/clipboard/New()
	..()
	update_icon(UPDATE_OVERLAYS)


/obj/item/clipboard/AltClick(mob/user)
	if(Adjacent(user) && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(is_pen(user.get_active_hand()))
			penPlacement(user, user.get_active_hand(), TRUE)
		else
			removePen(user)
		return
	. = ..()


/obj/item/clipboard/verb/removePen()
	set category = "Object"
	set name = "Remove clipboard pen"
	if(!ishuman(usr) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	penPlacement(usr, containedpen, FALSE)

/obj/item/clipboard/proc/isPaperwork(obj/item/W) //This could probably do with being somewhere else but for now it's fine here.
	if(istype(W, /obj/item/paper) || istype(W, /obj/item/paper_bundle))
		return PAPERWORK
	if(istype(W, /obj/item/photo))
		return PHOTO

/obj/item/clipboard/proc/checkTopPaper()
	if(toppaper.loc != src) //Oh no! We're missing a top sheet! Better get another one to be at the top.
		toppaper = locate(/obj/item/paper) in src
		if(!toppaper) //In case there's no paper, try find a paper bundle instead (why is paper_bundle not a subtype of paper?)
			toppaper = locate(/obj/item/paper_bundle) in src

/obj/item/clipboard/examine(mob/user)
	. = ..()
	. += "<span class='info'><b>Alt-Click</b> to remove its pen.</span>"
	if(in_range(user, src) && toppaper)
		. += toppaper.examine(user)


/obj/item/clipboard/proc/penPlacement(mob/user, obj/item/pen/pen, placing)
	if(placing)
		if(!is_pen(pen))
			return FALSE
		if(containedpen)
			to_chat(user, span_warning("There's already a pen in [src]!"))
			return FALSE
		if(!user.drop_transfer_item_to_loc(pen, src))
			return FALSE
		to_chat(user, span_notice("You have slided [pen] into [src]."))
		containedpen = pen
		update_icon(UPDATE_OVERLAYS)
		return TRUE
	if(!containedpen)
		to_chat(user, span_warning("There is no pen in [src] for you to remove!"))
		return FALSE
	to_chat(user, span_notice("You have removed [containedpen] from [src]."))
	containedpen.forceMove_turf()
	user.put_in_hands(containedpen, ignore_anim = FALSE)
	containedpen = null
	update_icon(UPDATE_OVERLAYS)
	return TRUE


/obj/item/clipboard/proc/showClipboard(mob/user) //Show them what's on the clipboard
	var/dat = {"<meta charset="UTF-8"><title>[src]</title>"}
	dat += "<a href='byond://?src=[UID()];doPenThings=[containedpen ? "Remove" : "Add"]'>[containedpen ? "Remove pen" : "Add pen"]</a><br><hr>"
	if(toppaper)
		dat += "<a href='byond://?src=[UID()];remove=\ref[toppaper]'>Remove</a><a href='byond://?src=[UID()];viewOrWrite=\ref[toppaper]'>[toppaper.name]</a><br><hr>"
	for(var/obj/item/P in src)
		if(isPaperwork(P) == PAPERWORK && P != toppaper)
			dat += "<a href='byond://?src=[UID()];remove=\ref[P]'>Remove</a><a href='byond://?src=[UID()];topPaper=\ref[P]'>Put on top</a><a href='byond://?src=[UID()];viewOrWrite=\ref[P]'>[P.name]</a><br>"
		if(isPaperwork(P) == PHOTO)
			dat += "<a href='byond://?src=[UID()];remove=\ref[P]'>Remove</a><a href='byond://?src=[UID()];viewOrWrite=\ref[P]'>[P.name]</a><br>"
	var/datum/browser/popup = new(user, "clipboard", "[src]", 400, 400)
	popup.set_content(dat)
	popup.open()


/obj/item/clipboard/update_overlays()
	. = ..()
	if(toppaper)
		. += toppaper.icon_state
		. += toppaper.overlays
	if(containedpen)
		. += "clipboard_pen"
	for(var/obj/O in src)
		if(istype(O, /obj/item/photo))
			var/image/img = image('icons/obj/bureaucracy.dmi')
			var/obj/item/photo/Ph = O
			img = Ph.tiny
			. += img
			break
	. += "clipboard_over"


/obj/item/clipboard/attackby(obj/item/I, mob/user, params)
	var/paperwork = isPaperwork(I)
	if(paperwork) //If it's a photo, paper bundle, or piece of paper, place it on the clipboard.
		add_fingerprint(user)
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You have clipped [I] onto [src]."))
		playsound(loc, "pageturn", 50, TRUE)
		if(paperwork == PAPERWORK)
			toppaper = I
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(is_pen(I))
		add_fingerprint(user)
		if(!toppaper) //If there's no paper we can write on, just stick the pen into the clipboard
			if(penPlacement(user, I, TRUE))
				return ATTACK_CHAIN_BLOCKED_ALL
			return ATTACK_CHAIN_PROCEED
		if(containedpen) //If there's a pen in the clipboard, let's just let them write and not bother asking about the pen
			toppaper.attackby(I, user, params)
			return ATTACK_CHAIN_BLOCKED_ALL
		var/writeonwhat = input(user, "Write on [toppaper.name], or place your pen in [src]?", "Pick one!") as null|anything in list("Write", "Place pen")
		if(!writeonwhat || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			return ATTACK_CHAIN_PROCEED
		switch(writeonwhat)
			if("Write")
				toppaper.attackby(I, user, params)
				return ATTACK_CHAIN_BLOCKED_ALL
			if("Place pen")
				if(penPlacement(user, I, TRUE))
					return ATTACK_CHAIN_BLOCKED_ALL
				return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/stamp)) //We can stamp the topmost piece of paper
		if(!toppaper)
			to_chat(user, span_warning("The [name] has no paperwork."))
			return ATTACK_CHAIN_PROCEED
		toppaper.attackby(I, user, params)
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/clipboard/attack_self(mob/user)
	showClipboard(user)

/obj/item/clipboard/Topic(href, href_list)
	..()
	if(!Adjacent(usr) || usr.incapacitated())
		return
	var/obj/item/I = usr.get_active_hand()
	if(href_list["doPenThings"])
		if(href_list["doPenThings"] == "Add")
			penPlacement(usr, I, TRUE)
		else
			penPlacement(usr, containedpen, FALSE)
	else if(href_list["remove"])
		var/obj/item/P = locate(href_list["remove"]) in src
		if(isPaperwork(P))
			P.forceMove_turf()
			usr.put_in_hands(P, ignore_anim = FALSE)
			to_chat(usr, "<span class='notice'>You remove [P] from [src].</span>")
			checkTopPaper() //So we don't accidentally make the top sheet not be on the clipboard
	else if(href_list["viewOrWrite"])
		var/obj/item/P = locate(href_list["viewOrWrite"]) in src
		if(!isPaperwork(P))
			return
		if(is_pen(I) && isPaperwork(P) != PHOTO) //Because you can't write on photos that aren't in your hand
			P.attackby(I, usr)
		else if(isPaperwork(P) == PAPERWORK) //Why can't these be subtypes of paper
			P.examine(usr)
		else if(isPaperwork(P) == PHOTO)
			var/obj/item/photo/Ph = P
			Ph.show(usr)
	else if(href_list["topPaper"])
		var/obj/item/P = locate(href_list["topPaper"]) in src
		if(P == toppaper)
			return
		to_chat(usr, "<span class='notice'>You flick the pages so that [P] is on top.</span>")
		playsound(loc, "pageturn", 50, 1)
		toppaper = P
	update_icon(UPDATE_OVERLAYS)
	showClipboard(usr)

#undef PAPERWORK
#undef PHOTO
