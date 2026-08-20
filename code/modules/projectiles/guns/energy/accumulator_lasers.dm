// MARK: cell-magazine weapons
/obj/item/gun/energy/accumulator
	name = "аккумуляторная пушка"
	desc = "Оружие, работающее на аккумуляторах. Как спектр, только вариант до реворка с некоторыми изменениями. Если вы это читаете, пишите баг репорт."
	icon_state = "energypistol"
	item_state = null
	ammo_x_offset = 1
	shaded_charge = TRUE
	ammo_type = list(
		/obj/item/ammo_casing/energy/disabler,
		/obj/item/ammo_casing/energy/laser,
	)
	colour_denendent = TRUE
	/// Our magazine, initialized in mapload
	var/obj/item/weapon_cell/magazine
	/// accumulator, that used by our gun
	var/accumulator_type = /obj/item/weapon_cell/energy_gun
	// all weapons are too good, so our little nerf here
	force = 20
	damage_mod = 0.7
	stamina_mod = 0.7

/obj/item/gun/energy/accumulator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ammo_alarm, 'sound/weapons/smg_empty_alarm.ogg')
	if(!accumulator_type)
		return
	magazine = new accumulator_type(src)
	if(magazine && magazine.get_cell())
		cell = magazine.get_cell()
	update_icon()

/obj/item/gun/energy/accumulator/examine(mob/user)
	. = ..()
	if(magazine)
		. += span_notice("Заряд аккумулятора: [round(cell.percent())]%")
		. += span_notice("Используйте <b>Alt+ЛКМ</b>, чтобы вытащить аккумулятор.")
	else
		. += span_notice("Аккумулятор отсутствует.")

/obj/item/gun/energy/accumulator/can_shoot(mob/living/user, silent)
	if(!magazine)
		return FALSE
	return ..()

/obj/item/gun/energy/accumulator/update_icon_state()
	if(!magazine)
		icon_state = "[initial(icon_state)]-e"
		item_state = "[initial(icon_state)]-e"
	else
		. = ..()

/obj/item/gun/energy/accumulator/attackby(obj/item/item, mob/user, params)
	if(!is_energy_gun_cell(item))
		return ..()
	add_fingerprint(user)
	if(!user.drop_transfer_item_to_loc(item, src))
		user.balloon_alert(user, "не выходит!")
		return ATTACK_CHAIN_PROCEED
	if(magazine)
		magazine.update_icon(UPDATE_OVERLAYS)
		user.put_in_hands(magazine)
	cell = item.get_cell()
	cell_type = cell.type
	magazine = item
	user.balloon_alert(user, "аккумулятор заменен")
	update_icon()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(magazine.is_available_shot(shot.e_cost))
		playsound(loc, 'sound/weapons/gun_interactions/spec_magin.ogg', 50, TRUE)
	return ATTACK_CHAIN_PROCEED

/obj/item/gun/energy/accumulator/click_alt(mob/user)
	if(!magazine)
		return ..()
	magazine.update_icon(UPDATE_OVERLAYS)
	user.put_in_hands(magazine)
	cell = null
	magazine = null
	update_icon()

