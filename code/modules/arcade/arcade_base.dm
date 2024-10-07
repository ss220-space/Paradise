
/obj/machinery/arcade
	name = "Arcade Game"
	desc = "One of the most generic arcade games ever."
	icon = 'icons/obj/machines/arcade.dmi'
	icon_state = "clawmachine_on"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	var/tokens = 0
	var/freeplay = 0				//for debugging and admin kindness
	var/token_price = 0
	var/last_winner = null			//for letting people who to hunt down and steal prizes from
	var/window_name = "arcade"		//in case you want to change the window name for certain machines

/obj/machinery/arcade/Initialize(mapload)
	. = ..()
	if(type == /obj/machinery/arcade)		//if you spawn the base-type, it will replace itself with a random subtype for randomness
		var/choice = pick(subtypesof(/obj/machinery/arcade))
		new choice(loc)
		return INITIALIZE_HINT_QDEL

/obj/machinery/arcade/examine(mob/user)
	. = ..()
	if(freeplay)
		. += "<span class='notice'>Someone enabled freeplay on this machine!</span>"
	else
		if(token_price)
			. += "<span class='notice'>\The [src.name] costs [token_price] credits per play.</span>"
		if(!tokens)
			. += "<span class='notice'>\The [src.name] has no available play credits. Better feed the machine!</span>"
		else if(tokens == 1)
			. += "<span class='notice'>\The [src.name] has only 1 play credit left!</span>"
		else
			. += "<span class='notice'>\The [src.name] has [tokens] play credits!</span>"

/obj/machinery/arcade/attack_hand(mob/user)
	if(..())
		if(in_use && src == user.machine)	//this one checks if they fell down/died and closes the game
			src.close_game()
		return
	if(in_use && src == user.machine)		//this one just checks if they are playing so it doesn't eat tokens
		return
	interact(user)

/obj/machinery/arcade/interact(mob/user)
	if(stat & BROKEN || panel_open)
		return
	if(!tokens && !freeplay)
		balloon_alert(user, "недостаточно кредитов!")
		return
	if(!in_use && (tokens || freeplay))
		in_use = 1
		start_play(user)
		return
	if(in_use)
		if(src != user.machine)
			balloon_alert(user, "автомат занят!")
		return

/obj/machinery/arcade/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(!freeplay)
		add_fingerprint(user)
		if(I.GetID())
			if(pay_with_card(user, token_price, name))
				tokens += 1
				return ATTACK_CHAIN_PROCEED_SUCCESS
			return ATTACK_CHAIN_PROCEED

		if(istype(I, /obj/item/stack/spacecash))
			if(pay_with_cash(I, user, token_price, name))
				tokens += 1
				return ATTACK_CHAIN_PROCEED_SUCCESS
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/machinery/arcade/screwdriver_act(mob/living/user, obj/item/I)
	if(!anchored)
		return FALSE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	update_icon(UPDATE_ICON_STATE)
	return TRUE


/obj/machinery/arcade/crowbar_act(mob/living/user, obj/item/I)
	if(!component_parts || !panel_open)
		return FALSE
	default_deconstruction_crowbar(user, I)
	return TRUE


/obj/machinery/arcade/proc/start_play(mob/user)
	user.set_machine(src)
	if(!freeplay)
		tokens -= 1

/obj/machinery/arcade/proc/close_game()
	in_use = 0
	for(var/mob/user in viewers(world.view, src))			// I don't know who you are.
		if(user.client && user.machine == src)				// I will look for you,
			user.unset_machine()							// I will find you,
			user << browse(null, "window=[window_name]")	// And I will kill you.
	return

/obj/machinery/arcade/proc/win()
	return

/obj/machinery/arcade/process()
	if(in_use)
		src.updateUsrDialog()
		if(!in_use)
			src.close_game()

/obj/machinery/arcade/Destroy()
	src.close_game()
	return ..()
