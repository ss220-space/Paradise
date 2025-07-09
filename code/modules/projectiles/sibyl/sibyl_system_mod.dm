GLOBAL_VAR_INIT(sibsys_automode, TRUE)

/obj/item/sibyl_system_mod
	name = "модуль Sibyl System"
	desc = "Проприетарный модуль от правоохранительной организации на энергетические оружия для подключения к системе Sibyl System"
	icon = 'icons/obj/weapons/sibyl.dmi'
	icon_state = "sibyl_chip"
	item_state = "sibyl_chip"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "combat=4;magnets=3;engineering=3"
	hitsound = "swing_hit"
	var/obj/item/gun/energy/weapon = null
	var/obj/item/card/id/auth_id = null
	var/state = SIBSYS_STATE_UNINSTALLED
	var/limit = SIBYL_NONLETHAL
	var/emagged = FALSE

	/// Flag for registering SSsecurity_level
	var/registered = FALSE

	var/voice_is_enabled = TRUE
	var/voice_cd = null

	var/list/available = list()
	var/list/nonlethal_names = list("stun", "disabler", "disable", "practice", "ion",
								"energy", "bluetag", "redtag", "yield", "mutation",
								"goddamn meteor", "plasma burst", "blue", "orange",
								"lightning beam", "clown", "teleport beam", "gun mimic",
								"kinetic", "taser")
	var/list/lethal_names = list("kill", "lethal", "scatter", "anti-vehicle",
								"snipe", "precise", "declone", "mindfuck", "bolt",
								"heavy bolt", "toxic dart", "spraydown", "accelerator")
	var/list/destructive_names = list("destroy", "annihilate")

/obj/item/sibyl_system_mod/proc/install(obj/item/gun/energy/W, mob/user = null)
	if(user)
		if(!user.drop_transfer_item_to_loc(src, W))
			return
	else
		forceMove(W)
	weapon = W
	weapon.sibyl_mod = src
	weapon.verbs += /obj/item/gun/energy/proc/toggle_voice
	state = SIBSYS_STATE_INSTALLED

	if(GLOB.sibsys_automode)
		RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(sync_limit))
		registered = TRUE
	sibyl_sound(user, 'sound/voice/dominator/link.ogg', 10 SECONDS)

	check_unknown_names()
	sync_limit()
	W.update_icon()
	if(user)
		to_chat(user, span_notice("Вы установили [src.declent_ru(ACCUSATIVE)] в [W.declent_ru(ACCUSATIVE)]. Установка доступных режимов в соответствии с уровнем опасности ([capitalize(SSsecurity_level.get_current_level_as_text())])."))
		if(!auth_id)
			to_chat(user, span_notice("Требуется авторизация! Приложите ID-карту."))

/obj/item/sibyl_system_mod/proc/uninstall(obj/item/gun/energy/W)
	if(registered)
		UnregisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED)
		registered = FALSE
	forceMove(get_turf(src))
	W.verbs -= /obj/item/gun/energy/proc/toggle_voice

	state = SIBSYS_STATE_UNINSTALLED
	lock(silent = TRUE)
	W.sibyl_mod = null
	weapon = null
	set_limit(SIBYL_NONLETHAL)
	W.update_icon()
	return state

/obj/item/sibyl_system_mod/attack_self(mob/user)
	..()
	toggle_voice(user)

/obj/item/sibyl_system_mod/proc/toggle_voice(mob/user)
	voice_is_enabled = !voice_is_enabled
	if(user)
		to_chat(user, span_notice("Голосовая подсистема [voice_is_enabled ? "включена" : "отключена"]."))

/obj/item/sibyl_system_mod/proc/lock(mob/user, silent = FALSE)
	if(emagged)
		return FALSE
	auth_id = null
	weapon.update_icon()
	if(!silent && user)
		to_chat(user, span_notice("Блокировка [weapon.declent_ru(GENITIVE)] включена."))
	return TRUE

/obj/item/sibyl_system_mod/proc/unlock(mob/user, obj/item/card/id/ID)
	if(state != SIBSYS_STATE_INSTALLED)
		return FALSE
	if(ID)
		auth_id = ID
	else //Если емагнули
		auth_id = TRUE
	weapon.update_icon()
	if(user)
		to_chat(user, span_notice("Блокировка [weapon.declent_ru(GENITIVE)] отключена."))
	return TRUE

