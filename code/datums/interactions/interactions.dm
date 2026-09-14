#define INTERACTION_CATEGORY_DEFAULT ""
#define INTERACTION_CATEGORY_HANDS "Руки"
#define INTERACTION_CATEGORY_MOUTH "Язык"

#define INTERACTION_CHECH_HANDS (1<<0)
#define INTERACTION_CHECH_ADJACENT (1<<1)
#define INTERACTION_CHECH_MOUTH (1<<2)
#define INTERACTION_CHECH_INCAPITATED (1<<3)
#define INTERACTION_CHECH_COVER_ZONE (1<<4)
#define INTERACTION_CHECH_TARGET_HANDS (1<<5)

/// Interaction without category
/datum/interaction
	abstract_type = /datum/interaction
	var/category = INTERACTION_CATEGORY_DEFAULT
	var/action
	var/danger = FALSE
	var/intaraction_flags = NONE

/// It is used to check for the possibility to use this interaction. Redefined for different types of interactions
/datum/interaction/proc/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target, cached_checks = new/list(2))
	var/local_cached_checks = cached_checks[1]
	var/local_cached_failed_checks = cached_checks[2]
	var/intaraction_flags = src.intaraction_flags & ~local_cached_checks

	if(intaraction_flags & local_cached_failed_checks)
		return FALSE

	if(intaraction_flags & INTERACTION_CHECH_HANDS)
		if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			local_cached_failed_checks |= INTERACTION_CHECH_HANDS
			return FALSE
		if(!user.has_organ_for_slot(ITEM_SLOT_HAND_LEFT) && !user.has_organ_for_slot(ITEM_SLOT_HAND_RIGHT))
			local_cached_failed_checks |= INTERACTION_CHECH_HANDS
			return FALSE
		local_cached_checks |= INTERACTION_CHECH_HANDS

	if(intaraction_flags & INTERACTION_CHECH_TARGET_HANDS)
		if(HAS_TRAIT(target, TRAIT_HANDS_BLOCKED))
			local_cached_failed_checks |= INTERACTION_CHECH_TARGET_HANDS
			return FALSE
		if(!target.has_organ_for_slot(ITEM_SLOT_HAND_LEFT) && !target.has_organ_for_slot(ITEM_SLOT_HAND_RIGHT))
			local_cached_failed_checks |= INTERACTION_CHECH_TARGET_HANDS
			return FALSE
		local_cached_checks |= INTERACTION_CHECH_TARGET_HANDS

	if(intaraction_flags & INTERACTION_CHECH_ADJACENT)
		if(!target.Adjacent(user))
			local_cached_failed_checks |= INTERACTION_CHECH_ADJACENT
			return FALSE
		local_cached_checks |= INTERACTION_CHECH_ADJACENT

	if(intaraction_flags & INTERACTION_CHECH_MOUTH)
		if(!get_location_accessible(user, BODY_ZONE_PRECISE_MOUTH))
			local_cached_failed_checks |= INTERACTION_CHECH_MOUTH
			return FALSE
		local_cached_checks |= INTERACTION_CHECH_MOUTH

	if(intaraction_flags & INTERACTION_CHECH_INCAPITATED)
		if(user.incapacitated())
			local_cached_failed_checks |= INTERACTION_CHECH_INCAPITATED
			return FALSE
		local_cached_checks |= INTERACTION_CHECH_INCAPITATED

	var/zone = user.zone_selected
	if(intaraction_flags & INTERACTION_CHECH_COVER_ZONE)
		if(!user.get_organ(zone) || user.covered_with_thick_material(zone))
			local_cached_failed_checks |= INTERACTION_CHECH_COVER_ZONE
			return FALSE
		local_cached_checks |= INTERACTION_CHECH_COVER_ZONE

	cached_checks[1] = local_cached_checks
	cached_checks[2] = local_cached_failed_checks

	return TRUE

// Used to execute the interaction
/datum/interaction/proc/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return

