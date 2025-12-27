//Visor modules for MODsuits

/// Base Visor - Adds a specific HUD and traits to you.
/obj/item/mod/module/visor
	name = "MOD visor module"
	desc = "Модуль ИЛС для МЭК, устанавливаемый в визор костюма. Говорят, он позволяет видеть вокруг на триста шестьдесят градусов."
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/visor)
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
	cooldown_time = 0.5 SECONDS
	/// The HUD type given by the visor.
	var/hud_type
	/// The trait given by the visor.
	var/visor_trait = list()

/obj/item/mod/module/visor/get_ru_names()
	return list(
		NOMINATIVE = "модуль ИЛС",
		GENITIVE = "модуля ИЛС",
		DATIVE = "модулю ИЛС",
		ACCUSATIVE = "модуль ИЛС",
		INSTRUMENTAL = "модулем ИЛС",
		PREPOSITIONAL = "модуле ИЛС",
	)

/obj/item/mod/module/visor/on_activation()
	if(hud_type)
		var/datum/atom_hud/hud = GLOB.huds[hud_type]
		hud.show_to(mod.wearer)
	if(length(visor_trait))
		ADD_TRAIT(mod.wearer, visor_trait, MODSUIT_TRAIT)
	mod.wearer.update_sight()

/obj/item/mod/module/visor/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(hud_type)
		var/datum/atom_hud/hud = GLOB.huds[hud_type]
		hud.hide_from(mod.wearer)
	if(length(visor_trait))
		REMOVE_TRAIT(mod.wearer, visor_trait, MODSUIT_TRAIT)
	mod.wearer.update_sight()

// MARK: Medical visor
/// Medical Visor - Gives you a medical HUD.
/obj/item/mod/module/visor/medhud
	name = "MOD medical visor module"
	desc = "Модуль медицинского ИЛС для МЭК, устанавливаемый в визор костюма. Сканирует биометрические данные органических форм жизни в поле зрения \
			и выводит эту информацию на дисплей пользователя. Также даёт доступ к просмотру медицинских записей экипажа объекта."
	icon_state = "medhud_visor"
	hud_type = DATA_HUD_MEDICAL_ADVANCED

/obj/item/mod/module/visor/medhud/get_ru_names()
	return list(
		NOMINATIVE = "модуль медицинского ИЛС",
		GENITIVE = "модуля медицинского ИЛС",
		DATIVE = "модулю медицинского ИЛС",
		ACCUSATIVE = "модуль медицинского ИЛС",
		INSTRUMENTAL = "модулем медицинского ИЛС",
		PREPOSITIONAL = "модуле медицинского ИЛС",
	)

// MARK: Diagnostic visor
/// Diagnostic Visor - Gives you a diagnostic HUD.
/obj/item/mod/module/visor/diaghud
	name = "MOD diagnostic visor module"
	desc = "Модуль диагностического ИЛС для МЭК, использующий набор мощных сенсоров для получения данных о продвинутой \
			машинерии, экзоскелетах и других устройствах. Выводит на дисплей пользователя информацию об их заряде и прочности."
	icon_state = "diaghud_visor"
	hud_type = DATA_HUD_DIAGNOSTIC

/obj/item/mod/module/visor/diaghud/get_ru_names()
	return list(
		NOMINATIVE = "модуль диагностического ИЛС",
		GENITIVE = "модуля диагностического ИЛС",
		DATIVE = "модулю диагностического ИЛС",
		ACCUSATIVE = "модуль диагностического ИЛС",
		INSTRUMENTAL = "модулем диагностического ИЛС",
		PREPOSITIONAL = "модуле диагностического ИЛС",
	)

// MARK: Security visor
/// Security Visor - Gives you a security HUD.
/obj/item/mod/module/visor/sechud
	name = "MOD security visor module"
	desc = "Модуль охранного ИЛС для МЭК с усовершенствованной системой тактического распознавания целей. Подключается к \
			базам данных службы безопасности, позволяя просматривать записи членов экипажа объекта, отдавать визуальные команды примитивным охранным \
			роботам и считывать данные с ID-карт."
	icon_state = "sechud_visor"
	hud_type = DATA_HUD_SECURITY_ADVANCED

/obj/item/mod/module/visor/sechud/get_ru_names()
	return list(
		NOMINATIVE = "модуль охранного ИЛС",
		GENITIVE = "модуля охранного ИЛС",
		DATIVE = "модулю охранного ИЛС",
		ACCUSATIVE = "модуль охранного ИЛС",
		INSTRUMENTAL = "модулем охранного ИЛС",
		PREPOSITIONAL = "модуле охранного ИЛС",
	)

// MARK: Meson visor
/// Meson Visor - Gives you meson vision.
/obj/item/mod/module/visor/meson
	name = "MOD meson visor module"
	desc = "Модуль мезонного ИЛС для МЭК, устанавливаемый в визор костюма. Принцип работы основан на технологии мезонного сканирования, \
			широко применяемой в строительстве и горнодобывающей отрасли. Позволяет видеть структуру и внутренние слои ландшафта через стены, \
			вне зависимости от уровня освещения."
	icon_state = "meson_visor"
	visor_trait = TRAIT_MESON_VISION

/obj/item/mod/module/visor/meson/get_ru_names()
	return list(
		NOMINATIVE = "модуль мезонного ИЛС",
		GENITIVE = "модуля мезонного ИЛС",
		DATIVE = "модулю мезонного ИЛС",
		ACCUSATIVE = "модуль мезонного ИЛС",
		INSTRUMENTAL = "модулем мезонного ИЛС",
		PREPOSITIONAL = "модуле мезонного ИЛС",
	)

// MARK: Thermal visor
/// Thermal Visor - Gives you thermal vision.
/obj/item/mod/module/visor/thermal
	name = "MOD thermal visor module"
	desc = "Модуль термального ИЛС для МЭК, устанавливаемый в визор костюма. Оснащён многоспектральным ИК-сканером, \
			позволяющим обнаруживать тепловые сигнатуры целей через препятствия."
	icon_state = "thermal_visor"
	origin_tech = "combat=6;engineering=6;syndicate=2"
	visor_trait = TRAIT_THERMAL_VISION

/obj/item/mod/module/visor/thermal/get_ru_names()
	return list(
		NOMINATIVE = "модуль термального ИЛС",
		GENITIVE = "модуля термального ИЛС",
		DATIVE = "модулю термального ИЛС",
		ACCUSATIVE = "модуль термального ИЛС",
		INSTRUMENTAL = "модулем термального ИЛС",
		PREPOSITIONAL = "модуле термального ИЛС",
	)

// MARK: Night vision
/// Night Visor - Gives you night vision.
/obj/item/mod/module/visor/night
	name = "MOD night visor module"
	desc = "Модуль ночного видения для МЭК, устанавливаемый в визор костюма. Оборудован продвинутой системой светосбора \
			и контроля уровня освещённости, что обеспечивает чёткую видимость в любых условиях освещённости."
	icon_state = "night_visor"
	origin_tech = "combat=5;engineering=5;syndicate=1"
	visor_trait = TRAIT_NIGHT_VISION

/obj/item/mod/module/visor/night/get_ru_names()
	return list(
		NOMINATIVE = "модуль ночного видения",
		GENITIVE = "модуля ночного видения",
		DATIVE = "модулю ночного видения",
		ACCUSATIVE = "модуль ночного видения",
		INSTRUMENTAL = "модулем ночного видения",
		PREPOSITIONAL = "модуле ночного видения",
	)
