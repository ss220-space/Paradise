/client
	var/list/parallax_layers
	var/list/parallax_layers_cached
	var/atom/movable/movingmob
	var/turf/previous_turf
	var/dont_animate_parallax //world.time of when we can state animate()ing parallax again
	var/last_parallax_shift //world.time of last update
	var/parallax_throttle = 0 //ds between updates
	var/parallax_movedir = 0
	var/parallax_layers_max = 4
	var/parallax_animate_timer


/datum/hud/proc/create_parallax()
	var/client/C = mymob.client
	if(!apply_parallax_pref())
		for(var/atom/movable/screen/plane_master/parallax as anything in get_true_plane_masters(PLANE_SPACE_PARALLAX))
			parallax.hide_plane(mymob)
		return

	for(var/atom/movable/screen/plane_master/parallax as anything in get_true_plane_masters(PLANE_SPACE_PARALLAX))
		parallax.unhide_plane(mymob)

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

	C.screen |= (C.parallax_layers)
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
	C.screen -= (C.parallax_layers_cached)
	for(var/atom/movable/screen/plane_master/plane_master as anything in get_true_plane_masters(PLANE_SPACE))
		plane_master.color = initial(plane_master.color)
	C.parallax_layers = null


/datum/hud/proc/apply_parallax_pref()
	var/client/C = mymob.client
	if(C.prefs)
		var/pref = C.prefs.parallax
		if(isnull(pref))
			pref = PARALLAX_HIGH
		switch(C.prefs.parallax)
			if(PARALLAX_INSANE)
				C.parallax_throttle = FALSE
				C.parallax_layers_max = 5
				return TRUE

			if(PARALLAX_MED)
				C.parallax_throttle = PARALLAX_DELAY_MED
				C.parallax_layers_max = 3
				return TRUE

			if(PARALLAX_LOW)
				C.parallax_throttle = PARALLAX_DELAY_LOW
				C.parallax_layers_max = 1
				return TRUE

			if(PARALLAX_DISABLE)
				return FALSE

	//This is high parallax.
	C.parallax_throttle = PARALLAX_DELAY_DEFAULT
	C.parallax_layers_max = 4
	return TRUE


/datum/hud/proc/update_parallax_pref()
	if(!mymob.client)
		return
	remove_parallax()
	create_parallax()
	update_parallax()


// This sets which way the current shuttle is moving (returns true if the shuttle has stopped moving so the caller can append their animation)
// Well, it would if our shuttle code had dynamic areas
/datum/hud/proc/set_parallax_movedir(new_parallax_movedir, skip_windups)
	. = FALSE
	var/client/C = mymob.client
	if(new_parallax_movedir == C.parallax_movedir)
		return
	var/animatedir = new_parallax_movedir
	if(new_parallax_movedir == FALSE)
		var/animate_time = 0
		for(var/thing in C.parallax_layers)
			var/atom/movable/screen/parallax_layer/L = thing
			if(istype(L, /atom/movable/screen/parallax_layer/planet) && SSmapping.lavaland_theme?.planet_icon_state)
				L.icon_state = SSmapping.lavaland_theme.planet_icon_state
			else
				L.icon_state = initial(L.icon_state)
			L.update_o(C.view)
			var/T = PARALLAX_LOOP_TIME / L.speed
			if(T > animate_time)
				animate_time = T
		C.dont_animate_parallax = world.time + min(animate_time, PARALLAX_LOOP_TIME)
		animatedir = C.parallax_movedir

	var/matrix/newtransform
	switch(animatedir)
		if(NORTH)
			newtransform = matrix(1, 0, 0, 0, 1, 480)
		if(SOUTH)
			newtransform = matrix(1, 0, 0, 0, 1,-480)
		if(EAST)
			newtransform = matrix(1, 0, 480, 0, 1, 0)
		if(WEST)
			newtransform = matrix(1, 0,-480, 0, 1, 0)

	var/shortesttimer
	for(var/thing in C.parallax_layers)
		var/atom/movable/screen/parallax_layer/L = thing

		var/T = PARALLAX_LOOP_TIME / L.speed
		if(isnull(shortesttimer))
			shortesttimer = T
		if(T < shortesttimer)
			shortesttimer = T
		L.transform = newtransform
		animate(L, transform = matrix(), time = T, easing = QUAD_EASING | (new_parallax_movedir ? EASE_IN : EASE_OUT), flags = ANIMATION_END_NOW)
		if(new_parallax_movedir)
			L.transform = newtransform
			animate(transform = matrix(), time = T) //queue up another animate so lag doesn't create a shutter

	C.parallax_movedir = new_parallax_movedir
	if(C.parallax_animate_timer)
		deltimer(C.parallax_animate_timer)
	var/datum/callback/CB = CALLBACK(src, PROC_REF(update_parallax_motionblur), C, animatedir, new_parallax_movedir, newtransform)
	if(skip_windups)
		CB.Invoke()
	else
		C.parallax_animate_timer = addtimer(CB, min(shortesttimer, PARALLAX_LOOP_TIME), TIMER_CLIENT_TIME|TIMER_STOPPABLE)


/datum/hud/proc/update_parallax_motionblur(client/C, animatedir, new_parallax_movedir, matrix/newtransform)
	C.parallax_animate_timer = FALSE
	for(var/thing in C.parallax_layers)
		var/atom/movable/screen/parallax_layer/L = thing
		if(!new_parallax_movedir)
			animate(L)
			continue

		var/newstate = initial(L.icon_state)
		if(animatedir)
			if(animatedir == NORTH || animatedir == SOUTH)
				newstate += "_vertical"
			else
				newstate += "_horizontal"

		var/T = PARALLAX_LOOP_TIME / L.speed

		if(newstate in icon_states(L.icon))
			L.icon_state = newstate
			L.update_o(C.view)

		L.transform = newtransform

		animate(L, transform = L.transform, time = 0, loop = -1, flags = ANIMATION_END_NOW)
		animate(transform = matrix(), time = T)


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

	var/force
	if(!C.previous_turf || (C.previous_turf.z != posobj.z))
		C.previous_turf = posobj
		force = TRUE

	if(!force && world.time < C.last_parallax_shift+C.parallax_throttle)
		return

	//Doing it this way prevents parallax layers from "jumping" when you change Z-Levels.
	var/offset_x = posobj.x - C.previous_turf.x
	var/offset_y = posobj.y - C.previous_turf.y

	if(!offset_x && !offset_y && !force)
		return

	var/last_delay = world.time - C.last_parallax_shift
	last_delay = min(last_delay, C.parallax_throttle)
	C.previous_turf = posobj
	C.last_parallax_shift = world.time

	for(var/thing in C.parallax_layers)
		var/atom/movable/screen/parallax_layer/L = thing
		L.update_status(mymob)

		if(L.absolute)
			L.offset_x = -(posobj.x - SSparallax.planet_x_offset) * L.speed
			L.offset_y = -(posobj.y - SSparallax.planet_y_offset) * L.speed
		else
			L.offset_x -= offset_x * L.speed
			L.offset_y -= offset_y * L.speed

			if(L.offset_x > 240)
				L.offset_x -= 480
			if(L.offset_x < -240)
				L.offset_x += 480
			if(L.offset_y > 240)
				L.offset_y -= 480
			if(L.offset_y < -240)
				L.offset_y += 480

		L.screen_loc = "CENTER-7:[round(L.offset_x,1)],CENTER-7:[round(L.offset_y,1)]"


/atom/movable/proc/update_parallax_contents()
	if(length(client_mobs_in_contents))
		for(var/thing in client_mobs_in_contents)
			var/mob/M = thing
			if(M && M.client && M.hud_used && length(M.client.parallax_layers))
				M.hud_used.update_parallax()

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
	screen_loc = "CENTER-7,CENTER-7"
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
	var/countx = CEILING((viewscales[1] / 2) * parallax_scaler, 1) + 1
	var/county = CEILING((viewscales[2] / 2) * parallax_scaler, 1) + 1
	var/list/new_overlays = new
	for(var/x in -countx to countx)
		for(var/y in -county to county)
			if(x == 0 && y == 0)
				continue
			var/mutable_appearance/texture_overlay = mutable_appearance(icon, icon_state)
			texture_overlay.transform = matrix(1, 0, x * 480, 0, 1, y * 480)
			new_overlays += texture_overlay

	cut_overlays()
	add_overlay(new_overlays)


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
	update_status(boss.mob)

/atom/movable/screen/parallax_layer/planet/update_status(mob/M)
	var/turf/T = get_turf(M)
	if(is_station_level(T.z))
		invisibility = 0
	else
		invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/parallax_layer/planet/update_o()
	return //Shit wont move
