/obj/item/grenade
	name = "grenade"
	desc = "Взрывчатое устройство, предназначенное для ручного подрыва."
	gender = FEMALE
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "chemg"
	item_state = "flashbang"
	belt_icon = "grenade"
	throw_speed = 4
	throw_range = 9
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE
	max_integrity = 40
	/// Will it detonate soon?
	var/active = FALSE
	/// Time between activation and detonation
	var/det_time = 5 SECONDS
	/// Are we able to see the detonation time on examine?
	var/display_timer = TRUE

/obj/item/grenade/deconstruct(disassembled = TRUE)
	if(!disassembled)
		prime()
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/proc/clown_check(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, span_warning("А? Как эта штука вообще работает?"))
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
			. += span_notice("Таймер установлен на <b>[det_time/10]</b> секунд[DECL_SEC_MIN(det_time/10)].")
		else
			. += span_warning("Настроено на <b>мгновенную</b> детонацию.")
	. += span_notice("Механизм активации может быть настроен <b>закручивающим</b> инструментом.")

/obj/item/grenade/attack_self(mob/user)
	if(!active && clown_check(user))
		balloon_alert(user, "взведено на [det_time/10] секунд[DECL_SEC_MIN(det_time/10)]!")
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
	SEND_SIGNAL(src, COMSIG_GRENADE_DETONATE, user)
	return

/obj/item/grenade/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.drop_item_ground(src)

/obj/item/grenade/screwdriver_act(mob/living/user, obj/item/I)
	switch(det_time)
		if(0.1 SECONDS)
			det_time = 1 SECONDS
		if(1 SECONDS)
			det_time = 3 SECONDS
		if(3 SECONDS)
			det_time = 5 SECONDS
		if(5 SECONDS)
			det_time = 0.1 SECONDS
	balloon_alert(user, "время детонации — [det_time == 0.1 SECONDS ? "мгновенно" : "[det_time/10] секунд[DECL_SEC_MIN(det_time/10)]"]")
	add_fingerprint(user)
	return TRUE

/obj/item/grenade/attack_hand(mob/user)
	GLOB.move_manager.stop_looping(src)
	. = ..()

/obj/item/grenade/blob_vore_act(obj/structure/blob/special/core/voring_core)
	obj_destruction(MELEE)
