#define VOX_TRADE_STACK_DIV 8
/datum/get_cost_step/stack_step/can_process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	return isstack(process_object)

/datum/get_cost_step/stack_step/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	var/obj/item/stack/stack = process_object
	var/point_value = 1
	if(istype(stack, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/sheet = stack
		point_value += sheet.point_value
	temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM] *= round(stack.amount / VOX_TRADE_STACK_DIV * point_value)

#undef VOX_TRADE_STACK_DIV
