///////////////////////////////////
//////////Machine Boards///////////
///////////////////////////////////

/datum/design/thermomachine
	id = "thermomachine"
	req_tech = list("programming" = 3, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/thermomachine
	category = list (CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING)

/datum/design/cell_charger
	id = "cell_charger"
	build_path = /obj/item/circuitboard/cell_charger
	materials = list(MAT_GLASS = 1000)
	build_type = IMPRINTER
	req_tech = list("powerstorage" = 3, "materials" = 3)
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/recharger
	id = "recharger"
	build_path = /obj/item/circuitboard/recharger
	materials = list(MAT_GLASS = 1000)
	build_type = IMPRINTER
	req_tech = list("powerstorage" = 3, "materials" = 3)
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/smes
	id = "smes"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/smes
	category = list (CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING)

/datum/design/emitter
	id = "emitter"
	req_tech = list("programming" = 3, "powerstorage" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/emitter
	category = list (CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING)

/datum/design/turbine_computer
	id = "power_turbine_console"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/turbine_computer
	category = list (CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING)

/datum/design/power_compressor
	id = "power_compressor"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/power_compressor
	category = list (CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING)

/datum/design/power_turbine
	id = "power_turbine"
	req_tech = list("programming" = 4, "powerstorage" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/power_turbine
	category = list (CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING)

/datum/design/quantumpad
	id = "quantumpad"
	req_tech = list("programming" = 4, "bluespace" = 4, "plasmatech" = 3, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/quantumpad
	category = list (CIRCUIT_IMPRINTER_CATEGORY_TELEPORTATION)

/datum/design/robotic_pad
	id = "robo_quantumpad"
	req_tech = list("programming" = 5, "bluespace" = 5, "plasmatech" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/roboquest_pad
	category = list (CIRCUIT_IMPRINTER_CATEGORY_TELEPORTATION)

/datum/design/teleport_hub
	id = "tele_hub"
	req_tech = list("programming" = 3, "bluespace" = 5, "materials" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/teleporter_hub
	category = list (CIRCUIT_IMPRINTER_CATEGORY_TELEPORTATION)

/datum/design/teleport_station
	id = "tele_station"
	req_tech = list("programming" = 5, "bluespace" = 4, "engineering" = 4, "plasmatech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/teleporter_station
	category = list (CIRCUIT_IMPRINTER_CATEGORY_TELEPORTATION)

/datum/design/teleport_perma
	id = "tele_perma"
	req_tech = list("programming" = 3, "bluespace" = 5, "materials" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/teleporter_perma
	category = list (CIRCUIT_IMPRINTER_CATEGORY_TELEPORTATION)

/datum/design/bodyscanner
	id = "bodyscanner"
	req_tech = list("programming" = 3, "biotech" = 2, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/bodyscanner
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MEDICAL)

/*	/datum/design/clonepod
	id = "clonepod"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/clonepod
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MEDICAL)
*/
/datum/design/clonescanner
	id = "clonescanner"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/clonescanner
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MEDICAL)

/datum/design/cryotube
	id = "cryotube"
	req_tech = list("programming" = 5, "biotech" = 3, "engineering" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/cryo_tube
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MEDICAL)

/datum/design/chem_dispenser
	id = "chem_dispenser"
	req_tech = list("programming" = 5, "biotech" = 3, "materials" = 4, "plasmatech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/chem_dispenser
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MEDICAL)

/datum/design/chem_master
	id = "chem_master"
	req_tech = list("biotech" = 3, "materials" = 3, "programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/chem_master
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MEDICAL)

/datum/design/chem_heater
	id = "chem_heater"
	req_tech = list("engineering" = 2, "biotech" = 2, "programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/chem_heater
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MEDICAL)

/datum/design/reagentgrinder
	id = "reagentgrinder"
	req_tech = list("biotech" = 2, "materials" = 2, "programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/reagentgrinder
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MEDICAL)

/datum/design/sleeper
	id = "sleeper"
	req_tech = list("programming" = 3, "biotech" = 2, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/sleeper
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MEDICAL)

/datum/design/botanical_dispenser
	id = "botanical_dispenser"
	req_tech = list("programming" = 5, "biotech" = 3, "materials" = 4, "plasmatech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/chem_dispenser/botanical
	category = list(CIRCUIT_IMPRINTER_CATEGORY_HYDROPONICS)

/datum/design/biogenerator
	id = "biogenerator"
	req_tech = list("programming" = 2, "biotech" = 3, "materials" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/biogenerator
	category = list (CIRCUIT_IMPRINTER_CATEGORY_HYDROPONICS)

/datum/design/hydroponics
	id = "hydro_tray"
	req_tech = list("biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/hydroponics
	category = list (CIRCUIT_IMPRINTER_CATEGORY_HYDROPONICS)

/datum/design/autolathe
	id = "autolathe"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/autolathe
	category = list(CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/circuit_imprinter
	id = "circuit_imprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/circuit_imprinter
	category = list(CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/cyborgrecharger
	id = "cyborgrecharger"
	req_tech = list("powerstorage" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/cyborgrecharger
	category = list(CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/destructive_analyzer
	id = "destructive_analyzer"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/destructive_analyzer
	category = list(CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/mechfab
	id = "mechfab"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mechfab
	category = list(CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/podfab
	id = "podfab"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/podfab
	category = list(CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/mech_recharger
	id = "mech_recharger"
	req_tech = list("programming" = 3, "powerstorage" = 4, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mech_recharger
	category = list(CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/experimentor
	id = "experimentor"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/experimentor
	category = list(CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/protolathe
	id = "protolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/protolathe
	category = list(CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/rdserver
	id = "rdserver"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/rdserver
	category = list(CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/gibber
	id = "gibber"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/gibber
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/smartfridge
	id = "smartfridge"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/smartfridge
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/monkey_recycler
	id = "monkey_recycler"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/monkey_recycler
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/seed_extractor
	id = "seed_extractor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/seed_extractor
	category = list (CIRCUIT_IMPRINTER_CATEGORY_HYDROPONICS)

/datum/design/processor
	id = "processor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/processor
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/recycler
	id = "recycler"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/recycler
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/holopad
	id = "holopad"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/holopad
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/arcadebattle
	id = "arcademachinebattle"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/arcade/battle
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/microwave
	id = "microwave"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/microwave
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/oven
	id = "oven"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/oven
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/grill
	id = "grill"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/grill
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/candy_maker
	id = "candymaker"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/candy_maker
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/deepfryer
	id = "deepfryer"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/deepfryer
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/slotmachine
	id = "arcadeslotmachine"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/arcade/slotmachine
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/orion_trail
	id = "arcademachineonion"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/arcade/orion_trail
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/pod
	id = "pod"
	req_tech = list("programming" = 2,"engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/pod
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/ore_redemption
	id = "ore_redemption"
	req_tech = list("programming" = 2, "engineering" = 2, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS=1000)
	build_path = /obj/item/circuitboard/ore_redemption
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/mining_equipment_vendor
	id = "mining_equipment_vendor"
	req_tech = list("engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS=1000)
	build_path = /obj/item/circuitboard/mining_equipment_vendor
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/clawgame
	id = "clawgame"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS=1000)
	build_path = /obj/item/circuitboard/clawgame
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/prize_counter
	id = "prize_counter"
	req_tech = list("programming" = 2, "materials" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS=1000)
	build_path = /obj/item/circuitboard/prize_counter
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/gameboard
	id = "gameboard"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS=1000)
	build_path = /obj/item/circuitboard/gameboard
	category = list(CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/plantgenes
	id = "plantgenes"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS=1000)
	build_path = /obj/item/circuitboard/plantgenes
	category = list(CIRCUIT_IMPRINTER_CATEGORY_HYDROPONICS)

/datum/design/dnaforensics
	id = "dnaforensics"
	req_tech = list("programming" = 2, "combat" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/dnaforensics
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/microscope
	id = "microscope"
	req_tech = list("programming" = 2, "combat" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/microscope
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/station_map
	id = "station_map"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/machine/station_map
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/station_map_engineer
	id = "engineering_station_map"
	req_tech = list("programming" = 5, "engineering" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/machine/station_map/engineering
	category = list (CIRCUIT_IMPRINTER_CATEGORY_MISC)

/datum/design/brs_server
	id = "brs_server"
	req_tech = null	// Unreachable by tech researching.
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_BLUESPACE = 100)
	build_path = /obj/item/circuitboard/brs_server
	category = list (CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/brs_portable_scanner
	id = "brs_portable_scanner"
	req_tech = null	// Unreachable by tech researching.
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_BLUESPACE = 200)
	build_path = /obj/item/circuitboard/brs_portable_scanner
	category = list (CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/brs_stationary_scanner
	id = "brs_stationary_scanner"
	req_tech = null	// Unreachable by tech researching.
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_BLUESPACE = 500)
	build_path = /obj/item/circuitboard/brs_stationary_scanner
	category = list (CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)

/datum/design/anomaly_generator
	id = "anomaly_generator"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/anomaly_generator
	category = list (CIRCUIT_IMPRINTER_CATEGORY_RESEARCH)
