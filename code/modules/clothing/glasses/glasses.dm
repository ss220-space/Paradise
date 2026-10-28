// MARK: Basic Glasses
/obj/item/clothing/glasses
	abstract_type = /obj/item/clothing/glasses
	name = "glasses"
	gender = PLURAL
	icon = 'icons/obj/clothing/glasses.dmi'
	flags_cover = GLASSESCOVERSEYES
	slot_flags = ITEM_SLOT_EYES
	materials = list(MAT_GLASS = 250)
	resistance_flags = NONE
	equip_sound = 'sound/items/handling/equip/generic_equip4.ogg'
	strip_delay = 20 // but seperated to allow items to protect but not impair vision, like space helmets
	put_on_delay = 25
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)
	/// Bitflags for vision enhancements (e.g., SEE_TURFS, SEE_MOBS).
	var/vision_flags = 0
	/// How well the wearer can see in darkness (base human is 2).
	var/see_in_dark = 2
	/// Level of invisibility the wearer can see (default SEE_INVISIBLE_LIVING).
	var/invis_view = SEE_INVISIBLE_LIVING
	/// Alpha value for lighting plane when worn (affects darkness rendering).
	var/lighting_alpha
	/// List of examine extensions (e.g., medical HUD, science HUD).
	var/examine_extensions = EXAMINE_HUD_NONE
	/// List of color matrix to override client.color while worn (e.g., grayscale).
	var/list/color_view = null
	/// Whether the glasses have prescription lenses.
	var/prescription = FALSE
	/// Whether the glasses can be upgraded with prescription lenses.
	var/prescription_upgradable = FALSE
	/// Whether the glasses are worn over a hat (affects layering).
	var/over_hat = FALSE
	/// Whether the eyewear is rendered above the mask (purely cosmetic).
	var/over_mask = FALSE

/obj/item/clothing/glasses/Initialize(mapload)
	. = ..()
	register_context()
	if(prescription_upgradable && prescription)
		// Pre-upgraded upgradable glasses
		upgrade_prescription()

/obj/item/clothing/glasses/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(isnull(held_item) || held_item == src)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Носить [over_mask ? "под маской" : "поверх маски"]"
		. = CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/clothing/glasses/regular) && prescription_upgradable && !prescription)
		context[SCREENTIP_CONTEXT_LMB] = "Установить диоптрические линзы"
		. = CONTEXTUAL_SCREENTIP_SET
	else if(held_item && held_item.tool_behaviour == TOOL_SCREWDRIVER && prescription)
		context[SCREENTIP_CONTEXT_LMB] = "Извлечь диоптрические линзы"
		. = CONTEXTUAL_SCREENTIP_SET

/obj/item/clothing/glasses/examine_tags(mob/user)
	. = ..()
	if(prescription)
		.["диоптрическ[genderize_examine_descriptor("ий", "ая", "ое", "ие")]"] = "Внутри установлены диоптрические линзы, помогающие при проблемах со зрением."
	else if(prescription_upgradable)
		.["совместим[genderize_examine_descriptor("ый", "ая", "ое", "ые")] с диоптрическими линзами"] = "Можно установить диоптрические линзы."

/obj/item/clothing/glasses/examine_descriptor(mob/user)
	return "очки"

/obj/item/clothing/glasses/examine_descriptor_gender()
	return "plural"

