#define CUSTOM_OUTFIT_ACTION_LOAD "load"
#define CUSTOM_OUTFIT_ACTION_COPY "copy"
#define CUSTOM_OUTFIT_ACTION_SAVE "save"
#define CUSTOM_OUTFIT_ACTION_APPLY "apply"
#define CUSTOM_OUTFIT_ACTION_ADD_IMPLANT "add_implant"
#define CUSTOM_OUTFIT_ACTION_REMOVE_IMPLANT "remove_implant"
#define CUSTOM_OUTFIT_ACTION_ADD_BACKPACK_ITEM "add_backpack_item"
#define CUSTOM_OUTFIT_ACTION_REMOVE_ITEM "remove_item"
#define CUSTOM_OUTFIT_ACTION_ADD_AUGMENTATION "add_augmentation"
#define CUSTOM_OUTFIT_ACTION_REMOVE_AUGMENTATION "remove_augmentation"
#define CUSTOM_OUTFIT_ACTION_TOGGLE_MINDSHIELD "toggle_mindshield"
#define CUSTOM_OUTFIT_ACTION_DENTAL_IMPLANT "dental_implant"
#define CUSTOM_OUTFIT_ACTION_CLICK "click"
#define CUSTOM_OUTFIT_ACTION_CLEAR "clear"

#define CUSTOM_OUTFIT_DEFAULT_NAME "Custom Outfit"
#define CUSTOM_OUTFIT_DEFAULT_COMPANY "Cybernetic"
#define CUSTOM_OUTFIT_DEFAULT_REAGENT_AMOUNT 5
#define CUSTOM_OUTFIT_MIN_REAGENT_AMOUNT 1
#define CUSTOM_OUTFIT_MAX_REAGENT_AMOUNT 100

/datum/custom_outfit
	var/mob/target_mob
	var/datum/outfit/edited_outfit
	var/list/external_augmentations = list()
	var/list/internal_augmentations = list()
	var/list/reagent_volumes = list()
	var/has_mindshield = FALSE
	var/backpack_dirty = FALSE
	var/dental_dirty = FALSE
	var/implants_dirty = FALSE
	var/augmentations_dirty = FALSE
	var/external_augmentations_dirty = FALSE
	var/internal_augmentations_dirty = FALSE
	var/mindshield_dirty = FALSE

	var/static/list/slot_to_human_var = list(
		"uniform" = "w_uniform",
		"suit" = "wear_suit",
		"back" = "back",
		"belt" = "belt",
		"gloves" = "gloves",
		"shoes" = "shoes",
		"head" = "head",
		"mask" = "wear_mask",
		"neck" = "neck",
		"l_ear" = "l_ear",
		"r_ear" = "r_ear",
		"glasses" = "glasses",
		"id" = "wear_id",
		"pda" = "wear_pda",
		"l_pocket" = "l_store",
		"r_pocket" = "r_store",
		"suit_store" = "s_store",
		"l_hand" = "l_hand",
		"r_hand" = "r_hand",
	)

	var/static/list/extra_outfit_vars = list(
		"box",
		"internals_slot",
		"toggle_helmet",
	)

	var/static/list/external_body_zones = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_R_FOOT,
	)

	var/static/list/slot_base_type = list(
		"head" = /obj/item/clothing/head,
		"glasses" = /obj/item/clothing/glasses,
		"l_ear" = /obj/item/radio/headset,
		"r_ear" = /obj/item/radio/headset,
		"neck" = /obj/item/clothing/neck,
		"mask" = /obj/item/clothing/mask,
		"uniform" = /obj/item/clothing/under,
		"suit" = /obj/item/clothing/suit,
		"gloves" = /obj/item/clothing/gloves,
		"shoes" = /obj/item/clothing/shoes,
		"belt" = /obj/item/storage/belt,
		"id" = /obj/item/card/id,
		"pda" = /obj/item/pda,
		"back" = /obj/item/storage/backpack,
	)

	var/static/list/slot_any_item = list(
		"suit_store",
		"l_hand",
		"r_hand",
		"l_pocket",
		"r_pocket",
	)

	var/static/list/internal_organ_options = list(
		"Глаза" = /obj/item/organ/internal/eyes/cybernetic,
		"Уши" = /obj/item/organ/internal/ears/cybernetic,
		"Сердце" = /obj/item/organ/internal/heart/cybernetic,
		"Лёгкие" = /obj/item/organ/internal/lungs/cybernetic,
		"Печень" = /obj/item/organ/internal/liver/cybernetic,
		"Почки" = /obj/item/organ/internal/kidneys/cybernetic,
	)

	var/static/list/type_option_cache = list()
	var/static/list/reagent_option_cache = list()

