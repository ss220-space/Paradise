// MARK: Base HUD Glasses
/obj/item/clothing/glasses/hud
	abstract_type = /obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "Проекционный дисплей, выводящий важную информацию практически в реальном времени."
	origin_tech = "magnets=3;biotech=2"
	prescription_upgradable = TRUE
	/// The visual icons granted by wearing these glasses.
	var/HUDType = null

/obj/item/clothing/glasses/hud/get_ru_names()
	return alist(
		NOMINATIVE = "ИЛС-очки",
		GENITIVE = "ИЛС-очков",
		DATIVE = "ИЛС-очкам",
		ACCUSATIVE = "ИЛС-очки",
		INSTRUMENTAL = "ИЛС-очками",
		PREPOSITIONAL = "ИЛС-очках",
	)

/obj/item/clothing/glasses/hud/examine(mob/user)
	. = ..()
	if(emagged)
		. += span_warning("Дисплей едва заметно мерцает.")

/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot, initial)
	. = ..()
	if(!istype(user) || !HUDType || !(slot & (ITEM_SLOT_EYES|ITEM_SLOT_HEAD)))
		return .

	if(islist(HUDType))
		for(var/new_hud in HUDType)
			var/datum/atom_hud/hud = GLOB.huds[new_hud]
			hud.show_to(user)
		return .

	var/datum/atom_hud/hud = GLOB.huds[HUDType]
	hud.show_to(user)

/obj/item/clothing/glasses/hud/dropped(mob/living/carbon/human/user, slot, silent = FALSE)
	. = ..()
	if(!istype(user) || !HUDType || !(slot & (ITEM_SLOT_EYES|ITEM_SLOT_HEAD)))
		return .

	if(islist(HUDType))
		for(var/new_hud in HUDType)
			var/datum/atom_hud/hud = GLOB.huds[new_hud]
			hud.hide_from(user)
		return .

	var/datum/atom_hud/hud = GLOB.huds[HUDType]
	hud.hide_from(user)

/obj/item/clothing/glasses/hud/emp_act(severity)
	. = ..()
	if(!emagged)
		emagged = TRUE

