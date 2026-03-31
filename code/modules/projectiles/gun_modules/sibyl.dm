/**
 * # Sibyl System Module
 */

GLOBAL_VAR_INIT(sibsys_automode, TRUE)

/obj/item/gun_module/sibyl
	name = "Sibyl System module"
	desc = "Проприетарный модуль от правоохранительной организации для энергетического оружия, подключающий его к системе Sibyl System"
	icon = 'icons/obj/weapons/sibyl.dmi'
	icon_state = "sibyl_chip"
	item_state = "sibyl_chip"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "combat=4;magnets=3;engineering=3"
	hitsound = SFX_SWING_HIT
	slot = ATTACHMENT_SLOT_SIBYL
	class = GUN_MODULE_CLASS_ENERGY_WEAPON
	can_detach = FALSE // Disable standard removal using ALT+LMB

	var/state = SIBSYS_STATE_UNINSTALLED
	var/datum/weakref/auth_id = null
	var/limit = SIBYL_TIER_NONLETHAL
	var/registered = FALSE
	var/voice_is_enabled = TRUE
	var/voice_cd = null

/obj/item/gun_module/sibyl/Destroy()
	if(registered)
		UnregisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED)
	. = ..()

/obj/item/gun_module/sibyl/get_ru_names()
	return list(
		NOMINATIVE = "модуль Sibyl System",
		GENITIVE = "модуля Sibyl System",
		DATIVE = "модулю Sibyl System",
		ACCUSATIVE = "модуль Sibyl System",
		INSTRUMENTAL = "модулем Sibyl System",
		PREPOSITIONAL = "модуле Sibyl System",
	)

/obj/item/gun_module/sibyl/create_overlay()
	return null

/obj/item/gun_module/sibyl/try_attach(obj/item/gun/target_gun, mob/user)
	if(!isenergygun(target_gun))
		if(user)
			user.balloon_alert(user, "несовместимо с Sibyl System!")
		return FALSE

	var/obj/item/gun/energy/energy_gun = target_gun
	if(!energy_gun.can_add_sibyl_system)
		if(user)
			user.balloon_alert(user, "не поддерживает Sibyl System!")
		return FALSE

	if(energy_gun.sibyl_mod)
		if(user)
			user.balloon_alert(user, "модуль уже установлен!")
		return FALSE

	energy_gun.attachments_by_slot[slot] = src
	energy_gun.add_attachment_overlay(src)
	if(user)
		user.drop_transfer_item_to_loc(src, energy_gun)
	else
		forceMove(energy_gun)

	gun = energy_gun
	on_attach(energy_gun, user)
	SEND_SIGNAL(energy_gun, COMSIG_GUN_MODULE_ATTACH, user, energy_gun, src)
	if(user)
		user.balloon_alert(user, "модуль установлен")
	return TRUE

/obj/item/gun_module/sibyl/on_attach(obj/item/gun/target_gun, mob/user)
	var/obj/item/gun/energy/energy_gun = target_gun
	energy_gun.sibyl_mod = src
	state = SIBSYS_STATE_INSTALLED
	energy_gun.verbs += /obj/item/gun/energy/proc/toggle_voice

	if(GLOB.sibsys_automode)
		RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(sync_limit))
		registered = TRUE

	RegisterSignal(target_gun, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(on_screwdriver_act))
	RegisterSignal(target_gun, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), PROC_REF(on_welder_act))
	RegisterSignal(target_gun, COMSIG_ATOM_TOOL_ACT(TOOL_CROWBAR), PROC_REF(on_crowbar_act))
	RegisterSignal(target_gun, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag_act))
	sibyl_sound(user, 'sound/voice/dominator/link.ogg', SIBYL_LINK_SOUND_COOLDOWN)
	sync_limit()
	energy_gun.update_icon()

	if(!user)
		return
	to_chat(user, span_notice("Вы установили [declent_ru(ACCUSATIVE)] в [energy_gun.declent_ru(ACCUSATIVE)]. Установка доступных режимов в соответствии с уровнем опасности ([capitalize(SSsecurity_level.get_current_level_as_text())])."))
	if(!auth_id?.resolve())
		to_chat(user, span_notice("Требуется авторизация! Приложите ID-карту."))

