/client
	var/list/parallax_layers
	var/list/parallax_layers_cached
	var/atom/movable/screen/parallax_home/parallax_rock
	var/atom/movable/movingmob
	var/turf/previous_turf
	/// world.time of when we can state animate()ing parallax again
	var/dont_animate_parallax
	/// Direction our current area wants to move parallax
	var/parallax_movedir = 0
	/// How many parallax layers to show our client
	var/parallax_layers_max = 4
	/// Timers for the area directional animation, one for each layer
	var/list/parallax_animate_timers
	/// Do we want to do parallax animations at all?
	/// Exists to prevent laptop fires
	var/do_parallax_animations = TRUE


/datum/hud/proc/create_parallax()
	var/client/C = mymob.client
	if(!apply_parallax_pref())
		for(var/atom/movable/screen/plane_master/parallax as anything in get_true_plane_masters(PLANE_SPACE_PARALLAX))
			parallax.hide_plane(mymob)
		return

	for(var/atom/movable/screen/plane_master/parallax as anything in get_true_plane_masters(PLANE_SPACE_PARALLAX))
		parallax.unhide_plane(mymob)

	if(isnull(C.parallax_rock))
		C.parallax_rock = new(null, src)
	C.screen |= C.parallax_rock

	if(!length(C.parallax_layers_cached))
		C.parallax_layers_cached = list()
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/layer_1(null, src)
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/layer_2(null, src)
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/planet(null, src)
		if(SSparallax.random_layer)
			C.parallax_layers_cached += new SSparallax.random_layer(null, src)
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/layer_3(null, src)

	C.parallax_layers = C.parallax_layers_cached.Copy()

	if(length(C.parallax_layers) > C.parallax_layers_max)
		C.parallax_layers.len = C.parallax_layers_max

	C.parallax_rock.vis_contents = C.parallax_layers
	// We could do not do parallax for anything except the main plane group
	// This could be changed, but it would require refactoring this whole thing
	// And adding non client particular hooks for all the inputs, and I do not have the time I'm sorry :(
	for(var/atom/movable/screen/plane_master/plane_master as anything in get_true_plane_masters(PLANE_SPACE))
		plane_master.color = list(
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0,
			1, 1, 1, 1,
			0, 0, 0, 0
			)

/datum/hud/proc/remove_parallax()
	var/client/C = mymob.client
	C.screen -= (C.parallax_rock)
	for(var/atom/movable/screen/plane_master/plane_master as anything in get_true_plane_masters(PLANE_SPACE))
		plane_master.color = initial(plane_master.color)
	C.parallax_layers = null


/datum/hud/proc/apply_parallax_pref()
	var/client/C = mymob.client
	var/pref = C.prefs?.parallax || PARALLAX_HIGH
	switch(pref)
		if (PARALLAX_INSANE)
			C.parallax_layers_max = 5
			C.do_parallax_animations = TRUE
			return TRUE

		if(PARALLAX_HIGH)
			C.parallax_layers_max = 4
			C.do_parallax_animations = TRUE
			return TRUE

		if (PARALLAX_MED)
			C.parallax_layers_max = 3
			C.do_parallax_animations = TRUE
			return TRUE

		if (PARALLAX_LOW)
			C.parallax_layers_max = 1
			C.do_parallax_animations = FALSE
			return TRUE

		if (PARALLAX_DISABLE)
			return FALSE


/datum/hud/proc/update_parallax_pref()
	if(!mymob.client)
		return
	remove_parallax()
	create_parallax()
	update_parallax()


