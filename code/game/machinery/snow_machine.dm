/**
 * Snow machine
 *
 * Generates snow and cools nearby air.
 */
/obj/machinery/snow_machine
	name = "snow machine"
	desc = "Добавьте немного воды, и у вас появится своя зимняя сказка!"
	icon_state = "snow_machine_off"
	density = TRUE
	layer = OBJ_LAYER
	/// Whether the machine is currently active
	var/active = FALSE
	/// Power consumed during the last process cycle
	var/power_used_this_cycle = 0
	/// Cooling rate multiplier based on matter bin parts
	var/cooling_speed = 1
	/// Power efficiency multiplier based on micro-laser parts
	var/power_efficiency = 1
	/// Minimum temperature the machine will cool to
	var/lower_temperature_limit = T0C - 10
	/// If TRUE, machine does not consume reagents to produce snow
	var/infinite_snow = FALSE

/obj/machinery/snow_machine/get_ru_names()
	return list(
		NOMINATIVE = "снегогенератор",
		GENITIVE = "снегогенератора",
		DATIVE = "снегогенератору",
		ACCUSATIVE = "снегогенератор",
		INSTRUMENTAL = "снегогенератором",
		PREPOSITIONAL = "снегогенераторе"
	)

/obj/machinery/snow_machine/Initialize(mapload)
	. = ..()
	create_reagents(300) //Makes 100 snow tiles!
	reagents.add_reagent("water", 300) //But any reagent will do
	reagents.flags |= REAGENT_NOREACT //Because a) this doesn't need to process and b) this way we can use any reagents without needing to worry about explosions and shit
	container_type = REFILLABLE
	component_parts = list()
	component_parts += new /obj/item/circuitboard/snow_machine(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	RefreshParts()

/obj/machinery/snow_machine/examine(mob/user)
	. = ..()
	. += span_notice("Внутренний резервуар показывает, что он заполнен на [infinite_snow ? "100" : round(reagents.total_volume / reagents.maximum_volume * 100)]%.")

/obj/machinery/snow_machine/RefreshParts()
	power_efficiency = 0
	cooling_speed = 0
	for(var/obj/item/stock_parts/matter_bin/matter_bin in component_parts)
		cooling_speed += matter_bin.rating

	for(var/obj/item/stock_parts/micro_laser/micro_laser in component_parts)
		power_efficiency += micro_laser.rating

/obj/machinery/snow_machine/attack_hand(mob/user)
	if(!powered() || !anchored)
		return

	if(turn_on_or_off(!active))
		add_fingerprint(user)
		balloon_alert(user, "[active ? "включено" : "выключено"]")

	return ..()

/obj/machinery/snow_machine/crowbar_act(mob/user, obj/item/crowbar)
	if(default_deconstruction_crowbar(user, crowbar))
		return TRUE

/obj/machinery/snow_machine/screwdriver_act(mob/user, obj/item/screwdriver)
	if(default_deconstruction_screwdriver(user, "snow_machine_openpanel", "snow_machine_off", screwdriver))
		turn_on_or_off(FALSE)
		return TRUE

/obj/machinery/snow_machine/wrench_act(mob/user, obj/item/wrench)
	. = TRUE
	if(!wrench.use_tool(src, user, 0, volume = wrench.tool_volume))
		return

	if(!anchored)
		turn_on_or_off(FALSE)

/obj/machinery/snow_machine/process()
	if(power_used_this_cycle)
		power_used_this_cycle /= power_efficiency
		use_power(power_used_this_cycle)
		power_used_this_cycle = 0

	if(!active || !anchored)
		return

	if(!powered())
		return

	if(!reagents.has_reagent(reagents.get_master_reagent_id(), 3))
		return //This means you don't need to top it up constantly to keep the nice snowclouds going

	var/turf/turf_location = get_turf(src)
	if(isspaceturf(turf_location) || turf_location.density) //If the snowmachine is on a dense tile or in space, then it shouldn't be able to produce any snow and so will turn off
		turn_on_or_off(FALSE, TRUE)
		return

	for(var/turf/current_turf in range(1, src))
		if(issimulatedturf(current_turf))
			var/datum/milla_safe/snow_machine_cooling/milla = new()
			milla.invoke_async(src, cooling_speed)

		if(prob(50))
			continue

		make_snowcloud(current_turf)

/datum/milla_safe/snow_machine_cooling

/datum/milla_safe/snow_machine_cooling/on_run(obj/machinery/snow_machine/snowy, modifier)
	var/turf/turf_location = get_turf(snowy)
	var/datum/gas_mixture/environment_gas_mixture = get_turf_air(turf_location)

	if(!issimulatedturf(turf_location) || turf_location.density)
		return

	var/initial_temperature = environment_gas_mixture.temperature()
	if(initial_temperature <= snowy.lower_temperature_limit) //Can we actually cool this?
		return

	var/old_thermal_energy = environment_gas_mixture.thermal_energy()
	var/amount_cooled = initial_temperature - modifier * 8000 / environment_gas_mixture.heat_capacity()
	environment_gas_mixture.set_temperature(max(amount_cooled, snowy.lower_temperature_limit))

	var/new_thermal_energy = environment_gas_mixture.thermal_energy()
	snowy.power_used_this_cycle += (old_thermal_energy - new_thermal_energy) / 100

/obj/machinery/snow_machine/power_change(forced = FALSE)
	if(!..())
		return

	if(!powered())
		turn_on_or_off(FALSE, TRUE)

	update_icon(UPDATE_ICON_STATE)

/obj/machinery/snow_machine/update_icon_state()
	if(panel_open)
		icon_state = "snow_machine_openpanel"
	else
		icon_state = "snow_machine_[active ? "on" : "off"]"

/**
 * Creates a snow cloud on the target turf
 *
 * Arguments:
 * * target_turf - The turf where the snow cloud should appear
 */
/obj/machinery/snow_machine/proc/make_snowcloud(turf/target_turf)
	if(isspaceturf(target_turf))
		return

	if(target_turf.density)
		return

	if(target_turf.get_readonly_air().temperature() > T0C + 1)
		return

	if(locate(/obj/effect/snowcloud, target_turf)) //Ice to see you
		return

	if(infinite_snow || !reagents.remove_reagent(reagents.get_master_reagent_id(), 3))
		new /obj/effect/snowcloud(target_turf, src)
		power_used_this_cycle += 1000
		return TRUE

/**
 * Toggles the machine's active state
 *
 * Arguments:
 * * activate - If TRUE, turn the machine on; if FALSE, turn it off
 * * give_message - If TRUE and turning off, show a visible warning message
 */
/obj/machinery/snow_machine/proc/turn_on_or_off(activate, give_message = FALSE)
	active = activate ? TRUE : FALSE
	if(!active && give_message)
		visible_message(
			span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] выключается!")
		)
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, FALSE)

	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/snow_machine/infinite
	desc = "Добавьте немного воды, и у вас появится своя зимняя сказка! Кажется сказка будет длиться вечно..."
	infinite_snow = TRUE
