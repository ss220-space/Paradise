#define BASE_WIZ_ROD_RANGE 15
/obj/effect/proc_holder/spell/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path."
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
#undef BASE_WIZ_ROD_RANGE
