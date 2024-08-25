/obj/machinery/atmospherics/meter
	name = "gas flow meter"
	desc = "It measures something."
	icon = 'icons/obj/pipes_and_stuff/atmospherics/meter.dmi'
	icon_state = "meterX"
	can_unwrench = TRUE
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_PUMP_OFFSET
	layer_offset = GAS_PUMP_OFFSET

	var/obj/machinery/atmospherics/pipe/target = null
	anchored = TRUE
	max_integrity = 150
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 40, "acid" = 0)
	power_channel = ENVIRON
	frequency = ATMOS_DISTRO_FREQ
	var/id
	var/id_tag
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 5

/obj/machinery/atmospherics/meter/Initialize(mapload)
	. = ..(mapload)
	SSair.atmos_machinery += src
	target = locate(/obj/machinery/atmospherics/pipe) in loc
	if(id && !id_tag)//i'm not dealing with further merge conflicts, fuck it
		id_tag = id

/obj/machinery/atmospherics/meter/Destroy()
	SSair.atmos_machinery -= src
	target = null
	return ..()


/obj/machinery/atmospherics/meter/update_icon_state()
	if(!target)
		icon_state = "meterX"
		return

	if(stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return

	var/datum/gas_mixture/environment = target.return_air()
	if(!environment)
		icon_state = "meterX"
		return

	var/env_pressure = environment.return_pressure()
	if(env_pressure <= 0.15*ONE_ATMOSPHERE)
		icon_state = "meter0"
	else if(env_pressure <= 1.8*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*0.3) + 0.5)
		icon_state = "meter1_[val]"
	else if(env_pressure <= 30*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5)-0.35) + 1
		icon_state = "meter2_[val]"
	else if(env_pressure <= 59*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5) - 6) + 1
		icon_state = "meter3_[val]"
	else
		icon_state = "meter4"


/obj/machinery/atmospherics/meter/process_atmos()
	if(!target || (stat & (BROKEN|NOPOWER)))
		update_icon(UPDATE_ICON_STATE)
		return

	var/datum/gas_mixture/environment = target.return_air()
	if(!environment)
		update_icon(UPDATE_ICON_STATE)
		return

	update_icon(UPDATE_ICON_STATE)

	if(!frequency)
		return

	var/datum/radio_frequency/radio_connection = SSradio.return_frequency(frequency)
	if(!radio_connection)
		return

	var/datum/signal/signal = new
	signal.source = src
	signal.transmission_method = 1
	signal.data = list(
		"tag" = id_tag,
		"device" = "AM",
		"pressure" = round(environment.return_pressure()),
		"sigtype" = "status",
	)
	radio_connection.post_signal(src, signal)


/obj/machinery/atmospherics/meter/proc/status()
	var/t = ""
	if(target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			t += "The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature,0.01)]&deg;K ([round(environment.temperature-T0C,0.01)]&deg;C)"
		else
			t += "The sensor error light is blinking."
	else
		t += "The connect error light is blinking."
	return t

/obj/machinery/atmospherics/meter/examine(mob/user)
	. = ..()
	if(get_dist(user, src) > 3 && !(istype(user, /mob/living/silicon/ai) || istype(user, /mob/dead)))
		. += span_boldnotice("You are too far away to read it.")

	else if(stat & (NOPOWER|BROKEN))
		. += span_danger("The display is off.")

	else if(target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			. += span_notice("The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature,0.01)]K ([round(environment.temperature-T0C,0.01)]&deg;C).")
		else
			. += span_warning("The sensor error light is blinking.")
	else
		. += span_warning("The connect error light is blinking.")

/obj/machinery/atmospherics/meter/Click()
	if(istype(usr, /mob/living/silicon/ai)) // ghosts can call ..() for examine
		usr.examinate(src)
		return 1

	return ..()


/obj/machinery/atmospherics/meter/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/pipe_meter(loc)
	qdel(src)


/obj/machinery/atmospherics/meter/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

