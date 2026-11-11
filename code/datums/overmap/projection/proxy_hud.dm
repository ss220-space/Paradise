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
