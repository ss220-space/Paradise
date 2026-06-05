/// Interaction without category
/datum/interaction
	var/category = ""
	var/action
	var/label
	var/danger = FALSE

/// It is used to check for the possibility to use this interaction. Redefined for different types of interactions
/datum/interaction/proc/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return TRUE

// Used to execute the interaction
/datum/interaction/proc/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return


/datum/interaction/bow
	action = "bow"
	label = "Отвесить поклон"

/datum/interaction/bow/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "кланя[PLUR_ET_YUT(user)]ся [target].")


/datum/interaction/bow_affably
	action = "bow_affably"
	label = "Приветливо кивнуть"

/datum/interaction/bow_affably/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "приветливо кивнул[GEND_A_O_I(user)] в сторону [target].")


/// Interaction with the Hands category requires ONLY the user to have hands
/datum/interaction/hands
	category = "hands"

/datum/interaction/hands/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE

	var/obj/item/organ/external/temp = user.bodyparts_by_name[BODY_ZONE_PRECISE_R_HAND]
	. = (temp?.is_usable())
	if(!.)
		temp = user.bodyparts_by_name[BODY_ZONE_PRECISE_L_HAND]
		. = (temp?.is_usable())


/datum/interaction/hands/wave
	action = "wave"
	label = "Приветливо помахать"

/datum/interaction/hands/wave/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "приветливо маш[PLUR_ET_UT(user)] в сторону [target].")


/datum/interaction/hands/fuckyou
	action = "fuckyou"
	label = "Показать средний палец"
	danger = TRUE

/datum/interaction/hands/fuckyou/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = span_danger("показыва[PLUR_ET_YUT(user)] [target] средний палец!"))


/datum/interaction/hands/threaten
	action = "threaten"
	label = "Погрозить кулаком"

/datum/interaction/hands/threaten/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = span_danger("гроз[PLUR_IT_YAT(user)] [target] кулаком!"))

/// An interaction that requires to be adjacent
/datum/interaction/hands/adjacent

/datum/interaction/hands/adjacent/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(.)
		. = user.Adjacent(target)


/datum/interaction/hands/adjacent/handshake
	action = "handshake"
	label = "Пожать руку"

/datum/interaction/hands/adjacent/handshake/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "жм[PLUR_YOT_UT(user)] руку [target].")


/datum/interaction/hands/adjacent/hug
	action = "hug"
	label = "Обнимашки!"

/datum/interaction/hands/adjacent/hug/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "обнима[PLUR_ET_YUT(user)] [target].")
	playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)


/datum/interaction/hands/adjacent/cheer
	action = "cheer"
	label = "Похлопать по плечу"

/datum/interaction/hands/adjacent/cheer/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "похлопыва[PLUR_ET_YUT(user)] [target] по плечу.")


/datum/interaction/hands/adjacent/slap
	action = "slap"
	label = "Дать пощечину!"
	danger = TRUE

/datum/interaction/hands/adjacent/slap/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
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


/datum/interaction/hands/adjacent/knock
	action = "knock"
	label = "Дать подзатыльник"
	danger = TRUE

/datum/interaction/hands/adjacent/knock/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/organ/external/head/head = target.get_organ(BODY_ZONE_HEAD)
	if(!head)
		return

	if(head.brute_dam < 5)
		target.apply_damage(1, def_zone = head)

	user.custom_emote(message = span_danger("да[PLUR_ET_YUT(user)] [target] подзатыльник!"))
	playsound(user.loc, 'sound/weapons/throwtap.ogg', 50, TRUE, -1)
	user.do_attack_animation(target)


/datum/interaction/hands/adjacent/pullwing
	action = "pullwing"
	label = "Дёрнуть за крылья!"

/datum/interaction/hands/adjacent/pullwing/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(.)
		return target.dna.species.name == SPECIES_MOTH

/datum/interaction/hands/adjacent/pullwing/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
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


/datum/interaction/hands/adjacent/pull
	action = "pull"
	label = "Дёрнуть за хвост!"
	danger = TRUE

/datum/interaction/hands/adjacent/pull/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(.)
		return (target.dna.species.name == SPECIES_TAJARAN)  || (target.dna.species.name == SPECIES_VOX)|| (target.dna.species.name == SPECIES_VULPKANIN) || (target.dna.species.name == SPECIES_UNATHI)

/datum/interaction/hands/adjacent/pull/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
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


/datum/interaction/hands/adjacent/pet
	action = "pet"
	label = "Погладить"

/datum/interaction/hands/adjacent/pet/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(.)
		. = (target.dna.species.name == SPECIES_TAJARAN)  || (target.dna.species.name == SPECIES_VOX)|| (target.dna.species.name == SPECIES_VULPKANIN) || (target.dna.species.name == SPECIES_UNATHI)
		. &= target.can_inject(user)

/datum/interaction/hands/adjacent/pet/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "[pick("глад[PLUR_IT_YAT(user)]", "поглажива[PLUR_ET_YUT(user)]")] [target].")


/datum/interaction/hands/adjacent/scratch
	action = "scratch"
	label = "Почесать"

/datum/interaction/hands/adjacent/scratch/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(.)
		. = (target.dna.species.name == SPECIES_TAJARAN)  || (target.dna.species.name == SPECIES_VOX)|| (target.dna.species.name == SPECIES_VULPKANIN) || (target.dna.species.name == SPECIES_UNATHI)
		. &= target.can_inject(user)

