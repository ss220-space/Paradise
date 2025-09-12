/obj/effect/proc_holder/spell/charged/beam/fire_blast
	name = "Извержение вулкана"
	desc = "Зарядите огненную атаку, которая цепочкой охватит ближайших язычников, поджигая их. \
			Цели, которые уже горят, имеют приоритет. Если цель не загорится или \
			погаснет до передачи атаки дальше, цепочка прекратится."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "flames"
	sound = 'sound/magic/fireball.ogg'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 45 SECONDS

	invocation = "V'LC'N!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	channel_time = 3 SECONDS
	target_radius = 6
	max_beam_bounces = 5

	/// How long the beam visual lasts, also used to determine time between jumps
	var/beam_duration = 2 SECONDS


/obj/effect/proc_holder/spell/charged/beam/fire_blast/valid_target(target, user)
	return ..() && isliving(target)


/obj/effect/proc_holder/spell/charged/beam/fire_blast/cast(list/targets)
	var/mob/living/target = targets[1]
	if(!istype(target))
		return ..()

	// Caster becomes fireblasted, but in a good way - heals damage over time
	target.apply_status_effect(/datum/status_effect/fire_blasted, beam_duration, -2)
	return ..()


/obj/effect/proc_holder/spell/charged/beam/fire_blast/send_beam(atom/origin, mob/living/carbon/to_beam, bounces = 4)
	// Send a beam from the origin to the hit mob
	origin.Beam(to_beam, icon_state = "solar_beam", time = beam_duration, beam_type = /obj/effect/ebeam/reacting/fire)

	// If they block the magic, the chain wont necessarily stop,
	// but likely will (due to them not catching on fire)
	if(to_beam.can_block_magic(antimagic_flags))
		to_beam.visible_message(
			span_warning("[to_beam.declent_ru(NOMINATIVE)] поглоща[pluralize_ru(to_beam.gender, "е", "ю")]т заклинание, оставаясь невредим[genderize_ru(to_beam.gender, "ым", "ой", "ым", "ыми")]!"),
			span_userdanger("Вы поглощаете заклинание, оставаясь невредимым!"),
		)
		// Apply status effect but with no overlay
		to_beam.apply_status_effect(/datum/status_effect/fire_blasted)

	// Otherwise, if unblocked apply the damage and set them up
	else
		to_beam.apply_damage(20, BURN/*, wound_bonus = 5*/)
		to_beam.adjust_fire_stacks(3)
		to_beam.IgniteMob()
		// Apply the fire blast status effect to show they got blasted
		to_beam.apply_status_effect(/datum/status_effect/fire_blasted, beam_duration * 0.5)

	// We can keep bouncing, try to continue the chain
	if(bounces >= 1)
		playsound(to_beam, sound, 50, vary = TRUE, extrarange = -1)
		// Chain continues shortly after. If they extinguish themselves in this time, the chain will stop anyways.
		addtimer(CALLBACK(src, PROC_REF(continue_beam), to_beam, bounces), beam_duration * 0.5)
		return

	playsound(to_beam, sound, 50, vary = TRUE, frequency = 12000)
	// We hit the maximum chain length, apply a bonus for managing it
	new /obj/effect/temp_visual/fire_blast_bonus(to_beam.loc)
	for(var/mob/living/nearby_living in range(1, to_beam))
		if(IS_HERETIC_OR_MONSTER(nearby_living) || nearby_living == action.owner)
			continue

		nearby_living.Knockdown(0.8 SECONDS)
		nearby_living.apply_damage(15, BURN/*, wound_bonus = 5*/)
		nearby_living.adjust_fire_stacks(2)
		nearby_living.IgniteMob()


