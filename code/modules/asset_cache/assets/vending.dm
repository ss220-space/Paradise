/datum/asset/spritesheet_batched/vending
	name = "vending"

/datum/asset/spritesheet_batched/vending/create_spritesheets()
	// initialising the list of items we need
	var/target_items = list()
	for(var/obj/machinery/vending/vendor as anything in subtypesof(/obj/machinery/vending))
		vendor = new vendor() // It seems `initial(list var)` has nothing. need to make a type.
		target_items |= vendor.products
		target_items |= vendor.premium
		target_items |= vendor.contraband
		qdel(vendor)
	// building icons for each item
	for (var/atom/item as anything in target_items)
		if (!ispath(item, /atom))
			continue

		var/icon_state = initial(item.icon_state)
		if(ispath(item, /obj))
			var/obj/obj_atom = item
			if(initial(obj_atom.icon_state_preview))
				icon_state = initial(obj_atom.icon_state_preview)
		var/has_gags = initial(item.greyscale_config) && initial(item.greyscale_colors)
		var/has_color = initial(item.color) && icon_state
		// GAGS and colored icons must be pregenerated
		// Otherwise we can rely on DMIcon, so skip it to save init time
		if(!has_gags && !has_color)
			continue

		var/imgid = replacetext(replacetext("[item]", "/obj/item/", ""), "/", "-")
		insert_icon(imgid, get_display_icon_for(item))
