#define CUSTOM_OUTFIT_ACTION_LOAD "load"
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

#define CUSTOM_OUTFIT_CHOICE_USE_ANYWAY "Use anyway"
#define CUSTOM_OUTFIT_CHOICE_CANCEL "Cancel"

#define CUSTOM_OUTFIT_DEFAULT_COMPANY "Cybernetic"
#define CUSTOM_OUTFIT_DEFAULT_REAGENT_AMOUNT 5
#define CUSTOM_OUTFIT_MIN_REAGENT_AMOUNT 1
#define CUSTOM_OUTFIT_MAX_REAGENT_AMOUNT 100

#define CUSTOM_OUTFIT_SLOT_UNIFORM "uniform"
#define CUSTOM_OUTFIT_SLOT_SUIT "suit"
#define CUSTOM_OUTFIT_SLOT_BACK "back"
#define CUSTOM_OUTFIT_SLOT_BELT "belt"
#define CUSTOM_OUTFIT_SLOT_GLOVES "gloves"
#define CUSTOM_OUTFIT_SLOT_SHOES "shoes"
#define CUSTOM_OUTFIT_SLOT_HEAD "head"
#define CUSTOM_OUTFIT_SLOT_MASK "mask"
#define CUSTOM_OUTFIT_SLOT_NECK "neck"
#define CUSTOM_OUTFIT_SLOT_L_EAR "l_ear"
#define CUSTOM_OUTFIT_SLOT_R_EAR "r_ear"
#define CUSTOM_OUTFIT_SLOT_GLASSES "glasses"
#define CUSTOM_OUTFIT_SLOT_ID "id"
#define CUSTOM_OUTFIT_SLOT_PDA "pda"
#define CUSTOM_OUTFIT_SLOT_L_POCKET "l_pocket"
#define CUSTOM_OUTFIT_SLOT_R_POCKET "r_pocket"
#define CUSTOM_OUTFIT_SLOT_SUIT_STORE "suit_store"
#define CUSTOM_OUTFIT_SLOT_L_HAND "l_hand"
#define CUSTOM_OUTFIT_SLOT_R_HAND "r_hand"