/obj/item/clothing/glasses/click_alt(mob/living/carbon/human/user)
	if(!istype(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	over_mask = !over_mask
	if(user.glasses == src)
		user.update_worn_glasses()
	balloon_alert(user, "ношение [over_mask ? "поверх маски" : "под маской"]")

/obj/item/clothing/glasses/attackby(obj/item/I, mob/living/carbon/human/user, params)
	if(!ishuman(user) || user.incapacitated())
		return ..()

	if(istype(I, /obj/item/clothing/glasses/regular))
		add_fingerprint(user)
		if(!prescription_upgradable)
			balloon_alert(user, "несовместимо!")
			return ATTACK_CHAIN_PROCEED
		if(prescription)
			balloon_alert(user, "линзы уже установлены!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))	// Store the glasses for later removal
			return ..()
		upgrade_prescription(I, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/clothing/glasses/update_icon_state()
	if(..())
		item_state = "[replacetext("[item_state]", "_up", "")][up ? "_up" : ""]"

/obj/item/clothing/glasses/update_name(updates = ALL)
	. = ..()
	if(prescription)
		name = "prescription [initial(name)]"
		set_ru_names_suffix(" (диоптрическ[GEND_II_AYA_II_IE(src)])")
	else
		name = initial(name)
		ru_names = get_ru_names_cached()

/obj/item/clothing/glasses/proc/upgrade_prescription(obj/item/I, mob/living/carbon/human/user)
	if(!I)
		new /obj/item/clothing/glasses/regular(src)
	else if(I.loc != src)
		I.forceMove(src)
	prescription = TRUE
	update_appearance(UPDATE_NAME)
	if(user)
		balloon_alert(user, "линзы установлены")
		if(user.glasses == src)
			user.update_nearsighted_effects()

/obj/item/clothing/glasses/proc/remove_prescription(mob/living/carbon/human/user)
	var/obj/item/clothing/glasses/regular/prescription_glasses = locate() in src

	if(!prescription_glasses)
		return

	prescription = FALSE
	update_appearance(UPDATE_NAME)

	prescription_glasses.forceMove(drop_location())

	if(user)
		balloon_alert(user, "линзы извлечены")
		user.put_in_hands(prescription_glasses, ignore_anim = FALSE)
		if(user.glasses == src)
			user.update_nearsighted_effects()

/obj/item/clothing/glasses/screwdriver_act(mob/living/user, obj/item/I)
	if(!prescription)
		return FALSE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return TRUE
	remove_prescription(user)
	return TRUE

/obj/item/clothing/glasses/visor_toggling(mob/user)
	. = ..()
	if(!.)
		return .
	if(visor_vars_to_toggle & VISOR_VISIONFLAGS)
		vision_flags ^= initial(vision_flags)
	if(visor_vars_to_toggle & VISOR_DARKNESSVIEW)
		see_in_dark ^= initial(see_in_dark)
	if(visor_vars_to_toggle & VISOR_INVISVIEW)
		invis_view ^= initial(invis_view)

// MARK: Prescription Glasses
/obj/item/clothing/glasses/regular
	name = "prescription glasses"
	desc = "Очки с диоптрическими линзами, предназначенные для ношения при нарушениях зрения."
	icon_state = "glasses"
	item_state = "glasses"
	prescription = TRUE

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

/obj/item/clothing/glasses/regular/get_ru_names()
	return alist(
		NOMINATIVE = "диоптрические очки",
		GENITIVE = "диоптрических очков",
		DATIVE = "диоптрическим очкам",
		ACCUSATIVE = "диоптрические очки",
		INSTRUMENTAL = "диоптрическими очками",
		PREPOSITIONAL = "диоптрических очках",
	)

/obj/item/clothing/glasses/regular/hipster
	desc = "Очки с диоптрическими линзами, предназначенные для ношения при нарушениях зрения. Обладают уникальным дизайном."
	icon_state = "hipster_glasses"
	item_state = "hipster_glasses"

// MARK: Sunglasses
/obj/item/clothing/glasses/sunglasses
	name = "sunglasses"
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света."
	icon_state = "sun"
	item_state = "sunglasses"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1
	prescription_upgradable = TRUE
	dog_fashion = /datum/dog_fashion/head
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

/obj/item/clothing/glasses/sunglasses/get_ru_names()
	return alist(
		NOMINATIVE = "солнцезащитные очки",
		GENITIVE = "солнцезащитных очков",
		DATIVE = "солнцезащитным очкам",
		ACCUSATIVE = "солнцезащитные очки",
		INSTRUMENTAL = "солнцезащитными очками",
		PREPOSITIONAL = "солнцезащитных очках",
	)

/obj/item/clothing/glasses/sunglasses_fake
	name = "cheap sunglasses"
	desc = "Предназначенные для защиты от УФ-излучения, на деле эти очки абсолютно неэффективны. Зато выглядят стильно."
	icon_state = "sun"
	item_state = "sunglasses"
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

/obj/item/clothing/glasses/sunglasses_fake/get_ru_names()
	return alist(
		NOMINATIVE = "дешёвые солнцезащитные очки",
		GENITIVE = "дешёвых солнцезащитных очков",
		DATIVE = "дешёвым солнцезащитным очкам",
		ACCUSATIVE = "дешёвые солнцезащитные очки",
		INSTRUMENTAL = "дешёвыми солнцезащитными очками",
		PREPOSITIONAL = "дешёвых солнцезащитных очках",
	)

/obj/item/clothing/glasses/sunglasses_fake/holo
	name = "holographic sunglasses"
	desc = "Защищают от голографических УФ-лучей голографического солнца."

/obj/item/clothing/glasses/sunglasses_fake/holo/get_ru_names()
	return alist(
		NOMINATIVE = "голографические солнцезащитные очки",
		GENITIVE = "голографических солнцезащитных очков",
		DATIVE = "голографическим солнцезащитным очкам",
		ACCUSATIVE = "голографические солнцезащитные очки",
		INSTRUMENTAL = "голографическими солнцезащитными очками",
		PREPOSITIONAL = "голографических солнцезащитных очках",
	)

/obj/item/clothing/glasses/sunglasses/prescription
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/big
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. Большие линзы для большего стиля."
	icon_state = "bigsunglasses"
	item_state = "bigsunglasses"

/obj/item/clothing/glasses/sunglasses/noir
	name = "noir sunglasses"
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			От них веет чрезвычайной старомодностью."
	actions_types = list(/datum/action/item_action/noir)

/obj/item/clothing/glasses/sunglasses/noir/get_ru_names()
	return alist(
		NOMINATIVE = "нуарные солнцезащитные очки",
		GENITIVE = "нуарных солнцезащитных очков",
		DATIVE = "нуарным солнцезащитным очкам",
		ACCUSATIVE = "нуарные солнцезащитные очки",
		INSTRUMENTAL = "нуарными солнцезащитными очками",
		PREPOSITIONAL = "нуарных солнцезащитных очках",
	)

/obj/item/clothing/glasses/sunglasses/noir/attack_self(mob/user)
	toggle_noir(user)

/obj/item/clothing/glasses/sunglasses/noir/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_EYES)
		return TRUE

/obj/item/clothing/glasses/sunglasses/noir/proc/toggle_noir(mob/user)
	color_view = color_view ? null : MATRIX_GREYSCALE //Toggles between null and grayscale, with null being the default option.
	user.update_client_colour()

/obj/item/clothing/glasses/sunglasses/yeah
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			На оправе расположена небольшая кнопка."
	COOLDOWN_DECLARE(use_cooldown)
	actions_types = list(/datum/action/item_action/YEEEAAAAAHHHHHHHHHHHHH)

/obj/item/clothing/glasses/sunglasses/yeah/attack_self(mob/user)
	pun(user)

/obj/item/clothing/glasses/sunglasses/yeah/proc/pun(mob/user)
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, "Момент упущен.")
		return

	playsound(loc, 'sound/misc/yeah.ogg', 100, FALSE)
	user.visible_message(span_biggerdanger("YEEEAAAAAHHHHHHHHHHHHH!!"))

	COOLDOWN_START(src, use_cooldown, 5 MINUTES)

/obj/item/clothing/glasses/sunglasses/reagent
	name = "sunscanners"
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			Оснащены научным сканером."
	examine_extensions = EXAMINE_HUD_SCIENCE

/obj/item/clothing/glasses/sunglasses/reagent/get_ru_names()
	return alist(
		NOMINATIVE = "научные солнцезащитные очки",
		GENITIVE = "научных солнцезащитных очков",
		DATIVE = "научным солнцезащитным очкам",
		ACCUSATIVE = "научные солнцезащитные очки",
		INSTRUMENTAL = "научными солнцезащитными очками",
		PREPOSITIONAL = "научных солнцезащитных очках",
	)

/obj/item/clothing/glasses/sunglasses/lasers
	name = "high-tech sunglasses"
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			По бокам расположено большое количество миниатюрных датчиков и панелей."

/obj/item/clothing/glasses/sunglasses/lasers/get_ru_names()
	return alist(
		NOMINATIVE = "высокотехнологичные солнцезащитные очки",
		GENITIVE = "высокотехнологичных солнцезащитных очков",
		DATIVE = "высокотехнологичным солнцезащитным очкам",
		ACCUSATIVE = "высокотехнологичные солнцезащитные очки",
		INSTRUMENTAL = "высокотехнологичными солнцезащитными очками",
		PREPOSITIONAL = "высокотехнологичных солнцезащитных очках",
	)

/obj/item/clothing/glasses/sunglasses/lasers/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/glasses/sunglasses/lasers/equipped(mob/user, slot, initial = FALSE) //grant them laser eyes upon equipping it.
	. = ..()
	if(slot == ITEM_SLOT_EYES)
		ADD_TRAIT(user, TRAIT_LASEREYES, UNIQUE_TRAIT_SOURCE(src))
		user.update_mutations()

/obj/item/clothing/glasses/sunglasses/lasers/dropped(mob/living/user, slot, silent = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_EYES)
		REMOVE_TRAIT(user, TRAIT_LASEREYES, UNIQUE_TRAIT_SOURCE(src))
		user.update_mutations()

/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Закрывает глаза, лишая зрения."
	gender = FEMALE
	icon_state = "blindfold_white"
	item_state = "blindfold_white"
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 3 // to make them blind
	prescription_upgradable = FALSE
	var/colour = null

/obj/item/clothing/glasses/sunglasses/blindfold/get_ru_names()
	return alist(
		NOMINATIVE = "повязка на глаза",
		GENITIVE = "повязки на глаза",
		DATIVE = "повязке на глаза",
		ACCUSATIVE = "повязку на глаза",
		INSTRUMENTAL = "повязкой на глаза",
		PREPOSITIONAL = "повязке на глаза",
	)

/obj/item/clothing/glasses/sunglasses/blindfold/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)
	add_atom_colour(colour, FIXED_COLOUR_PRIORITY)

/obj/item/clothing/glasses/sunglasses/blindfold/black
	colour = "#2a2a2a"

/obj/item/clothing/glasses/sunglasses/blindfold_fake
	name = "thin blindfold"
	desc = "Закрывает глаза, но недостаточно плотная, чтобы мешать обзору. Предназначение в первую очередь эстетическое."
	gender = FEMALE
	icon_state = "blindfold_white"
	item_state = "blindfold_white"
	flash_protect = FLASH_PROTECTION_NONE
	tint = 0
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/sunglasses/blindfold_fake/get_ru_names()
	return alist(
		NOMINATIVE = "тонкая повязка на глаза",
		GENITIVE = "тонкой повязки на глаза",
		DATIVE = "тонкой повязке на глаза",
		ACCUSATIVE = "тонкую повязку на глаза",
		INSTRUMENTAL = "тонкой повязкой на глаза",
		PREPOSITIONAL = "тонкой повязке на глаза",
	)

/obj/item/clothing/glasses/sunglasses/blindfold_fake/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)

