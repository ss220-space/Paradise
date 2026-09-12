// MARK: Lethal
/obj/item/gun/projectile/shotgun/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

// MARK: RS-870
/obj/item/gun/projectile/shotgun/riot
	name = "RS-870 shotgun"
	desc = "Помповый дробовик 12-го калибра, выпускаемый по лицензии \"Aegis Ordinance\". \
			Имеет удлинённый магазин на 6 патронов и несколько креплений под тактические модули. \
			Входит в стандартное оснащение службы безопасности \"Нанотрейзен\"."
	icon_state = "riotshotgun"
	item_state = "riotshotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot

	fire_sound = 'sound/weapons/gunshots/1shotgun.ogg'
	suppressed_fire_sound = 'sound/weapons/gunshots/shotgunsupp.ogg'
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_SHOTGUN_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 23, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 4, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = -6),
	)

/obj/item/gun/projectile/shotgun/riot/get_ru_names()
	return alist(
		NOMINATIVE = "дробовик RS-870",
		GENITIVE = "дробовика RS-870",
		DATIVE = "дробовику RS-870",
		ACCUSATIVE = "дробовик RS-870",
		INSTRUMENTAL = "дробовиком RS-870",
		PREPOSITIONAL = "дробовике RS-870",
	)

/obj/item/gun/projectile/shotgun/riot/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "RS-870 — помповый дробовик 12-го калибра среднего ценового сегмента, производимый \
		по лицензии \"Aegis Ordinance\". Платформа проектировалась под нужды корпоративных и муниципальных \
		служб охраны порядка как универсальный инструмент силового контроля.<br>\
		<br>\
		\"Нанотрейзен\" включила RS-870 в стандартное оснащение арсеналов службы безопасности. Дробовик \
		может использовать как резиновые пули для нелетального подавления, так и летальные дробовые патроны \
		широкого ряда разновидностей."\
	)

/obj/item/gun/projectile/shotgun/riot/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins, item_path = /obj/item/gun/projectile/shotgun/riot)

/obj/item/gun/projectile/shotgun/riot/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/circular_saw) || istype(I, /obj/item/gun/energy/plasmacutter))
		add_fingerprint(user)
		if(sawoff(user))
			return ATTACK_CHAIN_PROCEED_SUCCESS
		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/melee/energy))
		add_fingerprint(user)
		if(HAS_TRAIT(I, TRAIT_ITEM_ACTIVE) && sawoff(user))
			return ATTACK_CHAIN_PROCEED_SUCCESS
		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/pipe))
		add_fingerprint(user)
		if(unsaw(I, user))
			return ATTACK_CHAIN_PROCEED_SUCCESS
		return ATTACK_CHAIN_PROCEED

	return ..()

/obj/item/gun/projectile/shotgun/riot/sawoff(mob/user)
	if(attachments_by_slot[ATTACHMENT_SLOT_MUZZLE])
		balloon_alert(user, "нужно снять дульный модуль!")
		return
	if(sawn_state == SAWN_OFF)
		balloon_alert(user, "уже укорочено!")
		return
	if(isstorage(loc))// to prevent inventory exploits
		balloon_alert(user, "не подходящее место!")
		return

	if(chambered) // if the gun is chambering live ammo, shoot self, if chambering empty ammo, 'click'
		if(chambered.BB)
			afterattack(user, user)
			user.visible_message(
				span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] в руках [user] стреляет!"),
				span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] в ваших руках стреляет!")
			)
			return
		else
			afterattack(user, user)
			user.visible_message(
				span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] в руках [user] сухо щёлкает."),
				span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] в ваших руках сухо щёлкает.")
			)

	if(magazine.ammo_count()) // spill the mag onto the floor
		user.visible_message(
			span_danger("[user] распилива[PLUR_ET_YUT(user)] магазин [declent_ru(GENITIVE)], заставляя содержимое выпасть."),
			span_userdanger("Вы распиливаете магазин [declent_ru(GENITIVE)], заставляя содержимое выпасть.")
		)
		while(get_ammo(FALSE) > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round(0)
			if(CB)
				CB.loc = get_turf(loc)
				CB.update_icon()

	balloon_alert(user, "укорачивание...")
	if(do_after(user, 3 SECONDS, src))
		user.visible_message(
			span_notice("[user] укорачива[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы укорачиваете [declent_ru(ACCUSATIVE)].")
		)
		post_sawoff()
		return 1

/obj/item/gun/projectile/shotgun/riot/proc/post_sawoff()
	desc = initial(desc) + " [sawn_desc]"
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM
	current_skin = icon_state + "-short"
	item_state = item_state + "-short"		//phil235 is it different with different skin?
	item_color = item_color + "-short"
	slot_flags &= ~ITEM_SLOT_BACK    //you can't sling it on your back
	slot_flags |= ITEM_SLOT_BELT     //but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
	sawn_state = SAWN_OFF
	accuracy = GUN_ACCURACY_MINIMAL
	magazine.max_ammo = 3
	damage_mod = 0.75
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 18, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 4, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = -6),
	)
	update_icon()