/obj/item/clothing/glasses/hud/visor_toggling(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	if(visor_vars_to_toggle & VISOR_EXAM_EXTENTIONS)
		examine_extensions ^= initial(examine_extensions)

	if(visor_vars_to_toggle & VISOR_HUDTYPE)
		HUDType ^= initial(HUDType)

		var/datum/atom_hud/H = GLOB.huds[initial(HUDType)]
		if(istype(user) && src == user.glasses)
			if(HUDType)
				H.show_to(user)
			else
				H.hide_from(user)

/// Allows you to toggle HUDType on glasses.
/obj/item/clothing/glasses/hud/proc/multiHUD_toggling(mob/living/carbon/human/user)
	if(!HUDType || !user)
		return

	var/datum/atom_hud/oldHUD = GLOB.huds[HUDType]
	var/hudMode = null

	// DATA_HUD_MEDICAL_ADVANCED ->  DATA_HUD_SECURITY_ADVANCED
	switch(HUDType)
		if(DATA_HUD_MEDICAL_ADVANCED)
			HUDType = DATA_HUD_SECURITY_ADVANCED
			examine_extensions = EXAMINE_HUD_SECURITY_READ | EXAMINE_HUD_SECURITY_WRITE
			hudMode = "охранный"
		if(DATA_HUD_SECURITY_ADVANCED)
			HUDType = DATA_HUD_MEDICAL_ADVANCED
			examine_extensions = EXAMINE_HUD_MEDICAL
			hudMode = "медицинский"

	if(user.glasses == src)
		oldHUD.hide_from(user)
		var/datum/atom_hud/newHUD = GLOB.huds[HUDType]
		newHUD.show_to(user)

	balloon_alert(user, "режим ИЛС — [hudMode]")
	playsound(user, 'sound/items/buttonclick.ogg', 50, TRUE)

// MARK: Medical
/obj/item/clothing/glasses/hud/health
	name = "Medical HUD"
	desc = "Проекционный дисплей, носимый в качестве очков. Оснащён медицинским модулем, сканирующим живых существ в поле зрения и визуализирующим данные об их состоянии здоровья."
	icon_state = "healthhud"
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = EXAMINE_HUD_MEDICAL

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/health/get_ru_names()
	return alist(
		NOMINATIVE = "медицинские ИЛС-очки",
		GENITIVE = "медицинских ИЛС-очков",
		DATIVE = "медицинским ИЛС-очкам",
		ACCUSATIVE = "медицинские ИЛС-очки",
		INSTRUMENTAL = "медицинскими ИЛС-очками",
		PREPOSITIONAL = "медицинских ИЛС-очках",
	)

/obj/item/clothing/glasses/hud/health/night
	name = "Night Vision Medical HUD"
	desc = "Проекционный дисплей, носимый в качестве очков. Оснащён медицинским модулем, сканирующим живых существ в поле зрения и визуализирующим данные об их состоянии здоровья. \
			В данную модель встроена светочувствительная матрица, повышающая видимость в условиях ограниченного освещения."
	icon_state = "healthhudnight"
	item_state = "nvghud"
	origin_tech = "magnets=4;biotech=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/health/night/get_ru_names()
	return alist(
		NOMINATIVE = "медицинские ИЛС-очки ночного видения",
		GENITIVE = "медицинских ИЛС-очков ночного видения",
		DATIVE = "медицинским ИЛС-очкам ночного видения",
		ACCUSATIVE = "медицинские ИЛС-очки ночного видения",
		INSTRUMENTAL = "медицинскими ИЛС-очками ночного видения",
		PREPOSITIONAL = "медицинских ИЛС-очках ночного видения",
	)

/obj/item/clothing/glasses/hud/health/heart
	name = "Heart Medical Glasses"
	desc = "Модные очки в виде сердечек. Оснащены медицинским ИЛС-дисплеем, сканирующим живых существ в поле зрения и визуализирующим данные об их состоянии здоровья."
	icon_state = "heart_med"
	item_state = "heart_med"

/obj/item/clothing/glasses/hud/health/heart/get_ru_names()
	return alist(
		NOMINATIVE = "медицинские очки-сердечки",
		GENITIVE = "медицинских очков-сердечек",
		DATIVE = "медицинским очкам-сердечкам",
		ACCUSATIVE = "медицинские очки-сердечки",
		INSTRUMENTAL = "медицинскими очками-сердечками",
		PREPOSITIONAL = "медицинских очках-сердечках",
	)

/obj/item/clothing/glasses/hud/health/patch
	name = "Medical HUD Eyepatch"
	desc = "Проекционная повязка на глаз. Оснащена медицинским ИЛС-дисплеем, сканирующим живых существ в поле зрения и визуализирующим данные об их состоянии здоровья."
	gender = FEMALE
	icon_state = "medhudpatch"
	item_state = "medhudpatch"
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/health/patch/get_ru_names()
	return alist(
		NOMINATIVE = "медицинская ИЛС-повязка на глаз",
		GENITIVE = "медицинской ИЛС-повязки на глаз",
		DATIVE = "медицинской ИЛС-повязке на глаз",
		ACCUSATIVE = "медицинскую ИЛС-повязку на глаз",
		INSTRUMENTAL = "медицинской ИЛС-повязкой на глаз",
		PREPOSITIONAL = "медицинской ИЛС-повязке на глаз",
	)

/obj/item/clothing/glasses/hud/health/sunglasses
	name = "medical sunglasses"
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			Оснащены медицинским ИЛС-дисплеем, сканирующим живых существ в поле зрения и визуализирующим данные об их состоянии здоровья."
	icon_state = "sunhudmed"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/hud/health/sunglasses/get_ru_names()
	return alist(
		NOMINATIVE = "медицинские солнцезащитные очки",
		GENITIVE = "медицинских солнцезащитных очков",
		DATIVE = "медицинским солнцезащитным очкам",
		ACCUSATIVE = "медицинские солнцезащитные очки",
		INSTRUMENTAL = "медицинскими солнцезащитными очками",
		PREPOSITIONAL = "медицинских солнцезащитных очках",
	)

/obj/item/clothing/glasses/hud/health/tajblind
	name = "medical veil"
	desc = "Адомайская вуаль, скрывающая глаза владельца от посторонних, но не затрудняя обзор носителю. Эта модель оснащена медицинским ИЛС."
	gender = FEMALE
	icon_state = "tajblind_med"
	item_state = "tajblind_med"
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/health/tajblind/get_ru_names()
	return alist(
		NOMINATIVE = "медицинская вуаль",
		GENITIVE = "медицинской вуали",
		DATIVE = "медицинской вуали",
		ACCUSATIVE = "медицинскую вуаль",
		INSTRUMENTAL = "медицинской вуалью",
		PREPOSITIONAL = "медицинской вуали",
	)

/obj/item/clothing/glasses/hud/health/tajblind/sunglasses
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/hud/health/tajblind/attack_self(mob/user)
	toggle_veil(user)

/obj/item/clothing/glasses/hud/health/visor
	name = "Medical optical visor"
	desc = "Технологичный визор для глаз. Оснащён медицинским ИЛС-дисплеем, сканирующим живых существ в поле зрения и визуализирующим данные об их состоянии здоровья."
	gender = MALE
	icon_state = "medicalvisor"
	item_state = "medicalvisor"

/obj/item/clothing/glasses/hud/health/visor/get_ru_names()
	return alist(
		NOMINATIVE = "медицинский оптический визор",
		GENITIVE = "медицинского оптического визора",
		DATIVE = "медицинскому оптическому визору",
		ACCUSATIVE = "медицинский оптический визор",
		INSTRUMENTAL = "медицинским оптическим визором",
		PREPOSITIONAL = "медицинском оптическом визоре",
	)

/obj/item/clothing/glasses/hud/health/meson
	name = "Medical-Meson HUD"
	desc = "Специальные очки, используемые для визуального обнаружения брешей и полостей в окружающем пространстве. \
			Оснащены медицинским ИЛС-дисплеем, сканирующим живых существ в поле зрения и визуализирующим данные об их состоянии здоровья."
	icon_state = "mesonhealth"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/glasses/hud/health/meson/get_ru_names()
	return alist(
		NOMINATIVE = "медицинские мезонные ИЛС-очки",
		GENITIVE = "медицинских мезонных ИЛС-очков",
		DATIVE = "медицинским мезонным ИЛС-очкам",
		ACCUSATIVE = "медицинские мезонные ИЛС-очки",
		INSTRUMENTAL = "медицинскими мезонными ИЛС-очками",
		PREPOSITIONAL = "медицинских мезонных ИЛС-очках"
	)

/obj/item/clothing/glasses/hud/health/monocle
	name = "Medical HUD Monocle"
	desc = "Оптический прибор, носимый путём зажатия мышцами лица. \
			Оснащён медицинским ИЛС-дисплеем, сканирующим живых существ в поле зрения и визуализирующим данные об их состоянии здоровья."
	gender = MALE
	icon_state = "monohudmed"
	item_state = "monohud"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/health/monocle/get_ru_names()
	return alist(
		NOMINATIVE = "медицинский ИЛС-монокль",
		GENITIVE = "медицинского ИЛС-монокля",
		DATIVE = "медицинскому ИЛС-моноклю",
		ACCUSATIVE = "медицинский ИЛС-монокль",
		INSTRUMENTAL = "медицинским ИЛС-моноклем",
		PREPOSITIONAL = "медицинском ИЛС-монокле",
	)

// MARK: Diagnostic
/obj/item/clothing/glasses/hud/diagnostic
	name = "Diagnostic HUD"
	desc = "Проекционный дисплей, носимый в качестве очков. Оснащён диагностическим модулем, анализирующим целостность и состояние роботизированных систем."
	icon_state = "diagnostichud"
	origin_tech = "magnets=2;engineering=2"
	HUDType = DATA_HUD_DIAGNOSTIC

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/diagnostic/get_ru_names()
	return alist(
		NOMINATIVE = "диагностические ИЛС-очки",
		GENITIVE = "диагностических ИЛС-очков",
		DATIVE = "диагностическим ИЛС-очкам",
		ACCUSATIVE = "диагностические ИЛС-очки",
		INSTRUMENTAL = "диагностическими ИЛС-очками",
		PREPOSITIONAL = "диагностических ИЛС-очках",
	)

/obj/item/clothing/glasses/hud/diagnostic/patch
	name = "Diagnostic HUD Eyepatch"
	desc = "Проекционная повязка на глаз. Оснащена диагностическим ИЛС-дисплеем, анализирующим целостность и состояние роботизированных систем."
	gender = FEMALE
	icon_state = "diaghudpatch"
	item_state = "diaghudpatch"
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/diagnostic/patch/get_ru_names()
	return alist(
		NOMINATIVE = "диагностическая ИЛС-повязка на глаз",
		GENITIVE = "диагностической ИЛС-повязки на глаз",
		DATIVE = "диагностической ИЛС-повязке на глаз",
		ACCUSATIVE = "диагностическую ИЛС-повязку на глаз",
		INSTRUMENTAL = "диагностической ИЛС-повязкой на глаз",
		PREPOSITIONAL = "диагностической ИЛС-повязке на глаз",
	)

/obj/item/clothing/glasses/hud/diagnostic/heart
	name = "Heart Diagnostic Glasses"
	desc = "Модные очки в виде сердечек. Оснащены диагностическим ИЛС-дисплеем, анализирующим целостность и состояние роботизированных систем."
	icon_state = "heart_diagnostic"
	item_state = "heart_diagnostic"

/obj/item/clothing/glasses/hud/diagnostic/heart/get_ru_names()
	return alist(
		NOMINATIVE = "диагностические очки-сердечки",
		GENITIVE = "диагностических очков-сердечек",
		DATIVE = "диагностическим очкам-сердечкам",
		ACCUSATIVE = "диагностические очки-сердечки",
		INSTRUMENTAL = "диагностическими очками-сердечками",
		PREPOSITIONAL = "диагностических очках-сердечках",
	)

/obj/item/clothing/glasses/hud/diagnostic/night
	name = "Night Vision Diagnostic HUD"
	desc = "Проекционный дисплей, носимый в качестве очков. Оснащён диагностическим модулем, анализирующим целостность и состояние роботизированных систем. \
			В данную модель встроена светочувствительная матрица, повышающая видимость в условиях ограниченного освещения."
	icon_state = "diagnostichudnight"
	item_state = "nvghud"
	origin_tech = "magnets=4;powerstorage=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/diagnostic/night/get_ru_names()
	return alist(
		NOMINATIVE = "диагностические ИЛС-очки ночного видения",
		GENITIVE = "диагностических ИЛС-очков ночного видения",
		DATIVE = "диагностическим ИЛС-очкам ночного видения",
		ACCUSATIVE = "диагностические ИЛС-очки ночного видения",
		INSTRUMENTAL = "диагностическими ИЛС-очками ночного видения",
		PREPOSITIONAL = "диагностических ИЛС-очках ночного видения",
	)

/obj/item/clothing/glasses/hud/diagnostic/sunglasses
	name = "diagnostic sunglasses"
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			Оснащены диагностическим ИЛС-дисплеем, анализирующим целостность и состояние роботизированных систем."
	icon_state = "sunhuddiag"
	item_state = "sunhuddiag"
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/hud/diagnostic/sunglasses/get_ru_names()
	return alist(
		NOMINATIVE = "диагностические солнцезащитные очки",
		GENITIVE = "диагностических солнцезащитных очков",
		DATIVE = "диагностическим солнцезащитным очкам",
		ACCUSATIVE = "диагностические солнцезащитные очки",
		INSTRUMENTAL = "диагностическими солнцезащитными очками",
		PREPOSITIONAL = "диагностических солнцезащитных очках",
	)

/obj/item/clothing/glasses/hud/diagnostic/tajblind
	name = "diagnostic veil"
	desc = "Адомайская вуаль, скрывающая глаза владельца от посторонних, но не затрудняя обзор носителю. Эта модель оснащена диагностическим ИЛС."
	gender = FEMALE
	icon_state = "tajblind_diagnostic"
	item_state = "tajblind_diagnostic"
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/diagnostic/tajblind/get_ru_names()
	return alist(
		NOMINATIVE = "диагностическая вуаль",
		GENITIVE = "диагностической вуали",
		DATIVE = "диагностической вуали",
		ACCUSATIVE = "диагностическую вуаль",
		INSTRUMENTAL = "диагностической вуалью",
		PREPOSITIONAL = "диагностической вуали",
	)

/obj/item/clothing/glasses/hud/diagnostic/tajblind/sunglasses
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/hud/diagnostic/tajblind/attack_self(mob/user)
	toggle_veil(user)

/obj/item/clothing/glasses/hud/diagnostic/visor
	name = "Optical Diagnostic Visor"
	desc = "Технологичный визор для глаз. Оснащён диагностическим ИЛС-дисплеем, анализирующим целостность и состояние роботизированных систем."
	gender = MALE
	icon_state = "diagvisor"
	item_state = "diagvisor"

/obj/item/clothing/glasses/hud/diagnostic/visor/get_ru_names()
	return alist(
		NOMINATIVE = "диагностический оптический визор",
		GENITIVE = "диагностического оптического визора",
		DATIVE = "диагностическому оптическому визору",
		ACCUSATIVE = "диагностический оптический визор",
		INSTRUMENTAL = "диагностическим оптическим визором",
		PREPOSITIONAL = "диагностическом оптическом визоре",
	)

/obj/item/clothing/glasses/hud/diagnostic/monocle
	name = "Diagnostic HUD Monocle"
	desc = "Оптический прибор, носимый путём зажатия мышцами лица. \
			Оснащён диагностическим ИЛС-дисплеем, анализирующим целостность и состояние роботизированных систем."
	gender = MALE
	icon_state = "monohuddiag"
	item_state = "monohud"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/diagnostic/monocle/get_ru_names()
	return alist(
		NOMINATIVE = "диагностический ИЛС-монокль",
		GENITIVE = "диагностического ИЛС-монокля",
		DATIVE = "диагностическому ИЛС-моноклю",
		ACCUSATIVE = "диагностический ИЛС-монокль",
		INSTRUMENTAL = "диагностическим ИЛС-моноклем",
		PREPOSITIONAL = "диагностическом ИЛС-монокле",
	)

// MARK: Security
/obj/item/clothing/glasses/hud/security
	name = "Security HUD"
	desc = "Проекционный дисплей, носимый в качестве очков. Оснащён охранным модулем, сканирующим гуманоидов в поле зрения и визуализирующим данные об их охранном статусе."
	icon_state = "securityhud"
	origin_tech = "magnets=3;combat=2"
	var/global/list/jobs[0]
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = EXAMINE_HUD_SECURITY_READ | EXAMINE_HUD_SECURITY_WRITE

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/security/get_ru_names()
	return alist(
		NOMINATIVE = "охранные ИЛС-очки",
		GENITIVE = "охранных ИЛС-очков",
		DATIVE = "охранным ИЛС-очкам",
		ACCUSATIVE = "охранные ИЛС-очки",
		INSTRUMENTAL = "охранными ИЛС-очками",
		PREPOSITIONAL = "охранных ИЛС-очках",
	)

/obj/item/clothing/glasses/hud/security/read_only
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/glasses/hud/security/patch
	name = "Security HUD Eyepatch"
	desc = "Проекционная повязка на глаз. Оснащена охранным ИЛС-дисплеем, сканирующим гуманоидов в поле зрения и визуализирующим данные об их охранном статусе."
	gender = FEMALE
	icon_state = "sechudpatch"
	item_state = "sechudpatch"
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/security/patch/get_ru_names()
	return alist(
		NOMINATIVE = "охранная ИЛС-повязка на глаз",
		GENITIVE = "охранной ИЛС-повязки на глаз",
		DATIVE = "охранной ИЛС-повязке на глаз",
		ACCUSATIVE = "охранную ИЛС-повязку на глаз",
		INSTRUMENTAL = "охранной ИЛС-повязкой на глаз",
		PREPOSITIONAL = "охранной ИЛС-повязке на глаз",
	)

/obj/item/clothing/glasses/hud/security/patch/read_only
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/glasses/hud/security/night
	name = "Night Vision Security HUD"
	desc = "Проекционный дисплей, носимый в качестве очков. Оснащён охранным модулем, сканирующим гуманоидов в поле зрения и визуализирующим данные об их охранном статусе. \
			В данную модель встроена светочувствительная матрица, повышающая видимость в условиях ограниченного освещения."
	icon_state = "securityhudnight"
	origin_tech = "magnets=4;combat=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/security/night/get_ru_names()
	return alist(
		NOMINATIVE = "охранные ИЛС-очки ночного видения",
		GENITIVE = "охранных ИЛС-очков ночного видения",
		DATIVE = "охранным ИЛС-очкам ночного видения",
		ACCUSATIVE = "охранные ИЛС-очки ночного видения",
		INSTRUMENTAL = "охранными ИЛС-очками ночного видения",
		PREPOSITIONAL = "охранных ИЛС-очках ночного видения",
	)

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "security sunglasses"
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			Оснащены охранным ИЛС-дисплеем, сканирующим гуманоидов в поле зрения и визуализирующим данные об их охранном статусе."
	icon_state = "sunhud"
	origin_tech = "magnets=3;combat=3;engineering=3"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/security/sunglasses/get_ru_names()
	return alist(
		NOMINATIVE = "охранные солнцезащитные очки",
		GENITIVE = "охранных солнцезащитных очков",
		DATIVE = "охранным солнцезащитным очкам",
		ACCUSATIVE = "охранные солнцезащитные очки",
		INSTRUMENTAL = "охранными солнцезащитными очками",
		PREPOSITIONAL = "охранных солнцезащитных очках",
	)

/obj/item/clothing/glasses/hud/security/sunglasses/heart
	name = "Heart Security Glasses"
	desc = "Модные очки в виде сердечек. Оснащены охранным ИЛС-дисплеем, сканирующим гуманоидов в поле зрения и визуализирующим данные об их охранном статусе."
	icon_state = "heart_sec"
	item_state = "heart_sec"

/obj/item/clothing/glasses/hud/security/sunglasses/heart/get_ru_names()
	return alist(
		NOMINATIVE = "охранные очки-сердечки",
		GENITIVE = "охранных очков-сердечек",
		DATIVE = "охранным очкам-сердечкам",
		ACCUSATIVE = "охранные очки-сердечки",
		INSTRUMENTAL = "охранными очками-сердечками",
		PREPOSITIONAL = "охранных очках-сердечках",
	)

/obj/item/clothing/glasses/hud/security/sunglasses/heart/read_only
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/glasses/hud/security/sunglasses/tacticool
	name = "security tactical glasses"
	desc = "Баллистические очки со встроенным охранным ИЛС. Обеспечивают тактикульную защиту и стильно выглядят. \
			Эластичная лента позволяет носить их поверх шлема."
	icon_state = "secgoggles-g"
	item_state = "secgoggles-g"
	over_hat = TRUE
	can_toggle = TRUE
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT | VISOR_DARKNESSVIEW | VISOR_FULL_HUD
	visor_flags_cover = GLASSESCOVERSEYES
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/security/sunglasses/tacticool/get_ru_names()
	return alist(
		NOMINATIVE = "охранные тактические очки",
		GENITIVE = "охранных тактических очков",
		DATIVE = "охранным тактическим очкам",
		ACCUSATIVE = "охранные тактические очки",
		INSTRUMENTAL = "охранными тактическими очками",
		PREPOSITIONAL = "охранных тактических очках",
	)

/obj/item/clothing/glasses/hud/security/sunglasses/tacticool/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/right_click_mapper/attack_self, "Переключить [declent_ru(ACCUSATIVE)]")

