/mob/living/carbon/alien/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	var/skip_catch = FALSE
	if(isitem(AM))
		var/obj/item/throw_item = AM
		skip_catch = !throw_item.allowed_for_alien()
	..(AM, skip_catch, FALSE, blocked, throwingdatum)


/// Alien attack another alien
/mob/living/carbon/alien/attack_alien(mob/living/carbon/alien/M)
	switch(M.a_intent)
		if(INTENT_HELP)
			AdjustSleeping(-10 SECONDS)
			StopResting()
			AdjustParalysis(-6 SECONDS)
			AdjustStunned(-6 SECONDS)
			AdjustWeakened(-6 SECONDS)
			if(on_fire)
				M.visible_message(span_warning("[M] trying to extinguish [src.name]!"), span_warning("You trying to extinguish [src.name]!"))
				playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				adjust_fire_stacks(-0.5)
			else
				M.visible_message(span_notice("[M.name] nuzzles [src] trying to wake it up!"))

		if(INTENT_GRAB)
			grabbedby(M)

		if(INTENT_DISARM)
			..()
			if(drop_from_active_hand())
				M.visible_message(span_danger("[M.name] disarms [src.name]!"))
			playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		if(INTENT_HARM)
			..()
			visible_message(span_danger("[M] has slashed at [src]!"), span_userdanger("[M] has slashed at [src]!"))
			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			adjustBruteLoss(M.attack_damage)
			add_attack_logs(M, src, "Alien attack", ATKLOG_ALL)


/mob/living/carbon/alien/attack_larva(mob/living/carbon/alien/larva/L)
	if(..() && L.a_intent == INTENT_HARM)
		adjustBruteLoss(L.attack_damage)

/mob/living/carbon/alien/attack_hand(mob/living/carbon/human/M)
	if(..())	//to allow surgery to return properly.
		return 0

	switch(M.a_intent)
		if(INTENT_HELP)
			help_shake_act(M)
		if(INTENT_GRAB)
			grabbedby(M)
		if(INTENT_HARM)
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		if(INTENT_DISARM)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			return 1
	return 0

/mob/living/carbon/alien/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		switch(M.melee_damage_type)
			if(BRUTE)
				adjustBruteLoss(damage)
			if(BURN)
				adjustFireLoss(damage)
			if(TOX)
				adjustToxLoss(damage)
			if(OXY)
				adjustOxyLoss(damage)
			if(CLONE)
				adjustCloneLoss(damage)
			if(STAMINA)
				adjustStaminaLoss(damage)

/mob/living/carbon/alien/acid_act(acidpwr, acid_volume)
	return 0 //aliens are immune to acid.

/mob/living/carbon/alien/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = rand(5, 35)
		if(M.age_state.age != SLIME_BABY)
			damage = rand(10 + M.age_state.damage, 40 + M.age_state.damage)
		adjustBruteLoss(damage)
		add_attack_logs(M, src, "Slime'd for [damage] damage")
		updatehealth("slime attack")