/obj/item/gun/projectile/shotgun/riot/proc/unsaw(obj/item/A, mob/user)
	if(attachments_by_slot[ATTACHMENT_SLOT_MUZZLE])
		balloon_alert(user, "нужно снять дульный модуль!")
		return
	if(sawn_state == SAWN_INTACT)
		balloon_alert(user, "операция провалилась!")
		return
	if(isstorage(loc))	//To prevent inventory exploits
		balloon_alert(user, "не подходящее место!")
		return

	if(chambered)	//if the gun is chambering live ammo, shoot self, if chambering empty ammo, 'click'
		if(chambered.BB)
			afterattack(user, user)
			user.visible_message(
				span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] в руках [user] стреляет!"),
				span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] в ваших руках стреляет!")
			)
			return
		else
			afterattack(user, user)
			user.visible_message(
				span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] в руках [user] сухо щёлкает."),
				span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] в ваших руках сухо щёлкает.")
			)

	if(magazine.ammo_count())	//Spill the mag onto the floor
		user.visible_message(
			span_danger("[user] распилива[PLUR_ET_YUT(user)] магазин [declent_ru(GENITIVE)], заставляя содержимое выпасть."),
			span_userdanger("Вы распиливаете магазин [declent_ru(GENITIVE)], заставляя содержимое выпасть.")
		)
		while(get_ammo() > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round(0)
			if(CB)
				CB.loc = get_turf(loc)
				CB.update_icon()

	if(do_after(user, 3 SECONDS, src))
		qdel(A)
		user.visible_message(
			span_notice("[user] удлиня[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы удлиняете [declent_ru(ACCUSATIVE)].")
		)
		post_unsaw(user)
		return 1

/obj/item/gun/projectile/shotgun/riot/proc/post_unsaw()
	desc = initial(desc)
	w_class = initial(w_class)
	weapon_weight = initial(weapon_weight)
	current_skin = "riotshotgun"
	item_state = initial(item_state)
	slot_flags &= ~ITEM_SLOT_BELT
	slot_flags |= ITEM_SLOT_BACK
	sawn_state = SAWN_INTACT
	magazine.max_ammo = 6
	damage_mod = 1
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 23, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 4, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = -6),
	)
	update_icon()

/obj/item/gun/projectile/shotgun/riot/update_icon_state() //Can't use the old proc as it makes it go to riotshotgun-short_sawn
	if(current_skin)
		icon_state = "[current_skin]"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun/projectile/shotgun/riot/short
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot/short
	accuracy = GUN_ACCURACY_MINIMAL
	recoil = GUN_RECOIL_MEGA

/obj/item/gun/projectile/shotgun/riot/short/Initialize(mapload)
	. = ..()
	post_sawoff()

/obj/item/gun/projectile/shotgun/riot/buckshot
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot/buckshot

