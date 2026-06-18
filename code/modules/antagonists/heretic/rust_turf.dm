// Everything in the heretic module rusts turfs by calling rust_heretic_act() (do_rust_heretic_act, the
// rust spells, the grasp, the ascension's turf.rust_heretic_act(5), harvester, etc.). The /atom base of
// that proc is a no-op (see _heretic_compat.dm) and the real per-turf behaviour lives in rust_turf()
// below. This file ports tgstation's turf-rusting 1:1.
//
// Behaviour: walls just get a rust OVERLAY (via /datum/element/rust) and stay walls - NO dismantling, so the
// path isn't the wall-shredder the old port made it. TILED floors get their tile stripped to bare plating
// (the exposed, corroded look) and then rusted; we strip via make_plating() so the exposed under-floor
// pipes/cables are re-shown at full opacity instead of the half-hidden "transparent"-looking undertile state
// the old raw-ChangeTurf left them in.

/// How resistant this turf is to a heretic's rust. A turf only rusts if the heretic's rust_strength is
/// at least this high (see rust_heretic_act). Defaults to BASIC; stronger turf types raise it below.
/turf/var/rust_resistance = RUST_RESISTANCE_BASIC

// Reinforced / titanium turfs resist weak heretics (point: a fresh rust heretic, rust_strength 1, must
// NOT be able to rust reinforced walls - they need to grow first). Matches tg's rust_resistance values.
/turf/simulated/wall/r_wall
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/simulated/wall/mineral/titanium
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/simulated/wall/mineral/plastitanium
	rust_resistance = RUST_RESISTANCE_TITANIUM

// Don't rust space - it has no surface to corrode and rusting it looks broken.
/turf/space
	rust_resistance = RUST_RESISTANCE_ABSOLUTE


/// Check if the heretic is strong enough to rust this turf, and if so, rust it (overlay only).
/// rust_strength defaults to BASIC so the many no-arg callers (rust spells, charge, ...) rust basic turfs.
/turf/rust_heretic_act(rust_strength = RUST_RESISTANCE_BASIC)
	if(rust_strength < rust_resistance)
		return

	rust_turf()


/// Override this to change behaviour when being rusted by a heretic. Base behaviour (walls, plating, ...):
/// lay the rust overlay (and a small glowing rune) on top, leaving the turf itself otherwise untouched.
/turf/proc/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	AddElement(/datum/element/rust/heretic)
	new /obj/effect/glowing_rune(src)


// A TILED floor first has its tile stripped to bare plating ("exposes the floor" - the corroded look), then
// the plating is rusted. We use make_plating() - the proper tile-removal path - rather than a raw ChangeTurf
// so the now-exposed under-floor pipes/cables are re-shown correctly (full alpha / interactable) instead of
// being stranded in the half-hidden "undertile" state that made them render washed-out / "transparent".
/turf/simulated/floor/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	var/turf/simulated/floor/plating/stripped = make_plating(FALSE)
	stripped?.rust_turf()


// Bare plating just gets the rust overlay - there's no tile to strip. This is also the turf make_plating()
// hands off to above, so it must NOT strip again: plating is a /turf/simulated/floor subtype, so without
// this override it would re-enter the tiled-floor branch and recurse.
/turf/simulated/floor/plating/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	AddElement(/datum/element/rust/heretic)
	new /obj/effect/glowing_rune(src)