/obj/item/clothing/glasses/sunglasses/blindfold/cucumbermask
	name = "cucumber mask"
	desc = "Пара обычных ломтиков огурца. Медицински доказано: они благотворно влияют на глаза."
	heal_bodypart = INTERNAL_ORGAN_EYES
	icon_state = "cucumbermask"
	item_state = "cucumbermask"

/obj/item/clothing/glasses/sunglasses/blindfold/cucumbermask/get_ru_names()
	return alist(
		NOMINATIVE = "огуречная маска",
		GENITIVE = "огуречной маски",
		DATIVE = "огуречной маске",
		ACCUSATIVE = "огуречную маску",
		INSTRUMENTAL = "огуречной маской",
		PREPOSITIONAL = "огуречной маске",
	)

// MARK: Meson Glasses
/obj/item/clothing/glasses/meson
	name = "optical meson scanner"
	desc = "Специальные очки, используемые для визуального обнаружения брешей и полостей в окружающем пространстве."
	gender = MALE
	icon_state = "meson"
	item_state = "meson"
	origin_tech = "magnets=1;engineering=2"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = TRUE
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)
	var/active_on_equip = TRUE

/obj/item/clothing/glasses/meson/get_ru_names()
	return alist(
		NOMINATIVE = "оптический мезонный сканер",
		GENITIVE = "оптического мезонного сканера",
		DATIVE = "оптическому мезонному сканеру",
		ACCUSATIVE = "оптический мезонный сканер",
		INSTRUMENTAL = "оптическим мезонным сканером",
		PREPOSITIONAL = "оптическом мезонном сканере"
	)

