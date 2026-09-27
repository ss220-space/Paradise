/datum/action/cooldown/spell/charged/beam/fire_blast
	name = "Извержение Вулкана"
	desc = "Зарядите огненную атаку, которая цепочкой охватит ближайших язычников, поджигая их. \
			Цели, которые уже горят, имеют приоритет. Если цель не загорится или \
			погаснет до передачи атаки дальше, цепочка прекратится."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "flames"
	sound = 'sound/magic/fireball.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS

	invocation = "В'ЛК'Н!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	channel_time = 3 SECONDS
	target_radius = 6
	max_beam_bounces = 5

	/// How long the beam visual lasts, also used to determine time between jumps
	var/beam_duration = 2 SECONDS


/datum/action/cooldown/spell/charged/beam/fire_blast/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on)


/datum/action/cooldown/spell/charged/beam/fire_blast/cast(atom/cast_on)
	var/mob/living/target = cast_on
	if(!istype(target))
		return ..()

	target.apply_status_effect(/datum/status_effect/fire_blasted, beam_duration, -2)
	return ..()


/datum/action/cooldown/spell/charged/beam/fire_blast/send_beam(atom/origin, mob/living/carbon/to_beam, bounces = 4)
	origin.Beam(to_beam, icon_state = "solar_beam", time = beam_duration, beam_type = /obj/effect/ebeam/reacting/fire)

	if(to_beam.can_block_magic(antimagic_flags))
		to_beam.visible_message(
			span_warning("[DECLENT_RU_CAP(to_beam, NOMINATIVE)] поглоща[PLUR_ET_YUT(to_beam)] заклинание, оставаясь невредим[GEND_YM_OI_YM_YMI(to_beam)]!"),
			span_userdanger("Вы поглощаете заклинание, оставаясь невредимым!"),
		)
		to_beam.apply_status_effect(/datum/status_effect/fire_blasted)

	else
		to_beam.apply_damage(20, BURN/*, wound_bonus = 5*/)
		to_beam.adjust_fire_stacks(3)
		to_beam.IgniteMob()
		to_beam.apply_status_effect(/datum/status_effect/fire_blasted, beam_duration * 0.5)

	if(bounces >= 1)
		playsound(to_beam, sound, 50, vary = TRUE, extrarange = -1)
		addtimer(CALLBACK(src, PROC_REF(continue_beam), to_beam, bounces), beam_duration * 0.5)
		return

	playsound(to_beam, sound, 50, vary = TRUE, frequency = 12000)
	new /obj/effect/temp_visual/fire_blast_bonus(to_beam.loc)
	for(var/mob/living/nearby_living in range(1, to_beam))
		if(IS_HERETIC_OR_MONSTER(nearby_living) || nearby_living == owner)
			continue

		nearby_living.Knockdown(0.8 SECONDS)
		nearby_living.apply_damage(15, BURN/*, wound_bonus = 5*/)
		nearby_living.adjust_fire_stacks(2)
		nearby_living.IgniteMob()


/// Timer callback to continue the chain, calling send_fire_bream recursively.
/datum/action/cooldown/spell/charged/beam/fire_blast/proc/continue_beam(mob/living/carbon/beamed, bounces)
	if(QDELETED(beamed) || !beamed.on_fire || !beamed.has_status_effect(/datum/status_effect/fire_blasted))
		return

	var/mob/living/carbon/to_beam_next = get_target(beamed)
	if(isnull(to_beam_next)) // No target = no chain
		return

	send_beam(beamed, to_beam_next, bounces - 1)


/// Pick a carbon mob in a radius around us that we can reach.
/// Mobs on fire will have priority and be targeted over others.
/// Returns null or a carbon mob.
/datum/action/cooldown/spell/charged/beam/fire_blast/get_target(atom/center)
	var/list/possibles = list()
	var/list/priority_possibles = list()
	for(var/mob/living/carbon/to_check in view(target_radius, center))
		if(to_check == owner)
			continue

		if(to_check.has_status_effect(/datum/status_effect/fire_blasted)) // Already blasted
			continue

		if(IS_HERETIC_OR_MONSTER(to_check))
			continue


		possibles += to_check
		if(to_check.on_fire && to_check.stat != DEAD)
			priority_possibles += to_check

	if(!length(possibles))
		return null

	return length(priority_possibles) ? pick(priority_possibles) : pick(possibles)


/datum/status_effect/fire_blasted
	id = "fire_blasted"
	alert_type = null
	duration = 5 SECONDS
	tick_interval = 0.5 SECONDS
	/// How much fire / stam to do per tick (stamina damage is doubled this)
	var/tick_damage = 1
	/// How long does the animation of the appearance last? If 0 or negative, we make no overlay
	var/animate_duration = 0.75 SECONDS


/datum/status_effect/fire_blasted/on_creation(mob/living/new_owner, animate_duration = -1, tick_damage = 1)
	src.animate_duration = animate_duration
	src.tick_damage = tick_damage
	return ..()


/datum/status_effect/fire_blasted/on_apply()
	if(owner.on_fire && animate_duration > 0 SECONDS)
		var/mutable_appearance/warning_sign = mutable_appearance('icons/effects/effects.dmi', "blessed", BELOW_MOB_LAYER)
		var/atom/movable/flick_visual/warning = owner.flick_overlay_view(warning_sign, initial(duration))
		warning.alpha = 50
		animate(warning, alpha = 255, time = animate_duration)

	return TRUE


/datum/status_effect/fire_blasted/tick(seconds_between_ticks)
	owner.adjustFireLoss(tick_damage * seconds_between_ticks)
	owner.adjustStaminaLoss(2 * tick_damage * seconds_between_ticks)


/obj/effect/ebeam/reacting/fire
	name = "fire beam"


/obj/effect/ebeam/reacting/fire/beam_entered(atom/movable/entered)
	. = ..()
	if(!isliving(entered))
		return

	var/mob/living/living_entered = entered
	if(IS_HERETIC_OR_MONSTER(living_entered) || living_entered.has_status_effect(/datum/status_effect/fire_blasted))
		return

	living_entered.apply_damage(10, BURN/*, wound_bonus = 5*/)
	living_entered.adjust_fire_stacks(2)
	living_entered.IgniteMob()
	living_entered.apply_status_effect(/datum/status_effect/fire_blasted)


/obj/effect/temp_visual/fire_blast_bonus
	name = "fire blast"
	icon_state = "explosion"
