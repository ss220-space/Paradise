/obj/item/pipe_painter/window_painter
	name = "window painter"
	icon_state = "window_painter"
	var/colour = "#ffffff"


	var/list/paintable_windows = list(
			/obj/structure/window/reinforced,
			/obj/structure/window/basic,
			/obj/structure/window/full/reinforced,
			/obj/structure/window/full/basic,
			/obj/machinery/door/window)


/obj/item/pipe_painter/window_painter/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)
	mode = "paint"


/obj/item/pipe_painter/window_painter/attack_self(mob/user)
	var/choice = input(user,"Painter options") in list("Pipette","Choose Color","Color Presets")
	switch(choice)
		if("Pipette")
			mode = "pipette"
		if("Choose Color")
			mode = "paint"
			colour = input(user,"Choose Color") as color
			update_icon(UPDATE_OVERLAYS)
		if("Color Presets")
			mode = "paint"
			colour = input("Which color do you want to use?", name, colour) in GLOB.pipe_colors
			update_icon(UPDATE_OVERLAYS)


/obj/item/pipe_painter/window_painter/afterattack(atom/A, mob/user, proximity, params)
	if(!is_type_in_list(A, paintable_windows) || !in_range(user, A))
		return
	var/obj/structure/window/W = A

	if(mode == "paint")
		W.color = colour
		playsound(loc, usesound, 30, TRUE)
	else
		colour = W.color
		mode = "paint"
		to_chat(user, span_notice("You copy color of this window."))
		update_icon(UPDATE_OVERLAYS)


/obj/item/pipe_painter/window_painter/update_overlays()
	. = ..()
	. += mutable_appearance(icon, icon_state = "window_painter_colour", color = colour)

