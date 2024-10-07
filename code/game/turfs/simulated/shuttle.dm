/turf/simulated/wall/shuttle
	name = "wall"
	desc = "A light-weight titanium wall used in shuttles."
	icon = 'icons/turf/walls/shuttle/shuttle_wall.dmi'
	icon_state = "shuttle-0"
	base_icon_state = "shuttle"
	explosion_block = 3
	explosion_vertical_block = 2
	smooth = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	smoothing_groups = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_TITANIUM_WALLS + SMOOTH_GROUP_PLASTITANIUM_WALLS
	canSmoothWith = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE + SMOOTH_GROUP_FILLER + SMOOTH_GROUP_TITANIUM_WALLS + SMOOTH_GROUP_PLASTITANIUM_WALLS + SMOOTH_GROUP_TRANSPARENT_FLOOR
	thermal_conductivity = 0.05
	heat_capacity = 0

/turf/simulated/wall/shuttle/dismantle_wall(devastated = 0, explode = 0)
	return

/turf/simulated/wall/shuttle/take_damage(dam)
	return

/turf/simulated/wall/shuttle/welder_act()
	return

/turf/simulated/wall/shuttle/ex_act(severity)
	return

/turf/simulated/wall/shuttle/blob_act(obj/structure/blob/B)
	return

/turf/simulated/wall/shuttle/singularity_act()
	return

/turf/simulated/wall/shuttle/singularity_pull(S, current_size)
	return

/turf/simulated/wall/shuttle/burn_down()
	return


/turf/simulated/wall/shuttle/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_BLOCKED_ALL


/turf/simulated/wall/shuttle/attack_hand(mob/user)
	return

/turf/simulated/wall/shuttle/attack_animal(mob/living/simple_animal/M)
	return

/turf/simulated/wall/shuttle/mech_melee_attack(obj/mecha/M)
	return

/turf/simulated/wall/shuttle/rpd_act()
	return

/turf/simulated/wall/shuttle/rcd_act()
	return RCD_NO_ACT

/turf/simulated/wall/shuttle/acid_act(acidpwr, acid_volume, acid_id)
	return

/turf/simulated/wall/shuttle/try_decon(obj/item/I, mob/user, params)
	return

/turf/simulated/wall/shuttle/thermitemelt(mob/user, time)
	return

/turf/simulated/wall/shuttle/nodiagonal
	icon_state = "shuttle-15"

/turf/simulated/wall/shuttle/nosmooth
	icon_state = "shuttle_ns"
	smooth = NONE

/turf/simulated/wall/shuttle/onlyselfsmooth
	canSmoothWith = SMOOTH_GROUP_SHUTTLE_PARTS

/turf/simulated/wall/shuttle/onlyselfsmooth/nodiagonal
	icon_state = "shuttle-15"

/turf/simulated/wall/shuttle/overspace
	icon_state = "overspace"
	fixed_underlay = list("space"=1)


/turf/simulated/wall/shuttle/copyTurf(turf/T)
	. = ..()
	T.transform = transform

/turf/simulated/wall/shuttle/rpd_act(mob/user, obj/item/rpd/our_rpd)
	if(our_rpd.mode == RPD_DELETE_MODE)//No pipes on shuttles
		our_rpd.delete_all_pipes(user, src)

/turf/simulated/wall/shuttle/narsie_act()
	if(prob(20))
		ChangeTurf(/turf/simulated/wall/cult)


// sub-type to be used for interior shuttle walls
// won't get an underlay of the destination turf on shuttle move
// it's underlay must be preadded by using underlay_floor variables
/turf/simulated/wall/shuttle/nosmooth/interior
	var/underlay_floor_icon = null
	var/underlay_floor_icon_state = null
	var/underlay_floor_dir = 2

/turf/simulated/wall/shuttle/nosmooth/interior/Initialize()
	. = ..()
	if(underlay_floor_icon && underlay_floor_icon_state)
		var/image/floor_underlay = image(underlay_floor_icon,,underlay_floor_icon_state,,underlay_floor_dir)
		underlays.Cut()
		underlays.Add(floor_underlay)

/turf/simulated/wall/shuttle/nosmooth/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(T.color != color)
		T.color = color
	if(T.dir != dir)
		T.setDir(dir)
	T.transform = transform
	return T

//ПОЛЫ//

/turf/simulated/floor/shuttle
	name = "floor"
	icon = 'icons/turf/shuttle/floors.dmi'
	icon_state = "floor"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY


/turf/simulated/floor/shuttle/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_BLOCKED_ALL


/turf/simulated/floor/shuttle/tool_act()
	return FALSE

/turf/simulated/floor/shuttle/ratvar_act()
	if(prob(20))
		ChangeTurf(/turf/simulated/floor/clockwork)

/turf/simulated/floor/shuttle/rcd_act()
	return RCD_NO_ACT

/turf/simulated/floor/shuttle/syndicate //Used only by buildmode generators
	icon_state = "floor4"

/turf/simulated/floor/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/shuttle/plating/vox	//Vox skipjack plating
	oxygen = 0
	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD

/turf/simulated/floor/shuttle/transparent_floor
	icon_state = "transparent"
	transparent_floor = TURF_TRANSPARENT
	smoothing_groups = SMOOTH_GROUP_TRANSPARENT_FLOOR

/turf/simulated/floor/shuttle/transparent_floor/Initialize()
	. = ..()
	var/obj/O
	O = new()
	O.underlays.Add(src)
	underlays = O.underlays
	qdel(O)

/turf/simulated/floor/shuttle/transparent_floor/copyTurf(turf/T)
	. = ..()
	T.transform = transform

//Оно даже не наследовалось от стандартного пола... Какой ужас...
/turf/simulated/floor/shuttle/objective_check		// Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "brig floor"        						// Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/shuttle/objective_check/vox	//Vox skipjack floors
	name = "skipjack floor"
	oxygen = 0
	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD
