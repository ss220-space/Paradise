/obj/item/pipe_painter
	name = "pipe painter"
	icon = 'icons/obj/device.dmi'
	icon_state = "pipe_painter"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	item_state = "pipe_painter"
	usesound = 'sound/effects/spray2.ogg'
	toolbox_radial_menu_compatibility = TRUE
	var/list/modes
	var/mode

/obj/item/pipe_painter/New()
	..()
	modes = new()
	for(var/C in GLOB.pipe_colors)
		modes += "[C]"
	mode = pick(modes)

/obj/item/pipe_painter/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!istype(target, /obj/machinery/atmospherics/pipe) || istype(target, /obj/machinery/atmospherics/pipe/simple/heat_exchanging) || istype(target, /obj/machinery/atmospherics/pipe/simple/insulated) || !in_range(user, target))
		return

	var/obj/machinery/atmospherics/pipe/P = target

	if(P.pipe_color == "[GLOB.pipe_colors[mode]]")
		to_chat(user, span_notice("This pipe is aready painted [mode]!"))
		return

	if(HAS_TRAIT(P, TRAIT_UNDERFLOOR))
		to_chat(user, span_warning("You must remove the plating first."))
		return

	playsound(loc, usesound, 30, TRUE)
	P.change_color(GLOB.pipe_colors[mode])

/obj/item/pipe_painter/attack_self(mob/user as mob)
	var/new_paint_setting = tgui_input_list(user, "Which color do you want to use?", "Pick color", modes)
	if(!new_paint_setting)
		return
	mode = new_paint_setting

/obj/item/pipe_painter/examine(mob/user)
	. = ..()
	. += span_notice("It is in [mode] mode.")
