/obj/effect/appearance_clone

// Intentionally not Initialize(), to make sure the clone assumes the intended appearance in time for the camera getFlatIcon.
/obj/effect/appearance_clone/New(loc, atom/our_atom)
	if(!istype(our_atom))
		return ..()
	if(!isopenspaceturf(our_atom))
		appearance = our_atom.appearance
	dir = our_atom.dir
	if(ismovable(our_atom))
		var/atom/movable/our_movable = our_atom
		step_x = our_movable.step_x
		step_y = our_movable.step_y
	return ..()

/obj/item/camera/proc/camera_get_icon(list/turfs, turf/center, mob/user, psize = 96, datum/turf_reservation/clone_area, size, total)

	var/skip_normal = FALSE
	var/wipe_atoms = FALSE

	var/list/atoms = list()
	if(istype(clone_area) && total == clone_area.width && total == clone_area.height && size >= 0)
		var/turf/bottom_left = clone_area.bottom_left_turfs[1]
		var/cloned_center_x = round(bottom_left.x + ((total - 1) / 2))
		var/cloned_center_y = round(bottom_left.y + ((total - 1) / 2))
		for(var/turf/turf in turfs)
			var/offset_x = turf.x - center.x
			var/offset_y = turf.y - center.y
			var/turf/newT = locate(cloned_center_x + offset_x, cloned_center_y + offset_y, bottom_left.z)
			if(!(newT in clone_area.reserved_turfs)) //sanity check so we don't overwrite other areas somehow
				continue
			atoms += new /obj/effect/appearance_clone(newT, turf)
			if(turf.loc.icon_state)
				atoms += new /obj/effect/appearance_clone(newT, turf.loc)
			for(var/atom/atom in turf.contents)
				if(is_light(atom))
					continue
				if(!atom.invisibility || (see_ghosts && isobserver(atom)))
					atoms += new /obj/effect/appearance_clone(newT, atom)
		skip_normal = TRUE
		wipe_atoms = TRUE
		center = locate(cloned_center_x, cloned_center_y, bottom_left.z)

	if(!skip_normal)
		for(var/turf/turf in turfs)
			atoms += turf
			for(var/atom/movable/atom in turf)
				if(flashing_lights && is_light(atom))
					continue //Do not apply lighting, making whole image full bright.
				if(atom.invisibility)
					if(!(see_ghosts && isobserver(atom)))
						continue
				atoms += atom
			CHECK_TICK

	//Bigger icon base to capture those icons that were shifted to the next tile
	//i.e. pretty much all wall-mounted machinery
	var/icon/res = icon('icons/blanks/96x96.dmi', "nothing")
	res.Scale(psize, psize)

	var/list/sorted = list()
	var/j
	for(var/i in 1 to length(atoms))
		var/atom/atom = atoms[i]
		for(j = length(sorted), j > 0, --j)
			var/atom/c2 = sorted[j]
			if((c2.plane <= atom.plane) && (c2.layer <= atom.layer))
				break
		sorted.Insert(j+1, atom)
		CHECK_TICK

	var/xcomp = floor(psize / 2) - 15
	var/ycomp = floor(psize / 2) - 15

	if(!skip_normal) //these are not clones
		for(var/atom/atom in sorted)
			if(is_light(atom))
				continue //Lighting objects render last, need to be above all atoms and turfs displayed
			var/xo = (atom.x - center.x) * ICON_SIZE_X + atom.pixel_x + xcomp
			var/yo = (atom.y - center.y) * ICON_SIZE_Y + atom.pixel_y + ycomp
			if(ismovable(atom))
				var/atom/movable/AM = atom
				xo += AM.step_x
				yo += AM.step_y
			var/icon/img = getFlatIcon(atom, no_anim = TRUE)
			res.Blend(img, blendMode2iconMode(atom.blend_mode), xo, yo)
			CHECK_TICK
	else
		for(var/X in sorted) //these are clones
			var/obj/effect/appearance_clone/clone = X
			var/icon/img = getFlatIcon(clone, no_anim = TRUE)
			if(img)
				// Center of the image in X
				var/xo = (clone.x - center.x) * ICON_SIZE_X + clone.pixel_x + xcomp + clone.step_x
				// Center of the image in Y
				var/yo = (clone.y - center.y) * ICON_SIZE_Y + clone.pixel_y + ycomp + clone.step_y

				if(clone.transform) // getFlatIcon doesn't give a snot about transforms.
					var/datum/decompose_matrix/decompose = clone.transform.decompose()
					// Scale in X, Y
					if(decompose.scale_x != 1 || decompose.scale_y != 1)
						var/base_w = img.Width()
						var/base_h = img.Height()
						// scale_x can be negative
						img.Scale(base_w * abs(decompose.scale_x), base_h * decompose.scale_y)
						if(decompose.scale_x < 0)
							img.Flip(EAST)
						xo -= base_w * (decompose.scale_x - sign(decompose.scale_x)) / 2 * sign(decompose.scale_x)
						yo -= base_h * (decompose.scale_y - 1) / 2
					// Rotation
					if(decompose.rotation != 0)
						img.Turn(decompose.rotation)
					// Shift
					xo += decompose.shift_x
					yo += decompose.shift_y

				res.Blend(img, blendMode2iconMode(clone.blend_mode), xo, yo)
			CHECK_TICK

	if(wipe_atoms)
		QDEL_LIST(atoms)

	return res
