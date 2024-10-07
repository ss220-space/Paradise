/obj/machinery/portable_atmospherics
	name = "atmoalter"
	use_power = NO_POWER_USE
	max_integrity = 250
	pull_push_slowdown = 1.3
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 60, "acid" = 30)
	var/datum/gas_mixture/air_contents = new

	var/obj/machinery/atmospherics/unary/portables_connector/connected_port
	var/obj/item/tank/holding
	var/volume = 0
	var/maximum_pressure = 90*ONE_ATMOSPHERE


/obj/machinery/portable_atmospherics/Initialize(mapload)
	. = ..()
	SSair.atmos_machinery += src

	air_contents.volume = volume
	air_contents.temperature = T20C

	if(mapload)
		return INITIALIZE_HINT_LATELOAD

	check_for_port()


// Late init this otherwise it shares with the port and it tries to div temperature by 0
/obj/machinery/portable_atmospherics/LateInitialize()
	check_for_port()


/obj/machinery/portable_atmospherics/proc/check_for_port()
	var/obj/machinery/atmospherics/unary/portables_connector/port = locate() in loc
	if(port)
		connect(port)


/obj/machinery/portable_atmospherics/process_atmos()
	if(!connected_port) //only react when pipe_network will ont it do it for you
		//Allow for reactions
		air_contents.react()
		return
	update_icon()

/obj/machinery/portable_atmospherics/Destroy()
	SSair.atmos_machinery -= src
	disconnect()
	QDEL_NULL(air_contents)
	QDEL_NULL(holding)
	return ..()

/obj/machinery/portable_atmospherics/update_icon_state()
	return

/obj/machinery/portable_atmospherics/update_overlays()
	. = list()

/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return FALSE

	//Make sure are close enough for a valid connection
	if(new_port.loc != loc)
		return FALSE

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	// To avoid a chicken-egg thing where pipes need to
	// be initialized before the atmos cans are
	if(!connected_port.parent)
		connected_port.build_network()
	connected_port.parent.reconcile_air()

	set_anchored(TRUE) //Prevent movement

	return TRUE

/obj/machinery/portable_atmospherics/proc/disconnect()
	if(!connected_port)
		return FALSE

	set_anchored(FALSE)

	connected_port.connected_device = null
	connected_port = null

	return TRUE

/obj/machinery/portable_atmospherics/portableConnectorReturnAir()
	return air_contents

/obj/machinery/portable_atmospherics/AltClick(mob/living/user)
	if(!ishuman(user) && !issilicon(user))
		return
	if(!Adjacent(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("You can't do that right now!"))
		return
	if(holding)
		to_chat(user, span_notice("You remove [holding] from [src]."))
		replace_tank(user, TRUE)

/obj/machinery/portable_atmospherics/examine(mob/user)
	. = ..()
	if(holding)
		. += span_notice("\The [src] contains [holding]. Alt-click [src] to remove it.")

/obj/machinery/portable_atmospherics/return_analyzable_air()
	return air_contents

/obj/machinery/portable_atmospherics/proc/replace_tank(mob/living/user, close_valve, obj/item/tank/new_tank)
	if(holding)
		holding.forceMove(drop_location())
		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(holding, ignore_anim = FALSE)
	if(new_tank)
		holding = new_tank
	else
		holding = null
	update_icon()
	return TRUE


/obj/machinery/portable_atmospherics/attackby(obj/item/I, mob/user, params)
	if((stat & BROKEN) || user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/tank))
		add_fingerprint(user)
		var/obj/item/tank/new_tank = I
		if(!new_tank.fillable)
			to_chat(user, span_warning("The [new_tank.name] is incompatible with [src]."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(new_tank, src))
			return ..()
		if(holding)
			to_chat(user, span_notice("In one smooth motion you pop [holding] out of [src]'s connector and replace it with [new_tank]"))
		else
			to_chat(user, span_notice("You insert [new_tank] into [src]"))
		replace_tank(user, FALSE, new_tank)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/portable_atmospherics/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(connected_port)
		disconnect()
		to_chat(user, span_notice("You disconnect [name] from the port."))
		update_icon()
	else
		var/obj/machinery/atmospherics/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/unary/portables_connector/) in loc
		if(possible_port)
			if(connect(possible_port))
				to_chat(user, span_notice("You connect [src] to the port."))
				update_icon()
				return
			else
				to_chat(user, span_notice("[src] failed to connect to the port."))
				return
		else
			to_chat(user, span_notice("Nothing happens."))


/obj/machinery/portable_atmospherics/proceed_attack_results(obj/item/I, mob/living/user, params, def_zone)
	if(I.force < 10 && !(stat & BROKEN))
		user.visible_message(
			span_warning("[user] gently pokes [src] with [I]."),
			span_warning("You gently poke [src] with [I]."),
		)
		return ATTACK_CHAIN_BLOCKED
	return ..()