// This sets which way the current shuttle is moving (returns true if the shuttle has stopped moving so the caller can append their animation)
// Well, it would if our shuttle code had dynamic areas
/datum/hud/proc/set_parallax_movedir(new_parallax_movedir = NONE, skip_windups)
	. = FALSE
	var/client/C = mymob.client
	if(new_parallax_movedir == C.parallax_movedir)
		return

	var/animation_dir = new_parallax_movedir || C.parallax_movedir
	var/matrix/new_transform
	switch(animation_dir)
		if(NORTH)
			new_transform = matrix(1, 0, 0, 0, 1, 480)
		if(SOUTH)
			new_transform = matrix(1, 0, 0, 0, 1,-480)
		if(EAST)
			new_transform = matrix(1, 0, 480, 0, 1, 0)
		if(WEST)
			new_transform = matrix(1, 0,-480, 0, 1, 0)

	var/longest_timer = 0
	for(var/key in C.parallax_animate_timers)
		deltimer(C.parallax_animate_timers[key])
	C.parallax_animate_timers = list()
	for(var/atom/movable/screen/parallax_layer/layer as anything in C.parallax_layers)
		var/scaled_time = PARALLAX_LOOP_TIME / layer.speed
		if(new_parallax_movedir == NONE) // If we're stopping, we need to stop on the same dime, yeah?
			scaled_time = PARALLAX_LOOP_TIME
		longest_timer = max(longest_timer, scaled_time)

		if(skip_windups)
			update_parallax_motionblur(C, layer, new_parallax_movedir, new_transform)
			continue

		layer.transform = new_transform
		animate(layer, transform = matrix(), time = scaled_time, easing = QUAD_EASING | (new_parallax_movedir ? EASE_IN : EASE_OUT))
		if (new_parallax_movedir == NONE)
			continue
		//queue up another animate so lag doesn't create a shutter
		animate(transform = new_transform, time = 0)
		animate(transform = matrix(), time = scaled_time / 2)
		C.parallax_animate_timers[layer] = addtimer(CALLBACK(src, PROC_REF(update_parallax_motionblur), C, layer, new_parallax_movedir, new_transform), scaled_time, TIMER_CLIENT_TIME|TIMER_STOPPABLE)

	C.dont_animate_parallax = world.time + min(longest_timer, PARALLAX_LOOP_TIME)
	C.parallax_movedir = new_parallax_movedir

/datum/hud/proc/update_parallax_motionblur(client/C, atom/movable/screen/parallax_layer/layer, new_parallax_movedir, matrix/new_transform)
	if(!C)
		return
	C.parallax_animate_timers -= layer

	// If we are moving in a direction, we used the QUAD_EASING function with EASE_IN
	// This means our position function is x^2. This is always LESS then the linear we're using here
	// But if we just used the same time delay, our rate of change would mismatch. f'(1) = 2x for quad easing, rather then the 1 we get for linear
	// (This is because of how derivatives work right?)
	// Because of this, while our actual rate of change from before was PARALLAX_LOOP_TIME, our perceived rate of change was PARALLAX_LOOP_TIME / 2 (lower == faster).
	// Let's account for that here
	var/scaled_time = (PARALLAX_LOOP_TIME / layer.speed) / 2
	animate(layer, transform = new_transform, time = 0, loop = -1, flags = ANIMATION_END_NOW)
	animate(transform = matrix(), time = scaled_time)


