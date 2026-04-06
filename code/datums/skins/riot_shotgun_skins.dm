/datum/item_skin_data/gun/riotshotgun
	item_path = /obj/item/gun/projectile/shotgun/riot

/datum/item_skin_data/gun/riotshotgun/default
	name = "Помповый дробовик"
	icon_state = "riotshotgun"
	donation_tier = 1

/datum/item_skin_data/gun/riotshotgun/winchester1887
	name = "Рычажный дробовик"
	icon_state = "winchester"
	item_state = "winchester"
	donation_tier = 1
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 23, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 5, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 9, ATTACHMENT_OFFSET_Y = -4),
	)

/datum/item_skin_data/gun/riotshotgun/winchester1887/on_apply(obj/item/target)
	. = ..()
	var/obj/item/gun/projectile/shotgun/riot/shotgun = target
	if(!istype(shotgun))
		return
	shotgun.reload_sound = 'sound/weapons/gun_interactions/winchester_reload.ogg'
	shotgun.AddElement(/datum/element/item_emote_observer, emote_key = "twirl")
