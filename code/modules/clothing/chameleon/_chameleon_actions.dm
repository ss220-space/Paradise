/// Default duration of an EMP randomisation on a chameleon item
#define EMP_RANDOMISE_TIME (30 SECONDS)
/// Max symbols for custom outfit name
#define MAX_OUTFIT_NAME_LEN 10
/// Cap on how many custom outfits we can save
#define MAX_CUSTOM_OUTFITS 10

/// OUTFIT ACTION

/datum/action/chameleon_outfit
	name = "Select Chameleon Outfit"
	desc = "Left-Click: Select a job to update all of your chameleon items to.<br>\
			Middle-Click: Save your current chameleon setup as a custom outfit.<br>\
			Alt-Click: Delete custom outfit."
	button_icon_state = "chameleon_outfit"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE|AB_CHECK_HANDS_BLOCKED
	/// Determines when we're in use
	var/currently_in_use = FALSE
	/// Cached assoc list of job outfit datums by their names that we can select
	/// If you intend on editing this, ensure you are copying it first
	var/list/outfit_options
	/// Assoc list of custom outfit names ("Custom outfit 1", "Custom outfit 2", etc) to list of all item typepaths saved in that outfit
	var/list/custom_outfits
	///First who changed outfit and only one who can see cham. actions later
	var/datum/weakref/chameleon_master_ref = null

/datum/action/chameleon_outfit/New(Target)
	. = ..()
	outfit_options = get_initial_outfits()

/datum/action/chameleon_outfit/proc/get_initial_outfits()
	var/static/list/standard_outfit_options
	if(!standard_outfit_options)
		standard_outfit_options = list()
		for(var/datum/outfit/found_outfit as anything in subtypesof(/datum/outfit/job))
			if(initial(found_outfit.can_be_admin_equipped))
				standard_outfit_options[initial(found_outfit.name)] = new found_outfit
		sortTim(standard_outfit_options, cmp = /proc/cmp_text_asc)

	return standard_outfit_options

/datum/action/chameleon_outfit/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!. || currently_in_use || usr != owner)
		return .
	currently_in_use = TRUE
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		. = save_current_outfit(usr)
	else
		. = select_outfit(usr)
	currently_in_use = FALSE

/datum/action/chameleon_outfit/Grant(mob/grant_to)
	var/mob/master = chameleon_master_ref?.resolve()
	if(!master || master.stat == DEAD)
		if(isliving(grant_to))
			chameleon_master_ref = WEAKREF(grant_to)
		else
			return FALSE

	master = chameleon_master_ref?.resolve()
	if(master != grant_to)
		return FALSE

	return ..()

/datum/action/chameleon_outfit/AltTrigger(mob/clicker, trigger_flags)
	if(currently_in_use || !IsAvailable() || usr != owner)
		return FALSE

	currently_in_use = TRUE
	. = delete_custom_outfit(usr)
	currently_in_use = FALSE

/datum/action/chameleon_outfit/proc/delete_custom_outfit(mob/user)
	if(!LAZYLEN(custom_outfits))
		to_chat(owner, span_warning("No custom outfits found to remove!"))
		return FALSE

	var/outfit_ro_remove = tgui_input_list(user, "Select outfit to remove", "Outfit Removing", custom_outfits)
	if(isnull(outfit_ro_remove) || QDELETED(src) || QDELETED(user) || QDELETED(owner) || !IsAvailable())
		return FALSE

	LAZYREMOVE(custom_outfits, outfit_ro_remove)
	to_chat(owner, span_notice("Outfit <b>\"[outfit_ro_remove]\"</b> was successfully removed."))
	return TRUE

/datum/action/chameleon_outfit/proc/save_current_outfit(mob/user)
	if(LAZYLEN(custom_outfits) >= MAX_CUSTOM_OUTFITS)
		to_chat(owner, span_warning("You have exceeded the maximum amount of allowed custom outfits!"))
		return FALSE
	var/list/saved_paths = list()
	for(var/datum/action/item_action/chameleon/change/change_action in owner.actions)
		if(change_action.active_type)
			saved_paths |= change_action.active_type
	return save_outfit(user, saved_paths)