/obj/item/clothing/glasses/meson/equipped(mob/user, slot, initial)
	. = ..()
	if(active_on_equip && slot == ITEM_SLOT_EYES)
		ADD_TRAIT(user, TRAIT_MESON_VISION, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/glasses/meson/dropped(mob/user)
	. = ..()
	if(user)
		REMOVE_TRAIT(user, TRAIT_MESON_VISION, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/glasses/meson/sunglasses
	name = "meson sunglasses"
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			Оснащены системой мезонного зрения, предназначенной для визуального обнаружения брешей и полостей в окружающем пространстве."
	gender = PLURAL
	icon_state = "sunmeson"
	item_state = "sunmeson"
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/meson/sunglasses/get_ru_names()
	return alist(
		NOMINATIVE = "мезонные солнцезащитные очки",
		GENITIVE = "мезонных солнцезащитных очков",
		DATIVE = "мезонным солнцезащитным очкам",
		ACCUSATIVE = "мезонные солнцезащитные очки",
		INSTRUMENTAL = "мезонными солнцезащитными очками",
		PREPOSITIONAL = "мезонных солнцезащитных очках",
	)

/obj/item/clothing/glasses/meson/heart
	name = "heart meson glasses"
	desc = "Специальные очки, используемые для визуального обнаружения брешей и полостей в окружающем пространстве. \
			Выполнены в форме сердечек."
	gender = PLURAL
	icon_state = "heart_meson"
	item_state = "heart_meson"

/obj/item/clothing/glasses/meson/heart/get_ru_names()
	return alist(
		NOMINATIVE = "мезонные очки-сердечки",
		GENITIVE = "мезонных очков-сердечек",
		DATIVE = "мезонным очкам-сердечкам",
		ACCUSATIVE = "мезонные очки-сердечки",
		INSTRUMENTAL = "мезонными очками-сердечками",
		PREPOSITIONAL = "мезонных очках-сердечках",
	)

/obj/item/clothing/glasses/meson/night
	name = "night vision optical meson scanner"
	desc = "Специальные очки, используемые для визуального обнаружения брешей и полостей в окружающем пространстве. \
			Данная модель оснащена светочувствительной матрицей, повышающей видимость в условиях ограниченного освещения."
	gender = PLURAL
	icon_state = "nvgmeson"
	item_state = "nvgmeson"
	origin_tech = "magnets=4;engineering=5;plasmatech=4"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/meson/night/get_ru_names()
	return alist(
		NOMINATIVE = "мезонные очки ночного видения",
		GENITIVE = "мезонных очков ночного видения",
		DATIVE = "мезонным очкам ночного видения",
		ACCUSATIVE = "мезонные очки ночного видения",
		INSTRUMENTAL = "мезонными очками ночного видения",
		PREPOSITIONAL = "мезонных очках ночного видения"
	)

/obj/item/clothing/glasses/meson/prescription
	prescription = TRUE

/obj/item/clothing/glasses/meson/gar
	name = "gar mesons"
	desc = "Специальные очки, используемые для визуального обнаружения брешей и полостей в окружающем пространстве. \
			Обладают уникальным дизайном."
	gender = PLURAL
	icon_state = "garm"
	item_state = "garm"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb = list("полоснул")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = TRUE

/obj/item/clothing/glasses/meson/gar/get_ru_names()
	return alist(
		NOMINATIVE = "гар-мезонные очки",
		GENITIVE = "гар-мезонных очков",
		DATIVE = "гар-мезонным очкам",
		ACCUSATIVE = "гар-мезонные очки",
		INSTRUMENTAL = "гар-мезонными очками",
		PREPOSITIONAL = "гар-мезонных очках"
	)

/obj/item/clothing/glasses/meson/cyber
	name = "eye replacement implant"
	desc = "Имплантированная замена левого глаза с функцией мезонного зрения. Позволяет видеть бреши и полости в окружающем пространстве."
	gender = MALE
	icon_state = "cybereye-green"
	item_state = "eyepatch"
	flags_cover = NONE
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/meson/cyber/get_ru_names()
	return alist(
		NOMINATIVE = "имплант замены глаза",
		GENITIVE = "импланта замены глаза",
		DATIVE = "импланту замены глаза",
		ACCUSATIVE = "имплант замены глаза",
		INSTRUMENTAL = "имплантом замены глаза",
		PREPOSITIONAL = "импланте замены глаза",
	)

/obj/item/clothing/glasses/meson/cyber/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/glasses/meson/visor
	name = "meson optical visor"
	desc = "Технологичный визор для глаз. Оснащён системой мезонного зрения, предназначенной для визуального обнаружения брешей и полостей в окружающем пространстве."
	gender = MALE
	icon_state = "mesonvisor"
	item_state = "mesonvisor"

/obj/item/clothing/glasses/meson/visor/get_ru_names()
	return alist(
		NOMINATIVE = "мезонный оптический визор",
		GENITIVE = "мезонного оптического визора",
		DATIVE = "мезонному оптическому визору",
		ACCUSATIVE = "мезонный оптический визор",
		INSTRUMENTAL = "мезонным оптическим визором",
		PREPOSITIONAL = "мезонном оптическом визоре",
	)

/obj/item/clothing/glasses/meson/monocle
	name = "meson monocle scanner"
	desc = "Оптический прибор, носимый путём зажатия мышцами лица. \
			Оснащён системой мезонного зрения, предназначенной для визуального обнаружения брешей и полостей в окружающем пространстве."
	gender = MALE
	icon_state = "monomeson"
	item_state = "monohud"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/meson/monocle/get_ru_names()
	return alist(
		NOMINATIVE = "мезонный моноколь",
		GENITIVE = "мезонного монокля",
		DATIVE = "мезонному моноклю",
		ACCUSATIVE = "мезонный моноколь",
		INSTRUMENTAL = "мезонным моноклем",
		PREPOSITIONAL = "мезонном монокле",
	)

/obj/item/clothing/glasses/meson/atmos
	name = "atmospherics scanner goggles"
	desc = "Специальные очки, используемые для визуального обнаружения брешей и полостей в окружающем пространстве, а также \
			визуализации атмосферного давления."
	gender = PLURAL
	icon_state = "trayson-pressure"
	item_state =  null
	origin_tech = "materials=3;magnets=2;engineering=2"
	clothing_traits = list(TRAIT_PRESSURE_VISION)

/obj/item/clothing/glasses/meson/atmos/get_ru_names()
	return alist(
		NOMINATIVE = "атмосферные сканирующие очки",
		GENITIVE = "атмосферных сканирующих очков",
		DATIVE = "атмосферным сканирующим очкам",
		ACCUSATIVE = "атмосферные сканирующие очки",
		INSTRUMENTAL = "атмосферными сканирующими очками",
		PREPOSITIONAL = "атмосферных сканирующих очках",
	)

// MARK: Science Glasses
/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "Специальные очки, защищающие глаза от химикатов. Оснащены научным сканером."
	icon_state = "purple"
	item_state = "purple"
	origin_tech = "magnets=2;engineering=1"
	examine_extensions = EXAMINE_HUD_SCIENCE
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 80, ACID = 100)
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
	actions_types = list(/datum/action/item_action/toggle_research_scanner)

/obj/item/clothing/glasses/science/get_ru_names()
	return alist(
		NOMINATIVE = "научные очки",
		GENITIVE = "научных очков",
		DATIVE = "научным очкам",
		ACCUSATIVE = "научные очки",
		INSTRUMENTAL = "научными очками",
		PREPOSITIONAL = "научных очках",
	)

/obj/item/clothing/glasses/science/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_EYES)
		return TRUE

