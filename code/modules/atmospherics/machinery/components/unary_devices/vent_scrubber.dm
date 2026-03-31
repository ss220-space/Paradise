#define SCRUBBER_IDLE_POWER_USAGE 10

/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/vent_scrubber.dmi'
	icon_state = "map_scrubber"

	name = "air scrubber"
	desc = "Has a valve and pump attached to it"
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_SCRUBBER_OFFSET
	layer_offset = GAS_SCRUBBER_OFFSET

	idle_power_usage = SCRUBBER_IDLE_POWER_USAGE
	active_power_usage = 60

	can_unwrench = TRUE

	vent_movement = VENTCRAWL_ALLOWED|VENTCRAWL_CAN_SEE|VENTCRAWL_ENTRANCE_ALLOWED

	var/area/current_area

	var/list/turf/simulated/adjacent_turfs = list()

	var/scrubbing = TRUE //FALSE = siphoning, TRUE = scrubbing
	var/scrub = SCRUB_CO2

	var/volume_rate = 200
	var/widenet = FALSE //is this scrubber acting on the 3x3 area around it.

	connect_types = list(1,3) //connects to regular and scrubber pipes

	var/static/alist/gas_power_costs = alist(
		SCRUB_O2 = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_N2 = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_CO2 = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_PL = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_N2O = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_H2 = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_H2O = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_TRITIUM = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_BZ = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_PLUOXIUM = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_MIASMA = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_FREON = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_NITRIUM = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_HEALIUM = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_PROTO_NITRATE = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_ZAUKER = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_HALON = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_HELIUM = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_ANTINOBLIUM = SCRUBBER_IDLE_POWER_USAGE,
		SCRUB_HYPERNOBLIUM = SCRUBBER_IDLE_POWER_USAGE
	)

/obj/machinery/atmospherics/unary/vent_scrubber/on
	on = TRUE
	scrub = parent_type::scrub|SCRUB_N2O|SCRUB_PL

/obj/machinery/atmospherics/unary/vent_scrubber/on_tox
	on = TRUE
	scrub = parent_type::scrub|SCRUB_N2O

/obj/machinery/atmospherics/unary/vent_scrubber/Initialize(mapload)
	. = ..()
	icon = null
	asign_new_area(get_area(src))

/obj/machinery/atmospherics/unary/vent_scrubber/atmos_init()
	..()
	check_turfs()

/obj/machinery/atmospherics/unary/vent_scrubber/proc/asign_new_area(area/area)
	var/area/cached_current_area = current_area
	if(cached_current_area)
		cached_current_area.air_scrubs -= src
		current_area = null

	if(!area)
		return

	area.air_scrubs |= src
	current_area = area
	update_appearance(UPDATE_NAME)

/obj/machinery/atmospherics/unary/vent_scrubber/Destroy()
	asign_new_area(null)
	return ..()

/obj/machinery/atmospherics/unary/vent_scrubber/examine(mob/user)
	. = ..()
	if(welded)
		. += span_notice("It seems welded shut.")

/obj/machinery/atmospherics/unary/vent_scrubber/auto_use_power()
	if(!powered(power_channel))
		return 0
	if(!on || welded)
		return 0
	if(stat & (NOPOWER|BROKEN))
		return 0

	var/amount = idle_power_usage

	if(scrubbing)
		for(var/scrub, usage in gas_power_costs)
			amount += usage
	else
		amount = active_power_usage

	if(widenet)
		amount += amount * (length(adjacent_turfs) * (length(adjacent_turfs) / 2))
	use_power(amount, power_channel)
	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/update_name(updates)
	. = ..()
	name = "[current_area.name] Air Scrubber #[current_area.air_scrubs.Find(src)]"

/obj/machinery/atmospherics/unary/vent_scrubber/update_overlays()
	. = ..()
	SET_PLANE_IMPLICIT(src, FLOOR_PLANE)
	if(!check_icon_cache())
		return

	var/scrubber_icon = "scrubber"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	if(!powered())
		scrubber_icon += "off"
	else
		scrubber_icon += "[on ? "[scrubbing ? "on" : "in"]" : "off"]"

	if(welded)
		scrubber_icon = "scrubberweld"

	. += SSair.icon_manager.get_atmos_icon("device", state = scrubber_icon)
	update_pipe_image()

/obj/machinery/atmospherics/unary/vent_scrubber/update_underlays()
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


/obj/machinery/atmospherics/unary/vent_scrubber/get_data()
	var/list/data = list(
		"name" = name,
		"machine_type" = "AScr",
		"uid" = UID(),
		"power" = on,
		"scrubbing" = scrubbing,
		"widenet" = widenet,
		"filter" = scrub,
	)

	return data

/obj/machinery/atmospherics/unary/vent_scrubber/update_params(list/params)
	if(stat & (NOPOWER|BROKEN))
		return

	if("power" in params)
		on = params["power"]

	if("power_toggle" in params)
		on = !on

	if("widenet" in params)
		widenet = params["widenet"]

	if("toggle_widenet" in params)
		widenet = !widenet

	if("scrubbing" in params)
		scrubbing = params["scrubbing"]

	if("toggle_scrubbing" in params)
		scrubbing = !scrubbing

	if("scrub" in params)
		var/scrub_flag = params["scrub"]
		if(scrub_flag & scrub)
			scrub &= ~scrub_flag
		else
			scrub |= scrub_flag

	update_appearance(UPDATE_ICON)

/obj/machinery/atmospherics/unary/vent_scrubber/process_atmos(seconds)
	if(widenet)
		check_turfs()

	if(stat & (NOPOWER|BROKEN))
		return

	if(!node)
		on = FALSE

	if(welded)
		return FALSE

	if(!on)
		return FALSE

	scrub(loc)
	if(widenet)
		for(var/turf/simulated/tile as anything in adjacent_turfs)
			scrub(tile)