/datum/custom_outfit/New(mob/target_mob)
	src.target_mob = target_mob
	edited_outfit = new /datum/outfit
	edited_outfit.name = CUSTOM_OUTFIT_DEFAULT_NAME

	if(!ishuman(target_mob))
		return

	var/mob/living/carbon/human/human_target = target_mob
	capture_current_outfit(human_target)

/datum/custom_outfit/Destroy()
	target_mob = null

	if(edited_outfit)
		qdel(edited_outfit)
		edited_outfit = null

	external_augmentations.Cut()
	internal_augmentations.Cut()
	reagent_volumes.Cut()

	return ..()

/datum/custom_outfit/ui_state(mob/user)
	return ADMIN_STATE(R_EVENT)

/datum/custom_outfit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CustomOutfit")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/custom_outfit/ui_data(mob/user)
	var/list/data = list()

	data["outfit"] = serialize_outfit()
	data["backpack_items"] = serialize_backpack()
	data["implants"] = serialize_implants()
	data["augmentations"] = serialize_augmentations()
	data["mindshield"] = has_mindshield
	data["dental_reagents"] = serialize_reagents()
	data["has_dental_implant"] = length(reagent_volumes) > 0

	var/mob/living/carbon/human/human_target = target_mob
	if(!QDELETED(target_mob) && istype(human_target))
		data["target_name"] = human_target.name
		data["target_valid"] = TRUE
		data["backpack_is_storage"] = isstorage(human_target.back)
	else
		data["target_name"] = null
		data["target_valid"] = FALSE
		data["backpack_is_storage"] = FALSE

	return data

/datum/custom_outfit/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = FALSE

	var/mob/user = ui.user
	if(!user)
		return TRUE

	switch(action)
		if(CUSTOM_OUTFIT_ACTION_LOAD)
			to_chat(user, span_warning("Load is not implemented yet."))
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_COPY)
			to_chat(user, span_warning("Copy is not implemented yet."))
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_SAVE)
			to_chat(user, span_warning("Save is not implemented yet."))
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_APPLY)
			apply_outfit(user)
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_ADD_IMPLANT)
			if(choose_implant(user))
				implants_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_REMOVE_IMPLANT)
			var/path_text = params["path"]
			if(!path_text)
				path_text = params["ref"]

			var/implant_path = text2path(path_text)
			if(implant_path)
				edited_outfit.implants -= implant_path
				edited_outfit.cybernetic_implants -= implant_path
				implants_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_ADD_BACKPACK_ITEM)
			if(choose_backpack_item(user))
				backpack_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_REMOVE_ITEM)
			var/path_text = params["path"]
			if(!path_text)
				path_text = params["ref"]

			var/item_path = text2path(path_text)
			if(remove_backpack_item(item_path))
				backpack_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_ADD_AUGMENTATION)
			if(choose_augmentation(user))
				augmentations_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_REMOVE_AUGMENTATION)
			if(remove_augmentation(params["zone"]))
				augmentations_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_TOGGLE_MINDSHIELD)
			has_mindshield = !has_mindshield
			mindshield_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_DENTAL_IMPLANT)
			if(length(reagent_volumes))
				reagent_volumes = list()
				dental_dirty = TRUE
			else if(build_dental_pill(user))
				dental_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_CLICK)
			choose_item(user, params["slot"])
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_CLEAR)
			clear_slot(params["slot"])
			. = TRUE

	if(. && !QDELETED(ui))
		SStgui.try_update_ui(user, src, ui)

	return .

