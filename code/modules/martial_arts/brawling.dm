/datum/martial_art/boxing
	name = "Boxing"
	has_dirslash = FALSE
	change_musculs = FALSE
	weight = 1

/datum/martial_art/boxing/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, span_warning("Can't disarm while boxing!"))
	return 1

/datum/martial_art/boxing/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, span_warning("Can't grab while boxing!"))
	return 1

/datum/martial_art/boxing/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = rand(5, 8) + A.dna.species.punchdamagelow + A.physiology.punch_damage_low
	if(!damage)
		playsound(D.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
		D.visible_message(span_warning("[A] has attempted to hit [D] with a [atk_verb]!"))
		add_attack_logs(A, D, "Melee attacked with [src] (miss/block)", ATKLOG_ALL)
		return 0

	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE)

	playsound(D.loc, SFX_BOXING, 50, TRUE, -1)

	D.visible_message(span_danger("[A] has hit [D] with a [atk_verb]!"), \
								span_userdanger("[A] has hit [D] with a [atk_verb]!"))

	D.apply_damage(damage, STAMINA, affecting, armor_block)
	add_attack_logs(A, D, "Melee attacked with [src]", ATKLOG_ALL)
	if(D.getStaminaLoss() > 50)
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)
		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message(span_danger("[A] has knocked [D] out with a haymaker!"), \
								span_userdanger("[A] has knocked [D] out with a haymaker!"))
			D.apply_effect(20 SECONDS, WEAKEN, armor_block)
			D.Weaken(6 SECONDS)
			D.force_say(GLOB.hit_appends)
		else if(D.body_position == LYING_DOWN)
			D.force_say(GLOB.hit_appends)
	return 1

/datum/martial_art/psychotic_brawling
	name = "Psychotic Brawling"
	has_dirslash = FALSE
	change_musculs = FALSE
	weight = 3

/datum/martial_art/psychotic_brawling/can_use(mob/living/carbon/human/human)
	return !HAS_TRAIT(human, TRAIT_MARTIAL_ARTS_SUPPRESSED)

/datum/martial_art/psychotic_brawling/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return psycho_attack(A, D)

/datum/martial_art/psychotic_brawling/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return psycho_attack(A, D, TRUE)

/datum/martial_art/psychotic_brawling/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return psycho_attack(A, D)

/datum/martial_art/psychotic_brawling/proc/psycho_attack(mob/living/carbon/human/A, mob/living/carbon/human/D, grab_attack = FALSE)
	switch(rand(1, 8))
		if(1)
			D.help_shake_act(A)
			add_attack_logs(A, D, "helped with [src]")
			return TRUE
		if(2)
			A.emote("cry")
			A.Stun(2 SECONDS)
			return TRUE
		if(3)
			if(A.body_position == LYING_DOWN)
				return FALSE
			if(D.grabbedby(A, supress_message = TRUE))
				D.visible_message(
					span_danger("[A] в исступлении хватает [D]!"),
					span_userdanger("[A] в исступлении хватает вас!")
				)
				if(grab_attack)
					D.drop_l_hand()
					D.drop_r_hand()
			return TRUE
		if(4)
			var/damage = rand(5, 10)
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
			A.emote("flip")
			D.visible_message(
				span_danger("[A] бьёт [D] головой!"),
				span_userdanger("[A] бьёт вас головой!")
			)
			playsound(D.loc, 'sound/weapons/punch1.ogg', 40, TRUE, -1)
			D.apply_damage(damage, BRUTE, D.get_organ(BODY_ZONE_HEAD))
			objective_damage(A, D, damage, BRUTE)
			A.apply_damage(rand(5, 10), BRUTE, A.get_organ(BODY_ZONE_HEAD))
			if(!istype(D.head, /obj/item/clothing/head/helmet))
				D.adjustBrainLoss(5)
			A.Stun(randfloat(1 SECONDS, 4.5 SECONDS))
			D.Stun(randfloat(0.5 SECONDS, 3 SECONDS))
			add_attack_logs(A, D, "headbutted with [src]")
			return TRUE
		if(5, 6)
			var/atk_verb = pick("пинает", "бьёт", "впечатывает")
			var/damage = rand(15, 30)
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
			D.visible_message(
				span_danger("[A] [atk_verb] [D] с такой нечеловеческой силой, что [D] отлетает назад!"),
				span_userdanger("[A] [atk_verb] вас с такой нечеловеческой силой, что вас отбрасывает назад!")
			)
			playsound(D.loc, 'sound/effects/meteorimpact.ogg', 25, TRUE, -1)
			D.apply_damage(damage, BRUTE)
			objective_damage(A, D, damage, BRUTE)
			var/turf/throwtarget = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
			D.throw_at(throwtarget, 4, 2, A)
			D.Paralyse(6 SECONDS)
			add_attack_logs(A, D, "Melee attacked with [src]")
			return TRUE
		if(7, 8)
			return FALSE

/datum/martial_art/drunk_brawling
	name = "Drunken Brawling"
	weight = 2

/datum/martial_art/drunk_brawling/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(prob(70))
		A.visible_message(span_warning("[A] tries to grab ahold of [D], but fails!"), \
							span_warning("You fail to grab ahold of [D]!"))
		return TRUE

	if(D.grabbedby(A, supress_message = TRUE))
		D.visible_message(span_danger("[A] grabs ahold of [D] drunkenly!"), \
								span_userdanger("[A] grabs ahold of [D] drunkenly!"))
	return TRUE

/datum/martial_art/drunk_brawling/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_attack_logs(A, D, "Melee attacked with [src]")
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("jab","uppercut","overhand punch","drunken right hook","drunken left hook")

	var/damage = rand(0,6)

	if(atk_verb == "uppercut")
		if(prob(90))
			damage = 0
		else //10% chance to do a massive amount of damage
			damage = 14

	if(prob(50)) //they are drunk, they aren't going to land half of their hits
		damage = 0

	if(!damage)
		playsound(D.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
		D.visible_message(span_warning("[A] has attempted to hit [D] with a [atk_verb]!"))
		return 1 //returns 1 so that they actually miss and don't switch to attackhand damage

	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE)

	playsound(D.loc, 'sound/weapons/punch1.ogg', 25, TRUE, -1)

	D.visible_message(span_danger("[A] has hit [D] with a [atk_verb]!"), \
								span_userdanger("[A] has hit [D] with a [atk_verb]!"))

	D.apply_damage(damage, BRUTE, null, armor_block)
	objective_damage(A, D, damage, BRUTE)

	D.apply_damage(damage, STAMINA, armor_block)
	if(D.getStaminaLoss() > 50)
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)
		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message(span_danger("[A] has knocked [D] out with a haymaker!"), \
								span_userdanger("[A] has knocked [D] out with a haymaker!"))
			D.Paralyse(10 SECONDS)
			D.apply_effect(20 SECONDS, WEAKEN, armor_block)
			D.force_say(GLOB.hit_appends)
		else if(D.body_position == LYING_DOWN)
			D.force_say(GLOB.hit_appends)
	return 1