/datum/action/chameleon_outfit/proc/save_outfit(mob/user, list/saved_paths)
	if(!length(saved_paths))
		to_chat(owner, span_warning("No outfits found to save!"))
		return FALSE

	for(var/existing_outfit in custom_outfits)
		if(custom_outfits[existing_outfit] ~= saved_paths)
			to_chat(owner, span_warning("Outfit with the same positions is already saved!"))
			return FALSE

	var/new_outfit_name = tgui_input_text(user, "Specify custom outfit name", "Saving Outfit", "", max_length = MAX_OUTFIT_NAME_LEN)
	if(!new_outfit_name || QDELETED(src) || QDELETED(user) || QDELETED(owner) || !IsAvailable())
		return FALSE

	for(var/existing_outfit_name in custom_outfits)
		if(existing_outfit_name == new_outfit_name)
			to_chat(owner, span_warning("Outfit with the same name is already exist!"))
			return FALSE

	LAZYSET(custom_outfits, new_outfit_name, saved_paths)
	to_chat(owner, span_notice("Outfit saved as <b>\"[new_outfit_name]\"</b>."))
	return TRUE

/datum/action/chameleon_outfit/proc/select_outfit(mob/user)
	var/list/all_options = list()
	if(LAZYLEN(custom_outfits))
		all_options += "--- Custom outfits ---"
		all_options += custom_outfits
	all_options += "--- Job outfits ---"
	all_options += outfit_options

	var/selected = tgui_input_list(user, "Select outfit to change into", "Chameleon Outfit", all_options)
	if(isnull(selected) || QDELETED(src) || QDELETED(user) || QDELETED(owner) || !IsAvailable())
		return FALSE

	var/selected_outfit = all_options[selected]
	if(islist(selected_outfit))
		var/list/selected_custom_outfit = selected_outfit
		var/datum/outfit/empty_outfit = new
		apply_outfit(empty_outfit, selected_custom_outfit.Copy())
		qdel(empty_outfit)
		return TRUE

	if(istype(selected_outfit, /datum/outfit))
		apply_outfit(selected_outfit)
		return TRUE

	return FALSE

/**
 * Applies the given outfit to all chameleon actions the owner has
 *
 * * outfit - what outfit to apply
 * * outfit_types - optinal, list of typepaths to apply. If null, defaults to all items in the passed outfit. This list is mutated!
 */
/datum/action/chameleon_outfit/proc/apply_outfit(datum/outfit/outfit, list/outfit_types)
	if(isnull(outfit_types))
		outfit_types = outfit.get_chameleon_disguise_info()

	for(var/datum/action/item_action/chameleon/change/change_action in owner.actions)
		change_action.apply_outfit(outfit, outfit_types)

/// BASIC ITEM ACTION

/datum/action/item_action/chameleon/change
	name = "Chameleon Change"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE|AB_CHECK_HANDS_BLOCKED
	/// Typecache of all item types we explicitly cannot pick
	/// Note that abstract items are already excluded
	VAR_FINAL/static/list/chameleon_blacklist = list()
	/// Typecache of typepaths we can turn into
	VAR_FINAL/list/chameleon_typecache
	/// Assoc list of item name + icon state to item typepath
	/// This is passed to the list input
	VAR_FINAL/static/list/chameleon_list = list()
	/// The prime typepath of what class of item we're allowed to pick from
	var/chameleon_type
	/// Used in the action button to describe what we're changing into
	var/chameleon_name = "Item"
	/// What chameleon is active right now?
	/// Can be set in the declaration to update in init
	var/active_type
	var/obj/item/holder
	/// Cooldown from when we started being EMP'd
	COOLDOWN_DECLARE(emp_timer)
	///First who changed outfit and only one who can see cham. actions later
	var/datum/weakref/chameleon_master_ref = null

/datum/action/item_action/chameleon/change/New(Target)
	. = ..()
	if(!isitem(target))
		stack_trace("Adding chameleon action to non-item ([target])")
		qdel(src)
		return

	initialize_blacklist()
	initialize_disguises()
	holder = Target
	if(active_type)
		if(chameleon_blacklist[active_type])
			stack_trace("[type] has an active type defined in init which is blacklisted ([active_type])")
			active_type = null
		else
			update_look(active_type)

	RegisterSignal(target, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))

/datum/action/item_action/chameleon/change/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	holder = null
	return ..()

/datum/action/item_action/chameleon/change/ui_host()
	return target

/datum/action/item_action/chameleon/change/ui_state(mob/user)
	return GLOB.physical_state

