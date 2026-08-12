#define CUSTOM_OUTFIT_SAVE_FORMAT "ss1984_custom_outfit"
#define CUSTOM_OUTFIT_SAVE_VERSION 1

/datum/custom_outfit/proc/get_save_data()
	. = list()
	.["format"] = CUSTOM_OUTFIT_SAVE_FORMAT
	.["version"] = CUSTOM_OUTFIT_SAVE_VERSION
	.["outfit"] = edited_outfit.get_json_data()
	var/list/external = list()
	for(var/zone in external_augmentations)
		external[zone] = external_augmentations[zone]
	.["external_augmentations"] = external
	var/list/internal = list()
	for(var/organ_path in internal_augmentations)
		internal += "[organ_path]"
	.["internal_augmentations"] = internal
	var/list/reagents = list()
	for(var/reagent_path in reagent_volumes)
		reagents["[reagent_path]"] = reagent_volumes[reagent_path]
	.["reagent_volumes"] = reagents

/datum/custom_outfit/proc/save_to_file(mob/user)
	if(!user.client)
		return
	var/list/stored_data = get_save_data()
	var/json = json_encode(stored_data)
	var/file = file("data/TempCustomOutfit_[user.ckey].json")
	fdel(file)
	WRITE_FILE(file, json)
	user << ftp(file, "[build_save_file_name()].json")

/datum/custom_outfit/proc/build_save_file_name()
	var/raw_name = "[edited_outfit.name || CUSTOM_OUTFIT_DEFAULT_NAME]"
	var/static/regex/unsafe_filename_chars = regex(@"[^A-Za-z0-9_\- ]", "g")
	var/safe_name = unsafe_filename_chars.Replace(raw_name, "")
	safe_name = trim(safe_name)
	safe_name = copytext(safe_name, 1, 64)
	if(!length(safe_name))
		safe_name = CUSTOM_OUTFIT_DEFAULT_NAME
	return safe_name

/datum/custom_outfit/proc/load_from_file(mob/user)
	var/outfit_file = input(user, "Pick outfit json file:", "Custom Outfit") as null|file
	if(!outfit_file)
		return FALSE
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	var/file_data = file2text(outfit_file)
	if(!file_data)
		to_chat(user, span_warning("Could not read the selected file."))
		return FALSE
	var/list/save_data = json_decode(file_data)
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
	for(var/zone in external)
		var/list/limb_data = external[zone]
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
	for(var/reagent_text in reagents)
		var/reagent_path = text2path(reagent_text)
		var/amount = reagents[reagent_text]
		if(!ispath(reagent_path, /datum/reagent) || !isnum(amount) || amount <= 0)
			continue
		new_reagents[reagent_path] = min(amount, CUSTOM_OUTFIT_MAX_REAGENT_AMOUNT)

	qdel(edited_outfit)
	edited_outfit = loaded_outfit
	external_augmentations = new_external
	internal_augmentations = new_internal
	reagent_volumes = new_reagents

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
	var/list/sanitized_backpack = list()
	for(var/item_path in loaded_outfit.backpack_contents)
		var/count = loaded_outfit.backpack_contents[item_path]
		if(!is_valid_item_entry(item_path, count))
			continue
		sanitized_backpack[item_path] = count
	loaded_outfit.backpack_contents = sanitized_backpack
	if(loaded_outfit.box && !ispath(loaded_outfit.box, /obj/item))
		loaded_outfit.box = null
	loaded_outfit.implants = filter_path_list(loaded_outfit.implants, /obj/item/implant)
	loaded_outfit.cybernetic_implants = filter_path_list(loaded_outfit.cybernetic_implants, /obj/item/organ/internal/cyberimp)
	loaded_outfit.accessories = filter_path_list(loaded_outfit.accessories, /obj/item/clothing/accessory)

#undef CUSTOM_OUTFIT_SAVE_FORMAT
#undef CUSTOM_OUTFIT_SAVE_VERSION
