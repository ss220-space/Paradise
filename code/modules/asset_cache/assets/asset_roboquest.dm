/datum/asset/spritesheet/roboquest
	name = "roboquest"

/datum/asset/spritesheet/roboquest/create_spritesheets()
	for(var/equip_path in subtypesof(/obj/item/mecha_parts/mecha_equipment))
		var/obj/item/equip = new equip_path
		Insert(path2assetID(equip.type), equip.icon, equip.icon_state)
	for(var/path in subtypesof(/datum/roboshop_item))
		var/datum/roboshop_item/item = new path
		Insert(path2assetID(path), item.icon_file, item.icon_name)

/datum/asset/spritesheet/roboquest/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(64, 64)
	return pre_asset

/datum/asset/spritesheet/roboquest_large
	name = "roboquest_large"

/datum/asset/spritesheet/roboquest_large/create_spritesheets()
	for(var/path in subtypesof(/datum/quest_mech))
		var/datum/quest_mech/mecha = new path
		Insert(path2assetID(path), 'icons/obj/mecha/mecha.dmi', mecha.mech_icon)

/datum/asset/spritesheet/roboquest_large/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(128, 128)
	return pre_asset
