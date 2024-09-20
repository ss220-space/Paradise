/turf/simulated/floor/indestructible
	explosion_vertical_block = 50

/turf/simulated/floor/indestructible/ex_act(severity)
	return

/turf/simulated/floor/indestructible/blob_act(obj/structure/blob/B)
	return

/turf/simulated/floor/indestructible/singularity_act()
	return

/turf/simulated/floor/indestructible/singularity_pull(S, current_size)
	return

/turf/simulated/floor/indestructible/narsie_act()
	return

/turf/simulated/floor/indestructible/ratvar_act()
	return

/turf/simulated/floor/indestructible/burn_down()
	return


/turf/simulated/floor/indestructible/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_BLOCKED_ALL


/turf/simulated/floor/indestructible/attack_hand(mob/user)
	return

/turf/simulated/floor/indestructible/attack_animal(mob/living/simple_animal/M)
	return

/turf/simulated/floor/indestructible/mech_melee_attack(obj/mecha/M)
	return

/turf/simulated/floor/indestructible/crowbar_act(mob/user, obj/item/I)
	return

/turf/simulated/floor/indestructible/screwdriver_act(mob/living/user, obj/item/I)
	return

/turf/simulated/floor/indestructible/welder_act(mob/living/user, obj/item/I)
	return

/turf/simulated/floor/indestructible/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	return

/turf/simulated/floor/indestructible/plating
	name = "plating"
	icon_state = "plating"
	icon = 'icons/turf/floors/plating.dmi'
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/indestructible/necropolis
	name = "necropolis floor"
	desc = "It's regarding you suspiciously."
	icon = 'icons/turf/floors.dmi'
	icon_state = "necro1"
	baseturf = /turf/simulated/floor/indestructible/necropolis
	oxygen = 14
	nitrogen = 23
	temperature = 300
	planetary_atmos = TRUE
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA

/turf/simulated/floor/indestructible/necropolis/Initialize(mapload)
	. = ..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"

/turf/simulated/floor/indestructible/necropolis/air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

/turf/simulated/floor/indestructible/boss //you put stone tiles on this and use it as a base
	name = "necropolis floor"
	icon = 'icons/turf/floors/boss_floors.dmi'
	icon_state = "boss"
	smooth = SMOOTH_FALSE
	baseturf = /turf/simulated/floor/indestructible/boss
	oxygen = 14
	nitrogen = 23
	temperature = 300
	planetary_atmos = TRUE

/turf/simulated/floor/indestructible/boss/indoors //used for ashwalkers village
	oxygen = /turf/simulated/floor/lava::oxygen //lava near tendril
	nitrogen = /turf/simulated/floor/lava::nitrogen
	temperature = /turf/simulated/floor/lava::temperature

/turf/simulated/floor/indestructible/boss/air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

/turf/simulated/floor/indestructible/hierophant
	name = "floor"
	icon = 'icons/turf/floors/hierophant_floor.dmi'
	icon_state = "floor"
	base_icon_state = "hierophant_floor"
	oxygen = 14
	nitrogen = 23
	temperature = 300
	planetary_atmos = TRUE
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_HIERO_FLOOR
	smoothing_groups = SMOOTH_GROUP_HIERO_FLOOR

/turf/simulated/floor/indestructible/hierophant/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/simulated/floor/indestructible/hierophant/two

/turf/simulated/floor/indestructible/vox
	oxygen = 0 // I hate this
	nitrogen = 100

/turf/simulated/floor/indestructible/carpet
	name = "Carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet"
	base_icon_state = "carpet"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_CARPET
	smoothing_groups = SMOOTH_GROUP_CARPET
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/indestructible/grass
	name = "grass patch"
	icon_state = "grass1"
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/indestructible/grass/Initialize(mapload)
	. = ..()
	icon_state = "grass[rand(1,4)]"

/turf/simulated/floor/indestructible/asteroid
	name = "sand"
	icon = 'icons/turf/floors/plating.dmi'
	icon_state = "asteroid"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/indestructible/asteroid/Initialize(mapload)
	. = ..()
	if(prob(20))
		icon_state = "asteroid[rand(0,12)]"

/turf/simulated/floor/indestructible/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	always_lit = TRUE

/turf/simulated/floor/indestructible/abductor/Initialize(mapload)
	. = ..()
	icon_state = "alienpod[rand(1,9)]"

/turf/simulated/floor/indestructible/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/indestructible/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'

	// I'll be glad if someone wants a way to make an overlay that can also smooth. But
	var/obj/effect/beach_water_overlay/water_overlay
	var/water_overlay_icon = 'icons/misc/beach.dmi'
	var/water_overlay_icon_state = null
	var/water_overlay_smooth = NONE
	var/water_overlay_base_icon_state = null

