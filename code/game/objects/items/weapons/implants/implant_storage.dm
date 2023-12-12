/obj/item/implant/storage
	name = "storage bio-chip"
	desc = "Stores up to two big items in a bluespace pocket."
	icon_state = "storage_old"
	implant_state = "implant-syndicate"
	origin_tech = "materials=2;magnets=4;bluespace=5;syndicate=4"
	item_color = "r"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	implant_data = /datum/implant_fluff/storage
	var/obj/item/storage/hidden/implant/storage


/obj/item/implant/storage/Initialize(mapload)
	. = ..()
	storage = new /obj/item/storage/hidden/implant(src)


/obj/item/implant/storage/emp_act(severity)
	..()
	storage.emp_act(severity)


/obj/item/implant/storage/activate(cause)
	if(!length(storage.mobs_viewing))
		storage.MouseDrop(imp_in)
	else
		for(var/mob/to_close in storage.mobs_viewing)
			storage.close(to_close)


/obj/item/implant/storage/removed(mob/living/source)
	. = ..()
	if(!.)
		return .

	for(var/mob/check in range(1))
		if(check.s_active == storage)
			storage.close(check)

	for(var/obj/item/item in storage)
		storage.remove_from_storage(item, drop_location())


/obj/item/implant/storage/implant(mob/living/source, mob/user, force = FALSE)
	var/obj/item/implant/storage/imp_e = locate(src.type) in source
	if(imp_e)
		imp_e.storage.storage_slots += storage.storage_slots
		imp_e.storage.max_combined_w_class += storage.max_combined_w_class
		imp_e.storage.contents += storage.contents

		for(var/mob/check in range(1))
			if(check.s_active == storage)
				storage.close(check)
		storage.show_to(source)

		qdel(src)
		return TRUE

	return ..()


/obj/item/implant/storage/proc/get_contents() //Used for swiftly returning a list of the implant's contents i.e. for checking a theft objective's completion.
	if(storage && storage.contents)
		return storage.contents


/obj/item/implanter/storage
	name = "bio-chip implanter (storage)"
	imp = /obj/item/implant/storage


/obj/item/implantcase/storage
	name = "bio-chip case - 'Storage'"
	desc = "A glass case containing a storage bio-chip."
	imp = /obj/item/implant/storage


/obj/item/storage/hidden/implant
	name = "bluespace pocket"
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = WEIGHT_CLASS_GIGANTIC
	w_class = WEIGHT_CLASS_BULKY
	cant_hold = list(/obj/item/disk/nuclear)
	w_class_override = list(/obj/item/storage/belt)
	silent = TRUE