// MARK: Frontier level action
/obj/item/gun/projectile/shotgun/winchester
	name = "\"Frontier\" lever-action shotgun"
	desc = "Рычажный дробовик калибра 12x70 мм, собранный по схеме из открытой библиотеки \"Canon de Frontira\". \
			Фурнитура из полимера, имитирующего дерево, классический рычажный механизм перезарядки. \
			Популярен у оружейных энтузиастов и охотников на далёких мирах."
	icon_state = "winchester"
	item_state = "winchester"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/winchester
	pb_knockback = 0 // no knockback for this gun
	fire_sound = 'sound/weapons/gunshots/1shotgun.ogg'
	suppressed_fire_sound = 'sound/weapons/gunshots/shotgunsupp.ogg'
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 23, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 5, ATTACHMENT_OFFSET_Y = 5),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 9, ATTACHMENT_OFFSET_Y = -4),
	)
	reload_sound = 'sound/weapons/gun_interactions/winchester_reload.ogg'

/obj/item/gun/projectile/shotgun/winchester/get_ru_names()
	return alist(
		NOMINATIVE = "рычажный дробовик \"Фронтир\"",
		GENITIVE = "рычажного дробовика \"Фронтир\"",
		DATIVE = "рычажному дробовику \"Фронтир\"",
		ACCUSATIVE = "рычажный дробовик \"Фронтир\"",
		INSTRUMENTAL = "рычажным дробовиком \"Фронтир\"",
		PREPOSITIONAL = "рычажном дробовике \"Фронтир\"",
	)

/obj/item/gun/projectile/shotgun/winchester/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Схема рычажного дробовика под патрон 12x70 мм была загружена в библиотеку \"Canon de Frontira\" анонимным автором \
		несколько десятилетий назад и с тех пор не обновлялась. Конструкция воспроизводит историческую механику рычажной \
		перезарядки практически без изменений, что придаёт ей немалую экзотичность в контексте 26 века.<br>\
		<br>\
		Приклад и цевьё из дешёвого полимера, минимум металлических деталей, простой рычажный механизм — всё это делает \"Фронтир\" \
		пригодным для производства и обслуживания в условиях ограниченной инфраструктуры. Приятным бонусом является наличие креплений \
		для тактических модулей.<br>\
		<br>\
		Данный экземпляр — один из тысяч, собранных по одной и той же открытой схеме на разных концах освоенного \
		космоса. Производитель, материалы и качество сборки варьируются от экземпляра к экземпляру, однако базовая \
		механика остаётся неизменной."\
	)

/obj/item/gun/projectile/shotgun/winchester/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_emote_observer, emote_key = "twirl")
	AddElement(/datum/element/item_skins)

/obj/item/gun/projectile/shotgun/winchester/do_pointblank_shot(mob/living/user, atom/target)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(pump), user), 1) //auto reload after point blank shot

// MARK: Cargo defender
/obj/item/gun/projectile/shotgun/winchester/cargo
	name = "\"Cargo Defender\" lever-action shotgun"
	desc = "Рычажный дробовик калибра 12x70 мм с позолоченным покрытием и именной гравировкой. Механика идентична базовой схеме рычажного дробовика \"Фронтир\", \
			однако отделка и исполнение явно указывают на штучную работу. Судя по надписи, оружие было изготовлено или вручено в знак особых \
			заслуг перед отделом Снабжения."
	icon_state = "winchester_cargo"
	item_state = "winchester_cargo"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/winchester/cargo

/obj/item/gun/projectile/shotgun/winchester/cargo/get_ru_names()
	return alist(
		NOMINATIVE = "рычажный дробовик \"Защитник карго\"",
		GENITIVE = "рычажного дробовика \"Защитник карго\"",
		DATIVE = "рычажному дробовику \"Защитник карго\"",
		ACCUSATIVE = "рычажный дробовик \"Защитник карго\"",
		INSTRUMENTAL = "рычажным дробовиком \"Защитник карго\"",
		PREPOSITIONAL = "рычажном дробовике \"Защитник карго\"",
	)

