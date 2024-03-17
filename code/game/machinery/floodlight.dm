/obj/machinery/floodlight
	name = "emergency floodlight"
	icon = 'icons/obj/floodlight.dmi'
	icon_state = "flood00"
	anchored = FALSE
	density = TRUE
	max_integrity = 100
	integrity_failure = 80
	light_power = 20
	light_range = 14
	light_system = STATIC_LIGHT
	light_on = FALSE
	var/on = FALSE
	var/obj/item/stock_parts/cell/high/cell = null
	var/use = 5
	var/unlocked = FALSE
	var/open = FALSE

/obj/machinery/floodlight/get_cell()
	return cell

/obj/machinery/floodlight/Initialize()
	. = ..()
	cell = new(src)
	mapVarInit()

/obj/machinery/floodlight/Destroy()
	QDEL_NULL(cell)
	return ..()


/obj/machinery/floodlight/proc/mapVarInit()
	if(on)
		if(!cell)
			return
		if(cell.charge <= 0)
			return
		set_light_on(TRUE)
		update_icon(UPDATE_ICON_STATE)


/obj/machinery/floodlight/examine(mob/user)
	. = ..()
	if(!unlocked)
		. += span_notice("The panel is <b>screwed</b> shut.")
	else
		if(open)
			. += span_notice("The panel is <b>pried</b> open, looks like you could fit a cell in there.")
		else
			. += span_notice("The panel looks like it could be <b>pried</b> open, or <b>screwed</b> shut.")


/obj/machinery/floodlight/update_icon_state()
	icon_state = "flood[open ? "o" : ""][open && cell ? "b" : ""]0[on]"


/obj/machinery/floodlight/process()
	if(!on)
		return

	if(cell && !cell.use(use))
		on = FALSE
		update_icon(UPDATE_ICON_STATE)
		set_light_on(FALSE)
		visible_message(span_warning("[src] shuts down due to lack of power!"))


/obj/machinery/floodlight/attack_ai()
	return

/obj/machinery/floodlight/attack_hand(mob/user)
	add_fingerprint(user)
	if(open && cell)
		if(user.get_active_hand())
			to_chat(user, span_warning("Your hand is occupied!"))
			return
		cell.forceMove_turf()
		cell.add_fingerprint(user)
		cell.update_icon(UPDATE_OVERLAYS)
		user.put_in_hands(cell, ignore_anim = FALSE)
		cell = null
		to_chat(user, span_notice("You remove the power cell."))
		if(on)
			on = FALSE
			visible_message(span_warning("[src] shuts down due to lack of power!"))
			set_light_on(FALSE)
		update_icon(UPDATE_ICON_STATE)
		return

	if(on)
		on = FALSE
		to_chat(user, span_notice("You turn off the light."))
		set_light_on(FALSE)
	else
		if(!cell)
			to_chat(user, span_warning("You try to turn on [src] but nothing happens! Seems like it <b>lacks a power cell</b>."))
			return
		if(cell.charge <= 0)
			to_chat(user, span_warning("[src] hardly glows at all! Seems like the <b>power cell is empty</b>."))
			return
		if(!anchored)
			to_chat(user, span_warning("[src] must be anchored first!"))
			return
		on = TRUE
		to_chat(user, span_notice("You turn on the light."))
		set_light_on(TRUE)
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/floodlight/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		if(open)
			if(cell)
				to_chat(user, span_warning("There is a power cell already installed."))
			else
				add_fingerprint(user)
				user.drop_transfer_item_to_loc(I, src)
				cell = I
				to_chat(user, span_notice("You insert the power cell."))
		update_icon(UPDATE_ICON_STATE)
		return
	return ..()


/obj/machinery/floodlight/crowbar_act(mob/living/user, obj/item/I)
	add_fingerprint(user)
	if(!unlocked)
		to_chat(user, span_warning("The cover is screwed tightly down."))
		return TRUE

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	if(open)
		to_chat(user, span_notice("You pry the panel closed."))
	else
		to_chat(user, span_notice("You pry the panel open."))
	open = !open
	update_icon(UPDATE_ICON_STATE)
	return TRUE


/obj/machinery/floodlight/screwdriver_act(mob/living/user, obj/item/I)
	add_fingerprint(user)
	if(open)
		to_chat(user, span_warning("The screws can't reach while its open."))
		return TRUE

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	if(open)
		return

	if(unlocked)
		to_chat(user, span_notice("You screw the battery panel in place."))
	else
		to_chat(user, span_notice("You unscrew the battery panel."))
	unlocked = !unlocked
	update_icon(UPDATE_ICON_STATE)
	return TRUE


/obj/machinery/floodlight/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(anchored)
		extinguish_light()
	default_unfasten_wrench(user, I)


/obj/machinery/floodlight/extinguish_light(force = FALSE)
	if(on)
		on = FALSE
		set_light_on(FALSE)
		update_icon(UPDATE_ICON_STATE)

