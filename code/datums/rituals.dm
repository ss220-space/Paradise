#define DEFAULT_RITUAL_RANGE_FIND 1
#define DEFAULT_RITUAL_COOLDOWN (10 SECONDS)
#define DEFAULT_RITUAL_DISASTER_PROB 10
#define DEFAULT_RITUAL_FAIL_PROB 10

/// Ritual object bitflags
#define RITUAL_STARTED							(1<<0)
#define RITUAL_ENDED							(1<<1)
#define RITUAL_FAILED 							(1<<2)
/// Ritual datum bitflags
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
	/// If ritual requires more than one invoker
	var/extra_invokers = 0
	/// If invoker species isn't in allowed - he won't do ritual.
	var/list/allowed_species
	/// Required to ritual invoke things are located here
	var/required_things[] = list()
	/// If true - only whitelisted species will be added as invokers
	var/require_allowed_species = TRUE
	/// We search for humans in that radius
	var/finding_range = DEFAULT_RITUAL_RANGE_FIND
	/// Amount of maximum ritual uses.
	var/charges = -1
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
	var/ritual_should_del_things = TRUE
	/// After failed ritual proceed - we'll delete items.
	var/ritual_should_del_things_on_fail = FALSE
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
	var/failed = FALSE
	var/cause_disaster = FALSE
	var/del_things = FALSE
	var/start_cooldown = FALSE
	handle_ritual_object(RITUAL_STARTED)
	switch(ritual_invoke_check(obj, invoker))
		if(RITUAL_SUCCESSFUL)
			start_cooldown = TRUE
			handle_ritual_object(RITUAL_ENDED)
			del_things = TRUE
			charges--
		if(RITUAL_FAILED_INVALID_SPECIES)
			failed = TRUE
			message = invalid_species_message
		if(RITUAL_FAILED_EXTRA_INVOKERS)
			failed = TRUE
			message = extra_invokers_message
		if(RITUAL_FAILED_MISSED_REQUIREMENTS)
			failed = TRUE
			message = missed_reqs_message
		if(RITUAL_FAILED_ON_PROCEED)
			failed = TRUE
			cause_disaster = TRUE
			del_things = TRUE
			start_cooldown = TRUE
	
	if(start_cooldown)
		COOLDOWN_START(src, ritual_cooldown, cooldown_after_cast)

	if(message)
		to_chat(invoker, message)

	if(cause_disaster && prob(disaster_prob))
		disaster(obj, invoker)

	if((ritual_should_del_things_on_fail || ritual_should_del_things) && (del_things))
		del_things()

	if(failed)
		handle_ritual_object(RITUAL_FAILED)

	LAZYCLEARLIST(invokers)
	LAZYCLEARLIST(used_things)
	return

/datum/ritual/proc/handle_ritual_object(bitflags, silent = FALSE)
	switch(bitflags)
		if(RITUAL_STARTED)
			. = RITUAL_STARTED
			if(!silent)
				playsound(ritual_object.loc, 'sound/effects/ghost2.ogg', 50, TRUE)
		if(RITUAL_ENDED)
			. = RITUAL_ENDED
			if(!silent)
				playsound(ritual_object.loc, 'sound/effects/phasein.ogg', 50, TRUE)
		if(RITUAL_FAILED)
			. = RITUAL_FAILED
			if(!silent)
				playsound(ritual_object.loc, 'sound/effects/empulse.ogg', 50, TRUE)
	return .

/datum/ritual/proc/del_things() // This is a neutral variant with item delete. Override it to change.
	for(var/thing as anything in used_things)
		if(isitem(thing))
			qdel(thing)
	return

/datum/ritual/proc/ritual_invoke_check(obj/obj, mob/living/carbon/human/invoker)
	if(!charges && charges >= 0)
		return // should not have message
	if(allowed_species && !is_type_in_typecache(invoker.dna.species, allowed_species)) // double check to avoid funny situations
		return RITUAL_FAILED_INVALID_SPECIES
	if(extra_invokers && !check_invokers(invoker))
		return RITUAL_FAILED_EXTRA_INVOKERS
	if(required_things && !check_contents())
		return RITUAL_FAILED_MISSED_REQUIREMENTS
	if(ritual_check(obj, invoker))
		if(prob(fail_chance))
			return RITUAL_FAILED_ON_PROCEED
		return do_ritual(obj, invoker, invokers)

/datum/ritual/proc/check_invokers(mob/living/carbon/human/invoker)
	for(var/mob/living/carbon/human/human in range(finding_range, ritual_object))
		if(human == invoker)
			continue
		if(require_allowed_species && !is_type_in_typecache(human.dna.species, allowed_species))
			continue
		LAZYADD(invokers, human)

		if(LAZYLEN(invokers) >= extra_invokers)
			break
				
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

			if(current_amount >= needed_amount)
				break
		
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
			if(human == invoker)
				continue
			if(isashwalkershaman(human))
				LAZYADD(shaman_invokers, human)

			if(LAZYLEN(shaman_invokers) >= extra_shaman_invokers)
				break
				
		if(LAZYLEN(shaman_invokers) < extra_shaman_invokers)
			return FALSE

	return TRUE