/obj/item/gun/projectile/shotgun/winchester/cargo/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Штучный экземпляр рычажного дробовика с позолоченным \
		покрытием и гравировкой \"Защитник карго\". Механика полностью идентична стандартной схеме рычажного дробовика \
		из библиотеки \"Canon de Frontira\", однако качество отделки и характер надписи однозначно указывают на то, \
		что перед это не рядовое изделие.<br>\
		<br>\
		Позолота нанесена поверх ствола, гравировка выполнена вручную. Полимерная фурнитура заменена деревянной и покрыта лаком \
		— явный контраст с утилитарной грубостью большинства экземпляров, собранных по открытой схеме.<br>\
		<br>\
		Судя по всему, данный дробовик был изготовлен и вручён Квартирмейстеру за особые заслуги на службе. Кто, кому и когда — неизвестно."\
	)

/obj/item/gun/projectile/shotgun/winchester/cargo/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/high_value_item)

// MARK: Rusted shotgun
/obj/item/gun/projectile/shotgun/lethal/rusted

/obj/item/gun/projectile/shotgun/lethal/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 20, destroy_max_chance = 8, malf_low_bound = 0, malf_high_bound = 4)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 5, misfire_low_bound = 0, misfire_high_bound = 1)

// MARK: Basic Auto Shotgun
/obj/item/gun/projectile/shotgun/automatic

/obj/item/gun/projectile/shotgun/automatic/shoot_live_shot(mob/living/user, atom/target, pointblank = FALSE, message = TRUE)
	..()
	addtimer(CALLBACK(src, PROC_REF(pump), user), 1)

// MARK: SG20 Ferox
/obj/item/gun/projectile/shotgun/automatic/combat
	name = "SG20 \"Ferox\" shotgun"
	desc = "Самозарядный тактический дробовик 12-го калибра производства \"Mars Special\". Имеет трубчатый магазин на 6 патронов. \
			Оснащён креплениями для дополнительных модулей."
	icon_state = "cshotgun"
	item_state = "cshotgun"
	origin_tech = "combat=6"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com
	fire_sound = 'sound/weapons/gunshots/1shotgun.ogg'
	suppressed_fire_sound = 'sound/weapons/gunshots/shotgunsupp.ogg'
	accuracy = GUN_ACCURACY_SHOTGUN
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_SHOTGUN_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 22, ATTACHMENT_OFFSET_Y = 3),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = 7),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 9, ATTACHMENT_OFFSET_Y = -4),
	)
	recoil = GUN_RECOIL_HIGH

/obj/item/gun/projectile/shotgun/automatic/combat/get_ru_names()
	return alist(
		NOMINATIVE = "дробовик SG20 \"Феррокс\"",
		GENITIVE = "дробовика SG20 \"Феррокс\"",
		DATIVE = "дробовику SG20 \"Феррокс\"",
		ACCUSATIVE = "дробовик SG20 \"Феррокс\"",
		INSTRUMENTAL = "дробовиком SG20 \"Феррокс\"",
		PREPOSITIONAL = "дробовике SG20 \"Феррокс\"",
	)

// MARK: Dual Tube
/obj/item/gun/projectile/shotgun/automatic/dual_tube
	name = "cycler shotgun"
	desc = "Автоматический дробовик с двумя разделёнными трубчатыми магазинами."
	icon_state = "cycler"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube
	w_class = WEIGHT_CLASS_HUGE
	var/toggled = 0
	var/obj/item/ammo_box/magazine/internal/shot/alternate_magazine
	fire_sound = 'sound/weapons/gunshots/1shotgun_auto.ogg'
	accuracy = GUN_ACCURACY_SHOTGUN
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 3, ATTACHMENT_OFFSET_Y = 7),
	)
	recoil = GUN_RECOIL_HIGH

