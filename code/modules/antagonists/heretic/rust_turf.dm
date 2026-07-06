// Everything in the heretic module rusts turfs by calling rust_heretic_act() (do_rust_heretic_act, the
// rust spells, the grasp, the ascension's turf.rust_heretic_act(5), harvester, etc.). The /atom base of
// that proc is a no-op (see _heretic_compat.dm) and the real per-turf behaviour lives in rust_turf() below.
//
// Behaviour: walls just get a rust OVERLAY (via /datum/element/rust) and stay walls - no dismantling. TILED
// floors get their tile stripped to bare plating (the exposed, corroded look) and then rusted; we strip via
// make_plating() so the exposed under-floor pipes/cables are re-shown at full opacity instead of being left
// in a half-hidden "undertile" state.

// The rust_resistance var itself lives in the /turf declaration (code/game/turfs/turf.dm); per-type
// values are set in each turf's own definition (walls_reinforced.dm, walls_mineral.dm, space.dm).

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


// A tiled floor first has its tile stripped to bare plating via make_plating(), then the plating is rusted.
/turf/simulated/floor/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	var/turf/simulated/floor/plating/stripped = make_plating(FALSE)
	stripped?.rust_turf()


// Bare plating just gets the rust overlay. This must NOT strip again: plating is a /turf/simulated/floor
// subtype, so without this override it would re-enter the tiled-floor branch above and recurse.
/turf/simulated/floor/plating/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	AddElement(/datum/element/rust/heretic)
	new /obj/effect/glowing_rune(src)