/obj/item/gun/energy/accumulator/attackby(obj/item/item, mob/user, params)
	if(!is_laser_modification_case(item))
		return ..()
	var/choosen_weapon
	var/list/upgradable_variants = list(
		"карабин «Скорпион»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "energycarbine"),
		"пистолет «Оса»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "energypistol"),
		"автомат «Медуза»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "energy_rifle"),
		"дробовик «Скарабей»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "energy_shotgun"),
		"снайперская винтовка «Богомол»" = image(icon = 'icons/obj/weapons/guns_48x32.dmi', icon_state = "energy_sniper_rifle"),
	)
	var/choosen_type = show_radial_menu(user, item, upgradable_variants, src, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!choosen_type || !check_menu(user) || item.loc != user)
		return ATTACK_CHAIN_PROCEED

	switch(choosen_type)
		if("карабин «Скорпион»")
			choosen_weapon = /obj/item/gun/energy/accumulator/energy_carbine
		if("пистолет «Оса»")
			choosen_weapon = /obj/item/gun/energy/accumulator/energy_pistol
		if("автомат «Медуза»")
			choosen_weapon = /obj/item/gun/energy/accumulator/automatic
		if("дробовик «Скарабей»")
			choosen_weapon = /obj/item/gun/energy/accumulator/shotgun
		if("снайперская винтовка «Богомол»")
			choosen_weapon = /obj/item/gun/energy/accumulator/sniper_rifle

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

	user.put_in_hands(new_gun)
	playsound(user, 'sound/machines/ding.ogg', 50, TRUE)
	do_sparks(3, TRUE, spawn_turf)

	user.temporarily_remove_item_from_inventory(src)
	qdel(src)

	user.temporarily_remove_item_from_inventory(item)
	qdel(item)

	return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

/obj/item/gun/energy/accumulator/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

// MARK: Energy carbine
/obj/item/gun/energy/accumulator/energy_carbine
	name = "energy carbine"
	desc = "Обновленная энергетическая винтовка, работающая на съёмных аккумуляторах универсального образца. Укреплённый приклад позволяет стрелку вступить в ближний бой в случае исчерпания боезапаса."
	icon_state = "energycarbine"
	origin_tech = "combat=4;materials=2"
	ammo_type = list(
		/obj/item/ammo_casing/energy/disabler/energy_carbine,
		/obj/item/ammo_casing/energy/laser/energy_carbine,
	)
	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BELT
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_ENERGY_WEAPON
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 6, "y" = 5),
		ATTACHMENT_SLOT_UNDER = list("x" = 8, "y" = -6),
	)

/obj/item/gun/energy/accumulator/energy_carbine/get_ru_names()
	return alist(
		NOMINATIVE = "энерго-винтовка «Скорпион»",
		GENITIVE = "энерго-винтовки «Скорпион»",
		DATIVE = "энерго-винтовке «Скорпион»",
		ACCUSATIVE = "энерго-винтовку «Скорпион»",
		INSTRUMENTAL = "энерго-винтовкой «Скорпион»",
		PREPOSITIONAL = "энерго-винтовке «Скорпион»",
	)

// MARK: Energy pistol
/obj/item/gun/energy/accumulator/energy_pistol
	name = "energy pistol"
	desc = "Ручной бластер, работающий на съёмных аккумуляторах универсального образца. Способен производить усиленные выстрелы, разбивающие щиты."
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_ENERGY_WEAPON
	accuracy = GUN_ACCURACY_PISTOL
	weapon_weight = WEAPON_LIGHT
	force = 10
	ammo_type = list(
		/obj/item/ammo_casing/energy/disabler/energy_pistol,
		/obj/item/ammo_casing/energy/laser/energy_pistol,
	)
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 7, "y" = 7),
		ATTACHMENT_SLOT_UNDER = list("x" = 5, "y" = -5),
	)

/obj/item/gun/energy/accumulator/energy_pistol/get_ru_names()
	return alist(
		NOMINATIVE = "энерго-пистолет «Оса»",
		GENITIVE = "энерго-пистолета «Оса»",
		DATIVE = "энерго-пистолету «Оса»",
		ACCUSATIVE = "энерго-пистолет «Оса»",
		INSTRUMENTAL = "энерго-пистолетом «Оса»",
		PREPOSITIONAL = "энерго-пистолете «Оса»",
	)

