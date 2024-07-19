/// Mining vendor items sprites for UIs
/datum/asset/spritesheet/mining_vendor
	name = "mining_vendor"

/datum/asset/spritesheet/mining_vendor/create_spritesheets()
	var/items_list = list()
	for(var/category in GLOB.mining_vendor_items)
		for(var/item in GLOB.mining_vendor_items[category])
			var/datum/data/mining_equipment/new_equip = GLOB.mining_vendor_items[category][item]
			var/obj/new_item = new new_equip.equipment_path
			items_list[ckeyEx(new_equip.equipment_name)] = new_item
	for(var/item_name in items_list)
		var/obj/new_item = items_list[item_name]
		Insert(item_name, new_item.icon, new_item.icon_state)
		qdel(new_item)

/datum/asset/spritesheet/mining_vendor/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(64, 64)
	return pre_asset
