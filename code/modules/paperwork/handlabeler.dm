/obj/item/hand_labeler
	name = "hand labeler"
	desc = "A combined label printer, applicator, and remover, all in a single portable device. Designed to be easy to operate and use."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler_off"
	item_state = "labeler"
	var/label = null
	var/labels_left = 30
	var/mode = FALSE

/obj/item/hand_labeler/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return

	if(!mode)	//if it's off, give up.
		return

	if(!labels_left)
		to_chat(user, span_warning("No labels left!"))
		return

	if(!label || !length(label))
		to_chat(user, span_warning("No text set!"))
		return

	if(length(target.name) + length(label) > 64)
		to_chat(user, span_warning("Label too big!"))
		return

	if(ismob(target))
		to_chat(user, span_warning("You can't label creatures!")) // use a collar
		return

	user.visible_message(
		span_notice("[user] labels [target] as [label]."), \
		span_notice("You label [target] as [label].")
	)
	target.AddComponent(/datum/component/label, label)
	playsound(target, 'sound/items/handling/pickup/component_pickup.ogg', 20, TRUE)
	labels_left--

/obj/item/hand_labeler/update_icon_state()
	icon_state = "labeler_[mode ? "on" : "off"]"

/obj/item/hand_labeler/attack_self(mob/user)
	mode = !mode
	update_icon(UPDATE_ICON_STATE)
	if(mode)
		to_chat(user, span_notice("You turn on \the [src]."))
		//Now let them chose the text.
		var/str = reject_bad_text(tgui_input_text(user,"Label text?", "Set label"))
		if(!str || !length(str))
			to_chat(user, span_notice("Invalid text."))
			return
		label = str
		to_chat(user, span_notice("You set the text to '[str]'."))
	else
		to_chat(user, span_notice("You turn off \the [src]."))

/obj/item/hand_labeler/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/hand_labeler_refill))
		add_fingerprint(user)
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You have refilled [src]."))
		labels_left = initial(labels_left)	//Yes, it's capped at its initial value
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/hand_labeler_refill
	name = "hand labeler paper roll"
	icon = 'icons/obj/bureaucracy.dmi'
	desc = "A roll of paper. Use it on a hand labeler to refill it."
	icon_state = "labeler_refill"
	item_state = "labeler_refill"
	w_class = WEIGHT_CLASS_TINY
