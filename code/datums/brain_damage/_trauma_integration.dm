/**
 * Brain-trauma subsystem integration for master220 (ported from tg/selfharm for the heretic).
 *
 * master220 has no brain-trauma system, so this file adds:
 *  - a `traumas` list + the trauma-management procs on /obj/item/organ/internal/brain
 *  - the /mob/living/carbon convenience wrappers
 *  - minimal definitions of the standard severe traumas the heretic references that aren't
 *    present in the source (mute / paralysis / monophobia / eldritch_beauty)
 *
 * The base /datum/brain_trauma + /datum/brain_trauma/severe/flesh_desire live in
 * brain_trauma.dm / severe.dm. Trauma on_life() is driven off COMSIG_LIVING_LIFE (see base on_gain).
 */

// --- Brain organ: trauma storage + management ---
// (the `traumas` list var itself is declared on the brain in brain_item.dm)

/obj/item/organ/internal/brain/Destroy()
	QDEL_LIST(traumas)
	return ..()

/obj/item/organ/internal/brain/proc/has_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
	for(var/datum/brain_trauma/braintrauma as anything in traumas)
		if(!istype(braintrauma, brain_trauma_type) || braintrauma.resilience > resilience)
			continue
		return braintrauma

/obj/item/organ/internal/brain/proc/get_traumas_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
	. = list()
	for(var/datum/brain_trauma/braintrauma as anything in traumas)
		if(istype(braintrauma, brain_trauma_type) && (braintrauma.resilience <= resilience))
			. += braintrauma

/obj/item/organ/internal/brain/proc/can_gain_trauma(datum/brain_trauma/trauma, resilience, natural_gain = FALSE)
	if(!ispath(trauma))
		trauma = trauma.type
	if(!initial(trauma.can_gain))
		return FALSE
	if(!resilience)
		resilience = initial(trauma.resilience)

	var/resilience_tier_count = 0
	for(var/datum/brain_trauma/existing as anything in traumas)
		if(istype(existing, trauma))
			return FALSE
		if(resilience == existing.resilience)
			resilience_tier_count++

	var/max_traumas
	switch(resilience)
		if(TRAUMA_RESILIENCE_BASIC)
			max_traumas = TRAUMA_LIMIT_BASIC
		if(TRAUMA_RESILIENCE_SURGERY)
			max_traumas = TRAUMA_LIMIT_SURGERY
		if(TRAUMA_RESILIENCE_WOUND)
			max_traumas = TRAUMA_LIMIT_WOUND
		if(TRAUMA_RESILIENCE_LOBOTOMY)
			max_traumas = TRAUMA_LIMIT_LOBOTOMY
		if(TRAUMA_RESILIENCE_MAGIC)
			max_traumas = TRAUMA_LIMIT_MAGIC
		if(TRAUMA_RESILIENCE_ABSOLUTE)
			max_traumas = TRAUMA_LIMIT_ABSOLUTE

	if(natural_gain && resilience_tier_count >= max_traumas)
		return FALSE
	return TRUE

/// Adds a trauma to this brain, with extra args forwarded to the trauma's New().
/obj/item/organ/internal/brain/proc/gain_trauma(datum/brain_trauma/trauma, resilience, ...)
	var/list/arguments = list()
	if(args.len > 2)
		arguments = args.Copy(3)
	. = brain_gain_trauma(trauma, resilience, arguments)

/// Direct trauma-gaining proc. Assigns a trauma to this brain. Avoid using directly.
/obj/item/organ/internal/brain/proc/brain_gain_trauma(datum/brain_trauma/trauma, resilience, list/arguments)
	if(!can_gain_trauma(trauma, resilience))
		return null

	var/datum/brain_trauma/actual_trauma
	if(ispath(trauma))
		if(!LAZYLEN(arguments))
			actual_trauma = new trauma()
		else
			actual_trauma = new trauma(arglist(arguments))
	else
		actual_trauma = trauma

	if(actual_trauma.brain) // we don't accept used traumas here
		WARNING("brain_gain_trauma was given an already active trauma.")
		return null

	add_trauma_to_traumas(actual_trauma)
	if(owner)
		actual_trauma.owner = owner
		if(SEND_SIGNAL(owner, COMSIG_CARBON_GAIN_TRAUMA, trauma, resilience) & COMSIG_CARBON_BLOCK_TRAUMA)
			qdel(actual_trauma)
			return null
		if(!actual_trauma.on_gain())
			qdel(actual_trauma)
			return null

	if(resilience)
		actual_trauma.resilience = resilience

	SSblackbox.record_feedback("tally", "traumas", 1, actual_trauma.type)
	return actual_trauma

/// Adds the passed trauma instance to our list and links it to our brain. Does NOT set it up.
/obj/item/organ/internal/brain/proc/add_trauma_to_traumas(datum/brain_trauma/trauma)
	trauma.brain = src
	traumas += trauma

/// Removes the passed trauma instance from our list. Does NOT remove its effects (Destroy does).
/obj/item/organ/internal/brain/proc/remove_trauma_from_traumas(datum/brain_trauma/trauma)
	trauma.brain = null
	traumas -= trauma

