// MARK: Hitscan
/obj/item/gun/energy/laser/hitscan
	name = "хитскан пушка"
	desc = "Родитель всего хитскан оружия. Гиммик этой серии это собственно хитскан. Если вы это видите, пишите баг репорт."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hitscan)
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BELT

/obj/item/gun/energy/laser/hitscan/attackby(obj/item/item, mob/user, params)
	if(!is_laser_modification_case(item))
		return ..()

	var/choosen_weapon
	var/list/upgradable_variants = list(
		"карабин «Страж»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "lasergun"),
		"пистолет «Шершень»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "laserpistol"),
		"автомат «Зенит»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "lasermg"),
		"дробовик «Фокус»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "lasershotgun"),
		"снайперская винтовка «Игла»" = image(icon = 'icons/obj/weapons/guns_48x32.dmi', icon_state = "laserrifle"),
	)
	var/choosen_type = show_radial_menu(user, item, upgradable_variants, src, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!choosen_type || !check_menu(user) || item.loc != user)
		return ATTACK_CHAIN_PROCEED

	switch(choosen_type)
		if("карабин «Страж»")
			choosen_weapon = /obj/item/gun/energy/laser/hitscan/carbine
		if("пистолет «Шершень»")
			choosen_weapon = /obj/item/gun/energy/laser/hitscan/pistol
		if("автомат «Зенит»")
			choosen_weapon = /obj/item/gun/energy/laser/hitscan/assault_mg
		if("дробовик «Фокус»")
			choosen_weapon = /obj/item/gun/energy/laser/hitscan/shotgun
		if("снайперская винтовка «Игла»")
			choosen_weapon = /obj/item/gun/energy/laser/hitscan/sniper_rifle

	if(!choosen_weapon)
		return ATTACK_CHAIN_PROCEED

	if(choosen_weapon == src.type)
		user.balloon_alert(user, "уже модифицировано в это!")
		return ATTACK_CHAIN_PROCEED

	user.balloon_alert(user, "модификация оружия...")
	if(!do_after(user, 10 SECONDS))
		return ATTACK_CHAIN_PROCEED

	var/turf/spawn_turf = get_turf(user)
	var/obj/item/new_gun = new choosen_weapon(spawn_turf)

	user.temporarily_remove_item_from_inventory(item)
	qdel(item)

	user.put_in_hands(new_gun)
	playsound(user, 'sound/machines/ding.ogg', 50, TRUE)
	do_sparks(3, TRUE, spawn_turf)

	user.temporarily_remove_item_from_inventory(src)
	qdel(src)


	return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

/obj/item/gun/energy/laser/hitscan/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

// MARK: Hitscan carbine
/obj/item/gun/energy/laser/hitscan/carbine
	name = "Mk.3 laser gun"
	desc = "Третье поколение стандартной лазерной винтовки службы безопасности. Важнейшим отличием от ранних моделей является импульсная система ведения огня."
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 9, "y" = -5),
	)

/obj/item/gun/energy/laser/hitscan/carbine/get_ru_names()
	return alist(
		NOMINATIVE = "лазерная винтовка «Страж»",
		GENITIVE = "лазерной винтовки «Страж»",
		DATIVE = "лазерной винтовке «Страж»",
		ACCUSATIVE = "лазерную винтовку «Страж»",
		INSTRUMENTAL = "лазерной винтовкой «Страж»",
		PREPOSITIONAL = "лазерной винтовке «Страж»",
	)

// MARK: Hitscan pistol
/obj/item/gun/energy/laser/hitscan/pistol
	name = "laser pistol"
	desc = "Тактический лазерный пистолет, используемый службой безопасности. Способен вести огонь как в обычном, так и в ускоренном режиме."
	icon_state = "laserpistol"
	ammo_type = list(
		/obj/item/ammo_casing/energy/laser/hitscan/laser_pistol,
		/obj/item/ammo_casing/energy/laser/hitscan/laser_pistol/light,
	)
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_LIGHT
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_ENERGY_WEAPON
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 5, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 4, "y" = -5),
	)

/obj/item/gun/energy/laser/hitscan/pistol/get_ru_names()
	return alist(
		NOMINATIVE = "лазерный пистолет «Шершень»",
		GENITIVE = "лазерного пистолета «Шершень»",
		DATIVE = "лазерному пистолету «Шершень»",
		ACCUSATIVE = "лазерный пистолет «Шершень»",
		INSTRUMENTAL = "лазерным пистолетом «Шершень»",
		PREPOSITIONAL = "лазерном пистолете «Шершень»",
	)