/obj/item/clothing/glasses/hud/security/sunglasses/tacticool/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/glasses/hud/security/sunglasses/read_only
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/glasses/hud/security/sunglasses/aviators
	name = "security aviators"
	desc = "Очки-авиаторы с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			Оснащены охранным ИЛС-дисплеем, сканирующим гуманоидов в поле зрения и визуализирующим данные об их охранном статусе."
	icon_state = "aviators"

/obj/item/clothing/glasses/hud/security/sunglasses/aviators/get_ru_names()
	return alist(
		NOMINATIVE = "охранные очки-авиаторы",
		GENITIVE = "охранных очков-авиаторов",
		DATIVE = "охранным очкам-авиаторам",
		ACCUSATIVE = "охранные очки-авиаторы",
		INSTRUMENTAL = "охранными очками-авиаторами",
		PREPOSITIONAL = "охранных очках-авиаторах",
	)

/obj/item/clothing/glasses/hud/security/sunglasses/tajblind
	name = "security veil"
	desc = "Адомайская вуаль, скрывающая глаза владельца от посторонних, но не затрудняя обзор носителю. Эта модель оснащена охранным ИЛС."
	gender = FEMALE
	icon_state = "tajblind_sec"
	item_state = "tajblind_sec"
	tint_up = 1
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/security/sunglasses/tajblind/get_ru_names()
	return alist(
		NOMINATIVE = "охранная вуаль",
		GENITIVE = "охранной вуали",
		DATIVE = "охранной вуали",
		ACCUSATIVE = "охранную вуаль",
		INSTRUMENTAL = "охранной вуалью",
		PREPOSITIONAL = "охранной вуали",
	)

