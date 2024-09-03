/obj/item/proc/item_string_material()
	var/material_string
	switch(material_type)
		if(MATERIAL_CLASS_CLOTH)
			material_string = "\nТканевый предмет."
		if(MATERIAL_CLASS_TECH)
			material_string = "\nТехнологичный предмет."
		if(MATERIAL_CLASS_SOAP)
			material_string = "\nМыльный предмет."
	return material_string
