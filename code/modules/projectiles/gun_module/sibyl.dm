/**
 * # Sibyl System Module
 */

// Sibyl System limit level
#define SIBYL_NONLETHAL 1
#define SIBYL_LETHAL 2
#define SIBYL_DESTRUCTIVE 3

// Sibyl System states
#define SIBSYS_STATE_UNINSTALLED 0
#define SIBSYS_STATE_INSTALLED 1
#define SIBSYS_STATE_SCREWDRIVER_ACT 2
#define SIBSYS_STATE_WELDER_ACT 3

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

	var/state = SIBSYS_STATE_UNINSTALLED

	var/obj/item/card/id/auth_id = null

	var/limit = SIBYL_NONLETHAL

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

/obj/item/gun_module/sibyl/Initialize(mapload)
	. = ..()
	available = nonlethal_names

/obj/item/gun_module/sibyl/Destroy()
	if(registered)
		UnregisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED)
	QDEL_NULL(auth_id)
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
	if(!istype(target_gun, /obj/item/gun/energy))
		if(user)
			user.balloon_alert(user, "несовместимо с Sibyl System")
		return FALSE

	var/obj/item/gun/energy/energy_gun = target_gun

	if(!energy_gun.can_add_sibyl_system)
		if(user)
			user.balloon_alert(user, "оружие не поддерживает Sibyl System")
		return FALSE

	if(energy_gun.sibyl_mod)
		if(user)
			user.balloon_alert(user, "модуль уже установлен")
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

	sibyl_sound(user, 'sound/voice/dominator/link.ogg', 10 SECONDS)

	check_unknown_names(energy_gun)

	sync_limit()

	energy_gun.update_icon()

	if(user)
		to_chat(user, span_notice("Вы установили [declent_ru(ACCUSATIVE)] в [energy_gun.declent_ru(ACCUSATIVE)]. Установка доступных режимов в соответствии с уровнем опасности ([capitalize(SSsecurity_level.get_current_level_as_text())])."))
		if(!auth_id)
			to_chat(user, span_notice("Требуется авторизация! Приложите ID-карту."))

/obj/item/gun_module/sibyl/on_detach(obj/item/gun/target_gun, mob/user)
	var/obj/item/gun/energy/energy_gun = target_gun

	if(registered)
		UnregisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED)
		registered = FALSE

	energy_gun.verbs -= /obj/item/gun/energy/proc/toggle_voice

	state = SIBSYS_STATE_UNINSTALLED
	lock(silent = TRUE)

	energy_gun.sibyl_mod = null

	set_limit(SIBYL_NONLETHAL)

	energy_gun.update_icon()

/obj/item/gun_module/sibyl/proc/lock(mob/user, silent = FALSE)
	if(emagged)
		return FALSE
	auth_id = null
	gun?.update_icon()
	if(!silent && user)
		to_chat(user, span_notice("Блокировка [gun.declent_ru(GENITIVE)] включена."))
	return TRUE

/obj/item/gun_module/sibyl/proc/unlock(mob/user, obj/item/card/id/ID)
	if(state != SIBSYS_STATE_INSTALLED)
		return FALSE
	if(ID)
		auth_id = ID
	else
		auth_id = TRUE
	gun?.update_icon()
	if(user)
		to_chat(user, span_notice("Блокировка [gun.declent_ru(GENITIVE)] отключена."))
	return TRUE

/obj/item/gun_module/sibyl/proc/toggleAuthorization(obj/item/card/id/ID, mob/user)
	if(state != SIBSYS_STATE_INSTALLED)
		return FALSE
	if(emagged)
		to_chat(user, span_danger("ОШИБКА АУТЕНТИФИКАЦИИ: [ID] вызывает короткое замыкание при сканировании!"))
		return
	if(!auth_id)
		unlock(user, ID)
		to_chat(user, span_notice("Вы авторизировали [gun.declent_ru(ACCUSATIVE)] в системе Sibyl System под именем [auth_id.registered_name]."))
		sibyl_sound(user, 'sound/voice/dominator/user.ogg', 10 SECONDS)
	else if(auth_id == ID)
		lock(user)
		to_chat(user, span_notice("Вы деавторизировали [gun.declent_ru(ACCUSATIVE)] в системе Sibyl System."))
	else if(ACCESS_ARMORY in ID.GetAccess())
		lock(user)
		to_chat(user, span_notice("Вы принудительно деавторизировали [gun.declent_ru(ACCUSATIVE)] в системе Sibyl System."))
	gun?.update_icon()
	return TRUE