/obj/item/clothing/glasses/hud/security/sunglasses/tajblind/attack_self(mob/user)
	toggle_veil(user)

/obj/item/clothing/glasses/hud/security/sunglasses/tajblind/read_only
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/glasses/hud/security/sunglasses/visor
	name = "Security visor"
	desc = "Технологичный визор для глаз. Оснащён охранным ИЛС-дисплеем, сканирующим гуманоидов в поле зрения и визуализирующим данные об их охранном статусе. \
			Также защищает глаза носителя от яркого света."
	gender = MALE
	icon_state = "securityvisor"
	item_state = "securityvisor"

/obj/item/clothing/glasses/hud/security/sunglasses/visor/get_ru_names()
	return alist(
		NOMINATIVE = "охранный оптический визор",
		GENITIVE = "охранного оптического визора",
		DATIVE = "охранному оптическому визору",
		ACCUSATIVE = "охранный оптический визор",
		INSTRUMENTAL = "охранным оптическим визором",
		PREPOSITIONAL = "охранном оптическом визоре",
	)

/obj/item/clothing/glasses/hud/security/monocle
	name = "Security HUD Monocle"
	desc = "Оптический прибор, носимый путём зажатия мышцами лица. \
			Оснащён охранным ИЛС-дисплеем, сканирующим гуманоидов в поле зрения и визуализирующим данные об их охранном статусе."
	gender = MALE
	icon_state = "monohudsec"
	item_state = "monohud"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/security/monocle/get_ru_names()
	return alist(
		NOMINATIVE = "охранный ИЛС-монокль",
		GENITIVE = "охранного ИЛС-монокля",
		DATIVE = "охранному ИЛС-моноклю",
		ACCUSATIVE = "охранный ИЛС-монокль",
		INSTRUMENTAL = "охранным ИЛС-моноклем",
		PREPOSITIONAL = "охранном ИЛС-монокле",
	)

