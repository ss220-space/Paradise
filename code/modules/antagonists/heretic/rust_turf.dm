// Everything in the heretic module rusts turfs by calling rust_heretic_act() (do_rust_heretic_act, the
// rust spells, the grasp, the ascension's turf.rust_heretic_act(5), harvester, etc.). The /atom base of
// that proc is a no-op (see _heretic_compat.dm) and the real per-turf behaviour lives in rust_turf()
// below, so without this bridge only the two direct rust_turf() callers (eldritch_flask / rust grenade)
// ever actually rusted a turf — every spell/grasp silently no-op'd on the floor. Bridge them here.
// (strength is accepted for call-site compatibility; per-turf strength gating is future polish.)
/turf/rust_heretic_act(strength)
	rust_turf()

/// Override this to change behaviour when being rusted by a heretic
/turf/proc/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	AddElement(/datum/element/rust/heretic)
	new /obj/effect/glowing_rune(src)


/turf/simulated/wall/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		dismantle_wall()
		return

	return ..()


/turf/simulated/wall/mineral/titanium/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ChangeTurf(/turf/simulated/wall/rust)
		return

	return ..()


/turf/simulated/wall/mineral/plastitanium/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ChangeTurf(/turf/simulated/wall/rust)
		return

	return ..()


/turf/simulated/wall/r_wall/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ChangeTurf(/turf/simulated/wall/rust)
		return

	return ..()


/turf/simulated/floor/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	ChangeTurf(/turf/simulated/floor/plating)
	return ..()