/obj/item/gun_module/sibyl/proc/check_select(select)
	var/obj/item/gun/energy/energy_gun = gun
	if(!energy_gun)
		return FALSE

	var/obj/item/ammo_casing/energy/ammo = energy_gun.ammo_type[select]
	if(lowertext(ammo.select_name) in available)
		return TRUE
	else
		check_unknown_names(energy_gun)
	return FALSE

/obj/item/gun_module/sibyl/proc/check_auth(mob/living/user)
	if(!gun)
		return FALSE
	if(!emagged)
		if(!auth_id)
			to_chat(user, span_warning("Требуется авторизация! Приложите ID-карту."))
			return FALSE
		if(!find_and_compare_id_cards(user))
			to_chat(user, span_warning("Ваша ID-карта не совпадает с авторизованной."))
			return FALSE
	return TRUE

/obj/item/gun_module/sibyl/proc/find_and_compare_id_cards(mob/user)
	for(var/obj/item/card/id/found_id in user.get_all_id_cards())
		if(found_id == auth_id)
			return TRUE
	return FALSE

/obj/item/gun_module/sibyl/proc/set_limit(mode)
	if(!gun)
		return FALSE

	limit = mode
	switch(mode)
		if(SIBYL_NONLETHAL)
			available = nonlethal_names
		if(SIBYL_LETHAL)
			available = nonlethal_names + lethal_names
		if(SIBYL_DESTRUCTIVE)
			available = nonlethal_names + lethal_names + destructive_names

	var/obj/item/gun/energy/energy_gun = gun
	var/message = "Для [energy_gun.declent_ru(GENITIVE)] теперь доступны только данные режимы: [get_available_text()]!"
	energy_gun.update_icon()
	if(ismob(energy_gun.loc))
		to_chat(energy_gun.loc, span_notice("[message]"))
	return TRUE

/obj/item/gun_module/sibyl/proc/sync_limit(datum/source, old_level, new_level)
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

	var/obj/item/gun/energy/energy_gun = gun
	if(!energy_gun)
		return
	if(!check_select(energy_gun.select))
		energy_gun.select_fire()

/obj/item/gun_module/sibyl/proc/check_unknown_names(obj/item/gun/energy/energy_gun)
	var/list/known_names = nonlethal_names + lethal_names + destructive_names
	for(var/obj/item/ammo_casing/energy/ammo in energy_gun.ammo_type)
		if(!(ammo.select_name in known_names))
			nonlethal_names += list(ammo.select_name)

/obj/item/gun_module/sibyl/proc/get_available_text()
	var/list/names = list()
	var/obj/item/gun/energy/energy_gun = gun
	if(!energy_gun)
		return ""
	for(var/obj/item/ammo_casing/energy/ammo in energy_gun.ammo_type)
		if(ammo.select_name in available)
			names += list(ammo.select_name)
	return names.Join(", ")

/obj/item/gun_module/sibyl/proc/toggle_voice(mob/user)
	voice_is_enabled = !voice_is_enabled
	if(user)
		to_chat(user, span_notice("Голосовая подсистема [voice_is_enabled ? "включена" : "отключена"]."))

/obj/item/gun_module/sibyl/proc/sibyl_sound(mob/living/user, sound, time)
	if(user && voice_is_enabled && !voice_cd)
		user.playsound_local(get_turf(user), sound, 50, FALSE)
		voice_cd = addtimer(VARSET_CALLBACK(src, voice_cd, null), time)

