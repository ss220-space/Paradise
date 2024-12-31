/datum/ritual
	/// Linked object
	var/obj/ritual_object
	/// Name of our ritual
	var/name
	/// If ritual requires more than one invoker
	var/extra_invokers = 0
	/// If invoker species isn't in allowed - he won't do ritual.
	var/list/allowed_species
	/// If invoker special role isn't in allowed - he won't do ritual.
	var/list/allowed_special_role
	/// Required to ritual invoke things are located here
	var/list/required_things
	/// If true - only whitelisted species will be added as invokers
	var/require_allowed_species = TRUE
	/// Same as require_allowed_species, but requires special role to be counted as invoker.
	var/require_allowed_special_role = FALSE
	/// We search for humans in that radius
	var/finding_range = DEFAULT_RITUAL_RANGE_FIND
	/// Amount of maximum ritual uses.
	var/charges = -1
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
	/// If defined - do_after will be added to your ritual
	var/cast_time

/datum/ritual/Destroy(force)
	ritual_object = null
	LAZYNULL(used_things)
	LAZYNULL(required_things)
	LAZYNULL(invokers)
	return ..()
		
/datum/ritual/proc/pre_ritual_check(mob/living/carbon/human/invoker)
	var/failed = FALSE
	var/cause_disaster = FALSE
	
	var/del_things = FALSE
	var/start_cooldown = FALSE

	handle_ritual_object(RITUAL_STARTED)
	
	. = ritual_invoke_check(invoker)
	switch(.)
		if(RITUAL_SUCCESSFUL)
			start_cooldown = TRUE
			addtimer(CALLBACK(src, PROC_REF(handle_ritual_object), RITUAL_ENDED), 1 SECONDS)
			charges--
		if(RITUAL_FAILED_INVALID_SPECIES)
			failed = TRUE
		if(RITUAL_FAILED_EXTRA_INVOKERS)
			failed = TRUE
		if(RITUAL_FAILED_MISSED_REQUIREMENTS)
			failed = TRUE
		if(RITUAL_FAILED_INVALID_SPECIAL_ROLE)
			failed = TRUE
		if(RITUAL_FAILED_ON_PROCEED)
			failed = TRUE
			cause_disaster = TRUE
			start_cooldown = TRUE
		if(NONE)
			failed = TRUE
	
	if(start_cooldown)
		COOLDOWN_START(src, ritual_cooldown, cooldown_after_cast)

	if(cause_disaster && prob(disaster_prob))
		disaster(invoker)

	if((. & RITUAL_SUCCESSFUL) && (ritual_should_del_things))
		del_things = TRUE

	if((. & RITUAL_FAILED_ON_PROCEED) && (ritual_should_del_things_on_fail))
		del_things = TRUE

	if(del_things)
		del_things()

	if(failed)
		addtimer(CALLBACK(src, PROC_REF(handle_ritual_object), RITUAL_FAILED), 2 SECONDS)
	
	/// We use pre-defines
	LAZYCLEARLIST(invokers)
	LAZYCLEARLIST(used_things)

	return .

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
	for(var/obj/item/thing in used_things)
		qdel(thing)

	return

/datum/ritual/proc/ritual_invoke_check(mob/living/carbon/human/invoker)
	if(!COOLDOWN_FINISHED(src, ritual_cooldown))
		return NONE

	if(charges == 0)
		return NONE

	if(allowed_special_role && !LAZYIN(allowed_special_role, invoker.mind?.special_role))
		return RITUAL_FAILED_INVALID_SPECIAL_ROLE

	if(allowed_species && !is_type_in_list(invoker.dna.species, allowed_species)) // double check to avoid funny situations
		return RITUAL_FAILED_INVALID_SPECIES

	if(!check_invokers(invoker))
		return RITUAL_FAILED_EXTRA_INVOKERS

	if(required_things && !check_contents(invoker))
		return RITUAL_FAILED_MISSED_REQUIREMENTS

	if(prob(fail_chance))
		return RITUAL_FAILED_ON_PROCEED

	if(cast_time && !cast(invoker))
		return RITUAL_FAILED_ON_PROCEED

	return do_ritual(invoker)

/datum/ritual/proc/cast(mob/living/carbon/human/invoker)
	. = TRUE

	var/list/invokers_list = invokers.Copy() // create temp list to avoid funny situations
	LAZYADD(invokers_list, invoker)

	for(var/mob/living/carbon/human/human as anything in invokers_list)
		if(!do_after(human, cast_time, ritual_object, DA_IGNORE_HELD_ITEM, extra_checks = CALLBACK(src, PROC_REF(action_check_contents))))
			. = FALSE

	return .

