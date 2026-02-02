/// An info button that, when clicked, puts some text in the user's chat
/obj/effect/info
	name = "info"
	icon_state = "info"

	/// What should the info button display when clicked?
	var/info_text

/obj/effect/info/Initialize(mapload, info_text)
	. = ..()

	if(isnull(info_text))
		return

	src.info_text = info_text

/obj/effect/info/Click()
	. = ..()
	to_chat(usr, info_text)

/obj/effect/info/MouseEntered(location, control, params)
	. = ..()
	icon_state = "info_hovered"

/obj/effect/info/MouseExited()
	. = ..()
	icon_state = initial(icon_state)