/datum/interaction/bow
	action = "Отвесить поклон"

/datum/interaction/bow/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "кланя[PLUR_ET_YUT(user)]ся [target].")

/datum/interaction/bow_affably
	action = "Приветливо кивнуть"

/datum/interaction/bow_affably/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "приветливо кивнул[GEND_A_O_I(user)] в сторону [target].")

/// Interaction with the Hands category requires ONLY the user to have hands
/datum/interaction/hands
	abstract_type = /datum/interaction/hands
	category = INTERACTION_CATEGORY_HANDS
	intaraction_flags = INTERACTION_CHECH_HANDS|INTERACTION_CHECH_INCAPITATED

/datum/interaction/hands/wave
	action = "Приветливо помахать"

/datum/interaction/hands/wave/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "приветливо маш[PLUR_ET_UT(user)] в сторону [target].")

/datum/interaction/hands/fuckyou
	action = "Показать средний палец"
	danger = TRUE

/datum/interaction/hands/fuckyou/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = span_danger("показыва[PLUR_ET_YUT(user)] [target] средний палец!"))

/datum/interaction/hands/threaten
	action = "Погрозить кулаком"

/datum/interaction/hands/threaten/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = span_danger("гроз[PLUR_IT_YAT(user)] [target] кулаком!"))

/datum/interaction/hands/handshake
	action = "Пожать руку"
	intaraction_flags = INTERACTION_CHECH_ADJACENT|INTERACTION_CHECH_HANDS|INTERACTION_CHECH_TARGET_HANDS

/datum/interaction/hands/handshake/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "жм[PLUR_YOT_UT(user)] руку [target].")

/datum/interaction/hands/hug
	action = "Обнимашки!"
	intaraction_flags = INTERACTION_CHECH_ADJACENT|INTERACTION_CHECH_HANDS

/datum/interaction/hands/hug/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "обнима[PLUR_ET_YUT(user)] [target].")
	playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

/datum/interaction/hands/cheer
	action = "Похлопать по плечу"
	intaraction_flags = INTERACTION_CHECH_ADJACENT|INTERACTION_CHECH_HANDS

/datum/interaction/hands/cheer/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "похлопыва[PLUR_ET_YUT(user)] [target] по плечу.")

/datum/interaction/hands/slap
	action = "Дать пощечину!"
	danger = TRUE
	intaraction_flags = INTERACTION_CHECH_ADJACENT|INTERACTION_CHECH_HANDS
	var/list/possible_zones = list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_MOUTH)

/datum/interaction/hands/slap/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!(user.zone_selected in possible_zones))
		return FALSE

/datum/interaction/hands/slap/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/organ/external/targeted_organ = target.get_organ(user.zone_selected)
	if(!targeted_organ)
		return

	switch(user.zone_selected)
		if(BODY_ZONE_HEAD)
			user.custom_emote(message = span_danger("да[PLUR_ET_YUT(user)] [target] пощечину!"))
		if(BODY_ZONE_PRECISE_GROIN)
			user.custom_emote(message = span_danger("шлёпа[PLUR_ET_YUT(user)] [target] по заднице!"))
		if(BODY_ZONE_PRECISE_MOUTH)
			user.custom_emote(message = span_danger("да[PLUR_ET_YUT(user)] [target] по губе!"))
		else
			return
	if(targeted_organ.brute_dam < 5)
		target.apply_damage(1, def_zone = targeted_organ)

	playsound(user.loc, 'sound/effects/snap.ogg', 50, TRUE, -1)
	user.do_attack_animation(target)

/datum/interaction/hands/knock
	action = "Дать подзатыльник"
	danger = TRUE
	intaraction_flags = INTERACTION_CHECH_ADJACENT|INTERACTION_CHECH_HANDS

