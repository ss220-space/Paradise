/// Cargo quest items sprites for UIs
/datum/asset/spritesheet/cargo_quest
	name = "cargo_quest"

/datum/asset/spritesheet/cargo_quest/create_spritesheets()
	var/list/id_to_item = list()
	id_to_item[path2assetID(/obj/item/reagent_containers/glass/beaker/large)] = new /obj/item/reagent_containers/glass/beaker/large
	id_to_item[path2assetID(/obj/item/storage/box)] = new /obj/item/storage/box
	for(var/quest_thing_path in subtypesof(/datum/cargo_quest/thing))
		var/datum/cargo_quest/thing/quest_thing = new quest_thing_path(null, TRUE)
		for(var/thing_path in (list(quest_thing.item_for_show) + quest_thing.easy_items + quest_thing.normal_items + quest_thing.hard_items))
			if(!ispath(thing_path, /obj/item))
				continue
			var/obj/item/thing = new thing_path
			id_to_item[path2assetID(thing)] = thing
	for(var/id in id_to_item)
		var/obj/item/new_item = id_to_item[id]
		Insert(id, new_item.icon, new_item.icon_state)
	var/list/reagent_ids = list()
	for(var/quest_reagent_path in subtypesof(/datum/cargo_quest/reagents))
		var/datum/cargo_quest/reagents/quest_reagent = new quest_reagent_path(null, TRUE)
		for(var/reagent_id in (quest_reagent.repeated_reagents + quest_reagent.unique_reagents))
			reagent_ids |= reagent_id
	for(var/reagent_id in reagent_ids)
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_id]
		if(reagent.drink_icon)
			Insert(ckeyEx(reagent_id), 'icons/obj/drinks.dmi', reagent.drink_icon)


/datum/asset/spritesheet/cargo_quest/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(42, 42)
	return pre_asset
