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
	update_weight()

/datum/component/differentiate_storage_size/Destroy()
	UnregisterSignal(storage, list(COMSIG_ITEM_REMOVED_FROM_STORAGE, COMSIG_ITEM_INSERTED_INTO_STORAGE))
	storage = null
	return ..()

/// Checks the storage contents and updates its weight class to either folded_size or expanded_size.
/datum/component/differentiate_storage_size/proc/update_weight()
	SIGNAL_HANDLER

	if(initial_size == expanded_size)
		return
	if(!length(storage.contents))
		storage.w_class = folded_size
		return
	storage.w_class = expanded_size