/obj/item/gun_module/sibyl/on_detach(obj/item/gun/target_gun, mob/user)
	if(registered)
		UnregisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED)
		registered = FALSE

	UnregisterSignal(target_gun, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER))
	UnregisterSignal(target_gun, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER))
	UnregisterSignal(target_gun, COMSIG_ATOM_TOOL_ACT(TOOL_CROWBAR))
	UnregisterSignal(target_gun, COMSIG_ATOM_EMAG_ACT)
	var/obj/item/gun/energy/energy_gun = target_gun
	energy_gun.verbs -= /obj/item/gun/energy/proc/toggle_voice
	state = SIBSYS_STATE_UNINSTALLED
	lock()
	energy_gun.sibyl_mod = null
	limit = SIBYL_TIER_NONLETHAL
	energy_gun.update_icon()

/obj/item/gun_module/sibyl/proc/lock(mob/user)
	if(emagged)
		return FALSE

	auth_id = null
	gun?.update_icon()
	return TRUE

/obj/item/gun_module/sibyl/proc/unlock(mob/user, obj/item/card/id/ID)
	if(state != SIBSYS_STATE_INSTALLED)
		return FALSE
	auth_id = WEAKREF(ID)
	gun?.update_icon()
	return TRUE

/obj/item/gun_module/sibyl/proc/toggle_authorization(obj/item/card/id/card_id, mob/user)
	if(state != SIBSYS_STATE_INSTALLED)
		user.balloon_alert(user, "модуль поврежден!")
		return FALSE

	if(emagged)
		to_chat(user, span_danger("ОШИБКА АУТЕНТИФИКАЦИИ: [card_id] вызывает короткое замыкание при сканировании!"))
		return

	var/obj/item/card/id/current_auth = auth_id?.resolve()
	if(!current_auth)
		unlock(user, card_id)
		to_chat(user, span_notice("Вы авторизировали [gun.declent_ru(ACCUSATIVE)] в системе Sibyl System под именем [card_id.registered_name]."))
		sibyl_sound(user, 'sound/voice/dominator/user.ogg', SIBYL_LINK_SOUND_COOLDOWN)
	else if(current_auth == card_id)
		lock(user)
		to_chat(user, span_notice("Вы деавторизировали [gun.declent_ru(ACCUSATIVE)] в системе Sibyl System."))
	else if(ACCESS_ARMORY in card_id.GetAccess())
		lock(user)
		to_chat(user, span_notice("Вы принудительно деавторизировали [gun.declent_ru(ACCUSATIVE)] в системе Sibyl System."))

	gun?.update_icon()
	return TRUE

/obj/item/gun_module/sibyl/proc/check_select(select)
	var/obj/item/gun/energy/energy_gun = gun
	if(!energy_gun)
		return FALSE

	var/list/ammo_types = energy_gun.ammo_type
	var/obj/item/ammo_casing/energy/ammo = ammo_types[select]

	return (ammo.sibyl_tier & limit)

/obj/item/gun_module/sibyl/proc/check_auth(mob/living/user)
	if(!gun)
		return FALSE

	if(emagged)
		return TRUE

	var/obj/item/card/id/current_auth = auth_id?.resolve()
	if(!current_auth)
		to_chat(user, span_warning("Требуется авторизация! Приложите ID-карту."))
		return FALSE

	if(!find_and_compare_id_cards(user))
		to_chat(user, span_warning("Ваша ID-карта не совпадает с авторизованной."))
		return FALSE

	return TRUE

/obj/item/gun_module/sibyl/proc/can_fire(mob/living/user)
	if(state != SIBSYS_STATE_WELDER_ACT)
		return TRUE

	if(!prob(10))
		return TRUE

	playsound(loc, SFX_SPARKS, 30, TRUE)
	do_sparks(5, TRUE, src)
	if(!user)
		return FALSE

	to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] выдаёт сбой!"))
	return FALSE

/obj/item/gun_module/sibyl/proc/find_and_compare_id_cards(mob/user)
	var/obj/item/card/id/current_auth = auth_id?.resolve()
	if(!current_auth)
		return FALSE
	for(var/obj/item/card/id/found_id in user.get_all_id_cards())
		if(found_id == current_auth)
			return TRUE
	return FALSE

/obj/item/gun_module/sibyl/proc/sync_limit()
	SIGNAL_HANDLER

	var/obj/item/gun/energy/energy_gun = gun
	if(!energy_gun)
		return

	var/datum/security_level/current_level = SSsecurity_level.current_security_level
	if(!current_level)
		return

	var/old_limit = limit
	var/new_limit = current_level.sibyl_limit

	if(new_limit != old_limit)
		limit = new_limit
		energy_gun.update_icon()
		if(ismob(energy_gun.loc))
			to_chat(energy_gun.loc, span_notice("Для [energy_gun.declent_ru(GENITIVE)] теперь доступны только режимы, соответствующие уровню опасности ([capitalize(SSsecurity_level.get_current_level_as_text())])."))

	if(!check_select(energy_gun.select))
		energy_gun.select_fire()

