/obj/machinery/atmospherics/pipe/heat_exchanging
	icon = 'icons/obj/atmospherics/pipes/heat.dmi'
	icon_state = "intact"
	//pipe_icon = "hepipe"
	level = 2
	plane = GAME_PLANE
	layer = GAS_PIPE_VISIBLE_LAYER
	var/initialize_directions_he
	var/minimum_temperature_difference = 20
	var/thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	color = "#404040"
	buckle_lying = 1
	var/icon_temperature = T20C //stop small changes in temperature causing icon refresh
	resistance_flags = LAVA_PROOF | FIRE_PROOF


/obj/machinery/atmospherics/pipe/heat_exchanging/can_be_node(obj/machinery/atmospherics/pipe/heat_exchanging/target)
	if(!istype(target))
		return FALSE
	if(target.initialize_directions_he & get_dir(target,src))
		return TRUE


/obj/machinery/atmospherics/pipe/heat_exchanging/hide()
	return

/obj/machinery/atmospherics/pipe/heat_exchanging/GetInitDirections()
	return ..() | initialize_directions_he

/obj/machinery/atmospherics/pipe/heat_exchanging/process_atmos()
	if(!parent)
		return

	var/environment_temperature = 0
	var/datum/gas_mixture/pipe_air = return_air()

	var/turf/simulated/T = loc
	if(istype(T))
		if(T.blocks_air)
			environment_temperature = T.temperature
		else
			var/datum/gas_mixture/environment = T.return_air()
			environment_temperature = environment.temperature
	else
		environment_temperature = T.temperature

	if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
		parent.temperature_interact(T, volume, thermal_conductivity)

	//Heat causes pipe to glow
	if(pipe_air.temperature && (icon_temperature > 500 || pipe_air.temperature > 500)) //glow starts at 500K
		if(abs(pipe_air.temperature - icon_temperature) > 10)
			icon_temperature = pipe_air.temperature

			var/h_r = heat2color_r(icon_temperature)
			var/h_g = heat2color_g(icon_temperature)
			var/h_b = heat2color_b(icon_temperature)

			if(icon_temperature < 2000)//scale glow until 2000K
				var/scale = (icon_temperature - 500) / 1500
				h_r = 64 + (h_r - 64) * scale
				h_g = 64 + (h_g - 64) * scale
				h_b = 64 + (h_b - 64) * scale

			animate(src, color = rgb(h_r, h_g, h_b), time = 20, easing = SINE_EASING)

	//burn any mobs buckled based on temperature
	if(has_buckled_mobs())
		var/heat_limit = 1000
		if(pipe_air.temperature > heat_limit + 1)
			for(var/m in buckled_mobs)
				var/mob/living/buckled_mob = m
				buckled_mob.apply_damage(4 * log(pipe_air.temperature - heat_limit), BURN, BODY_ZONE_CHEST)



/obj/machinery/atmospherics/pipe/heat_exchanging/hidden
	level = 1
	icon_state="intact-f"
	plane = GAME_PLANE
	layer = GAS_PIPE_HIDDEN_LAYER
