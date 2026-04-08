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

	// dealing with creating a [/datum/component/pellet_cloud] on detonate
	/// if set, will spew out projectiles of this type
	var/shrapnel_type
	/// the higher this number, the more projectiles are created as shrapnel
	var/shrapnel_radius
	///Did we add the component responsible for spawning shrapnel to this?
	var/shrapnel_initialized

/obj/item/grenade/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CAN_ATTACH_TO_TRIPWIRE, INNATE_TRAIT)

/obj/item/grenade/deconstruct(disassembled = TRUE)
	if(!disassembled)
		prime()
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/proc/clown_check(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, span_warning("А? Как эта штука вообще работает?"))
		arm_grenade(user, 0.5 SECONDS)
		return FALSE
	return TRUE

/**
 * arm_grenade (formerly preprime) refers to when a grenade with a standard time fuze is activated, making it go beepbeepbeep and then detonate a few seconds later.
 * Grenades with other triggers like remote igniters probably skip this step and go straight to [/obj/item/grenade/proc/detonate]
 */
/obj/item/grenade/proc/arm_grenade(mob/user, delayoverride = det_time, msg = TRUE, volume = 75)
	var/turf/bombturf = get_turf(src)
	message_admins("[key_name_admin(usr)] has primed a [name] for detonation at [ADMIN_COORDJMP(bombturf)]")
	investigate_log("[key_name_log(usr)] has primed a [name] for detonation", INVESTIGATE_BOMB)
	add_attack_logs(user, src, "has primed for detonation", ATKLOG_FEW)
	add_fingerprint(user)
	if(user && msg)
		var/time = DisplayTimeText(delayoverride)
		balloon_alert(user, "взведено на [time] секунд[DECL_SEC_MIN(delayoverride / 10)]!")

	if(shrapnel_type && shrapnel_radius)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type = shrapnel_type, magnitude = shrapnel_radius)

	playsound(bombturf, 'sound/weapons/armbomb.ogg', volume, TRUE, -3)

	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		carbon_user.throw_mode_on()

	active = TRUE
	update_icon(UPDATE_ICON_STATE)
	SEND_SIGNAL(src, COMSIG_GRENADE_ARMED, det_time, delayoverride)
	addtimer(CALLBACK(src, PROC_REF(prime)), delayoverride)

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
		arm_grenade(user)

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

/obj/item/grenade/on_tripwire_trigger(obj/item/tripwire/base, mob/user)
	var/turf/turf = get_turf(base)
	forceMove(turf)
	active = TRUE
	update_appearance(UPDATE_ICON_STATE)
	playsound(turf, 'sound/weapons/armbomb.ogg', 60, TRUE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/grenade, prime)), 1 SECONDS)
	base.attached_item = null
	base.UnregisterSignal(base, COMSIG_TRIPWIRE_TRIGGERED)