/// Add a random trauma of a certain subtype.
/obj/item/organ/internal/brain/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience, natural_gain = FALSE)
	var/list/datum/brain_trauma/possible_traumas = list()
	for(var/datum/brain_trauma/brain_trauma as anything in subtypesof(brain_trauma_type))
		if(!can_gain_trauma(brain_trauma, resilience, natural_gain) || !initial(brain_trauma.random_gain))
			continue
		possible_traumas += brain_trauma

	if(!LAZYLEN(possible_traumas))
		return
	var/trauma_type = pick(possible_traumas)
	return gain_trauma(trauma_type, resilience)

/// Cure a random trauma of a certain resilience level.
/obj/item/organ/internal/brain/proc/cure_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_BASIC)
	var/list/curable = get_traumas_type(brain_trauma_type, resilience)
	if(LAZYLEN(curable))
		qdel(pick(curable))

/obj/item/organ/internal/brain/proc/cure_all_traumas(resilience = TRAUMA_RESILIENCE_BASIC)
	var/amount_cured = 0
	var/list/curable = get_traumas_type(resilience = resilience)
	for(var/datum/brain_trauma/trauma as anything in curable)
		qdel(trauma)
		amount_cured++
	return amount_cured

// --- /mob/living/carbon convenience wrappers ---
/mob/living/carbon/proc/has_trauma_type(brain_trauma_type, resilience)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(brain)
		. = brain.has_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/gain_trauma(datum/brain_trauma/trauma, resilience, ...)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(!brain)
		return
	var/list/arguments = list()
	if(args.len > 2)
		arguments = args.Copy(3)
	. = brain.brain_gain_trauma(trauma, resilience, arguments)

/mob/living/carbon/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(!brain)
		return
	. = brain.gain_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/cure_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(!brain)
		return
	. = brain.cure_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/cure_all_traumas(resilience)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(!brain)
		return
	. = brain.cure_all_traumas(resilience)

// --- Minimal definitions of standard severe traumas referenced by heretic content ---
// (These aren't present in the tg/selfharm source we ported from; kept intentionally simple.
//  Faithful behaviour can be expanded during the runtime-polish pass.)

/// Renders the victim unable to speak intelligibly.
/datum/brain_trauma/severe/mute
	name = "Немота"
	desc = "Пациент не способен говорить."
	scan_desc = "повреждение речевого центра"
	gain_text = span_warning_alt("Вы не можете произнести ни слова.")
	lose_text = span_notice_alt("Вы снова можете говорить.")
	resilience = TRAUMA_RESILIENCE_LOBOTOMY

/datum/brain_trauma/severe/mute/handle_speech(datum/source, list/speech_args)
	speech_args[1] = "" // blanks the spoken message

/// The victim periodically loses control of a limb (light, flavorful version).
/datum/brain_trauma/severe/paralysis
	name = "Паралич"
	desc = "Пациент периодически теряет контроль над конечностями."
	scan_desc = "повреждение моторной коры"
	gain_text = span_warning_alt("Вы теряете чувствительность в конечностях...")
	lose_text = span_notice_alt("Контроль над телом возвращается.")
	resilience = TRAUMA_RESILIENCE_LOBOTOMY

/datum/brain_trauma/severe/paralysis/on_life(seconds_per_tick, times_fired)
	if(prob(5))
		to_chat(owner, span_warning_alt("Ваши конечности на мгновение немеют!"))
		owner.AdjustImmobilized(2 SECONDS)

/// The victim is terrified of being alone.
/datum/brain_trauma/severe/monophobia
	name = "Монофобия"
	desc = "Пациент испытывает сильный страх, оставаясь в одиночестве."
	scan_desc = "острое тревожное расстройство"
	gain_text = span_warning_alt("Вы чувствуете нарастающий ужас от мысли остаться в одиночестве.")
	lose_text = span_notice_alt("Страх одиночества отступает.")

/datum/brain_trauma/severe/monophobia/on_life(seconds_per_tick, times_fired)
	if(!prob(10))
		return
	// Are there other people nearby?
	for(var/mob/living/carbon/human/other in oview(7, owner))
		if(other.stat != DEAD)
			return
	to_chat(owner, span_warning_alt(pick("Вы совсем одни...", "Где все?!", "Вас охватывает паника от одиночества.")))
	owner.Jitter(5 SECONDS)
	owner.do_jitter_animation()

/// Heretic-flavour trauma: the victim is haunted by eldritch beauty.
/datum/brain_trauma/severe/eldritch_beauty
	name = "Жуткая красота"
	desc = "Пациент одержим видениями неописуемой потусторонней красоты."
	scan_desc = "тяжёлое диссоциативное расстройство"
	gain_text = span_warning_alt("Перед вашими глазами расцветает невыразимая, ужасающая красота...")
	lose_text = span_notice_alt("Видения меркнут.")
	resilience = TRAUMA_RESILIENCE_MAGIC

/datum/brain_trauma/severe/eldritch_beauty/on_life(seconds_per_tick, times_fired)
	if(prob(8))
		to_chat(owner, span_warning_alt(pick("Узоры на стенах складываются в нечто прекрасное и неправильное.", "Вы не можете отвести взгляд от пустоты.", "Красота Обители зовёт вас.")))
