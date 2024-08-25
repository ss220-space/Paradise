/turf/simulated/openspace
	name = "open space"
	desc = "Watch your step!"
	icon = 'icons/turf/space.dmi'
	icon_state = "openspace" //transparent
	baseturf = /turf/simulated/openspace
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pathing_pass_method = TURF_PATHING_PASS_PROC
	var/can_cover_up = TRUE
	var/can_build_on = TRUE

	// PARACODE
	thermal_conductivity = 0.040
	heat_capacity = 10000
	transparent_floor = TURF_FULLTRANSPARENT // bruh
	intact = FALSE //this means wires go on top


/turf/simulated/openspace/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0

/turf/simulated/openspace/lavaland
	temperature = 300
	oxygen = 14
	nitrogen = 23
	planetary_atmos = TRUE

/turf/simulated/openspace/snow_atmosphere
	oxygen = 22
	nitrogen = 82
	temperature = 180
	planetary_atmos = TRUE

/turf/simulated/openspace/Initialize(mapload)
	. = ..()
	if(!GET_TURF_BELOW(src))
		stack_trace("[src] was inited as openspace with nothing below it at ([x], [y], [z])")
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_atom_created))
	return INITIALIZE_HINT_LATELOAD

/turf/simulated/openspace/LateInitialize()
	. = ..()
	AddElement(/datum/element/turf_z_transparency)

/turf/simulated/openspace/ChangeTurf(path, defer_change, keep_icon, ignore_air, copy_existing_baseturf)
	UnregisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)
	return ..()

/**
 * Prepares a moving movable to be precipitated if Move() is successful.
 * This is done in Enter() and not Entered() because there's no easy way to tell
 * if the latter was called by Move() or forceMove() while the former is only called by Move().
 */
/turf/simulated/openspace/Enter(atom/movable/movable, atom/oldloc)
	. = ..()
	if(.)
		//higher priority than CURRENTLY_Z_FALLING so the movable doesn't fall on Entered()
		movable.set_currently_z_moving(CURRENTLY_Z_FALLING_FROM_MOVE)

///Makes movables fall when forceMove()'d to this turf.
/turf/simulated/openspace/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	var/mob/mob = arrived
	if(ismob(mob) && mob.buckled && mob.currently_z_moving == CURRENTLY_Z_MOVING_GENERIC)
		return
	if(arrived.set_currently_z_moving(CURRENTLY_Z_FALLING))
		zFall(arrived, falling_from_move = TRUE)
/**
 * Drops movables spawned on this turf only after they are successfully initialized.
 * so flying mobs, qdeleted movables and things that were moved somewhere else during
 * Initialize() won't fall by accident.
 */
/turf/simulated/openspace/proc/on_atom_created(datum/source, atom/created_atom)
	SIGNAL_HANDLER
	if(ismovable(created_atom))
		//Drop it only when it's finished initializing, not before.
		addtimer(CALLBACK(src, PROC_REF(zfall_if_on_turf), created_atom), 0 SECONDS)

/turf/simulated/openspace/proc/zfall_if_on_turf(atom/movable/movable)
	if(QDELETED(movable) || movable.loc != src)
		return
	zFall(movable)

/turf/simulated/openspace/zAirIn()
	return TRUE

/turf/simulated/openspace/zAirOut()
	return TRUE

/turf/simulated/openspace/proc/check_fall()
	for(var/atom/movable/M as anything in contents)
		zfall_if_on_turf(M)

// this is open NON-floor.
/turf/simulated/openspace/zPassIn(direction)
	if(direction == DOWN)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_IN_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_IN_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/simulated/openspace/zPassOut(direction)
	if(direction == DOWN)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_OUT_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_OUT_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/simulated/openspace/proc/CanCoverUp()
	return can_cover_up

/turf/simulated/openspace/proc/CanBuildHere()
	return can_build_on


/turf/simulated/openspace/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !CanBuildHere())
		return .

	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/rods = I
		if(locate(/obj/structure/lattice/catwalk, src))
			to_chat(user, span_warning("There is already a catwalk here!"))
			return .
		if(locate(/obj/structure/lattice, src))
			if(!rods.use(1))
				to_chat(user, span_warning("You need two rods to build a catwalk!"))
				return .
			to_chat(user, span_notice("You construct a catwalk."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/catwalk(src)
			return .|ATTACK_CHAIN_SUCCESS
		if(!rods.use(1))
			to_chat(user, span_warning("You need one rod to build a lattice."))
			return .
		to_chat(user, span_notice("Constructing support lattice..."))
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		ReplaceWithLattice()
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/plasteel = I
		var/obj/structure/lattice/lattice = locate() in src
		if(!lattice)
			to_chat(user, span_warning("The plating is going to need some support! Place metal rods first."))
			return .
		if(!plasteel.use(1))
			to_chat(user, span_warning("You need one floor tile to build a floor!"))
			return .
		qdel(lattice)
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		to_chat(user, span_notice("You build a floor."))
		ChangeTurf(/turf/simulated/floor/plating)
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/fireproof_rods))
		var/obj/item/stack/fireproof_rods/rods = I
		if(locate(/obj/structure/lattice/catwalk/fireproof, src))
			to_chat(user, span_warning("Здесь уже есть мостик!"))
			return .
		var/obj/structure/lattice/fireproof/lattice = locate() in src
		if(!lattice)
			if(!rods.use(1))
				to_chat(user, span_warning("Вам нужен один огнеупорный стержень для постройки решётки!"))
				return .
			to_chat(user, span_notice("Вы установили прочную решётку."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/fireproof(src)
			return .|ATTACK_CHAIN_SUCCESS
		if(!rods.use(2))
			to_chat(user, span_warning("Вам нужно два огнеупорных стержня для постройки мостика!"))
			return .
		qdel(lattice)
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		to_chat(user, span_notice("Вы установили огнеупорный мостик."))
		new /obj/structure/lattice/catwalk/fireproof(src)
		return .|ATTACK_CHAIN_SUCCESS


/turf/simulated/openspace/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return TRUE
	return FALSE

/turf/simulated/openspace/singularity_act()
	return

/turf/simulated/openspace/acid_act(acidpwr, acid_volume)
	return

/turf/simulated/openspace/rcd_construct_act(mob/user, obj/item/rcd/our_rcd, rcd_mode)
	. = ..()
	if(rcd_mode != RCD_MODE_TURF)
		return RCD_NO_ACT
	if(our_rcd.useResource(1, user))
		to_chat(user, "Building Floor...")
		playsound(get_turf(our_rcd), our_rcd.usesound, 50, 1)
		add_attack_logs(user, src, "Constructed floor with RCD")
		ChangeTurf(our_rcd.floor_type)
		return RCD_ACT_SUCCESSFULL
	to_chat(user, span_warning("ERROR! Not enough matter in unit to construct this floor!"))
	playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
	return RCD_ACT_FAILED

/turf/simulated/openspace/bullet_act(obj/item/projectile/P, def_zone)
	return -1

// Every new proc that should be edited or added here. Also needs to be copied into /turf/space/openspace. I'm not sorry.

/turf/simulated/openspace/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	var/atom/movable/our_movable = pass_info.caller_ref.resolve()
	if(our_movable && !our_movable.can_z_move(DOWN, src, null, ZMOVE_FALL_FLAGS)) //If we can't fall here (flying/lattice), it's fine to path through
		return TRUE
	return FALSE

