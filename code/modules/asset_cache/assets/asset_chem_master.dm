/// Pill sprites for UIs
/datum/asset/spritesheet_batched/chem_master
	name = "chem_master"

/datum/asset/spritesheet_batched/chem_master/proc/get_transform()
	var/datum/icon_transformer/transform = new()
	transform.scale(64, 64)
	transform.crop(16, 16, 48, 48)
	transform.scale(16, 16)
	return transform

/datum/asset/spritesheet_batched/chem_master/create_spritesheets()
	var/datum/icon_transformer/transform = get_transform()
	for(var/pill_type = 1 to 20)
		insert_icon("pill[pill_type]", uni_icon('icons/obj/chemical.dmi', "pill[pill_type]", transform = transform))
	for(var/bottle_type in list("bottle", "wide_bottle", "round_bottle", "reagent_bottle"))
		insert_icon(bottle_type, uni_icon('icons/obj/chemical.dmi', bottle_type, transform = transform))
	for(var/i = 1 to 20)
		insert_icon("bandaid[i]", uni_icon('icons/obj/chemical.dmi', "bandaid[i]", transform = transform))

/datum/asset/spritesheet_batched/chem_master/large
	name = "chem_master_large"

/datum/asset/spritesheet_batched/chem_master/get_transform()
	var/datum/icon_transformer/transform = new()
	transform.scale(64, 64)
	transform.crop(16, 16, 48, 48)
	transform.scale(32, 32)
	return transform