// MARK: Hydroponic
/obj/item/clothing/glasses/hud/hydroponic
	name = "Hydroponic HUD"
	desc = "Проекционный дисплей, носимый в качестве очков. Оснащён ботаническим модулем, анализирующим состояние растений, растущих в гидропонных лотках и почве."
	icon_state = "hydroponichud"
	HUDType = DATA_HUD_HYDROPONIC
	examine_extensions = EXAMINE_HUD_BOTANY
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/hydroponic/get_ru_names()
	return alist(
		NOMINATIVE = "ботанические ИЛС-очки",
		GENITIVE = "ботанических ИЛС-очков",
		DATIVE = "ботаническим ИЛС-очкам",
		ACCUSATIVE = "ботанические ИЛС-очки",
		INSTRUMENTAL = "ботаническими ИЛС-очками",
		PREPOSITIONAL = "ботанических ИЛС-очках",
	)

/obj/item/clothing/glasses/hud/hydroponic/patch
	name = "Hydroponic HUD Eyepatch"
	desc = "Проекционная повязка на глаз. Оснащена ботаническим ИЛС-дисплеем, анализирующим состояние растений, растущих в гидропонных лотках и почве."
	gender = FEMALE
	icon_state = "hydrohudpatch"
	item_state = "hydrohudpatch"
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/hydroponic/patch/get_ru_names()
	return alist(
		NOMINATIVE = "ботаническая ИЛС-повязка на глаз",
		GENITIVE = "ботанической ИЛС-повязки на глаз",
		DATIVE = "ботанической ИЛС-повязке на глаз",
		ACCUSATIVE = "ботаническую ИЛС-повязку на глаз",
		INSTRUMENTAL = "ботанической ИЛС-повязкой на глаз",
		PREPOSITIONAL = "ботанической ИЛС-повязке на глаз",
	)