/datum/custom_outfit/proc/capture_current_outfit(mob/living/carbon/human/human_target)
	for(var/outfit_slot in slot_to_human_var)
		var/human_slot = slot_to_human_var[outfit_slot]
		var/obj/item/equipped_item = human_target.vars[human_slot]

		if(!equipped_item)
			continue

		edited_outfit.vars[outfit_slot] = equipped_item.type

	capture_backpack(human_target)
	capture_implants(human_target)
	capture_augmentations(human_target)

	has_mindshield = ismindshielded(human_target)

/datum/custom_outfit/proc/capture_backpack(mob/living/carbon/human/human_target)
	if(!isstorage(human_target.back))
		return

	for(var/obj/item/backpack_item in human_target.back.contents)
		edited_outfit.backpack_contents[backpack_item.type] = (edited_outfit.backpack_contents[backpack_item.type] || 0) + 1

/datum/custom_outfit/proc/capture_implants(mob/living/carbon/human/human_target)
	for(var/obj/item/implant/implant in human_target.contents)
		if(istype(implant, /obj/item/implant/mindshield))
			continue

		if(!(implant.type in edited_outfit.implants))
			edited_outfit.implants += implant.type

	for(var/obj/item/organ/internal/cyberimp/cyberimp_organ in human_target.internal_organs)
		if(!(cyberimp_organ.type in edited_outfit.cybernetic_implants))
			edited_outfit.cybernetic_implants += cyberimp_organ.type

/datum/custom_outfit/proc/capture_augmentations(mob/living/carbon/human/human_target)
	for(var/body_zone in external_body_zones)
		var/obj/item/organ/external/limb = human_target.get_organ(body_zone)
		if(limb && limb.is_robotic())
			external_augmentations[body_zone] = limb.model

	for(var/obj/item/organ/internal/organ in human_target.internal_organs)
		if(istype(organ, /obj/item/organ/internal/cyberimp))
			continue

		if(!organ.is_robotic())
			continue

		internal_augmentations[organ.type] = TRUE

/datum/custom_outfit/proc/serialize_outfit()
	var/list/data = list()

	for(var/outfit_slot in slot_to_human_var)
		data[outfit_slot] = entry(edited_outfit.vars[outfit_slot])

	data["name"] = edited_outfit.name
	return data

/datum/custom_outfit/proc/serialize_backpack()
	. = list()

	for(var/item_path in edited_outfit.backpack_contents)
		var/count = edited_outfit.backpack_contents[item_path]
		if(!ispath(item_path, /obj/item) || !isnum(count) || count <= 0)
			continue

		var/list/item_data = entry(item_path)
		if(!islist(item_data))
			continue

		item_data["count"] = count
		. += list(item_data)

/datum/custom_outfit/proc/serialize_implants()
	. = list()

	for(var/implant_path in edited_outfit.implants)
		. += list(entry(implant_path))

	for(var/cyberimp_path in edited_outfit.cybernetic_implants)
		. += list(entry(cyberimp_path))

/datum/custom_outfit/proc/serialize_augmentations()
	. = list()

	for(var/body_zone in external_augmentations)
		var/model = external_augmentations[body_zone]
		var/datum/robolimb/robolimb = GLOB.all_robolimbs[model]
		var/company = robolimb ? robolimb.company : CUSTOM_OUTFIT_DEFAULT_COMPANY

		. += list(list(
			"zone" = body_zone,
			"zone_name" = parse_zone(body_zone),
			"model" = model,
			"company" = company,
			"kind" = "external",
		))

	for(var/organ_path in internal_augmentations)
		if(!ispath(organ_path, /obj/item/organ/internal))
			continue

		var/obj/item/organ/internal/organ_ref = organ_path

		. += list(list(
			"zone" = "[organ_path]",
			"zone_name" = initial(organ_ref.name),
			"model" = null,
			"company" = CUSTOM_OUTFIT_DEFAULT_COMPANY,
			"kind" = "internal",
		))

/datum/custom_outfit/proc/serialize_reagents()
	. = list()

	for(var/reagent_path in reagent_volumes)
		var/amount = reagent_volumes[reagent_path]
		if(!ispath(reagent_path, /datum/reagent) || !isnum(amount) || amount <= 0)
			continue

		var/datum/reagent/reagent_ref = reagent_path

		. += list(list(
			"name" = initial(reagent_ref.name),
			"amount" = amount,
		))

