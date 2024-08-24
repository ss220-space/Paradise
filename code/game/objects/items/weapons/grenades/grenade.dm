/obj/item/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "grenade"
	item_state = "flashbang"
	belt_icon = "grenade"
	throw_speed = 4
	throw_range = 20
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE
	max_integrity = 40
	var/active = FALSE
	var/det_time = 5 SECONDS
	var/display_timer = TRUE


/obj/item/grenade/deconstruct(disassembled = TRUE)
	if(!disassembled)
		prime()
	if(!QDELETED(src))
		qdel(src)


/obj/item/grenade/proc/clown_check(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, span_warning("Huh? How does this thing work?"))
		active = TRUE
		update_icon(UPDATE_ICON_STATE)
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, TRUE, -3)
		addtimer(CALLBACK(src, PROC_REF(delayed_boom)), 0.5 SECONDS)
		return FALSE
	return TRUE


/obj/item/grenade/proc/delayed_boom(mob/living/user)
	if(!QDELETED(user))
		user.drop_item_ground(src)
	prime()


/obj/item/grenade/update_icon_state()
	icon_state = "[initial(icon_state)][active ? "_active" : ""]"


/obj/item/grenade/examine(mob/user)
	. = ..()
	if(display_timer)
		if(det_time > 1)
			. += span_notice("The timer is set to [det_time/10] second\s.")
		else
			. += span_warning("[src] is set for instant detonation.")


/obj/item/grenade/attack_self(mob/user)
	if(!active && clown_check(user))
		to_chat(user, "<span class='warning'>You prime the [name]! [det_time/10] seconds!</span>")
		active = TRUE
		update_icon(UPDATE_ICON_STATE)
		add_fingerprint(user)
		var/turf/bombturf = get_turf(src)
		message_admins("[key_name_admin(usr)] has primed a [name] for detonation at [ADMIN_COORDJMP(bombturf)]")
		investigate_log("[key_name_log(usr)] has primed a [name] for detonation", INVESTIGATE_BOMB)
		add_attack_logs(user, src, "has primed for detonation", ATKLOG_FEW)
		if(iscarbon(user))
			var/mob/living/carbon/c_user = user
			c_user.throw_mode_on()
		addtimer(CALLBACK(src, PROC_REF(prime)), det_time)


/obj/item/grenade/proc/prime(mob/user)
	return


/obj/item/grenade/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.drop_item_ground(src)


/obj/item/grenade/screwdriver_act(mob/living/user, obj/item/I)
	switch(det_time)
		if(0.1 SECONDS)
			det_time = 1 SECONDS
			to_chat(user, span_notice("You set [src] for 1 second detonation time."))
		if(1 SECONDS)
			det_time = 3 SECONDS
			to_chat(user, span_notice("You set [src] for 3 second detonation time."))
		if(3 SECONDS)
			det_time = 5 SECONDS
			to_chat(user, span_notice("You set [src] for 5 second detonation time."))
		if(5 SECONDS)
			det_time = 0.1 SECONDS
			to_chat(user, span_notice("You set [src] for instant detonation."))
	add_fingerprint(user)
	return TRUE


/obj/item/grenade/attack_hand(mob/user)
	SSmove_manager.stop_looping(src)
	. = ..()

