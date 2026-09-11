/// Component that dynamically toggles a storage item's weight class (w_class) based on whether it is completely empty or contains any items.
/// Note: This component operates in a strict binary mode, not progressively. It instantly resizes the storage to its maximum expanded size
/// as soon as a single item is placed inside, rather than scaling up incrementally based on the volume or number of stored items.
/datum/component/differentiate_storage_size
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Reference to the parent object cast as a storage item.
	var/obj/item/storage/storage
	/// The original weight class of the storage item before the component was attached.
	var/initial_size
	/// The weight class of the storage item when it contains at least one item.
	var/expanded_size
	/// The weight class of the storage item when it is empty. Falls back to initial_size if not specified.
	var/folded_size

/datum/component/differentiate_storage_size/Initialize(expanded_size_init, folded_size_init)
	if(!isstorage(parent))
		return COMPONENT_INCOMPATIBLE

	storage = parent

	initial_size = initial(storage.w_class)
	expanded_size = expanded_size_init
	folded_size = folded_size_init ? folded_size_init : initial_size

	RegisterSignals(storage, list(COMSIG_ITEM_REMOVED_FROM_STORAGE, COMSIG_ITEM_INSERTED_INTO_STORAGE), PROC_REF(update_weight))
	RegisterSignal(storage, COMSIG_PRE_INSERT_INTO_STORAGE, PROC_REF(check_insertion_possibility_before_update))
	RegisterSignal(storage, COMSIG_CHECK_DIFFERENTIATE_SIZE_COMPONENT, PROC_REF(return_component_existent))
	RegisterSignal(storage, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	update_weight()

/datum/component/differentiate_storage_size/Destroy()
	UnregisterSignal(storage, list(
		COMSIG_ITEM_REMOVED_FROM_STORAGE,
		COMSIG_ITEM_INSERTED_INTO_STORAGE,
		COMSIG_PRE_INSERT_INTO_STORAGE,
		COMSIG_CHECK_DIFFERENTIATE_SIZE_COMPONENT,
		COMSIG_ATOM_EXAMINE))
	storage = null
	return ..()

/// Checks the storage contents and updates its weight class to either folded_size or expanded_size.
/datum/component/differentiate_storage_size/proc/update_weight(datum/source)
	SIGNAL_HANDLER

	if(initial_size == expanded_size)
		return
	if(!length(storage.contents))
		storage.w_class = folded_size
		return
	storage.w_class = expanded_size

/// Checks some item inserting possible blocking conditions.
/datum/component/differentiate_storage_size/proc/check_insertion_possibility_before_update(datum/source, user)
	SIGNAL_HANDLER

	var/mob/mob_user
	if(user && ismob(user))
		mob_user = user

	var/storage_loc = storage.loc
	if(isstorage(storage_loc) && !istype(src, /obj/item/storage/backpack/holding))
		mob_user?.balloon_alert(mob_user, "не хватит места!")
		return BLOCK_INSERTING_ITEM

	if(ishuman(storage_loc))
		var/mob/living/carbon/human/loc_human = storage_loc
		var/slot_by_item = loc_human.get_slot_by_item(storage)
		if((storage.slot_flags_2 & ITEM_FLAG_POCKET_LARGE) || !(ITEM_SLOT_POCKETS & slot_by_item))
			return
		mob_user?.balloon_alert(mob_user, "не хватит места!")
		return BLOCK_INSERTING_ITEM

/// For checking this component's existence on some storage.
/datum/component/differentiate_storage_size/proc/return_component_existent()
	SIGNAL_HANDLER

	return HAS_DIFFERENTIATE_SIZE_COMPONENT

/// Examine info.
/datum/component/differentiate_storage_size/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_notice("Размер <b>изменяется</b> в зависимости от наличия содержимого.")
