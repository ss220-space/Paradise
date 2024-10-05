#define GROUP_EMERGENCY "Emergency"
#define GROUP_SECURITY "Security"
#define GROUP_ENGINEER "Engineering"
#define GROUP_MEDICAL "Medical"
#define GROUP_SCIENCE "Science"
#define GROUP_ORGANIC "Food and Livestock"
#define GROUP_MATERIALS "Raw Materials"
#define GROUP_VEND "Vending"

#define PERCENTAGE_PAYMENTS_STATION	 	0.25 	//25 percent on the account of the station
#define	PERCENTAGE_PAYMENTS_CARGO 		0.6 	//60 percent on the cargo account
#define PERCENTAGE_PAYMENTS_PERSONAL 	0.15	//15 percent on the account of the beggars

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

/datum/quest_customer/proc/send_reward(reward, var/list/copmpleted_quests = list())
	return FALSE

/datum/quest_customer/proc/special(datum/cargo_quests_storage/quest)
	return

/datum/quest_customer/centcomm
	group_name = "centcomm"

/datum/quest_customer/centcomm/xenoarcheology
	departament_name = "Xenoarcheology dept."
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_MATERIALS = 0.05)


/datum/quest_customer/centcomm/xenobiology
	departament_name = "Xenobiology dept."
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_ORGANIC = 0.05)

/datum/quest_customer/centcomm/alloy_and_composite
	departament_name = "Alloy and Composite div."
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_MATERIALS = 0.10)

/datum/quest_customer/centcomm/valuetech
	departament_name = "ValueTech sec."
	cargo_sale = list(GROUP_SCIENCE = 0.10)

/datum/quest_customer/centcomm/anomaly_research
	departament_name = "Anomaly Research fac."
	cargo_sale = list(GROUP_SCIENCE = 0.10)

/datum/quest_customer/centcomm/cryogenic_physics
	departament_name = "Cryogenic physics dept."
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_ENGINEER = 0.05, GROUP_MEDICAL = 0.05)

/datum/quest_customer/centcomm/applied_physics
	departament_name = "Applied Physics fac."
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_ENGINEER = 0.05, GROUP_SECURITY = 0.05)

/datum/quest_customer/centcomm/biological_warfare
	departament_name = "Biological Warfare div."
	cargo_sale = list(GROUP_SECURITY = 0.05, GROUP_MEDICAL = 0.05)

/datum/quest_customer/centcomm/gene_mutation
	departament_name = "Gene Mutation unit"
	cargo_sale = list(GROUP_MEDICAL = 0.10)

/datum/quest_customer/centcomm/xenoanatomy
	departament_name = "Xenoanatomy dept."
	cargo_sale = list(GROUP_MEDICAL = 0.10)

/datum/quest_customer/centcomm/exp_pharmacology
	departament_name = "Exp. Pharmacology sec."
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_MEDICAL = 0.05)

/datum/quest_customer/centcomm/chimera
	departament_name = "\"Chimera-731\" unit"
	cargo_sale = list(GROUP_MEDICAL = 0.05, GROUP_ORGANIC = 0.05)

/datum/quest_customer/centcomm/organic_farm
	departament_name = "NT Null-G Organic Farm"
	cargo_sale = list(GROUP_ENGINEER = 0.05, GROUP_ORGANIC = 0.10)

/datum/quest_customer/centcomm/fleet_vessel
	departament_name = "NT Fleet Vessel Spaceyard"
	cargo_sale = list(GROUP_SECURITY = 0.10, GROUP_MATERIALS = 0.05)

/datum/quest_customer/centcomm/advanced_expeditionary
	departament_name = "NT Advanced Expeditionary Corps"
	cargo_sale = list(GROUP_SECURITY = 0.05, GROUP_MATERIALS = 0.05, GROUP_ENGINEER = 0.05)

/datum/quest_customer/centcomm/space_mining
	departament_name = "NT Open Space Mining Facility"
	cargo_sale = list(GROUP_SCIENCE = 0.05, GROUP_MATERIALS = 0.05, GROUP_ENGINEER = 0.05)

/datum/quest_customer/centcomm/pioneer_outpost
	departament_name = "NT Pioneer Outpost"
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
	departament_name = "Plasma Enrichment fac."
	cargo_sale = list(GROUP_EMERGENCY = 0.03)

/datum/quest_customer/plasma/refinery
	departament_name = "Plasma Refinery cx."
	cargo_sale = list(GROUP_EMERGENCY = 0.03)

/datum/quest_customer/plasma/applications
	departament_name = "Plasma Applications dept."
	cargo_sale = list(GROUP_EMERGENCY = 0.03)

/datum/quest_customer/plasma/study
	departament_name = "Plasmatic biology study dept."
	cargo_sale = list(GROUP_EMERGENCY = 0.03)

/datum/quest_customer/centcomm/wares_shipping
	departament_name = "Wares Shipping dept."
	cargo_sale = list(GROUP_VEND = 0.05, GROUP_ORGANIC = 0.05)

/datum/quest_customer/centcomm/commercial
	departament_name = "Commercial dept."
	cargo_sale = list(GROUP_VEND = 0.05, GROUP_ORGANIC = 0.05)

/datum/quest_customer/centcomm/business_stategy
	departament_name = "Business Stategy dept."
	cargo_sale = list(GROUP_EMERGENCY = 0.05, GROUP_VEND = 0.05)

/datum/quest_customer/centcomm/headquarters
	departament_name = "Headquarters"
	cargo_sale = list(GROUP_EMERGENCY = 0.05, GROUP_VEND = 0.05)

/datum/quest_customer/corp
	group_name = "corporation"

/datum/quest_customer/corp/change_reward(datum/cargo_quests_storage/quest)
	quest.reward *= POINT_TO_CREDITS * COMMERCIAL_MODIFIER

/datum/quest_customer/corp/send_reward(reward, var/list/copmpleted_quests = list())
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
	station_money_account.credit(round(reward * PERCENTAGE_PAYMENTS_STATION), "Completed Order!", "Biesel TCD Terminal #[rand(111,333)]", "Station Account")

	
	SScapitalism.total_cargo_bounty += round(reward * PERCENTAGE_PAYMENTS_CARGO)
	var/datum/money_account/cargo_money_account = GLOB.department_accounts["Cargo"]
	cargo_money_account.credit(round(reward * PERCENTAGE_PAYMENTS_CARGO), "Completed Order!", "Biesel TCD Terminal #[rand(111,333)]", "Cargo Account")

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