/obj/item/gun/projectile/shotgun/automatic/dual_tube/get_ru_names()
	return alist(
		NOMINATIVE = "двухмагазинный дробовик",
		GENITIVE = "двухмагазинного дробовика",
		DATIVE = "двухмагазинному дробовику",
		ACCUSATIVE = "двухмагазинный дробовик",
		INSTRUMENTAL = "двухмагазинным дробовиком",
		PREPOSITIONAL = "двухмагазинном дробовике",
	)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/Initialize(mapload)
	. = ..()
	if(!alternate_magazine)
		alternate_magazine = new mag_type(src)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/Destroy()
	QDEL_NULL(alternate_magazine)
	return ..()

/obj/item/gun/projectile/shotgun/automatic/dual_tube/unload_act(mob/user)
	if(!chambered && length(magazine.contents))
		pump()
	else
		toggle_tube(user)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/proc/toggle_tube(mob/living/user)
	var/current_mag = magazine
	var/alt_mag = alternate_magazine
	magazine = alt_mag
	alternate_magazine = current_mag
	toggled = !toggled
	balloon_alert(user, "выбран [toggled ? "первый" : "второй"] магазин")
	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, TRUE)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/click_alt(mob/living/user)
	pump()
	return CLICK_ACTION_SUCCESS

/obj/item/gun/projectile/shotgun/automatic/dual_tube/AltShiftClick(mob/user)
	. = ..()
	try_detach_gun_module(user)

// MARK: Bulldog
/obj/item/gun/projectile/automatic/shotgun/bulldog
	name = "\"Bulldog\" mag-fed shotgun"
	desc = "Компактный самозарядный дробовик 12-го калибра с магазинным питанием. Полуавтоматический режим огня, высокая отдача, \
			крепления для тактических модулей. Собирается по открытой схеме из библиотеки \"Canon de Frontira\"."
	icon_state = "bulldog"
	item_state = "bulldog"
	origin_tech = "combat=6;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/gunshots/bulldog.ogg'
	suppressed_fire_sound = 'sound/weapons/gunshots/shotgunsupp.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_amount = 1
	accuracy = GUN_ACCURACY_SHOTGUN
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 23, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = 9),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 10, ATTACHMENT_OFFSET_Y = -6),
	)
	recoil = GUN_RECOIL_HIGH
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)

/obj/item/gun/projectile/automatic/shotgun/bulldog/get_ru_names()
	return alist(
		NOMINATIVE = "магазинный дробовик \"Бульдог\"",
		GENITIVE = "магазинного дробовика \"Бульдог\"",
		DATIVE = "магазинному дробовику \"Бульдог\"",
		ACCUSATIVE = "магазинный дробовик \"Бульдог\"",
		INSTRUMENTAL = "магазинным дробовиком \"Бульдог\"",
		PREPOSITIONAL = "магазинном дробовике \"Бульдог\"",
	)

/obj/item/gun/projectile/automatic/shotgun/bulldog/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/ammo_alarm, 'sound/weapons/smg_empty_alarm.ogg')

/obj/item/gun/projectile/automatic/shotgun/bulldog/update_icon_state()
	icon_state = "bulldog[chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/shotgun/bulldog/update_overlays()
	. = ..()
	if(magazine)
		. += "[magazine.icon_state]"

/obj/item/gun/projectile/automatic/shotgun/bulldog/update_weight()
	if(magazine)
		if(istype(magazine, /obj/item/ammo_box/magazine/m12g/XtrLrg))
			w_class = WEIGHT_CLASS_BULKY
		else
			w_class = WEIGHT_CLASS_NORMAL
	else
		w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/projectile/automatic/shotgun/bulldog/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box/magazine/m12g/XtrLrg) && isstorage(loc))	// To prevent inventory exploits
		var/obj/item/storage/storage = loc
		if(storage.max_w_class < WEIGHT_CLASS_BULKY)
			balloon_alert(user, "сначала вытащите магазин!")
			return ATTACK_CHAIN_PROCEED

	return ..()

/obj/item/gun/projectile/automatic/shotgun/bulldog/mastiff
	name = "\"Mastiff\" mag-fed shotgun"
	desc = "Компактный самозарядный дробовик 12-го калибра с магазинным питанием, являющийся дешёвой копией дробовика \"Бульдог\".\
			В отличие от оригинала, не совместим с расширенными магазинами."
	mag_type = /obj/item/ammo_box/magazine/cheap_m12g
	color = COLOR_ASSEMBLY_BROWN

