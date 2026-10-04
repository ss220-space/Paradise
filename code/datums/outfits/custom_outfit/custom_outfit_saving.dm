#define CUSTOM_OUTFIT_SAVE_FORMAT "ss1984_custom_outfit"
#define CUSTOM_OUTFIT_SAVE_VERSION 3

/datum/custom_outfit/proc/get_save_data()
	. = list()
	.["format"] = CUSTOM_OUTFIT_SAVE_FORMAT
	.["version"] = CUSTOM_OUTFIT_SAVE_VERSION
	.["outfit"] = edited_outfit.get_json_data()
	var/list/external = list()
	for(var/zone, zone_data in external_augmentations)
		external[zone] = zone_data
	.["external_augmentations"] = external
	var/list/internal = list()
	for(var/organ_path in internal_augmentations)
		internal += "[organ_path]"
	.["internal_augmentations"] = internal
	var/list/arm_sides = list()
	for(var/organ_path, side in arm_implant_sides)
		if(!(side in list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)))
			continue
		arm_sides["[organ_path]"] = side
	.["arm_implant_sides"] = arm_sides
	var/list/reagents = list()
	for(var/reagent_path, volume in reagent_volumes)
		reagents["[reagent_path]"] = volume
	.["reagent_volumes"] = reagents
	.["id_card_data"] = id_card_data
	var/list/saved_belt = list()
	for(var/item_path, count in belt_contents)
		if(!CUSTOM_OUTFIT_IS_VALID_ITEM_ENTRY(item_path, count))
			continue
		saved_belt["[item_path]"] = count
	.["belt_contents"] = saved_belt
	.["backpack_nested_contents"] = serialize_nested_for_save(CUSTOM_OUTFIT_CONTAINER_BACKPACK)
	.["belt_nested_contents"] = serialize_nested_for_save(CUSTOM_OUTFIT_CONTAINER_BELT)
	.["mod_suit"] = serialize_mod_configuration()

/// Serializes the MODsuit configuration into a list of type path strings.
/datum/custom_outfit/proc/serialize_mod_configuration()
	var/list/modules = list()
	for(var/module_path in mod_module_paths)
		if(CUSTOM_OUTFIT_IS_MOD_MODULE_PATH(module_path))
			modules += "[module_path]"
	var/list/deployed_parts = list()
	for(var/part_path in mod_deployed_parts)
		deployed_parts += "[part_path]"
	return list(
		"active" = mod_suit_active,
		"modules" = modules,
		"deployed_parts" = deployed_parts,
	)

/datum/custom_outfit/proc/save_to_client(mob/user)
	if(!user.client)
		return FALSE
	pending_save_json = json_encode(get_save_data())
	pending_save_name = "[build_save_file_name()].json"
	return TRUE

/datum/custom_outfit/proc/clear_pending_save()
	pending_save_json = null
	pending_save_name = null

/datum/custom_outfit/proc/build_save_file_name()
	var/raw_name = "[edited_outfit.name || CUSTOM_OUTFIT_DEFAULT_NAME]"
	var/static/regex/unsafe_filename_chars = regex(@"[^A-Za-z0-9_\- ]", "g")
	var/safe_name = unsafe_filename_chars.Replace(raw_name, "")
	safe_name = trim(safe_name)
	safe_name = copytext(safe_name, 1, 64)
	if(!length(safe_name))
		safe_name = CUSTOM_OUTFIT_DEFAULT_NAME
	return safe_name

#define CUSTOM_OUTFIT_LOAD_MAX_LENGTH 262144

/datum/custom_outfit/proc/load_from_json(mob/user, json_text)
	if(!istext(json_text) || !length(json_text))
		return FALSE
	if(length(json_text) > CUSTOM_OUTFIT_LOAD_MAX_LENGTH)
		tgui_alert(user, span_warning("JSON файл слишком большой."))
		return FALSE
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(!rustg_json_is_valid(json_text))
		tgui_alert(user, span_warning("Не удалось прочитать выбранный JSON файл."))
		return FALSE
	var/list/save_data = json_decode(json_text)
	if(!validate_save_data(save_data))
		tgui_alert(user, span_warning("Некорректный или устаревший JSON файл"))
		return FALSE
	if(!apply_save_data(save_data))
		tgui_alert(user, span_warning("Не удалось применить файл."))
		return FALSE
	return TRUE

