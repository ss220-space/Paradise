#define GROUP_EMERGENCY "Emergency"
#define GROUP_SECURITY "Security"
#define GROUP_ENGINEER "Engineering"
#define GROUP_MEDICAL "Medical"
#define GROUP_SCIENCE "Science"
#define GROUP_ORGANIC "Food and Livestock"
#define GROUP_MATERIALS "Raw Materials"
#define GROUP_VEND "Vending"

#define POINT_TO_CREDITS 10

/datum/customer
	var/departament_name
	var/group_name
	var/list/cargo_sale = list()
	var/list/can_order = list()
	var/list/cant_order = list(/datum/cargo_quest/thing/minerals/plasma)

/datum/customer/proc/set_sale()
	if(!length(cargo_sale))
		return
	for(var/category in cargo_sale)
		for(var/set_name in SSshuttle.supply_packs)
			var/datum/supply_packs/pack = SSshuttle.supply_packs[set_name]
			if(get_supply_group_name(pack.group) != category)
				continue
			pack.cost = round(pack.cost * cargo_sale[category])

	if(!cargo_sale[GROUP_SCIENCE])
		return

	SSshuttle.supply.callTime = max(SSshuttle.supply.callTime * cargo_sale[GROUP_SCIENCE], 90 SECONDS)

/datum/customer/proc/change_reward(datum/cargo_quests_storage/quest)
	return

/datum/customer/proc/get_difficulty()
	return

/datum/customer/proc/send_reward(reward)
	return FALSE

/datum/customer/proc/special(datum/cargo_quests_storage/quest)
	return

/datum/customer/centcomm
	group_name = "centcomm"

/datum/customer/centcomm/xenoarcheology
	departament_name = "Xenoarcheology dept."
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_MATERIALS = 0.95)


/datum/customer/centcomm/xenobiology
	departament_name = "Xenobiology dept."
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_ORGANIC = 0.95)

/datum/customer/centcomm/alloy_and_composite
	departament_name = "Alloy and Composite div."
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_MATERIALS = 0.90)

/datum/customer/centcomm/valuetech
	departament_name = "ValueTech sec."
	cargo_sale = list(GROUP_SCIENCE = 0.90)

/datum/customer/centcomm/anomaly_research
	departament_name = "Anomaly Research fac."
	cargo_sale = list(GROUP_SCIENCE = 0.90)

/datum/customer/centcomm/cryogenic_physics
	departament_name = "Cryogenic physics dept."
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_ENGINEER = 0.95, GROUP_MEDICAL = 0.95)

/datum/customer/centcomm/applied_physics
	departament_name = "Applied Physics fac."
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_ENGINEER = 0.95, GROUP_SECURITY = 0.95)

/datum/customer/centcomm/biological_warfare
	departament_name = "Biological Warfare div."
	cargo_sale = list(GROUP_SECURITY = 0.95, GROUP_MEDICAL = 0.95)

/datum/customer/centcomm/gene_mutation
	departament_name = "Gene Mutation unit"
	cargo_sale = list(GROUP_MEDICAL = 0.90)

/datum/customer/centcomm/xenoanatomy
	departament_name = "Xenoanatomy dept."
	cargo_sale = list(GROUP_MEDICAL = 0.90)

/datum/customer/centcomm/exp_pharmacology
	departament_name = "Exp. Pharmacology sec."
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_MEDICAL = 0.95)

/datum/customer/centcomm/chimera
	departament_name = "\"Chimera-731\" unit"
	cargo_sale = list(GROUP_MEDICAL = 0.95, GROUP_ORGANIC = 0.95)

/datum/customer/centcomm/organic_farm
	departament_name = "NT Null-G Organic Farm"
	cargo_sale = list(GROUP_ENGINEER = 0.95, GROUP_ORGANIC = 0.90)

/datum/customer/centcomm/fleet_vessel
	departament_name = "NT Fleet Vessel Spaceyard"
	cargo_sale = list(GROUP_SECURITY = 0.90, GROUP_MATERIALS = 0.95)

