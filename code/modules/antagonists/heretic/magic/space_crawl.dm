#define SPACE_PHASING "space-phasing"

/**
 * ### Space Crawl
 *
 * Lets the caster enter and exit tiles of space or misc turfs.
 */
/obj/effect/proc_holder/spell/jaunt/space_crawl
	name = "Космический сдвиг"
	desc = "Позволяет вам появляться и исчезать из реальности, находясь в космосе или на \
			открытом воздухе с низким давлением. Для возвращения, место прибытия тоже должно быть таковым."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "space_crawl"

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	clothes_req = FALSE
	human_req = FALSE
	phase_allowed = TRUE
	base_cooldown = 5 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	jaunt_type = /obj/effect/dummy/spell_jaunt/space
	///List of traits that are added to the heretic while in space phase jaunt
	var/static/list/jaunting_traits = list(TRAIT_RESIST_COLD, TRAIT_RESIST_COLD, TRAIT_NO_BREATH)


/obj/effect/proc_holder/spell/jaunt/space_crawl/on_spell_gain(mob/user = usr)
	. = ..()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))


/obj/effect/proc_holder/spell/jaunt/space_crawl/on_spell_loss(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOVABLE_MOVED)


/obj/effect/proc_holder/spell/jaunt/space_crawl/can_cast(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	var/turf/my_turf = get_turf(action.owner)
	if(isspaceturf(my_turf))
		return TRUE

	var/area/my_area = get_area(action.owner)
	if(is_space_or_openspace(my_turf) || my_area.outdoors && lavaland_equipment_pressure_check(my_turf))
		return TRUE

	return FALSE


/obj/effect/proc_holder/spell/jaunt/space_crawl/cast(list/targets)
	var/mob/living/cast_on = targets[1]
	. = ..()
	// Should always return something because we checked that in can_cast before arriving here
	var/turf/our_turf = get_turf(cast_on)
	do_spacecrawl(our_turf, cast_on)


/**
 * Attempts to enter or exit the passed space or misc turf.
 * Returns TRUE if we successfully entered or exited said turf, FALSE otherwise
 */
/obj/effect/proc_holder/spell/jaunt/space_crawl/proc/do_spacecrawl(turf/our_turf, mob/living/jaunter)
	if(is_jaunting(jaunter))
		. = try_exit_jaunt(our_turf, jaunter)
	else
		. = try_enter_jaunt(our_turf, jaunter)

	if(.)
		return

	//reset_spell_cooldown()
	cooldown_handler.start_recharge()
	to_chat(jaunter, span_warning("Вы не можете это сделать!"))


/**
 * Attempts to enter the passed space or misc turfs.
 */
/obj/effect/proc_holder/spell/jaunt/space_crawl/proc/try_enter_jaunt(turf/our_turf, mob/living/jaunter)
	// Begin the jaunt
	ADD_TRAIT(jaunter, TRAIT_NO_TRANSFORM, UID())
	var/obj/effect/dummy/spell_jaunt/holder = enter_jaunt(jaunter, our_turf)
	if(isnull(holder))
		REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, UID())
		return FALSE

	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))
	if(iscarbon(jaunter))
		jaunter.drop_all_held_items()
		// Sanity check to ensure we didn't lose our focus as a result.
		if(!HAS_TRAIT(jaunter, TRAIT_ALLOW_HERETIC_CASTING))
			REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, UID())
			exit_jaunt(jaunter, our_turf)
			return FALSE

		// Give them some space hands to prevent them from doing things
		var/obj/item/space_crawl/left_hand = new(jaunter)
		var/obj/item/space_crawl/right_hand = new(jaunter)
		left_hand.icon_state = "spacehand_right" // Icons swapped intentionally..
		right_hand.icon_state = "spacehand_left" // ..because perspective, or something
		jaunter.put_in_hands(left_hand)
		jaunter.put_in_hands(right_hand)

	jaunter.add_traits(jaunting_traits, SPACE_PHASING)
	RegisterSignal(jaunter, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_lost), override = TRUE)
	playsound(our_turf, 'sound/magic/cosmic_energy.ogg', 50, TRUE, -1)
	our_turf.visible_message(span_warning("[jaunter.declent_ru(NOMINATIVE)] погружается в [our_turf.declent_ru(ACCUSATIVE)]!"))
	new /obj/effect/temp_visual/space_explosion(our_turf)
	jaunter.ExtinguishMob()

	REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, UID())
	return TRUE

