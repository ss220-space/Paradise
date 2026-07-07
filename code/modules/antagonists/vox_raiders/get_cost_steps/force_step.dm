#define VOX_TRADE_FORCE_MULT 5

/datum/get_cost_step/force_step/can_process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	return process_object.force || process_object.throwforce

/datum/get_cost_step/force_step/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM] += round((process_object.force + process_object.throwforce) * VOX_TRADE_FORCE_MULT \
												+ (process_object.throw_speed * process_object.throw_range))

#undef VOX_TRADE_FORCE_MULT

