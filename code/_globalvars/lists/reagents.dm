// Base chemicals
GLOBAL_LIST_INIT(base_chemicals, list(/datum/reagent/water,/datum/reagent/oxygen,/datum/reagent/nitrogen,/datum/reagent/hydrogen,/datum/reagent/potassium,/datum/reagent/mercury,/datum/reagent/carbon,
							/datum/reagent/chlorine,/datum/reagent/fluorine,/datum/reagent/phosphorus,/datum/reagent/lithium,/datum/reagent/sulfur,/datum/reagent/acid,/datum/reagent/radium,
							/datum/reagent/iron,/datum/reagent/aluminum,/datum/reagent/silicon,/datum/reagent/consumable/sugar,/datum/reagent/consumable/ethanol))
// Standard chemicals
GLOBAL_LIST_INIT(standard_chemicals, list(/datum/reagent/slimejelly,/datum/reagent/blood,/datum/reagent/water,/datum/reagent/lube,/datum/reagent/medicine/charcoal,/datum/reagent/toxin,/datum/reagent/cyanide,
								/datum/reagent/medicine/morphine,/datum/reagent/medicine/morphine/syntmorphine,/datum/reagent/medicine/epinephrine,/datum/reagent/space_drugs,/datum/reagent/oxygen,/datum/reagent/copper,
								/datum/reagent/nitrogen,/datum/reagent/hydrogen,/datum/reagent/potassium,/datum/reagent/mercury,/datum/reagent/sulfur,/datum/reagent/carbon,/datum/reagent/chlorine,
								/datum/reagent/fluorine,/datum/reagent/sodium,/datum/reagent/phosphorus,/datum/reagent/lithium,/datum/reagent/consumable/sugar,/datum/reagent/acid,/datum/reagent/acid/facid,
								/datum/reagent/glycerol,/datum/reagent/radium,/datum/reagent/medicine/mutadone,/datum/reagent/thermite,/datum/reagent/mutagen,/datum/reagent/consumable/virus_food,/datum/reagent/iron,
								/datum/reagent/gold,/datum/reagent/silver,/datum/reagent/uranium,/datum/reagent/aluminum,/datum/reagent/silicon,/datum/reagent/fuel,/datum/reagent/space_cleaner,/datum/reagent/glyphosate/atrazine,
								/datum/reagent/plasma,/datum/reagent/medicine/teporone,/datum/reagent/lexorin,/datum/reagent/medicine/silver_sulfadiazine,/datum/reagent/medicine/salbutamol,
								/datum/reagent/medicine/perfluorodecalin,/datum/reagent/medicine/omnizine,/datum/reagent/medicine/synaptizine,/datum/reagent/medicine/haloperidol,/datum/reagent/medicine/potass_iodide,
								/datum/reagent/medicine/pen_acid,/datum/reagent/medicine/mannitol,/datum/reagent/medicine/oculine,/datum/reagent/medicine/styptic_powder,/datum/reagent/methamphetamine,
								/datum/reagent/medicine/cryoxadone,/datum/reagent/medicine/spaceacillin,/datum/reagent/carpotoxin,/datum/reagent/lsd,/datum/reagent/fluorosurfactant,
								/datum/reagent/fluorosurfactant,/datum/reagent/consumable/ethanol,/datum/reagent/ammonia,/datum/reagent/diethylamine,/datum/reagent/medicine/antihol,/datum/reagent/pancuronium,
								/datum/reagent/lipolicide,/datum/reagent/consumable/condensedcapsaicin,/datum/reagent/consumable/frostoil,/datum/reagent/amanitin,/datum/reagent/psilocybin,
								/datum/reagent/consumable/enzyme,/datum/reagent/consumable/drink/nothing,/datum/reagent/medicine/salglu_solution,/datum/reagent/consumable/ethanol/antifreeze,/datum/reagent/consumable/ethanol/neurotoxin, /datum/reagent/jestosterone))
