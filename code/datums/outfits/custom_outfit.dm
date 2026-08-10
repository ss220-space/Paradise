#define CUSTOM_OUTFIT_SAVE_FORMAT "ss1984_custom_outfit"
#define CUSTOM_OUTFIT_SAVE_VERSION 1

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
	var/body_dirty = FALSE
	var/backpack_dirty = FALSE
	var/dental_dirty = FALSE
	var/cached_preview_icon
	var/cached_preview_key
	var/preview_dirty = TRUE

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

	var/static/list/slot_to_item_flag = list(
		"uniform" = ITEM_SLOT_CLOTH_INNER,
		"suit" = ITEM_SLOT_CLOTH_OUTER,
		"back" = ITEM_SLOT_BACK,
		"belt" = ITEM_SLOT_BELT,
		"gloves" = ITEM_SLOT_GLOVES,
		"shoes" = ITEM_SLOT_FEET,
		"head" = ITEM_SLOT_HEAD,
		"mask" = ITEM_SLOT_MASK,
		"neck" = ITEM_SLOT_NECK,
		"l_ear" = ITEM_SLOT_EAR_LEFT,
		"r_ear" = ITEM_SLOT_EAR_RIGHT,
		"glasses" = ITEM_SLOT_EYES,
		"id" = ITEM_SLOT_ID,
		"pda" = ITEM_SLOT_PDA,
		"l_pocket" = ITEM_SLOT_POCKET_LEFT,
		"r_pocket" = ITEM_SLOT_POCKET_RIGHT,
		"suit_store" = ITEM_SLOT_SUITSTORE,
		"l_hand" = ITEM_SLOT_HAND_LEFT,
		"r_hand" = ITEM_SLOT_HAND_RIGHT,
	)

	var/static/list/slot_holders = list(
		"uniform",
		"suit",
		"back",
		"belt",
	)

	var/static/list/slot_dependents = list(
		"uniform" = list("l_pocket", "r_pocket", "id", "pda", "belt"),
		"suit" = list("suit_store"),
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
	data["dental_reagents"] = serialize_reagents()
	data["has_dental_implant"] = length(reagent_volumes) > 0

	if(!QDELETED(target_mob) && ishuman(target_mob))
		var/mob/living/carbon/human/human_target = target_mob
		data["target_name"] = human_target.name
		data["target_valid"] = TRUE
		data["backpack_is_storage"] = isstorage(human_target.back)

		var/appearance_key = build_appearance_key(human_target)
		if(preview_dirty || appearance_key != cached_preview_key)
			cached_preview_icon = generate_preview_icon()
			cached_preview_key = appearance_key
			preview_dirty = FALSE
		if(cached_preview_icon)
			data["preview_icon"] = cached_preview_icon
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
			load_from_file(user)
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_COPY)
			to_chat(user, span_warning("Copy is not implemented yet."))
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_SAVE)
			save_to_file(user)
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_APPLY)
			apply_outfit(user)
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_ADD_IMPLANT)
			if(choose_implant(user))
				body_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_REMOVE_IMPLANT)
			var/path_text = params["path"]
			if(!path_text)
				path_text = params["ref"]
			var/implant_path = text2path(path_text)
			if(implant_path && ((implant_path in edited_outfit.implants) || (implant_path in edited_outfit.cybernetic_implants)))
				edited_outfit.implants -= implant_path
				edited_outfit.cybernetic_implants -= implant_path
				body_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_ADD_BACKPACK_ITEM)
			if(choose_backpack_item(user))
				backpack_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_REMOVE_ITEM)
			var/path_text = params["path"]
			if(!path_text)
				path_text = params["ref"]
			if(remove_backpack_item(text2path(path_text)))
				backpack_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_ADD_AUGMENTATION)
			if(choose_augmentation(user))
				body_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_REMOVE_AUGMENTATION)
			if(remove_augmentation(params["zone"]))
				body_dirty = TRUE
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
		preview_dirty = TRUE
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

/datum/custom_outfit/proc/capture_backpack(mob/living/carbon/human/human_target)
	if(!isstorage(human_target.back))
		return
	for(var/obj/item/backpack_item in human_target.back.contents)
		edited_outfit.backpack_contents[backpack_item.type] = (edited_outfit.backpack_contents[backpack_item.type] || 0) + 1