/obj/item/clothing/glasses/hud/heart
	name = "Heart Hydroponic Glasses"
	desc = "Модные очки в виде сердечек. Оснащены ботаническим ИЛС-дисплеем, анализирующим состояние растений, растущих в гидропонных лотках и почве."
	icon_state = "heart_hydro"
	item_state = "heart_hydro"

/obj/item/clothing/glasses/hud/heart/get_ru_names()
	return alist(
		NOMINATIVE = "ботанические очки-сердечки",
		GENITIVE = "ботанических очков-сердечек",
		DATIVE = "ботаническим очкам-сердечкам",
		ACCUSATIVE = "ботанические очки-сердечки",
		INSTRUMENTAL = "ботаническими очками-сердечками",
		PREPOSITIONAL = "ботанических очках-сердечках",
	)

/obj/item/clothing/glasses/hud/hydroponic/night
	name = "Night Vision Hydroponic HUD"
	desc = "Проекционный дисплей, носимый в качестве очков. Оснащён ботаническим модулем, анализирующим состояние растений, растущих в гидропонных лотках и почве. \
			В данную модель встроена светочувствительная матрица, повышающая видимость в условиях ограниченного освещения."
	icon_state = "hydroponichudnight"
	item_state = "nvghud"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/hydroponic/night/get_ru_names()
	return alist(
		NOMINATIVE = "ботанические ИЛС-очки ночного видения",
		GENITIVE = "ботанических ИЛС-очков ночного видения",
		DATIVE = "ботаническим ИЛС-очкам ночного видения",
		ACCUSATIVE = "ботанические ИЛС-очки ночного видения",
		INSTRUMENTAL = "ботаническими ИЛС-очками ночного видения",
		PREPOSITIONAL = "ботанических ИЛС-очках ночного видения",
	)

/obj/item/clothing/glasses/hud/hydroponic/sunglasses
	name = "hydroponic sunglasses"
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			Оснащены ботаническим ИЛС-дисплеем, анализирующим состояние растений, растущих в гидропонных лотках и почве."
	icon_state = "sunhudhydro"
	item_state = "sunhudhydro"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/hud/hydroponic/sunglasses/get_ru_names()
	return alist(
		NOMINATIVE = "ботанические солнцезащитные очки",
		GENITIVE = "ботанических солнцезащитных очков",
		DATIVE = "ботаническим солнцезащитным очкам",
		ACCUSATIVE = "ботанические солнцезащитные очки",
		INSTRUMENTAL = "ботаническими солнцезащитными очками",
		PREPOSITIONAL = "ботанических солнцезащитных очках",
	)

/obj/item/clothing/glasses/hud/hydroponic/tajblind
	name = "blooming veil"
	desc = "Адомайская вуаль, скрывающая глаза владельца от посторонних, но не затрудняя обзор носителю. Эта модель оснащена ботаническим ИЛС."
	gender = FEMALE
	icon_state = "tajblind_bot"
	item_state = "tajblind_bot"
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/hydroponic/tajblind/get_ru_names()
	return alist(
		NOMINATIVE = "цветущая вуаль",
		GENITIVE = "цветущей вуали",
		DATIVE = "цветущей вуали",
		ACCUSATIVE = "цветущую вуаль",
		INSTRUMENTAL = "цветущей вуалью",
		PREPOSITIONAL = "цветущей вуали",
	)

