// Security Hud //
/datum/pai_software/sec_hud
	name = "Security HUD"
	ram_cost = 15
	id = "sec_hud"
	ui_icon = "exclamation-triangle"
	toggle_software = TRUE

/datum/pai_software/sec_hud/toggle(mob/living/silicon/pai/user)
	user.remove_med_sec_hud()
	user.secHUD = !user.secHUD
	if(user.secHUD)
		user.add_sec_hud()
		user.medHUD = FALSE
		user.adv_secHUD = FALSE

/datum/pai_software/sec_hud/is_active(mob/living/silicon/pai/user)
	return user.secHUD

// Medical Hud //
/datum/pai_software/med_hud
	name = "Medical HUD"
	ram_cost = 15
	id = "med_hud"
	ui_icon = "first-aid"
	toggle_software = TRUE

/datum/pai_software/med_hud/toggle(mob/living/silicon/pai/user)
	user.remove_med_sec_hud()
	user.medHUD = !user.medHUD
	if(user.medHUD)
		user.add_med_hud()
		user.secHUD = FALSE
		user.adv_secHUD = FALSE

/datum/pai_software/med_hud/is_active(mob/living/silicon/pai/user)
	return user.medHUD

// Universal Translator //
/datum/pai_software/translator
	name = "Universal Translator"
	ram_cost = 25
	id = "translator"
	ui_icon = "language"
	toggle_software = TRUE

/datum/pai_software/translator/toggle(mob/living/silicon/pai/user)
	// 	Galactic Common, Sol Common, Tradeband, Gutter and Trinary are added with New() and are therefore the current default, always active languages
	user.translator_on = !user.translator_on
	if(user.translator_on)
		user.add_language(LANGUAGE_UNATHI)
		user.add_language(LANGUAGE_TAJARAN)
		user.add_language(LANGUAGE_VULPKANIN)
		user.add_language(LANGUAGE_SKRELL)
		user.add_language(LANGUAGE_VOX)
		user.add_language(LANGUAGE_DIONA)
		user.add_language(LANGUAGE_KIDAN)
		user.add_language(LANGUAGE_SLIME)
		user.add_language(LANGUAGE_DRASK)
		user.add_language(LANGUAGE_CLOWN)
		user.add_language(LANGUAGE_NEO_RUSSIAN)
		user.add_language(LANGUAGE_MOTH)
	else
		user.remove_language(LANGUAGE_UNATHI)
		user.remove_language(LANGUAGE_TAJARAN)
		user.remove_language(LANGUAGE_VULPKANIN)
		user.remove_language(LANGUAGE_SKRELL)
		user.remove_language(LANGUAGE_VOX)
		user.remove_language(LANGUAGE_DIONA)
		user.remove_language(LANGUAGE_KIDAN)
		user.remove_language(LANGUAGE_SLIME)
		user.remove_language(LANGUAGE_DRASK)
		user.remove_language(LANGUAGE_CLOWN)
		user.remove_language(LANGUAGE_NEO_RUSSIAN)
		user.remove_language(LANGUAGE_MOTH)

/datum/pai_software/translator/is_active(mob/living/silicon/pai/user)
	return user.translator_on

// FLashlight //
/datum/pai_software/flashlight
	name = "Flashlight"
	ram_cost = 5
	id = "flashlight"
	ui_icon = "lightbulb"
	toggle_software = TRUE

/datum/pai_software/flashlight/toggle(mob/living/silicon/pai/user)
	var/atom/movable/actual_location = istype(user.loc, /obj/item/paicard) ? user.loc : user
	if(!user.flashlight_on)
		actual_location.set_light(5)
		user.card.set_light(5)
	else
		actual_location.set_light_on(FALSE)
		user.card.set_light_on(FALSE)

	user.flashlight_on = !user.flashlight_on

/datum/pai_software/flashlight/is_active(mob/living/silicon/pai/user)
	return user.flashlight_on

// Night Vision //
/datum/pai_software/vision
	name = "Night Vision"
	ram_cost = 5
	id = "nignt_vis"
	ui_icon = "bullseye"
	toggle_software = TRUE
	var/sight_mode = SILICONNIGHTVISION

/datum/pai_software/vision/toggle(mob/living/silicon/pai/user)
	if(!is_active(user))
		user.sight_mode |= sight_mode
	else
		user.sight_mode &= ~sight_mode
	user.update_sight()

/datum/pai_software/vision/is_active(mob/living/silicon/pai/user)
	return (user.sight_mode & sight_mode)

// Meson Vision //
/datum/pai_software/vision/meson_vision
	name = "Meson Vision"
	ram_cost = 5
	id = "meson_vis"
	ui_icon = "adjust"
	toggle_software = TRUE
	sight_mode = SILICONMESON

// Advanced Security Hud //
/datum/pai_software/adv_sec_hud
	name = "Advanced Security HUD"
	ram_cost = 20
	id = "adv_sec_hud"
	ui_icon = "exclamation-triangle"
	toggle_software = TRUE
	only_syndi = TRUE

/datum/pai_software/adv_sec_hud/toggle(mob/living/silicon/pai/user)
	user.remove_med_sec_hud()
	user.adv_secHUD = !user.adv_secHUD
	if(user.adv_secHUD)
		user.add_sec_hud()
		user.medHUD = FALSE
		user.secHUD = FALSE

/datum/pai_software/adv_sec_hud/is_active(mob/living/silicon/pai/user)
	return user.adv_secHUD

// Weakened AI Сapability //
/datum/pai_software/weak_ai
	name = "Weakened AI Capability"
	ram_cost = 60
	id = "weak_ai"
	ui_icon = "bug"
	toggle_software = TRUE
	only_syndi = TRUE

/datum/pai_software/weak_ai/toggle(mob/living/silicon/pai/user)
	user.ai_capability = !user.ai_capability

/datum/pai_software/weak_ai/is_active(mob/living/silicon/pai/user)
	return user.ai_capability

// Thermal Vision //
/datum/pai_software/vision/thermal_vision
	name = "Thermal Vision"
	ram_cost = 35
	id = "therm_vis"
	ui_icon = "binoculars"
	toggle_software = TRUE
	only_syndi = TRUE
	sight_mode = SILICONTHERM
