#define SPACE_PHASING "space-phasing"

/// Lets the caster enter and exit tiles of space or misc turfs.
/obj/effect/proc_holder/spell/jaunt/space_crawl
	name = "Космический Сдвиг"
	desc = "Позволяет вам появляться и исчезать из реальности, находясь в космосе или на \
			открытом воздухе с низким давлением. Для возвращения, место прибытия тоже должно быть таковым."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "space_crawl"

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	phase_allowed = TRUE
	base_cooldown = 5 SECONDS
	spell_requirements = NONE

	jaunt_type = /obj/effect/dummy/spell_jaunt/space
	///List of traits that are added to the heretic while in space phase jaunt
	var/static/list/jaunting_traits = list(TRAIT_RESIST_COLD, TRAIT_NO_BREATH)
	/// Message shown when the caster tries to enter/exit on a turf that isn't valid (see is_valid_turf).
	var/invalid_turf_message = "Вы должны находиться в космосе или на открытом воздухе с низким давлением!"
	/// The "hands" given to a carbon jaunter to stop them acting. Subtypes override this to rename them.
	var/jaunt_hand_type = /obj/item/space_crawl
	/// Sound played at the turf when the caster submerges into the jaunt. Subtypes override for their own flavour.
	var/jaunt_in_sound = 'sound/magic/cosmic_energy.ogg'
	/// Sound played at the turf when the caster resurfaces from the jaunt. Subtypes override for their own flavour.
	var/jaunt_out_sound = 'sound/magic/cosmic_energy.ogg'


/obj/effect/proc_holder/spell/jaunt/space_crawl/on_spell_gain(mob/user = usr)
	. = ..()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))


/obj/effect/proc_holder/spell/jaunt/space_crawl/on_spell_loss(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOVABLE_MOVED)


/obj/effect/proc_holder/spell/jaunt/space_crawl/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(is_jaunting(user) && is_valid_turf(user))
		return TRUE

	. = ..()
	if(!.)
		return FALSE

	if(is_valid_turf(user))
		return TRUE

	if(show_message)
		to_chat(user, span_warning(invalid_turf_message))
	return FALSE


/// Returns TRUE if the user is standing somewhere they can enter or exit the space phase.
/obj/effect/proc_holder/spell/jaunt/space_crawl/proc/is_valid_turf(mob/user = usr)
	var/turf/my_turf = get_turf(user)
	if(isspaceturf(my_turf))
		return TRUE

	var/area/my_area = get_area(user)
	return is_space_or_openspace(my_turf) || (my_area.outdoors && lavaland_equipment_pressure_check(my_turf))


/obj/effect/proc_holder/spell/jaunt/space_crawl/cast(list/targets, mob/user = usr)
	var/mob/living/cast_on = targets[1]
	. = ..()
	var/turf/our_turf = get_turf(cast_on)
	do_spacecrawl(our_turf, cast_on)


/// Attempts to enter or exit the passed space or misc turf.
/// Returns TRUE if we successfully entered or exited said turf, FALSE otherwise
/obj/effect/proc_holder/spell/jaunt/space_crawl/proc/do_spacecrawl(turf/our_turf, mob/living/jaunter)
	if(is_jaunting(jaunter))
		. = try_exit_jaunt(our_turf, jaunter)
	else
		. = try_enter_jaunt(our_turf, jaunter)

	if(.)
		return

	cooldown_handler.start_recharge()
	to_chat(jaunter, span_warning("Вы не можете это сделать!"))


/// Attempts to enter the passed space or misc turfs.
/obj/effect/proc_holder/spell/jaunt/space_crawl/proc/try_enter_jaunt(turf/our_turf, mob/living/jaunter)
	ADD_TRAIT(jaunter, TRAIT_NO_TRANSFORM, UID())
	var/obj/effect/dummy/spell_jaunt/holder = enter_jaunt(jaunter, our_turf)
	if(isnull(holder))
		REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, UID())
		return FALSE

	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))
	if(iscarbon(jaunter))
		jaunter.drop_all_held_items()
		for(var/obj/item/melee/touch_attack/touch_hand in jaunter.get_held_items())
			qdel(touch_hand)
		if(!HAS_TRAIT(jaunter, TRAIT_ALLOW_HERETIC_CASTING))
			REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, UID())
			exit_jaunt(jaunter, our_turf)
			return FALSE

		var/obj/item/space_crawl/left_hand = new jaunt_hand_type(jaunter)
		var/obj/item/space_crawl/right_hand = new jaunt_hand_type(jaunter)
		left_hand.icon_state = "spacehand_right" // Icons swapped intentionally..
		right_hand.icon_state = "spacehand_left" // ..because perspective, or something
		jaunter.put_in_hands(left_hand)
		jaunter.put_in_hands(right_hand)

	jaunter.add_traits(jaunting_traits, SPACE_PHASING)
	RegisterSignal(jaunter, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_lost), override = TRUE)
	if(jaunt_in_sound)
		playsound(our_turf, jaunt_in_sound, 50, TRUE, -1)
	our_turf.visible_message(span_warning("[DECLENT_RU_CAP(jaunter, NOMINATIVE)] погружается в [our_turf.declent_ru(ACCUSATIVE)]!"))
	new /obj/effect/temp_visual/space_explosion(our_turf)
	jaunter.ExtinguishMob()

	REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, UID())
	action?.build_all_button_icons(UPDATE_BUTTON_STATUS)
	return TRUE

