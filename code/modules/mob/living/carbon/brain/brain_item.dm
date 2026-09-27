/obj/item/organ/internal/brain
	name = "brain"
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Этот принадлежал человеку."
	icon_state = "brain2"
	max_damage = BRAIN_DAMAGE_DEATH
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=5"
	attack_verb = list("атаковал", "шлёпнул", "огрел")
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_BRAIN
	vital = TRUE
	hidden_pain = TRUE //the brain has no pain receptors, and brain damage is meant to be a stealthy damage type.
	var/mob/living/carbon/brain/brainmob = null
	var/mmi_icon = 'icons/obj/assemblies.dmi'
	var/mmi_icon_state = "mmi_full"
	/// If it's a fake brain without a mob assigned that should still be treated like a real brain.
	var/decoy_brain = FALSE
	/// TRUE giving to a user sci hud and active research scanner
	var/smart_mind = FALSE
	/// The original body for this brain, if this valriable is null - brain can apply any body without desease.
	var/datum/weakref/original_body = null
	var/list/datum/brain_trauma/traumas = list()

/obj/item/organ/internal/brain/get_ru_names()
	return alist(
		NOMINATIVE = "мозг человека",
		GENITIVE = "мозга человека",
		DATIVE = "мозгу человека",
		ACCUSATIVE = "мозг человека",
		INSTRUMENTAL = "мозгом человека",
		PREPOSITIONAL = "мозге человека",
	)

/obj/item/organ/internal/brain/Destroy()
	var/list/held_traumas = traumas.Copy()
	QDEL_LIST(held_traumas)
	QDEL_NULL(brainmob)
	original_body = null
	return ..()

/obj/item/organ/internal/brain/on_life()
	. = ..()
	for(var/datum/brain_trauma/trauma as anything in traumas)
		trauma.on_life()

/obj/item/organ/internal/brain/on_owner_death()
	. = ..()
	for(var/datum/brain_trauma/trauma as anything in traumas)
		trauma.on_death()

/obj/item/organ/internal/brain/proc/on_damage_changed(previous_damage)
	if(damage <= previous_damage)
		return

	if(owner)
		var/brain_message
		if(previous_damage < BRAIN_DAMAGE_MILD && damage >= BRAIN_DAMAGE_MILD)
			brain_message = span_warning("Вы чувствуете дурноту.")
		else if(previous_damage < BRAIN_DAMAGE_SEVERE && damage >= BRAIN_DAMAGE_SEVERE)
			brain_message = span_warning("Вы всё хуже контролируете свои мысли.")
		else if(previous_damage < BRAIN_DAMAGE_DEATH - 20 && damage >= BRAIN_DAMAGE_DEATH - 20)
			brain_message = span_warning("Вы чувствуете, как ваш разум то гаснет, то вспыхивает вновь...")
		if(brain_message)
			to_chat(owner, brain_message)

	if(damage > BRAIN_DAMAGE_MILD)
		roll_for_brain_trauma(damage - previous_damage)

/obj/item/organ/internal/brain/proc/roll_for_brain_trauma(damage_dealt)
	if(prob(damage_dealt * (1 + max(0, (damage - BRAIN_DAMAGE_MILD) / 100))))
		gain_trauma_type(BRAIN_TRAUMA_MILD, natural_gain = TRUE)

	if(damage < BRAIN_DAMAGE_SEVERE)
		return

	var/boosted = HAS_TRAIT(src, TRAIT_SPECIAL_TRAUMA_BOOST)
	if(!prob(damage_dealt * (1 + max(0, (damage - BRAIN_DAMAGE_SEVERE) / 100))))
		return

	if(prob(boosted ? 50 : 20))
		gain_trauma_type(BRAIN_TRAUMA_SPECIAL, boosted ? TRAUMA_RESILIENCE_SURGERY : null, natural_gain = TRUE)
	else
		gain_trauma_type(BRAIN_TRAUMA_SEVERE, natural_gain = TRUE)

