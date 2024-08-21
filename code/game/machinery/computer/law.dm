/obj/machinery/computer/aiupload
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."
	icon_screen = "command"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/aiupload
	var/mob/living/silicon/ai/current = null

	light_color = LIGHT_COLOR_WHITE
	light_range_on = 2


/obj/machinery/computer/aiupload/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/aiModule))
		add_fingerprint(user)
		if(!current)	//no AI selected
			to_chat(user, span_danger("No AI selected. Please chose a target before proceeding with upload."))
			return ATTACK_CHAIN_PROCEED
		if(!atoms_share_level(current, src))
			to_chat(user, span_danger("Unable to establish a connection") + ": You're too far away from the target silicon!")
			return ATTACK_CHAIN_PROCEED
		if(current.on_the_card)
			to_chat(user, span_danger("Unable to establish a connection") + ": Target silicon is on an inteliCard or undergoing a repair procedure!")
			return ATTACK_CHAIN_PROCEED
		var/obj/item/aiModule/aiModule = I
		aiModule.install(src)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/computer/aiupload/attack_hand(mob/user)
	if(src.stat & NOPOWER)
		to_chat(usr, "The upload computer has no power!")
		return
	if(src.stat & BROKEN)
		to_chat(usr, "The upload computer is broken!")
		return

	if(..())
		return TRUE

	src.current = select_active_ai(user)

	if(!src.current)
		to_chat(usr, "No active AIs detected.")
	else
		to_chat(usr, "[src.current.name] selected for law changes.")
	return


/obj/machinery/computer/aiupload/attack_ghost(mob/user)
	return TRUE


// Why is this not a subtype
/obj/machinery/computer/borgupload
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."
	icon_screen = "command"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/borgupload
	var/mob/living/silicon/robot/current = null


/obj/machinery/computer/borgupload/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/aiModule))
		if(!current)	//no borg selected
			to_chat(user, span_danger("No borg selected. Please chose a target before proceeding with upload."))
			return ATTACK_CHAIN_PROCEED
		if(!atoms_share_level(current, src))
			to_chat(user, span_danger("Unable to establish a connection") + ": You're too far away from the target silicon!")
			return ATTACK_CHAIN_PROCEED
		var/obj/item/aiModule/aiModule = I
		aiModule.install(src)
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/machinery/computer/borgupload/attack_hand(mob/user)
	if(src.stat & NOPOWER)
		to_chat(usr, "The upload computer has no power!")
		return
	if(src.stat & BROKEN)
		to_chat(usr, "The upload computer is broken!")
		return

	src.current = freeborg()

	if(!src.current)
		to_chat(usr, "No free cyborgs detected.")
	else
		to_chat(usr, "[src.current.name] selected for law changes.")
	return


/obj/machinery/computer/borgupload/attack_ghost(mob/user)
		return TRUE