/obj/item/gun/projectile/automatic/shotgun/bulldog/mastiff/get_ru_names()
	return alist(
		NOMINATIVE = "магазинный дробовик \"Мастифф\"",
		GENITIVE = "магазинного дробовика \"Мастифф\"",
		DATIVE = "магазинному дробовику \"Мастифф\"",
		ACCUSATIVE = "магазинный дробовик \"Мастифф\"",
		INSTRUMENTAL = "магазинным дробовиком \"Мастифф\"",
		PREPOSITIONAL = "магазинном дробовике \"Мастифф\"",
	)

// MARK: AS-12 Minotaur
/obj/item/gun/projectile/automatic/shotgun/minotaur
	name = "AS-12 \"Minotaur\" shotgun"
	desc = "Автоматический дробовик 12-го калибра с магазинным питанием."
	icon_state = "minotaur"
	item_state = "minotaur"
	origin_tech = "combat=6;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/gunshots/minotaur.ogg'
	suppressed_fire_sound = 'sound/weapons/gunshots/shotgunsupp.ogg'
	magin_sound = 'sound/weapons/gun_interactions/autoshotgun_mag_in.ogg'
	magout_sound = 'sound/weapons/gun_interactions/autoshotgun_mag_out.ogg'
	fire_delay = 0.15 SECONDS
	accuracy = GUN_ACCURACY_SHOTGUN
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 23, ATTACHMENT_OFFSET_Y = 0),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 1, ATTACHMENT_OFFSET_Y = 4),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = -5),
	)
	recoil = GUN_RECOIL_HIGH

/obj/item/gun/projectile/automatic/shotgun/minotaur/get_ru_names()
	return alist(
		NOMINATIVE = "магазинный дробовик AS-12 \"Минотавр\"",
		GENITIVE = "магазинного дробовика AS-12 \"Минотавр\"",
		DATIVE = "магазинному дробовику AS-12 \"Минотавр\"",
		ACCUSATIVE = "магазинный дробовик AS-12 \"Минотавр\"",
		INSTRUMENTAL = "магазинным дробовиком AS-12 \"Минотавр\"",
		PREPOSITIONAL = "магазинном дробовике AS-12 \"Минотавр\"",
	)

/obj/item/gun/projectile/automatic/shotgun/minotaur/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/ammo_alarm, 'sound/weapons/smg_empty_alarm.ogg')

/obj/item/gun/projectile/automatic/shotgun/minotaur/Initialize(mapload)
	. = ..()
	magazine = new/obj/item/ammo_box/magazine/m12g/XtrLrg

// MARK: SG40 Vastus
/obj/item/gun/projectile/automatic/cats
	name = "SG40 \"Vastus\" shotgun"
	desc = "Автоматический дробовик 12-го калибра производства \"Mars Special\", принятый на вооружение пехотных подразделений Транс-солнечной Федерации. \
			Поддерживает одиночный режим огня и очередь по 2 патрона. Высокая отдача и плотность огня делают его разрушительным инструментом \
			ближнего боя. Оснащён двумя слотами под тактические модули."
	icon_state = "tla_cats"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/cats12g
	fire_sound = 'sound/weapons/gunshots/1shotgun.ogg'
	suppressed_fire_sound = 'sound/weapons/gunshots/shotgunsupp.ogg'
	burst_amount = 2
	accuracy = GUN_ACCURACY_SHOTGUN
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_SHOTGUN_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 23, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = 6),
	)
	recoil = GUN_RECOIL_HIGH

/obj/item/gun/projectile/automatic/cats/get_ru_names()
	return alist(
		NOMINATIVE = "дробовик SG40 \"Вастус\"",
		GENITIVE = "дробовика SG40 \"Вастус\"",
		DATIVE = "дробовику SG40 \"Вастус\"",
		ACCUSATIVE = "дробовик SG40 \"Вастус\"",
		INSTRUMENTAL = "дробовиком SG40 \"Вастус\"",
		PREPOSITIONAL = "дробовике SG40 \"Вастус\"",
	)

