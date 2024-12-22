/obj/effect/appearance_clone

/obj/effect/appearance_clone/New(loc, atom/A) //Intentionally not Initialize(), to make sure the clone assumes the intended appearance in time for the camera getFlatIcon.
	if(istype(A))
		appearance = A.appearance
		dir = A.dir
		if(ismovable(A))
			var/atom/movable/AM = A
			step_x = AM.step_x
			step_y = AM.step_y
	. = ..()

/obj/item/camera/proc/camera_get_icon(list/turfs, turf/center, mob/user, psize = 96, datum/turf_reservation/clone_area, size, total)

	var/skip_normal = FALSE
	var/wipe_atoms = FALSE

	var/list/atoms = list()
	if(istype(clone_area) && total == clone_area.width && total == clone_area.height && size >= 0)
		var/turf/bottom_left = clone_area.bottom_left_turfs[1]
		var/cloned_center_x = round(bottom_left.x + ((total - 1) / 2))
		var/cloned_center_y = round(bottom_left.y + ((total - 1) / 2))
		for(var/turf/T in turfs)
			var/offset_x = T.x - center.x
			var/offset_y = T.y - center.y
			var/turf/newT = locate(cloned_center_x + offset_x, cloned_center_y + offset_y, bottom_left.z)
			if(!(newT in clone_area.reserved_turfs)) //sanity check so we don't overwrite other areas somehow
				continue
			atoms += new /obj/effect/appearance_clone(newT, T)
			if(T.loc.icon_state)
				atoms += new /obj/effect/appearance_clone(newT, T.loc)
			for(var/atom/A in T.contents)
				if(istype(A, /atom/movable/lighting_object))
					continue
				if(!A.invisibility || (see_ghosts && isobserver(A)))
					atoms += new /obj/effect/appearance_clone(newT, A)
		skip_normal = TRUE
		wipe_atoms = TRUE
		center = locate(cloned_center_x, cloned_center_y, bottom_left.z)

	if(!skip_normal)
		for(var/turf/T in turfs)
			atoms += T
			for(var/atom/movable/A in T)
				if(flashing_lights && istype(A, /atom/movable/lighting_object))
					continue //Do not apply lighting, making whole image full bright.
				if(A.invisibility)
					if(!(see_ghosts && isobserver(A)))
						continue
				atoms += A
			CHECK_TICK

	//Bigger icon base to capture those icons that were shifted to the next tile
	//i.e. pretty much all wall-mounted machinery
	var/icon/res = icon('icons/blanks/96x96.dmi', "nothing")
	res.Scale(psize, psize)

	var/list/sorted = list()
	var/j
	for(var/i in 1 to atoms.len)
		var/atom/c = atoms[i]
		for(j = sorted.len, j > 0, --j)
			var/atom/c2 = sorted[j]
			if((c2.plane <= c.plane) && (c2.layer <= c.layer))
				break
		sorted.Insert(j+1, c)
		CHECK_TICK

	var/xcomp = FLOOR(psize / 2, 1) - 15
	var/ycomp = FLOOR(psize / 2, 1) - 15

	if(!skip_normal) //these are not clones
		for(var/atom/A in sorted)
			if(istype(A, /atom/movable/lighting_object))
				continue //Lighting objects render last, need to be above all atoms and turfs displayed
			var/xo = (A.x - center.x) * world.icon_size + A.pixel_x + xcomp
			var/yo = (A.y - center.y) * world.icon_size + A.pixel_y + ycomp
			if(ismovable(A))
				var/atom/movable/AM = A
				xo += AM.step_x
				yo += AM.step_y
			var/icon/img = getFlatIcon(A, no_anim = TRUE)
			res.Blend(img, blendMode2iconMode(A.blend_mode), xo, yo)
			CHECK_TICK
	else
		for(var/X in sorted) //these are clones
			var/obj/effect/appearance_clone/clone = X
			var/icon/img = getFlatIcon(clone, no_anim = TRUE)
			if(img)
				// Center of the image in X
				var/xo = (clone.x - center.x) * world.icon_size + clone.pixel_x + xcomp + clone.step_x
				// Center of the image in Y
				var/yo = (clone.y - center.y) * world.icon_size + clone.pixel_y + ycomp + clone.step_y

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
						xo -= base_w * (decompose.scale_x - SIGN(decompose.scale_x)) / 2 * SIGN(decompose.scale_x)
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
