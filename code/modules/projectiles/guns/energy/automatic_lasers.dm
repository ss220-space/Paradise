// MARK: automatic laser carbine
/obj/item/gun/energy/laser/automatic
	name = "автоматический лазер"
	desc = "Родитель всех автоматических лазеров. Основной гиммик это показ патронов и полный автоматический огонь у всего оружия. Если вы это читаете, делайте баг репорт."
	colour_denendent = TRUE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BELT
	weapon_weight = WEAPON_HEAVY
	accuracy = GUN_ACCURACY_MINIMAL
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	gun_flags = GUN_AMMO_COUNTER
	ammo_count_overlay = "counter_automatic"

/obj/item/gun/energy/laser/automatic/attackby(obj/item/item, mob/user, params)
	if(!is_laser_modification_case(item))
		return ..()

	var/choosen_weapon
	var/list/upgradable_variants = list(
		"карабин «Гроза»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "automatic_laser"),
		"пистолет «Буря»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "automatic_laser_pistol"),
		"автомат «Ливень»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "automatic_laser_rifle"),
		"дробовик «Шторм»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "automatic_laser_shotgun"),
		"снайперская винтовка «Град»" = image(icon = 'icons/obj/weapons/guns_48x32.dmi', icon_state = "automatic_sniper_rifle"),
	)
	var/choosen_type = show_radial_menu(user, item, upgradable_variants, src, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!choosen_type || !check_menu(user) || item.loc != user)
		return ATTACK_CHAIN_PROCEED

	switch(choosen_type)
		if("карабин «Гроза»")
			choosen_weapon = /obj/item/gun/energy/laser/automatic/carbine
		if("пистолет «Буря»")
			choosen_weapon = /obj/item/gun/energy/laser/automatic/pistol
		if("автомат «Ливень»")
			choosen_weapon = /obj/item/gun/energy/laser/automatic/assault_mg
		if("дробовик «Шторм»")
			choosen_weapon = /obj/item/gun/energy/laser/automatic/shotgun
		if("снайперская винтовка «Град»")
			choosen_weapon = /obj/item/gun/energy/laser/automatic/sniper_rifle

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

/obj/item/gun/energy/laser/automatic/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/gun/energy/laser/automatic/carbine
	name = "automatic laser carbine"
	desc = "Полностью автоматический лазерный карабин нового поколения. Низкий урон и малая надёжность с лихвой компенсируются повышенной скоростью стрельбы."
	icon_state = "automatic_laser"
	ammo_type = list(
		/obj/item/ammo_casing/energy/disabler/automatic,
		/obj/item/ammo_casing/energy/laser/automatic,
	)
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 9, "y" = -5),
	)

/obj/item/gun/energy/laser/automatic/carbine/get_ru_names()
	return alist(
		NOMINATIVE = "автоматическая лазерная винтовка «Гроза»",
		GENITIVE = "автоматической лазерной винтовки «Гроза»",
		DATIVE = "автоматической лазерной винтовке «Гроза»",
		ACCUSATIVE = "автоматическую лазерную винтовку «Гроза»",
		INSTRUMENTAL = "автоматической лазерной винтовкой «Гроза»",
		PREPOSITIONAL = "автоматической лазерной винтовке «Гроза»",
	)

// MARK: automatic laser pistol
/obj/item/gun/energy/laser/automatic/pistol
	name = "automatic laser pistol"
	desc = "Полностью автоматический лазерный пистолет нового поколения. Малый заряд внутренней батареи и медленная скорострельность с лихвой компенсируется системой \"умных пуль\", помогающих при стрельбе."
	icon_state = "automatic_laser_pistol"
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_LIGHT
	accuracy = GUN_ACCURACY_RIFLE_LASER
	ammo_type = list(
		/obj/item/ammo_casing/energy/disabler/weaker_automatic,
		/obj/item/ammo_casing/energy/laser/weaker_automatic,
	)
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 7, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 4, "y" = -5),
	)

/obj/item/gun/energy/laser/automatic/pistol/get_ru_names()
	return alist(
		NOMINATIVE = "автоматический лазерная пистолет «Буря»",
		GENITIVE = "автоматического лазерного пистолета «Буря»",
		DATIVE = "автоматическому лазерному пистолету «Буря»",
		ACCUSATIVE = "автоматический лазерный пистолет «Буря»",
		INSTRUMENTAL = "автоматическим лазерным пистолетом «Буря»",
		PREPOSITIONAL = "автоматическом лазерном пистолете «Буря»",
	)