// Rare chemicals
GLOBAL_LIST_INIT(rare_chemicals, list(/datum/reagent/minttoxin,/datum/reagent/medicine/syndicate_nanites, /datum/reagent/xenomicrobes))
// Standard medicines
GLOBAL_LIST_INIT(standard_medicines, list(/datum/reagent/medicine/charcoal,/datum/reagent/toxin,/datum/reagent/cyanide,/datum/reagent/medicine/morphine,/datum/reagent/medicine/morphine/syntmorphine,/datum/reagent/medicine/epinephrine,/datum/reagent/space_drugs,
								/datum/reagent/medicine/mutadone,/datum/reagent/mutagen,/datum/reagent/medicine/teporone,/datum/reagent/lexorin,/datum/reagent/medicine/silver_sulfadiazine,
								/datum/reagent/medicine/salbutamol,/datum/reagent/medicine/perfluorodecalin, /datum/reagent/medicine/cryoxadone,/datum/reagent/medicine/omnizine,/datum/reagent/medicine/synaptizine,/datum/reagent/medicine/haloperidol,
								/datum/reagent/medicine/potass_iodide,/datum/reagent/medicine/pen_acid,/datum/reagent/medicine/mannitol,/datum/reagent/medicine/oculine,/datum/reagent/medicine/styptic_powder,
								/datum/reagent/methamphetamine,/datum/reagent/medicine/spaceacillin,/datum/reagent/carpotoxin,/datum/reagent/lsd,/datum/reagent/consumable/ethanol,/datum/reagent/ammonia,
								/datum/reagent/diethylamine,/datum/reagent/medicine/antihol,/datum/reagent/pancuronium,/datum/reagent/lipolicide,/datum/reagent/consumable/condensedcapsaicin,
								/datum/reagent/consumable/frostoil,/datum/reagent/amanitin,/datum/reagent/psilocybin,/datum/reagent/consumable/drink/nothing,/datum/reagent/medicine/salglu_solution,/datum/reagent/consumable/ethanol/neurotoxin))
// Rare medicines
GLOBAL_LIST_INIT(rare_medicines, list(/datum/reagent/medicine/syndicate_nanites,/datum/reagent/minttoxin,/datum/reagent/blood, /datum/reagent/xenomicrobes))
// Drinks
GLOBAL_LIST_INIT(drinks, subtypesof(/datum/reagent/consumable/drink/)\
						+ subtypesof(/datum/reagent/consumable/ethanol)\
						+ /datum/reagent/consumable/ethanol)

//Liver Toxins list
GLOBAL_LIST_INIT(liver_toxins, list(/datum/reagent/toxin, /datum/reagent/plasma, /datum/reagent/acid, /datum/reagent/acid/facid, /datum/reagent/cyanide,/datum/reagent/amanitin, /datum/reagent/carpotoxin))

//Random chem blacklist
GLOBAL_LIST_INIT(blocked_chems, list( \
	/datum/reagent/polonium, /datum/reagent/initropidril, /datum/reagent/concentrated_initro,
	/datum/reagent/sodium_thiopental, /datum/reagent/ketamine, /datum/reagent/coniine,
	/datum/reagent/medicine/adminordrazine, /datum/reagent/medicine/adminordrazine/nanites, /datum/reagent/beer2,
	/datum/reagent/slimetoxin, /datum/reagent/aslimetoxin, /datum/reagent/venom,
	/datum/reagent/toxin/spore, /datum/reagent/medicine/stimulants, /datum/reagent/medicine/stimulative_agent,
	/datum/reagent/medicine/syndicate_nanites,
	/datum/reagent,/datum/reagent/consumable/ethanol/dragons_breath, /datum/reagent/medicine/nanocalcium,
	/datum/reagent/bungotoxin, /datum/reagent/consumable/ethanol/fruit_wine,
))

GLOBAL_LIST_INIT(safe_chem_list, list( \
	/datum/reagent/medicine/antihol, /datum/reagent/medicine/charcoal, /datum/reagent/medicine/epinephrine, /datum/reagent/medicine/insulin, /datum/reagent/medicine/teporone,/datum/reagent/medicine/silver_sulfadiazine, /datum/reagent/medicine/salbutamol,
	/datum/reagent/medicine/omnizine, /datum/reagent/medicine/stimulants, /datum/reagent/medicine/synaptizine, /datum/reagent/medicine/potass_iodide, /datum/reagent/medicine/oculine, /datum/reagent/medicine/mannitol, /datum/reagent/medicine/styptic_powder,
	/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/salglu_solution, /datum/reagent/medicine/sal_acid, /datum/reagent/medicine/synthflesh, /datum/reagent/medicine/hydrocodone,
	/datum/reagent/medicine/mitocholide, /datum/reagent/medicine/rezadone
))

GLOBAL_LIST_INIT(safe_chem_applicator_list, list(/datum/reagent/medicine/silver_sulfadiazine, /datum/reagent/medicine/styptic_powder, /datum/reagent/medicine/synthflesh))

GLOBAL_LIST_INIT(borer_reagents, list( \
	/datum/reagent/medicine/charcoal, /datum/reagent/medicine/epinephrine, /datum/reagent/medicine/salbutamol, /datum/reagent/medicine/mannitol, /datum/reagent/capulettium_plus,
	/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/salglu_solution, /datum/reagent/medicine/hydrocodone,
	/datum/reagent/methamphetamine, /datum/reagent/medicine/mitocholide, /datum/reagent/fliptonium, /datum/reagent/medicine/insulin
))
