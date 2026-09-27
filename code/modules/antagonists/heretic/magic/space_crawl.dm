#define SPACE_PHASING "space-phasing"

/// Lets the caster enter and exit tiles of space or misc turfs.
/datum/action/cooldown/spell/jaunt/space_crawl
	name = "Космический Сдвиг"
	desc = "Позволяет вам появляться и исчезать из реальности, находясь в космосе или на \
			открытом воздухе с низким давлением. Для возвращения, место прибытия тоже должно быть таковым."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "space_crawl"

	school = SCHOOL_FORBIDDEN
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 5 SECONDS
	spell_requirements = NONE

	jaunt_type = /obj/effect/dummy/phased_mob/spell_jaunt/space
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


/datum/action/cooldown/spell/jaunt/space_crawl/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))


/datum/action/cooldown/spell/jaunt/space_crawl/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOVABLE_MOVED)


/datum/action/cooldown/spell/jaunt/space_crawl/can_cast_spell(feedback = TRUE)
	if(is_jaunting(owner) && is_valid_turf(owner))
		return TRUE

	. = ..()
	if(!.)
		return FALSE

	if(is_valid_turf(owner))
		return TRUE

	if(feedback)
		to_chat(owner, span_warning(invalid_turf_message))
	return FALSE


/// Returns TRUE if the user is standing somewhere they can enter or exit the space phase.
/datum/action/cooldown/spell/jaunt/space_crawl/proc/is_valid_turf(mob/user = usr)
	var/turf/my_turf = get_turf(user)
	if(isspaceturf(my_turf))
		return TRUE

	var/area/my_area = get_area(user)
	return is_space_or_openspace(my_turf) || (my_area.outdoors && lavaland_equipment_pressure_check(my_turf))


/datum/action/cooldown/spell/jaunt/space_crawl/cast(mob/living/cast_on)
	. = ..()
	var/turf/our_turf = get_turf(cast_on)
	do_spacecrawl(our_turf, cast_on)


/// Attempts to enter or exit the passed space or misc turf.
/// Returns TRUE if we successfully entered or exited said turf, FALSE otherwise
/datum/action/cooldown/spell/jaunt/space_crawl/proc/do_spacecrawl(turf/our_turf, mob/living/jaunter)
	if(is_jaunting(jaunter))
		. = try_exit_jaunt(our_turf, jaunter)
	else
		. = try_enter_jaunt(our_turf, jaunter)

	if(.)
		return

	StartCooldown()
	to_chat(jaunter, span_warning("Вы не можете это сделать!"))


/// Attempts to enter the passed space or misc turfs.
/datum/action/cooldown/spell/jaunt/space_crawl/proc/try_enter_jaunt(turf/our_turf, mob/living/jaunter)
	ADD_TRAIT(jaunter, TRAIT_NO_TRANSFORM, UID())
	var/obj/effect/dummy/phased_mob/spell_jaunt/holder = enter_jaunt(jaunter, our_turf)
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
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	return TRUE

/// Attempts to Exit the passed space or misc turf.
/datum/action/cooldown/spell/jaunt/space_crawl/proc/try_exit_jaunt(turf/our_turf, mob/living/jaunter, force = FALSE)
	if(!force && HAS_TRAIT_FROM(jaunter, TRAIT_NO_TRANSFORM, UID()))
		to_chat(jaunter, span_warning("Вы пока не можете вернуться!"))
		return FALSE

	if(!exit_jaunt(jaunter, our_turf))
		return FALSE

	jaunter.remove_traits(jaunting_traits, SPACE_PHASING)
	our_turf.visible_message(span_boldwarning("[DECLENT_RU_CAP(jaunter, NOMINATIVE)] выходит из [our_turf.declent_ru(GENITIVE)]!"))
	return TRUE


/datum/action/cooldown/spell/jaunt/space_crawl/on_jaunt_exited(obj/effect/dummy/phased_mob/spell_jaunt/jaunt, mob/living/carbon/human/unjaunter)
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

	build_all_button_icons(UPDATE_BUTTON_STATUS)
	return ..()


/// Signal proc for [SIGNAL_REMOVETRAIT] via [TRAIT_ALLOW_HERETIC_CASTING], losing our focus midcast will throw us out.
/datum/action/cooldown/spell/jaunt/space_crawl/proc/on_focus_lost(mob/living/source)
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
/// phased_mob_icon[_state] in /obj/effect/dummy/phased_mob/spell_jaunt/Entered, so those are the vars that matter here.
/obj/effect/dummy/phased_mob/spell_jaunt/space
	phased_mob_icon_state = "solarflare"
	movespeed = 0

#undef SPACE_PHASING
