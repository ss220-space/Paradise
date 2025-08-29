/obj/item/caution
	desc = "Осторожно! Мокрый пол!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("предупредил", "насторожил")

/obj/item/caution/get_ru_names()
	return list(
		NOMINATIVE = "знак мокрого пола",
		GENITIVE = "знака мокрого пола",
		DATIVE = "знаку мокрого пола",
		ACCUSATIVE = "знак мокрого пола",
		INSTRUMENTAL = "знаком мокрого пола",
		PREPOSITIONAL = "знаке мокрого пола"
	)

/obj/item/caution/proximity_sign
	var/timing = FALSE
	var/armed = FALSE
	var/timepassed = 0
	/// Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor

/obj/item/caution/proximity_sign/Initialize(mapload)
	. = ..()

/obj/item/caution/proximity_sign/Destroy()
	. = ..()
	QDEL_NULL(proximity_monitor)

/obj/item/caution/proximity_sign/attack_self(mob/user as mob)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind.assigned_role != JOB_TITLE_JANITOR)
			return
		if(armed)
			armed = FALSE
			balloon_alert(user, "обезврежено")
			QDEL_NULL(proximity_monitor)
			return
		timing = !timing
		if(timing)
			START_PROCESSING(SSobj, src)
		else
			armed = FALSE
			timepassed = 0
		to_chat(H, span_notice("Вы [timing ? "активируете таймер [declent_ru(GENITIVE)], у вас есть 15 секунд." : "деактивируете таймер [declent_ru(GENITIVE)]."]"))

/obj/item/caution/proximity_sign/process()
	if(!timing)
		STOP_PROCESSING(SSobj, src)
	timepassed++
	if(timepassed >= 15 && !armed)
		armed = TRUE
		timing = FALSE
		proximity_monitor = new(src)

/obj/item/caution/proximity_sign/HasProximity(mob/living/carbon/proximity_check_mob)
	if(!armed)
		return

	if(iscarbon(proximity_check_mob) && !isbrain(proximity_check_mob))
		var/mob/living/carbon/victim = proximity_check_mob
		if(victim.m_intent != MOVE_INTENT_WALK)
			visible_message("[capitalize(declent_ru(NOMINATIVE))] сообщает: \"Бег по мокрому полу может быть опасен для вашего здоровья!\"")
			explosion(loc, devastation_range = -1, heavy_impact_range = 0, light_impact_range = 2, cause = src)
			if(ishuman(victim))
				dead_legs(victim)
			if(src)
				qdel(src)

/obj/item/caution/proximity_sign/proc/dead_legs(mob/living/carbon/human/H as mob)
	var/obj/item/organ/external/l = H.get_organ(BODY_ZONE_L_LEG)
	var/obj/item/organ/external/r = H.get_organ(BODY_ZONE_R_LEG)
	if(l)
		l.droplimb(0, DROPLIMB_SHARP)
	if(r)
		r.droplimb(0, DROPLIMB_SHARP)
