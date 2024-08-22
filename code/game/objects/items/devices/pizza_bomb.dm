/obj/item/pizza_bomb
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pizzabox1"
	throw_range = 1
	var/timer = 1 SECONDS //Adjustable timer
	var/timer_set = FALSE
	var/primed = FALSE
	var/disarmed = FALSE
	var/wires = list("orange", "green", "blue", "yellow", "aqua", "purple")
	var/correct_wire
	var/armer //Used for admin purposes


/obj/item/pizza_bomb/Initialize(mapload)
	. = ..()
	correct_wire = pick(wires)


/obj/item/pizza_bomb/update_icon_state()
	if(disarmed)
		icon_state = "pizzabox_bomb_[correct_wire]"
		return
	if(primed || !timer_set)
		icon_state = "pizzabox_bomb"
		return
	icon_state = "pizzabox1"


/obj/item/pizza_bomb/update_name(updates)
	. = ..()
	if(timer_set && !disarmed)
		name = "pizza box"
	else
		name = "pizza bomb"


/obj/item/pizza_bomb/update_desc(updates)
	. = ..()
	if(disarmed)
		desc = "A devious contraption, made of a small explosive payload hooked up to pressure-sensitive wires. It's disarmed."
		return
	if(primed)
		desc = "OH GOD THAT'S NOT A PIZZA"
		return
	if(timer_set)
		desc = "A box suited for pizzas."
	else
		desc = "It seems inactive."


/obj/item/pizza_bomb/attack_self(mob/user)
	if(disarmed)
		to_chat(user, "<span class='notice'>\The [src] is disarmed.</span>")
		return

	if(!timer_set)
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
		var/new_timer = tgui_input_number(user, "Set a timer, from one second to ten seconds.", "Timer", timer / 10, 10, 1)
		if(!new_timer)
			return
		if(!Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			timer_set = 0
			name = "pizza box"
			desc = "A box suited for pizzas."
			icon_state = "pizzabox1"
			return
		timer = new_timer SECONDS
		timer_set = TRUE
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
		to_chat(user, "<span class='notice'>You set the timer to [timer / 10] before activating the payload and closing \the [src].")
		message_admins("[key_name_admin(usr)] has set a timer on a pizza bomb to [timer/10] seconds at [ADMIN_COORDJMP(loc)].")
		add_game_logs("has set the timer on a pizza bomb to [timer/10] seconds [COORD(loc)].", usr)
		armer = usr
		return

	if(!primed)
		audible_message("<span class='warning'>[bicon(src)] *beep* *beep*</span>")
		to_chat(user, "<span class='danger'>That's no pizza! That's a bomb!</span>")
		message_admins("[key_name_admin(usr)] has triggered a pizza bomb armed by [armer] at [ADMIN_COORDJMP(loc)].")
		add_game_logs("has triggered a pizza bomb armed by [armer] [COORD(loc)].", usr)
		primed = TRUE
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
		addtimer(CALLBACK(src, PROC_REF(go_boom)), timer)


/obj/item/pizza_bomb/proc/go_boom()
	if(disarmed)
		visible_message("<span class='danger'>[bicon(src)] Sparks briefly jump out of the [correct_wire] wire on \the [src], but it's disarmed!")
		return
	atom_say("Наслаждайтесь пиццей!")
	src.visible_message("<span class='userdanger'>\The [src] violently explodes!</span>")
	explosion(src.loc,1,2,4,flame_range = 2) //Identical to a minibomb
	qdel(src)


/obj/item/pizza_bomb/wirecutter_act(mob/living/user, obj/item/I)
	if(!primed && !disarmed)	// its a secret!
		return FALSE

	. = TRUE

	if(disarmed)
		user.visible_message(span_notice("[user] starts removing the payload and wires from [src]..."))
		if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume))
			return .
		user.visible_message(span_notice("[user] removes the insides of [src]!"))
		user.drop_item_ground(src, force = TRUE)
		new /obj/item/stack/cable_coil(loc, 3)
		new /obj/item/bombcore/miniature(loc)
		new /obj/item/pizzabox(loc)
		qdel(src)
		return .

	to_chat(user, span_danger("Oh God, what wire do you cut?!"))
	var/chosen_wire = tgui_input_list(user, "OH GOD, OH GOD", "WHAT WIRE?!", wires)
	if(!chosen_wire || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	user.visible_message(
		span_danger("[user] cuts the [chosen_wire] wire!"),
		span_userdanger("You cut the [chosen_wire] wire!"),
	)
	sleep(0.5 SECONDS)
	if(chosen_wire != correct_wire)
		to_chat(user, span_userdanger("WRONG WIRE!!!"))
		go_boom()
		return .
	audible_message(span_warning("[bicon(src)] The [name] suddenly stops beeping and seems lifeless."))
	to_chat(user, span_notice("You did it!"))
	disarmed = TRUE
	primed = FALSE
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)


/obj/item/pizza_bomb/autoarm
	timer_set = 1
	timer = 30 // 3 seconds