/obj/item/clothing/glasses/science/night
	name = "night vision science goggle"
	desc = "Специальные очки, защищающие глаза от химикатов. Оснащены научным сканером, \
			а также светочувствительной матрицей, повышающей видимость в условиях ограниченного освещения."
	icon_state = "nvpurple"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these

/obj/item/clothing/glasses/science/night/get_ru_names()
	return alist(
		NOMINATIVE = "научные очки ночного видения",
		GENITIVE = "научных очков ночного видения",
		DATIVE = "научным очкам ночного видения",
		ACCUSATIVE = "научные очки ночного видения",
		INSTRUMENTAL = "научными очками ночного видения",
		PREPOSITIONAL = "научных очках ночного видения",
	)

/obj/item/clothing/glasses/science/heart
	name = "heart science glasses"
	desc = "Специальные очки, защищающие глаза от химикатов. Оснащены научным сканером. Выполнены в форме сердечек."
	icon_state = "heart_science"
	item_state = "heart_science"

/obj/item/clothing/glasses/science/heart/get_ru_names()
	return alist(
		NOMINATIVE = "научные очки-сердечки",
		GENITIVE = "научных очков-сердечек",
		DATIVE = "научным очкам-сердечкам",
		ACCUSATIVE = "научные очки-сердечки",
		INSTRUMENTAL = "научными очками-сердечками",
		PREPOSITIONAL = "научных очках-сердечках",
	)

/obj/item/clothing/glasses/science/visor
	name = "science optical visor"
	desc = "Технологичный визор для глаз. Оснащён научным сканером, а также защищает глаза от воздействия химикатов."
	gender = MALE
	icon_state = "sciencevisor"
	item_state = "sciencevisor"

/obj/item/clothing/glasses/science/visor/get_ru_names()
	return alist(
		NOMINATIVE = "научный оптический визор",
		GENITIVE = "научного оптического визора",
		DATIVE = "научному оптическому визору",
		ACCUSATIVE = "научный оптический визор",
		INSTRUMENTAL = "научным оптическим визором",
		PREPOSITIONAL = "научном оптическом визоре",
	)

/obj/item/clothing/glasses/science/monocle
	name = "science hud monocle"
	desc = "Оптический прибор, носимый путём зажатия мышцами лица. \
			Оснащён научным сканером."
	gender = MALE
	icon_state = "monohudsci"
	item_state = "monohud"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/science/monocle/get_ru_names()
	return alist(
		NOMINATIVE = "научный ИЛС-моноколь",
		GENITIVE = "научного ИЛС-монокля",
		DATIVE = "научному ИЛС-моноклю",
		ACCUSATIVE = "научный ИЛС-моноколь",
		INSTRUMENTAL = "научным ИЛС-моноклем",
		PREPOSITIONAL = "научном ИЛС-монокле",
	)

// MARK: Material Scanner
/obj/item/clothing/glasses/material
	name = "optical material scanner"
	desc = "Специализированные очки, визуализирующие ряд определённых материалов сквозь препятствия."
	gender = MALE
	icon_state = "material"
	item_state = "glasses"
	origin_tech = "magnets=3;engineering=3"
	vision_flags = SEE_OBJS

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

/obj/item/clothing/glasses/material/get_ru_names()
	return alist(
		NOMINATIVE = "оптический сканер материалов",
		GENITIVE = "оптического сканера материалов",
		DATIVE = "оптическому сканеру материалов",
		ACCUSATIVE = "оптический сканер материалов",
		INSTRUMENTAL = "оптическим сканером материалов",
		PREPOSITIONAL = "оптическом сканере материалов",
	)

/obj/item/clothing/glasses/material/cyber
	name = "eye replacement implant"
	desc = "Имплантированная замена левого глаза с функцией распознавания материалов."
	icon_state = "cybereye-blue"
	item_state = "eyepatch"
	flags_cover = NONE

/obj/item/clothing/glasses/material/cyber/get_ru_names()
	return alist(
		NOMINATIVE = "имплант замены глаза",
		GENITIVE = "импланта замены глаза",
		DATIVE = "импланту замены глаза",
		ACCUSATIVE = "имплант замены глаза",
		INSTRUMENTAL = "имплантом замены глаза",
		PREPOSITIONAL = "импланте замены глаза",
	)

/obj/item/clothing/glasses/material/cyber/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/glasses/material/lighting
	name = "neutron goggles"
	desc = "Специализированный оптический прибор, полностью нивелирующий влияние света и тьмы с помощью нейтронной визуализации."
	gender = PLURAL
	origin_tech = null
	vision_flags = NONE
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE

/obj/item/clothing/glasses/material/lighting/get_ru_names()
	return alist(
		NOMINATIVE = "нейтронные очки",
		GENITIVE = "нейтронных очков",
		DATIVE = "нейтронным очкам",
		ACCUSATIVE = "нейтронные очки",
		INSTRUMENTAL = "нейтронными очками",
		PREPOSITIONAL = "нейтронных очках",
	)

/obj/item/clothing/glasses/material/lighting/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

