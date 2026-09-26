#define VOX_TRADE_UNIQUE_TECH_REWARD 300

/datum/get_cost_step/tech_step
	var/list/valuable_tech_list = list(
		RESEARCH_TREE_BLUESPACE,
		RESEARCH_TREE_ILLEGAL,
		RESEARCH_TREE_COMBAT,
		RESEARCH_TREE_ALIEN,
	)

/datum/get_cost_step/tech_step/can_process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	return temp_values[TRAIDER_VALUE_ORIGIN_TECH]

/datum/get_cost_step/tech_step/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	var/list/collected_tech_dict = trader.collected_tech_dict

	for(var/tech, tech_value in temp_values[TRAIDER_VALUE_ORIGIN_TECH])
		var/temp_mult = 1
		tech_value = text2num(tech_value)
		if(tech in collected_tech_dict)
			if(collected_tech_dict[tech] < tech_value)
				temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM_PRECIOUS] += VOX_TRADE_UNIQUE_TECH_REWARD * (tech_value - collected_tech_dict[tech])
				if(!temp_values[TRAIDER_VALUE_IS_VISUALISE_ONLY])
					collected_tech_dict[tech] = tech_value
				temp_values[TRAIDER_VALUE_TECH_FLAG] |= VOX_TRADER_UNIQUE_TECH
		else
			temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM_PRECIOUS] += VOX_TRADE_UNIQUE_TECH_REWARD * tech_value
			if(!temp_values[TRAIDER_VALUE_IS_VISUALISE_ONLY])
				collected_tech_dict += list("[tech]" = tech_value)
			temp_values[TRAIDER_VALUE_TECH_FLAG] |= VOX_TRADER_UNIQUE_TECH
		if(tech in valuable_tech_list)
			temp_mult = tech_value
			temp_values[TRAIDER_VALUE_TECH_FLAG] |= VOX_TRADER_VALUABLE_TECH
		var/excess_mult = tech_value > 7 ? 2 : 1
		temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM] += round(tech_value * temp_mult * excess_mult)
		temp_values[TRAIDER_VALUE_TECH_FLAG] |= VOX_TRADER_TECH

#undef VOX_TRADE_UNIQUE_TECH_REWARD