/**
 * Attempts to Exit the passed space or misc turf.
 */
/obj/effect/proc_holder/spell/jaunt/space_crawl/proc/try_exit_jaunt(turf/our_turf, mob/living/jaunter, force = FALSE)
	if(!force && HAS_TRAIT_FROM(jaunter, TRAIT_NO_TRANSFORM, UID()))
		to_chat(jaunter, span_warning("Вы пока не можете вернуться!"))
		return FALSE

	if(!exit_jaunt(jaunter, our_turf))
		return FALSE

	jaunter.remove_traits(jaunting_traits, SPACE_PHASING)
	our_turf.visible_message(span_boldwarning("[jaunter.declent_ru(NOMINATIVE)] выходит из [our_turf.declent_ru(GENITIVE)]!"))
	return TRUE


/obj/effect/proc_holder/spell/jaunt/space_crawl/on_jaunt_exited(obj/effect/dummy/spell_jaunt/jaunt, mob/living/carbon/human/unjaunter)
	UnregisterSignal(jaunt, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(unjaunter, list(SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING)))
	playsound(get_turf(unjaunter), 'sound/magic/cosmic_energy.ogg', 50, TRUE, -1)
	new /obj/effect/temp_visual/space_explosion(get_turf(unjaunter))
	if(!ishuman(unjaunter))
		return ..()

	for(var/obj/item/space_crawl/space_hand in unjaunter.get_held_items())
		unjaunter.drop_item_ground(space_hand, force = TRUE)
		qdel(space_hand)

	return ..()


/// Signal proc for [SIGNAL_REMOVETRAIT] via [TRAIT_ALLOW_HERETIC_CASTING], losing our focus midcast will throw us out.
/obj/effect/proc_holder/spell/jaunt/space_crawl/proc/on_focus_lost(mob/living/source)
	SIGNAL_HANDLER
	var/turf/our_turf = get_turf(source)
	try_exit_jaunt(our_turf, source, TRUE)


/// Spacecrawl "hands", prevent the user from holding items in spacecrawl
/obj/item/space_crawl
	name = "космический сдвиг"
	desc = "Находясь в этой форме, вы не можете держать что-то в руках."
	icon = 'icons/obj/eldritch.dmi'
	item_flags = ABSTRACT | DROPDEL


/obj/item/space_crawl/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/// Different graphic for position indicator
/obj/effect/dummy/spell_jaunt/space
	icon_state = "solarflare"
	movespeed = 0

#undef SPACE_PHASING


/**
 * ## Jaunt spells
 *
 * A basic subtype for jaunt related spells.
 * Jaunt spells put their caster in a dummy
 * phased_mob effect that allows them to float
 * around incorporeally.
 *
 * Doesn't actually implement any behavior on cast to
 * enter or exit the jaunt - that must be done via subtypes.
 *
 * Use enter_jaunt() and exit_jaunt() as wrappers.
 */
/obj/effect/proc_holder/spell/jaunt
	school = SCHOOL_TRANSMUTATION

	invocation_type = INVOCATION_NONE

	/// What dummy mob type do we put jaunters in on jaunt?
	var/jaunt_type = /obj/effect/dummy/spell_jaunt


/obj/effect/proc_holder/spell/jaunt/before_cast(atom/cast_on)
	return ..() | SPELL_NO_FEEDBACK // Don't do the feedback until after we're jaunting


