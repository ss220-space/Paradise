/obj/item/clothing/suit/storage
	var/pockets_count = 2 // two slots by default
	var/pockets_max_combined_w_class = 4
	w_class = WEIGHT_CLASS_NORMAL //we don't want these to be able to fit in their own pockets.

/obj/item/clothing/suit/storage/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets)
