/datum/item_skin_data
	/// Skin applyed item path
	var/item_path
	/// Name of skin (shown on radial menu)
	var/name
	/// Skin icon dmi (if null - use default item dmi)
	var/icon = null
	/// Skin icon_state
	var/icon_state
	/// Inhands item state
	var/item_state
	/// Icon for radial menu (if null - use icon_state)
	var/menu_icon_state = null
	/// Minimal donater tier (0 for allow all players)
	var/donation_tier = 0

/datum/item_skin_data/proc/on_apply(obj/item/target)
	if(item_state)
		target.item_state = item_state
	return TRUE


//MARK: Gun skins
/datum/item_skin_data/gun
	/// Override attachables offset for gun (see more gun.dm)
	var/attachable_offset = null

/datum/item_skin_data/gun/on_apply(obj/item/target)
	. = ..()
	if(!isgun(target))
		return
	var/obj/item/gun/gun = target
	if(attachable_offset)
		gun.attachable_offset = attachable_offset
		gun.update_attachment_overlays()