/datum/action/item_action/chameleon/change/ui_data(mob/user)
	var/list/data = list()
	data["selected_appearance"] = "[holder.name]_[holder.icon_state]"
	return data

/datum/action/item_action/chameleon/change/ui_static_data(mob/user, datum/tgui/ui = null)
	var/list/data = list()
	var/list/chameleon_skins = list()
	for(var/chameleon_type in chameleon_list[chameleon_name])
		var/obj/item/chameleon_item = chameleon_list[chameleon_name][chameleon_type]
		chameleon_skins.Add(list(list(
			"icon" = chameleon_item.icon,
			"icon_state" = chameleon_item.icon_state,
			"name" = initial(chameleon_item.name),
		)))

	data["chameleon_skins"] = chameleon_skins
	return data

/datum/action/item_action/chameleon/change/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Chameleon", "Change [chameleon_name] Appearance")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/action/item_action/chameleon/change/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("change_appearance")
			update_look(chameleon_list[chameleon_name][params["new_appearance"]])

/datum/action/item_action/chameleon/change/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER

	chameleon_master_ref = null

	if(owner)
		var/datum/action/chameleon_outfit/outfit = locate() in owner.actions
		if(outfit)
			outfit.chameleon_master_ref = null

		to_chat(owner, span_warning("Биометрическая защита [holder.declent_ru(GENITIVE)] была сброшена электромагнитным импульсом!"))

	if(COOLDOWN_FINISHED(src, emp_timer))
		emp_randomise()

/datum/action/item_action/chameleon/change/proc/check_chameleon_access(mob/grant_to)
	var/mob/master = chameleon_master_ref?.resolve()

	if(!master || master.stat == DEAD)
		if(isliving(grant_to))
			chameleon_master_ref = WEAKREF(grant_to)
			return TRUE
		return FALSE

	if(master != grant_to)
		return FALSE

	return TRUE

/datum/action/item_action/chameleon/change/Grant(mob/grant_to)
	if(!check_chameleon_access(grant_to))
		return FALSE

	. = ..()

	if(locate(/datum/action/chameleon_outfit) in grant_to.actions)
		return

	var/datum/action/chameleon_outfit/outfit_action = new(owner)
	outfit_action.chameleon_master_ref = chameleon_master_ref
	outfit_action.Grant(owner)

/datum/action/item_action/chameleon/change/Remove(mob/remove_from)
	. = ..()
	// Likewise when the mob loses the cham change action, if they have no others, they need to lose the outfit action
	if(locate(/datum/action/item_action/chameleon/change) in remove_from.actions)
		return

	var/datum/action/chameleon_outfit/outfit_action = locate() in remove_from.actions
	qdel(outfit_action)

/datum/action/item_action/chameleon/change/proc/initialize_blacklist()
	chameleon_blacklist |= typecacheof(target.type)

/datum/action/item_action/chameleon/change/proc/initialize_disguises()
	name = "Change [chameleon_name] Appearance"
	UpdateButtonIcon()

	LAZYINITLIST(chameleon_typecache)
	LAZYINITLIST(chameleon_list)
	LAZYINITLIST(chameleon_list[chameleon_name])

	if(!ispath(chameleon_type, /obj/item))
		stack_trace("Non-item chameleon type defined on [type] ([chameleon_type])")
		return

	add_chameleon_items(chameleon_type)

/datum/action/item_action/chameleon/change/proc/add_chameleon_items(type_to_add)
	chameleon_typecache |= typecacheof(type_to_add)
	for(var/obj/item/item_type as anything in chameleon_typecache)
		if(chameleon_blacklist[item_type] || (item_type::item_flags & ABSTRACT) || !item_type::icon_state)
			continue
		var/chameleon_item_name = "[replacetext(item_type::name, "\improper","")]_[item_type::icon_state]"
		var/item_exist = FALSE
		for(var/existing_item_name in chameleon_list[chameleon_name])
			if(existing_item_name == chameleon_item_name)
				item_exist = TRUE
				break
		if(!item_exist)
			chameleon_list[chameleon_name][chameleon_item_name] = item_type

/datum/action/item_action/chameleon/change/proc/select_look(mob/user)
	ui_interact(user)