/datum/hud/proc/update_parallax()
	var/client/C = mymob.client
	var/turf/posobj = get_turf(C.eye)
	if(!posobj)
		return
	var/area/areaobj = posobj.loc

	// Update the movement direction of the parallax if necessary (for shuttles)
	var/area/shuttle/SA = areaobj
	if(!SA || !SA.moving)
		set_parallax_movedir(0)
	else
		set_parallax_movedir(SA.parallax_movedir)

	var/force = FALSE
	if(!C.previous_turf || (C.previous_turf.z != posobj.z))
		C.previous_turf = posobj
		force = TRUE
	//Doing it this way prevents parallax layers from "jumping" when you change Z-Levels.
	var/offset_x = posobj.x - C.previous_turf.x
	var/offset_y = posobj.y - C.previous_turf.y

	if(!offset_x && !offset_y && !force)
		return

	var/glide_rate = round(world.icon_size / mymob.glide_size * world.tick_lag, world.tick_lag)
	C.previous_turf = posobj
	var/largest_change = max(abs(offset_x), abs(offset_y))
	var/max_allowed_dist = (glide_rate / world.tick_lag) + 1
	// If we aren't already moving/don't allow parallax, have made some movement, and that movement was smaller then our "glide" size, animate
	var/run_parralax = (C.do_parallax_animations && glide_rate && !areaobj.parallax_movedir && C.dont_animate_parallax <= world.time && largest_change <= max_allowed_dist)

	for(var/atom/movable/screen/parallax_layer/parallax_layer as anything in C.parallax_layers)
		parallax_layer.update_status(mymob)

		var/our_speed = parallax_layer.speed
		var/change_x
		var/change_y
		var/old_x = parallax_layer.offset_x
		var/old_y = parallax_layer.offset_y

		if(parallax_layer.absolute)
			// We use change here so the typically large absolute objects (just lavaland for now) don't jitter so much
			change_x = (posobj.x - SSparallax.planet_x_offset) * our_speed + old_x
			change_y = (posobj.y - SSparallax.planet_y_offset) * our_speed + old_y
		else
			change_x = offset_x * our_speed
			change_y = offset_y * our_speed

			// This is how we tile parralax sprites
			// It doesn't use change because we really don't want to animate this
			if(old_x - change_x > 240)
				parallax_layer.offset_x -= 480
				parallax_layer.pixel_w = parallax_layer.offset_x
			else if(old_x - change_x < -240)
				parallax_layer.offset_x += 480
				parallax_layer.pixel_w = parallax_layer.offset_x
			if(old_y - change_y > 240)
				parallax_layer.offset_y -= 480
				parallax_layer.pixel_z = parallax_layer.offset_y
			else if(old_y - change_y < -240)
				parallax_layer.offset_y += 480
				parallax_layer.pixel_z = parallax_layer.offset_y

		parallax_layer.offset_x -= change_x
		parallax_layer.offset_y -= change_y

		// Now that we have our offsets, let's do our positioning
		// We're going to use an animate to "glide" that last movement out, so it looks nicer
		// Don't do any animates if we're not actually moving enough distance yeah? thanks lad
		if(run_parralax && (largest_change * our_speed > 1))
			animate(parallax_layer, pixel_w = round(parallax_layer.offset_x, 1), pixel_z = round(parallax_layer.offset_y, 1), time = glide_rate)
		else
			parallax_layer.pixel_w = round(parallax_layer.offset_x, 1)
			parallax_layer.pixel_z = round(parallax_layer.offset_y, 1)

/atom/movable/proc/update_parallax_contents()
	if(length(client_mobs_in_contents))
		for(var/thing in client_mobs_in_contents)
			var/mob/M = thing
			if(M && M.client && M.hud_used && length(M.client.parallax_layers))
				M.hud_used.update_parallax()

// Root object for parallax, all parallax layers are drawn onto this
INITIALIZE_IMMEDIATE(/atom/movable/screen/parallax_home)
/atom/movable/screen/parallax_home
	icon = null
	blend_mode = BLEND_ADD
	plane = PLANE_SPACE_PARALLAX
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// We need parallax to always pass its args down into initialize, so we immediate init it
INITIALIZE_IMMEDIATE(/atom/movable/screen/parallax_layer)
/atom/movable/screen/parallax_layer
	icon = 'icons/effects/parallax.dmi'
	var/speed = 1
	var/offset_x = 0
	var/offset_y = 0
	var/absolute = FALSE
	blend_mode = BLEND_ADD
	plane = PLANE_SPACE_PARALLAX
	appearance_flags = APPEARANCE_UI | KEEP_TOGETHER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/atom/movable/screen/parallax_layer/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	// Parallax layers are independant of hud, they care about client
	// Not doing this will just create a bunch of hard deletes
	hud = null
	var/client/boss = hud_owner?.mymob?.client
	if(!boss) // If this typepath all starts to harddel your culprit is likely this
		return INITIALIZE_HINT_QDEL
	// I do not want to know bestie
	var/view = boss.view || world.view
	update_o(view)
	RegisterSignal(boss, COMSIG_VIEW_SET, PROC_REF(on_view_change))