/datum/custom_outfit/proc/capture_implants(mob/living/carbon/human/human_target)
	for(var/obj/item/implant/implant in human_target.contents)
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
		if(organ.is_robotic())
			internal_augmentations[organ.type] = TRUE

/datum/custom_outfit/proc/serialize_outfit()
	var/list/outfit_data = edited_outfit.get_json_data()
	. = list()
	for(var/slot in outfit_data)
		.[slot] = entry(outfit_data[slot])

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
	final_outfit.copy_from(edited_outfit)
	if(!preserve_implants)
		final_outfit.implants.Cut()
		final_outfit.cybernetic_implants.Cut()
	return final_outfit

/datum/custom_outfit/proc/apply_outfit(mob/user)
	if(QDELETED(target_mob) || !ishuman(target_mob))
		to_chat(user, span_warning("Target is no longer valid."))
		return
	var/mob/living/carbon/human/human_target = target_mob
	if(!human_target.dna || !human_target.dna.species)
		to_chat(user, span_warning("Target has no valid DNA or species."))
		return

	var/datum/outfit/final_outfit = make_final_outfit(preserve_implants = body_dirty)
	var/list/new_backpack_contents = edited_outfit.backpack_contents.Copy()
	var/list/stashed_items = list()
	var/list/to_delete = list()
	var/kept_existing_back = prepare_equipment(human_target, final_outfit, stashed_items, to_delete)
	delete_replaced_equipment(human_target, to_delete)

	if(body_dirty)
		remove_existing_implants(human_target)
		remove_existing_cyberimplants(human_target)
		human_target.dna.species.create_organs(human_target)
		apply_internal_augmentations(human_target)
		apply_external_augmentations(human_target)

	human_target.equipOutfit(final_outfit)
	restore_stashed_items(human_target, stashed_items)

	if(kept_existing_back && backpack_dirty)
		sync_existing_backpack(human_target, new_backpack_contents)

	if(dental_dirty)
		apply_reagent_pill(human_target)

	body_dirty = FALSE
	backpack_dirty = FALSE
	dental_dirty = FALSE

	human_target.regenerate_icons()
	log_and_message_admins("[key_name_admin(user)] changed equipment of [key_name_admin(human_target)] via Custom Outfit.")

/datum/custom_outfit/proc/prepare_equipment(mob/living/carbon/human/human_target, datum/outfit/final_outfit, list/stashed_items, list/to_delete)
	var/kept_existing_back = FALSE
	var/list/replaced_holders = list()

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

		to_delete += outfit_slot

		if(outfit_slot == "back")
			if(!outfit_path || !ispath(outfit_path, /obj/item/storage))
				final_outfit.backpack_contents = list()

		if(outfit_slot in slot_holders)
			replaced_holders += outfit_slot

	for(var/holder_slot in replaced_holders)
		var/list/dependents = slot_dependents[holder_slot]
		if(!dependents)
			continue
		for(var/dependent_slot in dependents)
			var/obj/item/dependent_item = human_target.vars[slot_to_human_var[dependent_slot]]
			if(QDELETED(dependent_item))
				continue
			var/dependent_path = edited_outfit.vars[dependent_slot]
			if(!dependent_path || dependent_item.type != dependent_path)
				if(!(dependent_slot in to_delete))
					to_delete += dependent_slot
				continue
			human_target.temporarily_remove_item_from_inventory(dependent_item, force = TRUE)
			dependent_item.forceMove(null)
			stashed_items[dependent_slot] = dependent_item

	return kept_existing_back

/datum/custom_outfit/proc/delete_replaced_equipment(mob/living/carbon/human/human_target, list/to_delete)
	for(var/outfit_slot in to_delete)
		if(outfit_slot in slot_holders)
			continue
		delete_slot_item(human_target, outfit_slot)
	for(var/holder_slot in slot_holders)
		if(holder_slot in to_delete)
			delete_slot_item(human_target, holder_slot)