/obj/item/organ/internal/brain/proc/get_trauma_scan_list()
	. = list()
	for(var/datum/brain_trauma/trauma as anything in traumas)
		var/severity
		switch(trauma.resilience)
			if(TRAUMA_RESILIENCE_BASIC)
				severity = "лёгкая"
			if(TRAUMA_RESILIENCE_SURGERY)
				severity = "тяжёлая"
			if(TRAUMA_RESILIENCE_LOBOTOMY)
				severity = "укоренившаяся"
			if(TRAUMA_RESILIENCE_MAGIC)
				severity = "стойкая"
			if(TRAUMA_RESILIENCE_ABSOLUTE)
				severity = "необратимая"
		. += "[severity] [trauma.scan_desc]"

/obj/item/organ/internal/brain/proc/get_trauma_scan_data()
	var/list/scanned_traumas = get_trauma_scan_list()
	if(!length(scanned_traumas))
		return
	return "Психические травмы: [russian_list(scanned_traumas)]."

/obj/item/organ/internal/brain/proc/has_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
	for(var/datum/brain_trauma/trauma as anything in traumas)
		if(istype(trauma, brain_trauma_type) && trauma.resilience <= resilience)
			return trauma

/obj/item/organ/internal/brain/proc/get_traumas_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
	. = list()
	for(var/datum/brain_trauma/trauma as anything in traumas)
		if(istype(trauma, brain_trauma_type) && trauma.resilience <= resilience)
			. += trauma

/obj/item/organ/internal/brain/proc/can_gain_trauma(datum/brain_trauma/trauma, resilience, natural_gain = FALSE)
	if(HAS_TRAIT(src, TRAIT_BRAIN_TRAUMA_IMMUNITY))
		return FALSE

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
		if(existing.resilience == resilience)
			resilience_tier_count++

	var/max_traumas
	switch(resilience)
		if(TRAUMA_RESILIENCE_BASIC)
			max_traumas = TRAUMA_LIMIT_BASIC
		if(TRAUMA_RESILIENCE_SURGERY)
			max_traumas = TRAUMA_LIMIT_SURGERY
		if(TRAUMA_RESILIENCE_LOBOTOMY)
			max_traumas = TRAUMA_LIMIT_LOBOTOMY
		if(TRAUMA_RESILIENCE_MAGIC)
			max_traumas = TRAUMA_LIMIT_MAGIC
		if(TRAUMA_RESILIENCE_ABSOLUTE)
			max_traumas = TRAUMA_LIMIT_ABSOLUTE

	if(natural_gain && resilience_tier_count >= max_traumas)
		return FALSE
	return TRUE

/obj/item/organ/internal/brain/proc/gain_trauma(datum/brain_trauma/trauma, resilience, ...)
	var/list/arguments = list()
	if(length(args) > 2)
		arguments = args.Copy(3)
	return brain_gain_trauma(trauma, resilience, arguments)

/obj/item/organ/internal/brain/proc/brain_gain_trauma(datum/brain_trauma/trauma, resilience, list/arguments)
	if(!can_gain_trauma(trauma, resilience))
		return

	var/datum/brain_trauma/actual_trauma
	if(ispath(trauma))
		if(!length(arguments))
			actual_trauma = new trauma()
		else
			actual_trauma = new trauma(arglist(arguments))
	else
		actual_trauma = trauma

	if(actual_trauma.brain)
		stack_trace("brain_gain_trauma was given an already active trauma [actual_trauma.type].")
		return

	add_trauma_to_traumas(actual_trauma)
	if(owner)
		actual_trauma.owner = owner
		if(SEND_SIGNAL(owner, COMSIG_CARBON_GAIN_TRAUMA, actual_trauma, resilience) & COMSIG_CARBON_BLOCK_TRAUMA)
			qdel(actual_trauma)
			return
		if(!actual_trauma.on_gain())
			qdel(actual_trauma)
			return
		log_game("[key_name(owner)] has gained the following brain trauma: [actual_trauma.type]")

	if(resilience)
		actual_trauma.resilience = resilience
	SSblackbox.record_feedback("tally", "traumas", 1, actual_trauma.type)
	return actual_trauma

