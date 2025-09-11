/obj/item/organ/internal/brain
	name = "brain"
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Этот принадлежал человеку."
	icon_state = "brain2"
	max_damage = 120
	force = 1.0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=5"
	attack_verb = list("атаковал", "шлёпнул", "огрел")
	var/mob/living/carbon/brain/brainmob = null
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_BRAIN
	vital = TRUE
	hidden_pain = TRUE //the brain has no pain receptors, and brain damage is meant to be a stealthy damage type.
	var/mmi_icon = 'icons/obj/assemblies.dmi'
	var/mmi_icon_state = "mmi_full"
	/// If it's a fake brain without a mob assigned that should still be treated like a real brain.
	var/decoy_brain = FALSE
	/// TRUE giving to a user sci hud and active research scanner
	var/smart_mind = FALSE
	var/list/datum/brain_trauma/traumas = list()

/obj/item/organ/internal/brain/get_ru_names()
	return list(
		NOMINATIVE = "мозг человека",
		GENITIVE = "мозга человека",
		DATIVE = "мозгу человека",
		ACCUSATIVE = "мозг человека",
		INSTRUMENTAL = "мозгом человека",
		PREPOSITIONAL = "мозге человека"
	)

/obj/item/organ/internal/brain/Destroy()
	QDEL_NULL(brainmob)
	return ..()

/obj/item/organ/internal/brain/proc/transfer_identity(mob/living/carbon/H)
	brainmob = new(src)
	if(isnull(dna)) // someone didn't set this right...
		log_runtime(EXCEPTION("[src] at [loc] did not contain a dna datum at time of removal."), src)
		dna = H.dna.Clone()
	name = "\the [dna.real_name]'s [initial(src.name)]"
	if(ru_names)
		for(var/i in NOMINATIVE to PREPOSITIONAL)
			ru_names[i] = initial(ru_names[i]) + " [dna.real_name]"
	brainmob.dna = dna.Clone() // Silly baycode, what you do
//	brainmob.dna = H.dna.Clone() Putting in and taking out a brain doesn't make it a carbon copy of the original brain of the body you put it in
	brainmob.name = dna.real_name
	brainmob.real_name = dna.real_name
	brainmob.timeofhostdeath = H.timeofdeath
	if(H.mind)
		H.mind.transfer_to(brainmob)

	to_chat(brainmob, span_notice("Вы чувствуете себя немного дезориентированным. Это нормально, когда вы просто мозг."))

/obj/item/organ/internal/brain/examine(mob/user) // -- TLE
	. = ..()
	if(brainmob && brainmob.client)//if there be a brain inside... the brain.
		. += "В нём ощущается мощная нейронная активность."
		return
	if(brainmob?.mind)
		var/foundghost = FALSE
		for(var/mob/dead/observer/G in GLOB.player_list)
			if(G.mind == brainmob.mind)
				foundghost = G.can_reenter_corpse
				break
		if(foundghost)
			. += "В нём ощущается слабая нейронная активность."
			return

	. += "Выглядит абсолютно безжизненным и неактивным."

/obj/item/organ/internal/brain/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT)
	if(dna)
		name = "[dna.real_name]'s [initial(name)]"
		if(ru_names)
			for(var/i in NOMINATIVE to PREPOSITIONAL)
				ru_names[i] = initial(ru_names[i]) + " [dna.real_name]"

	if(!owner)
		return ..() // Probably a redundant removal; just bail

	var/obj/item/organ/internal/brain/our_brain = src
	if(!special)
		var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()
		if(borer)
			borer.leave_host() //Should remove borer if the brain is removed - RR

		if(owner.mind && !decoy_brain && !HAS_TRAIT(owner, TRAIT_DECOY_BRAIN))	//don't transfer if the owner does not have a mind.
			our_brain.transfer_identity(user)

	if(ishuman(owner))
		owner.update_hair()

	owner.thought_bubble_image = initial(owner.thought_bubble_image)
	. = ..()


/obj/item/organ/internal/brain/insert(mob/living/target, special = ORGAN_MANIPULATION_DEFAULT)

	name = "[initial(name)]"
	var/brain_already_exists = FALSE
	if(ishuman(target)) // No more IPC multibrain shenanigans
		if(target.get_int_organ(/obj/item/organ/internal/brain))
			brain_already_exists = TRUE

		var/mob/living/carbon/human/H = target
		H.update_hair()

	var/target_changeling = ischangeling(target)
	if(target_changeling)
		decoy_brain = TRUE

	if(!brain_already_exists)
		if(brainmob && !target_changeling)
			if(target.key)
				target.ghostize()
			if(brainmob.mind)
				brainmob.mind.transfer_to(target)
			else
				target.key = brainmob.key
		else if(brainmob?.mind && target_changeling)
			brainmob.mind.current = null
			brainmob.ghostize()
	else
		log_debug("Multibrain shenanigans at ([target.x],[target.y],[target.z]), mob '[target]'")

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.special_post_clone_handling()

	..(target, special)