/datum/custom_outfit/proc/entry(data)
	if(ispath(data, /obj/item))
		var/obj/item/item_path = data
		return list(
			"path" = "[item_path]",
			"name" = initial(item_path.name),
			"desc" = initial(item_path.desc),
			"icon" = initial(item_path.icon),
			"icon_state" = initial(item_path.icon_state),
		)

	return data

/datum/custom_outfit/proc/make_final_outfit(preserve_implants = FALSE)
	var/datum/outfit/final_outfit = new edited_outfit.type
	copy_outfit(edited_outfit, final_outfit)

	if(!implants_dirty && !preserve_implants)
		final_outfit.implants.Cut()
		final_outfit.cybernetic_implants.Cut()
	else
		final_outfit.implants -= /obj/item/implant/mindshield

	return final_outfit

/datum/custom_outfit/proc/copy_outfit(datum/outfit/source, datum/outfit/destination)
	destination.name = source.name

	for(var/outfit_slot in slot_to_human_var)
		destination.vars[outfit_slot] = source.vars[outfit_slot]

	for(var/extra_var in extra_outfit_vars)
		destination.vars[extra_var] = source.vars[extra_var]

	destination.backpack_contents = source.backpack_contents ? source.backpack_contents.Copy() : list()
	destination.implants = source.implants ? source.implants.Copy() : list()
	destination.cybernetic_implants = source.cybernetic_implants ? source.cybernetic_implants.Copy() : list()
	destination.accessories = source.accessories ? source.accessories.Copy() : list()

/datum/custom_outfit/proc/apply_outfit(mob/user)
	if(QDELETED(target_mob) || !ishuman(target_mob))
		to_chat(user, span_warning("Target is no longer valid."))
		return

	var/mob/living/carbon/human/human_target = target_mob
	if(!human_target.dna || !human_target.dna.species)
		to_chat(user, span_warning("Target has no valid DNA or species."))
		return

	var/needs_organ_rebuild = implants_dirty || augmentations_dirty || internal_augmentations_dirty || external_augmentations_dirty
	var/datum/outfit/final_outfit = make_final_outfit(preserve_implants = needs_organ_rebuild)
	var/list/new_backpack_contents = final_outfit.backpack_contents.Copy()
	var/kept_existing_back = strip_unchanged_equipment(human_target, final_outfit)

	if(needs_organ_rebuild)
		remove_existing_implants(human_target)
		remove_existing_cyberimplants(human_target)
		human_target.dna.species.create_organs(human_target)
		apply_internal_augmentations(human_target)
		apply_external_augmentations(human_target)

	human_target.equipOutfit(final_outfit)

	if(kept_existing_back && backpack_dirty)
		sync_existing_backpack(human_target, new_backpack_contents)

	if(needs_organ_rebuild || mindshield_dirty)
		apply_mindshield(human_target)

	if(dental_dirty)
		apply_reagent_pill(human_target)

	backpack_dirty = FALSE
	dental_dirty = FALSE
	implants_dirty = FALSE
	augmentations_dirty = FALSE
	external_augmentations_dirty = FALSE
	internal_augmentations_dirty = FALSE
	mindshield_dirty = FALSE

	human_target.regenerate_icons()
	log_and_message_admins("[key_name_admin(user)] changed equipment of [key_name_admin(human_target)] via Custom Outfit.")

/datum/custom_outfit/proc/strip_unchanged_equipment(mob/living/carbon/human/human_target, datum/outfit/final_outfit)
	var/kept_existing_back = FALSE

	for(var/outfit_slot in slot_to_human_var)
		var/human_slot = slot_to_human_var[outfit_slot]
		var/obj/item/current_item = human_target.vars[human_slot]

		if(!current_item)
			continue

		var/outfit_path = final_outfit.vars[outfit_slot]

		if(outfit_path && current_item.type == outfit_path)
			final_outfit.vars[outfit_slot] = null

			if(outfit_slot == "back")
				kept_existing_back = TRUE
				final_outfit.box = null
				final_outfit.backpack_contents = list()

			continue

		if(outfit_slot == "back")
			if(!outfit_path || !ispath(outfit_path, /obj/item/storage))
				final_outfit.backpack_contents = list()
			else if(!backpack_dirty)
				final_outfit.backpack_contents = list()

		qdel(current_item)

	return kept_existing_back

