/datum/controller/subsystem/overmap/proc/update_proxy_huds()
	var/list/wanted_views = list()
	for(var/client/viewer as anything in client_eyes)
		if(QDELETED(viewer) || !viewer.mob)
			continue
		var/list/huds = list()
		for(var/datum/atom_hud/hud as anything in GLOB.all_huds)
			if(hud.hud_users_all_z_levels[viewer.mob] && !hud.queued_to_see[viewer.mob])
				huds += hud
		if(!length(huds))
			continue
		var/list/wanted = list()
		var/turf/eye = get_turf(viewer.eye || viewer.mob)
		if(!eye)
			continue
		var/list/view_size = getviewsize(viewer.view)
		for(var/obj/effect/abstract/hull_proxy_tile/tile as anything in proxy_hud_tiles)
			var/turf/anchor = get_turf(tile)
			if(!anchor || anchor.z != eye.z || abs(anchor.x + tile.pixel_x / ICON_SIZE_X - eye.x) > view_size[1] / 2 + 1 || abs(anchor.y + tile.pixel_y / ICON_SIZE_Y - eye.y) > view_size[2] / 2 + 1)
				continue
			if(fog_hides_from(viewer, tile.source_turf()))
				continue
			var/list/images = list()
			for(var/atom/target as anything in tile.hud_sources)
				if(QDELETED(target) || target.invisibility > viewer.mob.see_invisible || !length(target.active_hud_list))
					continue
				for(var/datum/atom_hud/hud as anything in huds)
					hud.collect_proxy_images(viewer.mob, target, images)
			if(length(images))
				wanted[tile] = images
		if(!length(wanted))
			continue
		var/datum/overmap_proxy_hud/view = proxy_hud_views[viewer]
		if(!view)
			view = new(viewer)
			proxy_hud_views[viewer] = view
		view.update(wanted)
		wanted_views[viewer] = TRUE
	for(var/client/viewer as anything in proxy_hud_views)
		if(!wanted_views[viewer])
			qdel(proxy_hud_views[viewer])
			proxy_hud_views -= viewer
