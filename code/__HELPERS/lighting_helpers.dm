/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EMISSIVE_COLOR]. Order of application matters: Default generated blockers are overlays, and will block its own emissive underlays. If you want an object to be both a blocker, and have their own emissive, it has to be an overlay instead. Grayscale lightmasks are visible in the BYOND right-click and Examine pane, unless they're covered up by another overlay.
/proc/emissive_appearance(icon, icon_state = "", atom/offset_spokesman, layer = FLOAT_LAYER, alpha = 255, appearance_flags = NONE, offset_const)
	return mutable_appearance(icon, icon_state, layer, offset_spokesman, EMISSIVE_PLANE, 255, appearance_flags|EMISSIVE_APPEARANCE_FLAGS, EMISSIVE_COLOR, offset_const)


/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EM_BLOCK_COLOR].
/proc/emissive_blocker(icon, icon_state = "", atom/offset_spokesman, layer = FLOAT_LAYER, alpha = 255, appearance_flags = NONE, offset_const)
	return mutable_appearance(icon, icon_state, layer, offset_spokesman, EMISSIVE_PLANE, alpha, appearance_flags|EMISSIVE_APPEARANCE_FLAGS, EM_BLOCK_COLOR, offset_const)


/// This is a semi hot proc, so we micro it. saves maybe 150ms
/proc/fast_emissive_blocker(atom/make_blocker)
	var/mutable_appearance/blocker = new
	blocker.icon = make_blocker.icon
	blocker.icon_state = make_blocker.icon_state
	// blocker.layer = FLOAT_LAYER // Implied, FLOAT_LAYER is default for appearances
	blocker.appearance_flags |= (make_blocker.appearance_flags|EMISSIVE_APPEARANCE_FLAGS)
	blocker.dir = make_blocker.dir
	blocker.alpha = make_blocker.alpha
	blocker.color = EM_BLOCK_COLOR
	// Note, we are ok with null turfs, that's not an error condition we'll just default to 0, the error would be
	// Not passing ANYTHING in, key difference
	SET_PLANE_EXPLICIT(blocker, EMISSIVE_PLANE, make_blocker)
	return blocker

