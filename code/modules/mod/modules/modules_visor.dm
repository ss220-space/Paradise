//Visor modules for MODsuits

///Base Visor - Adds a specific HUD and traits to you.
/obj/item/mod/module/visor
	name = "MOD visor module"
	desc = "A heads-up display installed into the visor of the suit. They say these also let you see behind you."
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/visor)
	cooldown_time = 0.5 SECONDS
	/// The HUD type given by the visor.
	var/hud_type
	/// The trait given by the visor.
	var/visor_trait = list()

/obj/item/mod/module/visor/get_ru_names()
	return list(
		NOMINATIVE = "модуль ИЛС для МЭК",
		GENITIVE = "модуля ИЛС для МЭК",
		DATIVE = "модулю ИЛС для МЭК",
		ACCUSATIVE = "модуль ИЛС для МЭК",
		INSTRUMENTAL = "модулем ИЛС для МЭК",
		PREPOSITIONAL = "модуле ИЛС для МЭК",
	)

/obj/item/mod/module/visor/on_activation()
	if(hud_type)
		var/datum/atom_hud/hud = GLOB.huds[hud_type]
		hud.add_hud_to(mod.wearer)
	if(length(visor_trait))
		ADD_TRAIT(mod.wearer, visor_trait, MODSUIT_TRAIT)
	mod.wearer.update_sight()

/obj/item/mod/module/visor/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(hud_type)
		var/datum/atom_hud/hud = GLOB.huds[hud_type]
		hud.remove_hud_from(mod.wearer)
	if(length(visor_trait))
		REMOVE_TRAIT(mod.wearer, visor_trait, MODSUIT_TRAIT)
	mod.wearer.update_sight()

//Medical Visor - Gives you a medical HUD.
/obj/item/mod/module/visor/medhud
	name = "MOD medical visor module"
	desc = "A heads-up display installed into the visor of the suit. This cross-references suit sensor data with a modern \
		biological scanning suite, allowing the user to visualize the current health of organic lifeforms, as well as \
		access data such as patient files in a convenient readout. They say these also let you see behind you."
	icon_state = "medhud_visor"
	hud_type = DATA_HUD_MEDICAL_ADVANCED

/obj/item/mod/module/visor/medhud/get_ru_names()
	return list(
		NOMINATIVE = "модуль медицинского ИЛС для МЭК",
		GENITIVE = "модуля медицинского ИЛС для МЭК",
		DATIVE = "модулю медицинского ИЛС для МЭК",
		ACCUSATIVE = "модуль медицинского ИЛС для МЭК",
		INSTRUMENTAL = "модулем медицинского ИЛС для МЭК",
		PREPOSITIONAL = "модуле медицинского ИЛС для МЭК",
	)

//Diagnostic Visor - Gives you a diagnostic HUD.
/obj/item/mod/module/visor/diaghud
	name = "MOD diagnostic visor module"
	desc = "A heads-up display installed into the visor of the suit. This uses a series of advanced sensors to access data \
		from advanced machinery, exosuits, and other devices, allowing the user to visualize current power levels \
		and integrity of such. They say these also let you see behind you."
	icon_state = "diaghud_visor"
	hud_type = DATA_HUD_DIAGNOSTIC_ADVANCED

/obj/item/mod/module/visor/diaghud/get_ru_names()
	return list(
		NOMINATIVE = "модуль диагностического ИЛС для МЭК",
		GENITIVE = "модуля диагностического ИЛС для МЭК",
		DATIVE = "модулю диагностического ИЛС для МЭК",
		ACCUSATIVE = "модуль диагностического ИЛС для МЭК",
		INSTRUMENTAL = "модулем диагностического ИЛС для МЭК",
		PREPOSITIONAL = "модуле диагностического ИЛС для МЭК",
	)

