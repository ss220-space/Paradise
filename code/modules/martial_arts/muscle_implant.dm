/datum/martial_art/muscle_implant
	name = "Боевое искусство усиленной мышечной имплантации"
	weight = 1
	/// Are we EMP'ed?
	var/is_emped = FALSE
	/// How much damage should our punches deal
	var/punch_damage = 13

/datum/martial_art/muscle_implant/harm_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	MARTIAL_ARTS_ACT_CHECK

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("Вы не хотите причинять вред [target.declent_ru(DATIVE)]!"))
		return FALSE
	var/picked_hit_type = pick("ударил", "размозжил")
	if(ishuman(target) && target.check_shields(user, punch_damage, "[DECLENT_RU_CAP(user, NOMINATIVE)] [picked_hit_type][GEND_A_O_I(user)]"))
		user.do_attack_animation(target)
		playsound(target.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
		return FALSE
	if(is_emped)
		do_the_punch(user, user)
	else
		do_the_punch(user, target)
	playsound(target.loc, 'sound/weapons/resonator_blast.ogg', 50, TRUE)
	playsound(target.loc, 'sound/weapons/genhit2.ogg', 50, TRUE)

	return TRUE

/datum/martial_art/muscle_implant/proc/do_the_punch(mob/living/carbon/human/puncher, mob/living/carbon/human/punchee)
	puncher.do_attack_animation(punchee, ATTACK_EFFECT_SMASH)
	add_attack_logs(puncher, punchee, "Melee attacked with martial-art [src] : Punched", ATKLOG_ALL)
	punchee.apply_damage(punch_damage, BRUTE, puncher.zone_selected)

	if(!IS_HORIZONTAL(puncher)) //Throw them if we are standing
		var/atom/throw_target = get_edge_target_turf(punchee, puncher.dir)
		punchee.throw_at(throw_target, rand(1, 2), 0.5, puncher)

	var/picked_hit_type = pick("ударил", "размозжил", "пнул")
	punchee.visible_message(
		span_danger("[DECLENT_RU_CAP(puncher, NOMINATIVE)] [picked_hit_type][GEND_A_O_I(puncher)] [punchee.declent_ru(ACCUSATIVE)]!"),
		span_danger("Вы [picked_hit_type]и [punchee.declent_ru(ACCUSATIVE)]!"),
		span_danger("Вы слышите тошнотворный звук удара плоти о плоть!")
	)

	if(puncher == punchee)
		to_chat(puncher, span_danger("Вы [picked_hit_type]и себя!"))
	else
		to_chat(puncher, span_danger("Вы [picked_hit_type]и [punchee.declent_ru(ACCUSATIVE)]!"))

/datum/martial_art/muscle_implant/proc/emp_act(severity, mob/owner)
	is_emped = TRUE
	to_chat(owner, span_danger("Ваши руки дико спазмируют!"))
	addtimer(CALLBACK(src, PROC_REF(reboot), owner), (18 / severity) SECONDS)

/datum/martial_art/muscle_implant/proc/reboot(mob/owner)
	is_emped = FALSE
	to_chat(owner, span_danger("Ваши руки перестают спазмировать."))
