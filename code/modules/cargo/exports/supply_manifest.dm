
// Correctly stamped manifest.
// Gives half of crate value
/datum/export/manifest_correct
	unit_name = "returned manifest"
	cost = CARGO_CRATE_VALUE / 2
	sales_market = EXPORT_NONE
	k_elasticity = 0
	export_types = list(/obj/item/paper/manifest)

/datum/export/manifest_correct/applies_to(obj/exported_item, apply_elastic, export_markets)
	if(!..())
		return FALSE

	var/obj/item/paper/manifest/paper = exported_item
	if(paper.is_approved() && !paper.erroneous)
		return TRUE
	return FALSE


// Correctly denied manifest.
// Refunds package cost minus the value of the crate.
/datum/export/manifest_error_denied
	unit_name = "correctly denied manifest"
	cost = -CARGO_CRATE_VALUE
	sales_market = EXPORT_NONE
	k_elasticity = 0
	export_types = list(/obj/item/paper/manifest)

/datum/export/manifest_error_denied/applies_to(obj/exported_item, apply_elastic, export_markets)
	if(!..())
		return FALSE

	var/obj/item/paper/manifest/paper = exported_item
	if(paper.is_denied() && paper.erroneous)
		return TRUE
	return FALSE

/datum/export/manifest_error_denied/get_base_cost(obj/item/paper/manifest/paper)
	return cost + paper.points


// Erroneously approved manifest.
// Subtracts package cost.
/datum/export/manifest_error
	unit_name = "erroneously approved manifest"
	cost = -CARGO_CRATE_VALUE
	sales_market = EXPORT_NONE
	k_elasticity = 0
	export_types = list(/obj/item/paper/manifest)
	allow_negative_cost = TRUE

/datum/export/manifest_error/applies_to(obj/exported_item, apply_elastic, export_markets)
	if(!..())
		return FALSE

	var/obj/item/paper/manifest/paper = exported_item
	if(paper.is_approved() && paper.erroneous)
		return TRUE
	return FALSE

/datum/export/manifest_error/get_base_cost(obj/item/paper/manifest/paper)
	return cost - paper.points

// Erroneously denied manifest.
// Subtracts package cost.
/datum/export/manifest_correct_denied
	unit_name = "erroneously denied manifest"
	cost = -CARGO_CRATE_VALUE
	sales_market = EXPORT_NONE
	k_elasticity = 0
	export_types = list(/obj/item/paper/manifest)
	allow_negative_cost = TRUE

/datum/export/manifest_correct_denied/applies_to(obj/exported_item, apply_elastic, export_markets)
	if(!..())
		return FALSE

	var/obj/item/paper/manifest/paper = exported_item
	if(paper.is_denied() && !paper.erroneous)
		return TRUE
	return FALSE

/datum/export/manifest_correct_denied/get_base_cost(obj/item/paper/manifest/paper)
	return cost - paper.points
