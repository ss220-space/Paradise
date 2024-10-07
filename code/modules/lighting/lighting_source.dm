// This is where the fun begins.
// These are the main datums that emit light.

/datum/light_source
	var/atom/top_atom        // The atom we're emitting light from (for example a mob if we're from a flashlight that's being held).
	var/atom/source_atom     // The atom that we belong to.

	var/turf/source_turf     // The turf under the above.
	var/turf/pixel_turf      // The turf the top_atom appears to over.
	var/light_power    // Intensity of the emitter light.
	var/light_range      // The range of the emitted light.
	var/light_color    // The colour of the light, string, decomposed by parse_light_color()

	// Variables for keeping track of the colour.
	var/lum_r
	var/lum_g
	var/lum_b

	// The lumcount values used to apply the light.
	var/tmp/applied_lum_r
	var/tmp/applied_lum_g
	var/tmp/applied_lum_b

	var/list/datum/lighting_corner/effect_str     // List used to store how much we're affecting corners.

	var/applied = FALSE // Whether we have applied our light yet or not.

	var/needs_update = LIGHTING_NO_UPDATE    // Whether we are queued for an update.


/datum/light_source/New(atom/owner, atom/top)
	source_atom = owner // Set our new owner.
	LAZYADD(source_atom.light_sources, src)
	if(top.flags & BLOCKS_LIGHT) // If the top atom blocks light, then our owner becomes the topmost instead. This still allows atoms that block light to be a light of their own.
		top_atom = source_atom
	else
		top_atom = top
	if(top_atom != source_atom)
		LAZYADD(top_atom.light_sources, src)

	source_turf = top_atom
	pixel_turf = get_turf_pixel(top_atom) || source_turf

	light_power = source_atom.light_power
	light_range = source_atom.light_range
	light_color = source_atom.light_color

	PARSE_LIGHT_COLOR(src)

	update()

/datum/light_source/Destroy(force)
	remove_lum()
	if(source_atom)
		LAZYREMOVE(source_atom.light_sources, src)

	if(top_atom)
		LAZYREMOVE(top_atom.light_sources, src)

	if(needs_update)
		SSlighting.sources_queue -= src

	. = ..()

// Yes this doesn't align correctly on anything other than 4 width tabs.
// If you want it to go switch everybody to elastic tab stops.
// Actually that'd be great if you could!
#define EFFECT_UPDATE(level) \
	if(needs_update == LIGHTING_NO_UPDATE) { \
		SSlighting.sources_queue += src; \
	} \
	if(needs_update < level) { \
		needs_update = level; \
	} \


// This proc will cause the light source to update the top atom, and add itself to the update queue.
/datum/light_source/proc/update(atom/new_top_atom)
	// This top atom is different.
	if(new_top_atom && new_top_atom != top_atom)
		if(top_atom != source_atom && top_atom.light_sources) // Remove ourselves from the light sources of that top atom.
			LAZYREMOVE(top_atom.light_sources, src)

		if(new_top_atom.flags & BLOCKS_LIGHT)
			top_atom = source_atom
		else
			top_atom = new_top_atom

		if(top_atom != source_atom)
			LAZYADD(top_atom.light_sources, src) // Add ourselves to the light sources of our new top atom.

	EFFECT_UPDATE(LIGHTING_CHECK_UPDATE)

// Will force an update without checking if it's actually needed.
/datum/light_source/proc/force_update()
	EFFECT_UPDATE(LIGHTING_FORCE_UPDATE)

// Will cause the light source to recalculate turfs that were removed or added to visibility only.
/datum/light_source/proc/vis_update()
	EFFECT_UPDATE(LIGHTING_VIS_UPDATE)

// Macro that applies light to a new corner.
// It is a macro in the interest of speed, yet not having to copy paste it.
// If you're wondering what's with the backslashes, the backslashes cause BYOND to not automatically end the line.
// As such this all gets counted as a single line.
// The braces and semicolons are there to be able to do this on a single line.

// This exists so we can cache the vars used in this macro, and save MASSIVE time :)
// Most of this is saving off datum var accesses, tho some of it does actually cache computation
// You will NEED to call this before you call APPLY_CORNER
#define SETUP_CORNERS_CACHE(lighting_source) \
	var/_turf_x = lighting_source.pixel_turf.x; \
	var/_turf_y = lighting_source.pixel_turf.y; \
	var/_turf_z = lighting_source.pixel_turf.z; \
	var/_range_divisor = max(1, lighting_source.light_range); \
	var/_light_power = lighting_source.light_power; \
	var/_applied_lum_r = lighting_source.applied_lum_r; \
	var/_applied_lum_g = lighting_source.applied_lum_g; \
	var/_applied_lum_b = lighting_source.applied_lum_b; \
	var/_lum_r = lighting_source.lum_r; \
	var/_lum_g = lighting_source.lum_g; \
	var/_lum_b = lighting_source.lum_b; \