/datum/ritual/proc/check_invokers(mob/living/carbon/human/invoker)
	if(!extra_invokers)
		return TRUE

	for(var/mob/living/carbon/human/human in range(finding_range, ritual_object))
		if(human == invoker)
			continue

		if(require_allowed_species && !is_type_in_list(human.dna.species, allowed_species))
			continue

		if(require_allowed_special_role && !LAZYIN(allowed_special_role, human.mind?.special_role))
			continue

		LAZYADD(invokers, human)

		if(LAZYLEN(invokers) >= extra_invokers)
			break
				
	if(LAZYLEN(invokers) < extra_invokers)
		ritual_object.balloon_alert(invoker, "требуется больше участников!")
		return FALSE

	return TRUE

/datum/ritual/proc/check_contents(mob/living/carbon/human/invoker)
	var/list/atom/movable/atoms = list()

	for(var/atom/obj as anything in range(finding_range, ritual_object))
		if(isitem(obj))
			var/obj/item/close_item = obj
			if(close_item.item_flags & ABSTRACT)
				continue

		if(obj.invisibility)
			continue

		if(obj == invoker)
			continue

		if(obj == ritual_object)
			continue

		if(LAZYIN(invokers, obj))
			continue

		LAZYADD(atoms, obj)

	var/list/requirements = required_things.Copy()
	for(var/atom/atom as anything in atoms)
		for(var/req_type in requirements)
			if(requirements[req_type] <= 0)
				continue
			
			if(!istype(atom, req_type))
				continue

			LAZYADD(used_things, atom)

			if(isstack(atom))
				var/obj/item/stack/picked_stack = atom
				requirements[req_type] -= picked_stack.amount
			else
				requirements[req_type]--

	var/list/what_are_we_missing = list()
	for(var/req_type in requirements)
		var/number_of_things = requirements[req_type]
		
		if(number_of_things <= 0)
			continue

		LAZYADD(what_are_we_missing, req_type)

	if(LAZYLEN(what_are_we_missing))
		ritual_object.balloon_alert(invoker, "требуется больше компонентов!")
		return FALSE

	return TRUE

/datum/ritual/proc/action_check_contents()
	for(var/atom/atom as anything in used_things)
		if(QDELETED(atom))
			return FALSE

		if(!(atom in range(finding_range, ritual_object)))
			return FALSE

	return TRUE

/datum/ritual/proc/do_ritual(mob/living/carbon/human/invoker) // Do ritual stuff.
	return RITUAL_SUCCESSFUL

/datum/ritual/proc/disaster(mob/living/carbon/human/invoker)
	return

/datum/ritual/ashwalker
	/// If ritual requires extra shaman invokers
	var/extra_shaman_invokers = 0
	/// If ritual can be invoked only by shaman
	var/shaman_only = FALSE
	allowed_species = list(/datum/species/unathi/ashwalker, /datum/species/unathi/draconid)