/obj/item/organ/internal/brain/proc/add_trauma_to_traumas(datum/brain_trauma/trauma)
	trauma.brain = src
	traumas += trauma

/obj/item/organ/internal/brain/proc/remove_trauma_from_traumas(datum/brain_trauma/trauma)
	trauma.brain = null
	traumas -= trauma

/obj/item/organ/internal/brain/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience, natural_gain = FALSE)
	var/list/possible_traumas = list()
	for(var/datum/brain_trauma/trauma as anything in subtypesof(brain_trauma_type))
		if(can_gain_trauma(trauma, resilience, natural_gain) && initial(trauma.random_gain))
			possible_traumas += trauma

	if(!length(possible_traumas))
		return
	return gain_trauma(pick(possible_traumas), resilience)

/obj/item/organ/internal/brain/proc/cure_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_BASIC)
	var/list/curable = get_traumas_type(brain_trauma_type, resilience)
	if(length(curable))
		qdel(pick(curable))

/obj/item/organ/internal/brain/proc/cure_all_traumas(resilience = TRAUMA_RESILIENCE_BASIC)
	var/list/curable = get_traumas_type(resilience = resilience)
	. = length(curable)
	QDEL_LIST(curable)

/obj/item/organ/internal/brain/proc/transfer_identity(mob/living/carbon/H)
	brainmob = new(src)
	if(isnull(dna)) // someone didn't set this right...
		stack_trace("[src] at [loc] did not contain a dna datum at time of removal.")
		dna = H.dna.Clone()
	name = "[dna.real_name]’s [initial(src.name)]"
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
	if(brainmob?.client)//if there be a brain inside... the brain.
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
		name = "[dna.real_name]’s [initial(name)]"
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

	for(var/datum/brain_trauma/trauma as anything in traumas)
		trauma.on_lose(silent = TRUE)
		trauma.owner = null

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
				target.possess_by_player(brainmob.key)
		else if(brainmob?.mind && target_changeling)
			brainmob.mind.current = null
			brainmob.ghostize()
	else
		log_debug("Multibrain shenanigans at ([target.x],[target.y],[target.z]), mob '[target]'")

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.special_post_clone_handling(special == ORGAN_MANIPULATION_TRANSPLANTATE)

	..(target, special)

	for(var/datum/brain_trauma/trauma as anything in traumas)
		if(trauma.owner)
			if(trauma.owner != target)
				stack_trace("Brain trauma [trauma.type] is being applied to [target] while owned by [trauma.owner]!")
			continue

		trauma.owner = target
		if(!trauma.on_gain())
			qdel(trauma)

/obj/item/organ/internal/brain/internal_receive_damage(amount = 0, silent = FALSE) //brains are special; if they receive damage by other means, we really just want the damage to be passed ot the owner and back onto the brain.
	owner?.apply_damage(amount, BRAIN)

/obj/item/organ/internal/brain/necrotize(silent = FALSE) //Brain also has special handling for when it necrotizes
	if(..() && owner && vital)
		owner.setBrainLoss(BRAIN_DAMAGE_DEATH)

/obj/item/organ/internal/brain/prepare_eat()
	return // Too important to eat.

/obj/item/organ/internal/brain/golem
	name = "runic mind"
	desc = "Туго свёрнутый свиток, испещрённый неразборчивыми рунами."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"

/obj/item/organ/internal/brain/golem/get_ru_names()
	return alist(
		NOMINATIVE = "рунический разум",
		GENITIVE = "рунического разума",
		DATIVE = "руническому разуму",
		ACCUSATIVE = "рунический разум",
		INSTRUMENTAL = "руническим разумом",
		PREPOSITIONAL = "руническом разуме",
	)

/obj/item/organ/internal/brain/cluwne

/obj/item/organ/internal/brain/cluwne/insert(mob/living/target, special = ORGAN_MANIPULATION_DEFAULT, make_cluwne = TRUE)
	..(target, special)
	if(ishuman(target) && make_cluwne)
		var/mob/living/carbon/human/H = target
		H.makeCluwne() //No matter where you go, no matter what you do, you cannot escape

