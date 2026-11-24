/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	color = BLOOD_COLOR_RED
	alpha = 255
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE //makes the graffiti visible over a wall.
	mergeable_decal = FALSE // Allows crayon drawings to overlap one another.
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	mouse_opacity = MOUSE_OPACITY_OPAQUE

/obj/effect/decal/cleanable/crayon/Initialize(mapload, main = color, type = icon_state, e_name = name, rotation = 0, scale = 1, text_char = null, font_family = "Small Fonts", outline_color = null, vertical_stretch = 1)
	. = ..()

	name = e_name
	desc = "A [name] drawn in crayon."

	if(text_char)
		icon_state = null
		color = null
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		var/rendered_size = max(8, round(12.5 * scale * vertical_stretch))
		var/box_size = max(32, round(32 * scale * vertical_stretch))
		var/offset = round((box_size - 32) / 2)
		maptext_width = box_size
		maptext_height = box_size
		maptext_x = -offset
		maptext_y = round(9 * scale) - offset
		var/outline_style = outline_color ? "-dm-text-outline: 1px [outline_color];" : ""
		maptext = "<div style='width: [box_size]px; text-align: center; font-family: [font_family]; font-size: [rendered_size]px; color: [main]; [outline_style]'>[html_encode(text_char)]</div>"
		if(rotation != 0)
			var/matrix/transform_matrix = matrix()
			transform_matrix.Turn(rotation)
			transform = transform_matrix
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

/obj/effect/decal/cleanable/crayon/never_should_have_come_here(turf/here_turf)
	return isgroundlessturf(here_turf)