/datum/interaction/hands/adjacent/scratch/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.zone_selected != BODY_ZONE_HEAD || ismachineperson(target) || isunathi(target) || isgrey(target))
		user.custom_emote(message = "[pick("чеш[PLUR_ET_UT(user)]")] [target].")
	else
		user.custom_emote(message = "[pick("чеш[PLUR_ET_UT(user)] за ухом", "чеш[PLUR_ET_UT(user)] голову")] [target].")


/// Interaction with the Hands category requires the user and the target to have hands
/datum/interaction/hands/adjacent/mutual

/datum/interaction/hands/adjacent/mutual/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(.)
		var/obj/item/organ/external/temp = target.bodyparts_by_name[BODY_ZONE_PRECISE_R_HAND]
		. = (temp?.is_usable())
		if(!.)
			temp = target.bodyparts_by_name[BODY_ZONE_PRECISE_L_HAND]
			. = (temp?.is_usable())


/datum/interaction/hands/adjacent/mutual/five
	action = "five"
	label = "Дать пять"

/datum/interaction/hands/adjacent/mutual/five/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = "да[PLUR_YOT_YUT(user)] [target] пять.")
	playsound(user.loc, 'sound/effects/snap.ogg', 25, TRUE, -1)


/datum/interaction/hands/adjacent/mutual/give
	action = "give"
	label = "Передать предмет"

/datum/interaction/hands/adjacent/mutual/give/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.give(target)

/// Interaction with the Mouth category
/datum/interaction/mouth
	category = "mouth"

/datum/interaction/mouth/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = !((user.head && (user.head.flags_cover & HEADCOVERSMOUTH)) || (user.wear_mask && (user.wear_mask.flags_cover & MASKCOVERSMOUTH)))
	. &= user.dna.species.name != SPECIES_DIONA


/datum/interaction/mouth/kiss
	action = "kiss"
	label = "Поцеловать"

/datum/interaction/mouth/kiss/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!get_location_accessible(user, BODY_ZONE_PRECISE_MOUTH))
		return

	if(!target.Adjacent(user.loc))
		user.custom_emote(message = "посыла[PLUR_ET_YUT(user)] [target] воздушный поцелуй.")

	else if(get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		user.custom_emote(message = "целу[PLUR_ET_YUT(user)] [target].")


/datum/interaction/mouth/tongue
	action = "tongue"
	label = "Показать язык"
	danger = TRUE

/datum/interaction/mouth/tongue/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.custom_emote(message = span_danger("показыва[PLUR_ET_YUT(user)] [target] язык!"))

/// Interaction with the Mouth category that requires to be adjacent
/datum/interaction/mouth/adjacent

/datum/interaction/mouth/adjacent/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(.)
		. = user.Adjacent(target)


/datum/interaction/mouth/adjacent/spit
	action = "spit"
	label = "Плюнуть"
	danger = TRUE

/datum/interaction/mouth/adjacent/spit/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!target.Adjacent(user.loc) || !get_location_accessible(user, BODY_ZONE_PRECISE_MOUTH))
		return

	user.custom_emote(message = span_danger("плю[PLUR_YOT_YUT(user)] в [target]!"))

	if(prob(20))
		target.AdjustEyeBlurry(3 SECONDS)


/// Interaction with the Mouth category requires having an accessible mouth for the user and the target
/datum/interaction/mouth/adjacent/mutual

/datum/interaction/mouth/adjacent/mutual/is_available(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(.)
		. = !((target.head && (target.head.flags_cover & HEADCOVERSMOUTH)) || (target.wear_mask && (target.wear_mask.flags_cover & MASKCOVERSMOUTH)))

/datum/interaction/mouth/adjacent/mutual/lick
	action = "lick"
	label = "Лизнуть в щеку"

/datum/interaction/mouth/adjacent/mutual/lick/execute(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!target.Adjacent(user.loc) || !get_location_accessible(user, BODY_ZONE_PRECISE_MOUTH) || !get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		return

	if(prob(90))
		user.custom_emote(message = "лизнул[GEND_A_O_I(user)] [target] в щеку.")

	else
		user.custom_emote(message = "особо тщательно лизнул[GEND_A_O_I(user)] [target].")

GLOBAL_LIST_INIT(interaction_entries, list(
	new /datum/interaction/bow,
	new /datum/interaction/bow_affably,
	new /datum/interaction/hands/wave,
	new /datum/interaction/hands/fuckyou,
	new /datum/interaction/hands/threaten,
	new /datum/interaction/hands/adjacent/handshake,
	new /datum/interaction/hands/adjacent/hug,
	new /datum/interaction/hands/adjacent/cheer,
	new /datum/interaction/hands/adjacent/slap,
	new /datum/interaction/hands/adjacent/knock,
	new /datum/interaction/hands/adjacent/pullwing,
	new /datum/interaction/hands/adjacent/pull,
	new /datum/interaction/hands/adjacent/pet,
	new /datum/interaction/hands/adjacent/scratch,
	new /datum/interaction/hands/adjacent/mutual/five,
	new /datum/interaction/hands/adjacent/mutual/give,
	new /datum/interaction/mouth/kiss,
	new /datum/interaction/mouth/tongue,
	new /datum/interaction/mouth/adjacent/spit,
	new /datum/interaction/mouth/adjacent/mutual/lick
))