/datum/custom_outfit/proc/sync_existing_backpack(mob/living/carbon/human/human_target, list/new_backpack_contents)
	if(!isstorage(human_target.back))
		return

	QDEL_LIST(human_target.back.contents)

	for(var/item_path in new_backpack_contents)
		var/count = new_backpack_contents[item_path]
		if(!ispath(item_path, /obj/item) || !isnum(count) || count <= 0)
			continue

		for(var/iteration in 1 to count)
			new item_path(human_target.back)

/datum/custom_outfit/proc/remove_existing_implants(mob/living/carbon/human/human_target)
	for(var/obj/item/implant/implant in human_target.contents.Copy())
		implant.removed(human_target)
		qdel(implant)

/datum/custom_outfit/proc/remove_existing_cyberimplants(mob/living/carbon/human/human_target)
	for(var/obj/item/organ/internal/cyberimp/cyberimp_organ in human_target.internal_organs.Copy())
		cyberimp_organ.remove(human_target, ORGAN_MANIPULATION_NOEFFECT)
		qdel(cyberimp_organ)

/datum/custom_outfit/proc/apply_augmentations(mob/living/carbon/human/human_target)
	if(!augmentations_dirty)
		return

	apply_external_augmentations(human_target)
	apply_internal_augmentations(human_target)

/datum/custom_outfit/proc/apply_external_augmentations(mob/living/carbon/human/human_target)
	for(var/body_zone in external_augmentations)
		var/model = external_augmentations[body_zone]
		var/obj/item/organ/external/limb = human_target.get_organ(body_zone)

		if(!limb)
			continue

		if(!limb.is_robotic() || limb.model != model)
			limb.robotize(company = model, convert_all = FALSE)

/datum/custom_outfit/proc/apply_internal_augmentations(mob/living/carbon/human/human_target)
	for(var/organ_path in internal_augmentations)
		if(!ispath(organ_path, /obj/item/organ/internal))
			continue

		new organ_path(human_target)

/datum/custom_outfit/proc/apply_mindshield(mob/living/carbon/human/human_target)
	if(has_mindshield)
		if(!ismindshielded(human_target))
			var/obj/item/implant/mindshield/mindshield_implant = new /obj/item/implant/mindshield(human_target)
			mindshield_implant.implant(human_target)
		return

	for(var/obj/item/implant/mindshield/mindshield_implant in human_target.contents)
		qdel(mindshield_implant)

/datum/custom_outfit/proc/apply_reagent_pill(mob/living/carbon/human/human_target)
	for(var/obj/item/reagent_containers/food/pill/old_pill in human_target.contents)
		qdel(old_pill)

	if(!length(reagent_volumes))
		return

	var/obj/item/reagent_containers/food/pill/pill = new /obj/item/reagent_containers/food/pill(human_target)
	var/total_volume = 0

	for(var/reagent_path in reagent_volumes)
		var/amount = reagent_volumes[reagent_path]
		if(!ispath(reagent_path, /datum/reagent) || !isnum(amount) || amount <= 0)
			continue

		total_volume += amount

	if(total_volume <= 0)
		return

	if(total_volume > pill.reagents.maximum_volume)
		pill.reagents.maximum_volume = total_volume

	for(var/reagent_path in reagent_volumes)
		var/amount = reagent_volumes[reagent_path]
		if(!ispath(reagent_path, /datum/reagent) || !isnum(amount) || amount <= 0)
			continue

		pill.reagents.add_reagent(reagent_path, amount)

	var/datum/action/item_action/hands_free/activate_pill/pill_action = new(pill, pill.icon, pill.icon_state)
	pill_action.name = "Раскусить [pill.declent_ru(ACCUSATIVE)]"
	pill_action.Grant(human_target)