/obj/item/gun/projectile/automatic/cats/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "SG40 \"Вастус\" — автоматический дробовик 12-го калибра, разработанный \"Mars Special\" по военному заказу \
		Транс-солнечной Федерации. Первостепенная задача при разработке — максимальная огневая мощь на сверхближних дистанциях.<br>\
		<br>\
		Автоматическая схема обеспечивает агрессивный темп стрельбы в режиме очереди по 2 патрона. \
		Высокая отдача — прямое следствие высокой скорострельности при стрельбе патронами 12g. Дульный срез и верхняя планка сохраняют стандартные \
		слоты под тактический обвес.<br>\
		<br>\
		SG40 принят на вооружение штурмовых подразделений ТСФ как специализированный инструмент зачистки в условиях ближнего боя. \
		За пределами вооружённых сил Федерации практически не встречается."\
	)

/obj/item/gun/projectile/automatic/cats/update_icon_state()
	icon_state = "tla_cats[magazine ? "" : "-e"]"

// MARK: Double-barreled
/obj/item/gun/projectile/revolver/doublebarrel
	name = "double-barreled shotgun"
	desc = "Двуствольный дробовик 12-го калибра, собранный по открытой схеме из библиотеки \"Canon de Frontira\". \
			Два патрона, высокая отдача, отсутствие креплений. Встречается повсеместно во множестве вариаций."
	icon_state = "dshotgun-base"
	item_state = "dshotgun-base"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	force = 10
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual
	fire_sound = 'sound/weapons/gunshots/1shotgun_old.ogg'
	can_holster = FALSE
	pb_knockback = 3
	accuracy = GUN_ACCURACY_SHOTGUN
	recoil = GUN_RECOIL_HIGH
	attachable_allowed = GUN_MODULE_CLASS_NONE
	can_air_shoot = FALSE

/obj/item/gun/projectile/revolver/doublebarrel/get_ru_names()
	return alist(
		NOMINATIVE = "двуствольный дробовик",
		GENITIVE = "двуствольного дробовика",
		DATIVE = "двуствольному дробовику",
		ACCUSATIVE = "двуствольный дробовик",
		INSTRUMENTAL = "двуствольным дробовиком",
		PREPOSITIONAL = "двуствольном дробовике",
	)

/obj/item/gun/projectile/revolver/doublebarrel/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins)

/obj/item/gun/projectile/revolver/doublebarrel/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/circular_saw) || istype(I, /obj/item/gun/energy/plasmacutter))
		add_fingerprint(user)
		if(sawoff(user))
			return ATTACK_CHAIN_PROCEED_SUCCESS
		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/melee/energy))
		add_fingerprint(user)
		if(HAS_TRAIT(I, TRAIT_ITEM_ACTIVE) && sawoff(user))
			return ATTACK_CHAIN_PROCEED_SUCCESS
		return ATTACK_CHAIN_PROCEED

	return ..()

/obj/item/gun/projectile/revolver/doublebarrel/sawoff(mob/user)
	. = ..()
	if(.)
		weapon_weight = WEAPON_MEDIUM
		can_holster = TRUE
		accuracy = GUN_ACCURACY_MINIMAL