/datum/ritual/ashwalker/summon_ashstorm
	name = "Ash storm summon"
	shaman_only = TRUE
	disaster_prob = 20
	charges = 2
	fail_chance = 20
	extra_invokers = 2
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
	if(!invoker.fire_stacks)
		return FALSE
	for(var/mob/living/carbon/human/human as anything in invokers)
		if(!human.fire_stacks)
			return FALSE
	return TRUE

/datum/ritual/ashwalker/summon_ashstorm/do_ritual(obj/obj, mob/living/carbon/human/invoker)
	SSweather.run_weather(/datum/weather/ash_storm)
	message_admins("[key_name(invoker)] accomplished ashstorm ritual and summoned ashstorm")
	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/summon_ashstorm/disaster(obj/obj, mob/living/carbon/human/invoker)
	var/list/targets = list()
	for(var/mob/living/carbon/human/human in SSmobs.clients_by_zlevel[invoker.z])
		if(isashwalker(human))
			LAZYADD(targets, human)
	if(!LAZYLEN(targets))
		return
	var/mob/living/carbon/human/human = pick(targets)
	var/datum/disease/virus/cadaver/cadaver = new
	cadaver.Contract(human)
	return

/datum/ritual/ashwalker/mind_transfer
	name = "Mind transfer"
	disaster_prob = 30
	fail_chance = 50
	extra_invokers = 1
	require_allowed_species = FALSE
	ritual_should_del_things_on_fail = TRUE
	required_things = list(
		/obj/item/twohanded/spear = 3,
		/obj/item/organ/internal/regenerative_core = 1
	)

/datum/ritual/ashwalker/mind_transfer/do_ritual(obj/obj, mob/living/carbon/human/invoker)
	var/mob/living/carbon/human/human = invokers[1]
	if(!human.mind || !human.ckey)
		return RITUAL_FAILED_ON_PROCEED // Your punishment
	var/obj/effect/proc_holder/spell/mind_transfer/transfer = new
	if(!transfer.cast(human, invoker))
		return RITUAL_FAILED_ON_PROCEED
	message_admins("[key_name(human)] accomplished mindtransfer ritual on [key_name(invoker)]")
	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/mind_transfer/disaster(obj/obj, mob/living/carbon/human/invoker)
	invoker.apply_damage(rand(10, 30), spread_damage = TRUE)
	invoker.emote("scream")
	if(prob(5))
		new /obj/item/organ/internal/legion_tumour(invoker)
	return

/datum/ritual/ashwalker/mind_transfer/handle_ritual_object(bitflags, silent = FALSE)
	. = ..(bitflags, TRUE)
	if(. == RITUAL_ENDED)
		playsound(ritual_object.loc, 'sound/effects/clone_jutsu.ogg', 50, TRUE)
		return
	. = ..(bitflags)
	return

/datum/ritual/ashwalker/summon
	name = "Summoning ritual"
	disaster_prob = 30
	fail_chance = 30
	shaman_only = TRUE
	extra_invokers = 1
	required_things = list(
		/obj/item/stack/sheet/sinew = 3,
		/obj/item/organ/internal/regenerative_core = 1,
		/obj/item/stack/sheet/animalhide/goliath_hide = 1
	)

