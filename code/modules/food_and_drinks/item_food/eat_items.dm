/// Helper eat_items procs are located here.
/obj/item/proc/try_item_eat(mob/target, mob/user)
	if(!is_eatable) 
		return FALSE
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/human = target
	if(!(material_type & human.dna.species.special_diet))
		return FALSE
	if(is_only_grab_intent && user.a_intent != INTENT_GRAB)
		return FALSE
	return TRUE

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
