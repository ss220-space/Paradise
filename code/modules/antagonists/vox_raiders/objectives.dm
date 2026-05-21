/datum/objective/raider_steal
	name = "Raider theft"
	needs_target = FALSE
	/// How much valuables need to be stolen
	var/precious_amount = 30
	/// How much value does the "price" have to have to be in order to be counted
	var/precious_value = 200
	/// How many extra valuables need to be stolen depending on the number of people in the game
	var/dynamic_amount = 10
	/// Every X players we add an additional number of values
	var/dynamic_player = 15

/datum/objective/raider_steal/update_explanation_text()
	explanation_text = "Соберите [precious_amount] ценностей, у каждой из которых цена минимум на [precious_value] кикиридитов. Все ценности должны быть приняты Расчичетчикиком."

/datum/objective/raider_steal/New(text, datum/team/team_to_join)
	. = ..()
	generate_amount_goal()

/datum/objective/raider_steal/proc/generate_amount_goal()
	var/players = num_station_players()
	precious_amount += round((players / dynamic_player) * dynamic_amount)
	update_explanation_text()
	return precious_amount

/datum/objective/raider_steal/check_completion()
	var/list_count = 0
	var/obj/machinery/vox_trader/trader = locate() in SSmachines.get_by_type(/obj/machinery/vox_trader)
	if(!trader)
		return
	trader.synchronize_traders_stats()
	for(var/index, value in trader.precious_collected_dict)
		list_count += value[VOX_TRADER_COUNT]
	if(list_count >= precious_amount)
		return TRUE
	return FALSE

/datum/objective/raider_entirety_steal
	name = "Raider entirety theft"
	needs_target = FALSE
	/// Total value sum
	var/precious_value = 50000
	/// How many additional valuables do you need to steal per player
	var/dynamic_value = 750

/datum/objective/raider_entirety_steal/update_explanation_text()
	explanation_text = "Соберите ценностей на сумму [precious_value]. Все ценности должны быть приняты Расчичетчикиком."

/datum/objective/raider_entirety_steal/New(text, datum/team/team_to_join)
	. = ..()
	generate_value_goal()

/datum/objective/raider_entirety_steal/proc/generate_value_goal()
	var/precious_amount = 0
	precious_amount += num_station_players() * dynamic_value
	update_explanation_text()
	return precious_amount

/datum/objective/raider_entirety_steal/check_completion()
	var/value_sum = 0
	for(var/obj/machinery/vox_trader/trader as anything in SSmachines.get_by_type(/obj/machinery/vox_trader))
		value_sum += trader.all_values_sum
	if(value_sum >= precious_value)
		return TRUE
	return FALSE

/datum/objective/raider_collection_access
	name = "Raider access collect"
	needs_target = FALSE
	/// How many accesses do you need to steal
	var/access_amount

/datum/objective/raider_collection_access/update_explanation_text()
	explanation_text = "Соберите [access_amount] уникальных доступов. Все доступы должны быть приняты Расчичетчикиком."

/datum/objective/raider_collection_access/New(text, datum/team/team_to_join)
	. = ..()
	var/max_accesses = length(get_all_accesses())
	access_amount = pick(min(20, max_accesses), max_accesses)
	update_explanation_text()

/datum/objective/raider_collection_access/check_completion()
	for(var/obj/machinery/vox_trader/trader as anything in SSmachines.get_by_type(/obj/machinery/vox_trader))
		if(length(trader.collected_access_list) >= access_amount)
			return TRUE
	return FALSE

/datum/objective/raider_collection_tech
	name = "Raider technology collect"
	needs_target = FALSE
	var/tech_amount	= 9
	var/tech_min_level = 5

/datum/objective/raider_collection_tech/update_explanation_text()
	explanation_text = "Соберите [tech_amount] уникальных технологий [tech_min_level] или больше уровня. Все технологии должны быть приняты Расчичетчикиком."

/datum/objective/raider_collection_tech/New(text, datum/team/team_to_join)
	. = ..()
	update_explanation_text()

/datum/objective/raider_collection_tech/check_completion()
	for(var/obj/machinery/vox_trader/trader as anything in SSmachines.get_by_type(/obj/machinery/vox_trader))
		if(!length(trader.collected_tech_dict))
			continue
		var/count = 0
		for(var/tech, level in trader.collected_tech_dict)
			if(level >= tech_min_level)
				count++
		if(count >= tech_amount)
			return TRUE
	return FALSE

/datum/objective/survive/vox
	name = "Не бросать своих"
	antag_menu_name = "Не бросать своих"
	explanation_text = "Не допустите собственной гибели и гибели остальных членов команды. Избегайте смерти влекущие за собой расходы стае."
