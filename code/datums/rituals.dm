#define DEFAULT_RITUAL_RANGE_FIND 1
#define DEFAULT_RITUAL_COOLDOWN (10 SECONDS)
#define RITUAL_SUCCESSFUL						(1<<0)
/// Invocation checks, should not be used in extra checks.
#define RITUAL_FAILED_INVALID_SPECIES			(1<<1)
#define RITUAL_FAILED_EXTRA_INVOKERS			(1<<2)
#define RITUAL_FAILED_ON_PROCEED				(1<<3)

/datum/ritual
	/// Linked object
	var/obj/ritual_object
	/// Name of our ritual
	var/name
	/// If ritual requires more than one ashwalker
	var/extra_invokers = 0
	/// If invoker species isn't in allowed - he won't do ritual.
	var/list/allowed_species
	/// If true - only whitelisted species will be added as invokers
	var/require_allowed_species = TRUE
	/// We search for ashwalkers in that radius
	var/finding_range = DEFAULT_RITUAL_RANGE_FIND
	/// Single rituals. If true - it cannot be choosen.
	var/ritual_completed = FALSE
	/// Messages on failed invocation.
	var/invalid_species_message = "Вы не можете понять, как с этим работать."
	var/extra_invokers_message = "Для выполнения данного ритуала требуется больше участников."
	/// Cooldown for one ritual
	COOLDOWN_DECLARE(ritual_cooldown)
	/// Our cooldown after we casted ritual.
	var/cooldown_after_cast = DEFAULT_RITUAL_COOLDOWN
	/// If our ritual failed on proceed - we'll try to cause disaster.
	var/disaster_prob = 0
	
/datum/ritual/proc/link_object(obj/obj)
	src.ritual_object = obj
	
/datum/ritual/Destroy(force)
	ritual_object = null
	return ..()
		
/datum/ritual/proc/pre_ritual_check(obj/obj, mob/living/carbon/human/invoker)
	var/message
	var/cause_disaster = FALSE
	switch(ritual_invoke_check(obj, invoker))
		if(RITUAL_SUCCESSFUL)
			COOLDOWN_START(src, ritual_cooldown, cooldown_after_cast)
		if(RITUAL_FAILED_INVALID_SPECIES)
			message = invalid_species_message
		if(RITUAL_FAILED_EXTRA_INVOKERS)
			message = extra_invokers_message
		if(RITUAL_FAILED_ON_PROCEED)
			cause_disaster = TRUE
			
	if(message)
		to_chat(invoker, message)

	if(cause_disaster && prob(disaster_prob))
		disaster(obj, invoker)

	return
		
/datum/ritual/proc/ritual_invoke_check(obj/obj, mob/living/carbon/human/invoker)
	if(ritual_completed)
		return // should not have message
	if(allowed_species && !is_type_in_typecache(invoker.dna.species, allowed_species)) // double check to avoid funny situations
		return RITUAL_FAILED_INVALID_SPECIES
	var/list/invokers = list()
	if(extra_invokers)
		for(var/mob/living/carbon/human/human in range(finding_range, ritual_object))
			if(require_allowed_species && !is_type_in_typecache(human.dna.species, allowed_species))
				continue
			LAZYADD(invokers, human)
				
		if(LAZYLEN(invokers) < extra_invokers)
			return RITUAL_FAILED_EXTRA_INVOKERS
			
	if(ritual_check(obj, invoker, invokers))
		return do_ritual(obj, invoker, invokers)
	
/datum/ritual/proc/ritual_check(obj/obj, mob/living/carbon/human/invoker, list/invokers) // Additional pre-ritual checks
	return TRUE

/datum/ritual/proc/do_ritual(obj/obj, mob/living/carbon/human/invoker, list/invokers) // Do ritual stuff.
	return RITUAL_SUCCESSFUL

/datum/ritual/proc/disaster(obj/obj, mob/living/carbon/human/invoker)
	return

/datum/ritual/ashwalker
	/// If ritual requires extra shaman invokers
	var/extra_shaman_invokers = 0
	/// If ritual can be invoked only by shaman
	var/shaman_only = FALSE

/datum/ritual/ashwalker/New()
	allowed_species = typecacheof(/datum/species/unathi/ashwalker)

/datum/ritual/ashwalker/ritual_check(obj/obj, mob/living/carbon/human/invoker, list/invokers)
	if(shaman_only && !isashwalkershaman(invoker))
		return FALSE

	var/list/shaman_invokers = list()
	if(extra_shaman_invokers)
		for(var/mob/living/carbon/human/human as anything in invokers)
			if(isashwalkershaman(human))
				LAZYADD(shaman_invokers, human)
				
		if(LAZYLEN(shaman_invokers) < extra_shaman_invokers)
			return FALSE

	return TRUE

