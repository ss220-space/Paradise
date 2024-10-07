#define EXTERNAL_PRESSURE_BOUND ONE_ATMOSPHERE
#define INTERNAL_PRESSURE_BOUND 0
#define PRESSURE_CHECKS 1

/obj/machinery/atmospherics/unary/vent_pump
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/vent_pump.dmi'
	icon_state = "map_vent"

	name = "air vent"
	desc = "Has a valve and pump attached to it"
	use_power = IDLE_POWER_USE

	layer = GAS_PIPE_VISIBLE_LAYER + GAS_SCRUBBER_OFFSET
	layer_offset = GAS_SCRUBBER_OFFSET

	vent_movement = VENTCRAWL_ALLOWED|VENTCRAWL_CAN_SEE|VENTCRAWL_ENTRANCE_ALLOWED

	can_unwrench = TRUE
	var/open = FALSE

	var/area/initial_loc
	var/area_uid

	on = FALSE
	var/releasing = TRUE // FALSE = siphoning, TRUE = releasing

	var/external_pressure_bound = EXTERNAL_PRESSURE_BOUND
	var/internal_pressure_bound = INTERNAL_PRESSURE_BOUND

	var/pressure_checks = PRESSURE_CHECKS
	//1: Do not pass external_pressure_bound
	//2: Do not pass internal_pressure_bound
	//3: Do not pass either

	// Used when handling incoming radio signals requesting default settings
	var/external_pressure_bound_default = EXTERNAL_PRESSURE_BOUND
	var/internal_pressure_bound_default = INTERNAL_PRESSURE_BOUND
	var/pressure_checks_default = PRESSURE_CHECKS

	var/weld_burst_pressure = 50 * ONE_ATMOSPHERE	//the (internal) pressure at which welded covers will burst off

	frequency = ATMOS_VENTSCRUB

	var/radio_filter_out
	var/radio_filter_in

	connect_types = list(CONNECT_TYPE_NORMAL, CONNECT_TYPE_SUPPLY) //connects to regular and supply pipes

	multitool_menu_type = /datum/multitool_menu/idtag/freq/vent_pump

/obj/machinery/atmospherics/unary/vent_pump/on
	on = TRUE
	icon_state = "map_vent_out"

/obj/machinery/atmospherics/unary/vent_pump/siphon
	releasing = FALSE

/obj/machinery/atmospherics/unary/vent_pump/siphon/on
	on = TRUE
	icon_state = "map_vent_in"

/obj/machinery/atmospherics/unary/vent_pump/New()
	..()
	GLOB.all_vent_pumps += src
	icon = null
	initial_loc = get_area(loc)
	area_uid = initial_loc.uid
	if(!id_tag)
		assign_uid()
		id_tag = num2text(uid)

/obj/machinery/atmospherics/unary/vent_pump/high_volume
	name = "large air vent"
	power_channel = EQUIP

/obj/machinery/atmospherics/unary/vent_pump/high_volume/New()
	..()
	air_contents.volume = 1000


/obj/machinery/atmospherics/unary/vent_pump/update_overlays()
	. = ..()
	SET_PLANE_IMPLICIT(src, FLOOR_PLANE)
	if(!check_icon_cache())
		return

	var/vent_icon = "vent"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	if(T.intact && node && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe))
		vent_icon += "h"

	if(welded)
		vent_icon += "weld"
	else if(!powered())
		vent_icon += "off"
	else
		vent_icon += "[on ? "[releasing ? "out" : "in"]" : "off"]"

	. += SSair.icon_manager.get_atmos_icon("device", state = vent_icon)

	update_pipe_image()


/obj/machinery/atmospherics/unary/vent_pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		if(T.intact && node && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe))
			return
		else
			if(node)
				add_underlay(T, node, dir, node.icon_connect_type)
			else
				add_underlay(T, direction = dir)


/obj/machinery/atmospherics/unary/vent_pump/hide()
	update_icon()
	update_underlays()