// MARK: Hitscan MG
/obj/item/gun/energy/laser/hitscan/assault_mg
	name = "laser machine gun"
	desc = "Лазерная винтовка, используемый службой безопасности. Экспериментальный генератор частиц способен запускать снаряды, рикошетящие от стен."
	icon_state = "lasermg"
	ammo_type = list(
		/obj/item/ammo_casing/energy/laser/hitscan/laser_mg,
		/obj/item/ammo_casing/energy/laser/hitscan/laser_mg/ricochet,
	)
	slot_flags = ITEM_SLOT_SUITSTORE
	accuracy = GUN_ACCURACY_RIFLE
	weapon_weight = WEAPON_HEAVY
	burst_amount = 3
	fire_delay = 0.2 SECONDS
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 2, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 7, "y" = -6),
	)
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE)
	gun_flags = GUN_AMMO_COUNTER
	ammo_count_overlay = "counter_laser"
	ammo_count_colour = COLOR_CYAN

/obj/item/gun/energy/laser/hitscan/assault_mg/get_ru_names()
	return alist(
		NOMINATIVE = "лазерная винтовка «Зенит»",
		GENITIVE = "лазерной винтовки «Зенит»",
		DATIVE = "лазерной винтовке «Зенит»",
		ACCUSATIVE = "лазерную винтовку «Зенит»",
		INSTRUMENTAL = "лазерной винтовкой «Зенит»",
		PREPOSITIONAL = "лазерной винтовке «Зенит»",
	)

// MARK: Hitscan shotgun
/obj/item/gun/energy/laser/hitscan/shotgun
	name = "laser shotgun"
	desc = "Экспериментальный лазерный дробовик с возможностью настройки фокусировки линз. В зависимости от настройки, дробовик способен бить как рассеяным, так и сфокусированным лучом."
	icon_state = "lasershotgun"
	ammo_type = list(
		/obj/item/ammo_casing/energy/laser/hitscan/laser_shotgun,
		/obj/item/ammo_casing/energy/laser/hitscan/laser_shotgun/wide,
	)
	slot_flags = ITEM_SLOT_SUITSTORE
	accuracy = GUN_ACCURACY_RIFLE
	weapon_weight = WEAPON_HEAVY
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 2, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 9, "y" = -6),
	)

/obj/item/gun/energy/laser/hitscan/shotgun/get_ru_names()
	return alist(
		NOMINATIVE = "лазерный дробовик «Фокус»",
		GENITIVE = "лазерного дробовика «Фокус»",
		DATIVE = "лазерному дробовику «Фокус»",
		ACCUSATIVE = "лазерный дробовик «Фокус»",
		INSTRUMENTAL = "лазерным дробовиком «Фокус»",
		PREPOSITIONAL = "лазерном дробовике «Фокус»",
	)

// MARK: Hitscan sniper rifle
/obj/item/gun/energy/laser/hitscan/sniper_rifle
	name = "laser sniper rifle"
	desc = "Высококачественная лазерная снайперская винтовка, применяемая службой безопасности. Имеет два режима стрельбы: тяжёлый выстрел широкого диапазона и бронебойный выстрел, способный поражать цели за препятствием."
	icon = 'icons/obj/weapons/guns_48x32.dmi'
	icon_state = "laserrifle"
	ammo_type = list(
		/obj/item/ammo_casing/energy/laser/hitscan/laser_rifle,
		/obj/item/ammo_casing/energy/laser/hitscan/laser_rifle/armorpierce,
	)
	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BACK
	accuracy = GUN_ACCURACY_SNIPER
	weapon_weight = WEAPON_HEAVY
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 4),
		ATTACHMENT_SLOT_UNDER = list("x" = 21, "y" = -9),
	)
	windup_delay = 1 SECONDS
	windup_sound = 'sound/weapons/laser_charge.ogg'

/obj/item/gun/energy/laser/hitscan/sniper_rifle/get_ru_names()
	return alist(
		NOMINATIVE = "лазерная снайперская винтовка «Игла»",
		GENITIVE = "лазерной снайперской винтовки «Игла»",
		DATIVE = "лазерной снайперской винтовке «Игла»",
		ACCUSATIVE = "лазерную снайперскую винтовку «Игла»",
		INSTRUMENTAL = "лазерной снайперской винтовкой «Игла»",
		PREPOSITIONAL = "лазерной снайперской винтовке «Игла»",
	)