/datum/interaction/hands/knock/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/organ/external/head/head = target.get_organ(BODY_ZONE_HEAD)
	if(!head)
		return

	if(head.brute_dam < 5)
		target.apply_damage(1, def_zone = head)

	user.custom_emote(message = span_danger("да[PLUR_ET_YUT(user)] [target] подзатыльник!"))
	playsound(user.loc, 'sound/weapons/throwtap.ogg', 50, TRUE, -1)
	user.do_attack_animation(target)


/datum/interaction/hands/pullwing
	action = "Дёрнуть за крылья!"
	intaraction_flags = INTERACTION_CHECH_ADJACENT|INTERACTION_CHECH_HANDS

/datum/interaction/hands/pullwing/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()

	if(!.)
		return FALSE

	if(!(target.dna.species.bodyflags & HAS_WING))
		return FALSE

/datum/interaction/hands/pullwing/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/organ/external/wing/wing = target.get_organ(BODY_ZONE_WING)
	if(!wing)
		user.custom_emote(message = "пыта[PLUR_ET_YUT(user)]ся поймать [target] за крылья, [span_danger("КОТОРЫХ НЕТ!!!")]")
		return

	if(!prob(30))
		user.custom_emote(message = "пыта[PLUR_ET_YUT(user)]ся поймать [target] за крылья!")
		return

	if((wing.is_dead() || wing.has_fracture()) && prob(20))
		user.custom_emote(message = span_danger("отрыва[PLUR_ET_YUT(user)] [target] крылья!"))
		wing.droplimb()
		return

	if(wing.brute_dam < 10)
		target.apply_damage(1, def_zone = wing)

	user.custom_emote(message = span_danger("дёрга[PLUR_ET_YUT(user)] [target] за крылья!"))

/datum/interaction/hands/pull
	action = "Дёрнуть за хвост!"
	danger = TRUE
	intaraction_flags = INTERACTION_CHECH_ADJACENT|INTERACTION_CHECH_HANDS

/datum/interaction/hands/pull/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()

	if(!.)
		return FALSE

	if(!(target.dna.species.bodyflags & HAS_TAIL))
		return FALSE

/datum/interaction/hands/pull/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/organ/external/tail/tail = target.get_organ(BODY_ZONE_TAIL)
	if(!tail)
		user.custom_emote(message = "пыта[PLUR_ET_YUT(user)]ся поймать [target] за хвост, [span_danger("КОТОРОГО НЕТ!!!")]")
		return

	var/obj/item/organ/internal/cyberimp/tail/blade/implant = target.get_organ_slot(INTERNAL_ORGAN_TAIL_DEVICE)
	if(istype(implant) && implant.activated)  // KEEP YOUR HANDS AWAY FROM ME!
		if(user.has_pain())
			user.emote("scream")

		user.custom_emote(message = span_danger("пыта[PLUR_ET_YUT(user)]ся дёрнуть [target] за хвост, но резко одёргива[PLUR_ET_YUT(user)] руки!"))
		user.apply_damage(5, implant.damage_type, BODY_ZONE_PRECISE_R_HAND)
		user.apply_damage(5, implant.damage_type, BODY_ZONE_PRECISE_L_HAND)
		return

	if(prob(70))
		user.custom_emote(message = "пыта[PLUR_ET_YUT(user)]ся поймать [target] за хвост!")
		return

	if((tail.is_dead() || tail.has_fracture()) && prob(20))
		user.custom_emote(message = span_danger("отрыва[PLUR_ET_YUT(user)] [target] хвост!"))
		tail.droplimb()
		return

	if(tail.brute_dam < 10)
		target.apply_damage(1, def_zone = tail)

	user.custom_emote(message = span_danger("дёрга[PLUR_ET_YUT(user)] [target] за хвост!"))

/datum/interaction/hands/pet
	action = "Погладить"
	intaraction_flags = INTERACTION_CHECH_ADJACENT|INTERACTION_CHECH_HANDS|INTERACTION_CHECH_COVER_ZONE

