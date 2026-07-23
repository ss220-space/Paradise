/datum/export/stack
	abstract_type = /datum/export/stack
	unit_name = "sheet"

/datum/export/stack/get_amount(obj/object)
	var/obj/item/stack/stack = object
	if(istype(stack))
		return stack.amount
	return 0

/datum/export/stack/hot_ice
	k_hit_percentile = 0.2 / MAX_STACK_SIZE //Meaning selling 1 full stack of materials will decrease subsequent sales by 20%
	k_recovery_time = 8 MINUTES
	amount_report_multiplier = SHEET_MATERIAL_AMOUNT
	cost = CARGO_CRATE_VALUE * 0.8
	message = "cm3 of Hot Ice"
	//material_id = /datum/material/hot_ice
	export_types = list(/obj/item/stack/sheet/hot_ice)
	//use_shared_exports = FALSE

/datum/export/stack/metal_hydrogen
	cost = CARGO_CRATE_VALUE * 1.05
	k_hit_percentile = 0.2 / MAX_STACK_SIZE //Meaning selling 1 full stack of materials will decrease subsequent sales by 20%
	k_recovery_time = 8 MINUTES
	amount_report_multiplier = SHEET_MATERIAL_AMOUNT
	message = "cm3 of metallic hydrogen"
	//material_id = /datum/material/metalhydrogen
	export_types = list(/obj/item/stack/sheet/mineral/metal_hydrogen)
	//use_shared_exports = FALSE

/datum/export/stack/ammonia_crystals
	cost = CARGO_CRATE_VALUE * 0.125
	unit_name = "of ammonia crystal"
	export_types = list(/obj/item/stack/ammonia_crystals)
