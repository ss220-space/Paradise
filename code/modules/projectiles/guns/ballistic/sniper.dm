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
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 12, ATTACHMENT_OFFSET_Y = -4),
	)

// MARK: AXMC
/obj/item/gun/projectile/automatic/sniper_rifle/axmc
	name = "axmc sniper rifle"
	desc = "Новейшая модель снайперской винтовки калибра .338, разработанная и изготовленная одной из дочерних компаний \"Нанотрейзен\". Обладает схожими со снайперской винтовкой \"Синдиката\" характеристиками."
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "AXMC"
	item_state = "AXMC"
	mag_type = /obj/item/ammo_box/magazine/a338
	fire_delay = 5.5 SECONDS
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/projectile/automatic/sniper_rifle/axmc/get_ru_names()
	return list(
		NOMINATIVE = "снайперская винтовка axmc",
		GENITIVE = "снайперской винтовки axmc",
		DATIVE = "снайперской винтовке axmc",
		ACCUSATIVE = "снайперскую винтовку axmc",
		INSTRUMENTAL = "снайперской винтовкой axmc",
		PREPOSITIONAL = "снайперской винтовке axmc",
	)

/obj/item/gun/projectile/automatic/sniper_rifle/axmc/attackby(obj/item/item, mob/user, params)
	//TODO: remove it after normal sprite for AXMC
	if(istype(item, /obj/item/gun_module/muzzle/suppressor))
		add_fingerprint(user)
		var/obj/item/gun_module/muzzle/suppressor/suppressor = item
		if(!can_suppress)
			balloon_alert(user, "несовместимо!")
			return ATTACK_CHAIN_PROCEED
		if(suppressed)
			balloon_alert(user, "уже установлено!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(suppressor, src))
			return ..()
		balloon_alert(user, "установлено")
		playsound(loc, 'sound/items/screwdriver.ogg', 40, TRUE)
		suppressed = suppressor
		suppressor.oldsound = fire_sound
		suppressor.initial_w_class = w_class
		fire_sound = 'sound/weapons/gunshots/1suppres.ogg'
		w_class = WEIGHT_CLASS_NORMAL //so pistols do not fit in pockets when suppressed
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/item/gun/projectile/automatic/sniper_rifle/axmc/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "-mag" : ""][suppressed ? "-suppressed" : ""]"
