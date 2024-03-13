#define CLOSET_BREAKOUT_TIME (2 MINUTES)

/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's an immobile card-locked storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "secure"
	density = TRUE
	opened = FALSE
	locked = TRUE
	broken = FALSE
	can_be_emaged = TRUE
	max_integrity = 250
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	damage_deflection = 20
	wall_mounted = FALSE //never solid (You can always pass over it)

/obj/structure/closet/secure_closet/can_open()
	if(locked)
		return FALSE
	return ..()

/obj/structure/closet/secure_closet/close()
	. = ..()
	if(. && broken)
		update_icon()


/obj/structure/closet/secure_closet/emp_act(severity)
	for(var/obj/object in src)
		object.emp_act(severity)

	if(broken || opened)
		return

	if(prob(50 / severity))
		locked = !locked
		playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		flick_overlay_view(image(icon, src, overlay_sparking), 1 SECONDS)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 1 SECONDS)

	if(prob(20 / severity))
		if(locked)
			req_access = list()
			req_access += pick(get_all_accesses())
			return
		open()


/obj/structure/closet/secure_closet/emag_act(mob/user)
	if(!broken)
		add_attack_logs(user, src, "emagged")
		broken = TRUE
		locked = FALSE
		playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		flick_overlay_view(image(icon, src, overlay_sparking), 1 SECONDS)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance), UPDATE_ICON|UPDATE_DESC), 1 SECONDS)
		if(user)
			to_chat(user, "<span class='notice'>You break the lock on [src].</span>")


/obj/structure/closet/secure_closet/proc/togglelock(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(opened)
		to_chat(user, "<span class='notice'>Close the locker first.</span>")
		return
	if(broken)
		to_chat(user, "<span class='warning'>The locker appears to be broken.</span>")
		return
	if(user.loc == src)
		to_chat(user, "<span class='notice'>You can't reach the lock from inside.</span>")
		return
	if(allowed(user))
		locked = !locked
		playsound(loc, pick(togglelock_sound), 15, TRUE, -3)
		visible_message("<span class='notice'>The locker has been [locked ? null : "un"]locked by [user].</span>")
		update_icon()
	else
		to_chat(user, "<span class='notice'>Access Denied</span>")

/obj/structure/closet/secure_closet/closed_item_click(mob/user)
	togglelock(user)

/obj/structure/closet/secure_closet/AltClick(mob/user)
	if(Adjacent(user))
		togglelock(user)


/obj/structure/closet/secure_closet/attack_hand(mob/user)
	add_fingerprint(user)
	if(locked)
		togglelock(user)
	else
		toggle(user)

/obj/structure/closet/secure_closet/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(usr.incapacitated()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(ishuman(usr) || isrobot(usr) || istype(usr, /mob/living/simple_animal/hostile/gorilla))
		add_fingerprint(usr)
		togglelock(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")


/obj/structure/closet/secure_closet/update_overlays()
	. = ..()
	if(!opened && !broken)
		if(locked)
			. += overlay_locked
		else
			. += overlay_unlocked


/obj/structure/closet/secure_closet/update_desc(updates = ALL)
	. = ..()
	if(broken)
		desc = "It appears to be broken."
	else
		desc = initial(desc)


/obj/structure/closet/secure_closet/container_resist(mob/living/user)
	if(opened)
		if(user.loc == src)
			user.forceMove(get_turf(src)) // Let's just be safe here
		return //Door's open... wait, why are you in it's contents then?

	if(!locked && !welded)
		return //It's a secure closet, but isn't locked. Easily escapable from, no need to 'resist'

	//okay, so the closet is either welded or locked... resist!!!
	visible_message(
		span_danger("[src] begins to shake violently!"),
		span_warning("You lean on the back of [src] and start pushing the door open. (this will take about [CLOSET_BREAKOUT_TIME / 10] minutes.)")
	)
	INVOKE_ASYNC(src, PROC_REF(resist_async), user)


/obj/structure/closet/secure_closet/proc/resist_async(mob/living/user)
	if(!do_after(user, CLOSET_BREAKOUT_TIME, target = src))
		return

	//closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
	if(!src || !user || user.incapacitated() || user.loc != src || opened)
		return

	//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
	if(!locked && !welded)
		return

	//Well then break it!
	playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	flick_overlay_view(image(icon, src, overlay_sparking), 1 SECONDS)
	broken = TRUE
	locked = FALSE
	welded = FALSE
	update_appearance(UPDATE_ICON|UPDATE_DESC)
	visible_message(
		span_danger("[user] successfully broke out of [src]!"),
		span_warning("You successfully break out!"),
	)

	if(istype(loc, /obj/structure/bigDelivery)) //Do this to prevent contents from being opened into nullspace (read: bluespace)
		var/obj/structure/bigDelivery/BD = loc
		BD.attack_hand(user)

	if(isobj(loc))
		var/obj/loc_as_obj = loc
		loc_as_obj.container_resist(user)

	open()


/obj/structure/closet/secure_closet/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && broken == 0 && user.a_intent != INTENT_HARM) // Stage one
		to_chat(user, "<span class='notice'>Вы начинаете откручивать панель замка [src]...</span>")
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(95)) // EZ
				to_chat(user, "<span class='notice'>Вы успешно открутили и сняли панель с замка [src]!</span>")
				desc += " Панель управления снята."
				broken = 3
				update_icon()
			else // Bad day)
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
				user.apply_damage(5, BRUTE , affecting)
				user.emote("scream")
				to_chat(user, "<span class='warning'>Проклятье! [I] сорвалась и повредила [affecting.name]!</span>")
		return TRUE

/obj/structure/closet/secure_closet/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && broken == 3 && user.a_intent != INTENT_HARM) // Stage two
		to_chat(user, "<span class='notice'>Вы начинаете подготавливать провода панели [src]...</span>")
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(80)) // Good hacker!
				to_chat(user, "<span class='notice'>Вы успешно подготовили провода панели замка [src]!</span>")
				desc += " Провода отключены и торчат наружу."
				broken = 2
			else // woopsy
				to_chat(user, "<span class='warning'>Черт! Не тот провод!</span>")
				do_sparks(5, 1, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

/obj/structure/closet/secure_closet/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && broken == 2 && user.a_intent != INTENT_HARM) // Stage three
		to_chat(user, "<span class='notice'>Вы начинаете подключать провода панели замка [src] к [I]...</span>")
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(80)) // Good hacker!
				desc += " Замок отключен."
				broken = 0 // Can be emagged
				emag_act(user)
			else // woopsy
				to_chat(user, "<span class='warning'>Черт! Не тот провод!</span>")
				do_sparks(5, 1, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE
