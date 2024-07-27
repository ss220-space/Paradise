// Used by /turf/simulated/floor/indestructible/upperlevel as a reference for where the other floor is
/obj/effect/levelref
	name = "level reference"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	invisibility = INVISIBILITY_ABSTRACT

	var/id = null
	var/obj/effect/levelref/other = null
	var/offset_x
	var/offset_y
	var/offset_z
	var/global/list/levels[0]

/obj/effect/levelref/New()
	..()
	levels += src

/obj/effect/levelref/Initialize()
	..()
	for(var/obj/effect/levelref/O in levels)
		if(id == O.id && O != src)
			other = O
			update_offset()
			O.other = src
			O.update_offset()
			for(var/turf/simulated/floor/indestructible/upperlevel/U in get_area(loc))
				U.init(src)
			return

/obj/effect/levelref/Destroy()
	levels -= src
	return ..()

/obj/effect/levelref/proc/update_offset()
	offset_x = other.x - x
	offset_y = other.y - y
	offset_z = other.z - z

// Used by /turf/simulated/floor/indestructible/upperlevel and /obj/effect/view_portal/visual
// to know if the world changed on the remote side
/obj/effect/portal_sensor
	invisibility = INVISIBILITY_ABSTRACT
	var/light_hash = -1
	var/triggered_this_tick = 0
	var/datum/owner			// owner that receive signals
	var/list/params[0]		// what to send to the main object to indicate which sensor
	var/trigger_limit = 5	// number of time we're allowed to trigger per ptick


/obj/effect/portal_sensor/Initialize(mapload, owner, ...)
	. = ..()
	src.owner = owner
	if(args.len >= 3)
		params = args.Copy(3)
	START_PROCESSING(SSobj, src)
	trigger()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/portal_sensor/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/effect/portal_sensor/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(trigger))


/obj/effect/portal_sensor/proc/on_exited(datum/source, atom/movable/departed, atom/newLoc)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(trigger))


/obj/effect/portal_sensor/process()
	// check_light()
	if(triggered_this_tick >= trigger_limit)
		call(owner, "trigger")(arglist(params))
	triggered_this_tick = 0

/obj/effect/portal_sensor/proc/trigger()
	triggered_this_tick++
	if(triggered_this_tick < trigger_limit)
		call(owner, "trigger")(arglist(params))

/* Знаю что это отключено и свет будет ужесан. Таков рефактор.
/obj/effect/portal_sensor/proc/check_light()
	var/turf/T = loc
	if(istype(T) && T.lighting_object && !T.lighting_object.needs_update)
		var/atom/movable/lighting_object/O = T.lighting_object
		var/hash = 0

		for(var/lighting_corner in O)
			var/datum/lighting_corner/C = lighting_corner
			hash = hash + C.lum_r + C.lum_g + C.lum_b

		if(hash != light_hash)
			light_hash = hash
			trigger()
	else
		if(light_hash != -1)
			light_hash = -1
			trigger()
*/

// for second floor showing floor below
/turf/simulated/floor/indestructible/upperlevel
	icon = 'icons/turf/areas.dmi'
	icon_state = "dark128"
	layer = AREA_LAYER + 0.5
	appearance_flags = TILE_BOUND|KEEP_TOGETHER|LONG_GLIDE
	var/turf/lower_turf
	var/obj/effect/portal_sensor/sensor

/turf/simulated/floor/indestructible/upperlevel/New()
	..()
	var/obj/effect/levelref/R = locate() in get_area(src)
	if(R && R.other)
		init(R)

/turf/simulated/floor/indestructible/upperlevel/Destroy()
	QDEL_NULL(sensor)
	return ..()

/turf/simulated/floor/indestructible/upperlevel/proc/init(var/obj/effect/levelref/R)
	lower_turf = locate(x + R.offset_x, y + R.offset_y, z + R.offset_z)
	if(lower_turf)
		sensor = new(lower_turf, src)

/turf/simulated/floor/indestructible/upperlevel/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(ismovable(arrived))
		if(isliving(arrived))
			var/mob/living/mob = arrived
			mob.emote("scream")
			mob.SpinAnimation(5, 1)
		arrived.forceMove(lower_turf)

/turf/simulated/floor/indestructible/upperlevel/attack_ghost(mob/user)
	user.forceMove(lower_turf)