/datum/custom_outfit/proc/delete_slot_item(mob/living/carbon/human/human_target, outfit_slot)
	var/obj/item/current_item = human_target.vars[slot_to_human_var[outfit_slot]]
	if(QDELETED(current_item))
		return
	if(outfit_slot == "back" && isstorage(current_item))
		QDEL_LIST(current_item.contents)
	qdel(current_item)

/datum/custom_outfit/proc/restore_stashed_items(mob/living/carbon/human/human_target, list/stashed_items)
	for(var/outfit_slot in slot_to_human_var)
		var/obj/item/stashed_item = stashed_items[outfit_slot]
		if(QDELETED(stashed_item))
			continue
		var/human_slot = slot_to_human_var[outfit_slot]
		if(human_target.vars[human_slot])
			continue
		human_target.equip_to_slot(stashed_item, slot_to_item_flag[outfit_slot], TRUE)
		if(human_target.vars[human_slot] != stashed_item)
			stashed_item.forceMove(human_target.loc)

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

/datum/custom_outfit/proc/generate_preview_icon()
	if(QDELETED(target_mob) || !ishuman(target_mob))
		return null
	var/mob/living/carbon/human/human_target = target_mob
	if(!human_target.dna || !human_target.dna.species)
		return null
	var/mob/living/carbon/human/dummy = new human_target.type
	if(!dummy)
		return null

	copy_appearance(human_target, dummy)

	var/datum/outfit/final_outfit = make_final_outfit(preserve_implants = TRUE)
	if(length(internal_augmentations))
		apply_internal_augmentations(dummy)
	if(length(external_augmentations))
		apply_external_augmentations(dummy)
	dummy.equipOutfit(final_outfit)
	dummy.regenerate_icons()

	var/icon/flat_icon = getFlatIcon(dummy, SOUTH, null, null, null, TRUE, TRUE)
	if(!flat_icon)
		qdel(dummy)
		return null
	var/base64_string = icon2base64(flat_icon)
	qdel(dummy)
	return base64_string

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
	var/list/type_options = list(
		"Кибер-имплант",
		"Био-имплант",
	)
	var/type_choice = tgui_input_list(user, "Выберите тип импланта", "Имплант", type_options)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(!type_choice)
		return FALSE
	if(type_choice == "Кибер-имплант")
		return choose_cyber_implant(user)
	return choose_bio_implant(user)

/datum/custom_outfit/proc/choose_cyber_implant(mob/user)
	var/list/options = list()
	for(var/implant_path in subtypesof(/obj/item/organ/internal/cyberimp))
		var/obj/item/organ/internal/cyberimp/implant_ref = implant_path
		var/implant_name = initial(implant_ref.name)
		if(!implant_name)
			continue
		options["[implant_name] ([implant_path])"] = implant_path
	if(!length(options))
		to_chat(user, span_warning("No cybernetic implants found."))
		return FALSE
	var/choice = tgui_input_list(user, "Choose a cybernetic implant", "Custom Outfit", options)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(isnull(choice))
		return FALSE
	var/implant_path = options[choice]
	if(!ispath(implant_path, /obj/item/organ/internal/cyberimp))
		return FALSE
	if(implant_path in edited_outfit.cybernetic_implants)
		to_chat(user, span_warning("This cybernetic implant is already installed."))
		return FALSE
	edited_outfit.cybernetic_implants += implant_path
	return TRUE

/datum/custom_outfit/proc/choose_bio_implant(mob/user)
	var/list/options = list()
	for(var/implant_path in subtypesof(/obj/item/implant))
		var/obj/item/implant/implant_ref = implant_path
		var/implant_name = initial(implant_ref.name)
		if(!implant_name)
			continue
		options["[implant_name] ([implant_path])"] = implant_path
	if(!length(options))
		to_chat(user, span_warning("No bio-implants found."))
		return FALSE
	var/choice = tgui_input_list(user, "Choose a bio-implant", "Custom Outfit", options)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(isnull(choice))
		return FALSE
	var/implant_path = options[choice]
	if(!ispath(implant_path, /obj/item/implant))
		return FALSE
	if(implant_path in edited_outfit.implants)
		to_chat(user, span_warning("This bio-implant is already installed."))
		return FALSE
	edited_outfit.implants += implant_path
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
	return TRUE

