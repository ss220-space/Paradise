GLOBAL_LIST_EMPTY(rad_collectors)

/obj/machinery/power/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = 1
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


/obj/machinery/power/rad_collector/attack_hand(mob/user as mob)
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


/obj/machinery/power/rad_collector/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		add_fingerprint(user)
		to_chat(user, "<span class='notice'>The [W.name] detects that [last_power]W were recently produced.</span>")
		return 1
	else if(istype(W, /obj/item/tank/internals/plasma))
		if(!src.anchored)
			to_chat(user, "<span class='warning'>The [src] needs to be secured to the floor first.</span>")
			return 1
		if(src.P)
			to_chat(user, "<span class='warning'>There's already a plasma tank loaded.</span>")
			return 1
		add_fingerprint(user)
		user.drop_transfer_item_to_loc(W, src)
		src.P = W
		update_icon()
	else if(W.tool_behaviour == TOOL_CROWBAR)
		if(P && !src.locked)
			add_fingerprint(user)
			eject()
			return 1
	else if(W.tool_behaviour == TOOL_WRENCH)
		if(P)
			to_chat(user, "<span class='notice'>Remove the plasma tank first.</span>")
			return 1
		add_fingerprint(user)
		playsound(src.loc, W.usesound, 75, 1)
		src.anchored = !src.anchored
		user.visible_message("[user.name] [anchored? "secures":"unsecures"] the [src.name].", \
			"You [anchored? "secure":"undo"] the external bolts.", \
			"You hear a ratchet")
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()
	else if(W.GetID() || ispda(W))
		if(src.allowed(user))
			add_fingerprint(user)
			if(active)
				src.locked = !src.locked
				to_chat(user, "The controls are now [src.locked ? "locked." : "unlocked."]")
			else
				src.locked = 0 //just in case it somehow gets locked
				to_chat(user, "<span class='warning'>The controls can only be locked when the [src] is active</span>")
		else
			to_chat(user, "<span class='warning'>Access denied!</span>")
			return 1
	else
		return ..()

/obj/machinery/power/rad_collector/return_analyzable_air()
	if(P)
		return P.return_analyzable_air()
	return null

/obj/machinery/power/rad_collector/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		eject()
		stat |= BROKEN

/obj/machinery/power/rad_collector/proc/eject()
	locked = 0
	var/obj/item/tank/internals/plasma/Z = src.P
	if(!Z)
		return
	Z.loc = get_turf(src)
	Z.layer = initial(Z.layer)
	Z.plane = initial(Z.plane)
	src.P = null
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