/obj/item/clothing/glasses/hud/hydroponic/tajblind/sunglasses
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/hud/hydroponic/tajblind/attack_self(mob/user)
	toggle_veil(user)

/obj/item/clothing/glasses/hud/hydroponic/visor
	name = "Hydroponic Optical Visor"
	desc = "Технологичный визор для глаз. Оснащён ботаническим ИЛС-дисплеем, анализирующим состояние растений, растущих в гидропонных лотках и почве."
	gender = MALE
	icon_state = "hydroponicvisor"
	item_state = "hydroponicvisor"

/obj/item/clothing/glasses/hud/hydroponic/visor/get_ru_names()
	return alist(
		NOMINATIVE = "ботанический оптический визор",
		GENITIVE = "ботанического оптического визора",
		DATIVE = "ботаническому оптическому визору",
		ACCUSATIVE = "ботанический оптический визор",
		INSTRUMENTAL = "ботаническим оптическим визором",
		PREPOSITIONAL = "ботаническом оптическом визоре",
	)

/obj/item/clothing/glasses/hud/hydroponic/monocle
	name = "Hydroponic HUD Monocle"
	desc = "Оптический прибор, носимый путём зажатия мышцами лица. \
			Оснащён ботаническим ИЛС-дисплеем, анализирующим состояние растений, растущих в гидропонных лотках и почве."
	gender = MALE
	icon_state = "monohudhydro"
	item_state = "monohud"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/hydroponic/monocle/get_ru_names()
	return alist(
		NOMINATIVE = "ботанический ИЛС-монокль",
		GENITIVE = "ботанического ИЛС-монокля",
		DATIVE = "ботаническому ИЛС-моноклю",
		ACCUSATIVE = "ботанический ИЛС-монокль",
		INSTRUMENTAL = "ботаническим ИЛС-моноклем",
		PREPOSITIONAL = "ботаническом ИЛС-монокле",
	)

// MARK: Skills
/obj/item/clothing/glasses/hud/skills
	name = "Skills HUD"
	desc = "Проекционный дисплей, носимый в качестве очков. Оснащён кадровым модулем, отображающим записи о трудовой деятельности сотрудников \"Нанотрейзен\"."
	icon_state = "skill"
	item_state = "skill"
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = EXAMINE_HUD_SKILLS
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY  = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/skills/get_ru_names()
	return alist(
		NOMINATIVE = "очки с кадровым ИЛС",
		GENITIVE = "очков с кадровым ИЛС",
		DATIVE = "очкам с кадровым ИЛС",
		ACCUSATIVE = "очки с кадровым ИЛС",
		INSTRUMENTAL = "очками с кадровым ИЛС",
		PREPOSITIONAL = "очках с кадровым ИЛС",
	)

/obj/item/clothing/glasses/hud/skills/patch
	name = "Skills HUD Eyepatch"
	desc = "Проекционная повязка на глаз. Оснащена кадровым ИЛС-дисплеем, отображающим записи о трудовой деятельности сотрудников \"Нанотрейзен\"."
	gender = FEMALE
	icon_state = "skillhudpatch"
	item_state = "skillhudpatch"
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/skills/patch/get_ru_names()
	return alist(
		NOMINATIVE = "повязка на глаз с кадровым ИЛС",
		GENITIVE = "повязки на глаз с кадровым ИЛС",
		DATIVE = "повязке на глаз с кадровым ИЛС",
		ACCUSATIVE = "повязку на глаз с кадровым ИЛС",
		INSTRUMENTAL = "повязкой на глаз с кадровым ИЛС",
		PREPOSITIONAL = "повязке на глаз с кадровым ИЛС",
	)

/obj/item/clothing/glasses/hud/skills/heart
	name = "Heart Skills Glasses"
	desc = "Модные очки в виде сердечек. Оснащены кадровым ИЛС-дисплеем, отображающим записи о трудовой деятельности сотрудников \"Нанотрейзен\"."
	icon_state = "heart_skill"
	item_state = "heart_skill"

/obj/item/clothing/glasses/hud/skills/heart/get_ru_names()
	return alist(
		NOMINATIVE = "очки-сердечки с кадровым ИЛС",
		GENITIVE = "очков-сердечек с кадровым ИЛС",
		DATIVE = "очкам-сердечкам с кадровым ИЛС",
		ACCUSATIVE = "очки-сердечки с кадровым ИЛС",
		INSTRUMENTAL = "очками-сердечками с кадровым ИЛС",
		PREPOSITIONAL = "очках-сердечках с кадровым ИЛС",
	)

/obj/item/clothing/glasses/hud/skills/sunglasses
	name = "skills sunglasses"
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			Оснащены кадровым ИЛС-дисплеем, отображающим записи о трудовой деятельности сотрудников \"Нанотрейзен\"."
	icon_state = "sunhudskill"
	see_in_dark = 1 // None of these three can be converted to booleans. Do not try it.
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY  = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/skills/sunglasses/get_ru_names()
	return alist(
		NOMINATIVE = "солнцезащитные очки с кадровым ИЛС",
		GENITIVE = "солнцезащитных очков с кадровым ИЛС",
		DATIVE = "солнцезащитным очкам с кадровым ИЛС",
		ACCUSATIVE = "солнцезащитные очки с кадровым ИЛС",
		INSTRUMENTAL = "солнцезащитными очками с кадровым ИЛС",
		PREPOSITIONAL = "солнцезащитных очках с кадровым ИЛС",
	)

