/// How much time does it take for an organic analyzer to finish (non-carbon mobs take less time)
#define SWARMER_ANALYZE_DELAY(target) (iscarbon(target) ? 45 SECONDS : 15 SECONDS)

/// How many organic resources we get on analyzing a carbon mob
#define SWARMER_ANALYZE_CARBON_GAIN (rand(60, 80))
/// How many organic resources we get on analyzing a hostile mob (/mob/living/simple_animal/hostile)
#define SWARMER_ANALYZE_HOSTILE_GAIN (rand(15, 30))
/// How many organic resources we get on analyzing a living mob (/mob/living)
#define SWARMER_ANALYZE_LIVING_GAIN (rand(10, 20))
/// How many metallic resources we get on analyzing a carbon machine
#define SWARMER_ANALYZE_MACHINE_GAIN (rand(50, 75))
/// How many metallic resources we get on removing a robotic organ on analyzing
#define SWARMER_ANALYZE_ROBOTIC_ORGAN_GAIN 10

/// How many bodyparts or organs we take on machine analyze finish
#define SWARMER_ANALYZE_FINISH_MACHINE_TAKE 2
/// What is the chance to remove a bodypart or organ on non-machine analyze
#define SWARMER_ANALYZE_ORGAN_REMOVE_CHANCE 20

/**
 * Swarmer mob analyzer
 *
 * Allows swarmers to analyze mobs for organic resources.
 */
/obj/structure/swarmer/organic_analyzer
	name = "swarmer organic analyzer"
	desc = "Устройство \"Свармеров\", которое вырабатывает ресурсы, извлекая из живых существ некритически важные органы и части тела."
	swarmer_examine = "Анализирует живых существ. Не делает этого в открученном состоянии. Загрузка в эту машину происходит через Right Click по существу свармером."
	icon_state = "bio_analyzer"
	max_integrity = 150
	contents_pressure_protection = 1
	contents_thermal_insulation = 1
	/// Current mob in src
	var/mob/living/occupant
	/// The list of weathers we protect the occupant from.
	var/list/weather_protection = list(TRAIT_ASHSTORM_IMMUNE, TRAIT_RADSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE) // Does not protect against lava or the The Floor Is Lava spell.
	/// The contents of the gas to be distributed to an occupant. Set in Initialize()
	var/datum/gas_mixture/air_contents = null
	/// Spark system (since we use them a lot)
	var/datum/effect_system/spark_spread/spark_system
	/// Active processing sound loop
	var/datum/looping_sound/swarmer_analyzer/sound_loop
	/// Organ removal chance for non-machine carbons
	var/organ_removal_chance = SWARMER_ANALYZE_ORGAN_REMOVE_CHANCE
	/// How many bodyparts we take from machine carbons
	var/machine_organ_take = SWARMER_ANALYZE_FINISH_MACHINE_TAKE

/obj/structure/swarmer/organic_analyzer/Initialize(mapload)
	. = ..()
	add_traits(weather_protection, INNATE_TRAIT)
	refresh_air()
	sound_loop = new(src, FALSE)
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/structure/swarmer/organic_analyzer/Destroy(force)
	QDEL_NULL(air_contents)
	QDEL_NULL(spark_system)
	QDEL_NULL(sound_loop)
	if(occupant)
		occupant.forceMove(loc)
		occupant.SetParalysis(0)
		occupant.SetSleeping(10 SECONDS)
	occupant = null
	return ..()

// Restarts the analyze timer after a while
/obj/structure/swarmer/organic_analyzer/emp_act(severity)
	..()
	if(!occupant)
		return

	sound_loop.stop()
	addtimer(CALLBACK(sound_loop, TYPE_PROC_REF(/datum/looping_sound, start)), SWARMER_STRUCTURE_EMP_DURATION * severity, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)
	animate(src, transform=matrix())
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(animate_recoil), src), SWARMER_STRUCTURE_EMP_DURATION * severity, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)

	var/new_delay = SWARMER_ANALYZE_DELAY(occupant) + SWARMER_STRUCTURE_EMP_DURATION * severity
	addtimer(CALLBACK(src, PROC_REF(finish_analyzing)), new_delay, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)

	occupant.SetParalysis(new_delay + 1 SECONDS, TRUE) // Extra second just incase
	occupant.SetSleeping(new_delay + 1 SECONDS) // Extra second just incase

