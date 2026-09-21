// CM-style mesh fences (poles + metal mesh between them)
// Sprites: icons/obj/electric_fence.dmi, icons/obj/electric_fence_alt.dmi, icons/obj/electric_fence_alt_door.dmi
/obj/structure/fence/meshfence
	desc = "Большая металлическая сетка, натянутая между двумя столбами. Дешёвый способ разделить зоны, не мешая обзору."
	icon = 'icons/obj/electric_fence.dmi'
	icon_state = "fence0"
	layer = ABOVE_OBJ_LAYER
	max_integrity = 200
	resistance_flags = FLAMMABLE

	var/junction = 0

/obj/structure/fence/meshfence/Initialize(mapload)
	. = ..()
	update_nearby_icons()

/obj/structure/fence/meshfence/bullet_act(obj/projectile/P, def_zone)
	playsound(src, 'sound/effects/fencehit.ogg', 35, TRUE)
	return TRUE

/obj/structure/fence/meshfence/Destroy()
	var/turf/our_turf = get_turf(src)
	. = ..()
	if(our_turf)
		for(var/direction in GLOB.cardinal)
			var/obj/structure/fence/meshfence/fence = locate() in get_step(our_turf, direction)
			fence?.update_cut_status()

/obj/structure/fence/meshfence/update_cut_status()
	. = ..()
	junction = 0
	for(var/obj/structure/fence/meshfence/fence in orange(src, 1))
		if(abs(x - fence.x) - abs(y - fence.y))
			junction |= get_dir(src, fence)
	for(var/obj/structure/fence/door/mesh/fence in orange(src, 1))
		if(abs(x - fence.x) - abs(y - fence.y))
			junction |= get_dir(src, fence)
	if(!hole_size)
		icon_state = "fence[junction]"
	else
		icon_state = "brokenfence[junction]"

/obj/structure/fence/meshfence/proc/update_nearby_icons()
	update_cut_status()
	for(var/direction in GLOB.cardinal)
		var/obj/structure/fence/meshfence/fence = locate() in get_step(src, direction)
		fence?.update_cut_status()

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
	icon_state = "door_closed"
	max_integrity = 70

/obj/structure/fence/door/mesh/update_door_status()
	set_density(!open)
	icon_state = open ? "door_open" : "door_closed"

/obj/structure/fence/door/mesh/toggle(mob/user)
	flick(open ? "door_closing" : "door_opening", src)
	..()

/obj/structure/fence/door/mesh/slim
	icon = 'icons/obj/dark_fence_alt_door.dmi'
