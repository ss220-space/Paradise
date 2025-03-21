/mob/living/basic/attack_hand(mob/living/carbon/human/user)
	// so that martial arts don't double dip
	if(..())
		return TRUE

	switch(user.a_intent)
		if(INTENT_HELP)
			if(stat == DEAD)
				return
			visible_message(span_notice("[user] [response_help_continuous] [src.declent_ru(ACCUSATIVE)]."), \
				span_notice("[user] [response_help_continuous] вас."))
			//to_chat(user, span_notice("Вы [response_help_simple] [src.declent_ru(ACCUSATIVE)]."))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
			return TRUE

		if(INTENT_GRAB)
			grabbedby(user)

		if(INTENT_DISARM)
			user.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			playsound(src, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
			var/shove_dir = get_dir(user, src)
			if(!Move(get_step(src, shove_dir), shove_dir))
				add_attack_logs(user, src, "толкнул")
				visible_message(span_danger("[user] [response_disarm_continuous] [src.declent_ru(ACCUSATIVE)]!"), \
					span_userdanger("[user] [response_disarm_continuous] вас!"), \
					span_warning("Вы слышите звуки шарканья!"))
				//to_chat(user, span_danger("Вы [response_disarm_simple] [src.declent_ru(ACCUSATIVE)]!"))
			else
				add_attack_logs(user, src, "толкнул")
				visible_message(span_danger("[user] [response_disarm_continuous] [src.declent_ru(ACCUSATIVE)], отталкивая [genderize_ru(src.gender, "его", "её", "его", "их")]!"), \
					span_userdanger("[user] оттолкнул вас!"), \
					span_warning("Вы слышите звуки шарканья!"))
				//to_chat(user, span_danger("Вы [response_disarm_simple] [src.declent_ru(ACCUSATIVE)], отталкивая [genderize_ru(src.gender, "его", "её", "его", "их")]!"))
			return TRUE
		if(INTENT_HARM)
			if(GLOB.pacifism_after_gt || HAS_TRAIT(user, TRAIT_PACIFISM))
				to_chat(user, span_warning("Вы не хотите вредить [src.declent_ru(DATIVE)]."))
				return
			user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			visible_message(span_danger("[user] [response_harm_continuous] [src.declent_ru(ACCUSATIVE)]!"), \
				span_userdanger("[user] [response_harm_continuous] вас!"))
			//to_chat(user, span_danger("Вы [response_harm_simple] [src.declent_ru(ACCUSATIVE)]!"))
			attack_threshold_check(user.dna.species.punchdamagehigh)
			add_attack_logs(user, src, "атаковал")
			updatehealth()
			return TRUE

/*
/mob/living/basic/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	playsound(loc, "punch", 25, TRUE, -1)
	visible_message(span_danger("[user] крушит [src.declent_ru(ACCUSATIVE)]!"), \
				span_userdanger("[user] сокрушает вас!"))
	to_chat(user, span_danger("Вы бьёте [src.declent_ru(ACCUSATIVE)]!"))
	adjustBruteLoss(30)
*/

/*
/mob/living/basic/attack_paw(mob/living/carbon/human/user)
	if(..()) //successful monkey bite.
		if(stat != DEAD)
			var/damage = rand(1, 3)
			attack_threshold_check(damage)
			return 1
	if(user.a_intent == INTENT_HELP)
		if(health > 0)
			visible_message(span_notice("[user.name] [response_help_continuous] [src.declent_ru(ACCUSATIVE)]."), \
				span_notice("[user.name] [response_help_continuous] вас."))
			to_chat(user, span_notice("Вы [response_help_simple] [src.declent_ru(ACCUSATIVE)]."))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
*/

/mob/living/basic/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(..()) //if harm or disarm intent.
		if(user.a_intent == INTENT_DISARM)
			playsound(loc, 'sound/weapons/pierce.ogg', 25, TRUE, -1)
			visible_message(span_danger("[user] [response_disarm_continuous] [src.declent_ru(ACCUSATIVE)]!"), \
				span_userdanger("[user] [response_disarm_continuous] вас!"), \
				span_warning("Вы слышите звуки шарканья!"))
			//to_chat(user, span_danger("Вы [response_disarm_simple] [src.declent_ru(ACCUSATIVE)]!"))
			add_attack_logs(user, src, "толкнул")
		else
			var/damage = rand(15, 30)
			visible_message(span_danger("[user] терзает [src.declent_ru(ACCUSATIVE)]!"), \
				span_userdanger("[user] терзает вас!"))
			//to_chat(user, span_danger("Вы бьёте [src.declent_ru(ACCUSATIVE)]!"))
			playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
			attack_threshold_check(damage)
			add_attack_logs(user, src, "атаковал")
		return 1

/mob/living/basic/attack_larva(mob/living/carbon/alien/larva/L)
	. = ..()
	if(. && stat != DEAD) //successful larva bite
		var/damage = rand(5, 10)
		. = attack_threshold_check(damage)

/mob/living/basic/attack_basic_mob(mob/living/basic/user)
	. = ..()
	if(.)
		// var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		return attack_threshold_check(user.melee_damage, user.melee_damage_type)

/mob/living/basic/attack_animal(mob/living/simple_animal/user)
	. = ..()
	if(.)
		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		return attack_threshold_check(damage, user.melee_damage_type)

/mob/living/basic/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = 20
		return attack_threshold_check(damage)

/mob/living/basic/proc/attack_threshold_check(damage, damagetype = BRUTE, armorcheck = MELEE, actuallydamage = TRUE)
	var/temp_damage = damage
	if(!damage_coeff[damagetype])
		temp_damage = 0
	else
		temp_damage *= damage_coeff[damagetype]

	if(temp_damage >= 0 && temp_damage <= force_threshold)
		visible_message(span_danger("[src] игнорирует удар."))
		return FALSE
	else
		apply_damage(damage, damagetype, null, getarmor(null, armorcheck))
		return TRUE

/mob/living/basic/bullet_act(obj/projectile/Proj, def_zone, piercing_hit = FALSE)
	apply_damage(Proj.damage, Proj.damage_type)
	Proj.on_hit(src, 0, piercing_hit)
	return

/mob/living/basic/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return FALSE

	..()
	if(QDELETED(src))
		return
	var/bomb_armor = getarmor(null, BOMB)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			if(prob(bomb_armor))
				adjustBruteLoss(500)
			else
				gib()
				return
		if (EXPLODE_HEAVY)
			var/bloss = 60
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			adjustBruteLoss(bloss)

		if (EXPLODE_LIGHT)
			var/bloss = 30
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			adjustBruteLoss(bloss)

/mob/living/basic/blob_act(obj/structure/blob/B)
	adjustBruteLoss(20)
	return

/mob/living/basic/do_attack_animation(atom/A, visual_effect_icon, used_item, no_effect)
	if(!no_effect && !visual_effect_icon && melee_damage)
		if(melee_damage < 10)
			visual_effect_icon = ATTACK_EFFECT_PUNCH
		else
			visual_effect_icon = ATTACK_EFFECT_SMASH
	..()

/mob/living/basic/update_stat()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
		else
			set_stat(CONSCIOUS)
	med_hud_set_status()

