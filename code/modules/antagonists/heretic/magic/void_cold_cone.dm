/obj/effect/proc_holder/spell/cone/staggered/cone_of_cold/void
	name = "Пустотный взрыв"
	desc = "Выпускает перед собой конус ледяной пустоты, замораживающий всё на своём пути. \
			Враги, оказавшиеся в конусе взрыва, получат небольшой урон, будут замедлены и со \
			временем охлаждены. Кроме того, поражённые предметы будут заморожены и могут разбиться, \
			а земля, попавшая под удар, покроется льдом и станет скользкой, \
			хотя при комнатной температуре она может быстро оттаять."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon_state = "icebeam"

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE

	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	// In room temperature, the ice won't last very long
	// ...but in space / freezing rooms, it will stick around
	turf_freeze_type = TURF_WET_ICE
	unfreeze_turf_duration = 1 MINUTES
	// Applies an "infinite" version of basic void chill
	// (This stacks with mansus grasp's void chill)
	frozen_status_effect_path = /datum/status_effect/void_chill/lasting
	unfreeze_mob_duration = 30 SECONDS
	// Does a smidge of damage
	on_freeze_brute_damage = 12
	on_freeze_burn_damage = 10
	// Also freezes stuff (Which will likely be unfrozen similarly to turfs)
	unfreeze_object_duration = 30 SECONDS


/obj/effect/proc_holder/spell/cone/staggered/cone_of_cold/void/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(IS_HERETIC_OR_MONSTER(target_mob))
		return

	return ..()


/obj/effect/proc_holder/spell/cone/staggered/cone_of_cold
	name = "Конус Холода"
	desc = "Выстреливает перед вами замораживающим конусом."

	base_cooldown = 30 SECONDS
	//cooldown_reduction_per_rank = 4 SECONDS

	invocation = "З'М'Р'ЗК!"
	invocation_type = INVOCATION_SHOUT

	cone_levels = 4
	respect_density = TRUE
	delay_between_level = 0.05 SECONDS

	/// What flags do we pass to MakeSlippery when affecting turfs?
	/// null / NONE / TURF_DRY means the turf is unaffected
	var/turf_freeze_type = TURF_WET_PERMAFROST
	/// How long do turfs remain slippery / frozen for?
	/// 0 seconds means the turf is unaffected, INFINITY means it's made perma-wet
	var/unfreeze_turf_duration = 45 SECONDS

	/// What status effect do we apply when affecting mobs?
	/// null means no status effect is applied
	var/datum/status_effect/frozen_status_effect_path = /datum/status_effect/freon/lasting
	/// How long do mobs remain frozen for?
	/// 0 seconds means no status effect is applied, INFINITY means infinite duration (or default duration of the status effect)
	var/unfreeze_mob_duration = 20 SECONDS
	/// How much brute do we apply on freeze?
	var/on_freeze_brute_damage = 10
	/// How much burn do we apply on freeze?
	var/on_freeze_burn_damage = 20

	/// How long do objects remain frozen for?
	/// 0 seconds mean no objects are frozen, INFINITY means infinite duration freeze
	var/unfreeze_object_duration = 20 SECONDS


/obj/effect/proc_holder/spell/cone/staggered/cone_of_cold/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	if(!turf_freeze_type || unfreeze_turf_duration <= 0 SECONDS) // 0 duration = don't apply the slip
		return

	if(iswallturf(target_turf))
		return

	var/turf/simulated/frozen_floor = target_turf
	frozen_floor.MakeSlippery(turf_freeze_type, unfreeze_turf_duration, permanent = (unfreeze_turf_duration == INFINITY))


/obj/effect/proc_holder/spell/cone/staggered/cone_of_cold/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(target_mob.can_block_magic(antimagic_flags) || target_mob == caster || HAS_TRAIT(target_mob, TRAIT_RESIST_COLD))
		return

	if(ispath(frozen_status_effect_path) && unfreeze_mob_duration > 0 SECONDS) // 0 duration = don't apply the status effect
		var/datum/status_effect/freeze = target_mob.apply_status_effect(frozen_status_effect_path)
		if(unfreeze_mob_duration != INFINITY)
			freeze.duration = world.time + unfreeze_mob_duration

	if(on_freeze_brute_damage || on_freeze_burn_damage)
		target_mob.take_overall_damage(on_freeze_brute_damage, on_freeze_burn_damage)

	to_chat(target_mob, span_userdanger("Вам холодно!"))


/obj/effect/proc_holder/spell/cone/staggered/cone_of_cold/do_obj_cone_effect(obj/target_obj, atom/caster, level)
	if(unfreeze_object_duration <= 0 SECONDS) // 0 duration = don't apply a freeze
		return

	if(!target_obj.freeze_add())
		return

	if(unfreeze_object_duration == INFINITY) // Infinity duration = don't set an unfreeze timer
		return

	addtimer(CALLBACK(target_obj, TYPE_PROC_REF(/obj/, unfreeze)), unfreeze_object_duration)