/obj/item/gun/projectile/revolver/doublebarrel/unload_act(mob/user)
	var/num_unloaded = 0
	var/atom/drop_loc = drop_location()
	while(get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.forceMove(drop_loc)
		CB.pixel_x = rand(-10, 10)
		CB.pixel_y = rand(-10, 10)
		CB.setDir(pick(GLOB.alldirs))
		CB.update_appearance()
		CB.SpinAnimation(10, 1)
		playsound(drop_loc, CB.casing_drop_sound, 70, TRUE)
		num_unloaded++
	if(num_unloaded)
		balloon_alert(user, "[declension_ru(num_unloaded, "разряжен [num_unloaded] патрон",  "разряжено [num_unloaded] патрона",  "разряжено [num_unloaded] патронов")]")
	else
		balloon_alert(user, "уже разряжено!")

// MARK: Improvised
/obj/item/gun/projectile/revolver/doublebarrel/improvised
	name = "improvised shotgun"
	desc = "Собранный из подручных материалов дробовик 12 калибра, конструкционно представляющий собой модифицированный кусок трубы.\
			Экстремальная отдача, минимальная точность и нулевое удобство использования."
	icon_state = "ishotgun"
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised
	fire_sound = 'sound/weapons/gunshots/1shotgunpipe.ogg'
	unique_rename = FALSE
	pb_knockback = 0
	var/slung = FALSE
	accuracy = GUN_ACCURACY_MINIMAL
	recoil = GUN_RECOIL_MEGA

/obj/item/gun/projectile/revolver/doublebarrel/improvised/get_ru_names()
	return alist(
		NOMINATIVE = "кустарный дробовик",
		GENITIVE = "кустарного дробовика",
		DATIVE = "кустарному дробовику",
		ACCUSATIVE = "кустарный дробовик",
		INSTRUMENTAL = "кустарным дробовиком",
		PREPOSITIONAL = "кустарном дробовике",
	)

/obj/item/gun/projectile/revolver/doublebarrel/improvised/attackby(obj/item/I, mob/user, params)
	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(sawn_state == SAWN_OFF)
			balloon_alert(user, "не совместимо!")
			return ATTACK_CHAIN_PROCEED
		if(!coil.use(10))
			balloon_alert(user, "нужно больше кабеля!")
			return ATTACK_CHAIN_PROCEED
		slot_flags |= ITEM_SLOT_BACK
		balloon_alert(user, "присоединён самодельный ремень!")
		slung = TRUE
		update_icon()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/gun/projectile/revolver/doublebarrel/improvised/update_icon_state()
	icon_state = "ishotgun[slung ? "sling" : sawn_state == SAWN_OFF ? "-sawn" : ""]"

/obj/item/gun/projectile/revolver/doublebarrel/improvised/sawoff(mob/user)
	. = ..()
	if(. && slung) //sawing off the gun removes the sling
		new /obj/item/stack/cable_coil(drop_location(), 10)
		slung = FALSE
		update_icon()

// MARK: Cane shotgun
/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane
	name = "cane"
	desc = "Трость — верный спутник настоящего джентльмена. Или клоуна."
	gender = FEMALE
	icon = 'icons/obj/items.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "cane"
	item_state = "stick"
	sawn_state = SAWN_OFF
	w_class = WEIGHT_CLASS_SMALL
	weapon_weight = WEAPON_LIGHT
	can_unsuppress = FALSE
	slot_flags = null
	origin_tech = "" // NO GIVAWAYS
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised/cane
	attack_verb = list("огрел", "проучил")
	suppressed = TRUE
	needs_permit = FALSE //its just a cane beepsky.....
	accuracy = GUN_ACCURACY_SHOTGUN
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/get_ru_names()
	return alist(
		NOMINATIVE = "трость",
		GENITIVE = "трости",
		DATIVE = "трости",
		ACCUSATIVE = "трость",
		INSTRUMENTAL = "тростью",
		PREPOSITIONAL = "трости",
	)

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/is_crutch()
	return 2

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/update_icon_state()
	return

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/update_overlays()
	return list()

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/attackby(obj/item/I, mob/user, params)
	if(iscoil(I))
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/examine(mob/user) // HAD TO REPEAT EXAMINE CODE BECAUSE GUN CODE DOESNT STEALTH
	var/f_name = "\a [src]."
	if(blood_DNA && !istype(src, /obj/effect/decal))
		if(gender == PLURAL)
			f_name = "some "
		else
			f_name = "a "
		f_name += span_danger("blood-stained [name]!")

	. = list("[icon2html(src, user)] That's [f_name]")

	if(desc)
		. += desc
