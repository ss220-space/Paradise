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
		ATTACHMENT_SLOT_MUZZLE = list("x" = 26, "y" = 1),
		ATTACHMENT_SLOT_RAIL = list("x" = 6, "y" = 5),
		ATTACHMENT_SLOT_UNDER = list("x" = 12, "y" = -4),
	)
	recoil = GUN_RECOIL_MEGA
	fire_modes = GUN_MODE_SINGLE_ONLY

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
		ATTACHMENT_SLOT_MUZZLE = list("x" = 21, "y" = 1),
		ATTACHMENT_SLOT_RAIL = list("x" = 6, "y" = 5),
		ATTACHMENT_SLOT_UNDER = list("x" = 12, "y" = -4),
	)



/obj/projectile/bullet/sniper
	//speed = 0.75
	//range = 100
	damage = 70
	weaken = 4 SECONDS
	dismemberment = 50
	armour_penetration = 50
	forced_accuracy = TRUE
	var/breakthings = TRUE

/obj/projectile/bullet/sniper/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && (!ismob(target) && breakthings))
		target.ex_act(rand(EXPLODE_DEVASTATE, EXPLODE_HEAVY))

	return ..()

//Sleepy ammo




/obj/projectile/bullet/sniper/soporific
	armour_penetration = 0
	nodamage = TRUE
	dismemberment = 0
	weaken = 0
	breakthings = FALSE
	var/sleep_time = 40 SECONDS

/obj/projectile/bullet/sniper/soporific/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && isliving(target))
		var/mob/living/L = target
		L.SetSleeping(sleep_time)

	return ..()

//hemorrhage ammo




/obj/projectile/bullet/sniper/explosive
	weaken = 6 SECONDS
	stun = 6 SECONDS
	damage = 85
	dismemberment = 0
	ricochets_max = 0

/obj/projectile/bullet/sniper/explosive/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && (!ismob(target, /mob/living) && breakthings))
		explosion(target, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flash_range = 5, cause = "[type] fired by [key_name(firer)]")

	return ..()

//hemorrhage ammo




/obj/projectile/bullet/sniper/haemorrhage
	armour_penetration = 15
	damage = 15
	dismemberment = 0
	weaken = 0
	breakthings = FALSE
	var/bleeding = 100

/obj/projectile/bullet/sniper/haemorrhage/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.bleed(bleeding)

	return ..()



/obj/projectile/bullet/sniper/penetrator
	icon_state = "gauss"
	name = "penetrator round"
	damage = 60
	forcedodge = -1
	dismemberment = 0
	weaken = 0
	breakthings = FALSE

//compact and penetrator ammo to avoid taipan abuse by traitors




/obj/projectile/bullet/sniper/compact //Can't dismember, and can't break things; just deals massive damage.
	knockdown = 4 SECONDS
	weaken = 0
	breakthings = FALSE
	dismemberment = 0









//toy magazine


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





/obj/projectile/bullet/sniper/a338
	damage = 80
	dismemberment = 0

//Sleepy ammo




/obj/projectile/bullet/sniper/soporific/a338

//hemorrhage ammo




/obj/projectile/bullet/sniper/explosive/a338

//hemorrhage ammo




/obj/projectile/bullet/sniper/haemorrhage/a338

//penetrator ammo




/obj/projectile/bullet/sniper/penetrator/a338

/obj/item/ammo_box/a338
	name = "Box of sniper rounds (.338)"
	desc = "Коробка, содержащая снайперские патроны .338 калибра."
	icon_state = "ammobox_338"
	origin_tech = "combat=5"
	ammo_type = /obj/item/ammo_casing/a338
	max_ammo = 20

/obj/item/ammo_box/a338/get_ru_names()
	return list(
		NOMINATIVE = "коробка снайперских патронов (.338)",
		GENITIVE = "коробки снайперских патронов (.338)",
		DATIVE = "коробке снайперских патронов (.338)",
		ACCUSATIVE = "коробку снайперских патронов (.338)",
		INSTRUMENTAL = "коробкой снайперских патронов (.338)",
		PREPOSITIONAL = "коробке снайперских патронов (.338)",
	)

/obj/item/ammo_box/a338/explosive
	name = "Box of explosive sniper rounds (.338)"
	desc = "Коробка, содержащая разрывные снайперские патроны .338 калибра."
	ammo_type = /obj/item/ammo_casing/a338_explosive

/obj/item/ammo_box/a338/explosive/get_ru_names()
	return list(
		NOMINATIVE = "коробка разрывных снайперских патронов (.338)",
		GENITIVE = "коробки разрывных снайперских патронов (.338)",
		DATIVE = "коробке разрывных снайперских патронов (.338)",
		ACCUSATIVE = "коробку разрывных снайперских патронов (.338)",
		INSTRUMENTAL = "коробкой разрывных снайперских патронов (.338)",
		PREPOSITIONAL = "коробке разрывных снайперских патронов (.338)",
	)

/obj/item/ammo_box/a338/penetrator
	name = "Box of penetrator sniper rounds (.338)"
	desc = "Коробка, содержащая проникающие снайперские патроны .338 калибра."
	ammo_type = /obj/item/ammo_casing/a338_penetrator

/obj/item/ammo_box/a338/penetrator/get_ru_names()
	return list(
		NOMINATIVE = "коробка проникающих снайперских патронов (.338)",
		GENITIVE = "коробки проникающих снайперских патронов (.338)",
		DATIVE = "коробке проникающих снайперских патронов (.338)",
		ACCUSATIVE = "коробку проникающих снайперских патронов (.338)",
		INSTRUMENTAL = "коробкой проникающих снайперских патронов (.338)",
		PREPOSITIONAL = "коробке проникающих снайперских патронов (.338)",
	)
