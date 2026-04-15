// MARK: Foam dart
/obj/item/ammo_casing/caseless/foam_dart
	name = "foam dart"
	icon = 'icons/obj/weapons/toy.dmi'
	icon_state = "foamdart"
	materials = list(MAT_METAL = 10)
	caliber = CALIBER_FOAM_FORCE
	projectile_type = /obj/projectile/bullet/reusable/foam_dart
	muzzle_flash_effect = null
	var/modified = FALSE
	harmful = FALSE

/obj/item/ammo_casing/caseless/foam_dart/get_ru_names()
	return list(
		NOMINATIVE = "пенопластовый патрон",
		GENITIVE = "пенопластового патрона",
		DATIVE = "пенопластовому патрону",
		ACCUSATIVE = "пенопластовый патрон",
		INSTRUMENTAL = "пенопластовым патроном",
		PREPOSITIONAL = "пенопластовом патроне",
	)

/obj/item/ammo_casing/caseless/foam_dart/update_desc(updates = ALL)
	. = ..()
	desc = "Имитация огнестрельного боеприпаса из пены и пластмассы для стрельбы из игрушечного оружия. [extra_info]"

/obj/item/ammo_casing/caseless/foam_dart/examine(mob/user)
	. = ..()
	if(modified)
		. += span_warning("Пуля была модифицирована.")

/obj/item/ammo_casing/caseless/foam_dart/update_icon_state()
	if(modified)
		icon_state = "foamdart_empty"
		if(BB)
			BB.icon_state = "foamdart_empty"
	else
		icon_state = initial(icon_state)
		if(BB)
			BB.icon_state = initial(BB.icon_state)

/obj/item/ammo_casing/caseless/foam_dart/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		add_fingerprint(user)
		var/obj/projectile/bullet/reusable/foam_dart/bullet = BB
		if(!bullet)
			balloon_alert(user, "пуля отсутствует!")
			return ATTACK_CHAIN_PROCEED
		if(!modified)
			balloon_alert(user, "патрон не модифицирован!")
			return ATTACK_CHAIN_PROCEED
		if(bullet.pen)
			balloon_alert(user, "в пулю уже вставлена ручка!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		harmful = TRUE
		I.forceMove(bullet)
		bullet.log_override = FALSE
		bullet.pen = I
		bullet.damage = 5
		bullet.nodamage = FALSE
		balloon_alert(user, "ручка вставлена")
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/ammo_casing/caseless/foam_dart/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!BB)
		add_fingerprint(user)
		balloon_alert(user, "пуля отсутствует!")
		return .
	if(modified)
		add_fingerprint(user)
		balloon_alert(user, "патрон уже модифицирован!")
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	modified = TRUE
	BB.damage_type = BRUTE
	update_icon()

/obj/item/ammo_casing/caseless/foam_dart/attack_self(mob/living/user)
	var/obj/projectile/bullet/reusable/foam_dart/FD = BB
	if(FD.pen)
		FD.damage = initial(FD.damage)
		FD.nodamage = initial(FD.nodamage)
		user.put_in_hands(FD.pen)
		balloon_alert(user, "ручка извлечена")
		FD.pen = null

/obj/item/ammo_casing/caseless/foam_dart/riot
	name = "riot foam dart"
	extra_info = "Усиленная версия, по силе удара сравнимая с полноценными резиновыми пулями."
	icon_state = "foamdart_riot"
	materials = list(MAT_METAL = 650)
	projectile_type = /obj/projectile/bullet/reusable/foam_dart/riot

/obj/item/ammo_casing/caseless/foam_dart/riot/get_ru_names()
	return list(
		NOMINATIVE = "пенопластовый патрон (усиленный)",
		GENITIVE = "пенопластового патрона (усиленный)",
		DATIVE = "пенопластовому патрону (усиленный)",
		ACCUSATIVE = "пенопластовый патрон (усиленный)",
		INSTRUMENTAL = "пенопластовым патроном (усиленный)",
		PREPOSITIONAL = "пенопластовом патроне (усиленный)",
	)

/obj/item/ammo_casing/caseless/foam_dart/sniper
	name = "foam sniper dart"
	extra_info = "Вариант большего размера для использования в игрушечных снайперских винтовках."
	icon_state = "foamdartsniper"
	materials = list(MAT_METAL = 20)
	caliber = CALIBER_FOAM_FORCE_SNIPER
	projectile_type = /obj/projectile/bullet/reusable/foam_dart/sniper

/obj/item/ammo_casing/caseless/foam_dart/sniper/get_ru_names()
	return list(
		NOMINATIVE = "пенопластовый патрон (снайперский)",
		GENITIVE = "пенопластового патрона (снайперский)",
		DATIVE = "пенопластовому патрону (снайперский)",
		ACCUSATIVE = "пенопластовый патрон (снайперский)",
		INSTRUMENTAL = "пенопластовым патроном (снайперский)",
		PREPOSITIONAL = "пенопластовом патроне (снайперский)",
	)

/obj/item/ammo_casing/caseless/foam_dart/sniper/update_icon_state()
	if(modified)
		icon_state = "foamdartsniper_empty"
		if(BB)
			BB.icon_state = "foamdartsniper_empty"
	else
		icon_state = initial(icon_state)
		if(BB)
			BB.icon_state = initial(BB.icon_state)

/obj/item/ammo_casing/caseless/foam_dart/sniper/riot
	name = "riot foam sniper dart"
	extra_info = "Усиленная версия для игрушечных снайперских винтовок, по силе удара сравнимая с полноценными резиновыми пулями."
	icon_state = "foamdartsniper_riot"
	materials = list(MAT_METAL = 1800)
	projectile_type = /obj/projectile/bullet/reusable/foam_dart/sniper/riot

/obj/item/ammo_casing/caseless/foam_dart/sniper/riot/get_ru_names()
	return list(
		NOMINATIVE = "пенопластовый патрон (снайперский усиленный)",
		GENITIVE = "пенопластового патрона (снайперский усиленный)",
		DATIVE = "пенопластовому патрону (снайперский усиленный)",
		ACCUSATIVE = "пенопластовый патрон (снайперский усиленный)",
		INSTRUMENTAL = "пенопластовым патроном (снайперский усиленный)",
		PREPOSITIONAL = "пенопластовом патроне (снайперский усиленный)",
	)

// MARK: Cap
/obj/item/ammo_casing/cap
	ammo_marking = "холостой"
	extra_info = "Холостой вариант для игрушечного оружия. Пуля отсутствует."
	materials = list(MAT_METAL = 10)
	caliber = CALIBER_CAP
	projectile_type = /obj/projectile/bullet/cap
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
