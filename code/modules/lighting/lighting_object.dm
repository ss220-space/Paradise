/datum/lighting_object
	///the underlay we are currently applying to our turf to apply light
	var/mutable_appearance/current_underlay

	///whether we are already in the SSlighting.objects_queue list
	var/needs_update = FALSE

	var/mutable_appearance/additive_underlay
	///the turf that our light is applied to
	var/turf/affected_turf

// Global list of lighting underlays, indexed by z level
GLOBAL_LIST_EMPTY(default_lighting_underlays_by_z)

/datum/lighting_object/New(turf/source)
	if(!isturf(source))
		qdel(src, force=TRUE)
		stack_trace("a lighting object was assigned to [source], a non turf! ")
		return
	. = ..()

	current_underlay = new(GLOB.default_lighting_underlays_by_z[source.z])

	affected_turf = source
	if (affected_turf.lighting_object)
		qdel(affected_turf.lighting_object, force = TRUE)
		stack_trace("a lighting object was assigned to a turf that already had a lighting object!")

	affected_turf.lighting_object = src
	affected_turf.luminosity = 0

	// This path is really hot. this is faster
	// Really this should be a global var or something, but lets not think about that yes?
	if(CONFIG_GET(flag/starlight))
		for(var/turf/space/space_tile in RANGE_TURFS(1, affected_turf))
			space_tile.update_starlight()

	additive_underlay = mutable_appearance(LIGHTING_ICON, "light", FLOAT_LAYER, LIGHTING_PLANE_ADDITIVE, 255, RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM)
	additive_underlay.blend_mode = BLEND_ADD

	needs_update = TRUE
	SSlighting.objects_queue += src

/datum/lighting_object/Destroy(force)
	if (!force)
		return QDEL_HINT_LETMELIVE
	SSlighting.objects_queue -= src
	if (isturf(affected_turf))
		affected_turf.lighting_object = null
		affected_turf.luminosity = 1
		affected_turf.underlays -= current_underlay
		myturf.underlays -= additive_underlay
	affected_turf = null
	return ..()

/datum/lighting_object/proc/update()
	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	// See LIGHTING_CORNER_DIAGONAL in lighting_corner.dm for why these values are what they are.
	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/turf/affected_turf = src.affected_turf
	var/datum/lighting_corner/red_corner = affected_turf.lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/green_corner = affected_turf.lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/blue_corner = affected_turf.lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/alpha_corner = affected_turf.lighting_corner_NE || dummy_lighting_corner

	var/max = max(red_corner.largest_color_luminosity, green_corner.largest_color_luminosity, blue_corner.largest_color_luminosity, alpha_corner.largest_color_luminosity)

	#if LIGHTING_SOFT_THRESHOLD != 0
	var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points™?, it won't even be a flat 0.
	// This number is mostly arbitrary.
	var/set_luminosity = max > 1e-6
	#endif

	var/mutable_appearance/current_underlay = src.current_underlay
	affected_turf.underlays -= current_underlay
	if(red_corner.cache_r & green_corner.cache_r & blue_corner.cache_r & alpha_corner.cache_r && \
		(red_corner.cache_g + green_corner.cache_g + blue_corner.cache_g + alpha_corner.cache_g + \
		red_corner.cache_b + green_corner.cache_b + blue_corner.cache_b + alpha_corner.cache_b == 8))
		//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = "transparent_lighting_object"
		current_underlay.color = null
		affected_turf.underlays += current_underlay
	else if(!set_luminosity)
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = "dark_lighting_object"
		current_underlay.color = null
		affected_turf.underlays += current_underlay
	else
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = null
		current_underlay.color = list(
			red_corner.cache_r, red_corner.cache_g, red_corner.cache_b, 00,
			green_corner.cache_r, green_corner.cache_g, green_corner.cache_b, 00,
			blue_corner.cache_r, blue_corner.cache_g, blue_corner.cache_b, 00,
			alpha_corner.cache_r, alpha_corner.cache_g, alpha_corner.cache_b, 00,
			00, 00, 00, 01
		)

	// Of note. Most of the cost in this proc is here, I think because color matrix'd underlays DO NOT cache well, which is what adding to underlays does
	// We use underlays because objects on each tile would fuck with maptick. if that ever changes, use an object for this instead
	affected_turf.underlays += current_underlay

	if(cr.applying_additive || cg.applying_additive || cb.applying_additive || ca.applying_additive)
		affected_turf.underlays -= additive_underlay
		additive_underlay.icon_state = "light"
		var/arr = cr.add_r
		var/arb = cr.add_b
		var/arg = cr.add_g

		var/agr = cg.add_r
		var/agb = cg.add_b
		var/agg = cg.add_g

		var/abr = cb.add_r
		var/abb = cb.add_b
		var/abg = cb.add_g

		var/aarr = ca.add_r
		var/aarb = ca.add_b
		var/aarg = ca.add_g

		additive_underlay.color = list(
			arr, arg, arb, 00,
			agr, agg, agb, 00,
			abr, abg, abb, 00,
			aarr, aarg, aarb, 00,
			00, 00, 00, 01
		)
		affected_turf.underlays += additive_underlay
	else
		affected_turf.underlays -= additive_underlay

	affected_turf.luminosity = set_luminosity

