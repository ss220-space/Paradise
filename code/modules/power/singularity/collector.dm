GLOBAL_LIST_EMPTY(rad_collectors)

/obj/machinery/power/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)
//	use_power = NO_POWER_USE
	max_integrity = 350
	integrity_failure = 80
	var/obj/item/tank/internals/plasma/P = null
	var/last_power = 0
	var/active = 0
	var/locked = 0
	var/drainratio = 1

/obj/machinery/power/rad_collector/Initialize(mapload)
	. = ..()
	GLOB.rad_collectors += src

/obj/machinery/power/rad_collector/Destroy()
	GLOB.rad_collectors -= src
	return ..()

/obj/machinery/power/rad_collector/process()
	if(P)
		if(P.air_contents.toxins <= 0)
			investigate_log("<font color='red'>out of fuel</font>.", INVESTIGATE_ENGINE)
			P.air_contents.toxins = 0
			eject()
		else
			P.air_contents.toxins -= 0.001*drainratio
	return


/obj/machinery/power/rad_collector/attack_hand(mob/user)
	if(..())
		return TRUE

	if(anchored)
		if(!src.locked)
			add_fingerprint(user)
			toggle_power()
			user.visible_message("[user.name] turns the [src.name] [active? "on":"off"].", \
			"You turn the [src.name] [active? "on":"off"].")
			investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [key_name_log(user)]. [P?"Fuel: [round(P.air_contents.toxins/0.29)]%":"<font color='red'>It is empty</font>"].", INVESTIGATE_ENGINE)
			return
		else
			to_chat(user, "<span class='warning'>The controls are locked!</span>")
			return


/obj/machinery/power/rad_collector/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/tank/internals/plasma))
		add_fingerprint(user)
		if(!anchored)
			to_chat(user, span_warning("The [name] should be secured to the floor first."))
			return ATTACK_CHAIN_PROCEED
		if(P)
			to_chat(user, span_warning("The [name] already has a plasma tank loaded."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You have loaded the plasma tank into [src]."))
		P = I
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(I.GetID() || is_pda(I))
		add_fingerprint(user)
		if(!allowed(user))
			to_chat(user, span_warning("Access denied."))
			return ATTACK_CHAIN_PROCEED
		if(!active)
			locked = FALSE //just in case it somehow gets locked
			to_chat(user, span_warning("The controls can only be locked while [src] is active."))
			return ATTACK_CHAIN_PROCEED
		locked = !locked
		to_chat(user, span_notice("The controls are now [locked ? "locked." : "unlocked."]"))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/power/rad_collector/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(P)
		add_fingerprint(user)
		to_chat(user, span_warning("You should remove the plasma tank first."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	set_anchored(!anchored)
	if(anchored)
		user.visible_message(
			span_notice("[user] has secured [src] to the floor."),
			span_notice("You have secured [src] to the floor."),
			span_italics("You hear a ratchet"),
		)
		connect_to_network()
	else
		user.visible_message(
			span_notice("[user] has unsecured [src] from floor."),
			span_notice("You have unsecured [src] from floor."),
			span_italics("You hear a ratchet"),
		)
		disconnect_from_network()


/obj/machinery/power/rad_collector/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	add_fingerprint(user)
	if(!P)
		to_chat(user, span_warning("The [name] has no loaded plasma tanks."))
		return .
	if(locked)
		to_chat(user, span_warning("The [name] is locked."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	eject(user)


/obj/machinery/power/rad_collector/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	to_chat(user, span_notice("The [I.name] detects that [last_power]W were recently produced.."))


/obj/machinery/power/rad_collector/return_analyzable_air()
	if(P)
		return P.return_analyzable_air()
	return null

/obj/machinery/power/rad_collector/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(obj_flags & NODECONSTRUCT))
		eject()
		stat |= BROKEN


/obj/machinery/power/rad_collector/proc/eject(mob/user)
	locked = FALSE
	if(!P)
		return
	P.forceMove_turf()
	user?.put_in_hands(P, ignore_anim = FALSE)
	P = null
	if(active)
		toggle_power()
	else
		update_icon()


/obj/machinery/power/rad_collector/proc/receive_pulse(var/pulse_strength)
	if(P && active)
		var/power_produced = 0
		power_produced = P.air_contents.toxins*pulse_strength*20
		add_avail(power_produced)
		last_power = power_produced
		return


/obj/machinery/power/rad_collector/update_icon_state()
	icon_state = "ca[active ? "_on" : ""]"


/obj/machinery/power/rad_collector/update_overlays()
	. = ..()
	if(P)
		. +=  "ptank"
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		. += "on"


/obj/machinery/power/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		flick("ca_active", src)
	else
		flick("ca_deactive", src)
	update_icon()

