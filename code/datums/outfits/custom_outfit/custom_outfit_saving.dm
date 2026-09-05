#define CUSTOM_OUTFIT_SAVE_FORMAT "ss1984_custom_outfit"
#define CUSTOM_OUTFIT_SAVE_VERSION 1

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
	var/list/reagents = list()
	for(var/reagent_path, volume in reagent_volumes)
		reagents["[reagent_path]"] = volume
	.["reagent_volumes"] = reagents
	.["id_card_data"] = id_card_data

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
		to_chat(user, span_warning("Outfit file is too large."))
		return FALSE
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(!rustg_json_is_valid(json_text))
		to_chat(user, span_warning("Could not read the selected file."))
		return FALSE
	var/list/save_data = json_decode(json_text)
	if(!validate_save_data(save_data))
		to_chat(user, span_warning("Malformed or outdated outfit file."))
		return FALSE
	if(!apply_save_data(save_data))
		to_chat(user, span_warning("Failed to apply outfit file."))
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
		if(!ispath(organ_path, /obj/item/organ/internal))
			continue
		new_internal[organ_path] = TRUE

	var/list/new_reagents = list()
	var/list/reagents = save_data["reagent_volumes"]
	for(var/reagent_text, amount in reagents)
		var/reagent_path = text2path(reagent_text)
		if(!ispath(reagent_path, /datum/reagent) || !isnum(amount) || amount <= 0)
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
				if(!(access_num in get_all_accesses()))
					continue
				new_id_card_data["access"] += access_num

	qdel(edited_outfit)
	edited_outfit = loaded_outfit
	external_augmentations = new_external
	internal_augmentations = new_internal
	reagent_volumes = new_reagents
	id_card_data = new_id_card_data

	body_dirty = TRUE
	backpack_dirty = TRUE
	dental_dirty = TRUE
	return TRUE

/datum/custom_outfit/proc/filter_path_list(list/source, type_path)
	. = list()
	for(var/entry_path in source)
		if(ispath(entry_path, type_path))
			. += entry_path

/datum/custom_outfit/proc/sanitize_loaded_outfit(datum/outfit/loaded_outfit)
	for(var/outfit_slot in slot_to_human_var)
		var/loaded_path = loaded_outfit.vars[outfit_slot]
		if(loaded_path && !ispath(loaded_path, /obj/item))
			loaded_outfit.vars[outfit_slot] = null
		if(loaded_path && !item_fits_species(loaded_path, slot_to_item_flag[outfit_slot], target_mob))
			loaded_outfit.vars[outfit_slot] = null
	var/list/sanitized_backpack = list()
	for(var/item_path, count in loaded_outfit.backpack_contents)
		if(!is_valid_item_entry(item_path, count))
			continue
		sanitized_backpack[item_path] = count
	loaded_outfit.backpack_contents = sanitized_backpack
	if(loaded_outfit.box && !ispath(loaded_outfit.box, /obj/item))
		loaded_outfit.box = null
	if(loaded_outfit.head && ispath(loaded_outfit.head, /obj/item/clothing/head/helmet/space/hardsuit))
		// Hardsuit helmets cannot be spawned standalone (their Initialize expects
		// the parent suit), so they are not a valid head slot item.
		loaded_outfit.head = null
	loaded_outfit.implants = filter_path_list(loaded_outfit.implants, /obj/item/implant)
	loaded_outfit.cybernetic_implants = filter_path_list(loaded_outfit.cybernetic_implants, /obj/item/organ/internal/cyberimp)
	var/list/fitting_cyber = list()
	for(var/organ_path in loaded_outfit.cybernetic_implants)
		if(organ_fits_species(organ_path, target_mob))
			fitting_cyber += organ_path
	loaded_outfit.cybernetic_implants = fitting_cyber
	loaded_outfit.accessories = filter_path_list(loaded_outfit.accessories, /obj/item/clothing/accessory)

#undef CUSTOM_OUTFIT_SAVE_FORMAT
#undef CUSTOM_OUTFIT_SAVE_VERSION
#undef CUSTOM_OUTFIT_LOAD_MAX_LENGTH
