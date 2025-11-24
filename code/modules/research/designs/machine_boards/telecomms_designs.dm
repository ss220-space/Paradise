////////////////////////////////////////
//////////Telecomms Equipment///////////
////////////////////////////////////////
// Only 2 of these exist, so they should really be in a different place. But oh well.
/datum/design/telecomms_core
	id = "s-hub"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 2, RESEARCH_TREE_ENGINEERING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/tcomms/core
	category = list(CIRCUIT_IMPRINTER_CATEGORY_TELECOMS)

/datum/design/telecomms_relay
	id = "s-relay"
	req_tech = list(RESEARCH_TREE_PROGRAMMING = 2, RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_BLUESPACE = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/tcomms/relay
	category = list(CIRCUIT_IMPRINTER_CATEGORY_TELECOMS)
