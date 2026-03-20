/datum/asset/spritesheet_batched/alloys
	name = "alloys"

/datum/asset/spritesheet_batched/alloys/create_spritesheets()
	for(var/datum/design/smelter/alloy_typepath as anything in subtypesof(/datum/design/smelter) + /datum/design/rglass)
		var/obj/item/stack/stack_type = initial(alloy_typepath.build_path)
		if(!stack_type)
			continue

		insert_icon(alloy_typepath.id, uni_icon(stack_type.icon, stack_type.icon_state))