//Security Visor - Gives you a security HUD.
/obj/item/mod/module/visor/sechud
	name = "MOD security visor module"
	desc = "A heads-up display installed into the visor of the suit. This module is a heavily-retrofitted targeting system, \
		plugged into various criminal databases to be able to view arrest records, command simple security-oriented robots, \
		and generally know who to shoot. They say these also let you see behind you."
	icon_state = "sechud_visor"
	hud_type = DATA_HUD_SECURITY_ADVANCED

/obj/item/mod/module/visor/sechud/get_ru_names()
	return list(
		NOMINATIVE = "модуль ИЛС службы безопасности для МЭК",
		GENITIVE = "модуля ИЛС  службы безопасностидля МЭК",
		DATIVE = "модулю ИЛС  службы безопасностидля МЭК",
		ACCUSATIVE = "модуль ИЛС  службы безопасностидля МЭК",
		INSTRUMENTAL = "модулем ИЛС  службы безопасностидля МЭК",
		PREPOSITIONAL = "модуле ИЛС  службы безопасностидля МЭК",
	)

//Meson Visor - Gives you meson vision.
/obj/item/mod/module/visor/meson
	name = "MOD meson visor module"
	desc = "A heads-up display installed into the visor of the suit. This module is based off well-loved meson scanner \
		technology, used by construction workers and miners across the galaxy to see basic structural and terrain layouts \
		through walls, regardless of lighting conditions. They say these also let you see behind you."
	icon_state = "meson_visor"
	visor_trait = TRAIT_MESON_VISION

/obj/item/mod/module/visor/meson/get_ru_names()
	return list(
		NOMINATIVE = "модуль мезонного зрения для МЭК",
		GENITIVE = "модуля мезонного зрения для МЭК",
		DATIVE = "модулю мезонного зрения для МЭК",
		ACCUSATIVE = "модуль мезонного зрения для МЭК",
		INSTRUMENTAL = "модулем мезонного зрения для МЭК",
		PREPOSITIONAL = "модуле мезонного зрения для МЭК",
	)

//Thermal Visor - Gives you thermal vision.
/obj/item/mod/module/visor/thermal
	name = "MOD thermal visor module"
	desc = "A heads-up display installed into the visor of the suit. This uses a small IR scanner to detect and identify \
		the thermal radiation output of objects near the user. While it can detect the heat output of even something as \
		small as a rodent, it still produces irritating red overlay. They say these also let you see behind you."
	icon_state = "thermal_visor"
	origin_tech = "combat=6;engineering=6;syndicate=2"
	visor_trait = TRAIT_THERMAL_VISION

/obj/item/mod/module/visor/thermal/get_ru_names()
	return list(
		NOMINATIVE = "модуль термального зрения для МЭК",
		GENITIVE = "модуля термального зрения для МЭК",
		DATIVE = "модулю термального зрения для МЭК",
		ACCUSATIVE = "модуль термального зрения для МЭК",
		INSTRUMENTAL = "модулем термального зрения для МЭК",
		PREPOSITIONAL = "модуле термального зрения для МЭК",
	)

//Night Visor - Gives you night vision.
/obj/item/mod/module/visor/night
	name = "MOD night visor module"
	desc = "A heads-up display installed into the visor of the suit. Typical for both civilian and military applications, \
		this allows the user to perceive their surroundings while in complete darkness, enhancing the view by tenfold; \
		yet brightening everything into a spooky green glow. They say these also let you see behind you."
	icon_state = "night_visor"
	origin_tech = "combat=5;engineering=5;syndicate=1"
	visor_trait = TRAIT_NIGHT_VISION

/obj/item/mod/module/visor/night/get_ru_names()
	return list(
		NOMINATIVE = "модуль ночного зрения для МЭК",
		GENITIVE = "модуля ночного зрения для МЭК",
		DATIVE = "модулю ночного зрения для МЭК",
		ACCUSATIVE = "модуль ночного зрения для МЭК",
		INSTRUMENTAL = "модулем ночного зрения для МЭК",
		PREPOSITIONAL = "модуле ночного зрения для МЭК",
	)