//we populate a list of turfs with nonatmos-blocked cardinal turfs AND
//	diagonal turfs that can share atmos with *both* of the cardinal turfs
/obj/machinery/atmospherics/unary/vent_scrubber/proc/check_turfs()
	adjacent_turfs.Cut()
	var/turf/turf = loc
	if(istype(turf))
		adjacent_turfs = turf.GetAtmosAdjacentTurfs(TRUE)

/obj/machinery/atmospherics/unary/vent_scrubber/proc/scrub(turf/simulated/tile)
	if(!tile || !istype(tile))
		return FALSE

	if(scrubbing && !should_scrub(tile.get_readonly_air()))
		return FALSE

	var/datum/milla_safe/vent_scrubber_process/milla = new()
	milla.invoke_async(src, tile)

/obj/machinery/atmospherics/unary/vent_scrubber/proc/should_scrub(datum/gas_mixture/environment)
	if(!scrubbing)
		return FALSE

	var/list/mixture = environment.get_interesting()
	var/list/gas_meta = GLOB.gas_meta

	for(var/gas_key, value in mixture)
		var/list/gas_meta_list = gas_meta[gas_key]
		if(gas_meta_list[META_GAS_SCRUB_FLAG] & scrub)
			if(value > MINIMUM_MOLE_COUNT)
				return TRUE

	return FALSE

#define SCRUB_GAS_SIMPLE(bit, gas_name) \
	if(scrub & bit) { \
		filtered_out.set_##gas_name(removed.gas_name()); \
		removed.set_##gas_name(0); \
	}

/datum/milla_safe/vent_scrubber_process

/datum/milla_safe/vent_scrubber_process/on_run(obj/machinery/atmospherics/unary/vent_scrubber/scrubber, turf/simulated/tile)
	if(!tile || !istype(tile))
		return FALSE

	var/datum/gas_mixture/environment = get_turf_air(tile)

	if(scrubber.scrubbing)
		if(scrubber.should_scrub(environment))
			var/transfer_moles = min(1, scrubber.volume_rate / environment.volume) * environment.total_moles()

			//Take a gas sample
			var/datum/gas_mixture/removed = environment.remove(transfer_moles)
			if(isnull(removed)) //in space
				return

			var/scrub = scrubber.scrub

			//Filter it
			var/datum/gas_mixture/filtered_out = new
			filtered_out.set_temperature(removed.temperature())

			SCRUB_GAS_SIMPLE(SCRUB_O2, oxygen)
			SCRUB_GAS_SIMPLE(SCRUB_N2, nitrogen)
			SCRUB_GAS_SIMPLE(SCRUB_CO2, carbon_dioxide)
			SCRUB_GAS_SIMPLE(SCRUB_PL, toxins)
			SCRUB_GAS_SIMPLE(SCRUB_N2O, sleeping_agent)
			SCRUB_GAS_SIMPLE(SCRUB_H2, hydrogen)
			SCRUB_GAS_SIMPLE(SCRUB_H2O, water_vapor)

			SCRUB_GAS_SIMPLE(SCRUB_TRITIUM, tritium)
			SCRUB_GAS_SIMPLE(SCRUB_BZ, bz)
			SCRUB_GAS_SIMPLE(SCRUB_PLUOXIUM, pluoxium)
			SCRUB_GAS_SIMPLE(SCRUB_MIASMA, miasma)
			SCRUB_GAS_SIMPLE(SCRUB_FREON, freon)
			SCRUB_GAS_SIMPLE(SCRUB_NITRIUM, nitrium)
			SCRUB_GAS_SIMPLE(SCRUB_HEALIUM, healium)
			SCRUB_GAS_SIMPLE(SCRUB_PROTO_NITRATE, proto_nitrate)
			SCRUB_GAS_SIMPLE(SCRUB_ZAUKER, zauker)
			SCRUB_GAS_SIMPLE(SCRUB_HALON, halon)
			SCRUB_GAS_SIMPLE(SCRUB_HELIUM, helium)
			SCRUB_GAS_SIMPLE(SCRUB_ANTINOBLIUM, antinoblium)
			SCRUB_GAS_SIMPLE(SCRUB_HYPERNOBLIUM, hypernoblium)

			if(removed.agent_b() > 0)
				filtered_out.set_agent_b(removed.agent_b())
				removed.set_agent_b(0)

			//Remix the resulting gases
			scrubber.air_contents.merge(filtered_out)

			environment.merge(removed)

	else //Just siphoning all air
		if(scrubber.air_contents.return_pressure() >= (50 * ONE_ATMOSPHERE))
			return

		var/transfer_moles = environment.total_moles() * (scrubber.volume_rate / environment.volume)

		var/datum/gas_mixture/removed = environment.remove(transfer_moles)

		scrubber.air_contents.merge(removed)

	if(!QDELETED(scrubber.parent))
		scrubber.parent.update = TRUE

	return TRUE
//#undef SCRUB_GAS_SIMPLE

/obj/machinery/atmospherics/unary/vent_scrubber/hide(i) //to make the little pipe section invisible, the icon changes.
	update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/power_change(forced = FALSE)
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/attack_alien(mob/user)
	if(!welded || !do_after(user, 2 SECONDS, src))
		return
	user.visible_message(
		span_warning("[user] furiously claws at [src]!"),
		span_notice("You manage to clear away the stuff blocking the scrubber."),
		span_italics("You hear loud scraping noises."),
	)
	set_welded(FALSE)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 100, TRUE)

/obj/machinery/atmospherics/unary/vent_scrubber/welder_act(mob/user, obj/item/I)
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

#undef SCRUBBER_IDLE_POWER_USAGE
