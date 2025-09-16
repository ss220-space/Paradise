/obj/effect/proc_holder/spell/jaunt/mirror_walk
	name = "По ту сторону зеркал"
	desc = "Позволяет вам незаметно и свободно перемещаться по станции в пределах зеркального мира. \
			Вы можете входить и выходить из зеркального мира только при наличии рядом отражающих \
			поверхностей и предметов, таких как окна, зеркала, отражающие стены или оборудование."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "ninja_cloak"

	base_cooldown = 6 SECONDS
	jaunt_type = /obj/effect/dummy/spell_jaunt/mirror_walk
	clothes_req = FALSE
	human_req = FALSE
	nonabstract_req = FALSE
	phase_allowed = TRUE
	/// The time it takes to enter the mirror / phase out / enter jaunt.
	var/phase_out_time = 1.5 SECONDS
	/// The time it takes to exit a mirror / phase in / exit jaunt.
	var/phase_in_time = 2 SECONDS
	/// Static typecache of types that are counted as reflective.
	var/static/list/special_reflective_surfaces = typecacheof(list(
		/obj/structure/window,
		/obj/structure/mirror,
	))


/obj/effect/proc_holder/spell/jaunt/mirror_walk/on_spell_gain(mob/user = usr)
	. = ..()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))


/obj/effect/proc_holder/spell/jaunt/mirror_walk/on_spell_loss(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOVABLE_MOVED)


/obj/effect/proc_holder/spell/jaunt/mirror_walk/can_cast(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE

	var/turf/owner_turf = get_turf(action.owner)
	if(!is_reflection_nearby(get_turf(owner_turf)))
		if(!feedback)
			return FALSE

		to_chat(action.owner, span_warning("Рядом нет отражающих поверхностей!"))
		return FALSE

	if(owner_turf.is_blocked_turf(exclude_mobs = TRUE))
		if(!feedback)
			return FALSE

		to_chat(action.owner, span_warning("Что-то не даёт вам перейти через отражение!"))
		return FALSE

	return TRUE


/obj/effect/proc_holder/spell/jaunt/mirror_walk/cast(list/targets)
	var/mob/living/cast_on = targets[1]
	. = ..()
	if(is_jaunting(cast_on))
		return exit_jaunt(cast_on)
	else
		return enter_jaunt(cast_on)


/obj/effect/proc_holder/spell/jaunt/mirror_walk/enter_jaunt(mob/living/jaunter, turf/loc_override)
	var/atom/nearby_reflection = is_reflection_nearby(jaunter)
	if(!nearby_reflection)
		to_chat(jaunter, span_warning("Рядом нет отражающих поверхностей, через которые можно было бы войти в зеркальный мир!"))
		return

	jaunter.Beam(nearby_reflection, icon_state = "light_beam", time = phase_out_time)
	nearby_reflection.visible_message(span_warning("[nearby_reflection.declent_ru(NOMINATIVE)] начинает светиться и слегка дрожать!"))
	if(!do_after(jaunter, phase_out_time, nearby_reflection, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_USER_LOC_CHANGE|DA_IGNORE_INCAPACITATED))
		return

	playsound(jaunter, 'sound/magic/ethereal_enter.ogg', 50, TRUE, -1)
	jaunter.visible_message(
		span_boldwarning("[jaunter.declent_ru(NOMINATIVE)] пропадает из реальности прямо на ваших глазах!"),
		span_notice("Вы прыгаете в отражение в [nearby_reflection.declent_ru(PREPOSITIONAL)], попадая в зеркальный мир."),
	)

	// Pass the turf of the nearby reflection to the parent call
	// as that's the location we're actually jaunting into
	var/obj/effect/dummy/spell_jaunt/jaunt = ..(jaunter, get_turf(nearby_reflection))
	if(!jaunt)
		return FALSE

	RegisterSignal(jaunt, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))
	return jaunt


/obj/effect/proc_holder/spell/jaunt/mirror_walk/exit_jaunt(mob/living/unjaunter, turf/loc_override)
	var/turf/phase_turf = get_turf(unjaunter)
	var/atom/nearby_reflection = is_reflection_nearby(phase_turf)
	if(!nearby_reflection)
		to_chat(unjaunter, span_warning("Рядом нет отражающих поверхностей, через которые можно было бы выйти из зеркального мира!"))
		return FALSE

	nearby_reflection.Beam(phase_turf, icon_state = "light_beam", time = phase_in_time)
	nearby_reflection.visible_message(span_warning(span_warning("[nearby_reflection.declent_ru(NOMINATIVE)] начинает светиться и слегка дрожать!")))
	if(!do_after(unjaunter, phase_in_time, nearby_reflection))
		return FALSE

	// We can move around while phasing in, but we'll always end up where we started it.
	// Pass the jaunter's turf at the start of the proc back to the parent call.
	return ..(unjaunter, phase_turf)


// Play a spooky noise, provide textual feedback, and make the turf colder.
/obj/effect/proc_holder/spell/jaunt/mirror_walk/on_jaunt_exited(obj/effect/dummy/spell_jaunt/jaunt, mob/living/unjaunter)
	. = ..()
	UnregisterSignal(jaunt, COMSIG_MOVABLE_MOVED)
	playsound(unjaunter, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	var/turf/simulated/phase_turf = get_turf(unjaunter)

	// Chilly!
	if(is_space_or_openspace(phase_turf))
		phase_turf.air.temperature = max(0, phase_turf.air.temperature - 20)

	var/atom/nearby_reflection = is_reflection_nearby(phase_turf)
	if(!nearby_reflection) // Should only be true if you're forced out somehow, like by having the spell removed
		return

	unjaunter.visible_message(
		span_boldwarning("[unjaunter.declent_ru(NOMINATIVE)] воплощается в реальность прямо на ваших глазах!"),
		span_notice("Вы выпрыгиваете из отражения в [nearby_reflection.declent_ru(PREPOSITIONAL)], покидая зеркальный мир."),
	)

/**
 * Goes through all nearby atoms in sight of the
 * passed caster and determines if they are "reflective"
 * for the purpose of us being able to utilize it to enter or exit.
 *
 * Returns an object reference to a "reflective" object in view if one was found,
 * or null if no object was found that was determined to be "reflective".
 */
/obj/effect/proc_holder/spell/jaunt/mirror_walk/proc/is_reflection_nearby(atom/caster)
	for(var/atom/thing as anything in view(2, caster))
		if(isitem(thing))
			var/obj/item/item_thing = thing
			if(item_thing.IsReflect())
				return thing

		if(ishuman(thing))
			var/mob/living/carbon/human/human_thing = thing
			if(human_thing.check_reflect())
				return thing

		if(isturf(thing))
			var/turf/turf_thing = thing
			if(turf_thing.turf_flags & NOJAUNT)
				continue

			if(turf_thing.flags_ricochet & RICOCHET_SHINY)
				return thing

		if(is_type_in_typecache(thing, special_reflective_surfaces))
			return thing

	return null


/obj/effect/dummy/spell_jaunt/mirror_walk
	name = "reflection"
