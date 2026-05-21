#define VOX_TRADE_STOCK_PARTS_RATING_REWARD 50

/datum/get_cost_step/stock_parts_step/can_process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	return istype(process_object, /obj/item/stock_parts)

/datum/get_cost_step/stock_parts_step/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	var/obj/item/stock_parts/part = process_object
	temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM] += part.rating * VOX_TRADE_STOCK_PARTS_RATING_REWARD

#undef VOX_TRADE_STOCK_PARTS_RATING_REWARD