/obj/item/gun_module/sibyl/proc/toggle_voice(mob/user)
	voice_is_enabled = !voice_is_enabled
	if(!user)
		return
	to_chat(user, span_notice("Голосовая подсистема [voice_is_enabled ? "включена" : "отключена"]."))

/obj/item/gun_module/sibyl/proc/sibyl_sound(mob/living/user, sound, time)
	if(user && voice_is_enabled && !voice_cd)
		user.playsound_local(get_turf(user), sound, 50, FALSE)
		voice_cd = addtimer(VARSET_CALLBACK(src, voice_cd, null), time)

/obj/item/gun_module/sibyl/proc/tool_fumble(mob/living/user, obj/item/tool, damage, damage_type)
	var/obj/item/organ/external/affecting
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		affecting = human.get_organ(user.r_hand == tool ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
	user.apply_damage(damage, damage_type, affecting)
	user.emote("scream")
	to_chat(user, span_warning("Проклятье! [DECLENT_RU_CAP(tool, NOMINATIVE)] сорвал[GEND_SYA_AS_OS_IS(tool)] и повредил[GEND_A_O_I(tool)] [affecting.declent_ru(ACCUSATIVE)]!"))

/obj/item/gun_module/sibyl/proc/on_emag_act(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if(emagged)
		return

	add_attack_logs(user, src, "emagged")
	emagged = TRUE
	unlock(user)

	if(user)
		user.visible_message(span_warning("Из [source.declent_ru(GENITIVE)] летят искры!"), span_notice("Вы взломали [source.declent_ru(ACCUSATIVE)], что привело к выключению [declent_ru(GENITIVE)]."))

/obj/item/gun_module/sibyl/proc/on_screwdriver_act(datum/source, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER

	switch(state)
		if(SIBSYS_STATE_WELDER_ACT)
			to_chat(user, span_warning("Крепление [declent_ru(GENITIVE)] повреждено. Требуется монтировка."))
			return
		if(SIBSYS_STATE_SCREWDRIVER_ACT)
			state = SIBSYS_STATE_INSTALLED
			to_chat(user, span_notice("Вы закрепили [declent_ru(ACCUSATIVE)] в [gun.declent_ru(PREPOSITIONAL)]."))
			return
		if(SIBSYS_STATE_INSTALLED)
			if(!prob(90))
				tool_fumble(user, tool, 5, BRUTE)
				return
			state = SIBSYS_STATE_SCREWDRIVER_ACT
			to_chat(user, span_notice("Вы ослабили крепление [declent_ru(GENITIVE)] на [gun.declent_ru(PREPOSITIONAL)]."))

/obj/item/gun_module/sibyl/proc/on_welder_act(datum/source, mob/living/user, obj/item/tool)
	switch(state)
		if(SIBSYS_STATE_WELDER_ACT)
			to_chat(user, span_warning("Крепление [declent_ru(GENITIVE)] повреждено. Требуется монтировка."))
			return
		if(SIBSYS_STATE_SCREWDRIVER_ACT)
			var/old_state = state
			to_chat(user, span_notice("Вы начинаете разваривать крепление [declent_ru(GENITIVE)]..."))
			if(!tool.use_tool(gun, user, SIBYL_DISMANTLE_DURATION, volume = tool.tool_volume))
				return
			if(state != old_state)
				return
			if(!prob(70))
				tool_fumble(user, tool, 10, BURN)
				return
			state = SIBSYS_STATE_WELDER_ACT
			to_chat(user, span_notice("Вы успешно разварили крепление [declent_ru(GENITIVE)]."))

/obj/item/gun_module/sibyl/proc/on_crowbar_act(datum/source, mob/living/user, obj/item/tool)
	if(state != SIBSYS_STATE_WELDER_ACT)
		return

	to_chat(user, span_notice("Вы начинаете поддевать [declent_ru(ACCUSATIVE)]..."))

	if(!tool.use_tool(gun, user, SIBYL_DISMANTLE_DURATION, volume = tool.tool_volume))
		return

	if(!prob(95))
		tool_fumble(user, tool, 5, BRUTE)
		return
	detach_without_check(gun, user, force = TRUE)
	to_chat(user, span_notice("Вы успешно сняли [declent_ru(ACCUSATIVE)]."))
