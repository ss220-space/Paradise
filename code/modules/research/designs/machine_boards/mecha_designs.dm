///////////////////////////////////
//////////Mecha Module Disks///////
///////////////////////////////////
// Ripley
/datum/design/ripley_main
	name = "Exosuit Board (APLU \"Ripley\" Central Control module)"
	desc = "Allows for the construction of a \"Ripley\" Central Control module."
	id = "ripley_main"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/ripley/main
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/ripley_peri
	name = "Exosuit Board (APLU \"Ripley\" Peripherals Control module)"
	desc = "Allows for the construction of a  \"Ripley\" Peripheral Control module."
	id = "ripley_peri"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/ripley/peripherals
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

// Odysseus
/datum/design/odysseus_main
	name = "Exosuit Board (\"Odysseus\" Central Control module)"
	desc = "Allows for the construction of a \"Odysseus\" Central Control module."
	id = "odysseus_main"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3,RESEARCH_TREE_BIOTECH = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/odysseus/main
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/odysseus_peri
	name = "Exosuit Board (\"Odysseus\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Odysseus\" Peripheral Control module."
	id = "odysseus_peri"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3,RESEARCH_TREE_BIOTECH = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/odysseus/peripherals
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

// Clarke
/datum/design/clarke_main
	name = "Exosuit Board (\"Clarke\" Central Control module)"
	desc = "Allows for the construction of a \"Clarke\" Central Control module."
	id = "clarke_main"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/clarke/main
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/clarke_peri
	name = "Exosuit Board (\"Clarke\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Clarke\" Peripheral Control module."
	id = "clarke_peri"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/clarke/peripherals
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

// Gygax
/datum/design/gygax_main
	name = "Exosuit Board (\"Gygax\" Central Control module)"
	desc = "Allows for the construction of a \"Gygax\" Central Control module."
	id = "gygax_main"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_ENGINEERING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/gygax/main
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/gygax_peri
	name = "Exosuit Board (\"Gygax\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Gygax\" Peripheral Control module."
	id = "gygax_peri"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_ENGINEERING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/gygax/peripherals
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/gygax_targ
	name = "Exosuit Board (\"Gygax\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Gygax\" Weapons & Targeting Control module."
	id = "gygax_targ"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_ENGINEERING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/gygax/targeting
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

// Durand
/datum/design/durand_main
	name = "Exosuit Board (\"Durand\" Central Control module)"
	desc = "Allows for the construction of a \"Durand\" Central Control module."
	id = "durand_main"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_ENGINEERING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/durand/main
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/durand_peri
	name = "Exosuit Board (\"Durand\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Durand\" Peripheral Control module."
	id = "durand_peri"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 4, RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_ENGINEERING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/durand/peripherals
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/durand_targ
	name = "Exosuit Board (\"Durand\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Durand\" Weapons & Targeting Control module."
	id = "durand_targ"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_ENGINEERING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/durand/targeting
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

// Phazon
/datum/design/phazon_main
	name = "Exosuit Board (\"Phazon\" Central Control module)"
	desc = "Allows for the construction of a \"Phazon\" Central Control module."
	id = "phazon_main"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 6, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_PLASMA = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_BLUESPACE = 100)
	build_path = /obj/item/circuitboard/mecha/phazon/main
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/phazon_peri
	name = "Exosuit Board (\"Phazon\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Phazon\" Peripheral Control module."
	id = "phazon_peri"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 6, RESEARCH_TREE_BLUESPACE = 5, RESEARCH_TREE_PLASMA = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_BLUESPACE = 100)
	build_path = /obj/item/circuitboard/mecha/phazon/peripherals
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/phazon_targ
	name = "Exosuit Design (\"Phazon\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Phazon\" Weapons & Targeting Control module."
	id = "phazon_targ"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 6, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_PLASMA = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_BLUESPACE = 100)
	build_path = /obj/item/circuitboard/mecha/phazon/targeting
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

// H.O.N.K.
/datum/design/honker_main
	name = "Exosuit Board (\"H.O.N.K\" Central Control module)"
	desc = "Allows for the construction of a \"H.O.N.K\" Central Control module."
	id = "honker_main"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/honker/main
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/honker_peri
	name = "Exosuit Board (\"H.O.N.K\" Peripherals Control module)"
	desc = "Allows for the construction of a \"H.O.N.K\" Peripheral Control module."
	id = "honker_peri"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/honker/peripherals
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/honker_targ
	name = "Exosuit Board (\"H.O.N.K\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"H.O.N.K\" Weapons & Targeting Control module."
	id = "honker_targ"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/honker/targeting
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/reticence_main
	name = "Exosuit Module (\"Reticence\" Central Control module)"
	desc = "Allows for the construction of a \"Reticence\" Central Control module."
	id = "reticence_main"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/reticence/main
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/reticence_peri
	name = "Exosuit Module (\"Reticence\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Reticence\" Peripheral Control module."
	id = "reticence_peri"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/reticence/peripherals
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)

/datum/design/reticence_targ
	name = "Exosuit Module (\"Reticence\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Reticence\" Weapons & Targeting Control module."
	id = "reticence_targ"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 3, RESEARCH_TREE_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/reticence/targeting
	category = list(CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT)