/datum/customer/centcomm/advanced_expeditionary
	departament_name = "NT Advanced Expeditionary Corps"
	cargo_sale = list(GROUP_SECURITY = 0.95, GROUP_MATERIALS = 0.95, GROUP_ENGINEER = 0.95)

/datum/customer/centcomm/space_mining
	departament_name = "NT Open Space Mining Facility"
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_MATERIALS = 0.95, GROUP_ENGINEER = 0.95)

/datum/customer/centcomm/pioneer_outpost
	departament_name = "NT Pioneer Outpost"
	cargo_sale = list(GROUP_MEDICAL = 0.95, GROUP_ENGINEER = 0.95, GROUP_SECURITY = 0.95)

/datum/customer/plasma
	group_name = "plasma"
	can_order = list(/datum/cargo_quest/thing/minerals/plasma)
	cant_order = null

/datum/customer/plasma/get_difficulty()
	return locate(/datum/quest_difficulty/normal) in SScargo_quests.difficulties

/datum/customer/plasma/special(datum/cargo_quests_storage/quest)
	SScargo_quests.plasma_quests += quest

/datum/customer/plasma/enrichment
	departament_name = "Plasma Enrichment fac."
	cargo_sale = list(GROUP_EMERGENCY = 0.97)

/datum/customer/plasma/refinery
	departament_name = "Plasma Refinery cx."
	cargo_sale = list(GROUP_EMERGENCY = 0.97)

/datum/customer/plasma/applications
	departament_name = "Plasma Applications dept."
	cargo_sale = list(GROUP_EMERGENCY = 0.97)

/datum/customer/plasma/study
	departament_name = "Plasmatic biology study dept."
	cargo_sale = list(GROUP_EMERGENCY = 0.97)

/datum/customer/centcomm/wares_shipping
	departament_name = "Wares Shipping dept."
	cargo_sale = list(GROUP_VEND = 0.95, GROUP_ORGANIC = 0.95)

/datum/customer/centcomm/commercial
	departament_name = "Commercial dept."
	cargo_sale = list(GROUP_VEND = 0.95, GROUP_ORGANIC = 0.95)

/datum/customer/centcomm/business_stategy
	departament_name = "Business Stategy dept."
	cargo_sale = list(GROUP_EMERGENCY = 0.95, GROUP_VEND = 0.95)

/datum/customer/centcomm/headquarters
	departament_name = "Headquarters"
	cargo_sale = list(GROUP_EMERGENCY = 0.95, GROUP_VEND = 0.95)

/datum/customer/corp
	group_name = "corporation"

/datum/customer/corp/change_reward(datum/cargo_quests_storage/quest)
	quest.reward *= POINT_TO_CREDITS

/datum/customer/corp/send_reward(reward)
	var/datum/money_account/station_money_account = GLOB.station_account
	station_money_account.credit(round(reward/4), "Completed Order!", "Biesel TCD Terminal #[rand(111,333)]", "Station Account")
	var/datum/money_account/cargo_money_account = GLOB.department_accounts["Cargo"]
	cargo_money_account.credit(round(reward/4*3), "Completed Order!", "Biesel TCD Terminal #[rand(111,333)]", "Cargo Account")
	return TRUE


/datum/customer/corp/chang
	departament_name = "Mr. Chang"

/datum/customer/corp/donk
	departament_name = "Donk Co."

/datum/customer/corp/waffle
	departament_name = "Waffle Co."

/datum/customer/corp/biotech
	departament_name = "BioTech Solutions"

/datum/customer/corp/einstein
	departament_name = "Einstein Engines Inc."

/datum/customer/corp/cybersun
	departament_name = "Cybersun Industries"

/datum/customer/corp/shellguard
	departament_name = "Shellguard Ammunitions"

/datum/customer/corp/ward
	departament_name = "Ward-Takanashi"

/datum/customer/corp/xion
	departament_name = "Xion Manufacturing Group"

/datum/customer/corp/bishop
	departament_name = "Bishop Cybernetics"

/datum/customer/corp/robust
	departament_name = "Robust Industries LLC"

/datum/customer/corp/gilthari
	departament_name = "Gilthari Exports"

/datum/customer/corp/major
	departament_name = "Major Bill's T&S"

/datum/customer/corp/haakon
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
