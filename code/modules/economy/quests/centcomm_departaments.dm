
/datum/centcomm_departament
	var/departament_name
	var/list/cargo_sale = list()

/datum/centcomm_departament/proc/set_sale()
	if(!length(cargo_sale))
		return
	for(var/category in cargo_sale)
		for(var/set_name in SSshuttle.supply_packs)
			var/datum/supply_packs/pack = SSshuttle.supply_packs[set_name]
			if(pack.group != category)
				continue
			pack.cost *= cargo_sale[category]

/datum/centcomm_departament/xenoarcheology
	departament_name = "Xenoarcheology dept."
	cargo_sale = list(SUPPLY_SCIENCE = 0.95, SUPPLY_MATERIALS = 0.95)


/datum/centcomm_departament/xenobiology
	departament_name = "Xenobiology dept."
	cargo_sale = list(SUPPLY_SCIENCE = 0.95, SUPPLY_ORGANIC = 0.95)

/datum/centcomm_departament/alloy_and_composite
	departament_name = "Alloy and Composite div."
	cargo_sale = list(SUPPLY_SCIENCE = 0.95, SUPPLY_MATERIALS = 0.90)

/datum/centcomm_departament/valuetech
	departament_name = "ValueTech sec."
	cargo_sale = list(SUPPLY_SCIENCE = 0.90)

/datum/centcomm_departament/anomaly_research
	departament_name = "Anomaly Research fac."
	cargo_sale = list(SUPPLY_SCIENCE = 0.90)

/datum/centcomm_departament/cryogenic_physics
	departament_name = "Cryogenic physics dept."
	cargo_sale = list(SUPPLY_SCIENCE = 0.95, SUPPLY_ENGINEER = 0.95, SUPPLY_MEDICAL = 0.95)

/datum/centcomm_departament/applied_physics
	departament_name = "Applied Physics fac."
	cargo_sale = list(SUPPLY_SCIENCE = 0.95, SUPPLY_ENGINEER = 0.95, SUPPLY_SECURITY = 0.95)

/datum/centcomm_departament/biological_warfare
	departament_name = "Biological Warfare div."
	cargo_sale = list(SUPPLY_SECURITY = 0.95, SUPPLY_MEDICAL = 0.95)

/datum/centcomm_departament/gene_mutation
	departament_name = "Gene Mutation unit"
	cargo_sale = list(SUPPLY_MEDICAL = 0.90)

/datum/centcomm_departament/xenoanatomy
	departament_name = "Xenoanatomy dept."
	cargo_sale = list(SUPPLY_MEDICAL = 0.90)

/datum/centcomm_departament/exp_pharmacology
	departament_name = "Exp. Pharmacology sec."
	cargo_sale = list(SUPPLY_SCIENCE = 0.95, SUPPLY_MEDICAL = 0.95)

/datum/centcomm_departament/chimera
	departament_name = "\"Chimera-731\" unit"
	cargo_sale = list(SUPPLY_MEDICAL = 0.95, SUPPLY_ORGANIC = 0.95)

/datum/centcomm_departament/organic_farm
	departament_name = "NT Null-G Organic Farm"
	cargo_sale = list(SUPPLY_ENGINEER = 0.95, SUPPLY_ORGANIC = 0.90)

/datum/centcomm_departament/fleet_vessel
	departament_name = "NT Fleet Vessel Spaceyard"
	cargo_sale = list(SUPPLY_SECURITY = 0.90, SUPPLY_MATERIALS = 0.95)

/datum/centcomm_departament/advanced_expeditionary
	departament_name = "NT Advanced Expeditionary Corps"
	cargo_sale = list(SUPPLY_SECURITY = 0.95, SUPPLY_MATERIALS = 0.95, SUPPLY_ENGINEER = 0.95)

/datum/centcomm_departament/space_mining
	departament_name = "NT Open Space Mining Facility"
	cargo_sale = list(SUPPLY_SCIENCE = 0.95, SUPPLY_MATERIALS = 0.95, SUPPLY_ENGINEER = 0.95)

/datum/centcomm_departament/pioneer_outpost
	departament_name = "NT Pioneer Outpost"
	cargo_sale = list(SUPPLY_MEDICAL = 0.95, SUPPLY_ENGINEER = 0.95, SUPPLY_SECURITY = 0.95)

/datum/centcomm_departament/plasma/enrichment
	departament_name = "Plasma Enrichment fac."
	cargo_sale = list(SUPPLY_EMERGENCY = 0.97)

/datum/centcomm_departament/plasma/refinery
	departament_name = "Plasma Refinery cx."
	cargo_sale = list(SUPPLY_EMERGENCY = 0.97)

/datum/centcomm_departament/plasma/applications
	departament_name = "Plasma Applications dept."
	cargo_sale = list(SUPPLY_EMERGENCY = 0.97)

/datum/centcomm_departament/plasma/study
	departament_name = "Plasmatic biology study dept."
	cargo_sale = list(SUPPLY_EMERGENCY = 0.97)

/datum/centcomm_departament/wares_shipping
	departament_name = "Wares Shipping dept."
	cargo_sale = list(SUPPLY_VEND = 0.95, SUPPLY_ORGANIC = 0.95)

/datum/centcomm_departament/commercial
	departament_name = "Commercial dept."
	cargo_sale = list(SUPPLY_VEND = 0.95, SUPPLY_ORGANIC = 0.95)

/datum/centcomm_departament/business_stategy
	departament_name = "Business Stategy dept."
	cargo_sale = list(SUPPLY_EMERGENCY = 0.95, SUPPLY_VEND = 0.95)

/datum/centcomm_departament/headquarters
	departament_name = "Headquarters"
	cargo_sale = list(SUPPLY_EMERGENCY = 0.95, SUPPLY_VEND = 0.95)

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