// MARK: Welding Glasses
/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Специализированные очки с УФ-экранированием высокого уровня. Предназначены для защиты глаз носителя при выполнении сварочных работ."
	icon_state = "welding-g"
	item_state = "welding-g"
	actions_types = list(/datum/action/item_action/toggle)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	can_toggle = TRUE
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
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

/obj/item/clothing/glasses/welding/get_ru_names()
	return alist(
		NOMINATIVE = "сварочные очки",
		GENITIVE = "сварочных очков",
		DATIVE = "сварочным очкам",
		ACCUSATIVE = "сварочные очки",
		INSTRUMENTAL = "сварочными очками",
		PREPOSITIONAL = "сварочных очках",
	)

/obj/item/clothing/glasses/welding/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/right_click_mapper/attack_self, "Переключить [declent_ru(ACCUSATIVE)]")

/obj/item/clothing/glasses/welding/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/glasses/welding/superior
	name = "superior welding goggles"
	desc = "Специализированные очки с УФ-экранированием высокого уровня. Предназначены для защиты глаз носителя при выполнении сварочных работ. \
			Линзы выполнены из дорогостоящих материалов, благодаря чему они не ухудшают обзор, в отличие от более дешёвых аналогов."
	icon_state = "rwelding-g"
	item_state = "rwelding-g"
	tint = 0

/obj/item/clothing/glasses/welding/superior/get_ru_names()
	return alist(
		NOMINATIVE = "улучшенные сварочные очки",
		GENITIVE = "улучшенных сварочных очков",
		DATIVE = "улучшенным сварочным очкам",
		ACCUSATIVE = "улучшенные сварочные очки",
		INSTRUMENTAL = "улучшенными сварочными очками",
		PREPOSITIONAL = "улучшенных сварочных очках",
	)

// MARK: Thermal Glasses
/obj/item/clothing/glasses/thermal
	name = "optical thermal scanner"
	desc = "Высокотехнологичный оптический прибор, предназначенный для обнаружения тепловых сигнатур живых существ сквозь препятствия."
	gender = MALE
	icon_state = "thermal"
	item_state = "thermal"
	origin_tech = "magnets=3"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = FLASH_PROTECTION_SENSITIVE
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

/obj/item/clothing/glasses/thermal/get_ru_names()
	return alist(
		NOMINATIVE = "оптический термальный сканер",
		GENITIVE = "оптического термального сканера",
		DATIVE = "оптическому термальному сканеру",
		ACCUSATIVE = "оптический термальный сканер",
		INSTRUMENTAL = "оптическим термальным сканером",
		PREPOSITIONAL = "оптическом термальном сканере",
	)

/obj/item/clothing/glasses/thermal/emp_act(severity)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		var/obj/item/organ/internal/eyes/eyes = H.get_organ_slot(INTERNAL_ORGAN_EYES)
		if(eyes && H.glasses == src)
			to_chat(H, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] перегружа[PLUR_ET_YUT(src)]ся и ослепля[PLUR_ET_YUT(src)] вас!"))
			H.flash_eyes(3, visual = TRUE)
			H.EyeBlind(6 SECONDS)
			H.EyeBlurry(10 SECONDS)
			eyes.internal_receive_damage(5)
	..()

/obj/item/clothing/glasses/thermal_fake
	name = "phirmel soonglesas"
	desc = "Дишёвые пластмассовые очки. Нащи их, если ты крутой."
	icon_state = "sunthermal"
	item_state = "sunthermal"

/obj/item/clothing/glasses/thermal_fake/get_ru_names()
	return alist(
		NOMINATIVE = "тармальные сонцезащитные очхи",
		GENITIVE = "тармальных сонцезащитных очхов",
		DATIVE = "тармальным сонцезащитным очхам",
		ACCUSATIVE = "тармальные сонцезащитные очхи",
		INSTRUMENTAL = "тармальными сонцезащитными очхами",
		PREPOSITIONAL = "тармальных сонцезащитных очхах",
	)

/obj/item/clothing/glasses/thermal/sunglasses
	name = "thermal sunglasses"
	desc = "Очки с экранированием от ультрафиолетовых лучей, защищающие глаза носителя от ярких вспышек света. \
			Оснащены тепловизионной системой, позволяющей обнаруживать тепловые сигнатуры живых существ сквозь препятствия."
	gender = PLURAL
	icon_state = "sunthermal"
	item_state = "sunthermal"
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/thermal/sunglasses/get_ru_names()
	return alist(
		NOMINATIVE = "термальные солнцезащитные очки",
		GENITIVE = "термальных солнцезащитных очков",
		DATIVE = "термальным солнцезащитным очкам",
		ACCUSATIVE = "термальные солнцезащитные очки",
		INSTRUMENTAL = "термальными солнцезащитными очками",
		PREPOSITIONAL = "термальных солнцезащитных очках",
	)

/obj/item/clothing/glasses/thermal/monocle
	name = "thermal monocle scanner"
	desc = "Оптический прибор, носимый путём зажатия мышцами лица. \
			Оснащён тепловизионной системой, позволяющей обнаруживать тепловые сигнатуры живых существ сквозь препятствия."
	icon_state = "monothermal"
	item_state = "monohud"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/thermal/monocle/get_ru_names()
	return alist(
		NOMINATIVE = "термальный моноколь",
		GENITIVE = "термального монокля",
		DATIVE = "термальному моноклю",
		ACCUSATIVE = "термальный моноколь",
		INSTRUMENTAL = "термальным моноклем",
		PREPOSITIONAL = "термальном монокле",
	)

/obj/item/clothing/glasses/thermal/eyepatch
	name = "optical thermal eyepatch"
	desc = "Повязка на глаз со встроенной тепловизионной системой, позволяющей обнаруживать тепловые сигнатуры живых существ сквозь препятствия."
	gender = FEMALE
	icon_state = "eyepatch"
	item_state = "eyepatch"

