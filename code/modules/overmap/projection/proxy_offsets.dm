/obj/effect/abstract/hull_proxy_offset
	name = ""
	invisibility = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	simulated = FALSE
	vis_flags = 0
	appearance_flags = KEEP_TOGETHER
	var/atom/movable/source

/obj/effect/abstract/hull_proxy_offset/Initialize(mapload, atom/movable/source)
	. = ..()
	src.source = source
	plane = source.plane
	layer = source.layer
	vis_contents += source

/obj/effect/abstract/hull_proxy_offset/Destroy()
	vis_contents.Cut()
	source = null
	return ..()

/obj/effect/abstract/hull_proxy_tile/proc/project_content(atom/movable/content, list/wanted)
	var/obj/effect/abstract/hull_proxy_offset/visual = offset_visuals?[content]
	if(!visual && !(content.pixel_x || content.pixel_y || content.pixel_w || content.pixel_z || content.bound_width > ICON_SIZE_X || content.bound_height > ICON_SIZE_Y))
		return content
	if(!visual)
		visual = new(null, content)
		LAZYSET(offset_visuals, content, visual)
	wanted[content] = TRUE
	return visual
