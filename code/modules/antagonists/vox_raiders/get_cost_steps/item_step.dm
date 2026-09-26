#define VOX_TRADE_TEMP_DIV 5
#define VOX_TRADE_ELECTROPROTECT_REWARD 50
#define VOX_TRADE_PERMEABILITY_COEFFICIENT_REWARD 20
#define VOX_TRADE_WEIGHT_MULT 3

/datum/get_cost_step/item_step/can_process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	return isitem(process_object)

/datum/get_cost_step/item_step/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	var/temp_value = 0
	var/obj/item/typed_item = process_object
	temp_value += temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM] / typed_item.toolspeed
	if(typed_item.max_heat_protection_temperature)
		temp_value += typed_item.max_heat_protection_temperature / VOX_TRADE_TEMP_DIV
	if(typed_item.siemens_coefficient)
		temp_value += VOX_TRADE_ELECTROPROTECT_REWARD * (1 - typed_item.siemens_coefficient)
	if(typed_item.permeability_coefficient)
		temp_value += VOX_TRADE_PERMEABILITY_COEFFICIENT_REWARD * (1 - typed_item.permeability_coefficient)
	if(typed_item.w_class)
		temp_value += typed_item.w_class * VOX_TRADE_WEIGHT_MULT
		if(typed_item.w_class >= WEIGHT_CLASS_BULKY)
			temp_values[TRAIDER_VALUE_TECH_FLAG] |= VOX_TRADER_WEIGHT
	temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM] += round(temp_value)

#undef VOX_TRADE_TEMP_DIV
#undef VOX_TRADE_ELECTROPROTECT_REWARD
#undef VOX_TRADE_PERMEABILITY_COEFFICIENT_REWARD
#undef VOX_TRADE_WEIGHT_MULT
