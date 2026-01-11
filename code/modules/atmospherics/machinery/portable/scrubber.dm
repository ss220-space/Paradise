
#define MAX_RATE 10 * ONE_ATMOSPHERE
/// The pump will be siphoning gas.
#define DIRECTION_IN 0
/// The pump will be pumping gas out.
#define DIRECTION_OUT 1

/obj/machinery/atmospherics/portable/scrubber
	name = "portable air scrubber"
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos.dmi'
	icon_state = "pscrubber_off"
	density = TRUE
	volume = 750
	/// The volume of gas that can be scrubbed every time `process_atmos()` is called (0.5 seconds).
	var/volume_rate = 101.325
	/// Is this scrubber acting on the 3x3 area around it.
	var/widenet = FALSE

/obj/machinery/atmospherics/portable/scrubber/examine(mob/user)
	. = ..()
	. += span_notice("Filters the air, placing harmful gases into the internal gas container. The container can be emptied by \
		connecting it to a connector port, you're unable to have [src] both connected, and on at the same time. \
		Changing the target pressure will result in faster or slower filter speeds, higher pressure is faster. \
		A tank of gas can also be attached, allowing you to remove harmful gases from the attached tank.")

/obj/machinery/atmospherics/portable/scrubber/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(prob(50 / severity))
		on = !on
		update_icon()

	..(severity)

/obj/machinery/atmospherics/portable/scrubber/update_icon_state()
	icon_state = "pscrubber_[on ? "on" : "off"]"

/obj/machinery/atmospherics/portable/scrubber/update_overlays()
	. = ..()
	if(holding_tank)
		. += "scrubber_open"
	if(connected_port)
		. += "scrubber_connector"

/obj/machinery/atmospherics/portable/scrubber/process_atmos()
	..()
	if(!on)
		return

	if(holding_tank)
		scrub(holding_tank.air_contents)
		return

	var/datum/milla_safe/portable_scrubber_scrub/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/portable_scrubber_scrub

/datum/milla_safe/portable_scrubber_scrub/on_run(obj/machinery/atmospherics/portable/scrubber/scrubber)
	var/turf/turf = get_turf(scrubber)
	scrubber.scrub(get_turf_air(turf))
	if(scrubber.widenet)
		for(var/turf/simulated/tile as anything in turf.GetAtmosAdjacentTurfs(alldir = TRUE))
			scrubber.scrub(get_turf_air(tile))

/obj/machinery/atmospherics/portable/scrubber/proc/scrub(datum/gas_mixture/environment)
	var/transfer_moles = min(1, volume_rate / environment.volume) * environment.total_moles()

	//Take a gas sample
	var/datum/gas_mixture/removed
	removed = environment.remove(transfer_moles)

	//Filter it
	if(!removed)
		return

	var/datum/gas_mixture/filtered_out = new

	filtered_out.set_temperature(removed.temperature())


	filtered_out.set_toxins(removed.toxins())
	removed.set_toxins(0)

	filtered_out.set_carbon_dioxide(removed.carbon_dioxide())
	removed.set_carbon_dioxide(0)

	filtered_out.set_sleeping_agent(removed.sleeping_agent())
	removed.set_sleeping_agent(0)

	filtered_out.set_agent_b(removed.agent_b())
	removed.set_agent_b(0)

	filtered_out.set_hydrogen(removed.hydrogen())
	removed.set_hydrogen(0)

	filtered_out.set_water_vapor(removed.water_vapor())
	removed.set_water_vapor(0)

	//Remix the resulting gases
	air_contents.merge(filtered_out)

	environment.merge(removed)

/obj/machinery/atmospherics/portable/scrubber/return_obj_air()
	RETURN_TYPE(/datum/gas_mixture)
	return air_contents

/obj/machinery/atmospherics/portable/scrubber/return_analyzable_air()
	return air_contents

/obj/machinery/atmospherics/portable/scrubber/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/atmospherics/portable/scrubber/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/atmospherics/portable/scrubber/attack_hand(mob/user)
	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)
	return

/obj/machinery/atmospherics/portable/scrubber/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortableScrubber", "Portable Scrubber")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/atmospherics/portable/scrubber/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"port_connected" = connected_port ? TRUE : FALSE,
		"max_rate" = MAX_RATE,
		"rate" = round(volume_rate, 0.001),
		"tank_pressure" = air_contents.return_pressure() > 0 ? round(air_contents.return_pressure(), 0.001) : 0
	)
	if(holding_tank)
		data["has_holding_tank"] = TRUE
		data["holding_tank"] = list("name" = holding_tank.name, "tank_pressure" = holding_tank.air_contents.return_pressure() > 0 ? round(holding_tank.air_contents.return_pressure(), 0.001) : 0)
	else
		data["has_holding_tank"] = FALSE

	return data

/obj/machinery/atmospherics/portable/scrubber/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			on = !on
			update_icon()
			return TRUE

		if("remove_tank")
			if(holding_tank)
				replace_tank(usr, FALSE)
			update_icon()
			return TRUE

		if("set_rate")
			volume_rate = clamp(text2num(params["rate"]), 0, MAX_RATE)
			return TRUE

	add_fingerprint(usr)

/obj/machinery/atmospherics/portable/scrubber/huge
	name = "huge air scrubber"
	icon_state = "scrubber:0"
	anchored = TRUE
	volume = 50000
	volume_rate = 5000
	widenet = TRUE

	var/global/gid = 1
	var/id = 0
	var/stationary = FALSE

/obj/machinery/atmospherics/portable/scrubber/huge/Initialize(mapload)
	. = ..()

	id = gid
	gid++
	name = "[name] (ID [id])"

/obj/machinery/atmospherics/portable/scrubber/huge/attack_hand(mob/user)
	to_chat(usr, span_warning("You can't directly interact with this machine. Use the area atmos computer."))

/obj/machinery/atmospherics/portable/scrubber/huge/update_icon_state()
	icon_state = "scrubber:[on]"

/obj/machinery/atmospherics/portable/scrubber/huge/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(stationary)
		to_chat(user, span_warning("The bolts are too tight for you to unscrew!"))
		return
	if(on)
		to_chat(user, span_warning("Turn it off first!"))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	set_anchored(!anchored)
	to_chat(user, span_notice("You [anchored ? "wrench" : "unwrench"] [src]."))

/obj/machinery/atmospherics/portable/scrubber/huge/stationary
	name = "stationary air scrubber"
	stationary = TRUE

#undef MAX_RATE
#undef DIRECTION_IN
#undef DIRECTION_OUT
