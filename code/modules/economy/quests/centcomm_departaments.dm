#define GROUP_EMERGENCY "Чрезвычайные ситуации"
#define GROUP_SECURITY "Безопасность"
#define GROUP_ENGINEER "Инженерия"
#define GROUP_MEDICAL "Медицина"
#define GROUP_SCIENCE "Наука"
#define GROUP_ORGANIC "Продовольствие и животноводство"
#define GROUP_MATERIALS "Материалы"
#define GROUP_VEND "Торговля"

#define PERCENTAGE_PAYMENTS_STATION 0.25 //25 percent on the account of the station
#define	PERCENTAGE_PAYMENTS_CARGO 0.6 //60 percent on the cargo account
#define PERCENTAGE_PAYMENTS_PERSONAL 0.15 //15 percent on the account of the beggars

#define POINT_TO_CREDITS 10
#define COMMERCIAL_MODIFIER 3

//Give up hope, hope, everyone who enters here

/datum/quest_customer
	var/departament_name
	var/group_name
	var/list/cargo_sale = list()
	var/list/can_order = list()
	var/list/cant_order = list(/datum/cargo_quest/thing/minerals/plasma)
	var/modificator = 0

/datum/quest_customer/proc/set_sale(modificator)
	if(!length(cargo_sale))
		return

	src.modificator = modificator
	for(var/category in cargo_sale)
		for(var/set_name in SSshuttle.supply_packs)
			var/datum/supply_packs/pack = SSshuttle.supply_packs[set_name]
			if(get_supply_group_name(pack.group) != category)
				continue
			pack.cost = round(pack.cost * (1 - cargo_sale[category] * modificator))

	if(!cargo_sale[GROUP_SCIENCE])
		return

	SSshuttle.supply.callTime = max(SSshuttle.supply.callTime * cargo_sale[GROUP_SCIENCE], 90 SECONDS)

/datum/quest_customer/proc/change_reward(datum/cargo_quests_storage/quest)
	return

/datum/quest_customer/proc/get_difficulty()
	return

/datum/quest_customer/proc/send_reward(reward, list/copmpleted_quests = list())
	return FALSE

/datum/quest_customer/proc/special(datum/cargo_quests_storage/quest)
	return

/datum/quest_customer/centcomm
	group_name = "centcomm"

/datum/quest_customer/centcomm/xenoarcheology
	departament_name = "Центр ксеноархеологии"
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_MATERIALS = 0.05)

/datum/quest_customer/centcomm/xenobiology
	departament_name = "Центр ксенобиологии"
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_ORGANIC = 0.05)

/datum/quest_customer/centcomm/alloy_and_composite
	departament_name = "Центр сплавов и композитов"
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_MATERIALS = 0.10)

/datum/quest_customer/centcomm/valuetech
	departament_name = "Центр информационных технологий"
	cargo_sale = list(GROUP_SCIENCE = 0.10)

/datum/quest_customer/centcomm/anomaly_research
	departament_name = "Центр исследования аномалий"
	cargo_sale = list(GROUP_SCIENCE = 0.10)

/datum/quest_customer/centcomm/cryogenic_physics
	departament_name = "Центр криогенной физики"
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_ENGINEER = 0.05, GROUP_MEDICAL = 0.05)

/datum/quest_customer/centcomm/applied_physics
	departament_name = "Центр прикладной физики"
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_ENGINEER = 0.05, GROUP_SECURITY = 0.05)

/datum/quest_customer/centcomm/biological_warfare
	departament_name = "Подразделение биологического вооружения"
	cargo_sale = list(GROUP_SECURITY = 0.05, GROUP_MEDICAL = 0.05)

/datum/quest_customer/centcomm/gene_mutation
	departament_name = "Подразделение генной инженерии"
	cargo_sale = list(GROUP_MEDICAL = 0.10)

/datum/quest_customer/centcomm/xenoanatomy
	departament_name = "Подразделение ксеноанатомии"
	cargo_sale = list(GROUP_MEDICAL = 0.10)

/datum/quest_customer/centcomm/exp_pharmacology
	departament_name = "Центр экспериментальной фармакологии"
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_MEDICAL = 0.05)

/datum/quest_customer/centcomm/chimera
	departament_name = "Подразделение \"Химера-731\""
	cargo_sale = list(GROUP_MEDICAL = 0.05, GROUP_ORGANIC = 0.05)

/datum/quest_customer/centcomm/organic_farm
	departament_name = "Органическая ферма НТ"
	cargo_sale = list(GROUP_ENGINEER = 0.05, GROUP_ORGANIC = 0.10)

/datum/quest_customer/centcomm/fleet_vessel
	departament_name = "Космодром флота НТ"
	cargo_sale = list(GROUP_SECURITY = 0.10, GROUP_MATERIALS = 0.05)

/datum/quest_customer/centcomm/advanced_expeditionary
	departament_name = "Передовой экспедиционный корпус НТ"
	cargo_sale = list(GROUP_SECURITY = 0.05, GROUP_MATERIALS = 0.05, GROUP_ENGINEER = 0.05)

/datum/quest_customer/centcomm/space_mining
	departament_name = "Космическое шахтёрское предприятие НТ"
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_MATERIALS = 0.05, GROUP_ENGINEER = 0.05)

/datum/quest_customer/centcomm/pioneer_outpost
	departament_name = "Пионерский аванпост НТ"
	cargo_sale = list(GROUP_MEDICAL = 0.05, GROUP_ENGINEER = 0.05, GROUP_SECURITY = 0.05)