/datum/ritual/ashwalker/check_invokers(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	if(shaman_only && !isashwalkershaman(invoker))
		to_chat(invoker, span_warning("Только шаман может выполнить данный ритуал!"))
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
			ritual_object.balloon_alert(invoker, "требуется больше шаманов!")
			return FALSE

	return TRUE

/datum/ritual/ashwalker/summon_ashstorm
	name = "Ash storm summon"
	shaman_only = TRUE
	disaster_prob = 20
	charges = 2
	cooldown_after_cast = 1200 SECONDS
	cast_time = 100 SECONDS
	fail_chance = 20
	extra_invokers = 2
	required_things = list(
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 1
	)

/datum/ritual/ashwalker/summon_ashstorm/check_contents(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	for(var/mob/living/living in used_things)
		if(living.stat != DEAD)
			to_chat(invoker, "Существа должны быть мертвы")
			return FALSE

	return TRUE

/datum/ritual/ashwalker/summon_ashstorm/del_things()
	. = ..()

	for(var/mob/living/living in used_things)
		living.gib()

	return

/datum/ritual/ashwalker/summon_ashstorm/check_invokers(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	if(!invoker.fire_stacks)
		to_chat(invoker, "Инициатор ритуала должнен быть в воспламеняемой субстанции.")
		return FALSE

	for(var/mob/living/carbon/human/human as anything in invokers)
		if(!human.fire_stacks)
			to_chat(invoker, "Участники ритуала должны быть в воспламеняемой субстанции.")
			return FALSE

	return TRUE

/datum/ritual/ashwalker/summon_ashstorm/do_ritual(mob/living/carbon/human/invoker)
	SSweather.run_weather(/datum/weather/ash_storm)
	message_admins("[key_name(invoker)] accomplished ashstorm ritual and summoned ashstorm")

	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/summon_ashstorm/disaster(mob/living/carbon/human/invoker)
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

/datum/ritual/ashwalker/summon_ashstorm/handle_ritual_object(bitflags, silent = FALSE)
	. = ..(bitflags, TRUE)

	switch(.)
		if(RITUAL_ENDED)
			playsound(ritual_object.loc, 'sound/magic/fleshtostone.ogg', 50, TRUE)
		if(RITUAL_STARTED)
			playsound(ritual_object.loc, 'sound/magic/invoke_general.ogg', 50, TRUE)
		if(RITUAL_FAILED)
			playsound(ritual_object.loc, 'sound/magic/castsummon.ogg', 50, TRUE)

	return .

/datum/ritual/ashwalker/transformation
	name = "Transformation ritual"
	disaster_prob = 30
	fail_chance = 50
	extra_invokers = 1
	cooldown_after_cast = 480 SECONDS
	cast_time = 30 SECONDS
	ritual_should_del_things_on_fail = TRUE
	required_things = list(
		/obj/item/twohanded/spear = 3,
		/obj/item/organ/internal/regenerative_core = 1,
		/mob/living/carbon/human = 1
	)

/datum/ritual/ashwalker/transformation/do_ritual(mob/living/carbon/human/invoker)
	var/mob/living/carbon/human/human = locate() in used_things

	if(!human || !human.mind || !human.ckey)
		return RITUAL_FAILED_ON_PROCEED // Your punishment

	human.set_species(/datum/species/unathi/ashwalker)
	human.mind.store_memory("Теперь вы пеплоходец, вы часть племени! Вы довольно смутно помните о прошлой жизни, и вы не помните, как пользоваться технологиями!")

	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/transformation/disaster(mob/living/carbon/human/invoker)
	invoker.adjustBrainLoss(15)
	invoker.SetKnockdown(5 SECONDS)
	
	var/mob/living/carbon/human/human = locate() in used_things

	if(QDELETED(human))
		return

	var/list/destinations = list()

	for(var/obj/item/radio/beacon/beacon in GLOB.global_radios)
		LAZYADD(destinations, get_turf(beacon))

	human.forceMove(safepick(destinations))
	playsound(get_turf(human), 'sound/magic/invoke_general.ogg', 50, TRUE)

	return

/datum/ritual/ashwalker/transformation/handle_ritual_object(bitflags, silent = FALSE)
	. = ..(bitflags, TRUE)

	if(. == RITUAL_ENDED)
		playsound(ritual_object.loc, 'sound/effects/clone_jutsu.ogg', 50, TRUE)
		return

	. = ..(bitflags)
	return .

/datum/ritual/ashwalker/summon
	name = "Summoning ritual"
	disaster_prob = 30
	fail_chance = 30
	shaman_only = TRUE
	cooldown_after_cast = 900 SECONDS
	cast_time = 30 SECONDS
	extra_invokers = 1

/datum/ritual/ashwalker/summon/do_ritual(mob/living/carbon/human/invoker)
	var/list/ready_for_summoning = list()

	for(var/mob/living/carbon/human/human in GLOB.mob_list)
		if(!human.ckey)
			continue

		if(!isashwalker(human))
			continue

		LAZYADD(ready_for_summoning, human)

	if(!LAZYLEN(ready_for_summoning))
		return RITUAL_FAILED_ON_PROCEED

	var/mob/living/carbon/human/human = tgui_input_list(invoker, "Who will be summoned?", "Summon ritual", ready_for_summoning)

	if(!human)
		return RITUAL_FAILED_ON_PROCEED

	deal_damage()
	summon(human)

	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/summon/proc/deal_damage()
	for(var/mob/living/carbon/human/summoner in range(finding_range, ritual_object))
		summoner.AdjustBlood(-(summoner.blood_volume * 0.20))
		summoner.apply_damage(25, def_zone = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))

	return TRUE

/datum/ritual/ashwalker/summon/proc/summon(mob/living/carbon/human/human)
	human.forceMove(get_turf(ritual_object))
	human.vomit()
	human.Weaken(10 SECONDS)

	return TRUE

/datum/ritual/ashwalker/summon/disaster(mob/living/carbon/human/invoker)
	if(!prob(70))
		return

	var/obj/item/organ/external/limb = invoker.get_organ(pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	limb?.droplimb()

	return

/datum/ritual/ashwalker/summon/handle_ritual_object(bitflags, silent = FALSE)
	. = ..(bitflags, TRUE)

	switch(.)
		if(RITUAL_ENDED)
			playsound(ritual_object.loc, 'sound/weapons/zapbang.ogg', 50, TRUE)
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(5, FALSE, ritual_object.loc)
			smoke.start()
		if(RITUAL_STARTED)
			playsound(ritual_object.loc, 'sound/magic/forcewall.ogg', 50, TRUE)
		if(RITUAL_FAILED)
			playsound(ritual_object.loc, 'sound/magic/invoke_general.ogg', 50, TRUE)

	return .

/datum/ritual/ashwalker/curse
	name = "Curse ritual"
	disaster_prob = 30
	fail_chance = 30
	cooldown_after_cast = 600 SECONDS
	cast_time = 30 SECONDS
	charges = 3
	shaman_only = TRUE
	extra_invokers = 2
	required_things = list(
		/mob/living/carbon/human = 3
	)

/datum/ritual/ashwalker/curse/del_things()
	for(var/mob/living/carbon/human/human in used_things)
		human.gib()

	return

/datum/ritual/ashwalker/curse/check_contents(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/human in used_things)
		if(human.stat != DEAD)
			to_chat(invoker, "Гуманоиды должны быть мертвы.")
			return FALSE

	return TRUE

/datum/ritual/ashwalker/curse/do_ritual(mob/living/carbon/human/invoker)
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

/datum/ritual/ashwalker/curse/disaster(mob/living/carbon/human/invoker)
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
	cooldown_after_cast = 800 SECONDS
	cast_time = 30 SECONDS
	shaman_only = TRUE
	extra_invokers = 4
	required_things = list(
		/mob/living/simple_animal/hostile/asteroid/goliath = 3,
		/obj/item/organ/internal/regenerative_core = 3
	)

/datum/ritual/ashwalker/power/del_things()
	for(var/mob/living/living in used_things)
		living.gib()

	return

/datum/ritual/ashwalker/power/check_contents(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	for(var/mob/living/living in used_things)
		if(living.stat != DEAD)
			to_chat(invoker, "Существа должны быть мертвы.")
			return FALSE

	return TRUE

/datum/ritual/ashwalker/power/do_ritual(mob/living/carbon/human/invoker)
	LAZYADD(invokers, invoker)

	for(var/mob/living/carbon/human/human as anything in invokers)
		if(LAZYIN(human.dna?.default_blocks, GLOB.weakblock))
			human.force_gene_block(GLOB.weakblock)

		human.force_gene_block(GLOB.strongblock, TRUE)

	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/power/disaster(mob/living/carbon/human/invoker)
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

/datum/ritual/ashwalker/power/handle_ritual_object(bitflags, silent =  FALSE)
	. = ..(bitflags, TRUE)

	switch(.)
		if(RITUAL_ENDED)
			playsound(ritual_object.loc, 'sound/magic/castsummon.ogg', 50, TRUE)
		if(RITUAL_STARTED)
			playsound(ritual_object.loc, 'sound/magic/smoke.ogg', 50, TRUE)
		if(RITUAL_FAILED)
			playsound(ritual_object.loc, 'sound/magic/strings.ogg', 50, TRUE)

	return .

/datum/ritual/ashwalker/resurrection
	name = "Resurrection ritual"
	charges = 3
	extra_invokers = 2
	cooldown_after_cast = 180 SECONDS
	cast_time = 30 SECONDS
	shaman_only = TRUE
	disaster_prob = 25
	fail_chance = 35
	required_things = list(
		/obj/item/organ/internal/regenerative_core = 2,
		/mob/living/carbon/human = 1,
		/obj/item/reagent_containers/food/snacks/grown/ash_flora/fireblossom = 4,
		/obj/item/reagent_containers/food/snacks/grown/ash_flora/cactus_fruit = 1
	)

/datum/ritual/ashwalker/resurrection/check_contents(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	for(var/mob/living/living in used_things)
		if(living.stat != DEAD)
			to_chat(invoker, "Существа должны быть мертвы.")
			return FALSE

	var/mob/living/carbon/human/human = locate() in used_things

	if(!human.mind || !human.ckey)
		return FALSE

	if(!isashwalker(human))
		fail_chance = 15

	return TRUE

/datum/ritual/ashwalker/resurrection/do_ritual(mob/living/carbon/human/invoker)
	var/mob/living/carbon/human/human = locate() in used_things
	human.revive()
	human.adjustBrainLoss(20)

	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/resurrection/disaster(mob/living/carbon/human/invoker)
	for(var/mob/living/carbon/human/human in range(10, ritual_object))
		if(!isashwalker(human) || human.stat == DEAD)
			continue

		human.adjustBrainLoss(15)

	return

/datum/ritual/ashwalker/resurrection/handle_ritual_object(bitflags, silent =  FALSE)
	. = ..(bitflags, TRUE)

	switch(.)
		if(RITUAL_ENDED)
			playsound(ritual_object.loc, 'sound/magic/clockwork/reconstruct.ogg', 50, TRUE)
		if(RITUAL_STARTED)
			playsound(ritual_object.loc, 'sound/magic/disable_tech.ogg', 50, TRUE)
		if(RITUAL_FAILED)
			playsound(ritual_object.loc, 'sound/magic/invoke_general.ogg', 50, TRUE)

	return .

/datum/ritual/ashwalker/recharge
	name = "Recharge rituals"
	extra_invokers = 3
	disaster_prob = 30
	fail_chance = 50
	cooldown_after_cast = 360 SECONDS
	cast_time = 30 SECONDS
	shaman_only = TRUE
	required_things = list(
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher = 1,
		/mob/living/simple_animal/hostile/asteroid/goliath = 1,
		/obj/item/organ/internal/regenerative_core = 1,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 1
	)
	var/list/blacklisted_rituals = list(/datum/ritual/ashwalker/power)

/datum/ritual/ashwalker/recharge/del_things()
	. = ..()

	for(var/mob/living/living in used_things)
		living.gib()

	return

/datum/ritual/ashwalker/recharge/check_contents(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	for(var/mob/living/living in used_things)
		if(living.stat != DEAD)
			to_chat(invoker, "Существа должны быть мертвы.")
			return FALSE

	return TRUE

/datum/ritual/ashwalker/recharge/do_ritual(mob/living/carbon/human/invoker)
	var/datum/component/ritual_object/component = ritual_object.GetComponent(/datum/component/ritual_object)

	if(!component)
		return RITUAL_FAILED_ON_PROCEED

	for(var/datum/ritual/ritual as anything in component.rituals)
		if(is_type_in_list(ritual, blacklisted_rituals))
			continue

		if(ritual.charges < 0)
			continue

		ritual.charges++

	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/recharge/disaster(mob/living/carbon/human/invoker)
	var/list/targets = list()

	for(var/mob/living/carbon/human/human in SSmobs.clients_by_zlevel[invoker.z])
		if(isashwalker(human))
			LAZYADD(targets, human)

	if(!LAZYLEN(targets))
		return

	var/mob/living/carbon/human/human = pick(targets)
	new /obj/item/organ/internal/legion_tumour(human)

	return

/datum/ritual/ashwalker/recharge/handle_ritual_object(bitflags, silent =  FALSE)
	. = ..(bitflags, TRUE)

	switch(.)
		if(RITUAL_ENDED)
			playsound(ritual_object.loc, 'sound/magic/castsummon.ogg', 50, TRUE)
		if(RITUAL_STARTED)
			playsound(ritual_object.loc, 'sound/magic/cult_spell.ogg', 50, TRUE)
		if(RITUAL_FAILED)
			playsound(ritual_object.loc, 'sound/magic/invoke_general.ogg', 50, TRUE)

	return .

/datum/ritual/ashwalker/population
	name = "Population ritual"
	extra_invokers = 2
	charges = 1
	cooldown_after_cast = 120 SECONDS
	cast_time = 30 SECONDS
	ritual_should_del_things_on_fail = TRUE
	required_things = list(
		/obj/item/reagent_containers/food/snacks/grown/ash_flora/cactus_fruit = 1,
		/obj/item/reagent_containers/food/snacks/grown/ash_flora/fireblossom = 1,
		/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem = 1,
		/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_leaf = 1,
		/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_cap = 1,
		/obj/item/reagent_containers/food/snacks/grown/ash_flora/shavings = 1
	)

/datum/ritual/ashwalker/population/check_invokers(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	if(!isashwalkershaman(invoker))
		disaster_prob = 40
		fail_chance = 40

	return TRUE

/datum/ritual/ashwalker/population/del_things()
	for(var/mob/living/living in used_things)
		living.gib()

	return

/datum/ritual/ashwalker/population/check_contents(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	for(var/mob/living/living in used_things)
		if(living.stat != DEAD)
			to_chat(invoker, "Существа должны быть мертвы.")
			return FALSE

	return TRUE

/datum/ritual/ashwalker/population/do_ritual(mob/living/carbon/human/invoker)
	new /obj/effect/mob_spawn/human/ash_walker/shaman(ritual_object.loc)

	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/population/disaster(mob/living/carbon/human/invoker)
	for(var/mob/living/carbon/human/human in SSmobs.clients_by_zlevel[invoker.z])
		if(!isashwalker(human) || !prob(disaster_prob))
			continue

		if(!isturf(human.loc))
			continue

		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(5, FALSE, get_turf(human.loc))
		smoke.start()

		for(var/obj/item/obj as anything in human.get_equipped_items(TRUE, TRUE))
			human.drop_item_ground(obj)

	return

/datum/ritual/ashwalker/population/handle_ritual_object(bitflags, silent =  FALSE)
	. = ..(bitflags, TRUE)

	switch(.)
		if(RITUAL_ENDED)
			playsound(ritual_object.loc, 'sound/magic/demon_consume.ogg', 50, TRUE)
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(5, FALSE, get_turf(ritual_object.loc))
			smoke.start()
		if(RITUAL_STARTED)
			playsound(ritual_object.loc, 'sound/magic/cult_spell.ogg', 50, TRUE)
		if(RITUAL_FAILED)
			playsound(ritual_object.loc, 'sound/magic/teleport_diss.ogg', 50, TRUE)
			
	return .

/datum/ritual/ashwalker/soul
	name = "Soul ritual"
	extra_invokers = 3
	cooldown_after_cast = 1200 SECONDS
	cast_time = 30 SECONDS
	required_things = list(
		/mob/living/carbon/human = 3,
		/obj/item/stack/sheet/animalhide/ashdrake = 1
	)

/datum/ritual/ashwalker/soul/check_invokers(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	if(!isashwalkershaman(invoker))
		disaster_prob = 40
		fail_chance = 70

	return TRUE

/datum/ritual/ashwalker/population/del_things()
	var/obj/item/stack/sheet/animalhide/ashdrake/stack = locate() in used_things
	stack.use(1)

	for(var/mob/living/living in used_things)
		living.gib()

	return

/datum/ritual/ashwalker/soul/check_contents(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	for(var/mob/living/living in used_things)
		if(living.stat != DEAD)
			to_chat(invoker, "Существа должны быть мертвы.")
			return FALSE

	return TRUE

/datum/ritual/ashwalker/soul/do_ritual(mob/living/carbon/human/invoker)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(5, FALSE, get_turf(invoker.loc))
	smoke.start()
	invoker.set_species(/datum/species/unathi/draconid)

	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/soul/disaster(mob/living/carbon/human/invoker)
	for(var/mob/living/carbon/human/human in SSmobs.clients_by_zlevel[invoker.z])
		if(!isashwalker(human) || !prob(disaster_prob))
			continue

		if(!isturf(human.loc))
			continue

		human.SetKnockdown(10 SECONDS)
		var/turf/turf = human.loc
		new /obj/effect/hotspot(turf)
		turf.hotspot_expose(700, 50, 1)

	return

/datum/ritual/ashwalker/soul/handle_ritual_object(bitflags, silent =  FALSE)
	. = ..(bitflags, TRUE)

	switch(.)
		if(RITUAL_ENDED)
			playsound(ritual_object.loc, 'sound/effects/whoosh.ogg', 50, TRUE)
		if(RITUAL_STARTED)
			playsound(ritual_object.loc, 'sound/effects/bamf.ogg', 50, TRUE)
		if(RITUAL_FAILED)
			playsound(ritual_object.loc, 'sound/effects/blobattack.ogg', 50, TRUE)

	return .

/datum/ritual/ashwalker/transmutation
	name = "Transmutation ritual"
	cooldown_after_cast = 120 SECONDS
	cast_time = 10 SECONDS
	required_things = list(
		/obj/item/stack/ore = 10
	)

/datum/ritual/ashwalker/transmutation/check_invokers(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	if(!isashwalkershaman(invoker))
		disaster_prob = 30
		fail_chance = 50

	return TRUE

/datum/ritual/ashwalker/transmutation/do_ritual(mob/living/carbon/human/invoker)
	var/ore_type = pick(subtypesof(/obj/item/stack/ore))

	var/obj/item/stack/ore/ore = new ore_type(get_turf(ritual_object))
	ore.add(10)

	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/transmutation/disaster(mob/living/carbon/human/invoker)
	for(var/mob/living/carbon/human/human in SSmobs.clients_by_zlevel[invoker.z])
		if(!isashwalker(human) || !prob(disaster_prob))
			continue

		if(!isturf(human.loc))
			continue

		human.SetKnockdown(10 SECONDS)
		var/turf/turf = human.loc
		new /obj/effect/hotspot(turf)
		turf.hotspot_expose(700, 50, 1)

	return

/datum/ritual/ashwalker/transmutation/handle_ritual_object(bitflags, silent =  FALSE)
	. = ..(bitflags, TRUE)

	switch(.)
		if(RITUAL_ENDED)
			playsound(ritual_object.loc, 'sound/effects/bin_close.ogg', 50, TRUE)
		if(RITUAL_STARTED)
			playsound(ritual_object.loc, 'sound/magic/cult_spell.ogg', 50, TRUE)
		if(RITUAL_FAILED)
			playsound(ritual_object.loc, 'sound/magic/knock.ogg', 50, TRUE)

	return .

/datum/ritual/ashwalker/interrogation
	name = "Interrogation ritual"
	cooldown_after_cast = 50 SECONDS
	shaman_only = TRUE
	cast_time = 10 SECONDS
	required_things = list(
		/mob/living/carbon/human = 1
	)

/datum/ritual/ashwalker/interrogation/check_invokers(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	if(invoker.health > 10)
		disaster_prob = 30
		fail_chance = 30

	return TRUE

/datum/ritual/ashwalker/interrogation/check_contents(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	var/mob/living/carbon/human/human = locate() in used_things
	if(!human || QDELETED(human))
		return RITUAL_FAILED_ON_PROCEED
		
	if(human.stat == DEAD || !human.mind)
		to_chat(invoker, "Гуманоид должен быть жив и иметь разум.")
		return FALSE

	return TRUE

/datum/ritual/ashwalker/interrogation/do_ritual(mob/living/carbon/human/invoker)
	var/obj/effect/proc_holder/spell/empath/empath = new
	if(!empath.cast(used_things, invoker))
		return RITUAL_FAILED_ON_PROCEED

	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/interrogation/disaster(mob/living/carbon/human/invoker)
	for(var/mob/living/carbon/human/human in SSmobs.clients_by_zlevel[invoker.z])
		if(!isashwalker(human))
			continue

		if(!isturf(human.loc))
			continue

		var/turf/turf = human.loc
		to_chat(human, "<font color='red' size='7'>HONK</font>")
		SEND_SOUND(turf, sound('sound/items/airhorn.ogg'))
		human.AdjustHallucinate(150 SECONDS)
		human.EyeBlind(5 SECONDS)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(5, FALSE, turf)
		smoke.start()

	return

/datum/ritual/ashwalker/interrogation/handle_ritual_object(bitflags, silent =  FALSE)
	. = ..(bitflags, TRUE)

	switch(.)
		if(RITUAL_ENDED)
			playsound(ritual_object.loc, 'sound/effects/anvil_start.ogg', 50, TRUE)
		if(RITUAL_STARTED)
			playsound(ritual_object.loc, 'sound/effects/hulk_hit_airlock.ogg', 50, TRUE)
		if(RITUAL_FAILED)
			playsound(ritual_object.loc, 'sound/effects/forge_destroy.ogg', 50, TRUE)
			
	return .

/datum/ritual/ashwalker/creation
	name = "Creation ritual"
	cooldown_after_cast = 150 SECONDS
	shaman_only = TRUE
	extra_invokers = 2
	cast_time = 30 SECONDS
	required_things = list(
		/mob/living/carbon/human = 2
	)

/datum/ritual/ashwalker/creation/check_invokers(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/human as anything in invokers)
		if(human.stat != UNCONSCIOUS)
			disaster_prob += 20
			fail_chance += 20

	return TRUE

/datum/ritual/ashwalker/creation/check_contents(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/human in used_things)
		if(human.stat != DEAD)
			to_chat(invoker, "Гуманоиды должны быть мертвы.")
			return FALSE

		if(!isashwalker(human))
			to_chat(invoker, "Гуманоиды должны быть пеплоходцами.")
			return FALSE

	return TRUE

/datum/ritual/ashwalker/creation/do_ritual(mob/living/carbon/human/invoker)
	for(var/mob/living/mob as anything in subtypesof(/mob/living/simple_animal/hostile/asteroid))
		if(prob(30))
			mob = new(get_turf(ritual_object))

	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/creation/disaster(mob/living/carbon/human/invoker)
	for(var/mob/living/carbon/human/human in SSmobs.clients_by_zlevel[invoker.z])
		if(!isashwalker(human) || !prob(disaster_prob))
			continue

		if(!isturf(human.loc))
			continue

		human.SetKnockdown(10 SECONDS)
		var/turf/turf = human.loc
		new /obj/effect/hotspot(turf)
		turf.hotspot_expose(700, 50, 1)

	return

/datum/ritual/ashwalker/creation/handle_ritual_object(bitflags, silent =  FALSE)
	. = ..(bitflags, TRUE)

	switch(.)
		if(RITUAL_ENDED)
			playsound(ritual_object.loc, 'sound/magic/demon_consume.ogg', 50, TRUE)
		if(RITUAL_STARTED)
			playsound(ritual_object.loc, 'sound/magic/blind.ogg', 50, TRUE)
		if(RITUAL_FAILED)
			playsound(ritual_object.loc, 'sound/magic/castsummon.ogg', 50, TRUE)

	return .

/datum/ritual/ashwalker/command
	name = "Command ritual"
	cooldown_after_cast = 150 SECONDS
	shaman_only = TRUE
	disaster_prob = 35
	extra_invokers = 1
	cast_time = 30 SECONDS
	required_things = list(
		/mob/living/simple_animal = 1,
		/obj/item/organ/internal/regenerative_core = 1,
		/obj/item/reagent_containers/food/snacks/monstermeat/spiderleg = 1
	)

/datum/ritual/ashwalker/command/check_contents(mob/living/carbon/human/invoker)
	. = ..()

	if(!.)
		return FALSE

	for(var/mob/living/simple_animal/living in used_things)
		if(living.client)
			to_chat(invoker, "Существо должно быть бездушным.")
			return FALSE

		if(living.sentience_type == SENTIENCE_BOSS)
			to_chat(invoker, "Ритуал не может воздействовать на мегафауну.")
			return FALSE

		if(living.stat != DEAD)
			to_chat(invoker, "Существа должны быть мертвы.")
			return FALSE

	return TRUE

/datum/ritual/ashwalker/command/do_ritual(mob/living/carbon/human/invoker)
	var/mob/living/simple_animal/animal = locate() in used_things
	
	if(QDELETED(animal))
		return RITUAL_FAILED_ON_PROCEED

	animal.faction = invoker.faction
	animal.revive()
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за раба пеплоходцев?", ROLE_SENTIENT, TRUE, source = animal)

	if(!LAZYLEN(candidates) || QDELETED(animal)) // no travelling into nullspace
		return RITUAL_FAILED_ON_PROCEED // no mercy guys. But you got friendly creature

	var/mob/mob = pick(candidates)
	animal.key = mob.key
	animal.universal_speak = 1
	animal.sentience_act()
	animal.can_collar = 1
	animal.maxHealth = max(animal.maxHealth, 200)
	animal.del_on_death = FALSE
	animal.master_commander = invoker

	animal.mind.store_memory("<B>Мой хозяин [invoker.name], выполню [genderize_ru(invoker.gender, "его", "её", "этого", "их")] цели любой ценой!</B>")
	to_chat(animal, chat_box_green("Вы - раб пеплоходцев. Всегда подчиняйтесь и помогайте им."))
	add_game_logs("стал питомцем игрока [key_name(invoker)]", animal)

	return RITUAL_SUCCESSFUL

/datum/ritual/ashwalker/command/disaster(mob/living/carbon/human/invoker)
	for(var/mob/living/carbon/human/human in SSmobs.clients_by_zlevel[invoker.z])
		if(!isashwalker(human) || !prob(disaster_prob))
			continue

		if(!isturf(human.loc))
			continue

		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(5, FALSE, get_turf(human.loc))
		smoke.start()
		
	var/mob/living/simple_animal/mob = locate() in used_things
	qdel(mob)

	new /mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient(get_turf(ritual_object))

	return

/datum/ritual/ashwalker/command/handle_ritual_object(bitflags, silent = FALSE)
	. = ..(bitflags, TRUE)

	switch(.)
		if(RITUAL_ENDED)
			playsound(ritual_object.loc, 'sound/magic/demon_consume.ogg', 50, TRUE)
		if(RITUAL_STARTED)
			playsound(ritual_object.loc, 'sound/magic/invoke_general.ogg', 50, TRUE)
		if(RITUAL_FAILED)
			playsound(ritual_object.loc, 'sound/magic/castsummon.ogg', 50, TRUE)

	return .
	
