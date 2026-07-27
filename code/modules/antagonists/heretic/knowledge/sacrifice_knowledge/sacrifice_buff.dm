
/// Screen alert for the below status effect.
/atom/movable/screen/alert/status_effect/unholy_determination
	name = "Нечестивая Решимость"
	desc = "Где вы вообще находитесь? Тьма сгущается. Паника растет. Времени нет. Сражайтесь или умрите!"
	icon_state = "wounded"


/// The buff given to people within the shadow realm to assist them in surviving.
/datum/status_effect/unholy_determination
	id = "unholy_determination"
	duration = 3 MINUTES // Given a default duration so no one gets to hold onto this buff forever by accident.
	alert_type = /atom/movable/screen/alert/status_effect/unholy_determination
	/// How much to heal every second
	var/heal_per_second = 0.25


/datum/status_effect/unholy_determination/on_creation(mob/living/new_owner, set_duration)
	if(!isnum(set_duration))
		return ..()

	duration = set_duration
	return ..()


/datum/status_effect/unholy_determination/on_apply()
	owner.add_traits(list(TRAIT_NOCRITDAMAGE), TRAIT_STATUS_EFFECT(id))
	return TRUE


/datum/status_effect/unholy_determination/on_remove()
	owner.remove_traits(list(TRAIT_NOCRITDAMAGE), TRAIT_STATUS_EFFECT(id))


/datum/status_effect/unholy_determination/tick(seconds_between_ticks)
	var/healing_amount = (heal_per_second * seconds_between_ticks) + (heal_per_second * (2 - owner.usable_legs))

	if(owner.health <= HEALTH_THRESHOLD_CRIT && owner.health >= HEALTH_THRESHOLD_DEAD)
		if(prob(5))
			to_chat(owner, span_purple("Ваше тело готово сдаться, но вы продолжаете бороться!"))

		healing_amount *= 2

	if(owner.health < HEALTH_THRESHOLD_DEAD)
		if(prob(5))
			to_chat(owner, span_big(span_purple("Вы долго не протяните...")))

		healing_amount *= -0.5

	if(owner.health > HEALTH_THRESHOLD_CRIT && prob(4))
		owner.Jitter(20 SECONDS)
		owner.Dizzy(10 SECONDS)
		owner.Hallucinate(6 SECONDS, 48 SECONDS)

	if(prob(2))
		playsound(owner, pick(GLOB.creepy_ambience), 50, TRUE)

	adjust_all_damages(healing_amount, seconds_between_ticks)
	adjust_temperature(seconds_between_ticks)
	adjust_bleed_wounds(seconds_between_ticks)


/// Heals up all the owner a bit, fire stacks and losebreath included.
/datum/status_effect/unholy_determination/proc/adjust_all_damages(amount, seconds_between_ticks)

	owner.adjust_fire_stacks(-1)

	var/damage_healed = 0
	damage_healed += owner.adjustToxLoss(-amount, updating_health = FALSE, forced = TRUE)
	damage_healed += owner.adjustOxyLoss(-amount, updating_health = FALSE)
	damage_healed += owner.adjustBruteLoss(-amount, updating_health = FALSE)
	damage_healed += owner.adjustFireLoss(-amount, updating_health = FALSE)
	if(damage_healed <= 0)
		return

	owner.updatehealth()


/// Adjust the owner's temperature up or down to standard body temperatures.
/datum/status_effect/unholy_determination/proc/adjust_temperature(seconds_between_ticks)
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/human_owner = owner
	var/target_temp = human_owner.dna.species.body_temperature
	if(owner.bodytemperature > target_temp)
		owner.adjust_bodytemperature(-50 * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_between_ticks, target_temp)
	else if(owner.bodytemperature < (target_temp + 1))
		owner.adjust_bodytemperature(50 * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_between_ticks, target_temp)
