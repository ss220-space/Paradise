#define VOX_TRADE_ARMOR_DIV 10

/datum/get_cost_step/armor_step/can_process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	return process_object.armor.has_any_armor()

/datum/get_cost_step/armor_step/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	var/temp_val = 0
	var/list/armor_list = process_object.armor.getList()
	for(var/param in armor_list)
		var/param_value = armor_list[param] == INFINITY ? 500 : armor_list[param]
		if(param_value == 0)
			continue
		var/div = 1
		if(param in list(FIRE, ACID))
			div = VOX_TRADE_ARMOR_DIV
		temp_val += div > 1 ? round(param_value / div) : temp_val

	if(!temp_val)
		return

	temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM] += temp_val
	temp_values[TRAIDER_VALUE_TECH_FLAG] |= VOX_TRADER_EQUIP

#undef VOX_TRADE_ARMOR_DIV