#define SETUP_CORNERS_REMOVAL_CACHE(lighting_source) \
	var/_applied_lum_r = lighting_source.applied_lum_r; \
	var/_applied_lum_g = lighting_source.applied_lum_g; \
	var/_applied_lum_b = lighting_source.applied_lum_b;

#define LUM_FALLOFF(C) (1 - CLAMP01(sqrt((C.x - _turf_x) ** 2 + (C.y - _turf_y) ** 2 + LIGHTING_HEIGHT) / _range_divisor))
// You may notice we still use squares here even though there are three components
// Because z diffs are so functionally small, cubes and cube roots are too aggressive
#define LUM_FALLOFF_MULTIZ(C) (1 - CLAMP01(sqrt((C.x - _turf_x) ** 2 + (C.y - _turf_y) ** 2 + abs(C.z - _turf_z) ** 2 + LIGHTING_HEIGHT) / _range_divisor))

#define APPLY_CORNER(C)                      \
	if(C.z == _turf_z) { 					 \
		. = LUM_FALLOFF(C); 				 \
	} 										 \
	else { 									 \
		. = LUM_FALLOFF_MULTIZ(C)			 \
	} 										 \
	. *= _light_power;                        \
	var/OLD = effect_str[C];                 \
	                                         \
	C.update_lumcount                        \
	(                                        \
		(. * _lum_r) - (OLD * _applied_lum_r), \
		(. * _lum_g) - (OLD * _applied_lum_g), \
		(. * _lum_b) - (OLD * _applied_lum_b)  \
	);

#define REMOVE_CORNER(C)                     \
	. = -effect_str[C];                      \
	C.update_lumcount                        \
	(                                        \
		. * _applied_lum_r,                   \
		. * _applied_lum_g,                   \
		. * _applied_lum_b                    \
	);

// This is the define used to calculate falloff.

/datum/light_source/proc/remove_lum()
	SETUP_CORNERS_REMOVAL_CACHE(src)
	applied = FALSE
	for (var/datum/lighting_corner/corner as anything in effect_str)
		REMOVE_CORNER(corner)
		LAZYREMOVE(corner.affecting, src)
		SSdemo.mark_turf(corner.master_NE)
		SSdemo.mark_turf(corner.master_SE)
		SSdemo.mark_turf(corner.master_SW)
		SSdemo.mark_turf(corner.master_NW)

	effect_str = null

/datum/light_source/proc/recalc_corner(datum/lighting_corner/C)
	SETUP_CORNERS_CACHE(src)
	LAZYINITLIST(effect_str)
	if(effect_str[C]) // Already have one.
		REMOVE_CORNER(C)
		effect_str[C] = 0

	APPLY_CORNER(C)
	effect_str[C] = .

// Keep in mind. Lighting corners accept the bottom left (northwest) set of cords to them as input
#define GENERATE_MISSING_CORNERS(gen_for) \
	if (!gen_for.lighting_corner_NE) { \
		gen_for.lighting_corner_NE = new /datum/lighting_corner(gen_for.x, gen_for.y, gen_for.z); \
	} \
	if (!gen_for.lighting_corner_SE) { \
		gen_for.lighting_corner_SE = new /datum/lighting_corner(gen_for.x, gen_for.y - 1, gen_for.z); \
	} \
	if (!gen_for.lighting_corner_SW) { \
		gen_for.lighting_corner_SW = new /datum/lighting_corner(gen_for.x - 1, gen_for.y - 1, gen_for.z); \
	} \
	if (!gen_for.lighting_corner_NW) { \
		gen_for.lighting_corner_NW = new /datum/lighting_corner(gen_for.x - 1, gen_for.y, gen_for.z); \
	} \
	gen_for.lighting_corners_initialised = TRUE;

#define INSERT_CORNERS(insert_into, draw_from)             \
	if (!draw_from.lighting_corners_initialised) {         \
		GENERATE_MISSING_CORNERS(draw_from);               \
	}                                                      \
	insert_into[draw_from.lighting_corner_NE] = 0;         \
	insert_into[draw_from.lighting_corner_SE] = 0;         \
	insert_into[draw_from.lighting_corner_SW] = 0;         \
	insert_into[draw_from.lighting_corner_NW] = 0;