// MARK: Energy rifle
/obj/item/gun/energy/accumulator/automatic
	name = "energy automatic rifle"
	desc = "Энергетическая автоматическая винтовка, работающая на съёмных аккумуляторах универсального образца. Популярна среди силовых структур по всей галактике как мощное оружие для проведения штурмовых операций."
	icon_state = "energy_rifle"
	ammo_type = list(
		/obj/item/ammo_casing/energy/disabler/energy_carbine/weak,
		/obj/item/ammo_casing/energy/laser/energy_carbine/weak,
	)
	fire_delay = 0.4 SECONDS
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_SEMIAUTO)
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	accuracy = GUN_ACCURACY_RIFLE
	slot_flags = ITEM_SLOT_SUITSTORE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_ENERGY_WEAPON
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 5),
		ATTACHMENT_SLOT_UNDER = list("x" = 8, "y" = -7),
	)
	gun_flags = GUN_AMMO_COUNTER
	ammo_count_overlay = "counter_energy"
	ammo_count_colour = COLOR_IRISH_ORANGE

/obj/item/gun/energy/accumulator/automatic/get_ru_names()
	return alist(
		NOMINATIVE = "энерго-автомат «Медуза»",
		GENITIVE = "энерго-автомата «Медуза»",
		DATIVE = "энерго-автомату «Медуза»",
		ACCUSATIVE = "энерго-автомат «Медуза»",
		INSTRUMENTAL = "энерго-автоматом «Медуза»",
		PREPOSITIONAL = "энерго-автомате «Медуза»",
	)

// MARK: Energy shotgun
/obj/item/gun/energy/accumulator/shotgun
	name = "energy shotgun"
	desc = "Энергетический дробовик, работающий на съёмных аккумуляторах универсального образца. Используется силовыми службами в тесных помещениях. Массивный вес дробовика позволяет использовать приклад в ближнем бою."
	icon_state = "energy_shotgun"
	ammo_type = list(
		/obj/item/ammo_casing/energy/disabler/scatter/energy_shotgun,
		/obj/item/ammo_casing/energy/laser/scatter/energy_shotgun,
	)
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	accuracy = GUN_ACCURACY_RIFLE
	slot_flags = ITEM_SLOT_SUITSTORE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_ENERGY_WEAPON
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 7),
		ATTACHMENT_SLOT_UNDER = list("x" = 8, "y" = -8),
	)

/obj/item/gun/energy/accumulator/shotgun/get_ru_names()
	return alist(
		NOMINATIVE = "энерго-дробовик «Скарабей»",
		GENITIVE = "энерго-дробовика «Скарабей»",
		DATIVE = "энерго-дробовику «Скарабей»",
		ACCUSATIVE = "энерго-дробовик «Скарабей»",
		INSTRUMENTAL = "энерго-дробовиком «Скарабей»",
		PREPOSITIONAL = "энерго-дробовике «Скарабей»",
	)

// MARK: Energy sniper rifle
/obj/item/gun/energy/accumulator/sniper_rifle
	name = "energy sniper rifle"
	desc = "Энергетическая снайперская винтовка, работающая на съёмных аккумуляторах универсального образца. Используется частными силовыми структурами для боев на дальних дистанциях."
	icon = 'icons/obj/weapons/guns_48x32.dmi'
	icon_state = "energy_sniper_rifle"
	ammo_type = list(
		/obj/item/ammo_casing/energy/disabler/energy_carbine/heavy,
		/obj/item/ammo_casing/energy/laser/energy_carbine/heavy,
	)
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	accuracy = GUN_ACCURACY_SNIPER
	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BACK
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_ENERGY_WEAPON
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 8, "y" = -7),
	)

/obj/item/gun/energy/accumulator/sniper_rifle/get_ru_names()
	return alist(
		NOMINATIVE = "энерго-снайперская винтовка «Богомол»",
		GENITIVE = "энерго-снайперской винтовки «Богомол»",
		DATIVE = "энерго-снайперской винтовке «Богомол»",
		ACCUSATIVE = "энерго-снайперскую винтовку «Богомол»",
		INSTRUMENTAL = "энерго-снайперской винтовкой «Богомол»",
		PREPOSITIONAL = "энерго-снайперской винтовке «Богомол»",
	)
