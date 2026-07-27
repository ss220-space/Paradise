
//Enemy intelligence is valuable, believe it or not
/datum/export/documents
	cost = CARGO_CRATE_VALUE * 1.25
	k_elasticity = 0
	sales_market = EXPORT_NONE
	unit_name = "enemy intelligence"
	export_types = list(/obj/item/documents)
	var/needed_interest = INTEREST_NANOTRASEN

/datum/export/documents/applies_to(obj/exported_item, apply_elastic, export_markets)
	if(!..())
		return FALSE

	var/obj/item/documents/sold_int = exported_item
	if(needed_interest & sold_int.sell_interest)
		return TRUE
	return FALSE

/datum/export/documents/get_base_cost(obj/item/documents/papers)
	return cost * papers.sell_multiplier
