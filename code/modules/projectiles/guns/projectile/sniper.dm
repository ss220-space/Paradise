/obj/item/gun/projectile/automatic/sniper_rifle
	name = "sniper rifle"
	desc = "The kind of gun that will leave you crying for mummy before you even realise your leg's missing."
	icon_state = "sniper"
	item_state = "sniper"
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds
	fire_sound = 'sound/weapons/gunshots/1sniper.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	fire_delay = 40
	burst_size = 1
	origin_tech = "combat=7"
	can_suppress = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	zoomable = TRUE
	zoom_amt = 7 //Long range, enough to see in front of you, but no tiles behind you.
	slot_flags = ITEM_SLOT_BACK
	actions_types = null
	accuracy = GUN_ACCURACY_SNIPER
	attachable_allowed = GUN_MODULE_CLASS_NONE
	recoil = GUN_RECOIL_MEGA

/obj/item/gun/projectile/automatic/sniper_rifle/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/gun_module/muzzle/suppressor))
		add_fingerprint(user)
		var/obj/item/gun_module/muzzle/suppressor/suppressor = I
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

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate
	name = "syndicate sniper rifle"
	desc = "Syndicate flavoured sniper rifle, it packs quite a punch, a punch to your face."
	origin_tech = "combat=7;syndicate=6"

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator
	name = "syndicate penetrator sniper rifle"
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds/compact

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator/Initialize(mapload)
	. = ..()
	desc += " It comes loaded with a penetrator magazine, but can use different magazines."

	QDEL_NULL(magazine)
	magazine = new /obj/item/ammo_box/magazine/sniper_rounds/compact/penetrator(src)


/obj/item/gun/projectile/automatic/sniper_rifle/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "-mag" : ""][suppressed ? "-suppressed" : ""]"


/obj/item/gun/projectile/automatic/sniper_rifle/compact //holds very little ammo, lacks zooming, and bullets are primarily damage dealers, but the gun lacks the downsides of the full size rifle
	name = "compact sniper rifle"
	desc = "A compact, unscoped version of the standard issue syndicate sniper rifle. Still capable of sending people crying."
	icon_state = "snipercompact"
	weapon_weight = WEAPON_LIGHT
	fire_delay = 2 SECONDS
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds/compact
	zoomable = FALSE
	accuracy = GUN_ACCURACY_SNIPER
	recoil = GUN_RECOIL_HIGH

//Normal Boolets
/obj/item/ammo_box/magazine/sniper_rounds
	name = "sniper rounds (.50)"
	icon_state = ".50mag"
	origin_tech = "combat=6"
	ammo_type = /obj/item/ammo_casing/point50
	max_ammo = 5
	caliber = ".50"

/obj/item/ammo_box/magazine/sniper_rounds/update_icon_state()
	if(ammo_count())
		icon_state = "[initial(icon_state)]-ammo"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/ammo_casing/point50
	desc = "A .50 bullet casing."
	caliber = ".50"
	projectile_type = /obj/projectile/bullet/sniper
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	icon_state = ".50"

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
/obj/item/ammo_box/magazine/sniper_rounds/soporific
	name = "sniper rounds (Zzzzz)"
	desc = "Soporific sniper rounds, designed for happy days and dead quiet nights..."
	icon_state = "soporific"
	origin_tech = "combat=6"
	ammo_type = /obj/item/ammo_casing/soporific
	max_ammo = 3

/obj/item/ammo_casing/soporific
	desc = "A .50 bullet casing, specialised in sending the target to sleep, instead of hell."
	caliber = ".50"
	projectile_type = /obj/projectile/bullet/sniper/soporific
	icon_state = ".50sop"
	harmful = FALSE

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
/obj/item/ammo_box/magazine/sniper_rounds/explosive
	name = "sniper rounds (boom)"
	desc = "What did you mean by saying warcrimes? There wasn't any millitary"
	icon_state = "explosive"
	ammo_type = /obj/item/ammo_casing/explosive
	max_ammo = 5

/obj/item/ammo_casing/explosive
	desc = "A .50 bullet casing, specialised in destruction"
	caliber = ".50"
	projectile_type = /obj/projectile/bullet/sniper/explosive
	icon_state = ".50exp"

/obj/projectile/bullet/sniper/explosive
	armour_penetration = 50
	damage = 85
	stun = 6 SECONDS
	dismemberment = 0
	weaken = 6 SECONDS
	breakthings = TRUE

/obj/projectile/bullet/sniper/explosive/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && (!ismob(target, /mob/living) && breakthings))
		explosion(target, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flash_range = 5, cause = "[type] fired by [key_name(firer)]")

	return ..()

//hemorrhage ammo
/obj/item/ammo_box/magazine/sniper_rounds/haemorrhage
	name = "sniper rounds (Bleed)"
	desc = "Haemorrhage sniper rounds, leaves your target in a pool of crimson pain"
	icon_state = "haemorrhage"
	ammo_type = /obj/item/ammo_casing/haemorrhage
	max_ammo = 5