/*
	if(human_owner.coretemperature > target_temp)
		human_owner.adjust_coretemperature(-50 * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_between_ticks, target_temp)
	else if(human_owner.coretemperature < (target_temp + 1))
		human_owner.adjust_coretemperature(50 * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_between_ticks, 0, target_temp)
*/

/// Slow and stop any blood loss the owner's experiencing.
/datum/status_effect/unholy_determination/proc/adjust_bleed_wounds(seconds_between_ticks)
	if(!ishuman(owner) || !owner.blood_volume)
		return

	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume = owner.blood_volume + (2 * seconds_between_ticks)

	if(!prob(20))
		return

	var/mob/living/carbon/human/human_owner = owner
	for(var/obj/item/organ/external/bodypart as anything in human_owner.bodyparts)
		if(!bodypart.has_internal_bleeding())
			continue

		bodypart.stop_internal_bleeding()
		return


/// Torment the target with a frightening hand
/proc/fire_curse_hand(mob/living/carbon/victim, turf/forced_turf, range = 8, projectile_type = /obj/projectile/curse_hand/hel)
	var/grab_dir = turn(victim.dir, pick(-90, 90, 180, 180)) // Not in front, favour behind
	var/turf/spawn_turf = get_freeway_ranged_target_turf(victim, grab_dir, range, 2)
	for(var/dir in GLOB.cardinal)
		if(spawn_turf)
			break

		spawn_turf = get_freeway_ranged_target_turf(victim, dir, range, 2)

	spawn_turf = forced_turf ? forced_turf : spawn_turf
	if(isnull(spawn_turf))
		return

	new /obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, victim.dir)
	playsound(spawn_turf, 'sound/effects/curse/curse2.ogg', 80, TRUE, -1)
	var/obj/projectile/hand = new projectile_type(spawn_turf)
	hand.preparePixelProjectile(victim, spawn_turf)
	if(QDELETED(hand)) // stack_trace already fired above if this failed
		return

	hand.fire()

/datum/reagent/inverse
	name = "Inverse reagent"
	id = "inverse"
	description = "An inverted reagent effect."

/datum/reagent/inverse/helgrasp
	name = "Helgrasp"
	id = "helgrasp"
	description = "A forbidden drink that calls grasping hands from beyond."
	reagent_state = LIQUID
	color = "#5d0f75"
	taste_description = "ice and old dust"
	metabolization_rate = 1 * REM
	var/list/timer_ids

/datum/reagent/inverse/helgrasp/on_mob_add(mob/living/carbon/human/user)
	. = ..()
	to_chat(user, span_hierophant("Вы слышите смех, когда перед вами появляются жуткие руки, жаждущие утащить вас в ад! Берегитесь!"))
	playsound(user.loc, 'sound/effects/ahaha.ogg', 80, TRUE, -1)

/datum/reagent/inverse/helgrasp/on_mob_life(mob/living/M)
	. = ..()
	if(!iscarbon(M))
		return
	var/mob/living/carbon/affected_mob = M
	spawn_hands(affected_mob)
	LAZYADD(timer_ids, addtimer(CALLBACK(src, PROC_REF(spawn_hands), affected_mob), 1 SECONDS, TIMER_STOPPABLE))

/datum/reagent/inverse/helgrasp/proc/spawn_hands(mob/living/carbon/affected_mob)
	if(!affected_mob && iscarbon(holder?.my_atom))
		affected_mob = holder.my_atom
	if(!affected_mob)
		return
	fire_curse_hand(affected_mob)

/datum/reagent/inverse/helgrasp/on_mob_delete(mob/living/carbon/human/user)
	. = ..()
	clear_hand_timers()

/datum/reagent/inverse/helgrasp/Destroy()
	clear_hand_timers()
	return ..()

/datum/reagent/inverse/helgrasp/proc/clear_hand_timers()
	for(var/timer_id in timer_ids)
		deltimer(timer_id)
	timer_ids = null

/datum/reagent/inverse/helgrasp/heretic
	name = "Хватка Обители"
	id = "mansus_touch"
	description = "Чья-то рука у вашего горла..."
