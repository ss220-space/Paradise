/obj/effect/proc_holder/spell/charged/beam/fire_blast
	name = "Извержение Вулкана"
	desc = "Зарядите огненную атаку, которая цепочкой охватит ближайших язычников, поджигая их. \
			Цели, которые уже горят, имеют приоритет. Если цель не загорится или \
			погаснет до передачи атаки дальше, цепочка прекратится."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "flames"
	sound = 'sound/magic/fireball.ogg'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 45 SECONDS

	invocation = "В'ЛК'Н!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	channel_time = 3 SECONDS
	target_radius = 6
	max_beam_bounces = 5

	/// How long the beam visual lasts, also used to determine time between jumps
	var/beam_duration = 2 SECONDS


/obj/effect/proc_holder/spell/charged/beam/fire_blast/valid_target(target, user)
	return ..() && isliving(target)


/obj/effect/proc_holder/spell/charged/beam/fire_blast/cast(list/targets, mob/user = usr)
	var/mob/living/target = targets[1]
	if(!istype(target))
		return ..()

	target.apply_status_effect(/datum/status_effect/fire_blasted, beam_duration, -2)
	return ..()


/obj/effect/proc_holder/spell/charged/beam/fire_blast/send_beam(atom/origin, mob/living/carbon/to_beam, bounces = 4)
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
		if(IS_HERETIC_OR_MONSTER(nearby_living) || nearby_living == action.owner)
			continue

		nearby_living.Knockdown(0.8 SECONDS)
		nearby_living.apply_damage(15, BURN/*, wound_bonus = 5*/)
		nearby_living.adjust_fire_stacks(2)
		nearby_living.IgniteMob()


/// Timer callback to continue the chain, calling send_fire_bream recursively.
/obj/effect/proc_holder/spell/charged/beam/fire_blast/proc/continue_beam(mob/living/carbon/beamed, bounces)
	if(QDELETED(beamed) || !beamed.on_fire || !beamed.has_status_effect(/datum/status_effect/fire_blasted))
		return

	var/mob/living/carbon/to_beam_next = get_target(beamed)
	if(isnull(to_beam_next)) // No target = no chain
		return

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

	/// What icon should we use for our overlay
	var/charge_overlay_icon
	/// What icon state should we use for our overlay
	var/charge_overlay_state
	/// The actual appearance / our overlay. Don't mess with this
	var/mutable_appearance/charge_overlay_instance

	/// What soundpath should we play when we start chanelling
	var/charge_sound
	/// The actual sound we generate, don't mess with this
	var/sound/charge_sound_instance


/obj/effect/proc_holder/spell/charged/Initialize(mapload)
	. = ..()
	if(!channel_message)
		channel_message = span_notice("Вы начинаете взывать к [src]...")

	if(charge_sound)
		charge_sound_instance = sound(charge_sound)

	if(charge_overlay_icon && charge_overlay_state)
		charge_overlay_instance = mutable_appearance(charge_overlay_icon, charge_overlay_state, EFFECTS_LAYER)


/obj/effect/proc_holder/spell/charged/create_new_targeting()
	return new /datum/spell_targeting/self


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

	to_chat(action.owner, span_warning("Вы уже взываете к [src]!"))
	return FALSE


/obj/effect/proc_holder/spell/charged/before_cast(list/targets, mob/user = usr)
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


/obj/effect/proc_holder/spell/charged/cast(list/targets, mob/user = usr)
	. = ..()
	var/atom/cast_on = targets[1]
	stop_channel_effect(cast_on)

/// Interrupts the chanelling effect, removing any overlay or sound playing (for the passed mob)
/obj/effect/proc_holder/spell/charged/proc/stop_channel_effect(mob/for_who)
	if(charge_overlay_instance)
		for_who.cut_overlay(charge_overlay_instance)

	if(charge_sound_instance)
		playsound(for_who, sound(null, repeat = 0), 50, FALSE)

	currently_channeling = FALSE
	if(!action)
		return

	action.UpdateButtonIcon()

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


/obj/effect/proc_holder/spell/charged/beam/before_cast(list/targets, mob/user = usr)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	var/atom/cast_on = targets[1]
	initial_target = get_target(cast_on)
	if(isnull(initial_target))
		cast_on.balloon_alert(cast_on, "нет целей!")
		stop_channel_effect(cast_on)
		return . | SPELL_CANCEL_CAST


/obj/effect/proc_holder/spell/charged/beam/cast(list/targets, mob/user = usr)
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
