#define DEFAULT_RITUAL_RANGE_FIND 1
#define DEFAULT_RITUAL_COOLDOWN (10 SECONDS)
#define RITUAL_SUCCESSFUL						(1<<0)
/// Invocation checks, should not be used in extra checks.
#define RITUAL_FAILED_INVALID_SPECIES			(1<<1)
#define RITUAL_FAILED_REQUIRED_SHAMAN_INVOKE	(1<<2)
#define RITUAL_FAILED_REQUIRED_EXTRA_SHAMAN		(1<<3)
#define RITUAL_FAILED_EXTRA_INVOKERS			(1<<4)

/datum/ritual
	/// Linked object
	var/obj/ritual_object
	/// Name of our ritual
	var/name = "Hello, I'm useless ritual"
	/// If ritual can be invoked only by shaman
	var/shaman_only = FALSE
	/// If ritual requires more than one ashwalker
	var/extra_invokers = 0
	/// If ritual requires extra shaman invokers
	var/extra_shaman_invokers = 0
	/// We search for ashwalkers in that radius
	var/finding_range = DEFAULT_RITUAL_RANGE_FIND
	/// Single rituals. If true - it cannot be choosen.
	var/ritual_completed = FALSE
	/// Messages on failed invocation.
	var/invalid_species_message = "Вы не можете понять, как с этим работать."
	var/shaman_required_message = "Данный ритуал должен выполнять шаман."
	var/extra_shaman_required_message = "Для выполнения данного ритуала требуется больше шаманов."
	var/extra_invokers_message = "Для выполнения данного ритуала требуется больше участников."
	/// Cooldown for one ritual
	COOLDOWN_DECLARE(ritual_cooldown)
	/// Our cooldown after we casted ritual.
	var/cooldown_after_cast = DEFAULT_RITUAL_COOLDOWN
	
/datum/ritual/proc/link_object(obj/obj)
	src.ritual_object = obj
	
/datum/ritual/Destroy(force)
	ritual_object = null
	return ..()
		
/datum/ritual/proc/pre_ritual_check(obj/obj, mob/living/carbon/human/invoker)
	var/message
	switch(ritual_invoke_check(obj, invoker))
		if(RITUAL_FAILED_INVALID_SPECIES)
			message = invalid_species_message
		if(RITUAL_FAILED_REQUIRED_SHAMAN_INVOKE)
			message = shaman_required_message
		if(RITUAL_FAILED_EXTRA_INVOKERS)
			message = extra_invokers_message
		if(RITUAL_FAILED_REQUIRED_EXTRA_SHAMAN)
			message = extra_shaman_required_message
		if(RITUAL_SUCCESSFUL)
			do_ritual(obj, invoker)
			COOLDOWN_START(src, ritual_cooldown, cooldown_after_cast)
			
	if(message)
		to_chat(invoker, message)

	return
		
/datum/ritual/proc/ritual_invoke_check(obj/obj, mob/living/carbon/human/invoker)
	if(!isashwalker(invoker)) // double check to avoid funny situations
		return RITUAL_FAILED_INVALID_SPECIES
	if(shaman_only && !isashwalkershaman(invoker))
		return RITUAL_FAILED_REQUIRED_SHAMAN_INVOKE
	var/list/invokers = list()
	var/list/shaman_invokers = list()
	if(extra_invokers || extra_shaman_invokers)
		for(var/mob/living/carbon/human/human in range(finding_range, obj))
			if(isashwalker(human))
				LAZYADD(invokers, human)
			if(isashwalkershaman(human))
				LAZYADD(shaman_invokers, human)
				
		if(LAZYLEN(invokers) < extra_invokers)
			return RITUAL_FAILED_EXTRA_INVOKERS
		if(LAZYLEN(shaman_invokers) < extra_shaman_invokers)
			return RITUAL_FAILED_REQUIRED_EXTRA_SHAMAN
			
	return ritual_check(obj, invoker, invokers, shaman_invokers)
	
/datum/ritual/proc/ritual_check(obj/obj, mob/living/carbon/human/invoker, list/invokers, list/shaman_invokers) // After extra checks we should return RITUAL_SUCCESSFUL.
	return RITUAL_SUCCESSFUL

/datum/ritual/proc/do_ritual(obj/obj, mob/living/carbon/human/invoker) // Do ritual stuff.
	return
