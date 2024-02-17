/obj/item/pizza_bomb
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pizzabox1"
	throw_range = 1
	var/timer = 10 //Adjustable timer
	var/timer_set = FALSE
	var/primed = FALSE
	var/disarmed = FALSE
	var/wires = list("orange", "green", "blue", "yellow", "aqua", "purple")
	var/correct_wire
	var/armer //Used for admin purposes


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
		timer = (input(user, "Set a timer, from one second to ten seconds.", "Timer", "[timer]") as num) * 10
		if(!in_range(src, usr) || issilicon(usr) || !usr.canmove || usr.restrained())
			timer_set = 0
			name = "pizza box"
			desc = "A box suited for pizzas."
			icon_state = "pizzabox1"
			return
		timer = clamp(timer, 10, 100)
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


/obj/item/pizza_bomb/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER && primed)
		to_chat(user, "<span class='danger'>Oh God, what wire do you cut?!</span>")
		var/chosen_wire = input(user, "OH GOD OH GOD", "WHAT WIRE?!") in wires
		if(!in_range(src, usr) || issilicon(usr) || !usr.canmove || usr.restrained())
			return
		playsound(src, I.usesound, 50, 1, 1)
		user.visible_message("<span class='warning'>[user] cuts the [chosen_wire] wire!</span>", "<span class='danger'>You cut the [chosen_wire] wire!</span>")
		sleep(5)
		if(chosen_wire == correct_wire)
			audible_message("<span class='warning'>[bicon(src)] \The [src] suddenly stops beeping and seems lifeless.</span>")
			to_chat(user, "<span class='notice'>You did it!</span>")
			disarmed = TRUE
			primed = FALSE
			update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
			return
		else
			to_chat(user, "<span class='userdanger'>WRONG WIRE!</span>")
			go_boom()
			return
	if(I.tool_behaviour == TOOL_WIRECUTTER && disarmed)
		if(!in_range(user, src))
			to_chat(user, "<span class='warning'>You can't see the box well enough to cut the wires out.</span>")
			return
		user.visible_message("<span class='notice'>[user] starts removing the payload and wires from \the [src].</span>")
		if(do_after(user, 40 * I.toolspeed * gettoolspeedmod(user), target = src))
			playsound(src, I.usesound, 50, 1, 1)
			user.drop_item_ground(src)
			user.visible_message("<span class='notice'>[user] removes the insides of \the [src]!</span>")
			new /obj/item/stack/cable_coil(src.loc, 3)
			new /obj/item/bombcore/miniature(src.loc)
			new /obj/item/pizzabox(src.loc)
			qdel(src)
		return
	..()

/obj/item/pizza_bomb/New()
	..()
	correct_wire = pick(wires)

/obj/item/pizza_bomb/autoarm
	timer_set = 1
	timer = 30 // 3 seconds