/atom/movable/screen/parallax_layer/proc/on_view_change(datum/source, new_size)
	SIGNAL_HANDLER
	update_o(new_size)

/atom/movable/screen/parallax_layer/proc/update_o(view)
	if(!view)
		view = world.view
	var/static/parallax_scaler = world.icon_size / 480

	// Turn the view size into a grid of correctly scaled overlays
	var/list/viewscales = getviewsize(view)
	// This could be half the size but we need to provide space for parallax movement on mob movement, and movement on scroll from shuttles, so like this instead
	var/countx = (CEILING((viewscales[1] / 2) * parallax_scaler, 1) + 1)
	var/county = (CEILING((viewscales[2] / 2) * parallax_scaler, 1) + 1)
	var/list/new_overlays = new
	for(var/x in -countx to countx)
		for(var/y in -county to county)
			if(x == 0 && y == 0)
				continue
			var/mutable_appearance/texture_overlay = mutable_appearance(icon, icon_state)
			texture_overlay.pixel_w += 480 * x
			texture_overlay.pixel_z += 480 * y
			new_overlays += texture_overlay

	cut_overlays()
	add_overlay(new_overlays)


// I left this so if the player re-enables parallax, it will correctly update parallax, instead "flicks" on the first move
/atom/movable/screen/parallax_layer/proc/update_status(mob/M)
	return


/atom/movable/screen/parallax_layer/layer_1
	icon_state = "layer1"
	speed = 0.6
	layer = 1


/atom/movable/screen/parallax_layer/layer_2
	icon_state = "layer2"
	speed = 1
	layer = 2


/atom/movable/screen/parallax_layer/layer_3
	icon_state = "layer3"
	speed = 1.4
	layer = 3


/atom/movable/screen/parallax_layer/random
	blend_mode = BLEND_OVERLAY
	speed = 3
	layer = 3


/atom/movable/screen/parallax_layer/random/space_gas
	icon_state = "space_gas"


/atom/movable/screen/parallax_layer/random/space_gas/Initialize(mapload, datum/hud/hud_owner)
	..()
	add_atom_colour(SSparallax.random_parallax_color, ADMIN_COLOUR_PRIORITY)


/atom/movable/screen/parallax_layer/random/asteroids
	icon_state = "asteroids"
	layer = 4


/atom/movable/screen/parallax_layer/planet
	icon_state = "planet"
	blend_mode = BLEND_OVERLAY
	absolute = TRUE //Status of seperation
	speed = 3
	layer = 30

/atom/movable/screen/parallax_layer/planet/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(SSmapping.lavaland_theme?.planet_icon_state)
		icon_state = SSmapping.lavaland_theme.planet_icon_state

	var/client/boss = hud_owner?.mymob?.canon_client
	if(!boss)
		return

	var/static/list/connections = list(
		COMSIG_MOVABLE_Z_CHANGED = PROC_REF(on_z_change),
		COMSIG_MOB_LOGOUT = PROC_REF(on_mob_logout),
	)
	AddComponent(/datum/component/connect_mob_behalf, boss, connections) // I have a feeling that this shit doesn't work
	update_status(hud_owner?.mymob)

/atom/movable/screen/parallax_layer/planet/proc/on_mob_logout(mob/source)
	SIGNAL_HANDLER
	var/client/boss = source.canon_client
	update_status(boss.mob)

/atom/movable/screen/parallax_layer/planet/proc/on_z_change(mob/source)
	SIGNAL_HANDLER
	var/client/boss = source.client
	if(boss)
		update_status(boss.mob)

/atom/movable/screen/parallax_layer/planet/update_status(mob/M)
	var/turf/T = get_turf(M)
	if(is_station_level(T.z))
		invisibility = 0
	else
		invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/parallax_layer/planet/update_o()
	return //Shit wont move
