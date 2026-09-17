// This could probably be an aoe spell but it's a little cursed, so I'm not touching it
/datum/action/cooldown/spell/aoe/spacetime_dist
	name = "Spacetime Distortion"
	desc = "Entangle the strings of space-time in an area around you, \
		randomizing the layout and making proper movement impossible. The strings vibrate... \
		Upgrading the spell increases range, it does not lower cooldown."
	sound = 'sound/magic/strings.ogg'
	button_icon_state = "spacetime"
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_WIZARD_GARB | SPELL_REQUIRES_NO_CENTCOM //Prevent people from getting to centcom
	spell_max_level = 3
	aoe_radius = 10
	/// Whether we're ready to cast again yet or not. In the event someone lowers their cooldown with charge.
	var/ready = TRUE
	/// The duration of the scramble
	var/duration = 15 SECONDS
	/// A lazylist of all scramble effects this spell has created.
	var/list/effects

/datum/action/cooldown/spell/aoe/spacetime_dist/Destroy()
	QDEL_LIST(effects)
	return ..()

/datum/action/cooldown/spell/aoe/spacetime_dist/level_spell(bypass_cap)
	. = ..()
	aoe_radius += 3

/datum/action/cooldown/spell/aoe/spacetime_dist/can_cast_spell(feedback)
	return ..() && ready

/datum/action/cooldown/spell/aoe/spacetime_dist/get_things_to_cast_on(atom/center)
	var/list/turfs = spiral_range_turfs(aoe_radius, center)
	if(!length(turfs))
		return

	var/list/targets = list()

	// Go through the turfs we got and pair them up
	// This is where we determine what to swap where
	var/num_to_scramble = round(length(turfs) * 0.5)
	for(var/i in 1 to num_to_scramble)
		targets[pick_n_take(turfs)] = pick_n_take(turfs)

	// If there's any turfs unlinked with a friend,
	// just randomly swap it with any turf in the area
	if(length(turfs))
		var/turf/loner = pick(turfs)
		var/area/caster_area = get_area(center)
		targets[loner] = get_turf(pick(caster_area.contents))
	return targets

/datum/action/cooldown/spell/aoe/spacetime_dist/cast(atom/cast_on)
	var/list/turf/to_switcharoo = get_things_to_cast_on(cast_on)
	if(!length(to_switcharoo))
		to_chat(cast_on, span_warning("For whatever reason, the strings nearby aren't keen on being tangled."))
		return

	ready = FALSE
	effects = list()

	for(var/turf/swap_a as anything in to_switcharoo)
		var/turf/swap_b = to_switcharoo[swap_a]
		var/obj/effect/cross_action/spacetime_dist/effect_a = new /obj/effect/cross_action/spacetime_dist(swap_a)
		var/obj/effect/cross_action/spacetime_dist/effect_b = new /obj/effect/cross_action/spacetime_dist(swap_b)
		effect_a.linked_dist = effect_b
		effect_a.add_overlay(swap_b.photograph())
		effect_b.linked_dist = effect_a
		effect_b.add_overlay(swap_a.photograph())
		effect_b.set_light_range_power_color(4, 30, "#c9fff5")
		effects += effect_a
		effects += effect_b
	after_cast(cast_on)
	return ..()

/datum/action/cooldown/spell/aoe/spacetime_dist/cast_on_thing_in_aoe(atom/victim, atom/caster)
	return

/datum/action/cooldown/spell/aoe/spacetime_dist/after_cast(atom/cast_on)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(clean_turfs)), duration)

/// Callback which cleans up our effects list after the duration expires.
/datum/action/cooldown/spell/aoe/spacetime_dist/proc/clean_turfs()
	QDEL_LIST(effects)
	ready = TRUE

/obj/effect/cross_action
	name = "cross me"
	desc = "for crossing"

/obj/effect/cross_action/spacetime_dist
	name = "spacetime distortion"
	desc = "A distortion in spacetime. You can hear faint music..."
	icon_state = "nothing"
	/// A flags which save people from being thrown about
	var/obj/effect/cross_action/spacetime_dist/linked_dist
	/// Used to prevent an infinite loop in the space time continuum
	var/cant_teleport = FALSE
	var/walks_left = 50 //prevents the game from hanging in extreme cases

/obj/effect/cross_action/spacetime_dist/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/cross_action/singularity_act()
	return

/obj/effect/cross_action/singularity_pull(atom/singularity, current_size)
	return

/obj/effect/cross_action/spacetime_dist/proc/walk_link(atom/movable/AM)
	if(linked_dist && walks_left > 0)
		flick("purplesparkles", src)
		linked_dist.get_walker(AM)
		walks_left--

/obj/effect/cross_action/spacetime_dist/proc/get_walker(atom/movable/AM)
	cant_teleport = TRUE
	flick("purplesparkles", src)
	AM.forceMove(get_turf(src))
	cant_teleport = FALSE

/obj/effect/cross_action/spacetime_dist/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!cant_teleport)
		walk_link(arrived)

/obj/effect/cross_action/spacetime_dist/attackby(obj/item/I, mob/user, params)
	. = ATTACK_CHAIN_BLOCKED_ALL
	if(user.drop_item_ground(I))
		walk_link(I)
	else
		walk_link(user)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/effect/cross_action/spacetime_dist/attack_hand(mob/user, list/modifiers)
	walk_link(user)

/obj/effect/cross_action/spacetime_dist/Destroy()
	cant_teleport = TRUE
	linked_dist = null
	return ..()