/datum/interaction/hands/pet/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "[pick("глад[PLUR_IT_YAT(user)]", "поглажива[PLUR_ET_YUT(user)]")] [target].")

/datum/interaction/hands/scratch
	action = "Почесать"
	intaraction_flags = INTERACTION_CHECH_ADJACENT|INTERACTION_CHECH_HANDS|INTERACTION_CHECH_COVER_ZONE

/datum/interaction/hands/scratch/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.zone_selected != BODY_ZONE_HEAD || ismachineperson(target) || isunathi(target) || isgrey(target))
		user.custom_emote(message = "[pick("чеш[PLUR_ET_UT(user)]")] [target].")
	else
		user.custom_emote(message = "[pick("чеш[PLUR_ET_UT(user)] за ухом", "чеш[PLUR_ET_UT(user)] голову")] [target].")

/datum/interaction/hands/five
	action = "Дать пять"
	intaraction_flags = INTERACTION_CHECH_ADJACENT|INTERACTION_CHECH_HANDS|INTERACTION_CHECH_TARGET_HANDS

/datum/interaction/hands/five/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "да[PLUR_YOT_YUT(user)] [target] пять.")
	playsound(user.loc, 'sound/effects/snap.ogg', 25, TRUE, -1)

/datum/interaction/hands/give
	action = "Передать предмет"
	intaraction_flags = INTERACTION_CHECH_ADJACENT|INTERACTION_CHECH_HANDS|INTERACTION_CHECH_TARGET_HANDS

/datum/interaction/hands/give/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.give(target)

/// Interaction with the Mouth category
/datum/interaction/mouth
	abstract_type = /datum/interaction/mouth
	category = INTERACTION_CATEGORY_MOUTH
	intaraction_flags = INTERACTION_CHECH_MOUTH

/datum/interaction/mouth/kiss
	action = "Поцеловать"

/datum/interaction/mouth/kiss/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!get_location_accessible(user, BODY_ZONE_PRECISE_MOUTH))
		return

	if(!target.Adjacent(user.loc))
		user.custom_emote(message = "посыла[PLUR_ET_YUT(user)] [target] воздушный поцелуй.")

	else if(get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		user.custom_emote(message = "целу[PLUR_ET_YUT(user)] [target].")

/datum/interaction/mouth/tongue
	action =  "Показать язык"
	danger = TRUE

/datum/interaction/mouth/tongue/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = span_danger("показыва[PLUR_ET_YUT(user)] [target] язык!"))

/datum/interaction/mouth/spit
	action = "Плюнуть"
	danger = TRUE
	intaraction_flags = INTERACTION_CHECH_MOUTH|INTERACTION_CHECH_ADJACENT

/datum/interaction/mouth/spit/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = span_danger("плю[PLUR_YOT_YUT(user)] в [target]!"))

	if(prob(20))
		target.AdjustEyeBlurry(3 SECONDS)

/datum/interaction/mouth/lick
	action = "Лизнуть в щеку"
	intaraction_flags = INTERACTION_CHECH_MOUTH|INTERACTION_CHECH_ADJACENT

/datum/interaction/mouth/lick/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()

	if(!.)
		return FALSE

	if(!get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE

/datum/interaction/mouth/lick/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(prob(90))
		user.custom_emote(message = "лизнул[GEND_A_O_I(user)] [target] в щеку.")
	else
		user.custom_emote(message = "особо тщательно лизнул[GEND_A_O_I(user)] [target].")

#undef INTERACTION_CATEGORY_DEFAULT
#undef INTERACTION_CATEGORY_HANDS
#undef INTERACTION_CATEGORY_MOUTH

#undef INTERACTION_CHECH_HANDS
#undef INTERACTION_CHECH_ADJACENT
#undef INTERACTION_CHECH_MOUTH
#undef INTERACTION_CHECH_INCAPITATED
#undef INTERACTION_CHECH_COVER_ZONE
#undef INTERACTION_CHECH_TARGET_HANDS
