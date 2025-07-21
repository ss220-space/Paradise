#define CLOSET_BREAKOUT_TIME (2 MINUTES)

/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "Защищённый металлический шкафчик, предназначенный для хранения различных предметов. \
			Оснащён электронным замком, который активируется с помощью ID-карты. Достаточно вместительный."
	ru_names = list(
		NOMINATIVE = "защищённый шкафчик",
		GENITIVE = "защищённого шкафчика",
		DATIVE = "защищённому шкафчику",
		ACCUSATIVE = "защищённый шкафчик",
		INSTRUMENTAL = "защищённым шкафчиком",
		PREPOSITIONAL = "защищённом шкафчике"
	)
	icon = 'icons/obj/closet.dmi'
	icon_state = "secure"
	density = TRUE
	opened = FALSE
	locked = TRUE
	can_be_emaged = TRUE
	max_integrity = 250
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	damage_deflection = 20
	wall_mounted = FALSE //never solid (You can always pass over it)


/obj/structure/closet/secure_closet/examine(mob/user)
	. = ..()
	switch(lock_broken)
		if(3)
			. += span_boldnotice("Панель управления замком снята.")
		if(2)
			. += span_boldnotice("Из замка торчат провода.")
		if(1)
			. += span_boldwarning("Замок взломан.")


/obj/structure/closet/secure_closet/can_open()
	if(locked)
		return FALSE
	return ..()


/obj/structure/closet/secure_closet/close()
	. = ..()
	if(. && lock_broken)
		update_icon()


/obj/structure/closet/secure_closet/emp_act(severity)
	for(var/obj/object in src)
		object.emp_act(severity)

	if(lock_broken || opened)
		return

	if(prob(50 / severity))
		locked = !locked
		playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		flick_overlay_view(mutable_appearance(icon, overlay_sparking), sparking_duration)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), sparking_duration)

	if(prob(20 / severity))
		if(locked)
			req_access = list()
			req_access += pick(get_all_accesses())
			return
		open()


/obj/structure/closet/secure_closet/emag_act(mob/user)
	if(!lock_broken)
		add_attack_logs(user, src, "emagged")
		lock_broken = TRUE
		locked = FALSE
		playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		flick_overlay_view(mutable_appearance(icon, overlay_sparking), sparking_duration)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance), UPDATE_ICON|UPDATE_DESC), sparking_duration)
		if(user)
			balloon_alert(user, "замок взломан")


/obj/structure/closet/secure_closet/proc/togglelock(mob/living/user)
	if(!istype(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		balloon_alert(user, "ваши руки заблокированы!")
		return
	if(opened)
		balloon_alert(user, "не закрыто!")
		return
	if(lock_broken)
		balloon_alert(user, "замок сломан!")
		return
	if(user.loc == src)
		balloon_alert(user, "изнутри не достать!")
		return
	if(allowed(user))
		locked = !locked
		playsound(loc, pick(togglelock_sound), 15, TRUE, -3)
		balloon_alert(user, "замок [locked ? "за" : "раз"]блокирован")
		update_icon()
	else
		balloon_alert(user, "отказано в доступе!")
	add_fingerprint(user)


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

	if(lock_broken)
		return .

	if(locked)
		. += mutable_appearance(icon, overlay_locked, CLOSET_OLAY_LAYER_LOCK_INDICATOR)
	else
		. += mutable_appearance(icon, overlay_unlocked, CLOSET_OLAY_LAYER_LOCK_INDICATOR)


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
	visible_message(
		span_danger("[capitalize(declent_ru(NOMINATIVE))] начинает качаться из стороны в сторону с громким стуком!"),
		span_warning("Вы опираетесь спиной на заднюю стенку [declent_ru(GENITIVE)] и начинаете изо всех сил давить ногами на дверь.")
	)
	INVOKE_ASYNC(src, PROC_REF(resist_async), user)


/obj/structure/closet/secure_closet/proc/resist_async(mob/living/user)
	if(!do_after(user, CLOSET_BREAKOUT_TIME, src))
		return

	//closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
	if(!src || !user || user.incapacitated(INC_IGNORE_RESTRAINED) || user.loc != src || opened)
		return

	//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
	if(!locked && !welded)
		return

	//Well then break it!
	playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	flick_overlay_view(mutable_appearance(icon, overlay_sparking), sparking_duration)
	lock_broken = TRUE
	locked = FALSE
	welded = FALSE
	update_appearance(UPDATE_ICON|UPDATE_DESC)
	visible_message(
		span_danger("[user] выламыва[pluralize_ru(user.gender, "ет", "ют")] дверь [declent_ru(GENITIVE)] и выбира[pluralize_ru(user.gender, "ет", "ют")]ся наружу!"),
		span_warning("Вы выламываете дверь [declent_ru(GENITIVE)] и выбираетесь наружу!"),
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
	if(locked && lock_broken == 0 && user.a_intent != INTENT_HARM) // Stage one
		balloon_alert(user, "снятие панели замка...")
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(95))
				balloon_alert(user, "панель замка снята")
				lock_broken = 3
				update_icon()
			else
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
				user.apply_damage(5, BRUTE , affecting)
				user.emote("scream")
				balloon_alert(user, "неудача!")
				to_chat(user, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] срыва[pluralize_ru(I.gender, "ет", "ют")]ся, ударяя вас по [affecting.declent_ru(DATIVE)]!"))
		return TRUE

/obj/structure/closet/secure_closet/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && lock_broken == 3 && user.a_intent != INTENT_HARM) // Stage two
		balloon_alert(user, "подготовка проводов...")
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(80))
				balloon_alert(user, "провода подготовлены")
				lock_broken = 2
			else
				balloon_alert(user, "неудача!")
				to_chat(user, span_warning("Вы неправильно подготавливаете провода и вас ударяет током!"))
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

/obj/structure/closet/secure_closet/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && lock_broken == 2 && user.a_intent != INTENT_HARM) // Stage three
		balloon_alert(user, "закорачивание провода...")
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(80))
				add_attack_logs(user, src, "hacked")
				lock_broken = TRUE
				locked = FALSE
				playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				flick_overlay_view(mutable_appearance(icon, overlay_sparking), sparking_duration)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance), UPDATE_ICON|UPDATE_DESC), sparking_duration)
				balloon_alert(user, "замок взломан")
			else
				balloon_alert(user, "неудача!")
				to_chat(user, span_warning("Вы закорачиваете неверный провод и вас ударяет током!"))
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE
