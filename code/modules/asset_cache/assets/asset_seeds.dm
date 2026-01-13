/// Cargo quest items sprites for UIs
/datum/asset/spritesheet_batched/seeds
	name = "seeds"

/datum/asset/spritesheet_batched/seeds/create_spritesheets()
	for(var/path in subtypesof(/obj/item/seeds))
		var/obj/item/seeds = new path
		insert_icon(path2assetID(seeds.type), uni_icon(seeds.icon, seeds.icon_state))

