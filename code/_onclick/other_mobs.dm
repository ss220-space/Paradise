/*
	Humans:
	Adds an exception for pull/grab handling and gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/UnarmedAttack(atom/A, proximity_flag)
	if(!can_unarmed_attack())
		return

	if(proximity_flag && pulling && (!isnull(pull_hand) && (pull_hand == PULL_WITHOUT_HANDS || pull_hand == hand)))
		if(A.grab_attack(src, pulling))
			changeNext_move(grab_state > GRAB_PASSIVE ? CLICK_CD_GRABBING : CLICK_CD_PULLING)
			return

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines
	if(proximity_flag && istype(G) && G.Touch(A, proximity_flag))
		return


	if(buckled && isstructure(buckled))
		var/obj/structure/S = buckled
		if(S.prevents_buckled_mobs_attacking())
			return

	A.attack_hand(src)


/mob/living/carbon/human/beforeAdjacentClick(atom/A, params)
	if(prob(get_bones_symptom_prob() * 3))
		var/obj/item/organ/external/active_hand = get_organ(hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
		if(!active_hand.has_fracture())
			var/used_item_name = get_active_hand()
			to_chat(src, span_danger("[used_item_name ? "You try to use [used_item_name], but y": "Y"]our [active_hand] don't withstand the load!"))
			active_hand.fracture()


/atom/proc/attack_hand(mob/user)
	. = FALSE
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

/*
/mob/living/carbon/human/RestrainedClickOn(var/atom/A) -- Handled by carbons
	return
*/

/mob/living/carbon/RestrainedClickOn(var/atom/A)
	return 0

/mob/living/carbon/human/RangedAttack(atom/A, params)
	. = ..()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		if(istype(G) && G.Touch(A, 0)) // for magic gloves
			return

	if(!GLOB.pacifism_after_gt && !HAS_TRAIT(src, TRAIT_PACIFISM))
		if(HAS_TRAIT(src, TRAIT_LASEREYES) && a_intent == INTENT_HARM)
			LaserEyes(A)

		if(HAS_TRAIT(src, TRAIT_TELEKINESIS))
			A.attack_tk(src)

	if(isturf(A) && get_dist(src, A) <= 1)
		Move_Pulled(A)


/**
 * Checks if this mob is in a valid state to punch someone.
 *
 * (Potentially) gives feedback to the mob if they cannot.
 */
/mob/living/proc/can_unarmed_attack()
	return !HAS_TRAIT(src, TRAIT_HANDS_BLOCKED)


/mob/living/carbon/human/can_unarmed_attack()
	. = ..()
	if(!.)
		return .

	if(!get_active_hand()) // we can pull if no hands are required, but otherwise attack without a hand is impossible.
		if(a_intent == INTENT_GRAB && pull_hand == PULL_WITHOUT_HANDS)
			return .
		var/obj/item/organ/external/limb = get_organ(hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
		if(!limb)
			to_chat(src, span_warning("Вы смотрите на то, что осталось от Вашей [hand ? "левой руки" : "правой руки"] и тяжко вздыхаете..."))
			return FALSE
		if(!limb.is_usable())
			to_chat(src, span_warning("Ваша [hand ? "левая рука" : "правая рука"] слишком травмирована."))
			return FALSE


/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(atom/A, proximity_flag)
	if(!can_unarmed_attack())
		return
	if(proximity_flag && pulling && !isnull(pull_hand) && pull_hand != PULL_WITHOUT_HANDS && pull_hand == hand)
		if(A.grab_attack(src, pulling))
			changeNext_move(grab_state > GRAB_PASSIVE ? CLICK_CD_GRABBING : CLICK_CD_PULLING)
			return
	A.attack_animal(src)

/mob/living/simple_animal/hostile/UnarmedAttack(atom/A, proximity_flag)
	if(!can_unarmed_attack())
		return
	if(proximity_flag && pulling && !isnull(pull_hand) && pull_hand != PULL_WITHOUT_HANDS && pull_hand == hand)
		if(A.grab_attack(src, pulling))
			changeNext_move(grab_state > GRAB_PASSIVE ? CLICK_CD_GRABBING : CLICK_CD_PULLING)
			return
	GiveTarget(A)
	if(target)
		AttackingTarget()

/atom/proc/attack_animal(mob/user)
	return

/mob/living/RestrainedClickOn(atom/A)
	return

/*
	Aliens
	Defaults to same as monkey in most places
*/
/mob/living/carbon/alien/UnarmedAttack(atom/A, proximity_flag)
	if(!can_unarmed_attack())
		return
	if(proximity_flag && pulling && (!isnull(pull_hand) && (pull_hand == PULL_WITHOUT_HANDS || pull_hand == hand)))
		if(A.grab_attack(src, pulling))
			changeNext_move(grab_state > GRAB_PASSIVE ? CLICK_CD_GRABBING : CLICK_CD_PULLING)
			return
	A.attack_alien(src)

/atom/proc/attack_alien(mob/living/carbon/alien/user)
	attack_hand(user)

/mob/living/carbon/alien/RestrainedClickOn(atom/A)
	return

// Babby aliens
/mob/living/carbon/alien/larva/UnarmedAttack(atom/A, proximity_flag)
	if(!can_unarmed_attack())
		return
	A.attack_larva(src)

/atom/proc/attack_larva(mob/user)
	return

/*
	Slimes
	Nothing happening here
*/
/mob/living/simple_animal/slime/UnarmedAttack(atom/A, proximity_flag)
	if(!can_unarmed_attack())
		return
	A.attack_slime(src)

/atom/proc/attack_slime(mob/user)
	return

/mob/living/simple_animal/slime/RestrainedClickOn(atom/A)
	return

/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/new_player/ClickOn()
	return


// pAIs are not intended to interact with anything in the world
/mob/living/silicon/pai/UnarmedAttack(atom/A, proximity_flag)
	return

