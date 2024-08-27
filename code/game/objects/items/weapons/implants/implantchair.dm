/obj/machinery/implantchair
	name = "mindshield implanter"
	desc = "Used to implant occupants with mindshield implants."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	density = TRUE
	anchored = TRUE
	var/max_implants = 5
	var/injection_cooldown = 30 SECONDS
	var/replenish_cooldown = 10 MINUTES
	var/cooldown_timer
	var/list/implants_list
	var/mob/living/carbon/human/occupant


/obj/machinery/implantchair/Initialize(mapload)
	. = ..()
	add_implants()


/obj/machinery/implantchair/Destroy()
	if(occupant)
		go_out()
	return ..()


/obj/machinery/implantchair/proc/add_implants()
	LAZYINITLIST(implants_list)
	var/imps_amount = max_implants - LAZYLEN(implants_list)
	if(imps_amount)
		for(var/i in 1 to imps_amount)
			var/obj/item/implant/mindshield/bio_chip = new(src)
			LAZYADD(implants_list, bio_chip)


/obj/machinery/implantchair/update_icon_state()
	icon_state = "implantchair[occupant ? "_on" : ""]"


/obj/machinery/implantchair/attack_hand(mob/user)
	add_fingerprint(user)
	user.set_machine(src)
	var/health_text = ""
	if(occupant)
		if(occupant.stat == DEAD)
			health_text = "<FONT color=red>Dead</FONT>"
		else if(occupant.health < 0)
			health_text = "<FONT color=red>[round(occupant.health, 0.1)]</FONT>"
		else
			health_text = "[round(occupant.health, 0.1)]"
	var/dat = {"<meta charset="UTF-8"><B>Mindshield Implanter Machine</B><BR>"}
	dat +="<B>Current occupant:</B> [occupant ? "<BR>Name: [occupant]<BR>Health: [health_text]<BR>" : "<FONT color=red>None</FONT>"]<BR>"
	var/remaining_time = cooldown_timer ? round(timeleft(cooldown_timer) / 10) : 0
	var/implants_length = LAZYLEN(implants_list)
	if(implants_length)
		dat += "<B>Status:</B> [cooldown_timer ? "<FONT color=red>Recharging... For <B>[remaining_time]</B> more seconds</FONT><BR>" : "<FONT color=green><B>READY</B></FONT>"]<BR>"
	else
		dat += "<B>Status:</B> [cooldown_timer ? "<FONT color=red>Replenishing... For <B>[remaining_time]</B> more seconds</FONT><BR>" : "<FONT color=green><B>READY</B></FONT>"]<BR>"
	dat += "<B>Implants:</B> [implants_length ? "[implants_length]<BR>" : cooldown_timer ? "<FONT color=red>0</FONT><BR>" : "<a href='byond://?src=[UID()];replenish=1'>Replenish</A>"]<BR>"
	if(occupant)
		if(locate(/obj/item/implant/mindshield) in occupant)
			dat += "Occupant is already <FONT color=green>implanted</FONT><BR>"
		if(!cooldown_timer && implants_length)
			dat += "<a href='byond://?src=[UID()];implant=1'>Implant</A><BR>"
		dat += "<a href='byond://?src=[UID()];eject=1'>Eject Occupant</A><BR>"
	dat += "<a href='byond://?src=[UID()];refresh=1'>Refresh</A>"
	user.set_machine(src)
	user << browse(dat, "window=implant")
	onclose(user, "implant")


/obj/machinery/implantchair/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE)
		return .
	put_mob(grabbed_thing, grabber)


/obj/machinery/implantchair/Topic(href, href_list)
	if(..())
		return

	if(href_list["implant"] && occupant && (!cooldown_timer) && LAZYLEN(implants_list))
		var/prev_occupant = occupant
		if(go_out(usr))
			implant(prev_occupant)
			cooldown_timer = addtimer(CALLBACK(src, PROC_REF(on_cooldown_finish)), injection_cooldown, TIMER_STOPPABLE|TIMER_DELETE_ME)

	if(href_list["replenish"] && (!cooldown_timer) && (!LAZYLEN(implants_list)))
		cooldown_timer = addtimer(CALLBACK(src, PROC_REF(on_cooldown_finish), TRUE), replenish_cooldown, TIMER_STOPPABLE|TIMER_DELETE_ME)

	if(href_list["eject"] && occupant)
		go_out(usr)

	updateUsrDialog()


/obj/machinery/implantchair/proc/on_cooldown_finish(replenish = FALSE)
	playsound(loc, 'sound/machines/ping.ogg', 50, TRUE)
	visible_message(span_notice("[src] is ready to implant."))
	if(replenish)
		add_implants()
	cooldown_timer = null
	updateUsrDialog()


/obj/machinery/implantchair/proc/implant(mob/living/carbon/human/target)
	if(!ishuman(target))
		return FALSE
	if(!LAZYLEN(implants_list))
		return FALSE
	for(var/obj/item/implant/mindshield/imp as anything in implants_list)
		if(imp.implant(target))
			playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
			target.visible_message(span_warning("[target] has been implanted by [src]."))
			LAZYREMOVE(implants_list, imp)
			return TRUE
	return FALSE


/obj/machinery/implantchair/MouseDrop_T(mob/living/carbon/human/dropping, mob/living/user, params)
	return put_mob(dropping, user)


/obj/machinery/implantchair/proc/put_mob(mob/living/carbon/human/target, mob/living/user)
	if(!put_mob_check(target, user))
		return FALSE
	target.pulledby?.stop_pulling()
	target.forceMove(src)
	occupant = target
	add_fingerprint(user)
	update_icon(UPDATE_ICON_STATE)
	updateUsrDialog()
	return TRUE


/obj/machinery/implantchair/proc/put_mob_check(mob/living/carbon/human/target, mob/living/user)
	if(stat & (NOPOWER|BROKEN))
		return FALSE
	if(target == user && !Adjacent(target))
		return FALSE
	if(target != user && (!Adjacent(user) && !user.Adjacent(target)))
		return FALSE
	if(!isliving(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE
	if(!ishuman(target))
		to_chat(user, span_warning("[src] cannot hold this!"))
		return FALSE
	if(occupant)
		to_chat(user, span_warning("[src] is already occupied!"))
		return FALSE
	if(target.buckled)
		to_chat(user, span_warning("Subject cannot be buckled."))
		return FALSE
	if(target.abiotic())
		to_chat(user, span_warning("Subject cannot have abiotic items on."))
		return FALSE
	if(target.has_buckled_mobs())
		to_chat(user, span_warning("Subject will not fit into [src] because [target.p_they()] [target.p_have()] a slime latched onto [target.p_their()] head."))
		return FALSE
	return TRUE


/obj/machinery/implantchair/proc/go_out(mob/living/carbon/human/user)
	if(!occupant)
		return FALSE
	if(occupant == user) // so that the guy inside can't eject himself -Agouri
		return FALSE
	if(user && (!ishuman(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)))
		return FALSE
	occupant.forceMove(loc)
	add_fingerprint(user)
	occupant = null
	update_icon(UPDATE_ICON_STATE)
	return TRUE


/obj/machinery/implantchair/verb/get_out()
	set name = "Eject occupant"
	set category = "Object"
	set src in oview(1)
	go_out(usr)


/obj/machinery/implantchair/verb/move_inside()
	set name = "Move Inside"
	set category = "Object"
	set src in oview(1)
	put_mob(usr, usr)