/obj/item/clothing/glasses/thermal/eyepatch/get_ru_names()
	return alist(
		NOMINATIVE = "оптическая термальная повязка на глаз",
		GENITIVE = "оптической термальной повязки на глаз",
		DATIVE = "оптической термальной повязке на глаз",
		ACCUSATIVE = "оптическую термальную повязку на глаз",
		INSTRUMENTAL = "оптической термальной повязкой на глаз",
		PREPOSITIONAL = "оптической термальной повязке на глаз",
	)

/obj/item/clothing/glasses/thermal/cyber
	name = "eye replacement implant"
	desc = "Имплантированная замена левого глаза с функцией термального зрения. Позволяет обнаруживать тепловые сигнатуры живых существ сквозь препятствия."
	gender = MALE
	icon_state = "cybereye-red"
	item_state = "eyepatch"

/obj/item/clothing/glasses/thermal/cyber/get_ru_names()
	return alist(
		NOMINATIVE = "имплант замены глаза",
		GENITIVE = "импланта замены глаза",
		DATIVE = "импланту замены глаза",
		ACCUSATIVE = "имплант замены глаза",
		INSTRUMENTAL = "имплантом замены глаза",
		PREPOSITIONAL = "импланте замены глаза",
	)

/obj/item/clothing/glasses/thermal/cyber/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

// MARK: Godeye
/obj/item/clothing/glasses/hud/godeye
	name = "eye of god"
	desc = "Странный глаз, который, как говорят, вырвали у всевидящего существа, некогда бродившего по пустошам."
	gender = MALE
	icon_state = "godeye"
	item_state = "godeye"
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	examine_extensions = EXAMINE_HUD_SCIENCE
	flags_cover = null
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	var/double_eye = FALSE
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

/obj/item/clothing/glasses/hud/godeye/get_ru_names()
	return alist(
		NOMINATIVE = "глаз бога",
		GENITIVE = "глаза бога",
		DATIVE = "глазу бога",
		ACCUSATIVE = "глаз бога",
		INSTRUMENTAL = "глазом бога",
		PREPOSITIONAL = "глазе бога",
	)

/obj/item/clothing/glasses/hud/godeye/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/glasses/hud/godeye/update_icon_state()
	icon_state = "[double_eye ? "double" : ""]godeye"
	item_state = "[double_eye ? "double" : ""]godeye"

/obj/item/clothing/glasses/hud/godeye/update_desc(updates = ALL)
	. = ..()
	if(!double_eye)
		desc = initial(desc)
		return
	desc = "Пара странных глаз, которые, как говорят, вырвали у всевидящего существа, некогда бродившего по пустошам."

/obj/item/clothing/glasses/hud/godeye/attackby(obj/item/I, mob/user, params)
	if(istype(I, type) && I != src && I.loc == user)
		add_fingerprint(user)
		if(double_eye)
			to_chat(user, span_notice("Глаз подмигивает вам и исчезает в бездне. Кажется, удача от вас отвернулась."))
		else
			double_eye = TRUE
			update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
			user.wear_glasses_update(src)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

// MARK: Tajaran Veil
/obj/item/clothing/glasses/tajblind
	name = "embroidered veil"
	desc = "Адомайская вуаль, скрывающая глаза владельца от посторонних, но не затрудняя обзор носителю."
	gender = FEMALE
	icon_state = "tajblind"
	item_state = "tajblind"
	actions_types = list(/datum/action/item_action/toggle)
	tint = 3

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

/obj/item/clothing/glasses/tajblind/get_ru_names()
	return alist(
		NOMINATIVE = "вышитая вуаль",
		GENITIVE = "вышитой вуали",
		DATIVE = "вышитой вуали",
		ACCUSATIVE = "вышитую вуаль",
		INSTRUMENTAL = "вышитой вуалью",
		PREPOSITIONAL = "вышитой вуали",
	)

/obj/item/clothing/glasses/tajblind/eng
	name = "industrial veil"
	desc = "Адомайская вуаль, скрывающая глаза владельца от посторонних, но не затрудняя обзор носителю. Эта модель оснащена мезонным сканером и УФ-экранированием."
	icon_state = "tajblind_engi"
	item_state = "tajblind_engi"
	vision_flags = SEE_TURFS
	flash_protect = FLASH_PROTECTION_WELDER
	var/flash_protect_up = FLASH_PROTECTION_NONE

/obj/item/clothing/glasses/tajblind/eng/get_ru_names()
	return alist(
		NOMINATIVE = "инженерная вуаль",
		GENITIVE = "инженерной вуали",
		DATIVE = "инженерной вуали",
		ACCUSATIVE = "инженерную вуаль",
		INSTRUMENTAL = "инженерной вуалью",
		PREPOSITIONAL = "инженерной вуали",
	)

/obj/item/clothing/glasses/tajblind/eng/sunglasses
	flash_protect_up = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/tajblind/eng/toggle_veil(mob/user)
	. = ..()
	if(.)
		flash_protect = up ? flash_protect_up : initial(flash_protect)

/obj/item/clothing/glasses/tajblind/sci
	name = "science veil"
	desc = "Адомайская вуаль, скрывающая глаза владельца от посторонних, но не затрудняя обзор носителю. Эта модель оснащена научным сканером."
	icon_state = "tajblind_sci"
	item_state = "tajblind_sci"
	examine_extensions = EXAMINE_HUD_SCIENCE
	actions_types = list(/datum/action/item_action/toggle_research_scanner,/datum/action/item_action/toggle)

/obj/item/clothing/glasses/tajblind/sci/get_ru_names()
	return alist(
		NOMINATIVE = "научная вуаль",
		GENITIVE = "научной вуали",
		DATIVE = "научной вуали",
		ACCUSATIVE = "научную вуаль",
		INSTRUMENTAL = "научной вуалью",
		PREPOSITIONAL = "научной вуали",
	)

/obj/item/clothing/glasses/tajblind/cargo
	name = "meson veil"
	desc = "Адомайская вуаль, скрывающая глаза владельца от посторонних, но не затрудняя обзор носителю. Эта модель оснащена мезонным сканером."
	icon_state = "tajblind_cargo"
	item_state = "tajblind_cargo"
	vision_flags = SEE_TURFS
	prescription_upgradable = TRUE

