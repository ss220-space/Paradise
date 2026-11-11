/obj/effect/landmark/overmap_navigation_beacon
	name = "shuttle navigation beacon"
	icon = 'icons/obj/objects.dmi'
	icon_state = "navbeacon0"
	dir = NORTH
	var/dock_id
	var/nav_order = 1
	var/lead_distance = 16

/obj/effect/landmark/overmap_navigation_beacon/Initialize(mapload)
	. = ..()
	GLOB.overmap_navigation_beacons += src

/obj/effect/landmark/overmap_navigation_beacon/Destroy()
	GLOB.overmap_navigation_beacons -= src
	return ..()

/obj/effect/landmark/overmap_navigation_beacon/proc/world_point(obj/overmap/entity/host)
	if(host && (!host.project_terrain || host.dock_host?.planet_landing))
		return list(host.get_world_x(), host.get_world_y())
	if(host?.shuttle && z == host.hull_z)
		return host.hull_to_world(x, y)
	if(host?.physical_space?.bubble_z == z)
		return host.physical_space.to_world(x, y)
	return null

/obj/overmap/entity/proc/navigation_collision_disabled()
	return relay_capture || is_jumping() || flight?.navigation_ignore_collisions