// MARK: automatic laser mg
/obj/item/gun/energy/laser/automatic/assault_mg
	name = "assault laser machine gun"
	desc = "Массивная штурмовая винтовка нового поколения. В отличие от других экземпляров данной линейки, не предполагает нелетального режима стрельбы. Может переключаться между точной стрельбой и \"ливнем\" из снарядов."
	icon_state = "automatic_laser_rifle"
	slot_flags = ITEM_SLOT_SUITSTORE
	accuracy = GUN_ACCURACY_MINIMAL
	ammo_type = list(
		/obj/item/ammo_casing/energy/laser/automatic,
		/obj/item/ammo_casing/energy/laser/automatic/machine_gun,
	)
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 2, "y" = 7),
		ATTACHMENT_SLOT_UNDER = list("x" = 7, "y" = -9),
	)

/obj/item/gun/energy/laser/automatic/assault_mg/get_ru_names()
	return alist(
		NOMINATIVE = "штурмовая лазерная винтовка «Ливень»",
		GENITIVE = "штурмовой лазерной винтовки «Ливень»",
		DATIVE = "штурмовой лазерной винтовке «Ливень»",
		ACCUSATIVE = "штурмовую лазерную винтовку «Ливень»",
		INSTRUMENTAL = "штурмовой лазерной винтовкой «Ливень»",
		PREPOSITIONAL = "штурмовой лазерной винтовке «Ливень»",
	)

// MARK: automatic laser shotgun
/obj/item/gun/energy/laser/automatic/shotgun
	name = "automatic laser shotgun"
	desc = "Полностью автоматический лазерный дробовик нового поколения. Стреляет \"картечью\" из энергетических снарядов."
	icon_state = "automatic_laser_shotgun"
	ammo_type = list(
		/obj/item/ammo_casing/energy/disabler/scatter/automatic_shotgun,
		/obj/item/ammo_casing/energy/laser/scatter/automatic_shotgun,
	)
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 2, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 9, "y" = -6),
	)

/obj/item/gun/energy/laser/automatic/shotgun/get_ru_names()
	return alist(
		NOMINATIVE = "автоматический лазерный дробовик «Шторм»",
		GENITIVE = "автоматического лазерного дробовика «Шторм»",
		DATIVE = "автоматическому лазерному дробовику «Шторм»",
		ACCUSATIVE = "автоматический лазерний дробовик «Шторм»",
		INSTRUMENTAL = "автоматическим лазерным дробовиком «Шторм»",
		PREPOSITIONAL = "автоматическом лазерном дробовике «Шторм»",
	)

// MARK: automatic laser sniper
/obj/item/gun/energy/laser/automatic/sniper_rifle
	name = "automatic sniper rifle"
	desc = "Полностью автоматическая лазерная снайперская винтовка нового поколения. Стреляет сконцентрированными сгустками энергии, которые способны менять направление в сторону цели."
	icon = 'icons/obj/weapons/guns_48x32.dmi'
	icon_state = "automatic_sniper_rifle"
	accuracy = GUN_ACCURACY_RIFLE_LASER
	slot_flags = ITEM_SLOT_SUITSTORE
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 8, "y" = 7),
		ATTACHMENT_SLOT_UNDER = list("x" = 21, "y" = -9),
	)
	ammo_type = list(
		/obj/item/ammo_casing/energy/disabler/automatic_sniper,
		/obj/item/ammo_casing/energy/laser/automatic_sniper,
	)
	gun_firemode = GUN_FIREMODE_SEMIAUTO
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)

/obj/item/gun/energy/laser/automatic/sniper_rifle/get_ru_names()
	return alist(
		NOMINATIVE = "автоматическая снайперская винтовка «Град»",
		GENITIVE = "автоматической снайперской винтовки «Град»",
		DATIVE = "автоматической снайперской винтовке «Град»",
		ACCUSATIVE = "автоматическую снайперскую винтовку «Град»",
		INSTRUMENTAL = "автоматической снайперской винтовкой «Град»",
		PREPOSITIONAL = "автоматической снайперской винтовке «Град»",
	)