/obj/item/gun_module/sibyl/screwdriver_act(mob/living/user, obj/item/I)
	if(state == SIBSYS_STATE_SCREWDRIVER_ACT)
		state = SIBSYS_STATE_INSTALLED
		to_chat(user, span_notice("Вы закрепили [declent_ru(ACCUSATIVE)] в [gun.declent_ru(PREPOSITIONAL)]."))
		return
	else
		if(prob(90))
			state = SIBSYS_STATE_SCREWDRIVER_ACT
			to_chat(user, span_notice("Вы ослабили крепление [declent_ru(GENITIVE)] на [gun.declent_ru(PREPOSITIONAL)]."))
		else
			var/mob/living/carbon/human/H = user
			var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
			user.apply_damage(5, BRUTE, affecting)
			user.emote("scream")
			to_chat(user, span_warning("Проклятье! [DECLENT_RU_CAP(I, NOMINATIVE)] сорвал[GEND_SYA_AS_OS_IS(I)]ась и повредил[GEND_A_O_I(I)] [affecting.declent_ru(ACCUSATIVE)]!"))
		return

/obj/item/gun_module/sibyl/welder_act(mob/living/user, obj/item/I)
	if(state == SIBSYS_STATE_WELDER_ACT)
		to_chat(user, span_notice("Вы начинаете заваривать болты [declent_ru(GENITIVE)] к [gun.declent_ru(DATIVE)]..."))
		if(I.use_tool(gun, user, 16 SECONDS, volume = I.tool_volume))
			state = SIBSYS_STATE_SCREWDRIVER_ACT
			to_chat(user, span_notice("Вы заварили болты [declent_ru(GENITIVE)] к [gun.declent_ru(DATIVE)]."))
		return

	if(state == SIBSYS_STATE_SCREWDRIVER_ACT)
		var/old_state = state
		to_chat(user, span_notice("Вы начинаете разваривать болты [declent_ru(GENITIVE)] от [gun.declent_ru(GENITIVE)]..."))
		if(I.use_tool(gun, user, 16 SECONDS, volume = I.tool_volume))
			if(state != old_state)
				return
			if(prob(70))
				state = SIBSYS_STATE_WELDER_ACT
				to_chat(user, span_notice("Вы успешно разварили болты [declent_ru(GENITIVE)] от [gun.declent_ru(GENITIVE)]."))
			else
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
				user.apply_damage(10, BURN, affecting)
				user.emote("scream")
				to_chat(user, span_warning("Проклятье! [DECLENT_RU_CAP(I, NOMINATIVE)] сорвал[GEND_SYA_AS_OS_IS(I)]ась и повредил[GEND_A_O_I(I)] [affecting.declent_ru(ACCUSATIVE)]!"))
		return

/obj/item/gun_module/sibyl/crowbar_act(mob/living/user, obj/item/I)
	if(state != SIBSYS_STATE_WELDER_ACT)
		return

	to_chat(user, span_notice("Вы начинаете поддевать крепление [declent_ru(GENITIVE)] от [gun.declent_ru(GENITIVE)]..."))

	if(!I.use_tool(gun, user, 16 SECONDS, volume = I.tool_volume))
		return

	if(prob(95))
		detach_without_check(gun, user, force = TRUE)
		to_chat(user, span_notice("Вы успешно сняли крепление [declent_ru(GENITIVE)] от [gun.declent_ru(GENITIVE)]."))
	else
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
		user.apply_damage(5, BRUTE, affecting)
		user.emote("scream")
		to_chat(user, span_warning("Проклятье! [DECLENT_RU_CAP(I, NOMINATIVE)] сорвал[GEND_SYA_AS_OS_IS(I)]ась и повредил[GEND_A_O_I(I)] [affecting.declent_ru(ACCUSATIVE)]!"))
	return

#undef SIBYL_NONLETHAL
#undef SIBYL_LETHAL
#undef SIBYL_DESTRUCTIVE
#undef SIBSYS_STATE_UNINSTALLED
#undef SIBSYS_STATE_INSTALLED
#undef SIBSYS_STATE_SCREWDRIVER_ACT
#undef SIBSYS_STATE_WELDER_ACT