/obj/item/organ/internal/brain/internal_receive_damage(amount = 0, silent = FALSE) //brains are special; if they receive damage by other means, we really just want the damage to be passed ot the owner and back onto the brain.
	owner?.apply_damage(amount, BRAIN)


/obj/item/organ/internal/brain/necrotize(silent = FALSE) //Brain also has special handling for when it necrotizes
	if(..() && owner && vital)
		owner.setBrainLoss(120)


/obj/item/organ/internal/brain/prepare_eat()
	return // Too important to eat.


////////////////////////////////////TRAUMAS////////////////////////////////////////

/obj/item/organ/internal/brain/proc/has_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
	for(var/X in traumas)
		var/datum/brain_trauma/braintrauma = X
		if(!istype(braintrauma, brain_trauma_type) || braintrauma.resilience > resilience)
			continue

		return braintrauma

/obj/item/organ/internal/brain/proc/get_traumas_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
	. = list()
	for(var/X in traumas)
		var/datum/brain_trauma/braintrauma = X
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
	for(var/X in traumas)
		if(istype(X, trauma))
			return FALSE

		var/datum/brain_trauma/T = X
		if(resilience == T.resilience)
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

//Proc to use when directly adding a trauma to the brain, so extra args can be given
/obj/item/organ/internal/brain/proc/gain_trauma(datum/brain_trauma/trauma, resilience, ...)
	var/list/arguments = list()
	if(args.len > 2)
		arguments = args.Copy(3)
	. = brain_gain_trauma(trauma, resilience, arguments)

//Direct trauma gaining proc. Necessary to assign a trauma to its brain. Avoid using directly.
/obj/item/organ/internal/brain/proc/brain_gain_trauma(datum/brain_trauma/trauma, resilience, list/arguments)
	if(!can_gain_trauma(trauma, resilience))
		return null

	var/datum/brain_trauma/actual_trauma
	if(ispath(trauma))
		if(!LAZYLEN(arguments))
			actual_trauma = new trauma() //arglist with an empty list runtimes for some reason
		else
			actual_trauma = new trauma(arglist(arguments))
	else
		actual_trauma = trauma

	if(actual_trauma.brain) //we don't accept used traumas here
		WARNING("gain_trauma was given an already active trauma.")
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

/// Adds the passed trauma instance to our list of traumas and links it to our brain.
/// DOES NOT handle setting up the trauma, that's done by [proc/brain_gain_trauma]!
/obj/item/organ/internal/brain/proc/add_trauma_to_traumas(datum/brain_trauma/trauma)
	trauma.brain = src
	traumas += trauma

/// Removes the passed trauma instance to our list of traumas and links it to our brain
/// DOES NOT handle removing the trauma's effects, that's done by [/datum/brain_trauma/Destroy()]!
/obj/item/organ/internal/brain/proc/remove_trauma_from_traumas(datum/brain_trauma/trauma)
	trauma.brain = null
	traumas -= trauma

//Add a random trauma of a certain subtype
/obj/item/organ/internal/brain/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience, natural_gain = FALSE)
	var/list/datum/brain_trauma/possible_traumas = list()
	for(var/T in subtypesof(brain_trauma_type))
		var/datum/brain_trauma/brain_trauma = T
		if(!can_gain_trauma(brain_trauma, resilience, natural_gain) && initial(brain_trauma.random_gain))
			continue

		possible_traumas += brain_trauma

	if(!LAZYLEN(possible_traumas))
		return

	var/trauma_type = pick(possible_traumas)
	return gain_trauma(trauma_type, resilience)

//Cure a random trauma of a certain resilience level
/obj/item/organ/internal/brain/proc/cure_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_BASIC)
	var/list/traumas = get_traumas_type(brain_trauma_type, resilience)
	if(LAZYLEN(traumas))
		qdel(pick(traumas))

/obj/item/organ/internal/brain/proc/cure_all_traumas(resilience = TRAUMA_RESILIENCE_BASIC)
	var/amount_cured = 0
	var/list/traumas = get_traumas_type(resilience = resilience)
	for(var/X in traumas)
		qdel(X)
		amount_cured++

	return amount_cured


/obj/item/organ/internal/brain/golem
	name = "runic mind"
	desc = "Туго свёрнутый свиток, испещрённый неразборчивыми рунами."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"

/obj/item/organ/internal/brain/golem/get_ru_names()
	return list(
		NOMINATIVE = "рунический разум",
		GENITIVE = "рунического разума",
		DATIVE = "руническому разуму",
		ACCUSATIVE = "рунический разум",
		INSTRUMENTAL = "руническим разумом",
		PREPOSITIONAL = "руническом разуме"
	)

/obj/item/organ/internal/brain/Destroy() //copypasted from MMIs.
	QDEL_NULL(brainmob)
	return ..()

/obj/item/organ/internal/brain/cluwne

/obj/item/organ/internal/brain/cluwne/insert(mob/living/target, special = ORGAN_MANIPULATION_DEFAULT, make_cluwne = TRUE)
	..(target, special)
	if(ishuman(target) && make_cluwne)
		var/mob/living/carbon/human/H = target
		H.makeCluwne() //No matter where you go, no matter what you do, you cannot escape

