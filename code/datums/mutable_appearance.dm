// Mutable appearances are an inbuilt byond datastructure. Read the documentation on them by hitting F1 in DM.
// Basically use them instead of images for overlays/underlays and when changing an object's appearance if you're doing so with any regularity.
// Unless you need the overlay/underlay to have a different direction than the base object. Then you have to use an image due to a bug.

// Mutable appearances are children of images, just so you know.

// Mutable appearances erase template vars on new, because they accept an appearance to copy as an arg
// If we have nothin to copy, we set the float plane

#if DM_BUILD > 1642
/mutable_appearance/proc/New(mutable_appearance/to_copy)
	if(!to_copy)
		plane = FLOAT_PLANE
#else
/mutable_appearance/New(mutable_appearance/to_copy)
	..()
	if(!to_copy)
		plane = FLOAT_PLANE
#endif

// Helper similar to image()
/proc/mutable_appearance(icon, icon_state = "", layer = FLOAT_LAYER, atom/offset_spokesman, plane = FLOAT_PLANE, alpha = 255, appearance_flags = NONE, color, offset_const)
	var/mutable_appearance/appearance = new()
	appearance.icon = icon
	appearance.icon_state = icon_state
	appearance.layer = layer
	appearance.alpha = alpha
	appearance.appearance_flags |= appearance_flags
	if(color)
		appearance.color = color

	if(plane != FLOAT_PLANE)
		// You need to pass in some non null object to reference
		if(isatom(offset_spokesman))
			// Note, we are ok with null turfs, that's not an error condition we'll just default to 0, the error would be
			// Not passing ANYTHING in, key difference
			SET_PLANE_EXPLICIT(appearance, plane, offset_spokesman)
		// That or I'll let you pass in a static offset. Don't be stupid now
		else if(!isnull(offset_const))
			SET_PLANE_W_SCALAR(appearance, plane, offset_const)
		// otherwise if you're setting plane you better have the guts to back it up
		else
			stack_trace("No plane offset passed in as context for a non floating mutable appearance, things are gonna go to hell on multiz maps")
	else if(!isnull(offset_spokesman) && !isatom(offset_spokesman))
		stack_trace("Why did you pass in offset_spokesman as [offset_spokesman]? We need an atom to properly offset planes")

	return appearance


/mutable_appearance/clean/New()
	. = ..()
	alpha = 255
	transform = null


/mutable_appearance/emissive_blocker


/mutable_appearance/emissive_blocker/New()
	. = ..()
	// Need to do this here because it's overriden by the parent call
	color = EM_BLOCK_COLOR
	appearance_flags = EMISSIVE_APPEARANCE_FLAGS