/// Attempts to Exit the passed space or misc turf.
/obj/effect/proc_holder/spell/jaunt/space_crawl/proc/try_exit_jaunt(turf/our_turf, mob/living/jaunter, force = FALSE)
	if(!force && HAS_TRAIT_FROM(jaunter, TRAIT_NO_TRANSFORM, UID()))
		to_chat(jaunter, span_warning("Вы пока не можете вернуться!"))
		return FALSE

	if(!exit_jaunt(jaunter, our_turf))
		return FALSE

	jaunter.remove_traits(jaunting_traits, SPACE_PHASING)
	our_turf.visible_message(span_boldwarning("[DECLENT_RU_CAP(jaunter, NOMINATIVE)] выходит из [our_turf.declent_ru(GENITIVE)]!"))
	return TRUE


/obj/effect/proc_holder/spell/jaunt/space_crawl/on_jaunt_exited(obj/effect/dummy/spell_jaunt/jaunt, mob/living/carbon/human/unjaunter)
	UnregisterSignal(jaunt, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(unjaunter, list(SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING)))
	if(jaunt_out_sound)
		playsound(get_turf(unjaunter), jaunt_out_sound, 50, TRUE, -1)
	new /obj/effect/temp_visual/space_explosion(get_turf(unjaunter))
	if(!ishuman(unjaunter))
		return ..()

	for(var/obj/item/space_crawl/space_hand in unjaunter.get_held_items())
		unjaunter.drop_item_ground(space_hand, force = TRUE)
		qdel(space_hand)

	action?.build_all_button_icons(UPDATE_BUTTON_STATUS)
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

/// Different graphic for position indicator - a ball of lightning, so the jaunter can easily spot themselves.
/// The holder itself is invisible (invisibility = 60); the position indicator is a client image built from
/// phased_mob_icon[_state] in /obj/effect/dummy/spell_jaunt/Entered, so those are the vars that matter here.
/obj/effect/dummy/spell_jaunt/space
	phased_mob_icon_state = "solarflare"
	movespeed = 0

#undef SPACE_PHASING


/// A basic subtype for jaunt related spells. Jaunt spells put their caster in a dummy phased_mob effect
/// that allows them to float around incorporeally.
///
/// Doesn't actually implement any behavior on cast to enter or exit the jaunt - that must be done via
/// subtypes. Use enter_jaunt() and exit_jaunt() as wrappers.
/obj/effect/proc_holder/spell/jaunt
	school = SCHOOL_TRANSMUTATION
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


/// Places the [jaunter] in a jaunt holder mob. If [loc_override] is supplied, the jaunt will be moved to
/// that turf to start at. Returns the holder mob that was created.
/obj/effect/proc_holder/spell/jaunt/proc/enter_jaunt(mob/living/jaunter, turf/loc_override)
	SHOULD_CALL_PARENT(TRUE)

	var/obj/effect/dummy/spell_jaunt/jaunt = new jaunt_type(loc_override || get_turf(jaunter), jaunter)
	RegisterSignal(jaunt, COMSIG_MOB_EJECTED_FROM_JAUNT, PROC_REF(on_jaunt_exited))
	jaunter.forceMove(jaunt)

	return jaunt

/// Ejects the [unjaunter] from jaunt. The jaunt object in turn should call on_jaunt_exited. If
/// [loc_override] is supplied, the jaunt will be moved to that turf before ejecting the unjaunter.
/// Returns TRUE on successful exit, FALSE otherwise.
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


/// Called when a mob is ejected from the jaunt holder and goes back to normal. This is called both from
/// exit_jaunt() but also if the caster is ejected involuntarily for some reason. Use this to clear state
/// data applied when jaunting, such as the trait TRAIT_MAGICALLY_PHASED.
/// * jaunt - The mob holder effect the caster has just exited
/// * unjaunter - The spellcaster who is no longer jaunting
/obj/effect/proc_holder/spell/jaunt/proc/on_jaunt_exited(obj/effect/dummy/spell_jaunt/jaunt, mob/living/unjaunter)
	return
/*
	SHOULD_CALL_PARENT(TRUE)
	check_flags |= AB_CHECK_PHASED
	unjaunter.remove_traits(list(TRAIT_MAGICALLY_PHASED, TRAIT_RUNECHAT_HIDDEN, TRAIT_WEATHER_IMMUNE), UID())
	SEND_SIGNAL(unjaunter, COMSIG_MOB_AFTER_EXIT_JAUNT, src)
*/

/obj/effect/proc_holder/spell/jaunt/on_spell_loss(mob/living/remove_from)
	exit_jaunt(remove_from)
	if(!is_jaunting(remove_from)) // In case you have made exit_jaunt conditional, as in mirror walk
		return ..()

	var/obj/effect/dummy/spell_jaunt/jaunt = remove_from.loc
	jaunt.eject_jaunter()
	return ..()
