//
/datum/component/differentiate_storage_size
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/obj/item/storage/storage
	var/initial_size
	var/expanded_size
	var/folded_size

/datum/component/differentiate_storage_size/Initialize(expanded_size_init, folded_size_init)
	if(!isstorage(parent))
		return COMPONENT_INCOMPATIBLE

	storage = parent
	if(!storage.dynamic_storage_size)
		return

	initial_size = initial(storage.w_class)
	expanded_size = expanded_size_init
	folded_size = folded_size_init ? folded_size_init : initial_size

	RegisterSignals(storage, list(COMSIG_ITEM_REMOVED_FROM_STORAGE, COMSIG_ITEM_INSERTED_INTO_STORAGE), PROC_REF(update_weight))
	update_weight()

/datum/component/differentiate_storage_size/proc/update_weight()
	SIGNAL_HANDLER

	if(initial_size == expanded_size)
		return
	if(!length(storage.contents))
		storage.w_class = folded_size
		return
	storage.w_class = expanded_size