/datum/custom_outfit/proc/validate_save_data(list/data)
	if(!islist(data))
		return FALSE
	if(data["format"] != CUSTOM_OUTFIT_SAVE_FORMAT)
		return FALSE
	if(!isnum(data["version"]) || data["version"] != CUSTOM_OUTFIT_SAVE_VERSION)
		return FALSE
	if(!islist(data["outfit"]))
		return FALSE
	if(!islist(data["external_augmentations"]))
		return FALSE
	if(!islist(data["internal_augmentations"]))
		return FALSE
	if(!islist(data["reagent_volumes"]))
		return FALSE
	if(data["id_card_data"] != null && !islist(data["id_card_data"]))
		return FALSE
	if(!islist(data["belt_contents"]))
		return FALSE
	if(!islist(data["backpack_nested_contents"]))
		return FALSE
	if(!islist(data["belt_nested_contents"]))
		return FALSE
	if(!islist(data["belt_contents"]))
		return FALSE
	if(!islist(data["backpack_nested_contents"]))
		return FALSE
	if(!islist(data["belt_nested_contents"]))
		return FALSE
	if(!islist(data["mod_suit"]))
		return FALSE
	var/list/mod_data = data["mod_suit"]
	if(!islist(mod_data["modules"]) || !islist(mod_data["deployed_parts"]))
		return FALSE
	return TRUE

