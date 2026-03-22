/obj/machinery/atmospherics/unary/thermomachine
	name = "temperature control unit"
	desc = "Heats or cools gas in connected pipes."
	icon = 'icons/map_icons/objects.dmi'
	icon_state = "/obj/machinery/atmospherics/components/unary/thermomachine"
	post_init_icon_state = "thermo_base"
	density = TRUE
	max_integrity = 300
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, FIRE = 80, ACID = 30)
	layer = OBJ_LAYER
	greyscale_config = /datum/greyscale_config/thermomachine
	flags = NO_NEW_GAGS_PREVIEW
	greyscale_colors = COLOR_VIBRANT_LIME
	/// actual temperature will be defined by RefreshParts() and by the cooling var
	var/min_temperature = T20C
	/// actual temperature will be defined by RefreshParts() and by the cooling var
	var/max_temperature = T20C
	var/target_temperature = T20C
	var/heat_capacity = 0
	var/cooling = TRUE
	var/base_heating = 140
	var/base_cooling = 170

/obj/machinery/atmospherics/unary/thermomachine/Initialize(mapload)
	. = ..()
	initialize_directions = dir
	init_parts()
	update_icon()

/obj/machinery/atmospherics/unary/thermomachine/proc/init_parts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/thermomachine(null)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stack/sheet/glass(src)
	component_parts += new /obj/item/stack/cable_coil(src, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/thermomachine/on_construction()
	..(dir, dir)

/obj/machinery/atmospherics/unary/thermomachine/examine(mob/user)
	. = ..()
	. += span_notice("Cools or heats the gas of the connected pipenet, uses a large amount of electricity while activated.")
	. += span_notice("The thermostat is set to [target_temperature]K ([(T0C - target_temperature) * -1]C).")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Efficiency <b>[(heat_capacity / 5000) * 100]%</b>.")
		. += span_notice("Temperature range <b>[min_temperature]K - [max_temperature]K ([(T0C - min_temperature) * -1]C - [(T0C-max_temperature) * -1]C)</b>.")


/obj/machinery/atmospherics/unary/thermomachine/proc/swap_function()
	cooling = !cooling
	target_temperature = T20C
	RefreshParts()
	update_icon()

/obj/machinery/atmospherics/unary/thermomachine/build_network(remove_deferral)
	var/datum/pipeline/pipenet = node?.returnPipenet()
	if(pipenet)
		setPipenet(pipenet)
		pipenet.addMachineryMember(src)
	. = ..()

/obj/machinery/atmospherics/unary/thermomachine/RefreshParts()
	var/calculated_bin_rating
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		calculated_bin_rating += bin.rating
	var/bin_rating_fixed = (calculated_bin_rating - 1)
	heat_capacity = 5000 * POW2(bin_rating_fixed)
	min_temperature = T20C
	max_temperature = T20C
	if(cooling)
		var/calculated_laser_rating
		for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
			calculated_laser_rating += laser.rating
		min_temperature = max(T0C - (base_cooling + calculated_laser_rating * 15), TCMB) //73.15K with T1 stock parts
	else
		var/calculated_laser_rating
		for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
			calculated_laser_rating += laser.rating
		max_temperature = T20C + (base_heating * calculated_laser_rating) //573.15K with T1 stock parts

/obj/machinery/atmospherics/unary/thermomachine/update_icon_state()
	var/new_color
	switch(target_temperature)
		if(HEAT_WARNING_3 to INFINITY)
			new_color = COLOR_RED
		if(HEAT_WARNING_2 to HEAT_WARNING_3)
			new_color = COLOR_ORANGE
		if(HEAT_WARNING_1 to HEAT_WARNING_2)
			new_color = COLOR_YELLOW
		if(COLD_WARNING_1 to HEAT_WARNING_1)
			new_color = COLOR_VIBRANT_LIME
		if(COLD_WARNING_2 to COLD_WARNING_1)
			new_color = COLOR_CYAN
		if(COLD_WARNING_3 to COLD_WARNING_2)
			new_color = COLOR_BLUE
		else
			new_color = COLOR_VIOLET

	set_greyscale_colors(colors = new_color)

	if(panel_open)
		icon_state = "thermo-open"
		return ..()

	if(on && powered() && !(stat & BROKEN))
		icon_state = "thermo_1"
		return ..()
	icon_state = "thermo_base"
	return ..()
// TODO replace with pipes overlays for atmos machines
/obj/machinery/atmospherics/unary/thermomachine/update_underlays()
	if(!..())
		return

	underlays.Cut()
	var/turf/tile = get_turf(src)
	if(!istype(tile))
		return
	add_underlay(tile, node, dir)


/obj/machinery/atmospherics/unary/thermomachine/update_pipe_image()
	pipe_vision_img = image('icons/obj/pipes_and_stuff/atmospherics/thermomachine.dmi', "pipe",  loc = src.loc, layer = ABOVE_HUD_LAYER + src.layer, dir = src.dir)
	var/turf/tile = get_turf(src)
	SET_PLANE_EXPLICIT(pipe_vision_img, PIPECRAWL_IMAGES_PLANE, tile)

/obj/machinery/atmospherics/unary/thermomachine/process_atmos(seconds)
	if(!on)
		return

	// Coolers don't heat.
	if(air_contents.temperature() <= target_temperature && cooling)
		return
	// Heaters don't cool.
	if(air_contents.temperature() >= target_temperature && !cooling)
		return

	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = heat_capacity + air_heat_capacity
	var/old_temperature = air_contents.temperature()

	if(combined_heat_capacity > 0)
		var/combined_energy = heat_capacity * target_temperature + air_heat_capacity * air_contents.temperature()
		air_contents.set_temperature(combined_energy / combined_heat_capacity)

	//todo: have current temperature affected. require power to bring down current temperature again

	var/temperature_delta = abs(old_temperature - air_contents.temperature())
	if(temperature_delta > 1)
		var/new_active_consumption = (temperature_delta * 25) * min(log(10, air_contents.temperature()) - 1, 1)
		active_power_usage = new_active_consumption + idle_power_usage
		parent.update = TRUE
	else
		active_power_usage = idle_power_usage

/obj/machinery/atmospherics/unary/thermomachine/crowbar_act(mob/user, obj/item/item)
	if(default_deconstruction_crowbar(user, item))
		return TRUE

/obj/machinery/atmospherics/unary/thermomachine/screwdriver_act(mob/user, obj/item/item)
	if(default_deconstruction_screwdriver(user, "thermo-open", "thermo-0", item))
		on = FALSE
		update_icon()
		return TRUE

/obj/machinery/atmospherics/unary/thermomachine/wrench_act(mob/user, obj/item/item)
	. = TRUE
	if(!panel_open)
		to_chat(user, span_notice("Open the maintenance panel first."))
		return
	if(!item.use_tool(src, user, 0, volume = item.tool_volume))
		return
	var/list/choices = list("West" = WEST, "East" = EAST, "South" = SOUTH, "North" = NORTH)
	var/selected = tgui_input_list(user, "Select a direction for the connector.", "Connector Direction", choices)
	if(!selected)
		return
	dir = choices[selected]
	var/node_connect = dir
	initialize_directions = dir
	for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break
	initialize_atmos_network()
	update_icon()

/obj/machinery/atmospherics/unary/thermomachine/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/atmospherics/unary/thermomachine/attack_ghost(mob/user)
	attack_hand(user)

/obj/machinery/atmospherics/unary/thermomachine/attack_hand(mob/user)
	if(panel_open)
		to_chat(user, span_notice("Close the maintenance panel first."))
		return
	ui_interact(user)

/obj/machinery/atmospherics/unary/thermomachine/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/atmospherics/unary/thermomachine/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GasFreezer", name)
		ui.open()

/obj/machinery/atmospherics/unary/thermomachine/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["cooling"] = cooling

	data["min"] = min_temperature
	data["max"] = max_temperature
	data["target"] = target_temperature
	data["targetCelsius"] = round(target_temperature - T0C, 1)
	data["initial"] = initial(target_temperature)
	data["temperatureCelsius"] = round(air_contents.temperature() - T0C, 1)
	data["temperature"] = air_contents.temperature()
	data["pressure"] = air_contents.return_pressure()
	return data

/obj/machinery/atmospherics/unary/thermomachine/ui_act(action, params)
	if(..())
		return
	add_fingerprint(usr)
	switch(action)
		if("power")
			on = !on
			use_power = on ? ACTIVE_POWER_USE : IDLE_POWER_USE
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			update_icon()
			. = TRUE

		if("cooling")
			swap_function()
			investigate_log("was changed to [cooling ? "cooling" : "heating"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE

		if("minimum")
			target_temperature = T20C
			update_icon()

		if("maximum")
			target_temperature = max_temperature
			update_icon()

		if("temp")
			var/amount = params["temp"]
			amount = text2num(amount)
			target_temperature = clamp(amount, min_temperature, max_temperature)
			update_icon()

		if("target")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = tgui_input_number(usr, "Set new target ([min_temperature] - [max_temperature] K):", name, target_temperature, min_temperature, max_temperature)

				if(!isnull(target))
					. = TRUE

			else if(adjust)
				target = target_temperature + adjust
				. = TRUE

			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE

			if(.)
				target_temperature = clamp(target, min_temperature, max_temperature)
				investigate_log("was set to [target_temperature] K by [key_name(usr)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/unary/thermomachine/freezer
	icon_state = "/obj/machinery/atmospherics/unary/thermomachine/freezer"
	post_init_icon_state = "thermo_1"
	flags = /obj/machinery/atmospherics/unary::flags

/obj/machinery/atmospherics/unary/thermomachine/freezer/upgraded
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/machinery/atmospherics/unary/thermomachine/freezer/upgraded/init_parts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/thermomachine(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/thermomachine/freezer/on
	on = TRUE
	flags = /obj/machinery/atmospherics/unary::flags | NO_NEW_GAGS_PREVIEW

/obj/machinery/atmospherics/unary/thermomachine/freezer/on/Initialize(mapload)
	. = ..()
	if(target_temperature == initial(target_temperature))
		target_temperature = min_temperature

/obj/machinery/atmospherics/unary/thermomachine/freezer/on/coldroom
	name = "Cold room temperature control unit"
	greyscale_colors = COLOR_CYAN
	icon_state = "/obj/machinery/atmospherics/unary/thermomachine/freezer/on/coldroom"

/obj/machinery/atmospherics/unary/thermomachine/freezer/on/coldroom/Initialize(mapload)
	. = ..()
	target_temperature = COLD_ROOM_TEMP

/obj/machinery/atmospherics/unary/thermomachine/freezer/on/server
	name = "Server room temperature control unit"

/obj/machinery/atmospherics/unary/thermomachine/freezer/on/server/Initialize(mapload)
	. = ..()
	target_temperature = SERVER_ROOM_TEMP

/obj/machinery/atmospherics/unary/thermomachine/heater
	cooling = FALSE
	icon_state = "/obj/machinery/atmospherics/unary/thermomachine/heater"
	post_init_icon_state = "thermo_1"
	flags = /obj/machinery/atmospherics/unary::flags

/obj/machinery/atmospherics/unary/thermomachine/heater/on
	on = TRUE
	flags = /obj/machinery/atmospherics/unary::flags | NO_NEW_GAGS_PREVIEW

/obj/machinery/atmospherics/unary/thermomachine/heater/upgraded
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/machinery/atmospherics/unary/thermomachine/heater/upgraded/init_parts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/thermomachine(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

