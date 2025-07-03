#define MIN_SHOCK_REDUCTION 50 //The minimum amount of shock reduction in reagents for absence of pain

/mob/living/carbon
	var/last_pain_message = ""
	COOLDOWN_DECLARE(pain_cd)


/**
 * Whether or not a mob can feel pain.
 *
 * Returns TRUE if the mob can feel pain, FALSE otherwise
 */
/mob/proc/has_pain()
	if(stat)
		return FALSE

	return TRUE


/mob/living/carbon/has_pain()
	. = ..()
	if(!.)
		return FALSE

	if(HAS_TRAIT(src, TRAIT_NO_PAIN))
		return FALSE

	if(shock_reduction() >= MIN_SHOCK_REDUCTION)
		return FALSE

	return TRUE

// partname is the name of a body part
// amount is a num from 1 to 100
/mob/living/carbon/proc/pain(partname, amount)
	if(reagents.has_reagent("sal_acid"))
		return

	if(!has_pain())
		return

	if(!COOLDOWN_FINISHED(src, pain_cd))
		return

	var/msg
	switch(amount)
		if(1 to 10)
			msg = span_userdanger("<b>Вы чувствуете боль в [partname].</b>")

		if(11 to 90)
			msg = span_userdanger(span_bold(span_fontsize2("<b>Вы чувствуете сильную боль в [partname]!")))

		if(91 to INFINITY)
			msg = span_userdanger(span_bold(span_fontsize3("Ох чёрт! Вы чувствуете невыносимую боль в [partname]!")))

	if(msg && (msg != last_pain_message || prob(10)))
		last_pain_message = msg
		if(get_preference(PREFTOGGLE_3_PAIN_BLURB))
			pain_blurb(msg)
		else
			to_chat(src, msg)

	COOLDOWN_START(src, pain_cd, (get_preference(PREFTOGGLE_3_PAIN_BLURB) ? 30 SECONDS : 10 SECONDS) - amount)


// message is the custom message to be displayed
/mob/living/carbon/proc/custom_pain(message)
	if(!has_pain())
		return

	if(get_preference(PREFTOGGLE_3_PAIN_BLURB) && !COOLDOWN_FINISHED(src, pain_cd))
		return

	// Anti message spam checks
	if(!message || message == last_pain_message && !COOLDOWN_FINISHED(src, pain_cd))
		COOLDOWN_START(src, pain_cd, (get_preference(PREFTOGGLE_3_PAIN_BLURB) ? 30 SECONDS : 10 SECONDS))
		return

	last_pain_message = message
	if(get_preference(PREFTOGGLE_3_PAIN_BLURB))
		pain_blurb(message)
	else
		to_chat(src, span_userdanger("[message]"))

	COOLDOWN_START(src, pain_cd, (get_preference(PREFTOGGLE_3_PAIN_BLURB) ? 30 SECONDS : 10 SECONDS))

/mob/living/carbon/human/proc/handle_pain()
	// not when sleeping

	if(!has_pain())
		return

	var/maxdam = 0
	var/obj/item/organ/external/damaged_organ = null
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if((bodypart.status & ORGAN_DEAD|ORGAN_ROBOT) || bodypart.hidden_pain)
			continue

		var/dam = bodypart.get_damage()
		// make the choice of the organ depend on damage,
		// but also sometimes use one of the less damaged ones
		if(dam > maxdam && (maxdam == 0 || prob(70)))
			damaged_organ = bodypart
			maxdam = dam

		if(!damaged_organ)
			continue

		pain(damaged_organ.declent_ru(PREPOSITIONAL), maxdam)

	// Damage to internal organs hurts a lot.
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		if(organ.hidden_pain)
			continue

		if(organ.damage < 2 || !prob(2))
			continue

		var/obj/item/organ/external/parent = get_organ(organ.parent_organ_zone)
		custom_pain("Вы чувствуете острую боль в [parent.declent_ru(PREPOSITIONAL)].")

#undef MIN_SHOCK_REDUCTION
