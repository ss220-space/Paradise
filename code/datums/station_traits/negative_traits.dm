/datum/station_trait/carp_infestation
	name = "Нашествие карпов"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Недалеко от станции расположился большой косяк космических карпов"
	trait_to_give = STATION_TRAIT_CARP_INFESTATION

/datum/station_trait/distant_supply_lines
	name = "Проблемы со снабжением"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Из-за чрезвычайного происшествия с шаттлом поставок, все цены в карго повышены."
	//blacklist = list(/datum/station_trait/strong_supply_lines)

/datum/station_trait/distant_supply_lines/on_round_start()
	for(var/set_name in SSshuttle.supply_packs)
		var/datum/supply_packs/pack = SSshuttle.supply_packs[set_name]
		pack.cost *= 1.2

/datum/station_trait/late_arrivals
	name = "Позднее прибытие"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Из-за ошибки в расчетах маршрута, прибытие на станцию произошло гораздо позже, чем ожидалось."
	trait_to_give = STATION_TRAIT_LATE_ARRIVALS
	//blacklist = list(/datum/station_trait/random_spawns, /datum/station_trait/hangover)

