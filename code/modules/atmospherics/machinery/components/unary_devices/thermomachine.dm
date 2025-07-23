/obj/machinery/atmospherics/components/unary/thermomachine
	name = "thermomachine"
	desc = "Heats or cools gas in connected pipes."
	icon_state = "cold_map"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	active_power_usage = 5000
	plane = GAME_PLANE
	layer = OBJ_LAYER
	resistance_flags = null
	max_integrity = 300
	power_channel = EQUIP
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 30)

	var/icon_state_on
	var/icon_state_open

	var/min_temperature = T20C
	var/max_temperature = T20C
	var/target_temperature = T20C
	var/heat_capacity = 0
	var/interactive = TRUE // So mapmakers can disable interaction.

/obj/machinery/atmospherics/components/unary/thermomachine/New()
	..()
	initialize_directions = dir
	component_parts += populate_parts()
	RefreshParts()

/obj/machinery/atmospherics/components/unary/thermomachine/proc/populate_parts()
	var/list/parts = list()
	parts += new /obj/item/stock_parts/matter_bin(null)
	parts += new /obj/item/stock_parts/matter_bin(null)
	parts += new /obj/item/stock_parts/micro_laser(null)
	parts += new /obj/item/stock_parts/micro_laser(null)
	parts += new /obj/item/stack/cable_coil(null, 1)
	return parts

/obj/machinery/atmospherics/components/unary/thermomachine/on_construction()
	..(dir, dir)

/obj/machinery/atmospherics/components/unary/thermomachine/RefreshParts()
	var/coefficient
	for(var/obj/item/stock_parts/matter_bin/matter_bin in component_parts)
		coefficient += matter_bin.rating
	heat_capacity = 1000 * ((coefficient - 1) ** 2)

/obj/machinery/atmospherics/components/unary/thermomachine/update_icon_state()
	if(panel_open)
		icon_state = icon_state_open
	else if(on && is_operational())
		icon_state = icon_state_on
	else
		icon_state = initial(icon_state)

/obj/machinery/atmospherics/components/unary/thermomachine/process()
	return	// need to overwrite the parent or it returns PROCESS_KILL and it stops processing/using power

/obj/machinery/atmospherics/components/unary/thermomachine/process_atmos()
	..()
	if(!on)
		return FALSE
	var/datum/gas_mixture/air_contents = AIR1

	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = heat_capacity + air_heat_capacity
	var/old_temperature = air_contents.temperature

	if(combined_heat_capacity > 0)
		var/combined_energy = heat_capacity * target_temperature + air_heat_capacity * air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity

	var/temperature_delta= abs(old_temperature - air_contents.temperature)
	if(temperature_delta > 1)
		active_power_usage = (heat_capacity * temperature_delta) / 10 + idle_power_usage
		update_parents()
	else
		active_power_usage = idle_power_usage
	return TRUE

/obj/machinery/atmospherics/components/unary/thermomachine/power_change()
	if(!..())
		return

	if(stat & NOPOWER)
		on = FALSE
		use_power = IDLE_POWER_USE

	update_icon(UPDATE_ICON_STATE)

/obj/machinery/atmospherics/components/unary/thermomachine/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

/obj/machinery/atmospherics/components/unary/thermomachine/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/atmospherics/components/unary/thermomachine/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, icon_state_on, initial(icon_state), I))
		on = 0
		use_power = IDLE_POWER_USE
		update_icon(UPDATE_ICON_STATE)
		return TRUE

/obj/machinery/atmospherics/components/unary/thermomachine/wrench_act(mob/user, obj/item/I)
	if(default_change_direction_wrench(user, I))
		return TRUE

/obj/machinery/atmospherics/components/unary/thermomachine/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/atmospherics/components/unary/thermomachine/attack_ghost(mob/user)
	attack_hand(user)

/obj/machinery/atmospherics/components/unary/thermomachine/attack_hand(mob/user)
	if(..())
		return TRUE

	if(panel_open)
		to_chat(user, span_notice("Сначала закройте панель техобслуживания."))
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/components/unary/thermomachine/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GasFreezer", "Газотемпературная система")
		ui.open()

/obj/machinery/atmospherics/components/unary/thermomachine/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on

	data["min"] = round(min_temperature)
	data["max"] = round(max_temperature)
	data["target"] = round(target_temperature)
	data["targetCelsius"] = round(target_temperature - T0C, 1)
	data["initial"] = T20C

	var/datum/gas_mixture/air_contents = AIR1
	data["temperature"] = round(air_contents.temperature)
	data["temperatureCelsius"] = round(air_contents.temperature - T0C, 1)
	if(air_contents.total_moles() == 0 && air_contents.temperature == 0)
		data["temperatureCelsius"] = 0
	data["pressure"] = round(air_contents.return_pressure())
	return data

/obj/machinery/atmospherics/components/unary/thermomachine/ui_act(action, params)
	if(..())
		return
	add_fingerprint(usr)
	. = TRUE
	switch(action)
		if("power")
			on = !on
			if(on)
				use_power = ACTIVE_POWER_USE
			else
				use_power = IDLE_POWER_USE
			update_icon()

		if("minimum")
			target_temperature = min_temperature

		if("maximum")
			target_temperature = max_temperature

		if("target")
			target_temperature += text2num(params["adjust"])
			target_temperature = clamp(target_temperature, min_temperature, max_temperature)


/obj/machinery/atmospherics/components/unary/thermomachine/freezer
	name = "freezer"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "freezer"
	icon_state_on = "freezer_1"
	icon_state_open = "freezer-o"

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/New()
	..()
	component_parts += new /obj/item/circuitboard/thermomachine/freezer(null)

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/upgraded/populate_parts()
	var/list/parts = list()
	parts += new /obj/item/stock_parts/matter_bin/super(null)
	parts += new /obj/item/stock_parts/matter_bin/super(null)
	parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	parts += new /obj/item/stack/sheet/glass(null)
	parts += new /obj/item/stack/cable_coil(null, 1)
	return parts

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/RefreshParts()
	..()
	var/coefficient
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		coefficient += laser.rating
	min_temperature = max(T0C - (170 + coefficient * 15), TCMB)

/obj/machinery/atmospherics/components/unary/thermomachine/heater
	name = "heater"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "heater"
	icon_state_on = "heater_1"
	icon_state_open = "heater-o"

/obj/machinery/atmospherics/components/unary/thermomachine/heater/New()
	..()
	component_parts += new /obj/item/circuitboard/thermomachine/heater(null)

/obj/machinery/atmospherics/components/unary/thermomachine/heater/upgraded/populate_parts()
	var/list/parts = list()
	parts += new /obj/item/stock_parts/matter_bin/super(null)
	parts += new /obj/item/stock_parts/matter_bin/super(null)
	parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	parts += new /obj/item/stack/sheet/glass(null)
	parts += new /obj/item/stack/cable_coil(null, 1)
	return parts

/obj/machinery/atmospherics/components/unary/thermomachine/heater/RefreshParts()
	..()
	var/coefficient
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		coefficient += laser.rating
	max_temperature = T20C + (140 * coefficient)