// Updates icon state based on occupant
/obj/structure/swarmer/organic_analyzer/update_icon_state()
	icon_state = occupant ? "[initial(icon_state)]_mob" : initial(icon_state)

/**
 * Handles loading in a mob, checks if we have any space for them.
 * Returns TRUE if we have space.
 * Returns FALSE otherwise.
 */
/obj/structure/swarmer/organic_analyzer/proc/try_load_mob(mob/living/target)
	if(!anchored)
		return FALSE
	if(occupant)
		return FALSE

	occupant = target
	var/delay = SWARMER_ANALYZE_DELAY(occupant)
	addtimer(CALLBACK(src, PROC_REF(finish_analyzing)), delay, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)
	occupant.Paralyse(delay + 1 SECONDS, TRUE) // Extra second just incase
	occupant.Sleeping(delay + 1 SECONDS) // Extra second just incase
	occupant.forceMove(src)

	spark_system.start()
	sound_loop.start()
	animate_recoil(src)
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/**
 * Callback proc from signal proc
 *
 * Deletes a random non critical bodypart/organ,
 * adjusts swarmer resources,
 * teleports the target to a safe place.
 */
/obj/structure/swarmer/organic_analyzer/proc/finish_analyzing()
	if(QDELETED(occupant))
		occupant = null
		return
	if(!(locate(occupant) in src))
		occupant = null
		return

	balloon_alert_to_viewers("обработано!")
	refresh_air()
	sound_loop.stop()
	animate(src, transform=matrix())
	take_random_organs()
	adjust_resources()
	teleport_to_safe()
	if(iscarbon(occupant))
		var/mob/living/carbon/target = occupant
		if(target.handcuffed)
			target.clear_cuffs(target.handcuffed)
	occupant = null
	update_icon(UPDATE_ICON_STATE)

/**
 * Proc used to adjust resources based on occupant mob
 *
 * Adjusts twice less from corpses.
 */
/obj/structure/swarmer/organic_analyzer/proc/adjust_resources()
	var/modifier = occupant.is_dead() ? 0.5 : 1 // We get less from corpses
	if(ismachineperson(occupant))
		return adjust_swarmer_metallic_resources(SWARMER_ANALYZE_MACHINE_GAIN * modifier)
	if(iscarbon(occupant))
		modifier = occupant.mind ? 1 : 0.3 // Much less from carbons with no mind
		return adjust_swarmer_organic_resources(SWARMER_ANALYZE_CARBON_GAIN * modifier)
	if(ishostile(occupant))
		return adjust_swarmer_organic_resources(SWARMER_ANALYZE_HOSTILE_GAIN * modifier)
	if(isliving(occupant))
		return adjust_swarmer_organic_resources(SWARMER_ANALYZE_LIVING_GAIN * modifier)

/**
 * Proc used to get rid of random bodyparts and organs
 *
 * Removes [machine_organ_take] bodyparts from machine carbons, removes
 * safe to remove organs and bodyparts from other carbons with a chance one by one.
 *
 * Adjusts metallic resources if there was
 * a robotic organ removed on non-machine analyze.
 */
