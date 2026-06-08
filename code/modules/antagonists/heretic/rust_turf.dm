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