/datum/custom_outfit
	var/mob/target_mob
	var/datum/outfit/edited_outfit
	var/list/external_augmentations = list()
	var/list/internal_augmentations = list()
	var/list/reagent_volumes = list()
	var/body_dirty = FALSE
	var/backpack_dirty = FALSE
	var/dental_dirty = FALSE
	var/obj/item/reagent_containers/food/pill/dental_holder
	var/datum/reagents_editor/custom_outfit_dental/dental_editor
	var/cached_preview_icon
	var/cached_preview_key
	var/preview_dirty = TRUE
	var/preview_pending = FALSE

	var/static/list/slot_to_human_var = list(
		CUSTOM_OUTFIT_SLOT_UNIFORM = "w_uniform",
		CUSTOM_OUTFIT_SLOT_SUIT = "wear_suit",
		CUSTOM_OUTFIT_SLOT_BACK = "back",
		CUSTOM_OUTFIT_SLOT_BELT = "belt",
		CUSTOM_OUTFIT_SLOT_GLOVES = "gloves",
		CUSTOM_OUTFIT_SLOT_SHOES = "shoes",
		CUSTOM_OUTFIT_SLOT_HEAD = "head",
		CUSTOM_OUTFIT_SLOT_MASK = "wear_mask",
		CUSTOM_OUTFIT_SLOT_NECK = "neck",
		CUSTOM_OUTFIT_SLOT_L_EAR = "l_ear",
		CUSTOM_OUTFIT_SLOT_R_EAR = "r_ear",
		CUSTOM_OUTFIT_SLOT_GLASSES = "glasses",
		CUSTOM_OUTFIT_SLOT_ID = "wear_id",
		CUSTOM_OUTFIT_SLOT_PDA = "wear_pda",
		CUSTOM_OUTFIT_SLOT_L_POCKET = "l_store",
		CUSTOM_OUTFIT_SLOT_R_POCKET = "r_store",
		CUSTOM_OUTFIT_SLOT_SUIT_STORE = "s_store",
		CUSTOM_OUTFIT_SLOT_L_HAND = "l_hand",
		CUSTOM_OUTFIT_SLOT_R_HAND = "r_hand",
	)

	var/static/list/slot_to_item_flag = list(
		CUSTOM_OUTFIT_SLOT_UNIFORM = ITEM_SLOT_CLOTH_INNER,
		CUSTOM_OUTFIT_SLOT_SUIT = ITEM_SLOT_CLOTH_OUTER,
		CUSTOM_OUTFIT_SLOT_BACK = ITEM_SLOT_BACK,
		CUSTOM_OUTFIT_SLOT_BELT = ITEM_SLOT_BELT,
		CUSTOM_OUTFIT_SLOT_GLOVES = ITEM_SLOT_GLOVES,
		CUSTOM_OUTFIT_SLOT_SHOES = ITEM_SLOT_FEET,
		CUSTOM_OUTFIT_SLOT_HEAD = ITEM_SLOT_HEAD,
		CUSTOM_OUTFIT_SLOT_MASK = ITEM_SLOT_MASK,
		CUSTOM_OUTFIT_SLOT_NECK = ITEM_SLOT_NECK,
		CUSTOM_OUTFIT_SLOT_L_EAR = ITEM_SLOT_EAR_LEFT,
		CUSTOM_OUTFIT_SLOT_R_EAR = ITEM_SLOT_EAR_RIGHT,
		CUSTOM_OUTFIT_SLOT_GLASSES = ITEM_SLOT_EYES,
		CUSTOM_OUTFIT_SLOT_ID = ITEM_SLOT_ID,
		CUSTOM_OUTFIT_SLOT_PDA = ITEM_SLOT_PDA,
		CUSTOM_OUTFIT_SLOT_L_POCKET = ITEM_SLOT_POCKET_LEFT,
		CUSTOM_OUTFIT_SLOT_R_POCKET = ITEM_SLOT_POCKET_RIGHT,
		CUSTOM_OUTFIT_SLOT_SUIT_STORE = ITEM_SLOT_SUITSTORE,
		CUSTOM_OUTFIT_SLOT_L_HAND = ITEM_SLOT_HAND_LEFT,
		CUSTOM_OUTFIT_SLOT_R_HAND = ITEM_SLOT_HAND_RIGHT,
	)

	var/static/list/slot_holders = list(
		CUSTOM_OUTFIT_SLOT_UNIFORM,
		CUSTOM_OUTFIT_SLOT_SUIT,
		CUSTOM_OUTFIT_SLOT_BACK,
		CUSTOM_OUTFIT_SLOT_BELT,
	)

	var/static/list/slot_dependents = list(
		CUSTOM_OUTFIT_SLOT_UNIFORM = list(
			CUSTOM_OUTFIT_SLOT_L_POCKET,
			CUSTOM_OUTFIT_SLOT_R_POCKET,
			CUSTOM_OUTFIT_SLOT_ID,
			CUSTOM_OUTFIT_SLOT_PDA,
			CUSTOM_OUTFIT_SLOT_BELT,
		),
		CUSTOM_OUTFIT_SLOT_SUIT = list(
			CUSTOM_OUTFIT_SLOT_SUIT_STORE,
		),
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

	var/static/list/limb_status_options = list(
		"Ампутировано" = CUSTOM_OUTFIT_LIMB_STATUS_AMPUTATED,
		"Протез" = CUSTOM_OUTFIT_LIMB_STATUS_PROSTHETIC,
		"Аугментация" = CUSTOM_OUTFIT_LIMB_STATUS_AUGMENTED,
	)

	var/static/list/no_amputate_zones = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_PRECISE_GROIN,
	)

	var/static/list/limb_amputation_dependents = list(
		BODY_ZONE_L_ARM = BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM = BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_L_LEG = BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_R_LEG = BODY_ZONE_PRECISE_R_FOOT,
	)

	var/static/list/slot_base_type = list(
		CUSTOM_OUTFIT_SLOT_HEAD = /obj/item/clothing/head,
		CUSTOM_OUTFIT_SLOT_GLASSES = /obj/item/clothing/glasses,
		CUSTOM_OUTFIT_SLOT_L_EAR = /obj/item/radio/headset,
		CUSTOM_OUTFIT_SLOT_R_EAR = /obj/item/radio/headset,
		CUSTOM_OUTFIT_SLOT_NECK = /obj/item/clothing/neck,
		CUSTOM_OUTFIT_SLOT_MASK = /obj/item/clothing/mask,
		CUSTOM_OUTFIT_SLOT_UNIFORM = /obj/item/clothing/under,
		CUSTOM_OUTFIT_SLOT_SUIT = /obj/item/clothing/suit,
		CUSTOM_OUTFIT_SLOT_GLOVES = /obj/item/clothing/gloves,
		CUSTOM_OUTFIT_SLOT_SHOES = /obj/item/clothing/shoes,
		CUSTOM_OUTFIT_SLOT_BELT = /obj/item/storage/belt,
		CUSTOM_OUTFIT_SLOT_ID = /obj/item/card/id,
		CUSTOM_OUTFIT_SLOT_PDA = /obj/item/pda,
		CUSTOM_OUTFIT_SLOT_BACK = /obj/item/storage/backpack,
	)

	var/static/list/slot_any_item = list(
		CUSTOM_OUTFIT_SLOT_SUIT_STORE,
		CUSTOM_OUTFIT_SLOT_L_HAND,
		CUSTOM_OUTFIT_SLOT_R_HAND,
		CUSTOM_OUTFIT_SLOT_L_POCKET,
		CUSTOM_OUTFIT_SLOT_R_POCKET,
	)

	var/static/list/internal_organ_options = list(
		"Глаза" = /obj/item/organ/internal/eyes/cybernetic,
		"Уши" = /obj/item/organ/internal/ears/cybernetic,
		"Сердце" = /obj/item/organ/internal/heart/cybernetic,
		"Лёгкие" = /obj/item/organ/internal/lungs/cybernetic,
		"Печень" = /obj/item/organ/internal/liver/cybernetic,
		"Почки" = /obj/item/organ/internal/kidneys/cybernetic,
	)

	var/static/list/head_appearance_vars = list(
		"h_style",
		"f_style",
		"hair_colour",
		"facial_colour",
		"h_grad_style",
		"h_grad_colour",
		"sec_hair_colour",
	)

	var/static/list/reagent_option_cache = list()
	var/static/list/slot_option_cache = list()

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
	QDEL_NULL(dental_editor)
	QDEL_NULL(dental_holder)
	QDEL_NULL(edited_outfit)
	LAZYCLEARLIST(external_augmentations)
	LAZYCLEARLIST(internal_augmentations)
	LAZYCLEARLIST(reagent_volumes)
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
		if(!preview_pending && (preview_dirty || appearance_key != cached_preview_key))
			preview_pending = TRUE
			addtimer(CALLBACK(src, PROC_REF(regenerate_preview_icon)), 1)
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

		if(CUSTOM_OUTFIT_ACTION_ADD_BACKPACK_ITEM)
			if(choose_backpack_item(user))
				backpack_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_REMOVE_IMPLANT)
			var/implant_path = get_path_param(params)
			if(implant_path && ((implant_path in edited_outfit.implants) || (implant_path in edited_outfit.cybernetic_implants)))
				edited_outfit.implants -= implant_path
				edited_outfit.cybernetic_implants -= implant_path
				body_dirty = TRUE
			. = TRUE

		if(CUSTOM_OUTFIT_ACTION_REMOVE_ITEM)
			if(remove_backpack_item(get_path_param(params)))
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
			if(!QDELETED(dental_holder) && dental_holder.reagents && dental_holder.reagents.total_volume > 0)
				dental_holder.reagents.clear_reagents()
				reagent_volumes = list()
				dental_dirty = TRUE
			else
				open_dental_editor(user)
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