/obj/structure/swarmer/organic_analyzer/proc/take_random_organs()
	if(!ishuman(occupant))
		return
	var/mob/living/carbon/human/target = occupant
	if(ismachineperson(target)) // Machine handling
		var/removed_amount = 0
		while(removed_amount < machine_organ_take)
			var/obj/item/organ/external/bodypart = pick(target.bodyparts)
			if(ischest(bodypart) || isgroin(bodypart))
				continue
			removed_amount += 1
			var/atom/movable/thing = bodypart.remove(target)
			if(!QDELETED(thing))
				qdel(thing)
		target.UpdateAppearance()
		return
	for(var/obj/item/organ/external/bodypart as anything in target.bodyparts) // Non machine handling
		if(isgroin(bodypart)) // groin gets skipped
			continue
		if(ischest(bodypart)) // Liver, kidneys
			var/list/organ_list = target.get_organs_zone(BODY_ZONE_CHEST)
			for(var/obj/item/organ/internal/organ as anything in organ_list)
				if(!istype(organ, /obj/item/organ/internal/liver) && !istype(organ, /obj/item/organ/internal/kidneys))
					continue
				if(!prob(organ_removal_chance))
					continue
				if(organ.is_robotic())
					adjust_swarmer_metallic_resources(SWARMER_ANALYZE_ROBOTIC_ORGAN_GAIN)
				var/atom/movable/thing = organ.remove(target)
				if(!QDELETED(thing))
					qdel(thing)
			continue
		if(ishead(bodypart)) // Eyes, ears
			var/list/organ_list = target.get_organs_zone(BODY_ZONE_HEAD)
			for(var/obj/item/organ/internal/organ as anything in organ_list)
				if(!istype(organ, /obj/item/organ/internal/eyes) && !istype(organ, /obj/item/organ/internal/ears))
					continue
				if(!prob(organ_removal_chance))
					continue
				if(organ.is_robotic())
					adjust_swarmer_metallic_resources(SWARMER_ANALYZE_ROBOTIC_ORGAN_GAIN)
				var/atom/movable/thing = organ.remove(target)
				if(!QDELETED(thing))
					qdel(thing)
			continue
		if(!prob(organ_removal_chance)) // / Arms, legs, tails, wings
			continue
		if(!bodypart.owner) // Trying to remove removed bodypart child, and thats bad
			continue
		if(bodypart.is_robotic())
			adjust_swarmer_metallic_resources(SWARMER_ANALYZE_ROBOTIC_ORGAN_GAIN)
		var/atom/movable/thing = bodypart.remove(target)
		if(!QDELETED(thing))
			qdel(thing)
	target.UpdateAppearance()

/// Proc used to get rid of the occupant (teleport it to a safe place)
/obj/structure/swarmer/organic_analyzer/proc/teleport_to_safe()
	var/turf/safe_turf = find_safe_turf(z)
	if(!safe_turf)
		occupant.forceMove(loc)
		return
	playsound(src, 'sound/effects/sparks4.ogg', 50, TRUE)
	occupant.SetSleeping(5 SECONDS)
	do_teleport(occupant, safe_turf)

/obj/structure/swarmer/organic_analyzer/return_obj_air()
	return air_contents

/obj/structure/swarmer/organic_analyzer/return_analyzable_air()
	return air_contents

/// Refreshes air_contents variable after each occupant
/obj/structure/swarmer/organic_analyzer/proc/refresh_air()
	air_contents = null
	air_contents = new
	air_contents.set_temperature(T20C)
	air_contents.volume = 50

	air_contents.set_oxygen(O2STANDARD * ONE_ATMOSPHERE * 50 / (R_IDEAL_GAS_EQUATION * T20C))
	air_contents.set_nitrogen(N2STANDARD * ONE_ATMOSPHERE * 50 / (R_IDEAL_GAS_EQUATION * T20C))

/obj/structure/swarmer/organic_analyzer/swarmer_grab_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	if(!occupant)
		return ..()

	swarmer.balloon_alert(swarmer, "не открутить, работает!")
	return FALSE

/obj/structure/swarmer/organic_analyzer/get_ru_names()
	return alist(
		NOMINATIVE = "анализатор \"Свармеров\"",
		GENITIVE = "анализатора \"Свармеров\"",
		DATIVE = "анализатору \"Свармеров\"",
		ACCUSATIVE = "анализатор \"Свармеров\"",
		INSTRUMENTAL = "анализатором \"Свармеров\"",
		PREPOSITIONAL = "анализаторе \"Свармеров\""
	)

#undef SWARMER_ANALYZE_DELAY
#undef SWARMER_ANALYZE_CARBON_GAIN
#undef SWARMER_ANALYZE_HOSTILE_GAIN
#undef SWARMER_ANALYZE_LIVING_GAIN
#undef SWARMER_ANALYZE_MACHINE_GAIN
#undef SWARMER_ANALYZE_ROBOTIC_ORGAN_GAIN
#undef SWARMER_ANALYZE_FINISH_MACHINE_TAKE
#undef SWARMER_ANALYZE_ORGAN_REMOVE_CHANCE
