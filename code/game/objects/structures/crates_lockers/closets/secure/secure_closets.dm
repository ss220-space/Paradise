#define CLOSET_BREAKOUT_TIME 2 MINUTES

/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's an immobile card-locked storage unit."
	icon_state = "secure"
	locked = TRUE
	can_be_emaged = TRUE
	max_integrity = 250
	armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 80, ACID = 80)
	damage_deflection = 20

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
		playsound(loc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		flick_overlay_view(mutable_appearance(icon, overlay_sparking), sparking_duration)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), sparking_duration)

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
		playsound(loc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		flick_overlay_view(mutable_appearance(icon, overlay_sparking), sparking_duration)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance), UPDATE_ICON|UPDATE_DESC), sparking_duration)
		if(user)
			to_chat(user, span_notice("You break the lock on [src]."))

/obj/structure/closet/secure_closet/closed_item_click(mob/user)
	togglelock(user)

/obj/structure/closet/secure_closet/click_alt(mob/user)
	togglelock(user)
	return CLICK_ACTION_SUCCESS

/obj/structure/closet/secure_closet/attack_hand(mob/user)
	if(locked)
		togglelock(user)
	else
		add_fingerprint(user)
		toggle(user)

/obj/structure/closet/secure_closet/update_overlays()
	. = ..()

	if(opened)
		return .

	if(overlay_locker)
		. += mutable_appearance(icon, overlay_locker, CLOSET_OLAY_LAYER_LOCK_FRAME)

	if(broken)
		return .

	if(locked)
		. += mutable_appearance(icon, overlay_locked, CLOSET_OLAY_LAYER_LOCK_INDICATOR)
	else
		. += mutable_appearance(icon, overlay_unlocked, CLOSET_OLAY_LAYER_LOCK_INDICATOR)

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

	if(user.incapacitated(INC_IGNORE_RESTRAINED))
		return

	//okay, so the closet is either welded or locked... resist!!!
	balloon_alert_to_viewers("начинает трястись!", "вы сопротивляетесь...")
	visible_message(
		span_danger("[src] begins to shake violently!"),
		span_warning("Вы упираетесь спиной в внутреннюю стенку [declent_ru(ACCUSATIVE)] и начинаете толкать дверь...")
	)
	INVOKE_ASYNC(src, PROC_REF(resist_async), user)

/obj/structure/closet/secure_closet/proc/resist_async(mob/living/user)
	if(!do_after(user, breakout_time, src))
		return

	//closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
	if(!src || !user || user.incapacitated(INC_IGNORE_RESTRAINED) || user.loc != src || opened)
		return

	//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
	if(!locked && !welded)
		return

	//Well then break it!
	playsound(loc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	flick_overlay_view(mutable_appearance(icon, overlay_sparking), sparking_duration)
	broken = TRUE
	locked = FALSE
	welded = FALSE
	update_appearance(UPDATE_ICON|UPDATE_DESC)
	user.visible_message(
		span_danger("[user.declent_ru(NOMINATIVE)] успешно выбира[PLUR_ET_UT(user)]ся из [declent_ru(GENITIVE)]!"),
		span_notice("Вы успешно выбираетесь из [declent_ru(GENITIVE)]!")
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
		to_chat(user, span_notice("Вы начинаете откручивать панель замка [src]..."))
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(95)) // EZ
				to_chat(user, span_notice("Вы успешно открутили и сняли панель с замка [src]!"))
				desc += " Панель управления снята."
				broken = 3
				update_icon()
			else // Bad day)
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
				user.apply_damage(5, BRUTE , affecting)
				user.emote("scream")
				to_chat(user, span_warning("Проклятье! [I] сорвалась и повредила [affecting.name]!"))
		return TRUE

/obj/structure/closet/secure_closet/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && broken == 3 && user.a_intent != INTENT_HARM) // Stage two
		to_chat(user, span_notice("Вы начинаете подготавливать провода панели [src]..."))
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(80)) // Good hacker!
				to_chat(user, span_notice("Вы успешно подготовили провода панели замка [src]!"))
				desc += " Провода отключены и торчат наружу."
				broken = 2
			else // woopsy
				to_chat(user, span_warning("Черт! Не тот провод!"))
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

/obj/structure/closet/secure_closet/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && broken == 2 && user.a_intent != INTENT_HARM) // Stage three
		to_chat(user, span_notice("Вы начинаете подключать провода панели замка [src] к [I]..."))
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(80)) // Good hacker!
				desc += " Замок отключен."
				broken = 0 // Can be emagged
				emag_act(user)
			else // woopsy
				to_chat(user, span_warning("Черт! Не тот провод!"))
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

#undef CLOSET_BREAKOUT_TIME
