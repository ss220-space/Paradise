/*
 * An element used for making a trail of effects appear behind a movable atom when it moves.
 */

/datum/element/effect_trail
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The effect used for the trail generation.
	var/chosen_effect

/datum/element/effect_trail/Attach(datum/target, chosen_effect = /obj/effect/forcefield/cosmic_field)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(generate_effect))
	src.chosen_effect = chosen_effect

/datum/element/effect_trail/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/// Generates an effect
/datum/element/effect_trail/proc/generate_effect(atom/movable/target_object)
	SIGNAL_HANDLER

	var/turf/open_turf = get_turf(target_object)
	if(istype(open_turf))
		new chosen_effect(open_turf)

// Cosmic field trail subtype which applies any passive upgrades (anti-explosion / anti-projectile) to the
// fields it lays down. Ported 1:1 from /tg/station's effect_trail/cosmic_field.
/datum/element/effect_trail/cosmic_field
	/// Whether the fields we generate disable nearby bombs.
	var/prevents_explosions = FALSE
	/// Whether the fields we generate slow projectiles passing through them.
	var/slows_projectiles = FALSE

/datum/element/effect_trail/cosmic_field/generate_effect(atom/movable/target_object)
	var/turf/open_turf = get_turf(target_object)
	if(!istype(open_turf))
		return
	var/obj/effect/forcefield/cosmic_field/new_field = new chosen_effect(open_turf)
	if(prevents_explosions)
		new_field.prevents_explosions()
	if(slows_projectiles)
		new_field.slows_projectiles()

/datum/element/effect_trail/cosmic_field/antiexplosion
	prevents_explosions = TRUE

/datum/element/effect_trail/cosmic_field/antiprojectile
	prevents_explosions = TRUE
	slows_projectiles = TRUE

/// If we are a cosmic heretic, returns the effect-trail element matching our passive level (a stargazer always
/// gets the strongest). Returns the plain trail otherwise. Mirrors /tg/station's cosmic_trail_based_on_passive.
/proc/cosmic_trail_based_on_passive(mob/living/source)
	if(istype(source, /mob/living/simple_animal/hostile/heretic_summon/star_gazer))
		return /datum/element/effect_trail/cosmic_field/antiprojectile

	var/datum/status_effect/heretic_passive/cosmic/cosmic_passive = source.has_status_effect(/datum/status_effect/heretic_passive/cosmic)
	if(!cosmic_passive)
		return /datum/element/effect_trail/cosmic_field
	if(cosmic_passive.applied_level >= 3)
		return /datum/element/effect_trail/cosmic_field/antiprojectile
	if(cosmic_passive.applied_level >= 2)
		return /datum/element/effect_trail/cosmic_field/antiexplosion
	return /datum/element/effect_trail/cosmic_field