/datum/custom_outfit/proc/regenerate_preview_icon()
	preview_pending = FALSE
	if(QDELETED(src) || QDELETED(target_mob) || !ishuman(target_mob))
		return
	var/mob/living/carbon/human/human_target = target_mob
	cached_preview_key = build_appearance_key(human_target)
	preview_dirty = FALSE
	cached_preview_icon = generate_preview_icon()
	SStgui.update_uis(src)

/datum/custom_outfit/proc/get_path_param(list/params)
	var/path_text = params["path"]
	if(!path_text)
		path_text = params["ref"]
	return text2path(path_text)

/datum/custom_outfit/proc/is_valid_item_entry(item_path, count)
	return ispath(item_path, /obj/item) && isnum(count) && count > 0

/datum/custom_outfit/proc/get_slot_options(base_type)
	. = slot_option_cache[base_type]
	if(.)
		return
	. = list()
	for(var/item_path in valid_subtypesof(base_type))
		var/obj/item/item_ref = item_path
		var/item_name = initial(item_ref.name)
		if(!item_name)
			continue
		.["[item_name] ([item_path])"] = item_path
	slot_option_cache[base_type] = .

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
		if(!limb)
			external_augmentations[body_zone] = list(
				"status" = CUSTOM_OUTFIT_LIMB_STATUS_AMPUTATED,
				"company" = null,
			)
			continue
		if(limb.is_robotic())
			external_augmentations[body_zone] = list(
				"status" = CUSTOM_OUTFIT_LIMB_STATUS_PROSTHETIC,
				"company" = limb.model,
			)
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
		var/list/limb_data = external_augmentations[body_zone]
		var/status = limb_data["status"]
		var/company = limb_data["company"]
		var/status_name
		switch(status)
			if(CUSTOM_OUTFIT_LIMB_STATUS_AMPUTATED)
				status_name = "Ампутировано"
			if(CUSTOM_OUTFIT_LIMB_STATUS_PROSTHETIC)
				status_name = "Протез"
			if(CUSTOM_OUTFIT_LIMB_STATUS_AUGMENTED)
				status_name = "Аугментация"
		. += list(list(
			"zone" = body_zone,
			"zone_name" = parse_zone(body_zone),
			"status" = status,
			"status_name" = status_name,
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
		tgui_alert(user, "Target is no longer valid.")
		return
	var/mob/living/carbon/human/human_target = target_mob
	if(!human_target.dna || !human_target.dna.species)
		tgui_alert(user, "Target has no valid DNA or species.")
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
		sync_dental_reagents()
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
			if(outfit_slot == CUSTOM_OUTFIT_SLOT_BACK)
				kept_existing_back = TRUE
				final_outfit.box = null
				final_outfit.backpack_contents = list()
			continue

		to_delete += outfit_slot

		if(outfit_slot == CUSTOM_OUTFIT_SLOT_BACK)
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
	if(outfit_slot == CUSTOM_OUTFIT_SLOT_BACK && isstorage(current_item))
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
		var/list/limb_data = external_augmentations[body_zone]
		var/status = limb_data["status"]
		var/company = limb_data["company"]
		var/obj/item/organ/external/limb = human_target.get_organ(body_zone)

		switch(status)
			if(CUSTOM_OUTFIT_LIMB_STATUS_AMPUTATED)
				if(limb)
					qdel(limb.remove(human_target))

			if(CUSTOM_OUTFIT_LIMB_STATUS_PROSTHETIC)
				if(limb && (!limb.is_robotic() || limb.model != company))
					limb.robotize(company = company, convert_all = FALSE)

			if(CUSTOM_OUTFIT_LIMB_STATUS_AUGMENTED)
				if(limb)
					limb.robotize(make_tough = TRUE, company = company, convert_all = FALSE)

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
	var/list/validated_reagents = list()
	var/total_volume = 0
	for(var/reagent_path in reagent_volumes)
		var/amount = reagent_volumes[reagent_path]
		if(!ispath(reagent_path, /datum/reagent) || !isnum(amount) || amount <= 0)
			continue
		validated_reagents[reagent_path] = amount
		total_volume += amount
	if(!total_volume)
		return
	var/obj/item/reagent_containers/food/pill/pill = new /obj/item/reagent_containers/food/pill(human_target)
	if(total_volume > pill.reagents.maximum_volume)
		pill.reagents.maximum_volume = total_volume
	for(var/reagent_path in validated_reagents)
		pill.reagents.add_reagent(reagent_path, validated_reagents[reagent_path])
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
		tgui_alert(user, "Target is no longer valid.")
		return FALSE
	var/mob/living/carbon/human/human_target = target_mob
	if(!isstorage(human_target.back))
		tgui_alert(user, "Target does not have a storage back item.")
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
	var/list/implant_types = list(
		"Кибер-имплант" = /obj/item/organ/internal/cyberimp,
		"Био-имплант" = /obj/item/implant,
	)
	var/type_choice = tgui_input_list(user, "Выберите тип импланта", "Имплант", implant_types)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(!type_choice)
		return FALSE
	return add_implant_of_type(user, implant_types[type_choice])

/datum/custom_outfit/proc/build_named_type_list(list/type_paths)
	. = list()
	for(var/type_path in type_paths)
		var/atom/typed_ref = type_path
		var/type_name = initial(typed_ref.name)
		if(!type_name)
			continue
		.["[type_name] ([type_path])"] = type_path

/datum/custom_outfit/proc/add_implant_of_type(mob/user, base_path)
	var/list/options = build_named_type_list(valid_subtypesof(base_path))
	if(!length(options))
		to_chat(user, span_warning("No implants found."))
		return FALSE
	var/choice = tgui_input_list(user, "Выберит имплант", "Custom Outfit", options)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(isnull(choice))
		return FALSE
	var/implant_path = options[choice]
	if(!ispath(implant_path, base_path))
		return FALSE
	var/list/destination = (base_path == /obj/item/organ/internal/cyberimp) ? edited_outfit.cybernetic_implants : edited_outfit.implants
	if(implant_path in destination)
		return FALSE
	destination += implant_path
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

	var/list/status_options = limb_status_options.Copy()
	if(body_zone in no_amputate_zones)
		status_options -= "Ампутировано"
	var/status_choice = tgui_input_list(user, "Выберите состояние части тела", "Аугментация", status_options)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(!status_choice)
		return FALSE
	var/status = status_options[status_choice]

	var/company = null
	if(status != CUSTOM_OUTFIT_LIMB_STATUS_AMPUTATED)
		var/list/companies = list()
		for(var/company_name in GLOB.all_robolimbs)
			var/datum/robolimb/robolimb = GLOB.all_robolimbs[company_name]
			if(!robolimb.has_subtypes)
				continue
			if(!(body_zone in robolimb.parts))
				continue
			companies[company_name] = robolimb
		if(!length(companies))
			tgui_alert(user, "No augmentations available for this body part.")
			return FALSE
		var/company_choice = tgui_input_list(user, "Выберите фирму-изготовителя", "Аугментация", companies)
		if(QDELETED(src) || QDELETED(user))
			return FALSE
		if(!company_choice)
			return FALSE
		var/datum/robolimb/selected_limb = companies[company_choice]
		if(!selected_limb)
			return FALSE
		company = selected_limb.company

	external_augmentations[body_zone] = list(
		"status" = status,
		"company" = company,
	)

	if(status == CUSTOM_OUTFIT_LIMB_STATUS_AMPUTATED)
		var/dependent_zone = limb_amputation_dependents[body_zone]
		if(dependent_zone)
			external_augmentations[dependent_zone] = list(
				"status" = CUSTOM_OUTFIT_LIMB_STATUS_AMPUTATED,
				"company" = null,
			)
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
		var/obj/item/organ/internal/organ_ref = organ_path
		var/organ_name = initial(organ_ref.name)
		if(!organ_name)
			continue
		organ_paths["[organ_name] ([organ_path])"] = organ_path
	if(!length(organ_paths))
		tgui_alert(user, "No cybernetic variants found for this organ.")
		return FALSE
	var/variant_choice = tgui_input_list(user, "Выберите вариант", "Аугментация", organ_paths)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(!variant_choice)
		return FALSE
	var/organ_path = organ_paths[variant_choice]
	if(!organ_path)
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

/datum/custom_outfit/proc/get_reagent_options()
	if(length(reagent_option_cache))
		return reagent_option_cache
	var/list/options = list()
	for(var/datum/reagent/reagent_path as anything in valid_subtypesof(/datum/reagent))
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
	var/list/options = get_slot_options(base_type)
	if(!length(options))
		tgui_alert(user, "No matching items found for this slot.")
		return FALSE
	var/choice = tgui_input_list(user, "Выберите предмет", "Custom Outfit", options)
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
	if(!ispath(choice, /obj/item))
		if(choice)
			tgui_alert(user, "Invalid item", "Custom Outfit", list("OK"))
		return FALSE
	var/base_type = slot_base_type[slot]
	if(base_type && !(slot in slot_any_item) && !ispath(choice, base_type))
		var/confirm_choice = tgui_alert(user, "This item may not fit the selected slot.", "Custom Outfit", list(CUSTOM_OUTFIT_CHOICE_USE_ANYWAY, CUSTOM_OUTFIT_CHOICE_CANCEL))
		if(QDELETED(src) || QDELETED(user))
			return FALSE
		if(confirm_choice != CUSTOM_OUTFIT_CHOICE_USE_ANYWAY)
			return FALSE
	if(initial(choice.icon_state) == null)
		var/confirm_choice = tgui_alert(user, "Warning: This item's icon_state is null, indicating it is very probably not actually a usable item.", "Custom Outfit", list(CUSTOM_OUTFIT_CHOICE_USE_ANYWAY, CUSTOM_OUTFIT_CHOICE_CANCEL))
		if(QDELETED(src) || QDELETED(user))
			return FALSE
		if(confirm_choice != CUSTOM_OUTFIT_CHOICE_USE_ANYWAY)
			return FALSE
	edited_outfit.vars[slot] = choice
	if(slot == CUSTOM_OUTFIT_SLOT_BACK)
		backpack_dirty = TRUE
		if(!ispath(choice, /obj/item/storage))
			edited_outfit.backpack_contents.Cut()
	return TRUE

/datum/custom_outfit/proc/clear_slot(slot)
	if(!(slot in slot_to_human_var))
		return FALSE
	edited_outfit.vars[slot] = null
	if(slot == CUSTOM_OUTFIT_SLOT_BACK)
		backpack_dirty = TRUE
		edited_outfit.backpack_contents.Cut()
	return TRUE

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
		for(var/head_var in head_appearance_vars)
			if(head_var in source_head.vars)
				dummy_head.vars[head_var] = source_head.vars[head_var]

	var/obj/item/organ/internal/eyes/source_eyes = source.get_int_organ(/obj/item/organ/internal/eyes)
	var/obj/item/organ/internal/eyes/dummy_eyes = dummy.get_int_organ(/obj/item/organ/internal/eyes)
	if(source_eyes && dummy_eyes && ("eye_colour" in source_eyes.vars))
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
	var/list/key_parts = list(
		human_target.type,
		human_target.dna?.species?.name,
		human_target.gender,
		human_target.vars["s_tone"],
		eyes_organ ? eyes_organ.vars["eye_colour"] : null,
		json_encode(human_target.dna?.UI),
		json_encode(human_target.vars["m_styles"]),
		json_encode(human_target.vars["m_colours"]),
	)
	for(var/head_var in head_appearance_vars)
		key_parts += head_organ ? head_organ.vars[head_var] : null
	return key_parts.Join("|")

/datum/custom_outfit/proc/open_dental_editor(mob/user)
	if(QDELETED(dental_holder))
		dental_holder = new /obj/item/reagent_containers/food/pill()
		dental_holder.name = "зубной имплант"
		dental_holder.create_reagents(CUSTOM_OUTFIT_MAX_REAGENT_AMOUNT)
		for(var/reagent_path in reagent_volumes)
			dental_holder.reagents.add_reagent(reagent_path, reagent_volumes[reagent_path])
	if(QDELETED(dental_editor))
		dental_editor = new /datum/reagents_editor/custom_outfit_dental(dental_holder, src)
	dental_editor.ui_interact(user)

/datum/custom_outfit/proc/on_dental_editor_closed()
	sync_dental_reagents()
	dental_dirty = TRUE
	SStgui.update_uis(src)

/datum/custom_outfit/proc/sync_dental_reagents()
	reagent_volumes = list()
	if(QDELETED(dental_holder) || !dental_holder.reagents)
		return
	for(var/datum/reagent/reagent_instance in dental_holder.reagents.reagent_list)
		if(reagent_instance.volume > 0)
			reagent_volumes[reagent_instance.type] = reagent_instance.volume

/obj/item/reagent_containers/food/pill/custom_outfit_editor
	name = "dental implant"
	icon_state = "pill"
	var/datum/custom_outfit/custom_outfit_ref

/obj/item/reagent_containers/food/pill/custom_outfit_editor/ui_close(mob/user)
	. = ..()
	if(custom_outfit_ref)
		custom_outfit_ref.sync_dental_reagents()

/datum/reagents_editor/custom_outfit_dental
	var/datum/custom_outfit/linked_outfit

/datum/reagents_editor/custom_outfit_dental/New(atom/target, datum/custom_outfit/owner)
	. = ..(target)
	linked_outfit = owner

/datum/reagents_editor/custom_outfit_dental/Destroy()
	if(linked_outfit)
		linked_outfit.dental_editor = null
		linked_outfit = null
	return ..()

/datum/reagents_editor/custom_outfit_dental/ui_close(mob/user)
	. = ..()
	if(linked_outfit)
		linked_outfit.on_dental_editor_closed()

#undef CUSTOM_OUTFIT_ACTION_LOAD
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

#undef CUSTOM_OUTFIT_CHOICE_USE_ANYWAY
#undef CUSTOM_OUTFIT_CHOICE_CANCEL

#undef CUSTOM_OUTFIT_DEFAULT_COMPANY
#undef CUSTOM_OUTFIT_DEFAULT_REAGENT_AMOUNT
#undef CUSTOM_OUTFIT_MIN_REAGENT_AMOUNT
#undef CUSTOM_OUTFIT_MAX_REAGENT_AMOUNT

#undef CUSTOM_OUTFIT_SLOT_UNIFORM
#undef CUSTOM_OUTFIT_SLOT_SUIT
#undef CUSTOM_OUTFIT_SLOT_BACK
#undef CUSTOM_OUTFIT_SLOT_BELT
#undef CUSTOM_OUTFIT_SLOT_GLOVES
#undef CUSTOM_OUTFIT_SLOT_SHOES
#undef CUSTOM_OUTFIT_SLOT_HEAD
#undef CUSTOM_OUTFIT_SLOT_MASK
#undef CUSTOM_OUTFIT_SLOT_NECK
#undef CUSTOM_OUTFIT_SLOT_L_EAR
#undef CUSTOM_OUTFIT_SLOT_R_EAR
#undef CUSTOM_OUTFIT_SLOT_GLASSES
#undef CUSTOM_OUTFIT_SLOT_ID
#undef CUSTOM_OUTFIT_SLOT_PDA
#undef CUSTOM_OUTFIT_SLOT_L_POCKET
#undef CUSTOM_OUTFIT_SLOT_R_POCKET
#undef CUSTOM_OUTFIT_SLOT_SUIT_STORE
#undef CUSTOM_OUTFIT_SLOT_L_HAND
#undef CUSTOM_OUTFIT_SLOT_R_HAND
