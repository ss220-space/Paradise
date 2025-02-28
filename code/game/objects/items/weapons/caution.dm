/obj/item/caution
	desc = "Осторожно! Мокрый пол!"
	name = "wet floor sign"
	ru_names = list(
		NOMINATIVE = "знак мокрого пола",
		GENITIVE = "знака мокрого пола",
		DATIVE = "знаку мокрого пола",
		ACCUSATIVE = "знак мокрого пола",
		INSTRUMENTAL = "знаком мокрого пола",
		PREPOSITIONAL = "знаке мокрого пола"
	)
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("предупредил", "насторожил")

/obj/item/caution/proximity_sign
	var/timing = 0
	var/armed = 0
	var/timepassed = 0

/obj/item/caution/proximity_sign/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/proximity_monitor)

/obj/item/caution/proximity_sign/attack_self(mob/user as mob)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind.assigned_role != JOB_TITLE_JANITOR)
			return
		if(armed)
			armed = 0
			balloon_alert(user, "обезврежено")
			return
		timing = !timing
		if(timing)
			START_PROCESSING(SSobj, src)
		else
			armed = 0
			timepassed = 0
		to_chat(H, span_notice("Вы [timing ? "активируете таймер [declent_ru(GENITIVE)], у вас есть 15 секунд." : "деактивируете таймер [declent_ru(GENITIVE)]."]"))

/obj/item/caution/proximity_sign/process()
	if(!timing)
		STOP_PROCESSING(SSobj, src)
	timepassed++
	if(timepassed >= 15 && !armed)
		armed = 1
		timing = 0

/obj/item/caution/proximity_sign/HasProximity(atom/movable/AM)
	if(armed)
		if(iscarbon(AM) && !isbrain(AM))
			var/mob/living/carbon/C = AM
			if(C.m_intent != MOVE_INTENT_WALK)
				visible_message("[capitalize(declent_ru(NOMINATIVE))] сообщает, \"Бег по мокрому полу может быть опасен для вашего здоровья!\"")
				explosion(loc,-1,0,2, cause = src)
				if(ishuman(C))
					dead_legs(C)
				if(src)
					qdel(src)

/obj/item/caution/proximity_sign/proc/dead_legs(mob/living/carbon/human/H as mob)
	var/obj/item/organ/external/l = H.get_organ(BODY_ZONE_L_LEG)
	var/obj/item/organ/external/r = H.get_organ(BODY_ZONE_R_LEG)
	if(l)
		l.droplimb(0, DROPLIMB_SHARP)
	if(r)
		r.droplimb(0, DROPLIMB_SHARP)
