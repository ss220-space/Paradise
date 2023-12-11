#define GROUP_EMERGENCY "Emergency"
#define GROUP_SECURITY "Security"
#define GROUP_ENGINEER "Engineering"
#define GROUP_MEDICAL "Medical"
#define GROUP_SCIENCE "Science"
#define GROUP_ORGANIC "Food and Livestock"
#define GROUP_MATERIALS "Raw Materials"
#define GROUP_VEND "Vending"


/datum/centcomm_departament
	var/departament_name
	var/list/cargo_sale = list()

/datum/centcomm_departament/proc/set_sale()
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
/datum/centcomm_departament/science/xenoarcheology
	departament_name = "Xenoarcheology dept."
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_MATERIALS = 0.95)


/datum/centcomm_departament/science/xenobiology
	departament_name = "Xenobiology dept."
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_ORGANIC = 0.95)

/datum/centcomm_departament/science/alloy_and_composite
	departament_name = "Alloy and Composite div."
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_MATERIALS = 0.90)

/datum/centcomm_departament/science/valuetech
	departament_name = "ValueTech sec."
	cargo_sale = list(GROUP_SCIENCE = 0.90)

/datum/centcomm_departament/science/anomaly_research
	departament_name = "Anomaly Research fac."
	cargo_sale = list(GROUP_SCIENCE = 0.90)

/datum/centcomm_departament/science/cryogenic_physics
	departament_name = "Cryogenic physics dept."
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_ENGINEER = 0.95, GROUP_MEDICAL = 0.95)

/datum/centcomm_departament/science/applied_physics
	departament_name = "Applied Physics fac."
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_ENGINEER = 0.95, GROUP_SECURITY = 0.95)

/datum/centcomm_departament/biological_warfare
	departament_name = "Biological Warfare div."
	cargo_sale = list(GROUP_SECURITY = 0.95, GROUP_MEDICAL = 0.95)

/datum/centcomm_departament/gene_mutation
	departament_name = "Gene Mutation unit"
	cargo_sale = list(GROUP_MEDICAL = 0.90)

/datum/centcomm_departament/xenoanatomy
	departament_name = "Xenoanatomy dept."
	cargo_sale = list(GROUP_MEDICAL = 0.90)

/datum/centcomm_departament/exp_pharmacology
	departament_name = "Exp. Pharmacology sec."
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_MEDICAL = 0.95)

/datum/centcomm_departament/chimera
	departament_name = "\"Chimera-731\" unit"
	cargo_sale = list(GROUP_MEDICAL = 0.95, GROUP_ORGANIC = 0.95)

/datum/centcomm_departament/organic_farm
	departament_name = "NT Null-G Organic Farm"
	cargo_sale = list(GROUP_ENGINEER = 0.95, GROUP_ORGANIC = 0.90)

/datum/centcomm_departament/fleet_vessel
	departament_name = "NT Fleet Vessel Spaceyard"
	cargo_sale = list(GROUP_SECURITY = 0.90, GROUP_MATERIALS = 0.95)

/datum/centcomm_departament/advanced_expeditionary
	departament_name = "NT Advanced Expeditionary Corps"
	cargo_sale = list(GROUP_SECURITY = 0.95, GROUP_MATERIALS = 0.95, GROUP_ENGINEER = 0.95)

/datum/centcomm_departament/space_mining
	departament_name = "NT Open Space Mining Facility"
	cargo_sale = list(GROUP_SCIENCE = 0.95, GROUP_MATERIALS = 0.95, GROUP_ENGINEER = 0.95)

/datum/centcomm_departament/pioneer_outpost
	departament_name = "NT Pioneer Outpost"
	cargo_sale = list(GROUP_MEDICAL = 0.95, GROUP_ENGINEER = 0.95, GROUP_SECURITY = 0.95)

/datum/centcomm_departament/plasma/enrichment
	departament_name = "Plasma Enrichment fac."
	cargo_sale = list(GROUP_EMERGENCY = 0.97)

/datum/centcomm_departament/plasma/refinery
	departament_name = "Plasma Refinery cx."
	cargo_sale = list(GROUP_EMERGENCY = 0.97)

/datum/centcomm_departament/plasma/applications
	departament_name = "Plasma Applications dept."
	cargo_sale = list(GROUP_EMERGENCY = 0.97)

/datum/centcomm_departament/plasma/study
	departament_name = "Plasmatic biology study dept."
	cargo_sale = list(GROUP_EMERGENCY = 0.97)

/datum/centcomm_departament/wares_shipping
	departament_name = "Wares Shipping dept."
	cargo_sale = list(GROUP_VEND = 0.95, GROUP_ORGANIC = 0.95)

/datum/centcomm_departament/commercial
	departament_name = "Commercial dept."
	cargo_sale = list(GROUP_VEND = 0.95, GROUP_ORGANIC = 0.95)

/datum/centcomm_departament/business_stategy
	departament_name = "Business Stategy dept."
	cargo_sale = list(GROUP_EMERGENCY = 0.95, GROUP_VEND = 0.95)

/datum/centcomm_departament/headquarters
	departament_name = "Headquarters"
	cargo_sale = list(GROUP_EMERGENCY = 0.95, GROUP_VEND = 0.95)

/datum/centcomm_departament/corp/set_sale()
	return

/datum/centcomm_departament/corp/chang
	departament_name = "Mr. Chang"

/datum/centcomm_departament/corp/donk
	departament_name = "Donk Co."

/datum/centcomm_departament/corp/waffle
	departament_name = "Waffle Co."

/datum/centcomm_departament/corp/biotech
	departament_name = "BioTech Solutions"

/datum/centcomm_departament/corp/einstein
	departament_name = "Einstein Engines Inc."

/datum/centcomm_departament/corp/cybersun
	departament_name = "Cybersun Industries"

/datum/centcomm_departament/corp/shellguard
	departament_name = "Shellguard Ammunitions"

/datum/centcomm_departament/corp/ward
	departament_name = "Ward-Takanashi"

/datum/centcomm_departament/corp/xion
	departament_name = "Xion Manufacturing Group"

/datum/centcomm_departament/corp/bishop
	departament_name = "Bishop Cybernetics"

/datum/centcomm_departament/corp/robust
	departament_name = "Robust Industries LLC"

/datum/centcomm_departament/corp/gilthari
	departament_name = "Gilthari Exports"

/datum/centcomm_departament/corp/major
	departament_name = "Major Bill's T&S"

/datum/centcomm_departament/corp/haakon
	departament_name = "Haakon Group"


#undef GROUP_EMERGENCY
#undef GROUP_SECURITY
#undef GROUP_ENGINEER
#undef GROUP_MEDICAL
#undef GROUP_SCIENCE
#undef GROUP_ORGANIC
#undef GROUP_MATERIALS
#undef GROUP_VEND
