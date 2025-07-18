// stored_energy += (pulse_strength - RAD_COLLECTOR_THRESHOLD) * RAD_COLLECTOR_COEFFICIENT
#define RAD_COLLECTOR_THRESHOLD 80	// This gets subtracted from the value of absorbed radiation
#define RAD_COLLECTOR_COEFFICIENT 400
#define RAD_COLLECTOR_STORED_OUT 0.04	// (this * 100)% of stored power outputted per tick. Doesn't actualy change output total, lower numbers just means collectors output for longer in absence of a source
#define RAD_COLLECTOR_OUTPUT min(stored_energy, (stored_energy * RAD_COLLECTOR_STORED_OUT) + 1000) //Produces at least 1000 watts if it has more than that stored

GLOBAL_LIST_EMPTY(rad_collectors)

/obj/machinery/power/rad_collector
	name = "radiation collector array"
	desc = "Устройство, способное преобразовывать излучение в полезную электрическую энергию с помощью плазмы. Оно особенно эффективно поглощает бета-частицы, а также, в меньшей степени, гамма-частицы."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)
	max_integrity = 350
	integrity_failure = 80
	rad_insulation_beta = RAD_BETA_COLLECTOR
	rad_insulation_gamma = RAD_LIGHT_INSULATION
	var/obj/item/tank/internals/plasma/loaded_tank = null
	var/stored_energy = 0
	var/active = FALSE
	var/locked = FALSE
	var/drainratio = 1
	var/powerproduction_drain = 0.001
	var/power_threshold = RAD_COLLECTOR_THRESHOLD
	var/power_coefficient = RAD_COLLECTOR_COEFFICIENT
	/// A record of the absorbed strength of each beta wave that hit the collector. This keeps record up to rad_time old, and only the maximum absorption for each time point.
	var/beta_waves = list()
	/// A record of the absorbed strength of each gamma wave that hit the collector. This keeps record up to rad_time old, and only the maximum absorption for each time point.
	var/gamma_waves = list()
	/// Amount of time across which the maximum wave is checked
	var/rad_time = 5 SECONDS
	/// The current time count for clearing old data from the lists
	var/rad_time_counter = 0

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
	if(world.time > rad_time_counter)
		rad_time_counter = world.time + rad_time
		for(var/listing in gamma_waves)
			if(world.time > text2num(listing) + rad_time)
				gamma_waves -= listing
			// We put the listing in oldest to newest so as soon as we hit something new enough we can keep the rest
			else
				break
		for(var/listing in beta_waves)
			if(world.time > text2num(listing) + rad_time)
				beta_waves -= listing
			// We put the listing in oldest to newest so as soon as we hit something new enough we can keep the rest
			else
				break


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
		var/max_beta = 0
		var/max_gamma = 0
		// Find the maximum beta and gamma absorptions we have logged
		for(var/listing in beta_waves)
			if(max_beta < beta_waves[listing])
				max_beta = beta_waves[listing]
		for(var/listing in gamma_waves)
			if(max_gamma < gamma_waves[listing])
				max_gamma = gamma_waves[listing]
		var/beta_delta = max_beta - RAD_COLLECTOR_THRESHOLD
		var/gamma_delta = max_gamma - RAD_COLLECTOR_THRESHOLD
		. += span_notice("[src]'s display states that it has stored <b>[DisplayJoules(joules)]</b>, and is processing <b>[DisplayPower(RAD_COLLECTOR_OUTPUT)]</b>")
		. += span_notice("Strongest Beta absorption over the last [rad_time /(1 SECONDS)] seconds: <b>[max_beta]</b>, <b>[abs(beta_delta)]</b> [beta_delta >= 0 ? "above" : "below"] threshold")
		. += span_notice("Strongest Gamma absorption over the last [rad_time /(1 SECONDS)] seconds: <b>[max_gamma]</b>, <b>[abs(gamma_delta)]</b> [gamma_delta >= 0 ? "above" : "below"] threshold")
	else
		. += span_notice("<b>[src]'s display displays the words:</b> \"Power production mode. Please insert <b>Plasma</b>.\"")

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


/// Converts absorbed Beta or Gamma radiation into electrical energy
/obj/machinery/power/rad_collector/rad_act(atom/source, amount, emission_type)
	// Log the absorption at current time. If we already have one logged and the new value is bigger overwrite it.
	if(emission_type == BETA_RAD)
		if(!beta_waves["[world.time]"])
			beta_waves += list("[world.time]" = amount)
		else if(beta_waves["[world.time]"] < amount)
			beta_waves["[world.time]"] = amount
	if(emission_type == GAMMA_RAD)
		if(!gamma_waves["[world.time]"])
			gamma_waves += list("[world.time]" = amount)
		else if(gamma_waves["[world.time]"] < amount)
			gamma_waves["[world.time]"] = amount
	if(emission_type != ALPHA_RAD && loaded_tank && active && amount > power_threshold)
		stored_energy += (amount - power_threshold) * power_coefficient


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

#undef RAD_COLLECTOR_THRESHOLD
#undef RAD_COLLECTOR_COEFFICIENT
#undef RAD_COLLECTOR_STORED_OUT
#undef RAD_COLLECTOR_OUTPUT