/datum/action/item_action/chameleon/change/proc/random_look()
	var/picked_name = pick(chameleon_list[chameleon_name])
	update_look(chameleon_list[chameleon_name][picked_name])

/datum/action/item_action/chameleon/change/proc/update_look(obj/item/picked_item)
	var/obj/item/chameleon_item = target

	update_item(picked_item)
	active_type = picked_item
	if(ismob(chameleon_item.loc))
		chameleon_item.update_equipped_item()
	else
		UpdateButtonIcon()
	SStgui.update_uis(src)

/datum/action/item_action/chameleon/change/proc/update_item(obj/item/picked_item)
	PROTECTED_PROC(TRUE) // Call update_look, not this!

	var/obj/item/item_target = target
	var/obj/item/fake_item = new picked_item(null)

	item_target.name = fake_item.name
	item_target.desc = fake_item.desc

	item_target.icon = fake_item.icon
	item_target.icon_state = fake_item.post_init_icon_state || fake_item.icon_state
	item_target.item_state = fake_item.item_state
	item_target.item_color = fake_item.item_color
	item_target.lefthand_file = fake_item.lefthand_file
	item_target.righthand_file = fake_item.righthand_file
	if(fake_item.sprite_sheets || fake_item.onmob_sheets)
		item_target.sprite_sheets = fake_item.sprite_sheets
		item_target.onmob_sheets = fake_item.onmob_sheets

	if(fake_item.greyscale_colors)
		var/list/worn_configs = fake_item.greyscale_config_worn
		if(worn_configs)
			for(var/slot in worn_configs)
				item_target.onmob_sheets[slot] = SSgreyscale.get_colored_icon_by_type(
				worn_configs[slot],
				fake_item.greyscale_colors,
			)
		var/list/species_configs = fake_item.greyscale_config_worn_species
		if(species_configs)
			for(var/slot in species_configs)
				item_target.sprite_sheets[slot] = SSgreyscale.get_colored_icon_by_type(
				species_configs[slot],
				fake_item.greyscale_colors,
			)
		if(fake_item.greyscale_config_inhand_left)
			item_target.lefthand_file = SSgreyscale.get_colored_icon_by_type(
				fake_item.greyscale_config_inhand_left,
				fake_item.greyscale_colors,
			)
		if(fake_item.greyscale_config_inhand_right)
			item_target.righthand_file = SSgreyscale.get_colored_icon_by_type(
				fake_item.greyscale_config_inhand_right,
				fake_item.greyscale_colors,
			)

	item_target.flags_inv = fake_item.flags_inv
	item_target.flags_cover = fake_item.flags_cover	// why?

	qdel(fake_item)

/datum/action/item_action/chameleon/change/do_effect(trigger_flags)
	select_look(owner)
	return TRUE

/datum/action/item_action/chameleon/change/proc/emp_randomise(amount = EMP_RANDOMISE_TIME)
	START_PROCESSING(SSprocessing, src)
	random_look()

	COOLDOWN_START(src, emp_timer, amount)

/datum/action/item_action/chameleon/change/process()
	if(COOLDOWN_FINISHED(src, emp_timer))
		STOP_PROCESSING(SSprocessing, src)
		return
	random_look()

/datum/action/item_action/chameleon/change/proc/apply_outfit(datum/outfit/applying_from, list/all_items_to_apply)
	SHOULD_CALL_PARENT(TRUE)

	var/using_item_type
	for(var/item_type in all_items_to_apply)
		if(!ispath(item_type, /obj/item))
			stack_trace("Invalid item type passed to apply_outfit ([item_type])")
			continue
		if(chameleon_typecache[item_type])
			using_item_type = item_type
			break

	if(isnull(using_item_type))
		return FALSE

	if(istype(applying_from, /datum/outfit/job))
		var/datum/outfit/job/job_outfit = applying_from
		var/datum/job/job_datum = SSjobs.GetJobType(job_outfit.jobtype)
		if(job_datum)
			apply_job_data(job_datum)

	update_look(using_item_type)
	all_items_to_apply -= using_item_type
	return TRUE

/// Used when applying this cham item via a job datum (from an outfit selection)
/datum/action/item_action/chameleon/change/proc/apply_job_data(datum/job/job_datum)
	return

#undef EMP_RANDOMISE_TIME
#undef MAX_OUTFIT_NAME_LEN
#undef MAX_CUSTOM_OUTFITS