/datum/custom_outfit/proc/remove_augmentation(zone_text)
	if(!zone_text)
		return FALSE
	var/organ_path = text2path(zone_text)
	if(organ_path && (organ_path in internal_augmentations))
		internal_augmentations -= organ_path
		return TRUE
	if(zone_text in external_augmentations)
		external_augmentations -= zone_text
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
	var/list/options = list()
	for(var/item_path in subtypesof(base_type))
		var/obj/item/item_ref = item_path
		var/item_name = initial(item_ref.name)
		if(!item_name)
			continue
		options["[item_name] ([item_path])"] = item_path
	if(!length(options))
		to_chat(user, span_warning("No valid items found for this slot."))
		return FALSE
	var/choice = tgui_input_list(user, "Choose an item", "Custom Outfit", options)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(isnull(choice))
		return FALSE
	return set_item(user, slot, options[choice])

/datum/custom_outfit/proc/choose_any_item(mob/user, slot)
	var/obj/item/chosen_path = pick_closest_path(FALSE)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	return set_item(user, slot, chosen_path)

/datum/custom_outfit/proc/set_item(mob/user, slot, obj/item/choice)
	if(!(slot in slot_to_human_var))
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
	if(!isnum(data["version"]) || data["version"] > CUSTOM_OUTFIT_SAVE_VERSION)
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
		var/model = external[zone]
		if(!(zone in external_body_zones) || !istext(model))
			continue
		new_external[zone] = model

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

/datum/custom_outfit/proc/sanitize_loaded_outfit(datum/outfit/loaded_outfit)
	for(var/outfit_slot in slot_to_human_var)
		var/loaded_path = loaded_outfit.vars[outfit_slot]
		if(loaded_path && !ispath(loaded_path, /obj/item))
			loaded_outfit.vars[outfit_slot] = null
	var/list/sanitized_backpack = list()
	for(var/item_path in loaded_outfit.backpack_contents)
		var/count = loaded_outfit.backpack_contents[item_path]
		if(!ispath(item_path, /obj/item) || !isnum(count) || count <= 0)
			continue
		sanitized_backpack[item_path] = count
	loaded_outfit.backpack_contents = sanitized_backpack
	if(loaded_outfit.box && !ispath(loaded_outfit.box, /obj/item))
		loaded_outfit.box = null
	var/list/sanitized_implants = list()
	for(var/implant_path in loaded_outfit.implants)
		if(ispath(implant_path, /obj/item/implant))
			sanitized_implants += implant_path
	loaded_outfit.implants = sanitized_implants
	var/list/sanitized_cyberimplants = list()
	for(var/cyberimp_path in loaded_outfit.cybernetic_implants)
		if(ispath(cyberimp_path, /obj/item/organ/internal/cyberimp))
			sanitized_cyberimplants += cyberimp_path
	loaded_outfit.cybernetic_implants = sanitized_cyberimplants
	var/list/sanitized_accessories = list()
	for(var/accessory_path in loaded_outfit.accessories)
		if(ispath(accessory_path, /obj/item/clothing/accessory))
			sanitized_accessories += accessory_path
	loaded_outfit.accessories = sanitized_accessories

