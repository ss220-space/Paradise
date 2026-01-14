/datum/asset/spritesheet_batched/materials
	name = "materials"

/datum/asset/spritesheet_batched/materials/create_spritesheets()
	for(var/datum/material/material_typepath as anything in subtypesof(/datum/material))
		var/obj/item/stack/stack_type = initial(material_typepath.sheet_type)
		if(!stack_type)
			continue

		insert_icon(material_typepath.id, uni_icon(stack_type.icon, stack_type.icon_state))
