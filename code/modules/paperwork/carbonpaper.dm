/obj/item/paper/carbon
	icon_state = "paper_stack"
	var/copied = FALSE
	var/iscopy = FALSE

/obj/item/paper/carbon/update_icon_state()
	. = ..()
	var/has_text = LAZYLEN(raw_text_inputs) && show_written_words
	if(iscopy)
		icon_state = has_text ? "cpaper_words" : "cpaper"
	else if(copied)
		icon_state = has_text ? "paper_words" : "paper"
	else
		icon_state = has_text ? "paper_stack_words" : "paper_stack"

GAME_VERB_SRC(/obj/item/paper/carbon, removecopy, usr, "Удалить копию", VERB_CATEGORY_HIDDEN)
	if(usr.incapacitated || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(!copied)
		var/obj/item/paper/carbon/copy = copy(/obj/item/paper/carbon, usr.loc, colored = FALSE)
		copy.name = "Copy - [name]"
		copy.iscopy = TRUE
		copy.copied = TRUE
		LAZYNULL(copy.raw_stamp_data)
		LAZYNULL(copy.stamp_cache)
		copy.cut_overlays()
		copy.update_appearance()

		copied = TRUE
		update_appearance()
		to_chat(usr, span_notice("You tear off the carbon-copy!"))
	else
		to_chat(usr, span_warning("There are no more carbon copies attached to this paper!"))
