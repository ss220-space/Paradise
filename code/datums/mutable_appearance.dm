// Mutable appearances are an inbuilt byond datastructure. Read the documentation on them by hitting F1 in DM.
// Basically use them instead of images for overlays/underlays and when changing an object's appearance if you're doing so with any regularity.
// Unless you need the overlay/underlay to have a different direction than the base object. Then you have to use an image due to a bug.

// Mutable appearances are children of images, just so you know.

// Mutable appearances erase template vars on new, because they accept an appearance to copy as an arg
// If we have nothin to copy, we set the float plane
/mutable_appearance/New(mutable_appearance/to_copy)
	..()
	if(!to_copy)
		plane = FLOAT_PLANE


// Helper similar to image()
/proc/mutable_appearance(icon, icon_state = "", layer = FLOAT_LAYER, plane = FLOAT_PLANE, alpha = 255, appearance_flags = NONE, color)
	var/mutable_appearance/MA = new()
	MA.icon = icon
	MA.icon_state = icon_state
	MA.layer = layer
	MA.plane = plane
	MA.alpha = alpha
	MA.appearance_flags |= appearance_flags
	if(color)
		MA.color = color
	return MA


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
	plane = EMISSIVE_PLANE

