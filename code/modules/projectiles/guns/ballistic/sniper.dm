// TODO: Merge it with bolt_action_rifles.dm

// MARK: Generic
/obj/item/gun/projectile/automatic/sniper_rifle
	name = "sniper rifle"
	desc = "The kind of gun that will leave you crying for mummy before you even realise your leg's missing."
	icon_state = "sniper"
	item_state = "sniper"
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds
	icon = 'icons/obj/weapons/guns_48x32.dmi'
	suppressed_fire_sound = 'sound/weapons/gunshots/snipersupp.ogg'
	fire_sound = 'sound/weapons/gunshots/1sniper.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	fire_delay = 40
	burst_size = 1
	origin_tech = "combat=7"
	can_suppress = TRUE
	slot_flags = ITEM_SLOT_BACK
	actions_types = null
	accuracy = GUN_ACCURACY_SNIPER
	attachable_allowed = GUN_MODULE_CLASS_SNIPER_MUZZLE | GUN_MODULE_CLASS_SNIPER_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 26, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 12, ATTACHMENT_OFFSET_Y = -4),
	)
	recoil = GUN_RECOIL_MEGA
	fire_modes = GUN_MODE_SINGLE_ONLY

/obj/item/gun/projectile/automatic/sniper_rifle/update_icon_state()
	icon_state = base_icon_state

/obj/item/gun/projectile/automatic/sniper_rifle/update_overlays()
	. = ..()
	if(!magazine)
		return
	. += mutable_appearance(icon, "[base_icon_state]_mag", layer = FLOAT_LAYER - 0.01)


// MARK: Syndicate SR
/obj/item/gun/projectile/automatic/sniper_rifle/syndicate
	name = "syndicate sniper rifle"
	desc = "Syndicate flavoured sniper rifle, it packs quite a punch, a punch to your face."
	origin_tech = "combat=7;syndicate=6"

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator
	name = "syndicate penetrator sniper rifle"
	icon_state = "sniperpenetrator"
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds/compact

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator/Initialize(mapload)
	. = ..()
	desc += " It comes loaded with a penetrator magazine, but can use different magazines."

	QDEL_NULL(magazine)
	magazine = new /obj/item/ammo_box/magazine/sniper_rounds/compact/penetrator(src)

// MARK: Compact Syndicate SR
/obj/item/gun/projectile/automatic/sniper_rifle/compact //holds very little ammo, lacks zooming, and bullets are primarily damage dealers, but the gun lacks the downsides of the full size rifle
	name = "compact sniper rifle"
	desc = "A compact, unscoped version of the standard issue syndicate sniper rifle. Still capable of sending people crying."
	icon_state = "snipercompact"
	weapon_weight = WEAPON_LIGHT
	fire_delay = 2 SECONDS
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds/compact
	accuracy = GUN_ACCURACY_SNIPER
	recoil = GUN_RECOIL_HIGH
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 21, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -4),
	)

// MARK: AXMC
/obj/item/gun/projectile/automatic/sniper_rifle/axmc
	name = "axmc sniper rifle"
	desc = "Новейшая модель снайперской винтовки калибра .338, разработанная и изготовленная одной из дочерних компаний \"Нанотрейзен\". Обладает схожими со снайперской винтовкой \"Синдиката\" характеристиками."
	icon_state = "axmc"
	item_state = "AXMC"
	mag_type = /obj/item/ammo_box/magazine/a338
	fire_delay = 5.5 SECONDS
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 36, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 10, ATTACHMENT_OFFSET_Y = 6),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 17, ATTACHMENT_OFFSET_Y = -4),
	)

/obj/item/gun/projectile/automatic/sniper_rifle/axmc/get_ru_names()
	return list(
		NOMINATIVE = "снайперская винтовка axmc",
		GENITIVE = "снайперской винтовки axmc",
		DATIVE = "снайперской винтовке axmc",
		ACCUSATIVE = "снайперскую винтовку axmc",
		INSTRUMENTAL = "снайперской винтовкой axmc",
		PREPOSITIONAL = "снайперской винтовке axmc",
	)