/datum/ritual/ashwalker/summon/do_ritual(obj/obj, mob/living/carbon/human/invoker)
	var/list/ready_for_summoning = list()
	for(var/mob/living/carbon/human/human in SSmobs.clients_by_zlevel[invoker.z])
		if(isashwalker(human))
			LAZYADD(ready_for_summoning, human)
	if(!LAZYLEN(ready_for_summoning))
		return RITUAL_FAILED_ON_PROCEED
	var/mob/living/carbon/human/human = tgui_input_list(invoker, "Who will be summoned?", "Summon ritual", ready_for_summoning)
	if(!human)
		return RITUAL_FAILED_ON_PROCEED
	human.forceMove(ritual_object)
	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/summon/disaster(obj/obj, mob/living/carbon/human/invoker)
	var/obj/item/organ/external/limb = invoker.get_organ(pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	limb?.droplimb()
	return

/datum/ritual/ashwalker/summon/handle_ritual_object(bitflags, silent = FALSE)
	. = ..(bitflags, TRUE)
	if(. == RITUAL_ENDED)
		playsound(ritual_object.loc, 'sound/weapons/zapbang.ogg', 50, TRUE)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(5, FALSE, ritual_object.loc)
		smoke.start()
		return
	. = ..(bitflags)
	return

/datum/ritual/ashwalker/curse
	name = "Curse ritual"
	disaster_prob = 30
	fail_chance = 30
	charges = 3
	shaman_only = TRUE
	extra_invokers = 2
	required_things = list(
		/mob/living/carbon/human = 3
	)

/datum/ritual/ashwalker/curse/del_things()
	for(var/mob/living/carbon/human as anything in used_things)
		human.gib()
	return

/datum/ritual/ashwalker/curse/ritual_check(obj/obj, mob/living/carbon/human/invoker)
	. = ..()
	if(!.)
		return FALSE
	for(var/mob/living/carbon/human/human as anything in used_things)
		if(human.stat != DEAD)
			return FALSE
	return TRUE

/datum/ritual/ashwalker/curse/do_ritual(obj/obj, mob/living/carbon/human/invoker)
	var/list/humans = list()
	for(var/mob/living/carbon/human/human in SSmobs.clients_by_zlevel[invoker.z])
		if(!isashwalker(human))
			LAZYADD(humans, human)
			
	if(!LAZYLEN(humans))
		return RITUAL_FAILED_ON_PROCEED

	var/mob/living/carbon/human/human = pick(humans)
	var/datum/disease/vampire/disease = new
	if(!disease.Contract(human))
		return RITUAL_FAILED_ON_PROCEED
	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/curse/disaster(obj/obj, mob/living/carbon/human/invoker)
	var/list/targets = list()
	for(var/mob/living/carbon/human/human in SSmobs.clients_by_zlevel[invoker.z])
		if(isashwalker(human))
			LAZYADD(targets, human)
	if(!LAZYLEN(targets))
		return
	var/mob/living/carbon/human/human = pick(targets)
	human.monkeyize()
	return

/datum/ritual/ashwalker/power
	name = "Power ritual"
	disaster_prob = 40
	fail_chance = 40
	charges = 1
	shaman_only = TRUE
	extra_invokers = 4
	required_things = list(
		/mob/living/carbon/human = 5,
		/mob/living/simple_animal/hostile/asteroid/goliath = 3,
		/obj/item/organ/internal/regenerative_core = 3
	)

/datum/ritual/ashwalker/power/del_things()
	for(var/mob/living/living in used_things)
		living.gib()
	return

/datum/ritual/ashwalker/power/ritual_check(obj/obj, mob/living/carbon/human/invoker)
	. = ..()
	if(!.)
		return FALSE
	for(var/mob/living/living in used_things)
		if(living.stat != DEAD)
			return FALSE
	for(var/mob/living/carbon/human/human in used_things)
		if(!isashwalker(human))
			return FALSE
	return TRUE

/datum/ritual/ashwalker/power/do_ritual(obj/obj, mob/living/carbon/human/invoker)
	var/mob/living/carbon/human/human = pick(invokers)
	human.force_gene_block(GLOB.hulkblock, TRUE)
	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/power/disaster(obj/obj, mob/living/carbon/human/invoker)
	var/list/targets = list()
	for(var/mob/living/carbon/human/human in SSmobs.clients_by_zlevel[invoker.z])
		if(isashwalker(human))
			LAZYADD(targets, human)
	if(!LAZYLEN(targets))
		return
	invoker.force_gene_block(pick(GLOB.bad_blocks), TRUE)
	for(var/mob/living/carbon/human/human as anything in invokers)
		human.force_gene_block(pick(GLOB.bad_blocks), TRUE)
	var/mob/living/carbon/human/human = pick(targets)
	human.force_gene_block(pick(GLOB.bad_blocks), TRUE)
	return

/datum/ritual/ashwalker/cure
	name = "Cure ritual"
	charges = 3
	extra_invokers = 2
	cooldown_after_cast = 180 SECONDS
	required_things = list(
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher = 1,
		/mob/living/simple_animal/hostile/asteroid/goliath = 3,
		/obj/item/organ/internal/regenerative_core = 3
	)

/datum/ritual/ashwalker/cure/del_things()
	for(var/mob/living/living in used_things)
		living.gib()
	return

/datum/ritual/ashwalker/cure/ritual_check(obj/obj, mob/living/carbon/human/invoker)
	. = ..()
	if(!.)
		return FALSE
	for(var/mob/living/living in used_things)
		if(living.stat != DEAD)
			return FALSE
	if(!isashwalkershaman(invoker))
		fail_chance = 50
		disaster_prob = 50
	return TRUE

/datum/ritual/ashwalker/cure/do_ritual(obj/obj, mob/living/carbon/human/invoker)
	for(var/mob/living/carbon/human/human in range(finding_range, ritual_object))
		if(!isashwalker(human) || human.stat == DEAD)
			continue
		human.reagents.add_reagent("nutriment", 15)
		human.adjustBrainLoss(-20)
		for(var/datum/disease/disease in human.diseases)
			disease.cure()
	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/cure/disaster(obj/obj, mob/living/carbon/human/invoker)
	for(var/mob/living/carbon/human/human in range(10, ritual_object))
		if(!isashwalker(human) || human.stat == DEAD || !prob(disaster_prob))
			continue
		var/datum/disease/appendicitis/disease = new
		disease.Contract(human)
		human.adjustBrainLoss(20)
	return

