/datum/get_cost_step/gas_step/can_process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	return process_object.return_obj_air()

/datum/get_cost_step/gas_step/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	var/datum/gas_mixture/canister_mix = process_object.return_obj_air()
	if(!canister_mix.total_moles())
		return

	var/list/canister_gas = canister_mix.get_interesting()

	var/worth = 0
	var/list/gas_meta = GLOB.gas_meta
	for(var/gasID, value in canister_gas)
		worth += ROUND_UP(gas_meta[gasID][META_BASE_VALUE] * value)
		if(worth > MAX_GAS_CREDITS)
			worth = MAX_GAS_CREDITS
			break

	temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM] += worth