/obj/item/sibyl_system_mod/proc/toggleAuthorization(obj/item/card/id/ID, mob/user)
	if(state != SIBSYS_STATE_INSTALLED)
		return FALSE
	if(emagged)
		to_chat(user, span_danger("ОШИБКА АУТЕНТИФИКАЦИИ: [ID] вызывает короткое замыкание при сканировании!"))
		return
	if(!auth_id)
		unlock(user, ID)
		to_chat(user, span_notice("Вы авторизировали [weapon.declent_ru(ACCUSATIVE)] в системе Sibyl System под именем [auth_id.registered_name]."))
		sibyl_sound(user, 'sound/voice/dominator/user.ogg', 10 SECONDS)
	else if(auth_id == ID)
		lock(user)
		to_chat(user, span_notice("Вы деавторизировали [weapon.declent_ru(ACCUSATIVE)] в системе Sibyl System."))
	else if(ACCESS_ARMORY in ID.GetAccess())
		lock(user)
		to_chat(user, span_notice("Вы принудительно деавторизировали [weapon.declent_ru(ACCUSATIVE)] в системе Sibyl System."))
	weapon.update_icon()
	return TRUE

// Returns FALSE if the next ammo_type[select] is not yet available, otherwise TRUE
/obj/item/sibyl_system_mod/proc/check_select(var/select)
	var/obj/item/ammo_casing/energy/ammo = weapon.ammo_type[select]
	if(lowertext(ammo.select_name) in available)
		return TRUE
	else
		check_unknown_names()
	return FALSE

/obj/item/sibyl_system_mod/proc/check_auth(mob/living/user)
	if(!weapon)
		return FALSE
	if(!emagged)
		if(!auth_id)
			to_chat(user, span_warning("Требуется авторизация! Приложите ID-карту."))
			return FALSE
		if(!find_and_compare_id_cards(user))
			to_chat(user, span_warning("Ваша ID-карта не совпадает с авторизованной."))
			return FALSE
	return TRUE

/obj/item/sibyl_system_mod/proc/find_and_compare_id_cards(mob/user)
	for(var/obj/item/card/id/found_id in user.get_all_id_cards())
		if(found_id == auth_id)
			return TRUE
	return FALSE

/obj/item/sibyl_system_mod/proc/set_limit(mode)
	if(!weapon)
		return FALSE

	limit = mode
	switch(mode)
		if(SIBYL_NONLETHAL)
			available = nonlethal_names
		if(SIBYL_LETHAL)
			available = nonlethal_names + lethal_names
		if(SIBYL_DESTRUCTIVE)
			available = nonlethal_names + lethal_names + destructive_names

	var/message = "Для [weapon.declent_ru(GENITIVE)] теперь доступны только данные режимы: [get_available_text()]!"
	weapon.update_icon()
	if(ismob(weapon.loc))
		to_chat(weapon.loc, span_notice("[message]"))
	return TRUE

/obj/item/sibyl_system_mod/proc/sync_limit(datum/source, old_level, new_level)
	SIGNAL_HANDLER
	switch(SSsecurity_level.get_current_level_as_number())
		if(SEC_LEVEL_GREEN)
			set_limit(SIBYL_NONLETHAL)
		if(SEC_LEVEL_BLUE)
			set_limit(SIBYL_LETHAL)
		if(SEC_LEVEL_RED)
			set_limit(SIBYL_LETHAL)
		if(SEC_LEVEL_GAMMA)
			set_limit(SIBYL_DESTRUCTIVE)
		if(SEC_LEVEL_EPSILON)
			set_limit(SIBYL_DESTRUCTIVE)
		if(SEC_LEVEL_DELTA)
			set_limit(SIBYL_DESTRUCTIVE)
	if(!check_select(weapon?.select))
		weapon.select_fire()

/obj/item/sibyl_system_mod/proc/check_unknown_names()
	for(var/obj/item/ammo_casing/energy/ammo in weapon.ammo_type)
		if(ammo.select_name in nonlethal_names)
			continue
		if(ammo.select_name in lethal_names)
			continue
		if(ammo.select_name in destructive_names)
			continue
		nonlethal_names += list(ammo.select_name)

/obj/item/sibyl_system_mod/proc/get_available_text()
	var/list/names = list()
	for(var/obj/item/ammo_casing/energy/ammo in weapon.ammo_type)
		if(ammo.select_name in available)
			names += list(ammo.select_name)
	return names.Join(", ")


/obj/item/sibyl_system_mod/proc/sibyl_sound(mob/living/user, sound, time)
	if(user && voice_is_enabled && !voice_cd)
		user.playsound_local(get_turf(user), sound, 50, FALSE)
		voice_cd = addtimer(VARSET_CALLBACK(src, voice_cd, null), time)

/obj/item/sibyl_system_mod/Destroy()
	if(registered)
		UnregisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED)
    
	weapon = null
	auth_id = null
	return ..()