/datum/custom_outfit/proc/copy_appearance(mob/living/carbon/human/source, mob/living/carbon/human/dummy)
	if(source.dna.species.type != dummy.dna.species.type)
		dummy.set_species(source.dna.species.type, save_appearance = TRUE)

	dummy.real_name = source.real_name
	dummy.gender = source.gender

	if(source.dna && dummy.dna)
		if(islist(source.dna.UI))
			dummy.dna.UI = source.dna.UI.Copy()
		if(islist(source.dna.SE))
			dummy.dna.SE = source.dna.SE.Copy()
		dummy.dna.uni_identity = source.dna.uni_identity
		dummy.dna.struc_enzymes = source.dna.struc_enzymes
		dummy.dna.blood_type = source.dna.blood_type

	if("s_tone" in source.vars)
		dummy.vars["s_tone"] = source.vars["s_tone"]

	var/list/source_styles = source.vars["m_styles"]
	if(islist(source_styles))
		dummy.vars["m_styles"] = source_styles.Copy()

	var/list/source_colours = source.vars["m_colours"]
	if(islist(source_colours))
		dummy.vars["m_colours"] = source_colours.Copy()

	var/obj/item/organ/external/head/source_head = source.get_organ(BODY_ZONE_HEAD)
	var/obj/item/organ/external/head/dummy_head = dummy.get_organ(BODY_ZONE_HEAD)
	if(source_head && dummy_head)
		dummy_head.h_style = source_head.h_style
		if("f_style" in source_head.vars)
			dummy_head.vars["f_style"] = source_head.vars["f_style"]
		if("hair_colour" in source_head.vars)
			dummy_head.vars["hair_colour"] = source_head.vars["hair_colour"]
		if("facial_colour" in source_head.vars)
			dummy_head.vars["facial_colour"] = source_head.vars["facial_colour"]
		if("h_grad_style" in source_head.vars)
			dummy_head.vars["h_grad_style"] = source_head.vars["h_grad_style"]
		if("h_grad_colour" in source_head.vars)
			dummy_head.vars["h_grad_colour"] = source_head.vars["h_grad_colour"]
		if("sec_hair_colour" in source_head.vars)
			dummy_head.vars["sec_hair_colour"] = source_head.vars["sec_hair_colour"]

	var/obj/item/organ/internal/eyes/source_eyes = source.get_int_organ(/obj/item/organ/internal/eyes)
	var/obj/item/organ/internal/eyes/dummy_eyes = dummy.get_int_organ(/obj/item/organ/internal/eyes)
	if(source_eyes && dummy_eyes && "eye_colour" in source_eyes.vars)
		dummy_eyes.vars["eye_colour"] = source_eyes.vars["eye_colour"]

	if(dummy.dna && dummy_eyes)
		dummy.dna.write_eyes_attributes(dummy_eyes)

	dummy.update_body()
	dummy.update_hair()
	dummy.update_eyes()
	dummy.regenerate_icons()

/datum/custom_outfit/proc/build_appearance_key(mob/living/carbon/human/human_target)
	var/obj/item/organ/external/head/head_organ = human_target.get_organ(BODY_ZONE_HEAD)
	var/obj/item/organ/internal/eyes/eyes_organ = human_target.get_int_organ(/obj/item/organ/internal/eyes)

	var/list/dna_ui = human_target.dna ? human_target.dna.UI : null

	var/list/key_parts = list(
		human_target.type,
		human_target.dna.species.name,
		human_target.gender,
		human_target.vars["s_tone"],
		head_organ ? head_organ.h_style : null,
		head_organ ? head_organ.vars["f_style"] : null,
		head_organ ? head_organ.vars["hair_colour"] : null,
		head_organ ? head_organ.vars["facial_colour"] : null,
		head_organ ? head_organ.vars["h_grad_style"] : null,
		head_organ ? head_organ.vars["h_grad_colour"] : null,
		head_organ ? head_organ.vars["sec_hair_colour"] : null,
		eyes_organ ? eyes_organ.vars["eye_colour"] : null,
		json_encode(dna_ui),
		json_encode(human_target.vars["m_styles"]),
		json_encode(human_target.vars["m_colours"]),
	)
	return key_parts.Join("|")

#undef CUSTOM_OUTFIT_SAVE_FORMAT
#undef CUSTOM_OUTFIT_SAVE_VERSION

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
#undef CUSTOM_OUTFIT_ACTION_DENTAL_IMPLANT
#undef CUSTOM_OUTFIT_ACTION_CLICK
#undef CUSTOM_OUTFIT_ACTION_CLEAR

#undef CUSTOM_OUTFIT_DEFAULT_NAME
#undef CUSTOM_OUTFIT_DEFAULT_COMPANY
#undef CUSTOM_OUTFIT_DEFAULT_REAGENT_AMOUNT
#undef CUSTOM_OUTFIT_MIN_REAGENT_AMOUNT
#undef CUSTOM_OUTFIT_MAX_REAGENT_AMOUNT
