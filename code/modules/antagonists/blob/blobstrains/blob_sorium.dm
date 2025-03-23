
//sets you on fire, does burn damage, explodes into flame when burnt, weak to water
/datum/blobstrain/reagent/b_sorium
	name = "Сорий"
	description = "наносит высокий урон травмами и отбрасывает людей в стороны."
	effectdesc = "при попадании создает сориумный взрыв."
	analyzerdescdamage = "Наносит высокий урон травмами и отбрасывает людей в стороны."
	analyzerdesceffect = "При попадании создает сориумный взрыв."
	color = "#808000"
	complementary_color = "#a2a256"
	blobbernaut_message = "splashes"
	message = "Блоб врезается в вас и отбрасывает в сторону"
	reagent = /datum/reagent/blob/b_sorium


/datum/blobstrain/reagent/b_sorium/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(prob(damage))
		reagent_vortex(B, TRUE, damage * 0.7)
	return ..()

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
		playsound(pull, 'sound/effects/whoosh.ogg', 25, 1) //credit to Robinhood76 of Freesound.org for this.
	else
		new /obj/effect/temp_visual/shockwave(pull)
		playsound(pull, 'sound/effects/bang.ogg', 25, 1)
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


