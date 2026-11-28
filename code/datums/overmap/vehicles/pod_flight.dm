/datum/hull_proxy/pod/New(obj/overmap/entity/pod/vessel, turf/viewer_turf)
	src.vessel = vessel
	src.viewer_turf = viewer_turf
	var/obj/effect/abstract/hull_proxy_tile/pod/tile = new(null)
	tile.craft = vessel.pod
	tile.frame_turf = viewer_turf
	SET_PLANE_EXPLICIT(tile, GAME_PLANE, viewer_turf)
	tile.vis_contents += vessel.pod
	tiles = list(tile)
	RegisterSignal(vessel, COMSIG_QDELETING, PROC_REF(on_vessel_deleted))

/datum/hull_proxy/pod/place(new_center_x, new_center_y, new_z, new_heading, list/bounds, time)
	var/obj/effect/abstract/hull_proxy_tile/pod/tile = tiles[1]
	var/matrix/turned = matrix()
	turned.Turn(new_heading)
	tile.glide(new_center_x - 0.5 * cos(new_heading) - 0.5 * sin(new_heading), new_center_y + 0.5 * sin(new_heading) - 0.5 * cos(new_heading), new_z, turned, bounds, time)