/turf/simulated/floor/indestructible/upperlevel/proc/trigger()
	name = lower_turf.name
	desc = lower_turf.desc

	// render each atom
	underlays.Cut()
	for(var/X in list(lower_turf) + lower_turf.contents)
		var/atom/A = X
		if(A && A.invisibility <= SEE_INVISIBLE_LIVING)
			var/image/I = image(A, layer = AREA_LAYER + A.layer * 0.01, dir = A.dir)
			I.pixel_x = A.pixel_x
			I.pixel_y = A.pixel_y
			underlays += I

/obj/effect/visual_portal
	name = "???"
	desc = "You'll have to get closer to clearly see what this is."
	icon = 'icons/misc/view_portal.dmi'
	icon_state = "arrow"
	opacity = TRUE
	density = TRUE
	anchored = TRUE
	appearance_flags = TILE_BOUND|KEEP_TOGETHER|LONG_GLIDE
	plane = ABOVE_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	var/id = null // used to connect to "other" visual portal

	var/obj/effect/visual_portal/other // the other visual portal we will link to
	var/distance = 6 // dist that we render out
	var/radius = 3 // dist we render on other axis, in each direction
	var/frustrum = FALSE // if TRUE, get wider and wider at each step outward. Like trapezium!
	var/stepout = TRUE // if TRUE, it'll make step forward dir for view.
	var/teleport = TRUE // determines if bumping of ghost-clicking should teleport into "other" portal loc

	var/list/viewing_turfs = list()

/obj/effect/visual_portal/Initialize(mapload)
	. = ..()
	GLOB.visual_portals += src
	if(!id)
		qdel(src)
		return
	icon_state = null
	for(var/obj/effect/visual_portal/other_portal as anything in GLOB.visual_portals)
		if(other_portal == src || other_portal.other || other_portal.z != z)
			continue // z comparsion needed so no parallax will "effect" our visual
		if(id == other_portal.id)
			other = other_portal
			other_portal.other = src
			create_view()
			other_portal.create_view()
			return

/obj/effect/visual_portal/Destroy()
	. = ..()
	GLOB.visual_portals -= src

// Creates view and adds it to his own vis_content
/obj/effect/visual_portal/proc/create_view(reset_view = FALSE)
	if(!distance || !radius)
		return
	// setup references
	var/crossdir = angle2dir((dir2angle(dir) + 90) % 360)

	// setup far turfs
	var/turf/T1 = get_turf(other)
	if(stepout) // step forward
		T1 = get_step(T1, dir)
	var/turf/T2 = T1

	for(var/i in 1 to radius)
		T1 = get_step(T1, crossdir)
		T2 = get_step(T2, GetOppositeDir(crossdir))
	if(frustrum)
		// make a trapezium, with length dist, short end radius*2 long,
		// and 45 degree angles
		viewing_turfs = block(T1, T2)
		for(var/i in 1 to distance)
			T1 = get_step(get_step(T1, dir), crossdir)
			T2 = get_step(get_step(T2, dir), GetOppositeDir(crossdir))
			viewing_turfs += block(T1, T2)
	else
		// else make a box dist x radius*2
		for(var/i in 1 to distance)
			T2 = get_step(T2, dir)
		viewing_turfs = block(T1, T2)


	if(reset_view)
		vis_contents.Cut()
	vis_contents += viewing_turfs

	// Now we need to "center" it
	var/width = radius + (distance * frustrum)
	switch(dir)
		if(NORTH)
			pixel_x = -width * world.icon_size
			pixel_y = world.icon_size
		if(SOUTH)
			pixel_x = -width * world.icon_size
			pixel_y = -distance * world.icon_size - world.icon_size
		if(WEST)
			pixel_x = -distance * world.icon_size - world.icon_size
			pixel_y = -width * world.icon_size
		if(EAST)
			pixel_x = world.icon_size
			pixel_y = -width * world.icon_size

/obj/effect/visual_portal/Bumped(atom/movable/moving_atom)
	. = ..()
	if(!teleport)
		return
	// make the person glide onto the dest, giving a smooth transition
	var/ox = moving_atom.x - x
	var/oy = moving_atom.y - y
	moving_atom.forceMove(locate(other.x + ox, other.y + oy, other.z))
	sleep(1)
	moving_atom.forceMove(get_turf(other.loc))

/obj/effect/visual_portal/attack_ghost(mob/user)
	if(!teleport)
		return
	user.forceMove(get_turf(other.loc))
