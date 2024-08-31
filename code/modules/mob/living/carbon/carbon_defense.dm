/mob/living/carbon/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(skipcatch || !isitem(AM))
		return ..()

	var/obj/item/check = AM
	if(check.carbon_skip_catch_check(src))
		return ..()

	put_in_active_hand(AM)
	visible_message(span_warning("[src] catches [AM]!"))
	throw_mode_off()
	SEND_SIGNAL(src, COMSIG_CARBON_THROWN_ITEM_CAUGHT, AM)
	return TRUE


/**
 * Individual check for items to skip catching.
 */
/obj/item/proc/carbon_skip_catch_check(mob/living/carbon/user)
	. = TRUE
	if(!isturf(loc))
		return .
	if(!user.in_throw_mode)
		return .
	if(!(user.mobility_flags & MOBILITY_MOVE))
		return .
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return .
	if(user.get_active_hand())
		return .
	if(GetComponent(/datum/component/two_handed) && user.get_inactive_hand())
		return .
	. = FALSE


/mob/living/carbon/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	if(volume > 10) // Anything over 10 volume will make the mob wetter.
		wetlevel = min(wetlevel + 1,5)


/mob/living/carbon/attackby(obj/item/I, mob/user, params)
	if(!length(surgeries) || user.a_intent != INTENT_HELP)
		return ..()

	for(var/datum/surgery/surgery as anything in surgeries)
		if(surgery.next_step(user, src))
			return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/mob/living/carbon/attack_hand(mob/living/carbon/human/user)
	if(!iscarbon(user))
		return

	for(var/datum/disease/virus/V in diseases)
		if(V.spread_flags & CONTACT)
			V.Contract(user, act_type = CONTACT, need_protection_check = TRUE, zone = user.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)

	for(var/datum/disease/virus/V in user.diseases)
		if(V.spread_flags & CONTACT)
			V.Contract(src, act_type = CONTACT, need_protection_check = TRUE, zone = user.zone_selected)

	if(body_position == LYING_DOWN && surgeries.len)
		if(user.a_intent == INTENT_HELP)
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user, src))
					return TRUE
	return FALSE

/mob/living/carbon/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		if(M.powerlevel > 0)
			var/stunprob = M.powerlevel * 7 + 10  // 17 at level 1, 80 at level 10
			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				visible_message("<span class='danger'>The [M.name] has shocked [src]!</span>", "<span class='userdanger'>The [M.name] has shocked you!</span>")

				do_sparks(5, TRUE, src)
				var/power = (M.powerlevel + rand(0,3)) STATUS_EFFECT_CONSTANT
				Stun(power)
				Stuttering(power)
				if(prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6, 6 + M.age_state.damage))
		return 1

/mob/living/carbon/is_mouth_covered(head_only = FALSE, mask_only = FALSE)
	if((!mask_only && head && (head.flags_cover & HEADCOVERSMOUTH)) || (!head_only && wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH)))
		return TRUE

//Called when drawing cult runes/using cult spells. Deal damage to a random arm/hand, or chest if not there.
/mob/living/carbon/cult_self_harm(damage)
	var/dam_zone = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
	var/obj/item/organ/external/affecting = get_organ(dam_zone)
	if(!affecting)
		affecting = get_organ(BODY_ZONE_CHEST)
	if(!affecting) //bruh where's your chest
		return FALSE
	apply_damage(damage, BRUTE, affecting)
