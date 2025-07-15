// stored_energy += (pulse_strength - RAD_COLLECTOR_EFFICIENCY) * RAD_COLLECTOR_COEFFICIENT
#define RAD_COLLECTOR_EFFICIENCY 80 	// radiation needs to be over this amount to get power
#define RAD_COLLECTOR_COEFFICIENT 100
#define RAD_COLLECTOR_STORED_OUT 0.04	// (this * 100)% of stored power outputted per tick. Doesn't actualy change output total, lower numbers just means collectors output for longer in absence of a source
#define RAD_COLLECTOR_OUTPUT min(stored_energy, (stored_energy * RAD_COLLECTOR_STORED_OUT) + 1000) //Produces at least 1000 watts if it has more than that stored

GLOBAL_LIST_EMPTY(rad_collectors)

/obj/machinery/power/rad_collector
	name = "\improper radiation collector array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)
	max_integrity = 350
	integrity_failure = 80
	rad_insulation = RAD_EXTREME_INSULATION
	var/obj/item/tank/internals/plasma/loaded_tank = null
	var/stored_energy = 0
	var/active = FALSE
	var/locked = FALSE
	var/drainratio = 1
	var/powerproduction_drain = 0.001

/obj/machinery/power/rad_collector/Initialize(mapload)
	. = ..()
	GLOB.rad_collectors += src

/obj/machinery/power/rad_collector/Destroy()
	GLOB.rad_collectors -= src
	return ..()

/obj/machinery/power/rad_collector/process()
	if(!loaded_tank)
		return
	if(!loaded_tank.air_contents.toxins)
		investigate_log("[span_red("out of fuel")].", INVESTIGATE_SINGULO)
		playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
		eject()
	else
		var/gasdrained = min(powerproduction_drain * drainratio, loaded_tank.air_contents.toxins)
		loaded_tank.air_contents.toxins -= gasdrained

		var/power_produced = RAD_COLLECTOR_OUTPUT
		add_avail(power_produced)
		stored_energy -= power_produced


/obj/machinery/power/rad_collector/attack_hand(mob/user)
	if(..())
		return TRUE

	if(anchored)
		if(!locked)
			add_fingerprint(user)
			toggle_power()
			user.visible_message("[user.name] turns the [name] [active ? "on" : "off"].", "You turn the [name] [active ? "on" : "off"].")
			investigate_log("turned [active ? "<font color='green'>on</font>" : "<font color='red'>off</font>"] by [user.key]. [loaded_tank ? "Fuel: [round(loaded_tank.air_contents.toxins / 0.29)]%" : "<font color='red'>It is empty</font>"].", INVESTIGATE_SINGULO)
		else
			to_chat(user, "<span class='warning'>The controls are locked!</span>")


/obj/machinery/power/rad_collector/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/tank/internals/plasma))
		add_fingerprint(user)
		if(!anchored)
			to_chat(user, span_warning("The [name] should be secured to the floor first."))
			return ATTACK_CHAIN_PROCEED
		if(loaded_tank)
			to_chat(user, span_warning("The [name] already has a plasma tank loaded."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You have loaded the plasma tank into [src]."))
		loaded_tank = I
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
	if(loaded_tank)
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
	if(!loaded_tank)
		to_chat(user, span_warning("The [name] has no loaded plasma tanks."))
		return .
	if(locked)
		to_chat(user, span_warning("The [name] is locked."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	eject(user)

/obj/machinery/power/rad_collector/return_analyzable_air()
	if(loaded_tank)
		return loaded_tank.return_analyzable_air()
	return null

/obj/machinery/power/rad_collector/examine(mob/user)
	. = ..()
	if(active)
		// stored_energy is converted directly to watts every SSmachines.wait * 0.1 seconds.
		// Therefore, its units are joules per SSmachines.wait * 0.1 seconds.
		// So joules = stored_energy * SSmachines.wait * 0.1
		var/joules = stored_energy * SSmachines.wait * 0.1
		. += "<span class='notice'>[src]'s display states that it has stored <b>[DisplayJoules(joules)]</b>, and is processing <b>[DisplayPower(RAD_COLLECTOR_OUTPUT)]</b>.</span>"
	else
		. += "<span class='notice'><b>[src]'s display displays the words:</b> \"Power production mode. Please insert <b>Plasma</b>.\"</span>"

/obj/machinery/power/rad_collector/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(obj_flags & NODECONSTRUCT))
		eject()
		stat |= BROKEN


/obj/machinery/power/rad_collector/proc/eject(mob/user)
	locked = FALSE
	if(!loaded_tank)
		return
	loaded_tank.forceMove_turf()
	user?.put_in_hands(loaded_tank, ignore_anim = FALSE)
	loaded_tank = null
	if(active)
		toggle_power()
	else
		update_icon()


/obj/machinery/power/rad_collector/rad_act(amount)
	. = ..()
	if(loaded_tank && active && amount > RAD_COLLECTOR_EFFICIENCY)
		stored_energy += (amount - RAD_COLLECTOR_EFFICIENCY) * RAD_COLLECTOR_COEFFICIENT


/obj/machinery/power/rad_collector/update_icon_state()
	icon_state = "ca[active ? "_on" : ""]"


/obj/machinery/power/rad_collector/update_overlays()
	. = ..()
	if(loaded_tank)
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

#undef RAD_COLLECTOR_EFFICIENCY
#undef RAD_COLLECTOR_COEFFICIENT
#undef RAD_COLLECTOR_STORED_OUT
#undef RAD_COLLECTOR_OUTPUT