/obj/machinery/atmospherics/unary/vent_pump/process_atmos()
	..()
	if(stat & (NOPOWER|BROKEN))
		return FALSE
	if(!node)
		on = FALSE
		// The state has changed, do some updates
		broadcast_status()
		update_icon()
	//broadcast_status() // from now air alarm/control computer should request update purposely --rastaf0
	if(!on)
		return FALSE

	if(welded)
		if(air_contents.return_pressure() >= weld_burst_pressure && prob(5))	//the weld is on but the cover is welded shut, can it withstand the internal pressure?
			visible_message(span_danger("The welded cover of [src] bursts open!"))
			for(var/mob/living/M in range(1))
				unsafe_pressure_release(M, air_contents.return_pressure())	//let's send everyone flying
			set_welded(FALSE)
		return FALSE

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()
	if(releasing) //internal -> external
		var/pressure_delta = 10000
		if(pressure_checks & 1)
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))
		if(pressure_checks & 2)
			pressure_delta = min(pressure_delta, (air_contents.return_pressure() - internal_pressure_bound))

		if(pressure_delta > 0.5 && air_contents.temperature > 0)
			var/transfer_moles = pressure_delta * environment.volume / (air_contents.temperature * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
			loc.assume_air(removed)
			air_update_turf()
			parent?.update = TRUE

	else //external -> internal
		var/pressure_delta = 10000
		if(pressure_checks & 1)
			pressure_delta = min(pressure_delta, (environment_pressure - external_pressure_bound))
		if(pressure_checks & 2)
			pressure_delta = min(pressure_delta, (internal_pressure_bound - air_contents.return_pressure()))

		if(pressure_delta > 0.5 && environment.temperature > 0)
			var/transfer_moles = pressure_delta * air_contents.volume / (environment.temperature * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
			if(isnull(removed)) //in space
				return
			air_contents.merge(removed)
			air_update_turf()
			parent.update = TRUE

	return TRUE

//Radio remote control

/obj/machinery/atmospherics/unary/vent_pump/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency

	if(frequency)

		//some vents work his own special way
		radio_filter_in = frequency == ATMOS_VENTSCRUB ? RADIO_FROM_AIRALARM : RADIO_ATMOSIA
		radio_filter_out = frequency == ATMOS_VENTSCRUB ? RADIO_TO_AIRALARM : RADIO_ATMOSIA

		radio_connection = SSradio.add_object(src, frequency, radio_filter_in)

	if(frequency != ATMOS_VENTSCRUB)
		initial_loc.air_vent_info -= id_tag
		initial_loc.air_vent_names -= id_tag
		name = "vent pump"
	else
		broadcast_status()

/obj/machinery/atmospherics/unary/vent_pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"area" = src.area_uid,
		"tag" = src.id_tag,
		"device" = "AVP",
		"power" = on,
		"direction" = releasing?("release"):("siphon"),
		"checks" = pressure_checks,
		"internal" = internal_pressure_bound,
		"external" = external_pressure_bound,
		"timestamp" = world.time,
		"sigtype" = "status"
	)
	if(frequency == ATMOS_VENTSCRUB)
		if(!initial_loc.air_vent_names[id_tag])
			var/new_name = "[initial_loc.name] Vent Pump #[initial_loc.air_vent_names.len+1]"
			initial_loc.air_vent_names[id_tag] = new_name
			src.name = new_name
		initial_loc.air_vent_info[id_tag] = signal.data

	radio_connection.post_signal(src, signal, radio_filter_out)

	return 1


/obj/machinery/atmospherics/unary/vent_pump/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)
		broadcast_status()

/obj/machinery/atmospherics/unary/vent_pump/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	//log_admin("DEBUG \[[world.timeofday]\]: /obj/machinery/atmospherics/unary/vent_pump/receive_signal([signal.debug_print()])")
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return 0

	if(signal.data["purge"] != null)
		pressure_checks &= ~1
		releasing = FALSE

	if(signal.data["stabilize"] != null)
		pressure_checks |= 1
		releasing = TRUE

	if(signal.data["power"] != null)
		on = text2num(signal.data["power"])

	if(signal.data["power_toggle"] != null)
		on = !on

	if(signal.data["checks"] != null)
		if(signal.data["checks"] == "default")
			pressure_checks = pressure_checks_default
		else
			pressure_checks = text2num(signal.data["checks"])

	if(signal.data["checks_toggle"] != null)
		pressure_checks = (pressure_checks?0:3)

	if(signal.data["direction"] != null)
		releasing = text2num(signal.data["direction"])

	if(signal.data["set_internal_pressure"] != null)
		if(signal.data["set_internal_pressure"] == "default")
			internal_pressure_bound = internal_pressure_bound_default
		else
			internal_pressure_bound = between(
				0,
				text2num(signal.data["set_internal_pressure"]),
				ONE_ATMOSPHERE*50
			)

	if(signal.data["set_external_pressure"] != null)
		if(signal.data["set_external_pressure"] == "default")
			external_pressure_bound = external_pressure_bound_default
		else
			external_pressure_bound = between(
				0,
				text2num(signal.data["set_external_pressure"]),
				ONE_ATMOSPHERE*50
			)

	if(signal.data["adjust_internal_pressure"] != null)
		internal_pressure_bound = between(
			0,
			internal_pressure_bound + text2num(signal.data["adjust_internal_pressure"]),
			ONE_ATMOSPHERE*50
		)

	if(signal.data["adjust_external_pressure"] != null)


		external_pressure_bound = between(
			0,
			external_pressure_bound + text2num(signal.data["adjust_external_pressure"]),
			ONE_ATMOSPHERE*50
		)

	if(signal.data["init"] != null)
		name = signal.data["init"]
		return

	if(signal.data["status"] != null)
		spawn(2)
			broadcast_status()
		return //do not update_icon

		//log_admin("DEBUG \[[world.timeofday]\]: vent_pump/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
	spawn(2)
		broadcast_status()
	update_icon()
	return


