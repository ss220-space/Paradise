#define TALL_CANDLE 1
#define MID_CANDLE 2
#define SHORT_CANDLE 3

/obj/item/candle
	name = "red candle"
	desc = "In Greek myth, Prometheus stole fire from the Gods and gave it to humankind. The jewelry he kept for himself."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = WEIGHT_CLASS_TINY
	var/wax = 200
	/// Index for the icon state
	var/wax_index = TALL_CANDLE
	var/lit = FALSE
	var/infinite = FALSE
	var/start_lit = FALSE
	var/flickering = FALSE
	light_color = "#E09D37"


/obj/item/candle/Initialize(mapload)
	. = ..()
	if(start_lit)
		// No visible message
		light(show_message = FALSE)


/obj/item/candle/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/candle/update_icon_state()
	if(flickering)
		icon_state = "candle[wax_index]_flicker"
	else
		icon_state = "candle[wax_index][lit ? "_lit" : ""]"


/obj/item/candle/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>[S] can't hold [src] while it's lit!</span>")
		return FALSE
	return TRUE


/obj/item/candle/attackby(obj/item/W, mob/user, params)
	if(is_hot(W))
		light("<span class='notice'>[user] lights [src] with [W].</span>")
		return
	return ..()


/obj/item/candle/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(I.tool_use_check(user, 0)) //Don't need to flash eyes because you are a badass
		light("<span class='notice'>[user] casually lights the [name] with [I], what a badass.</span>")


/obj/item/candle/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(!lit)
		light() //honk
	return ..()


/obj/item/candle/proc/light(show_message)
	if(!lit)
		lit = TRUE
		if(show_message)
			usr.visible_message(show_message)
		set_light(CANDLE_LUM)
		START_PROCESSING(SSobj, src)
		update_icon(UPDATE_ICON_STATE)


/obj/item/candle/proc/update_wax_index()
	var/new_wax_index
	if(wax > 150)
		new_wax_index = TALL_CANDLE
	else if(wax > 80)
		new_wax_index = MID_CANDLE
	else
		new_wax_index = SHORT_CANDLE
	if(wax_index != new_wax_index)
		wax_index = new_wax_index
		return TRUE
	return FALSE


/obj/item/candle/proc/start_flickering()
	flickering = TRUE
	update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, PROC_REF(stop_flickering)), 4 SECONDS, TIMER_UNIQUE)


/obj/item/candle/proc/stop_flickering()
	flickering = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/item/candle/process()
	if(!lit)
		return
	if(!infinite)
		wax--
		if(wax_index != SHORT_CANDLE) // It's not at its shortest
			if(update_wax_index())
				update_icon(UPDATE_ICON_STATE)
	if(!wax)
		spawn_candle_trash()
		qdel(src)
	update_icon(UPDATE_ICON_STATE)
	if(isturf(loc)) //start a fire if possible
		var/turf/T = loc
		T.hotspot_expose(700, 5)

/obj/item/candle/proc/spawn_candle_trash()
	new/obj/item/trash/candle(src.loc)
	if(istype(src.loc, /mob))
		var/mob/M = src.loc
		M.temporarily_remove_item_from_inventory(src, force = TRUE) //src is being deleted anyway

/obj/item/candle/proc/unlight()
	if(lit)
		lit = FALSE
		update_icon(UPDATE_ICON_STATE)
		set_light(0)


/obj/item/candle/attack_self(mob/user)
	if(lit)
		user.visible_message("<span class='notice'>[user] snuffs out [src].</span>")
		unlight()


/obj/item/candle/get_spooked()
	if(lit)
		start_flickering()
		playsound(src, 'sound/effects/candle_flicker.ogg', 15, TRUE)
		return TRUE
	return FALSE


/obj/item/candle/eternal
	desc = "A candle. This one seems to have an odd quality about the wax."
	infinite = TRUE


/obj/item/candle/eternal/wizard
	desc = "A candle. It smells like magic, so that would explain why it burns brighter."
	start_lit = TRUE


/obj/item/candle/extinguish_light(force = FALSE)
	if(!force)
		return
	infinite = FALSE
	wax = 1 // next process will burn it out

/obj/item/candle/torch
	name = "torch"
	desc = "A torch fashioned from a stick and a piece of cloth."
	wax = 300
	icon = 'icons/obj/lighting.dmi'
	icon_state = "torch"
	item_state = "torch"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	light_color = LIGHT_COLOR_ORANGE
	slot_flags = SLOT_BELT
	materials = list(MAT_BIOMASS = 50)

	damtype = BURN
	force = 7
	var/force_lower = 5
	var/force_upp = 10

	var/icon_on = "torch-on"
	var/fuel_lower = 200
	var/fuel_upp = 400

/obj/item/candle/torch/New()
	wax = rand(fuel_lower, fuel_upp)
	force = rand(force_lower, force_upp)
	..()

/obj/item/candle/torch/update_icon_state()
	if(lit)
		icon_state = icon_on
		item_state = icon_on
	else
		icon_state = initial(icon_state)
		item_state = initial(icon_state)

	update_equipped_item()


/obj/item/candle/torch/light(show_message)
	if(!lit)
		lit = TRUE
		if(show_message)
			usr.visible_message(show_message)
		set_light(5)
		START_PROCESSING(SSobj, src)
		update_icon(UPDATE_ICON_STATE)

/obj/item/candle/torch/spawn_candle_trash()
	var/obj/item/burnt_torch/T = new(loc)
	if(ismob(loc))
		var/mob/M = loc
		M.temporarily_remove_item_from_inventory(src, force = TRUE)
		M.put_in_hands(T)

/obj/item/candle/torch/can_enter_storage(obj/item/storage/S, mob/user)
	return

#undef TALL_CANDLE
#undef MID_CANDLE
#undef SHORT_CANDLE

