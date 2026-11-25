/obj/structure/fence/meshfence
	desc = "Большая металлическая сетка, натянутая между двумя столбами. Дешёвый способ разделить зоны, не мешая обзору."
	icon = 'icons/obj/electric_fence.dmi'
	icon_state = "fence0"
	layer = ABOVE_OBJ_LAYER
	max_integrity = 200
	resistance_flags = FLAMMABLE
	pass_flags_self = PASSFENCE
	smooth = SMOOTH_BITMASK
	base_icon_state = "fence"
	smoothing_groups = SMOOTH_GROUP_MESH_FENCE
	canSmoothWith = SMOOTH_GROUP_MESH_FENCE

/obj/structure/fence/meshfence/Initialize(mapload)
	. = ..(mapload)
	if(hole_size)
		base_icon_state = "brokenfence"
	QUEUE_SMOOTH(src)

/obj/structure/fence/meshfence/bullet_act(obj/projectile/P, def_zone)
	playsound(src, 'sound/effects/fencehit.ogg', 35, TRUE)
	return TRUE

/obj/structure/fence/meshfence/set_smoothed_icon_state(new_junction)
	icon_state = "[base_icon_state][new_junction]"

/// Slim fence - electric_fence_alt.dmi
/obj/structure/fence/meshfence/slim
	icon = 'icons/obj/electric_fence_alt.dmi'

/obj/structure/fence/meshfence/dark
	icon = 'icons/obj/dark_fence.dmi'

/obj/structure/fence/meshfence/dark_slim
	icon = 'icons/obj/dark_fence_alt.dmi'

// Mesh fence door
/obj/structure/fence/door/mesh
	desc = "Прочная сетчатая дверь между двумя металлическими столбами. Дешёвый способ отделить зоны, сохраняя обзор."
	icon = 'icons/obj/electric_fence_alt_door.dmi'
	max_integrity = 70

	smoothing_groups = SMOOTH_GROUP_MESH_FENCE

/obj/structure/fence/door/mesh/Initialize(mapload)
	. = ..(mapload)
	QUEUE_SMOOTH(src)

/obj/structure/fence/door/mesh/Destroy()
	var/turf/our_turf = get_turf(src)
	. = ..()
	if(our_turf)
		for(var/direction in GLOB.cardinal)
			var/atom/A = locate() in get_step(our_turf, direction)
			if(A && (istype(A, /obj/structure/fence/meshfence) || istype(A, /obj/structure/fence/door/mesh)))
				QUEUE_SMOOTH(A)

/obj/structure/fence/door/mesh/toggle(mob/user)
	flick(open ? "door_closing" : "door_opening", src)
	..()
	QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/fence/door/mesh/update_door_status()
	set_density(!open)
	icon_state = open ? "door_open" : "door_closed"

/// Slim door
/obj/structure/fence/door/mesh/slim
	icon = 'icons/obj/dark_fence_alt_door.dmi'