/// Timer callback to continue the chain, calling send_fire_bream recursively.
/obj/effect/proc_holder/spell/charged/beam/fire_blast/proc/continue_beam(mob/living/carbon/beamed, bounces)
	// We will only continue the chain if we exist, are still on fire, and still have the status effect
	if(QDELETED(beamed) || !beamed.on_fire || !beamed.has_status_effect(/datum/status_effect/fire_blasted))
		return

	// We fulfilled the conditions, get the next target
	var/mob/living/carbon/to_beam_next = get_target(beamed)
	if(isnull(to_beam_next)) // No target = no chain
		return

	// Chain again! Recursively
	send_beam(beamed, to_beam_next, bounces - 1)


/// Pick a carbon mob in a radius around us that we can reach.
/// Mobs on fire will have priority and be targeted over others.
/// Returns null or a carbon mob.
/obj/effect/proc_holder/spell/charged/beam/fire_blast/get_target(atom/center)
	var/list/possibles = list()
	var/list/priority_possibles = list()
	for(var/mob/living/carbon/to_check in view(target_radius, center))
		if(to_check == action.owner)
			continue

		if(to_check.has_status_effect(/datum/status_effect/fire_blasted)) // Already blasted
			continue

		if(IS_HERETIC_OR_MONSTER(to_check))
			continue

		//if(!length(get_path_to(center, to_check, max_distance = target_radius, simulated_only = FALSE)))
		//	continue

		possibles += to_check
		if(to_check.on_fire && to_check.stat != DEAD)
			priority_possibles += to_check

	if(!length(possibles))
		return null

	return length(priority_possibles) ? pick(priority_possibles) : pick(possibles)


/**
 * Status effect applied when someone's hit by the fire blast.
 *
 * Applies an overlay, then causes a damage over time (or heal over time)
 */
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


// The beam fireblast spits out, causes people to walk through it to be on fire
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
	// Apply the fireblasted effect - no overlay
	living_entered.apply_status_effect(/datum/status_effect/fire_blasted)


// Visual effect played when we hit the max bounces
/obj/effect/temp_visual/fire_blast_bonus
	name = "fire blast"
	icon = 'icons/effects/effects.dmi'
	icon_state = "explosion"
	duration = 1 SECONDS


/**
 * ## Channelled spells
 *
 * These spells do something after a channel time.
 * To use this template, all that's needed is for cast() to be implemented.
 */
/obj/effect/proc_holder/spell/charged
	overlay_icon_state = "bg_spell_border_active_yellow"

	/// What message do we display when we start chanelling?
	var/channel_message
	/// Whether we're currently channelling / charging the spell
	var/currently_channeling = FALSE
	/// How long it takes to channel the spell.
	var/channel_time = 10 SECONDS
	/// Flags of the do_after
	var/channel_flags = DA_IGNORE_USER_LOC_CHANGE|DA_IGNORE_HELD_ITEM

	// Overlay optional, applied when we start channelling
	/// What icon should we use for our overlay
	var/charge_overlay_icon
	/// What icon state should we use for our overlay
	var/charge_overlay_state
	/// The actual appearance / our overlay. Don't mess with this
	var/mutable_appearance/charge_overlay_instance

	// Sound optional, played when we start chanelling
	/// What soundpath should we play when we start chanelling
	var/charge_sound
	/// The actual sound we generate, don't mess with this
	var/sound/charge_sound_instance


/obj/effect/proc_holder/spell/charged/New(Target, original)
	. = ..()
	if(!channel_message)
		channel_message = span_notice("You start chanelling [src]...")

	if(charge_sound)
		charge_sound_instance = sound(charge_sound)

	if(charge_overlay_icon && charge_overlay_state)
		charge_overlay_instance = mutable_appearance(charge_overlay_icon, charge_overlay_state, EFFECTS_LAYER)


/obj/effect/proc_holder/spell/charged/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom


/obj/effect/proc_holder/spell/charged/Destroy()
	if(action.owner)
		stop_channel_effect(action.owner)

	charge_overlay_instance = null
	charge_sound_instance = null
	return ..()


