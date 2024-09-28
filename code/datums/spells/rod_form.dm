/// The base distance a wizard rod will go without upgrades.
#define BASE_WIZ_ROD_RANGE 15

/obj/effect/proc_holder/spell/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path."
	clothes_req = TRUE
	human_req = FALSE
	base_cooldown = 1 MINUTES
	cooldown_min = 20 SECONDS
	invocation = "CLANG!"
	invocation_type = "shout"
	action_icon_state = "immrod"
	centcom_cancast = FALSE
	sound = 'sound/effects/whoosh.ogg'
	/// The max distance the rod goes on cast
	var/rod_max_distance = BASE_WIZ_ROD_RANGE
	/// Rod speed
	var/rod_delay = 2


/obj/effect/proc_holder/spell/rod_form/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/rod_form/cast(list/targets, mob/user = usr)
	var/turf/start = get_turf(user)
	if(!start || start != user.loc)
		to_chat(user, span_warning("You cannot summon a rod in the ether, the spell fizzles out!"))
		revert_cast()
		return FALSE

	var/flight_dist = rod_max_distance + spell_level * 3
	var/turf/distant_turf = get_ranged_target_turf(start, user.dir, flight_dist)
	new /obj/effect/immovablerod/wizard(start, distant_turf, null, rod_delay, FALSE, user, flight_dist)


/**
 * Wizard Version of the Immovable Rod
 */
/obj/effect/immovablerod/wizard
	notify = FALSE
	/// The wizard who's piloting our rod.
	var/mob/living/wizard
	/// The distance the rod will go.
	var/max_distance = BASE_WIZ_ROD_RANGE
	/// The turf the rod started from, to calcuate distance.
	var/turf/start_turf


/obj/effect/immovablerod/wizard/Initialize(mapload, atom/target_atom, atom/specific_target, move_delay = 1, force_looping = FALSE, mob/living/wizard, max_distance = BASE_WIZ_ROD_RANGE)
	. = ..()
	if(wizard)
		set_wizard(wizard)
	src.start_turf = get_turf(src)
	src.max_distance = max_distance


/obj/effect/immovablerod/wizard/Destroy(force)
	start_turf = null
	if(wizard)
		eject_wizard()
	return ..()


/obj/effect/immovablerod/wizard/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(get_dist(start_turf, get_turf(src)) >= max_distance)
		qdel(src)
		return
	return ..()


/// Should never happen, but better safe than sorry
/obj/effect/immovablerod/wizard/penetrate(mob/living/smeared_mob)
	if(smeared_mob == wizard)
		return
	return ..()


/**
 * Set wizard as our_wizard, placing them in the rod
 * and preparing them for travel.
 */
/obj/effect/immovablerod/wizard/proc/set_wizard(mob/living/wizard)
	setDir(wizard.dir)
	src.wizard = wizard
	wizard.forceMove(src)
	wizard.add_traits(list(TRAIT_GODMODE, TRAIT_NO_TRANSFORM), UNIQUE_TRAIT_SOURCE(src))


/**
 * Eject our current wizard, removing them from the rod
 * and fixing all of the variables we changed.
 */
/obj/effect/immovablerod/wizard/proc/eject_wizard()
	if(QDELETED(wizard))
		wizard = null
		return
	wizard.remove_traits(list(TRAIT_GODMODE, TRAIT_NO_TRANSFORM), UNIQUE_TRAIT_SOURCE(src))
	wizard.forceMove(get_turf(src))
	wizard = null


#undef BASE_WIZ_ROD_RANGE