/obj/effect/proc_holder/spell/jaunt/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	. = ..()
	if(!.)
		return FALSE

	var/area/owner_area = get_area(action.owner)
	var/turf/owner_turf = get_turf(action.owner)
	if(!owner_area || !owner_turf)
		return FALSE // nullspaced?

	if(!HASBIT(owner_turf?.turf_flags, NOJAUNT))
		return isliving(user)

	if(show_message)
		to_chat(action.owner, span_danger("Какая-то потусторонняя сила мешает вам совершить Космический Сдвиг."))

	return FALSE


/**
 * Places the [jaunter] in a jaunt holder mob
 * If [loc_override] is supplied,
 * the jaunt will be moved to that turf to start at
 *
 * Returns the holder mob that was created
 */
/obj/effect/proc_holder/spell/jaunt/proc/enter_jaunt(mob/living/jaunter, turf/loc_override)
	SHOULD_CALL_PARENT(TRUE)

	var/obj/effect/dummy/spell_jaunt/jaunt = new jaunt_type(loc_override || get_turf(jaunter), jaunter)
	RegisterSignal(jaunt, COMSIG_MOB_EJECTED_FROM_JAUNT, PROC_REF(on_jaunt_exited))
	jaunter.forceMove(jaunt)
	//check_flags &= ~AB_CHECK_PHASED
	//jaunter.add_traits(list(TRAIT_MAGICALLY_PHASED, TRAIT_RUNECHAT_HIDDEN, TRAIT_WEATHER_IMMUNE), UID())
	// Don't do the feedback until we have runechat hidden.
	// Otherwise the text will follow the jaunt holder, which reveals where our caster is travelling.
	//spell_feedback(jaunter)

	// This needs to happen at the end, after all the traits and stuff is handled
	//SEND_SIGNAL(jaunter, COMSIG_MOB_ENTER_JAUNT, src, jaunt)
	return jaunt

/**
 * Ejects the [unjaunter] from jaunt
 * The jaunt object in turn should call on_jaunt_exited
 * If [loc_override] is supplied,
 * the jaunt will be moved to that turf
 * before ejecting the unjaunter
 *
 * Returns TRUE on successful exit, FALSE otherwise
 */
/obj/effect/proc_holder/spell/jaunt/proc/exit_jaunt(mob/living/unjaunter, turf/loc_override)
	SHOULD_CALL_PARENT(TRUE)

	var/obj/effect/dummy/spell_jaunt/jaunt = unjaunter.loc
	if(!istype(jaunt))
		return FALSE

	if(jaunt.jaunter != unjaunter)
		CRASH("Jaunt spell attempted to exit_jaunt with an invalid unjaunter, somehow.")

	if(loc_override)
		jaunt.forceMove(loc_override)

	jaunt.eject_jaunter()
	return TRUE


/**
 * Called when a mob is ejected from the jaunt holder and goes back to normal.
 * This is called both fom exit_jaunt() but also if the caster is ejected involuntarily for some reason.
 * Use this to clear state data applied when jaunting, such as the trait TRAIT_MAGICALLY_PHASED.
 * Arguments
 * * jaunt - The mob holder effect the caster has just exited
 * * unjaunter - The spellcaster who is no longer jaunting
 */
/obj/effect/proc_holder/spell/jaunt/proc/on_jaunt_exited(obj/effect/dummy/spell_jaunt/jaunt, mob/living/unjaunter)
	return
/*
	SHOULD_CALL_PARENT(TRUE)
	check_flags |= AB_CHECK_PHASED
	unjaunter.remove_traits(list(TRAIT_MAGICALLY_PHASED, TRAIT_RUNECHAT_HIDDEN, TRAIT_WEATHER_IMMUNE), UID())
	// This needs to happen at the end, after all the traits and stuff is handled
	SEND_SIGNAL(unjaunter, COMSIG_MOB_AFTER_EXIT_JAUNT, src)
*/

/obj/effect/proc_holder/spell/jaunt/on_spell_loss(mob/living/remove_from)
	exit_jaunt(remove_from)
	if(!is_jaunting(remove_from)) // In case you have made exit_jaunt conditional, as in mirror walk
		return ..()

	var/obj/effect/dummy/spell_jaunt/jaunt = remove_from.loc
	jaunt.eject_jaunter()
	return ..()