/datum/custom_outfit/proc/choose_backpack_item(mob/user)
	if(QDELETED(target_mob) || !ishuman(target_mob))
		to_chat(user, span_warning("Target is no longer valid."))
		return FALSE

	var/mob/living/carbon/human/human_target = target_mob
	if(!isstorage(human_target.back))
		to_chat(user, span_warning("Target does not have a storage back item."))
		return FALSE

	var/obj/item/chosen_path = pick_closest_path(FALSE)
	if(QDELETED(src) || QDELETED(user) || QDELETED(target_mob) || !ishuman(target_mob))
		return FALSE

	if(!ispath(chosen_path, /obj/item))
		return FALSE

	edited_outfit.backpack_contents[chosen_path] = (edited_outfit.backpack_contents[chosen_path] || 0) + 1
	return TRUE

/datum/custom_outfit/proc/remove_backpack_item(item_path)
	if(!item_path)
		return FALSE

	if(!(item_path in edited_outfit.backpack_contents))
		return FALSE

	var/count = edited_outfit.backpack_contents[item_path]
	if(!isnum(count))
		edited_outfit.backpack_contents -= item_path
		return TRUE

	count -= 1

	if(count <= 0)
		edited_outfit.backpack_contents -= item_path
	else
		edited_outfit.backpack_contents[item_path] = count

	return TRUE

/datum/custom_outfit/proc/choose_implant(mob/user)
	var/list/options = get_type_options(/obj/item/organ/internal/cyberimp)
	if(!length(options))
		to_chat(user, span_warning("No implants found."))
		return FALSE

	var/choice = tgui_input_list(user, "Choose an implant", "Custom Outfit", options)
	if(QDELETED(src) || QDELETED(user))
		return FALSE

	if(isnull(choice))
		return FALSE

	var/implant_path = options[choice]
	if(!ispath(implant_path, /obj/item/organ/internal/cyberimp))
		return FALSE

	if(implant_path in edited_outfit.cybernetic_implants)
		return FALSE

	edited_outfit.cybernetic_implants += implant_path
	return TRUE

/datum/custom_outfit/proc/choose_augmentation(mob/user)
	var/list/type_options = list(
		"Внешняя часть",
		"Внутренний орган",
	)

	var/type_choice = tgui_input_list(user, "Выберите тип аугментации", "Аугментация", type_options)
	if(QDELETED(src) || QDELETED(user))
		return FALSE

	if(!type_choice)
		return FALSE

	if(type_choice == "Внешняя часть")
		return choose_external_augmentation(user)

	return choose_internal_augmentation(user)

/datum/custom_outfit/proc/choose_external_augmentation(mob/user)
	var/list/zone_options = list()

	for(var/body_zone in external_body_zones)
		zone_options[parse_zone(body_zone)] = body_zone

	if(!length(zone_options))
		return FALSE

	var/zone_choice = tgui_input_list(user, "Выберите часть тела", "Аугментация", zone_options)
	if(QDELETED(src) || QDELETED(user))
		return FALSE

	if(!zone_choice)
		return FALSE

	var/body_zone = zone_options[zone_choice]
	if(!body_zone)
		return FALSE

	var/list/companies = list()

	for(var/company in GLOB.all_robolimbs)
		var/datum/robolimb/robolimb = GLOB.all_robolimbs[company]
		if(!robolimb.has_subtypes)
			continue

		if(!(body_zone in robolimb.parts))
			continue

		companies[company] = robolimb

	if(!length(companies))
		to_chat(user, span_warning("No augmentations available for this body part."))
		return FALSE

	var/company_choice = tgui_input_list(user, "Выберите фирму-изготовителя", "Аугментация", companies)
	if(QDELETED(src) || QDELETED(user))
		return FALSE

	if(!company_choice)
		return FALSE

	var/datum/robolimb/selected_limb = companies[company_choice]
	if(!selected_limb)
		return FALSE

	external_augmentations[body_zone] = selected_limb.company
	return TRUE

