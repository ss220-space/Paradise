/turf/space/transit
	icon_state = "black_arrow"
	dir = SOUTH
	plane = PLANE_SPACE

/turf/space/transit/north
	dir = NORTH

/turf/space/transit/east
	dir = EAST

/turf/space/transit/south
	dir = SOUTH

/turf/space/transit/west
	dir = WEST


/turf/space/transit/attackby(obj/item/I, mob/user, params)
	//Overwrite because we dont want people building rods in space.
	return ATTACK_CHAIN_BLOCKED_ALL


/turf/space/transit/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(!arrived)
		return
	if(!arrived.simulated || istype(arrived, /obj/docking_port))
		return //this was fucking hilarious, the docking ports were getting thrown to random Z-levels
	var/max = world.maxx-TRANSITIONEDGE
	var/min = 1+TRANSITIONEDGE

	//now select coordinates for a border turf
	var/_x
	var/_y
	switch(dir)
		if(SOUTH)
			_x = rand(min,max)
			_y = max
		if(WEST)
			_x = max
			_y = rand(min,max)
		if(EAST)
			_x = min
			_y = rand(min,max)
		else
			_x = rand(min,max)
			_y = min

	var/list/levels_available = get_all_linked_levels_zpos()
	var/turf/T = locate(_x, _y, pick(levels_available))
	arrived.forceMove(T)
	arrived.newtonian_move(dir)


/turf/space/transit/rpd_act()
	return

/turf/space/transit/rcd_act()
	return RCD_NO_ACT


/turf/space/transit/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/turf/space/transit/update_icon_state()
	var/p = 9
	var/angle = 0
	var/state = 1
	switch(dir)
		if(NORTH)
			angle = 180
			state = ((-p*x+y) % 15) + 1
			if(state < 1)
				state += 15
		if(EAST)
			angle = 90
			state = ((x+p*y) % 15) + 1
		if(WEST)
			angle = -90
			state = ((x-p*y) % 15) + 1
			if(state < 1)
				state += 15
		else
			state =	((p*x+y) % 15) + 1

	icon_state = "speedspace_ns_[state]"
	transform = turn(matrix(), angle)

/turf/space/transit/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	. = ..()
