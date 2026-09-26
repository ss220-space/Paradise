#define VOX_TRADE_VALUE_ACCESS_REWARD 100
#define VOX_TRADE_VALUABLE_ACCESS_REWARD 500
/datum/get_cost_step/id_cart_step
	var/list/valuable_access_list = list()

/datum/get_cost_step/id_cart_step/New()
	. = ..()
	valuable_access_list += get_region_accesses(REGION_COMMAND) + get_all_centcom_access() + get_all_syndicate_access() + get_all_misc_access()

/datum/get_cost_step/id_cart_step/can_process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	return is_id_card(process_object)

/datum/get_cost_step/id_cart_step/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	var/obj/item/card/id/id_cart = process_object
	var/list/collected_access_list = trader.collected_access_list
	for(var/access in id_cart.access)
		if(access in collected_access_list)
			continue
		if(access in valuable_access_list)
			temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM_PRECIOUS] += VOX_TRADE_VALUABLE_ACCESS_REWARD
			temp_values[TRAIDER_VALUE_TECH_FLAG] |= VOX_TRADER_ACCESS_UNIQUE
		else
			temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM_PRECIOUS] += VOX_TRADE_VALUE_ACCESS_REWARD
		temp_values[TRAIDER_VALUE_ACCEPTED_ACCESS] += access

#undef VOX_TRADE_VALUE_ACCESS_REWARD
#undef VOX_TRADE_VALUABLE_ACCESS_REWARD