/datum/custom_outfit/proc/apply_save_data(list/save_data)
	var/datum/outfit/loaded_outfit = new /datum/outfit
	if(!loaded_outfit.load_from(save_data["outfit"]))
		qdel(loaded_outfit)
		return FALSE
	sanitize_loaded_outfit(loaded_outfit)

	var/list/outfit_data = save_data["outfit"]
	loaded_outfit.toggle_helmet = outfit_data["toggle_helmet"] ? TRUE : FALSE
	loaded_outfit.internals_slot = outfit_data["internals_slot"]
	if(!loaded_outfit.name)
		loaded_outfit.name = CUSTOM_OUTFIT_DEFAULT_NAME

	var/list/new_external = list()
	var/list/external = save_data["external_augmentations"]
	for(var/zone, limb_data in external)
		if(!(zone in external_body_zones) || !islist(limb_data))
			continue
		var/status = limb_data["status"]
		if(!(status in list(CUSTOM_OUTFIT_LIMB_STATUS_AMPUTATED, CUSTOM_OUTFIT_LIMB_STATUS_PROSTHETIC, CUSTOM_OUTFIT_LIMB_STATUS_AUGMENTED)))
			continue
		var/company = limb_data["company"]
		if(status != CUSTOM_OUTFIT_LIMB_STATUS_AMPUTATED && !istext(company))
			continue
		new_external[zone] = list(
			"status" = status,
			"company" = company,
		)

	var/list/new_internal = list()
	for(var/organ_text in save_data["internal_augmentations"])
		var/organ_path = text2path(organ_text)
		if(!CUSTOM_OUTFIT_IS_INTERNAL_ORGAN_PATH(organ_path))
			continue
		new_internal[organ_path] = TRUE
	var/list/new_arm_sides = list()
	if(islist(save_data["arm_implant_sides"]))
		for(var/organ_text, side in save_data["arm_implant_sides"])
			var/organ_path = text2path(organ_text)
			if(!(organ_path in loaded_outfit.cybernetic_implants))
				continue
			if(!(side in list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)))
				continue
			new_arm_sides[organ_path] = side

	var/list/new_reagents = list()
	var/list/reagents = save_data["reagent_volumes"]
	for(var/reagent_text, amount in reagents)
		var/reagent_path = text2path(reagent_text)
		if(!CUSTOM_OUTFIT_IS_VALID_REAGENT_VOLUME(reagent_path, amount))
			continue
		new_reagents[reagent_path] = min(amount, CUSTOM_OUTFIT_MAX_REAGENT_AMOUNT)

	var/list/new_id_card_data = null
	var/list/id_data = save_data["id_card_data"]
	if(islist(id_data))
		new_id_card_data = list(
			"name" = istext(id_data["name"]) ? id_data["name"] : null,
			"assignment" = istext(id_data["assignment"]) ? id_data["assignment"] : null,
			"rank" = istext(id_data["rank"]) ? id_data["rank"] : null,
			"access" = list(),
			"sex" = (id_data["sex"] in list("Мужской", "Женский")) ? id_data["sex"] : null,
			"age" = isnum(id_data["age"]) ? clamp(id_data["age"], 17, 120) : null,
			"blood_type" = istext(id_data["blood_type"]) ? id_data["blood_type"] : null,
			"dna_hash" = istext(id_data["dna_hash"]) ? id_data["dna_hash"] : null,
			"fingerprint_hash" = istext(id_data["fingerprint_hash"]) ? id_data["fingerprint_hash"] : null,
			"associated_account_number" = isnum(id_data["associated_account_number"]) ? max(id_data["associated_account_number"], 0) : null,
			"mining_points" = isnum(id_data["mining_points"]) ? max(id_data["mining_points"], 0) : null,
			"untrackable" = id_data["untrackable"] ? TRUE : FALSE,
		)
		if(islist(id_data["access"]))
			for(var/access_entry in id_data["access"])
				var/access_num = isnum(access_entry) ? access_entry : text2num("[access_entry]")
				if(!isnum(access_num))
					continue
				if(!(access_num in get_absolutely_all_accesses()))
					continue
				new_id_card_data["access"] += access_num

	var/list/new_belt_contents = list()
	if(islist(save_data["belt_contents"]))
		for(var/item_text, count in save_data["belt_contents"])
			var/item_path = text2path(item_text)
			if(!is_valid_item_entry(item_path, count))
				continue
			new_belt_contents[item_path] = count

	var/list/new_nested = list(CUSTOM_OUTFIT_CONTAINER_BACKPACK = list(), CUSTOM_OUTFIT_CONTAINER_BELT = list())
	if(islist(save_data["backpack_nested_contents"]))
		new_nested[CUSTOM_OUTFIT_CONTAINER_BACKPACK] = apply_nested_for_load(save_data["backpack_nested_contents"])
	if(islist(save_data["belt_nested_contents"]))
		new_nested[CUSTOM_OUTFIT_CONTAINER_BELT] = apply_nested_for_load(save_data["belt_nested_contents"])

	qdel(edited_outfit)
	edited_outfit = loaded_outfit
	apply_mod_save_data(save_data["mod_suit"])
	external_augmentations = new_external
	internal_augmentations = new_internal
	arm_implant_sides = new_arm_sides
	reagent_volumes = new_reagents
	id_card_data = new_id_card_data
	belt_contents = new_belt_contents
	nested_storage_contents = new_nested

	body_dirty = TRUE
	backpack_dirty = TRUE
	belt_dirty = TRUE
	dental_dirty = TRUE
	return TRUE

/datum/custom_outfit/proc/filter_path_list(list/source, type_path)
	. = list()
	for(var/entry_path in source)
		if(ispath(entry_path, type_path))
			. += entry_path

/// Restores the MODsuit configuration from saved data, discarding invalid entries.
/datum/custom_outfit/proc/apply_mod_save_data(list/mod_data)
	reset_mod_configuration()
	if(!islist(mod_data))
		return
	mod_suit_active = mod_data["active"] ? TRUE : FALSE
	var/list/valid_modules = list()
	for(var/module_text in mod_data["modules"])
		var/module_path = text2path(module_text)
		if(!CUSTOM_OUTFIT_IS_MOD_MODULE_PATH(module_path))
			continue
		if(module_path in valid_modules)
			continue
		valid_modules += module_path
	for(var/module_path in mod_module_paths)
		if(!(module_path in valid_modules))
			valid_modules += module_path
	mod_module_paths = valid_modules
	mod_active_modules = valid_modules.Copy()
	var/valid_parts = get_mod_part_paths(get_mod_suit_path())
	var/list/valid_deployed = list()
	for(var/part_text in mod_data["deployed_parts"])
		var/part_path = text2path(part_text)
		if(!(part_path in valid_parts))
			continue
		valid_deployed += part_path
	mod_deployed_parts = valid_deployed
	mod_configured_for = get_mod_suit_path()

