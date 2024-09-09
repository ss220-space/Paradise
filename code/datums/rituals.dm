#define DEFAULT_RITUAL_RANGE_FIND 1
#define DEFAULT_RITUAL_COOLDOWN (10 SECONDS)
#define DEFAULT_RITUAL_DISASTER_PROB 10
#define DEFAULT_RITUAL_FAIL_PROB 10

#define RITUAL_SUCCESSFUL						(1<<0)
/// Invocation checks, should not be used in extra checks.
#define RITUAL_FAILED_INVALID_SPECIES			(1<<1)
#define RITUAL_FAILED_EXTRA_INVOKERS			(1<<2)
#define RITUAL_FAILED_MISSED_REQUIREMENTS		(1<<3)
#define RITUAL_FAILED_ON_PROCEED				(1<<4)

/datum/ritual
	/// Linked object
	var/obj/ritual_object
	/// Name of our ritual
	var/name
	/// If ritual requires more than one ashwalker
	var/extra_invokers = 0
	/// If invoker species isn't in allowed - he won't do ritual.
	var/list/allowed_species
	/// Required to ritual invoke things are located here
	var/required_things[] = list()
	/// If true - only whitelisted species will be added as invokers
	var/require_allowed_species = TRUE
	/// We search for humans in that radius
	var/finding_range = DEFAULT_RITUAL_RANGE_FIND
	/// Single rituals. If true - it cannot be choosen.
	var/ritual_completed = FALSE
	/// Messages on failed invocation.
	var/invalid_species_message = "Вы не можете понять, как с этим работать."
	var/extra_invokers_message = "Для выполнения данного ритуала требуется больше участников."
	var/missed_reqs_message = "Для выполнения данного ритуала требуется удовлетворить его требования."
	/// Cooldown for one ritual
	COOLDOWN_DECLARE(ritual_cooldown)
	/// Our cooldown after we casted ritual.
	var/cooldown_after_cast = DEFAULT_RITUAL_COOLDOWN
	/// If our ritual failed on proceed - we'll try to cause disaster.
	var/disaster_prob = DEFAULT_RITUAL_DISASTER_PROB
	/// A chance of failing our ritual.
	var/fail_chance = DEFAULT_RITUAL_FAIL_PROB
	/// After successful ritual we'll destroy used things.
	var/ritual_should_del_things = FALSE
	/// Temporary list of objects, which we will delete. Or use in transformations! Then clear list.
	var/list/used_things = list()
	/// Temporary list of invokers.
	var/list/invokers = list()
	
/datum/ritual/proc/link_object(obj/obj)
	ritual_object = obj
	
/datum/ritual/Destroy(force)
	ritual_object = null
	LAZYNULL(used_things)
	LAZYNULL(required_things)
	LAZYNULL(invokers)
	return ..()
		
/datum/ritual/proc/pre_ritual_check(obj/obj, mob/living/carbon/human/invoker)
	var/message
	var/cause_disaster = FALSE
	var/del_things = FALSE
	switch(ritual_invoke_check(obj, invoker))
		if(RITUAL_SUCCESSFUL)
			COOLDOWN_START(src, ritual_cooldown, cooldown_after_cast)
			del_things = TRUE
		if(RITUAL_FAILED_INVALID_SPECIES)
			message = invalid_species_message
		if(RITUAL_FAILED_EXTRA_INVOKERS)
			message = extra_invokers_message
		if(RITUAL_FAILED_MISSED_REQUIREMENTS)
			message = missed_reqs_message
		if(RITUAL_FAILED_ON_PROCEED)
			cause_disaster = TRUE
			
	if(message)
		to_chat(invoker, message)

	if(cause_disaster && prob(disaster_prob))
		disaster(obj, invoker)

	if(ritual_should_del_things && del_things)
		del_things()

	LAZYCLEARLIST(invokers)
	LAZYCLEARLIST(used_things)
	return

/datum/ritual/proc/del_things() // This is a neutral variant with item delete. Override it to change.
	for(var/thing as anything in used_things)
		if(isitem(thing))
			qdel(thing)
	return

/datum/ritual/proc/ritual_invoke_check(obj/obj, mob/living/carbon/human/invoker)
	if(ritual_completed)
		return // should not have message
	if(allowed_species && !is_type_in_typecache(invoker.dna.species, allowed_species)) // double check to avoid funny situations
		return RITUAL_FAILED_INVALID_SPECIES
	if(extra_invokers && !check_invokers())
		return RITUAL_FAILED_EXTRA_INVOKERS
	if(required_things && !check_contents())
		return RITUAL_FAILED_MISSED_REQUIREMENTS
	if(ritual_check(obj, invoker, invokers))
		if(prob(fail_chance))
			return RITUAL_FAILED_ON_PROCEED
		return do_ritual(obj, invoker, invokers)

/datum/ritual/proc/check_invokers()
	for(var/mob/living/carbon/human/human in range(finding_range, ritual_object))
		if(require_allowed_species && !is_type_in_typecache(human.dna.species, allowed_species))
			continue
		LAZYADD(invokers, human)
				
		if(LAZYLEN(invokers) < extra_invokers)
			return FALSE

	return TRUE

/datum/ritual/proc/check_contents()
    for(var/thing in required_things)
        var/needed_amount = required_things[thing]
        var/current_amount = 0

        for(var/obj in range(finding_range, ritual_object))
            if(ispath(obj, thing))
                current_amount++
				LAZYADD(used_things, obj)

        if(current_amount < needed_amount)
            return FALSE

    return TRUE

/datum/ritual/proc/ritual_check(obj/obj, mob/living/carbon/human/invoker) // Additional pre-ritual checks
	return TRUE

/datum/ritual/proc/do_ritual(obj/obj, mob/living/carbon/human/invoker) // Do ritual stuff.
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

/datum/ritual/ashwalker/ritual_check(obj/obj, mob/living/carbon/human/invoker)
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

/datum/ritual/ashwalker/summon_ashstorm
	name = "Ash storm summon"
	shaman_only = TRUE
	disaster_prob = 20
	fail_chance = 20
	ritual_should_del_things = TRUE
	required_things = list(
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 2,
		/mob/living/simple_animal/hostile/asteroid/goliath = 1,
		/obj/item/candle = 1
	)

/datum/ritual/ashwalker/summon_ashstorm/check_contents()
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/mob in used_things)
		if(mob.stat != DEAD)
			return FALSE

	return TRUE

/datum/ritual/ashwalker/summon_ashstorm/del_things()
	. = ..()
	for(var/mob/mob in used_things)
		mob.gib()

/datum/ritual/ashwalker/summon_ashstorm/ritual_check(obj/obj, mob/living/carbon/human/invoker)
	. = ..()
	if(!.)
		return FALSE
	for(var/mob/living/carbon/human/human as anything in invokers)
		if(!human.fire_stacks)
			return FALSE
	return TRUE

/datum/ritual/ashwalker/summon_ashstorm/do_ritual(obj/obj, mob/living/carbon/human/invoker)
	SSweather.run_weather(/datum/weather/ash_storm)
	message_admins("[key_name(invoker)] accomplished ashstorm ritual and summoned ashstorm")
	ritual_completed = TRUE
	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/summon_ashstorm/disaster(obj/obj, mob/living/carbon/human/invoker)
	for(var/mob/living/carbon/human/human in SSmobs.clients_by_zlevel[invoker.z])
		if(isashwalker(human))
			var/datum/disease/virus/cadaver/cadaver = new
			cadaver.Contract(human)
			break
	return

