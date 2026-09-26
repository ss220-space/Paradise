#define VOX_TRADE_INTEGRITY_REWARD 5

/datum/get_cost_step/integrity_step/can_process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	return process_object.obj_integrity > 0

/datum/get_cost_step/integrity_step/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM] += round((process_object.obj_integrity / process_object.max_integrity) * VOX_TRADE_INTEGRITY_REWARD)

#undef VOX_TRADE_INTEGRITY_REWARD
