

/// Check if the heretic is strong enough to rust this turf, and if so, rust it (overlay only).
/// rust_strength defaults to BASIC so the many no-arg callers (rust spells, charge, ...) rust basic turfs.
/turf/rust_heretic_act(rust_strength = RUST_RESISTANCE_BASIC, spawn_rune = TRUE)
	if(rust_strength < rust_resistance)
		return

	rust_turf(spawn_rune)


/// Override this to change behaviour when being rusted by a heretic. Base behaviour (walls, plating, ...):
/// lay the rust overlay (and a small glowing rune) on top, leaving the turf itself otherwise untouched.
/turf/proc/rust_turf(spawn_rune = TRUE)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	AddElement(/datum/element/rust/heretic)
	if(spawn_rune)
		new /obj/effect/glowing_rune(src)


/turf/simulated/floor/rust_turf(spawn_rune = TRUE)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	var/turf/simulated/floor/plating/stripped = make_plating(FALSE)
	stripped?.rust_turf(spawn_rune)


/turf/simulated/floor/plating/rust_turf(spawn_rune = TRUE)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	AddElement(/datum/element/rust/heretic)
	if(spawn_rune)
		new /obj/effect/glowing_rune(src)