/datum/custom_outfit/proc/choose_internal_augmentation(mob/user)
	if(!length(internal_organ_options))
		return FALSE

	var/organ_choice = tgui_input_list(user, "Выберите орган", "Аугментация", internal_organ_options)
	if(QDELETED(src) || QDELETED(user))
		return FALSE

	if(!organ_choice)
		return FALSE

	var/cyber_base_path = internal_organ_options[organ_choice]
	if(!ispath(cyber_base_path, /obj/item/organ/internal))
		return FALSE

	var/list/organ_paths = list()

	for(var/organ_path in typesof(cyber_base_path))
		if(!ispath(organ_path, /obj/item/organ/internal))
			continue

		var/obj/item/organ/internal/organ_ref = organ_path
		var/organ_name = initial(organ_ref.name)

		if(!organ_name)
			continue

		organ_paths["[organ_name] ([organ_path])"] = organ_path

	if(!length(organ_paths))
		to_chat(user, span_warning("No cybernetic variants found for this organ."))
		return FALSE

	var/variant_choice = tgui_input_list(user, "Выберите вариант", "Аугментация", organ_paths)
	if(QDELETED(src) || QDELETED(user))
		return FALSE

	if(!variant_choice)
		return FALSE

	var/organ_path = organ_paths[variant_choice]
	if(!ispath(organ_path, /obj/item/organ/internal))
		return FALSE

	internal_augmentations[organ_path] = TRUE
	internal_augmentations_dirty = TRUE
	augmentations_dirty = TRUE
	return TRUE

/datum/custom_outfit/proc/remove_augmentation(zone_text)
	if(!zone_text)
		return FALSE

	var/organ_path = text2path(zone_text)

	if(organ_path && (organ_path in internal_augmentations))
		internal_augmentations -= organ_path
		internal_augmentations_dirty = TRUE
		augmentations_dirty = TRUE
		return TRUE

	if(zone_text in external_augmentations)
		external_augmentations -= zone_text
		external_augmentations_dirty = TRUE
		augmentations_dirty = TRUE
		return TRUE

	return FALSE

/datum/custom_outfit/proc/build_dental_pill(mob/user)
	var/list/reagent_options = get_reagent_options()
	if(!length(reagent_options))
		to_chat(user, span_warning("No reagents found."))
		return FALSE

	var/changed = FALSE

	while(TRUE)
		var/choice = tgui_input_list(user, "Выберите реагент", "Зубной имплант", reagent_options)
		if(QDELETED(src) || QDELETED(user))
			return FALSE

		if(!choice)
			break

		var/reagent_path = reagent_options[choice]
		if(!ispath(reagent_path, /datum/reagent))
			continue

		var/amount = tgui_input_number(
			user,
			"Введите количество реагента (макс. [CUSTOM_OUTFIT_MAX_REAGENT_AMOUNT])",
			"Количество",
			CUSTOM_OUTFIT_DEFAULT_REAGENT_AMOUNT,
			CUSTOM_OUTFIT_MAX_REAGENT_AMOUNT,
			CUSTOM_OUTFIT_MIN_REAGENT_AMOUNT,
		)

		if(QDELETED(src) || QDELETED(user))
			return FALSE

		if(!amount)
			continue

		reagent_volumes[reagent_path] = amount
		changed = TRUE

		var/again = tgui_alert(user, "Добавить ещё реагент?", "Зубной имплант", list("Добавить ещё", "Закончить"))
		if(QDELETED(src) || QDELETED(user))
			return FALSE

		if(again != "Добавить ещё")
			break

	return changed

/datum/custom_outfit/proc/get_reagent_options()
	if(length(reagent_option_cache))
		return reagent_option_cache

	var/list/options = list()

	for(var/datum/reagent/reagent_path as anything in subtypesof(/datum/reagent))
		var/datum/reagent/reagent_ref = reagent_path
		var/reagent_name = initial(reagent_ref.name)

		if(!reagent_name)
			continue

		options["[reagent_name] ([reagent_path])"] = reagent_path

	reagent_option_cache = options
	return reagent_option_cache

/datum/custom_outfit/proc/choose_item(mob/user, slot)
	if(!(slot in slot_to_human_var))
		return FALSE

	if(slot in slot_any_item)
		return choose_any_item(user, slot)

	var/base_type = slot_base_type[slot]
	if(!base_type)
		return choose_any_item(user, slot)

	var/list/options = get_type_options(base_type)
	if(!length(options))
		return choose_any_item(user, slot)

	var/choice = tgui_input_list(user, "Choose an item", "Custom Outfit", options)
	if(QDELETED(src) || QDELETED(user))
		return FALSE

	if(isnull(choice))
		return FALSE

	var/item_path = options[choice]
	return set_item(user, slot, item_path)

