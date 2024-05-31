/// List of plane offset + 1 -> mutable appearance to use
/// Fills with offsets as they are generated
GLOBAL_LIST_INIT_TYPED(fullbright_overlays, /mutable_appearance, list(create_fullbright_overlay(0)))

/proc/create_fullbright_overlay(offset)
	var/mutable_appearance/lighting_effect = mutable_appearance('icons/effects/alphacolors.dmi', "white")
	SET_PLANE_W_SCALAR(lighting_effect, LIGHTING_PLANE, offset)
	lighting_effect.layer = LIGHTING_LAYER
	lighting_effect.blend_mode = BLEND_ADD
	return lighting_effect

/area
	luminosity = TRUE
	///The mutable appearance we underlay to show light
	var/mutable_appearance/lighting_effect = null
	///Whether this area has a currently active base lighting, bool
	var/area_has_base_lighting = FALSE
	///alpha 0-255 of lighting_effect and thus baselighting intensity
	var/base_lighting_alpha = 0
	///The colour of the light acting on this area
	var/base_lighting_color = null
	///Whether this area allows static lighting and thus loads the lighting objects
	var/static_lighting = TRUE
	///Whether this area is iluminated by starlight
	var/use_starlight = FALSE

/area/proc/set_base_lighting(new_base_lighting_color = -1, new_alpha = -1)
	if(base_lighting_alpha == new_alpha && base_lighting_color == new_base_lighting_color)
		return FALSE
	if(new_alpha != -1)
		base_lighting_alpha = new_alpha
	if(new_base_lighting_color != -1)
		base_lighting_color = new_base_lighting_color
	update_base_lighting()
	return TRUE

/area/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, base_lighting_color))
			set_base_lighting(new_base_lighting_color = var_value)
			. = TRUE
		if(NAMEOF(src, base_lighting_alpha))
			set_base_lighting(new_alpha = var_value)
			. = TRUE
		if(NAMEOF(src, static_lighting))
			update_static_lighting(var_value)
			. = TRUE

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return .

	return ..()

/area/proc/update_base_lighting()
	if(!area_has_base_lighting && (!base_lighting_alpha || !base_lighting_color))
		return

	if(!area_has_base_lighting)
		add_base_lighting()
		return
	remove_base_lighting()
	if(base_lighting_alpha && base_lighting_color)
		add_base_lighting()

/area/proc/remove_base_lighting()
	for(var/turf/T in src)
		T.cut_overlay(lighting_effect)
	QDEL_NULL(lighting_effect)
	area_has_base_lighting = FALSE

/area/proc/add_base_lighting()
	lighting_effect = mutable_appearance('icons/effects/alphacolors.dmi', "white")
	lighting_effect.plane = LIGHTING_PLANE
	lighting_effect.layer = LIGHTING_LAYER
	lighting_effect.blend_mode = BLEND_ADD
	lighting_effect.alpha = base_lighting_alpha
	lighting_effect.color = base_lighting_color
	for(var/turf/T in src)
		T.add_overlay(lighting_effect)
		T.luminosity = 1
	area_has_base_lighting = TRUE

/area/proc/update_static_lighting(new_static_value)
	if(new_static_value == static_lighting)
		return
	if(new_static_value)
		for(var/turf/T in src)
			T.lighting_build_overlay()
			CHECK_TICK
	else
		for(var/turf/T in src)
			T.lighting_clear_overlay()
			CHECK_TICK
