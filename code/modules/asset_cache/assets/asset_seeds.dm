/// Cargo quest items sprites for UIs
/datum/asset/spritesheet/seeds
	name = "seeds"

/datum/asset/spritesheet/seeds/create_spritesheets()
	for(var/path in subtypesof(/obj/item/seeds))
		var/obj/item/seeds = new path
		Insert(path2assetID(seeds.type), seeds.icon, seeds.icon_state)

