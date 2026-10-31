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

/datum/overmap_proxy_hud
	var/client/owner
	var/list/copies = list()

/datum/overmap_proxy_hud/New(client/owner)
	src.owner = owner

/datum/overmap_proxy_hud/Destroy()
	for(var/obj/effect/abstract/hull_proxy_tile/tile as anything in copies)
		remove_tile(tile)
	owner = null
	return ..()

/datum/overmap_proxy_hud/proc/remove_tile(obj/effect/abstract/hull_proxy_tile/tile)
	var/list/images = copies[tile]
	for(var/image/original as anything in images)
		var/image/copy = images[original]
		owner?.images.Remove(copy)
		qdel(copy)
	copies -= tile

/datum/overmap_proxy_hud/proc/update(list/wanted)
	for(var/obj/effect/abstract/hull_proxy_tile/tile as anything in copies)
		if(!wanted[tile])
			remove_tile(tile)
	for(var/obj/effect/abstract/hull_proxy_tile/tile as anything in wanted)
		var/list/sources = wanted[tile]
		var/list/images = copies[tile]
		if(!images)
			images = list()
			copies[tile] = images
		for(var/image/original as anything in images)
			if(!sources[original])
				var/image/old_copy = images[original]
				owner?.images.Remove(old_copy)
				qdel(old_copy)
				images -= original
		for(var/image/original as anything in sources)
			var/atom/target = sources[original]
			var/image/copy = images[original]
			if(!copy)
				copy = image(loc = tile)
				images[original] = copy
				owner?.images.Add(copy)
			copy.appearance = original.appearance
			copy.loc = tile
			copy.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			copy.pixel_x += target.pixel_x
			copy.pixel_y += target.pixel_y
			copy.pixel_w += target.pixel_w
			copy.pixel_z += target.pixel_z
			if(original.plane != FLOAT_PLANE)
				SET_PLANE_EXPLICIT(copy, PLANE_TO_TRUE(original.plane), tile)

/datum/atom_hud/proc/collect_proxy_images(mob/viewer, atom/target, list/output)
	if(!hud_users_all_z_levels[viewer] || queued_to_see[viewer] || !hud_atoms_all_z_levels[target] || (target in hud_exceptions[viewer]))
		return
	for(var/category in hud_icons)
		var/entry = target.active_hud_list?[category]
		if(islist(entry))
			for(var/image/mark as anything in entry)
				output[mark] = target
		else if(isimage(entry))
			output[entry] = target