/datum/quest_customer/plasma
	group_name = "plasma"
	can_order = list(/datum/cargo_quest/thing/minerals/plasma)
	cant_order = null

/datum/quest_customer/plasma/get_difficulty()
	return locate(/datum/quest_difficulty/normal) in SScargo_quests.difficulties

/datum/quest_customer/plasma/special(datum/cargo_quests_storage/quest)
	SScargo_quests.plasma_quests += quest

/datum/quest_customer/plasma/enrichment
	departament_name = "Комплекс по обогащению плазмы"
	cargo_sale = list(GROUP_EMERGENCY = 0.03)

/datum/quest_customer/plasma/refinery
	departament_name = "Комплекс по переработке плазмы"
	cargo_sale = list(GROUP_EMERGENCY = 0.03)

/datum/quest_customer/plasma/applications
	departament_name = "Отделение реализации плазмы"
	cargo_sale = list(GROUP_EMERGENCY = 0.03)

/datum/quest_customer/plasma/study
	departament_name = "Центр изучения плазмы"
	cargo_sale = list(GROUP_EMERGENCY = 0.03)

/datum/quest_customer/centcomm/wares_shipping
	departament_name = "Подразделение логистики"
	cargo_sale = list(GROUP_VEND = 0.05, GROUP_ORGANIC = 0.05)

/datum/quest_customer/centcomm/commercial
	departament_name = "Отдел торговли"
	cargo_sale = list(GROUP_VEND = 0.05, GROUP_ORGANIC = 0.05)

/datum/quest_customer/centcomm/business_stategy
	departament_name = "Отдел делового планирования"
	cargo_sale = list(GROUP_EMERGENCY = 0.05, GROUP_VEND = 0.05)

/datum/quest_customer/centcomm/headquarters
	departament_name = "Главный штаб"
	cargo_sale = list(GROUP_EMERGENCY = 0.05, GROUP_VEND = 0.05)

/datum/quest_customer/corp
	group_name = "corporation"

/datum/quest_customer/corp/change_reward(datum/cargo_quests_storage/quest)
	quest.reward *= POINT_TO_CREDITS * COMMERCIAL_MODIFIER

/datum/quest_customer/corp/send_reward(reward, list/copmpleted_quests = list())
	var/list/nishebrod_jobs = list()
	var/list/linked_departaments = list() //HEHE HI HA
	var/personals_reward = round(reward * PERCENTAGE_PAYMENTS_PERSONAL)
	for(var/datum/cargo_quest/quest in copmpleted_quests)
		nishebrod_jobs |= quest.bounty_jobs
		linked_departaments |= quest.linked_departament

	//If not, it pays to the account of the department
	if(!SScapitalism.smart_bounty_payment(nishebrod_jobs, personals_reward))
		SScapitalism.smart_departament_payment(linked_departaments, personals_reward)

	SScapitalism.total_station_bounty += round(reward * PERCENTAGE_PAYMENTS_STATION)
	var/datum/money_account/station_money_account = SScapitalism.base_account
	station_money_account.credit(round(reward * PERCENTAGE_PAYMENTS_STATION), "Завершённый запрос на поставку", "Терминал Бизель №[rand(111,333)]", "Счёт объекта")

	SScapitalism.total_cargo_bounty += round(reward * PERCENTAGE_PAYMENTS_CARGO)
	var/datum/money_account/cargo_money_account = GLOB.department_accounts["Cargo"]
	cargo_money_account.credit(round(reward * PERCENTAGE_PAYMENTS_CARGO), "Завершённый запрос на поставку", "Терминал Бизель №[rand(111,333)]", "Счёт Отдела снабжения")

	return TRUE

/datum/quest_customer/corp/chang
	departament_name = "Mr. Chang"

/datum/quest_customer/corp/donk
	departament_name = "Donk Co."

/datum/quest_customer/corp/waffle
	departament_name = "Waffle Co."

/datum/quest_customer/corp/biotech
	departament_name = "BioTech Solutions"

/datum/quest_customer/corp/einstein
	departament_name = "Einstein Engines Inc."

/datum/quest_customer/corp/cybersun
	departament_name = "Cybersun Industries"

/datum/quest_customer/corp/shellguard
	departament_name = "Shellguard Ammunitions"

/datum/quest_customer/corp/ward
	departament_name = "Ward-Takanashi"

/datum/quest_customer/corp/xion
	departament_name = "Xion Manufacturing Group"

/datum/quest_customer/corp/bishop
	departament_name = "Bishop Cybernetics"

/datum/quest_customer/corp/robust
	departament_name = "Robust Industries LLC"

/datum/quest_customer/corp/gilthari
	departament_name = "Gilthari Exports"

/datum/quest_customer/corp/major
	departament_name = "Major Bill's T&S"

/datum/quest_customer/corp/haakon
	departament_name = "Haakon Group"

#undef GROUP_EMERGENCY
#undef GROUP_SECURITY
#undef GROUP_ENGINEER
#undef GROUP_MEDICAL
#undef GROUP_SCIENCE
#undef GROUP_ORGANIC
#undef GROUP_MATERIALS
#undef GROUP_VEND

#undef POINT_TO_CREDITS
#undef COMMERCIAL_MODIFIER

#undef PERCENTAGE_PAYMENTS_STATION
#undef PERCENTAGE_PAYMENTS_CARGO
#undef PERCENTAGE_PAYMENTS_PERSONAL
