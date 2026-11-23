/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	color = BLOOD_COLOR_RED
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE //makes the graffiti visible over a wall.
	mergeable_decal = FALSE // Allows crayon drawings to overlap one another.
	appearance_flags = PIXEL_SCALE
	mouse_opacity = MOUSE_OPACITY_OPAQUE

/obj/effect/decal/cleanable/crayon/Initialize(mapload, main = color, type = icon_state, e_name = name, rotation = 0, scale = 1, text_char = null, font_family = "Small Fonts, Fixedsys, monospace")
	. = ..()

	name = e_name
	desc = "A [name] drawn in crayon."

	if(text_char)
		icon_state = null
		color = null
		maptext_width = 32
		maptext_height = 32
		maptext = "<div style='width: 32px; height: 32px; line-height: 32px; text-align: center; font-family: [font_family]; font-size: 20px; font-weight: bold; color: [main]; -dm-text-outline: 1px #111111;'>[html_encode(text_char)]</div>"
	else
		icon_state = type
		color = main

	if(rotation != 0 || scale != 1)
		var/matrix/transform_matrix = matrix()
		if(rotation != 0)
			transform_matrix.Turn(rotation)
		if(scale != 1)
			transform_matrix.Scale(scale)
		transform = transform_matrix

	if(isturf(loc))
		RegisterSignal(loc, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_turf_cleaned))

/obj/effect/decal/cleanable/crayon/proc/on_turf_cleaned(datum/source, clean_types)
	SIGNAL_HANDLER
	if(clean_types & clean_type)
		qdel(src)
		return COMPONENT_CLEANED

/obj/effect/decal/cleanable/crayon/never_should_have_come_here(turf/here_turf)
	return isgroundlessturf(here_turf)