/obj/effect/proc_holder/spell/charged/on_spell_loss(mob/living/remove_from)
	stop_channel_effect(remove_from)
	return ..()


/obj/effect/proc_holder/spell/charged/can_cast(mob/user, charge_check, show_message)
	. = ..()
	if(!.)
		return FALSE

	if(!currently_channeling)
		return TRUE

	if(!show_message)
		return FALSE

	to_chat(action.owner, span_warning("You're already channeling [src]!"))
	return FALSE


/obj/effect/proc_holder/spell/charged/before_cast(list/targets)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	var/atom/cast_on = targets[1]
	to_chat(cast_on, channel_message)

	if(charge_sound_instance)
		playsound(cast_on, charge_sound_instance, 50, FALSE)

	if(charge_overlay_instance)
		cast_on.add_overlay(charge_overlay_instance)

	currently_channeling = TRUE
	if(action)
		action.UpdateButtonIcon()

	if(do_after(action.owner, channel_time, timed_action_flags = channel_flags))
		return

	stop_channel_effect(cast_on)
	return . | SPELL_CANCEL_CAST


/obj/effect/proc_holder/spell/charged/cast(list/targets)
	. = ..()
	var/atom/cast_on = targets[1]
	stop_channel_effect(cast_on)

/*
/obj/effect/proc_holder/spell/charged/set_statpanel_format()
	. = ..()
	if(!islist(.))
		return

	if(currently_channeling)
		.[PANEL_DISPLAY_STATUS] = "CHANNELING"
*/

/// Interrupts the chanelling effect, removing any overlay or sound playing (for the passed mob)
/obj/effect/proc_holder/spell/charged/proc/stop_channel_effect(mob/for_who)
	if(charge_overlay_instance)
		for_who.cut_overlay(charge_overlay_instance)

	if(charge_sound_instance)
		// Play a null sound in to cancel the sound playing, because byond
		playsound(for_who, sound(null, repeat = 0), 50, FALSE)

	currently_channeling = FALSE
	if(!action)
		return

	action.UpdateButtonIcon()

/**
 * ### Channelled "Beam" spells
 *
 * Channelled spells that pick a random target from nearby atoms to cast a spell on.
 * Commonly used for beams, hence the name, but nothing's stopping projectiles or whatever from working.
 *
 * If no targets are nearby, cancels the spell and refunds the cooldown.
 */
/obj/effect/proc_holder/spell/charged/beam
	/// The radius around the caster to find a target.
	var/target_radius = 5
	/// The maximum number of bounces the beam will go before stopping.
	var/max_beam_bounces = 1
	/// Who's our initial beam target? Set in before cast, used in cast.
	var/atom/initial_target


/obj/effect/proc_holder/spell/charged/beam/Destroy()
	initial_target = null // This like shouuld never hang references but I've seen some cursed things so let's be safe
	return ..()


/obj/effect/proc_holder/spell/charged/beam/before_cast(list/targets)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	var/atom/cast_on = targets[1]
	initial_target = get_target(cast_on)
	if(isnull(initial_target))
		cast_on.balloon_alert(cast_on, "no targets nearby!")
		stop_channel_effect(cast_on)
		return . | SPELL_CANCEL_CAST


/obj/effect/proc_holder/spell/charged/beam/cast(list/targets)
	. = ..()
	var/atom/cast_on = targets[1]
	send_beam(cast_on, initial_target, max_beam_bounces)
	initial_target = null


/obj/effect/proc_holder/spell/charged/beam/proc/send_beam(atom/origin, atom/to_beam, bounces)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] did not implement send_beam and either has no effects or implemented the spell incorrectly.")


/obj/effect/proc_holder/spell/charged/beam/proc/get_target(atom/center)
	var/list/things = list()
	for(var/atom/nearby_thing in range(target_radius, center))
		if(nearby_thing == action.owner || nearby_thing == center)
			continue

		things += nearby_thing

	if(!length(things))
		return null

	return pick(things)
