/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EMISSIVE_COLOR]. Order of application matters: Default generated blockers are overlays, and will block its own emissive underlays. If you want an object to be both a blocker, and have their own emissive, it has to be an overlay instead. Grayscale lightmasks are visible in the BYOND right-click and Examine pane, unless they're covered up by another overlay.
/proc/emissive_appearance(icon, icon_state = "", layer = FLOAT_LAYER, alpha = 255, appearance_flags = NONE)
	return mutable_appearance(icon, icon_state, layer, EMISSIVE_PLANE, alpha, appearance_flags|EMISSIVE_APPEARANCE_FLAGS, EMISSIVE_COLOR)


/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EM_BLOCK_COLOR].
/proc/emissive_blocker(icon, icon_state = "", layer = FLOAT_LAYER, alpha = 255, appearance_flags = NONE)
	return mutable_appearance(icon, icon_state, layer, EMISSIVE_PLANE, alpha, appearance_flags|EMISSIVE_APPEARANCE_FLAGS, EM_BLOCK_COLOR)


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
	blocker.plane = EMISSIVE_PLANE
	return blocker