/obj/machinery/atmospherics/unary/vent_pump/attack_alien(mob/user)
	if(!welded || !do_after(user, 2 SECONDS, src))
		return
	user.visible_message(
		span_warning("[user] furiously claws at [src]!"),
		span_notice("You manage to clear away the stuff blocking the vent."),
		span_italics("You hear loud scraping noises."),
	)
	set_welded(FALSE)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 100, TRUE)


/obj/machinery/atmospherics/unary/vent_pump/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/paper) || istype(I, /obj/item/stack/spacecash))
		add_fingerprint(user)
		if(welded)
			to_chat(user, span_warning("The vent is welded."))
			return .
		if(!open)
			to_chat(user, span_warning("You can't shove that down there when it is closed"))
			return .
		if(!user.drop_transfer_item_to_loc(I, src))
			return .
		return ATTACK_CHAIN_BLOCKED_ALL


/obj/machinery/atmospherics/unary/vent_pump/multitool_act(mob/user, obj/item/I)
	. = TRUE
	multitool_menu_interact(user, I)


/obj/machinery/atmospherics/unary/vent_pump/screwdriver_act(mob/user, obj/item/I)
	if(welded)
		return FALSE
	. = TRUE
	to_chat(user, span_notice("Now [open ? "closing" : "opening"] the vent."))
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return .
	open = !open
	user.visible_message(
		"[user] screwdrivers the vent [open ? "open" : "shut"].",
		"You screwdriver the vent [open ? "open" : "shut"].",
		"You hear a screwdriver.",
	)


/obj/machinery/atmospherics/unary/vent_pump/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return .
	WELDER_ATTEMPT_WELD_MESSAGE
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return .
	set_welded(!welded)
	if(welded)
		user.visible_message(
			span_notice("[user] welds [src] shut!"),
			span_notice("You weld [src] shut!"),
		)
	else
		user.visible_message(
			span_notice("[user] unwelds [src]!"),
			span_notice("You unweld [src]!"),
		)


/obj/machinery/atmospherics/unary/vent_pump/attack_hand(mob/user)
	if(welded || !open)
		return ..()

	add_fingerprint(user)
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return

	for(var/obj/item/thing as anything in src)
		if(istype(thing, /obj/item/paper) || istype(thing, /obj/item/stack/spacecash))
			thing.forceMove(our_turf)
			user.put_in_hands(thing, ignore_anim = FALSE)


/obj/machinery/atmospherics/unary/vent_pump/examine(mob/user)
	. = ..()
	if(welded)
		. += span_notice("It seems welded shut.")

/obj/machinery/atmospherics/unary/vent_pump/power_change(forced = FALSE)
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/unary/vent_pump/proc/set_tag(new_tag)
	if(frequency == ATMOS_VENTSCRUB)
		initial_loc.air_vent_info -= id_tag
		initial_loc.air_vent_names -= id_tag
	id_tag = new_tag
	broadcast_status()

/obj/machinery/atmospherics/unary/vent_pump/Destroy()
	GLOB.all_vent_pumps -= src
	if(initial_loc)
		initial_loc.air_vent_info -= id_tag
		initial_loc.air_vent_names -= id_tag
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()