/obj/item/clothing/glasses/tajblind/cargo/get_ru_names()
	return alist(
		NOMINATIVE = "мезонная вуаль",
		GENITIVE = "мезонной вуали",
		DATIVE = "мезонной вуали",
		ACCUSATIVE = "мезонную вуаль",
		INSTRUMENTAL = "мезонной вуалью",
		PREPOSITIONAL = "мезонной вуали",
	)

/obj/item/clothing/glasses/tajblind/cargo/sunglasses
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/tajblind/attack_self(mob/user)
	toggle_veil(user)

/obj/item/clothing/glasses/proc/toggle_veil(mob/living/carbon/human/user)
	if(user.incapacitated())
		return FALSE
	. = TRUE
	up = !up
	tint = up ? tint_up : initial(tint)
	if(user.glasses == src)
		balloon_alert(user, "[up ? "" : "де"]активировано")
		user.wear_glasses_update(src)


// MARK: Misc Glasses
/obj/item/clothing/glasses/heart
	name = "heart-shaped glasses"
	desc = "Дешёвые пластиковые очки причудливой формы."
	icon_state = "heart"
	item_state = "heart"
	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
	)

/obj/item/clothing/glasses/heart/get_ru_names()
	return alist(
		NOMINATIVE = "очки-сердечки",
		GENITIVE = "очков-сердечек",
		DATIVE = "очкам-сердечкам",
		ACCUSATIVE = "очки-сердечки",
		INSTRUMENTAL = "очками-сердечками",
		PREPOSITIONAL = "очках-сердечках",
	)

/obj/item/clothing/glasses/heart/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)

/obj/item/clothing/glasses/janitor
	name = "janitorial goggles"
	desc = "Защитят Ваши глаза от мыла."
	icon_state = "purple"
	item_state = "purple"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)

/obj/item/clothing/glasses/janitor/get_ru_names()
	return alist(
		NOMINATIVE = "очки уборщика",
		GENITIVE = "очков уборщика",
		DATIVE = "очкам уборщика",
		ACCUSATIVE = "очки уборщика",
		INSTRUMENTAL = "очками уборщика",
		PREPOSITIONAL = "очках уборщика",
	)

/obj/item/clothing/glasses/goldblue
	name = "round gold-rimmed glasses"
	desc = "Круглые очки в золотистой оправе с тёмно-синими линзами."
	icon_state = "goldblue"
	item_state = "goldblue"

/obj/item/clothing/glasses/goldblue/get_ru_names()
	return alist(
		NOMINATIVE = "очки в золотистой оправе",
		GENITIVE = "очков в золотистой оправе",
		DATIVE = "очкам в золотистой оправе",
		ACCUSATIVE = "очки в золотистой оправе",
		INSTRUMENTAL = "очками в золотистой оправе",
		PREPOSITIONAL = "очках в золотистой оправе",
	)

/obj/item/clothing/glasses/night
	name = "night vision goggles"
	desc = "Оптический прибор, улучшающий видимость в условиях ограниченного освещения."
	icon_state = "night"
	item_state = "glasses"
	origin_tech = "materials=4;magnets=4;plasmatech=4;engineering=4"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these

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

/obj/item/clothing/glasses/night/get_ru_names()
	return alist(
		NOMINATIVE = "очки ночного видения",
		GENITIVE = "очков ночного видения",
		DATIVE = "очкам ночного видения",
		ACCUSATIVE = "очки ночного видения",
		INSTRUMENTAL = "очками ночного видения",
		PREPOSITIONAL = "очках ночного видения",
	)

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Стильная повязка, закрывающая глаз."
	gender = FEMALE
	icon_state = "eyepatch"
	item_state = "eyepatch"

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

/obj/item/clothing/glasses/eyepatch/get_ru_names()
	return alist(
		NOMINATIVE = "повязка на глаз",
		GENITIVE = "повязки на глаз",
		DATIVE = "повязке на глаз",
		ACCUSATIVE = "повязку на глаз",
		INSTRUMENTAL = "повязкой на глаз",
		PREPOSITIONAL = "повязке на глаз",
	)

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Оптический прибор, носимый путём зажатия мышцами лица."
	icon_state = "monocle"
	item_state = "monohud"
	gender = MALE
	prescription_upgradable = TRUE

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

/obj/item/clothing/glasses/monocle/get_ru_names()
	return alist(
		NOMINATIVE = "моноколь",
		GENITIVE = "монокля",
		DATIVE = "моноклю",
		ACCUSATIVE = "моноколь",
		INSTRUMENTAL = "моноклем",
		PREPOSITIONAL = "монокле",
	)

/obj/item/clothing/glasses/threedglasses
	name = "3D glasses"
	desc = "Когда-то давно люди использовали такие очки, чтобы делать изображение на экранах трёхмерным."
	icon_state = "3d"
	item_state = "3d"

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

/obj/item/clothing/glasses/threedglasses/get_ru_names()
	return alist(
		NOMINATIVE = "3D-очки",
		GENITIVE = "3D-очков",
		DATIVE = "3D-очкам",
		ACCUSATIVE = "3D-очки",
		INSTRUMENTAL = "3D-очками",
		PREPOSITIONAL = "3D-очках",
	)

/obj/item/clothing/glasses/gglasses
	name = "green glasses"
	desc = "Очки цвета тёмной зелени — выглядят зловеще."
	icon_state = "gglasses"
	item_state = "gglasses"

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
	prescription_upgradable = TRUE

/obj/item/clothing/glasses/gglasses/get_ru_names()
	return alist(
		NOMINATIVE = "зелёные очки",
		GENITIVE = "зелёных очков",
		DATIVE = "зелёным очкам",
		ACCUSATIVE = "зелёные очки",
		INSTRUMENTAL = "зелёными очками",
		PREPOSITIONAL = "зелёных очках",
	)
