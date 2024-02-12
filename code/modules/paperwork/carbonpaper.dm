/obj/item/paper/carbon
	name = "paper"
	icon_state = "paper_stack"
	item_state = "paper"
	var/copied = FALSE
	var/iscopy = FALSE

/obj/item/paper/carbon/examine(mob/user)
	. = ..()
	if(!iscopy)
		. += span_info("<b>Alt-Shift-Click</b> to remove carbon-copy.")

/obj/item/paper/carbon/update_icon_state()
	if(iscopy)
		if(info)
			icon_state = "cpaper_words"
			return
		icon_state = "cpaper"
	else if(copied)
		if(info)
			icon_state = "paper_words"
			return
		icon_state = "paper"
	else
		if(info)
			icon_state = "paper_stack_words"
			return
		icon_state = "paper_stack"


/obj/item/paper/carbon/AltShiftClick(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return

	if(iscopy || copied)
		to_chat(usr, "There are no more carbon copies attached to this paper!")
		return
	var/copycontents = html_decode(info)
	var/obj/item/paper/carbon/copy = new /obj/item/paper/carbon (usr.loc)
	copycontents = replacetext(copycontents, "<font face=\"[deffont]\" color=", "<font face=\"[deffont]\" nocolor=")	//state of the art techniques in action
	copycontents = replacetext(copycontents, "<font face=\"[crayonfont]\" color=", "<font face=\"[crayonfont]\" nocolor=")	//This basically just breaks the existing color tag, which we need to do because the innermost tag takes priority.
	copy.info += copycontents
	copy.info += "</font>"
	copy.name = "Copy - " + name
	copy.fields = fields
	copy.updateinfolinks()
	to_chat(usr, "<span class='notice'>You tear off the carbon-copy!</span>")
	copied = TRUE
	copy.iscopy = TRUE
	copy.update_icon()
	update_icon()