/datum/light_source/proc/update_corners()
	var/update = FALSE
	var/atom/source_atom = src.source_atom

	if(QDELETED(source_atom))
		qdel(src)
		return

	if(source_atom.light_power != light_power)
		light_power = source_atom.light_power
		update = TRUE

	if(source_atom.light_range != light_range)
		light_range = source_atom.light_range
		update = TRUE

	if(!top_atom)
		top_atom = source_atom
		update = TRUE

	if(!light_range || !light_power)
		qdel(src)
		return

	if(isturf(top_atom))
		if(source_turf != top_atom)
			source_turf = top_atom
			pixel_turf = source_turf
			update = TRUE
	else if(top_atom.loc != source_turf)
		source_turf = top_atom.loc
		pixel_turf = get_turf_pixel(top_atom)
		update = TRUE
	else
		var/P = get_turf_pixel(top_atom)
		if(P != pixel_turf)
			pixel_turf = P
			update = TRUE

	if(!isturf(source_turf))
		if(applied)
			remove_lum()
		return

	if(light_range && light_power && !applied)
		update = TRUE

	if(source_atom.light_color != light_color)
		light_color = source_atom.light_color
		PARSE_LIGHT_COLOR(src)
		update = TRUE

	else if(applied_lum_r != lum_r || applied_lum_g != lum_g || applied_lum_b != lum_b)
		update = TRUE

	if(update)
		needs_update = LIGHTING_CHECK_UPDATE
		applied = TRUE
	else if(needs_update == LIGHTING_CHECK_UPDATE)
		return //nothing's changed

	var/list/datum/lighting_corner/corners = list()

	if(source_turf)
		var/uses_multiz = !!GET_LOWEST_STACK_OFFSET(source_turf.z)
		var/oldlum = source_turf.luminosity
		source_turf.luminosity = CEILING(light_range, 1)
		if(uses_multiz)
			for(var/turf/T in view(CEILING(light_range, 1), source_turf))
				if(IS_OPAQUE_TURF(T))
					continue
				INSERT_CORNERS(corners, T)

				var/turf/below = GET_TURF_BELOW(T)
				var/turf/previous = T
				while(below)
					// If we find a non transparent previous, end
					if(!previous.transparent_floor)
						break
					if(IS_OPAQUE_TURF(below))
						// If we're opaque but the tile above us is transparent, then we should be counted as part of the potential "space"
						// Of this corner
						break
					// Now we do lighting things to it
					INSERT_CORNERS(corners, below)
					// ANNND then we add the one below it
					previous = below
					below = GET_TURF_BELOW(below)

				var/turf/above = GET_TURF_ABOVE(T)
				while(above)
					// If we find a non transparent turf, end
					if(!above.transparent_floor || IS_OPAQUE_TURF(above))
						break
					INSERT_CORNERS(corners, above)
					above = GET_TURF_ABOVE(above)
		else // Yes I know this could be acomplished with an if in the for loop, but it's fukin lighting code man
			for(var/turf/T in view(CEILING(light_range, 1), source_turf))
				if(IS_OPAQUE_TURF(T))
					continue
				INSERT_CORNERS(corners, T)
				SSdemo.mark_turf(T)

		source_turf.luminosity = oldlum

	SETUP_CORNERS_CACHE(src)

	var/list/datum/lighting_corner/new_corners = (corners - src.effect_str)
	LAZYINITLIST(src.effect_str)
	for (var/datum/lighting_corner/corner as anything in new_corners)
		APPLY_CORNER(corner)
		if (. != 0)
			LAZYADD(corner.affecting, src)
			effect_str[corner] = .
	// New corners are a subset of corners. so if they're both the same length, there are NO old corners!
	if(needs_update != LIGHTING_VIS_UPDATE && length(corners) != length(new_corners))
		for (var/datum/lighting_corner/corner as anything in corners - new_corners) // Existing corners
			APPLY_CORNER(corner)
			if (. != 0)
				effect_str[corner] = .
			else
				LAZYREMOVE(corner.affecting, src)
				effect_str -= corner

	var/list/datum/lighting_corner/gone_corners = effect_str - corners
	for (var/datum/lighting_corner/corner as anything in gone_corners)
		REMOVE_CORNER(corner)
		LAZYREMOVE(corner.affecting, src)
	effect_str -= gone_corners

	applied_lum_r = lum_r
	applied_lum_g = lum_g
	applied_lum_b = lum_b

	UNSETEMPTY(src.effect_str)

#undef EFFECT_UPDATE
#undef LUM_FALLOFF
#undef REMOVE_CORNER
#undef APPLY_CORNER
#undef SETUP_CORNERS_REMOVAL_CACHE
#undef SETUP_CORNERS_CACHE
#undef GENERATE_MISSING_CORNERS