/datum/custom_outfit/proc/choose_any_item(mob/user, slot)
	var/obj/item/chosen_path = pick_closest_path(FALSE)
	if(QDELETED(src) || QDELETED(user))
		return FALSE

	return set_item(user, slot, chosen_path)

/datum/custom_outfit/proc/set_item(mob/user, slot, obj/item/choice)
	if(!(slot in slot_to_human_var))
		return FALSE

	if(!ispath(choice, /obj/item))
		tgui_alert(user, "Invalid item", "Custom Outfit", list("OK"))
		return FALSE

	var/base_type = slot_base_type[slot]
	if(base_type && !(slot in slot_any_item) && !ispath(choice, base_type))
		var/confirm_choice = tgui_alert(user, "This item may not fit the selected slot.", "Custom Outfit", list("Use anyway", "Cancel"))
		if(QDELETED(src) || QDELETED(user))
			return FALSE

		if(confirm_choice != "Use anyway")
			return FALSE

	if(initial(choice.icon_state) == null)
		var/confirm_choice = tgui_alert(user, "Warning: This item's icon_state is null, indicating it is very probably not actually a usable item.", "Custom Outfit", list("Use anyway", "Cancel"))
		if(QDELETED(src) || QDELETED(user))
			return FALSE

		if(confirm_choice != "Use anyway")
			return FALSE

	edited_outfit.vars[slot] = choice

	if(slot == "back")
		backpack_dirty = TRUE
		if(!ispath(choice, /obj/item/storage))
			edited_outfit.backpack_contents.Cut()

	return TRUE

/datum/custom_outfit/proc/clear_slot(slot)
	if(!(slot in slot_to_human_var))
		return FALSE

	edited_outfit.vars[slot] = null

	if(slot == "back")
		backpack_dirty = TRUE
		edited_outfit.backpack_contents.Cut()

	return TRUE

/datum/custom_outfit/proc/get_type_options(base_type)
	if(!base_type)
		return list()

	if(base_type in type_option_cache)
		return type_option_cache[base_type]

	var/list/options = list()

	for(var/thing_path in subtypesof(base_type))
		var/obj/item/item_ref = thing_path
		var/thing_name = initial(item_ref.name)

		if(!thing_name)
			continue

		options["[thing_name] ([thing_path])"] = thing_path

	type_option_cache[base_type] = options
	return options

#undef CUSTOM_OUTFIT_ACTION_LOAD
#undef CUSTOM_OUTFIT_ACTION_COPY
#undef CUSTOM_OUTFIT_ACTION_SAVE
#undef CUSTOM_OUTFIT_ACTION_APPLY
#undef CUSTOM_OUTFIT_ACTION_ADD_IMPLANT
#undef CUSTOM_OUTFIT_ACTION_REMOVE_IMPLANT
#undef CUSTOM_OUTFIT_ACTION_ADD_BACKPACK_ITEM
#undef CUSTOM_OUTFIT_ACTION_REMOVE_ITEM
#undef CUSTOM_OUTFIT_ACTION_ADD_AUGMENTATION
#undef CUSTOM_OUTFIT_ACTION_REMOVE_AUGMENTATION
#undef CUSTOM_OUTFIT_ACTION_TOGGLE_MINDSHIELD
#undef CUSTOM_OUTFIT_ACTION_DENTAL_IMPLANT
#undef CUSTOM_OUTFIT_ACTION_CLICK
#undef CUSTOM_OUTFIT_ACTION_CLEAR

#undef CUSTOM_OUTFIT_DEFAULT_NAME
#undef CUSTOM_OUTFIT_DEFAULT_COMPANY
#undef CUSTOM_OUTFIT_DEFAULT_REAGENT_AMOUNT
#undef CUSTOM_OUTFIT_MIN_REAGENT_AMOUNT
#undef CUSTOM_OUTFIT_MAX_REAGENT_AMOUNT