/obj/item/ammo_casing/haemorrhage
	desc = "A .50 bullet casing, specialised in causing massive bloodloss"
	caliber = ".50"
	projectile_type = /obj/projectile/bullet/sniper/haemorrhage
	icon_state = ".50exp"

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

//penetrator ammo
/obj/item/ammo_box/magazine/sniper_rounds/penetrator
	name = "sniper rounds (penetrator)"
	desc = "An extremely powerful round capable of passing straight through cover and anyone unfortunate enough to be behind it."
	icon_state = "penetrator"
	ammo_type = /obj/item/ammo_casing/penetrator
	origin_tech = "combat=6"
	max_ammo = 5

/obj/item/ammo_casing/penetrator
	desc = "A .50 caliber penetrator round casing."
	caliber = ".50"
	projectile_type = /obj/projectile/bullet/sniper/penetrator
	icon_state = ".50pen"

/obj/projectile/bullet/sniper/penetrator
	icon_state = "gauss"
	name = "penetrator round"
	damage = 60
	forcedodge = -1
	dismemberment = 0
	weaken = 0
	breakthings = FALSE

//compact and penetrator ammo to avoid taipan abuse by traitors
/obj/item/ammo_box/magazine/sniper_rounds/compact
	name = "sniper rounds (compact)"
	desc = "An extremely powerful round capable of inflicting massive damage on a target."
	ammo_type = /obj/item/ammo_casing/compact
	max_ammo = 4
	caliber = ".50L"

/obj/item/ammo_casing/compact
	desc = "A .50 caliber compact round casing."
	caliber = ".50L"
	projectile_type = /obj/projectile/bullet/sniper/compact
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	icon_state = ".50"

/obj/projectile/bullet/sniper/compact //Can't dismember, and can't break things; just deals massive damage.
	damage = 70
	knockdown = 4 SECONDS
	armour_penetration = 50
	breakthings = FALSE
	dismemberment = 0

/obj/item/ammo_box/magazine/sniper_rounds/compact/penetrator
	name = "penetrator sniper rounds(compact)"
	desc = "An extremely powerful round capable of passing straight through cover and anyone unfortunate enough to be behind it."
	icon_state = "penetrator"
	ammo_type = /obj/item/ammo_casing/compact/penetrator
	origin_tech = "combat=6"
	max_ammo = 5

/obj/item/ammo_casing/compact/penetrator
	desc = "A .50 caliber penetrator round casing."
	projectile_type = /obj/projectile/bullet/sniper/penetrator
	icon_state = ".50pen"

/obj/item/ammo_box/magazine/sniper_rounds/compact/soporific
	name = "soporofic sniper rounds(compact)"
	desc = "Soporific sniper rounds, designed for happy days and dead quiet nights..."
	icon_state = "soporific"
	origin_tech = "combat=6"
	ammo_type = /obj/item/ammo_casing/compact/soporific
	max_ammo = 3

/obj/item/ammo_casing/compact/soporific
	desc = "A .50 bullet casing, specialised in sending the target to sleep, instead of hell."
	projectile_type = /obj/projectile/bullet/sniper/soporific
	icon_state = ".50sop"
	harmful = FALSE

//toy magazine
/obj/item/ammo_box/magazine/toy/sniper_rounds
	name = "donksoft Sniper magazine"
	icon_state = ".50mag"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper/riot
	max_ammo = 6
	caliber = "foam_force_sniper"


/obj/item/ammo_box/magazine/toy/sniper_rounds/update_icon_state()
	return


/obj/item/ammo_box/magazine/toy/sniper_rounds/update_overlays()
	. = ..()
	var/ammo = ammo_count()
	if(ammo && istype(contents[length(contents)], /obj/item/ammo_casing/caseless/foam_dart/sniper/riot))
		. += ".50mag-r"
	else if(ammo)
		. += ".50mag-f"


/obj/item/gun/projectile/automatic/sniper_rifle/axmc
	name = "axmc sniper rifle"
	desc = "Новейшая модель снайперской винтовки калибра .338, разработанная и изготовленная одной из дочерних компаний Нанотрейзен. Обладает схожими со снайперской винтовкой Синдиката характеристиками."
	ru_names = list(
		NOMINATIVE = "снайперская винтовка axmc",
		GENITIVE = "снайперской винтовки axmc",
		DATIVE = "снайперской винтовке axmc",
		ACCUSATIVE = "снайперскую винтовку axmc",
		INSTRUMENTAL = "снайперской винтовкой axmc",
		PREPOSITIONAL = "снайперской винтовке axmc",
	)
	icon_state = "AXMC"
	item_state = "AXMC"
	mag_type = /obj/item/ammo_box/magazine/a338
	fire_delay = 5.5 SECONDS

/obj/item/ammo_box/magazine/a338
	name = "sniper rounds (.338)"
	ru_names = list(
		NOMINATIVE = "снайперские патроны .338",
		GENITIVE = "снайперских патронов .338",
		DATIVE = "снайперским патронам .338",
		ACCUSATIVE = "снайперские патроны .338",
		INSTRUMENTAL = "снайперскими патронами .338",
		PREPOSITIONAL = "снайперских патронах .338",
	)
	icon_state = ".338mag"
	origin_tech = "combat=6"
	ammo_type = /obj/item/ammo_casing/a338
	max_ammo = 10
	caliber = ".338"