/datum/custom_outfit/proc/sanitize_loaded_outfit(datum/outfit/loaded_outfit)
	for(var/outfit_slot in slot_to_human_var)
		var/loaded_path = loaded_outfit.vars[outfit_slot]
		if(is_mod_part_type_path(loaded_path))
			loaded_outfit.vars[outfit_slot] = null
			loaded_path = null
		if(loaded_path && !CUSTOM_OUTFIT_IS_ITEM_PATH(loaded_path))
			loaded_outfit.vars[outfit_slot] = null
		if(loaded_path && !item_fits_species(loaded_path, slot_to_item_flag[outfit_slot], target_mob))
			loaded_outfit.vars[outfit_slot] = null
	var/list/sanitized_backpack = list()
	for(var/item_path, count in loaded_outfit.backpack_contents)
		if(!is_valid_item_entry(item_path, count))
			continue
		sanitized_backpack[item_path] = count
	loaded_outfit.backpack_contents = sanitized_backpack
	if(loaded_outfit.box && !CUSTOM_OUTFIT_IS_ITEM_PATH(loaded_outfit.box))
		loaded_outfit.box = null
	if(loaded_outfit.head && CUSTOM_OUTFIT_IS_HARDSUIT_HELMET_PATH(loaded_outfit.head))
		loaded_outfit.head = null
	loaded_outfit.implants = filter_path_list(loaded_outfit.implants, /obj/item/implant)
	loaded_outfit.cybernetic_implants = filter_path_list(loaded_outfit.cybernetic_implants, /obj/item/organ/internal/cyberimp)
	var/list/fitting_cyber = list()
	for(var/organ_path in loaded_outfit.cybernetic_implants)
		if(is_arm_cyberimp_path(organ_path) && copytext("[organ_path]", -2) == "/l")
			continue
		if(organ_fits_species(organ_path, target_mob))
			fitting_cyber += organ_path
	loaded_outfit.cybernetic_implants = fitting_cyber
	loaded_outfit.accessories = filter_path_list(loaded_outfit.accessories, /obj/item/clothing/accessory)

/datum/custom_outfit/proc/serialize_nested_for_save(container_key)
	. = list()
	var/list/container_nested = nested_storage_contents[container_key]
	for(var/parent_path_str, children in container_nested)
		if(!islist(children))
			continue
		var/list/child_out = list()
		for(var/item_path, child_count in children)
			if(!CUSTOM_OUTFIT_IS_VALID_ITEM_ENTRY(item_path, child_count))
				continue
			child_out["[item_path]"] = child_count
		if(length(child_out))
			.[parent_path_str] = child_out

/datum/custom_outfit/proc/apply_nested_for_load(list/nested_data)
	. = list()
	for(var/parent_text, children in nested_data)
		if(!islist(children))
			continue
		var/parent_path = text2path(parent_text)
		if(!CUSTOM_OUTFIT_IS_STORAGE_PATH(parent_path))
			continue
		var/list/child_out = list()
		for(var/item_text, child_count in children)
			var/item_path = text2path(item_text)
			if(!is_valid_item_entry(item_path, child_count))
				continue
			child_out[item_path] = child_count
		if(length(child_out))
			.["[parent_path]"] = child_out

#undef CUSTOM_OUTFIT_SAVE_FORMAT
#undef CUSTOM_OUTFIT_SAVE_VERSION
#undef CUSTOM_OUTFIT_LOAD_MAX_LENGTH