/**
 * ### Staggered Cone
 *
 * Staggered Cone spells will reach each cone level
 * gradually / with a delay, instead of affecting the entire
 * cone area at once.
 */
/obj/effect/proc_holder/spell/cone/staggered

	/// The delay between each cone level triggering.
	var/delay_between_level = 0.2 SECONDS


/obj/effect/proc_holder/spell/cone/staggered/make_cone(list/cone_turfs, atom/caster)
	var/level_counter = 0
	for(var/list/turf_list in cone_turfs)
		level_counter++
		addtimer(CALLBACK(src, PROC_REF(do_cone_effects), turf_list, caster, level_counter), delay_between_level * level_counter)


/**
 * ## Cone spells
 *
 * Cone spells shoot off as a cone from the caster.
 */
/obj/effect/proc_holder/spell/cone
	/// This controls how many levels the cone has. Increase this value to make a bigger cone.
	var/cone_levels = 3
	/// This value determines if the cone penetrates walls.
	var/respect_density = FALSE


/obj/effect/proc_holder/spell/cone/cast(list/targets)
	. = ..()
	var/atom/cast_on = targets[1]
	var/list/cone_turfs = get_cone_turfs(get_turf(cast_on), cast_on.dir, cone_levels)
	make_cone(cone_turfs, cast_on)


/obj/effect/proc_holder/spell/cone/proc/make_cone(list/cone_turfs, atom/caster)
	for(var/list/turf_list in cone_turfs)
		do_cone_effects(turf_list, caster)


/// This proc does obj, mob and turf cone effects on all targets in the passed list.
/obj/effect/proc_holder/spell/cone/proc/do_cone_effects(list/target_turf_list, atom/caster, level = 1)
	for(var/turf/target_turf as anything in target_turf_list)
		if(QDELETED(target_turf)) //if turf is no longer there
			continue

		do_turf_cone_effect(target_turf, caster, level)
		if(iswallturf(target_turf))
			continue

		for(var/atom/movable/movable_content as anything in target_turf)
			if(isobj(movable_content))
				do_obj_cone_effect(movable_content, caster, level)
			else if(isliving(movable_content))
				do_mob_cone_effect(movable_content, caster, level)


///This proc deterimines how the spell will affect turfs.
/obj/effect/proc_holder/spell/cone/proc/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	return


///This proc deterimines how the spell will affect objects.
/obj/effect/proc_holder/spell/cone/proc/do_obj_cone_effect(obj/target_obj, atom/caster, level)
	return


///This proc deterimines how the spell will affect mobs.
/obj/effect/proc_holder/spell/cone/proc/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	return


///This proc creates a list of turfs that are hit by the cone.
/obj/effect/proc_holder/spell/cone/proc/get_cone_turfs(turf/starter_turf, dir_to_use, cone_levels = 3)
	var/list/turfs_to_return = list()
	var/turf/turf_to_use = starter_turf
	var/turf/left_turf
	var/turf/right_turf
	var/right_dir
	var/left_dir
	switch(dir_to_use)
		if(NORTH)
			left_dir = WEST
			right_dir = EAST

		if(SOUTH)
			left_dir = EAST
			right_dir = WEST

		if(EAST)
			left_dir = NORTH
			right_dir = SOUTH

		if(WEST)
			left_dir = SOUTH
			right_dir = NORTH

	// Go though every level of the cone levels and generate the cone.
	for(var/level in 1 to cone_levels)
		var/list/level_turfs = list()
		// Our center turf always exists, it's straight ahead of the caster.
		turf_to_use = get_step(turf_to_use, dir_to_use)
		level_turfs += turf_to_use
		// Level 1 only ever has 1 turf, it's a cone.
		if(level != 1)
			var/level_width_in_each_direction = round((calculate_cone_shape(level) - 1) / 2)
			left_turf = turf_to_use
			right_turf = turf_to_use
			// Check turfs to the left...
			for(var/left_of_center in 1 to level_width_in_each_direction)
				if(respect_density && left_turf.density)
					break

				left_turf = get_step(left_turf, left_dir)
				level_turfs += left_turf

			// And turfs to the right.
			for(var/right_of_enter in 1 to level_width_in_each_direction)
				if(respect_density && right_turf.density)
					break
				right_turf = get_step(right_turf, right_dir)
				level_turfs += right_turf

		// Add the list of all turfs on this level to the turfs to return
		turfs_to_return += list(level_turfs)

		// If we're at the last level, we're done
		if(level == cone_levels)
			break
		// But if we're not at the last level, we should check that we can keep going
		if(respect_density && turf_to_use.density)
			break

	return turfs_to_return


/**
 * Adjusts the width of the cone at the passed level.
 * This is never called on the first level of the cone (level 1 is always 1 width)
 *
 * Return a number - the TOTAL width of the cone at the passed level.
 */
/obj/effect/proc_holder/spell/cone/proc/calculate_cone_shape(current_level)
	// Default formula: (1 (innate) -> 3 -> 5 -> 5 -> 7 -> 7 -> 9 -> 9 -> ...)
	return current_level + (current_level % 2) + 1
