/datum/get_cost_step/valuable_objects_step
	var/list/valuable_objects_dict = list(
		/obj/machinery/nuclearbomb = 5000,
		/obj/item/mod = 300,
		/obj/machinery/power/port_gen = 800,
		/obj/machinery/power = 600,
		/obj/machinery/the_singularitygen/tesla = 8000,
		/obj/machinery/the_singularitygen = 6000,
		/obj/structure/particle_accelerator = 3000,
		/obj/machinery/power/emitter = 500,
		/obj/machinery/power/supermatter_crystal = 15000,
		/obj/machinery/satellite/meteor_shield = 1200,
		/obj/item/circuitboard/computer/sat_control = 2000,
		/obj/item/dna_probe = 150,
		/obj/item/circuitboard/machine/dna_vault = 3000,
		/obj/item/circuitboard/machine/bluespace_tap = 4500,
		/obj/item/circuitboard/machine/bsa = 800,
		/obj/machinery/snow_machine = 750,
		/obj/structure/toilet/bluespace = 5000,
		/obj/structure/toilet/captain_toilet = 3500,
		///obj/structure/toilet/material/king = 2250,
		/obj/structure/toilet/golden_toilet = 1250,
		/obj/structure/toilet = 250,
		/obj/machinery/shower = 150,
		/obj/structure/urinal = 150,
	)

/datum/get_cost_step/valuable_objects_step/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	for(var/valuable_type, value in valuable_objects_dict)
		if(!istype(process_object, valuable_type))
			continue
		temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM_PRECIOUS] += value
		break