/obj/item/clothing/glasses/hud/skills/tajblind
	name = "skills veil"
	desc = "Адомайская вуаль, скрывающая глаза владельца от посторонних, но не затрудняя обзор носителю. Эта модель оснащена кадровым ИЛС."
	gender = FEMALE
	icon_state = "tajblind_skill"
	item_state = "tajblind_skill"
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/skills/tajblind/get_ru_names()
	return alist(
		NOMINATIVE = "вуаль с кадровым ИЛС",
		GENITIVE = "вуали с кадровым ИЛС",
		DATIVE = "вуали с кадровым ИЛС",
		ACCUSATIVE = "вуаль с кадровым ИЛС",
		INSTRUMENTAL = "вуалью с кадровым ИЛС",
		PREPOSITIONAL = "вуали с кадровым ИЛС",
	)

/obj/item/clothing/glasses/hud/skills/tajblind/sunglasses
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/hud/skills/tajblind/attack_self(mob/user)
	toggle_veil(user)

/obj/item/clothing/glasses/hud/skills/visor
	name = "Skill Optical Visor"
	desc = "Технологичный визор для глаз. Оснащён кадровым ИЛС-дисплеем, отображающим записи о трудовой деятельности сотрудников \"Нанотрейзен\"."
	gender = MALE
	icon_state = "skillvisor"
	item_state = "skillvisor"
	flash_protect = FLASH_PROTECTION_FLASH

/obj/item/clothing/glasses/hud/skills/visor/get_ru_names()
	return alist(
		NOMINATIVE = "оптический визор с кадровым ИЛС",
		GENITIVE = "оптического визора с кадровым ИЛС",
		DATIVE = "оптическому визору с кадровым ИЛС",
		ACCUSATIVE = "оптический визор с кадровым ИЛС",
		INSTRUMENTAL = "оптическим визором с кадровым ИЛС",
		PREPOSITIONAL = "оптическом визоре с кадровым ИЛС",
	)

/obj/item/clothing/glasses/hud/skills/monocle
	name = "Skills HUD Monocle"
	desc = "Оптический прибор, носимый путём зажатия мышцами лица. \
			Оснащён кадровым ИЛС-дисплеем, отображающим записи о трудовой деятельности сотрудников \"Нанотрейзен\"."
	gender = MALE
	icon_state = "monohudskill"
	item_state = "monohud"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/skills/monocle/get_ru_names()
	return alist(
		NOMINATIVE = "монокль с кадровым ИЛС",
		GENITIVE = "монокля с кадровым ИЛС",
		DATIVE = "моноклю с кадровым ИЛС",
		ACCUSATIVE = "монокль с кадровым ИЛС",
		INSTRUMENTAL = "моноклем с кадровым ИЛС",
		PREPOSITIONAL = "монокле с кадровым ИЛС",
	)

// MARK: Multi-mode
/obj/item/clothing/glasses/hud/multimode
	name = "multi-mode HUD glasses"
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			Оснащены многорежимным ИЛС-дисплеем, позволяющим переключаться между медицинским и охранным режимами."
	actions_types = list(/datum/action/item_action/switch_hud)
	icon_state = "sunhudmed"
	origin_tech = "magnets=4;combat=4;engineering=4;biotech=4"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY  = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/multimode/get_ru_names()
	return alist(
		NOMINATIVE = "многорежимные ИЛС-очки",
		GENITIVE = "многорежимных ИЛС-очков",
		DATIVE = "многорежимным ИЛС-очкам",
		ACCUSATIVE = "многорежимные ИЛС-очки",
		INSTRUMENTAL = "многорежимными ИЛС-очками",
		PREPOSITIONAL = "многорежимных ИЛС-очках",
	)

/obj/item/clothing/glasses/hud/multimode/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/right_click_mapper/attack_self, "Переключить [declent_ru(ACCUSATIVE)]")

/obj/item/clothing/glasses/hud/multimode/attack_self(mob/user)
	multiHUD_toggling(user)

/obj/item/clothing/glasses/hud/multimode/captain
	name = "Gold multi-mod HUD glasses"
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			Оснащены многорежимным ИЛС-дисплеем, позволяющим переключаться между медицинским и охранным режимами. Выполнены в золотом цвете."
	icon_state = "sunhudcap"
	item_state = "sunhudcap"
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY  = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/hud/multimode/captain/get_ru_names()
	return alist(
		NOMINATIVE = "золотые многорежимные ИЛС-очки",
		GENITIVE = "золотых многорежимных ИЛС-очков",
		DATIVE = "золотым многорежимным ИЛС-очкам",
		ACCUSATIVE = "золотые многорежимные ИЛС-очки",
		INSTRUMENTAL = "золотыми многорежимными ИЛС-очками",
		PREPOSITIONAL = "золотых многорежимных ИЛС-очках",
	)

/obj/item/clothing/glasses/hud/multimode/centcom
	name = "Centcom multi-mod HUD aviators"
	icon_state = "aviators"

/obj/item/clothing/glasses/hud/multimode/centcom/get_ru_names()
	return alist(
		NOMINATIVE = "многорежимные ИЛС-очки ЦентКома НТ",
		GENITIVE = "многорежимных ИЛС-очков ЦентКома НТ",
		DATIVE = "многорежимным ИЛС-очкам ЦентКома НТ",
		ACCUSATIVE = "многорежимные ИЛС-очки ЦентКома НТ",
		INSTRUMENTAL = "многорежимными ИЛС-очками ЦентКома НТ",
		PREPOSITIONAL = "многорежимных ИЛС-очках ЦентКома НТ",
	)