/turf/simulated/floor/indestructible/beach/Initialize(mapload)
	. = ..()
	if(water_overlay_icon_state || water_overlay_icon != 'icons/misc/beach.dmi')
		water_overlay = new(src, water_overlay_icon, water_overlay_icon_state, water_overlay_smooth, water_overlay_base_icon_state)

/turf/simulated/floor/indestructible/beach/Destroy()
	QDEL_NULL(water_overlay)
	return ..()

/turf/simulated/floor/indestructible/beach/sand
	name = "Sand"
	icon_state = "desert"
	mouse_opacity = MOUSE_OPACITY_ICON
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY


/turf/simulated/floor/indestructible/beach/sand/Initialize(mapload)
	. = ..()			//adds some aesthetic randomness to the beach sand
	icon_state = pick("desert", "desert0", "desert1", "desert2", "desert3", "desert4")

/turf/simulated/floor/indestructible/beach/sand/dense			//for boundary "walls"
	density = TRUE

/turf/simulated/floor/indestructible/beach/coastline
	name = "Coastline"
	//icon = 'icons/misc/beach2.dmi'
	//icon_state = "sandwater"
	icon_state = "beach"
	water_overlay_icon_state = "water_coast"
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/simulated/floor/indestructible/beach/coastline/dense		//for boundary "walls"
	density = TRUE

/turf/simulated/floor/indestructible/beach/water
	name = "Shallow Water"
	icon_state = "seashallow"
	water_overlay_icon_state = "water_shallow"
	var/obj/machinery/poolcontroller/linkedcontroller = null
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/simulated/floor/indestructible/beach/water/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!linkedcontroller || !ismob(arrived))
		return .
	if(isliving(arrived))
		var/mob/living/creature = arrived
		creature.ExtinguishMob()
	linkedcontroller.mobinpool += arrived

/turf/simulated/floor/indestructible/beach/water/Exited(atom/movable/departed, atom/newLoc)
	. = ..()
	if(!linkedcontroller || !ismob(departed))
		return .
	linkedcontroller.mobinpool -= departed

/turf/simulated/floor/indestructible/beach/water/InitializedOn(atom/A)
	if(!linkedcontroller)
		return
	if(istype(A, /obj/effect/decal/cleanable)) // Better a typecheck than looping through thousands of turfs everyday
		linkedcontroller.decalinpool += A

/turf/simulated/floor/indestructible/beach/water/dense			//for boundary "walls"
	density = TRUE

/turf/simulated/floor/indestructible/beach/water/edge_drop
	name = "Water"
	icon_state = "seadrop"
	water_overlay_icon_state = "water_drop"

/turf/simulated/floor/indestructible/beach/water/drop
	name = "Water"
	icon = 'icons/turf/floors/seadrop.dmi'
	icon_state = "seadrop"
	water_overlay_icon = 'icons/turf/floors/seadrop-o.dmi'
	water_overlay_smooth = SMOOTH_BITMASK
	water_overlay_base_icon_state = "seadrop-o"
	smooth = SMOOTH_BITMASK
	base_icon_state = "seadrop"
	canSmoothWith = SMOOTH_GROUP_BEACH
	smoothing_groups = SMOOTH_GROUP_BEACH

/turf/simulated/floor/indestructible/beach/water/drop/dense
	density = TRUE

/turf/simulated/floor/indestructible/beach/water/deep
	name = "Deep Water"
	icon_state = "seadeep"
	water_overlay_icon_state = "water_deep"

/turf/simulated/floor/indestructible/beach/water/deep/dense
	density = TRUE

/turf/simulated/floor/indestructible/beach/water/deep/wood_floor
	name = "Sunken Floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "wood"

/turf/simulated/floor/indestructible/beach/water/deep/sand_floor
	name = "Sea Floor"
	icon_state = "sand"

/turf/simulated/floor/indestructible/beach/water/deep/rock_wall
	name = "Reef Stone"
	icon_state = "desert7"
	density = TRUE
	opacity = TRUE
	explosion_block = 2
	mouse_opacity = MOUSE_OPACITY_ICON


/obj/effect/beach_water_overlay
	name = "Water overlay that you shouldn't see"
	icon = 'icons/misc/beach.dmi'
	icon_state = null
	smooth = NONE
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

/obj/effect/beach_water_overlay/Initialize(mapload, new_icon, new_icon_state, new_smooth, new_base_icon_state)
	icon = new_icon
	icon_state = new_icon_state
	smooth = new_smooth
	base_icon_state = new_base_icon_state
	if(smooth)
		canSmoothWith = SMOOTH_GROUP_BEACH
	. = ..()

// used with /effect/view_portal in order to get rid of dynamic lighting.
/turf/simulated/floor/indestructible/view_portal
	name = "Deep space"
	desc = "Deep space nothing"
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	always_lit = TRUE

/turf/simulated/floor/indestructible/view_portal/dense
	density = TRUE
