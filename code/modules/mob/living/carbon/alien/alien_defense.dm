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
			if(M != src)
				AdjustSleeping(-10 SECONDS)
				AdjustParalysis(-6 SECONDS)
				AdjustStunned(-6 SECONDS)
				AdjustWeakened(-6 SECONDS)
				set_resting(FALSE, instant = TRUE)

			if(on_fire)
				M.visible_message(span_warning("[DECLENT_RU_CAP(M, NOMINATIVE)] пыта[PLUR_ET_UT(M)]ся потушить [declent_ru(ACCUSATIVE)]!"), span_warning("Вы пытаетесь потушить [declent_ru(ACCUSATIVE)]"))
				playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
				adjust_fire_stacks(-1)
			else
				M.visible_message(span_notice("[DECLENT_RU_CAP(M, NOMINATIVE)] тряс[PLUR_ET_UT(M)] [declent_ru(ACCUSATIVE)] пытаясь разбудить [GEND_HIS_HER(src)]!"))

		if(INTENT_GRAB)
			grabbedby(M)

		if(INTENT_DISARM)
			..()
			if(drop_from_active_hand())
				M.visible_message(span_danger("[DECLENT_RU_CAP(M, NOMINATIVE)] обезоруживает [declent_ru(ACCUSATIVE)]!"))
			playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

		if(INTENT_HARM)
			..()
			visible_message(span_danger("[DECLENT_RU_CAP(M, NOMINATIVE)] полоснул[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!"), span_userdanger("[DECLENT_RU_CAP(M, NOMINATIVE)] полоснул [declent_ru(ACCUSATIVE)]!"))
			playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
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
		apply_damage(damage, M.melee_damage_type)

/mob/living/carbon/alien/acid_act(acidpwr, acid_volume)
	return 0 //aliens are immune to acid.

/mob/living/carbon/alien/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = rand(5, 35)
		if(M.age_state.age != SLIME_BABY)
			damage = rand(10 + M.age_state.damage, 40 + M.age_state.damage)
		adjustBruteLoss(damage)
		add_attack_logs(M, src, "Slime'd for [damage] damage")

/mob/living/carbon/alien/handle_flamer_fire_crossed(obj/flamer_fire/fire)
	. = ..()
	switch(fire.fire_variant)
		if(FIRE_VARIANT_TYPE_B) //Armor Shredding Greenfire
			fire.set_on_fire(src) //Deals an extra proc of fire when you're crossing it. 30 damage per tile crossed, plus 15 per Process().
			SetSlowed(1 SECONDS, (SLOWDOWN_AMT_GREENFIRE))
			to_chat(src, span_danger("Мы чувствуем, как части нашего экзоскелета сплавляются с вязкой жидкостью внизу и отрываются, пока мы с трудом пробираемся сквозь пламя!"))
