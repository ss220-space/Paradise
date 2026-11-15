// These can only be applied by blobs. They are what (reagent) blobs are made out of.
/datum/reagent/blob
	name = UNKNOWN_STATUS_RUS
	description = "Это не должно существовать, вам следует немедленно обратиться за помощью в adminhelp и написать баг-репорт в Discord'е."
	color = COLOR_WHITE
	taste_description = "ошибок в коде"
	penetrates_skin = TRUE
	clothing_penetration = 1
	metabolization_rate = BLOB_REAGENTS_METABOLISM


/// Used by blob reagents to calculate the reaction volume they should use when exposing mobs.
/datum/reagent/blob/proc/return_mob_expose_reac_volume(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	if(exposed_mob.stat == DEAD || HAS_TRAIT(exposed_mob, TRAIT_BLOB_ALLY))
		return FALSE //the dead, and blob mobs, don't cause reactions
	return round(reac_volume * min(1.5 - touch_protection, 1), 0.1) //full touch protection means 50% volume, any prot below 0.5 means 100% volume.

/// Exists to earmark the new overmind arg used by blob reagents.
/datum/reagent/blob/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	return ..()


/datum/reagent/blob/blazing_oil
	name = "Пылающее масло"
	id = "blob_blazing_oil"
	taste_description = "горящее масло"
	color = "#B68D00"

/datum/reagent/blob/blazing_oil/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.adjust_fire_stacks(round(reac_volume/10))
	exposed_mob.IgniteMob()
	if(exposed_mob)
		exposed_mob.apply_damage(0.8*reac_volume, BURN, forced=TRUE)
	if(iscarbon(exposed_mob))
		exposed_mob.emote("scream")


/datum/reagent/blob/cryogenic_poison
	name = "Криогенный яд"
	id = "blob_cryogenic_poison"
	description = "впрыскивает в цель замораживающий яд, который со временем наносит большой урон."
	color = "#8BA6E9"
	taste_description = "леденящего холода"

/datum/reagent/blob/cryogenic_poison/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	if(exposed_mob.reagents)
		exposed_mob.reagents.add_reagent(/datum/reagent/consumable/frostoil, 0.3*reac_volume)
		exposed_mob.reagents.add_reagent(/datum/reagent/consumable/drink/cold/ice, 0.3*reac_volume)
		exposed_mob.reagents.add_reagent(/datum/reagent/blob/cryogenic_poison, 0.3*reac_volume)
	exposed_mob.apply_damage(0.2*reac_volume, BRUTE, forced=TRUE)

/datum/reagent/blob/cryogenic_poison/on_mob_life(mob/living/carbon/affected_mob)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= affected_mob.adjustBruteLoss(0.5 * REM, updating_health = FALSE)
	update_flags |= affected_mob.adjustFireLoss(0.5 * REM, updating_health = FALSE)
	update_flags |= affected_mob.adjustToxLoss(0.5 * REM, updating_health = FALSE)
	return ..() | update_flags


/datum/reagent/blob/b_sorium
	name = "Сорий"
	id = "blob_sorium"
	taste_description = "толчков"
	color = "#B68D00"

/datum/reagent/blob/b_sorium/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.apply_damage(0.6*reac_volume, BRUTE)
	if(prob(30))
		reagent_vortex(exposed_mob, TRUE, reac_volume)

/proc/reagent_vortex(mob/living/M, setting_type, volume)
	var/turf/pull = get_turf(M)
	if(!setting_type)
		new /obj/effect/temp_visual/implosion(pull)
		playsound(pull, 'sound/effects/whoosh.ogg', 25, TRUE) //credit to Robinhood76 of Freesound.org for this.
	else
		new /obj/effect/temp_visual/shockwave_old(pull)
		playsound(pull, 'sound/effects/bang.ogg', 25, TRUE)
	var/range_power = clamp(round(volume/5, 1), 1, 5)
	for(var/atom/movable/X in range(range_power,pull))
		if(iseffect(X))
			continue
		if(X.move_resist <= MOVE_FORCE_DEFAULT && !X.anchored)
			var/distance = get_dist(X, pull)
			var/moving_power = max(range_power - distance, 1)
			spawn(0)
				if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
					if(setting_type)
						var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, pull)))
						var/throw_range = 5 - distance
						X.throw_at(throw_target, throw_range, 1)
					else
						X.throw_at(pull, distance, 1)
				else
					if(setting_type)
						for(var/i = 0, i < moving_power, i++)
							sleep(2)
							if(!step_away(X, pull))
								break
					else
						for(var/i = 0, i < moving_power, i++)
							sleep(2)
							if(!step_towards(X, pull))
								break