/obj/item/ammo_box/magazine/a338/update_icon_state()
	if(ammo_count())
		icon_state = "[initial(icon_state)]-ammo"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/ammo_casing/a338
	desc = "Гильзя калибра .338."
	caliber = ".338"
	projectile_type = /obj/projectile/bullet/sniper/a338
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	icon_state = ".50"

/obj/projectile/bullet/sniper/a338
	damage = 80
	dismemberment = 0

//Sleepy ammo
/obj/item/ammo_box/magazine/a338/soporific
	name = "sniper rounds .338 (Zzzzz)"
	ru_names = list(
		NOMINATIVE = "снайперские патроны .338 (усыпляющие)",
		GENITIVE = "снайперских патронов .338 (усыпляющих)",
		DATIVE = "снайперским патронам .338 (усыпляющим)",
		ACCUSATIVE = "снайперские патроны .338 (усыпляющие)",
		INSTRUMENTAL = "снайперскими патронами .338 (усыпляющими)",
		PREPOSITIONAL = "снайперских патронах .338 (усыпляющих)",
	)
	desc = "Усыпляющие снайперские патроны калибра .338, созданные для счастливых дней и тихих ночей..."
	icon_state = ".338soporific"
	origin_tech = "combat=6"
	ammo_type = /obj/item/ammo_casing/a338_soporific
	max_ammo = 6

/obj/item/ammo_casing/a338_soporific
	caliber = ".338"
	projectile_type = /obj/projectile/bullet/sniper/soporific/a338
	icon_state = ".50sop"
	harmful = FALSE

/obj/projectile/bullet/sniper/soporific/a338

//hemorrhage ammo
/obj/item/ammo_box/magazine/a338/explosive
	name = "sniper rounds .338 (boom)"
	ru_names = list(
		NOMINATIVE = "снайперские патроны .338 (разрывные)",
		GENITIVE = "снайперских патронов .338 (разрывных)",
		DATIVE = "снайперским патронам .338 (разрывным)",
		ACCUSATIVE = "снайперские патроны .338 (разрывные)",
		INSTRUMENTAL = "снайперскими патронами .338 (разрывными)",
		PREPOSITIONAL = "снайперских патронах .338 (разрывных)",
	)
	desc = "Что вы имели в виду, говоря о военных преступлениях? Не было никаких военных."
	icon_state = ".338explosive"
	ammo_type = /obj/item/ammo_casing/a338_explosive
	max_ammo = 10

/obj/item/ammo_casing/a338_explosive
	caliber = ".338"
	projectile_type = /obj/projectile/bullet/sniper/explosive/a338
	icon_state = ".50exp"

/obj/projectile/bullet/sniper/explosive/a338

//hemorrhage ammo
/obj/item/ammo_box/magazine/a338/haemorrhage
	name = "sniper rounds 338 (Bleed)"
	ru_names = list(
		NOMINATIVE = "снайперские патроны .338 (кровопускающие)",
		GENITIVE = "снайперских патронов .338 (кровопускающих)",
		DATIVE = "снайперским патронам .338 (кровопускающим)",
		ACCUSATIVE = "снайперские патроны .338 (кровопускающие)",
		INSTRUMENTAL = "снайперскими патронами .338 (кровопускающими)",
		PREPOSITIONAL = "снайперских патронах .338 (кровопускающих)",
	)
	desc = "Кровопускающие снайперские выстрелы, оставляют вашу цель в луже кровавой боли"
	icon_state = ".338haemorrhage"
	ammo_type = /obj/item/ammo_casing/a338_haemorrhage
	max_ammo = 10

/obj/item/ammo_casing/a338_haemorrhage
	caliber = ".338"
	projectile_type = /obj/projectile/bullet/sniper/haemorrhage/a338
	icon_state = ".50exp"

/obj/projectile/bullet/sniper/haemorrhage/a338

//penetrator ammo
/obj/item/ammo_box/magazine/a338/penetrator
	name = "sniper rounds 338 (penetrator)"
	ru_names = list(
		NOMINATIVE = "снайперские патроны .338 (проникающие)",
		GENITIVE = "снайперских патронов .338 (проникающих)",
		DATIVE = "снайперским патронам .338 (проникающим)",
		ACCUSATIVE = "снайперские патроны .338 (проникающие)",
		INSTRUMENTAL = "снайперскими патронами .338 (проникающими)",
		PREPOSITIONAL = "снайперских патронах .338 (проникающих)",
	)
	desc = "Чрезвычайно мощный патрон, способный пронзить укрытие и любого, кому не повезло оказаться за ним."
	icon_state = ".338penetrator"
	ammo_type = /obj/item/ammo_casing/a338_penetrator
	origin_tech = "combat=6"
	max_ammo = 10

/obj/item/ammo_casing/a338_penetrator
	caliber = ".338"
	projectile_type = /obj/projectile/bullet/sniper/penetrator/a338
	icon_state = ".50pen"

/obj/projectile/bullet/sniper/penetrator/a338
