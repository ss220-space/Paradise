/obj/item/clothing/under/solgov
	icon = 'icons/obj/clothing/uniforms/solgov.dmi'
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 30, ACID = 30)
	displays_id = 0
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/uniform.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/vulpkanin/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
	)

/obj/item/clothing/under/solgov/marine
	name = "Sol Federation marine uniform"
	desc = "Комфортная и удобная униформа военно-морских сил Транс-Солнечной Федерации."
	icon_state = "solgov"
	item_state = "solgov"
	item_color = "solgov"

/obj/item/clothing/under/solgov/marine/forest
	desc = "Комфортный и удобный лесной камуфляж Транс-Солнечной Федерации."
	icon_state = "solgov_forest"
	item_state = "solgov_forest"
	item_color = "solgov_forest"

/obj/item/clothing/under/solgov/marine/urban
	desc = "Комфортный и удобный городской камуфляж Транс-Солнечной Федерации."
	icon_state = "solgov_urban"
	item_state = "solgov_urban"
	item_color = "solgov_urban"

/obj/item/clothing/under/solgov/marine/get_ru_names()
	return alist(
		NOMINATIVE = "униформа ВМС ТСФ",
		GENITIVE = "униформы ВМС ТСФ",
		DATIVE = "униформе ВМС ТСФ",
		ACCUSATIVE = "униформу ВМС ТСФ",
		INSTRUMENTAL = "униформой ВМС ТСФ",
		PREPOSITIONAL = "униформе ВМС ТСФ",
	)

/obj/item/clothing/under/solgov/marine/civ
	desc = "Комфортная, воссоздающая военную униформу, одежда. Не похоже, чтобы она защищала."
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, fire = 0, acid = 0)

/obj/item/clothing/under/solgov/marine/forest/civ
	desc = "Комфортная, воссоздающая лесной камуфляж, одежда. Не похоже, чтобы она защищала."
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, fire = 0, acid = 0)

/obj/item/clothing/under/solgov/marine/urban/civ
	desc = "Комфортная, воссоздающая городской камуфляж, одежда. Не похоже, чтобы она защищала."
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, fire = 0, acid = 0)

/obj/item/clothing/under/solgov/elite
	name = "Trans-Solar Federation Specops marine uniform"
	desc = "Комфортная и удобная униформа спецназа военно-морских сил Транс-Солнечной Федерации."
	icon_state = "solgovelite"
	item_color = "solgovelite"

/obj/item/clothing/under/solgov/elite/get_ru_names()
	return alist(
		NOMINATIVE = "униформа спецназа ВМС ТСФ",
		GENITIVE = "униформы спецназа ВМС ТСФ",
		DATIVE = "униформе спецназа ВМС ТСФ",
		ACCUSATIVE = "униформу спецназа ВМС ТСФ",
		INSTRUMENTAL = "униформой спецназа ВМС ТСФ",
		PREPOSITIONAL = "униформе спецназа ВМС ТСФ",
	)

/obj/item/clothing/under/solgov/command
	name = "Sol Federation Lieutenant's uniform"
	desc = "Комфортная и удобная униформа военно-морских сил Транс-Солнечной Федерации. Имеет дополнительные погоны на плечах."
	icon_state = "solgovc"
	item_color = "solgovc"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 30, ACID = 30)

/obj/item/clothing/under/solgov/command/get_ru_names()
	return alist(
		NOMINATIVE = "униформа лейтенанта ВМС ТСФ",
		GENITIVE = "униформы лейтенанта ВМС ТСФ",
		DATIVE = "униформе лейтенанта ВМС ТСФ",
		ACCUSATIVE = "униформу лейтенанта ВМС ТСФ",
		INSTRUMENTAL = "униформой лейтенанта ВМС ТСФ",
		PREPOSITIONAL = "униформе лейтенанта ВМС ТСФ",
	)

/obj/item/clothing/under/solgov/command/elite
	name = "Trans-Solar Federation Specops Lieutenant's uniform"
	desc = "Комфортная и удобная униформа спецназа военно-морских сил Транс-Солнечной Федерации. Имеет дополнительные погоны на плечах и манжеты на рукавах."
	icon_state = "solgovcelite"
	item_color = "solgovcelite"

/obj/item/clothing/under/solgov/command/elite/get_ru_names()
	return alist(
		NOMINATIVE = "униформа лейтенанта спецназа ВМС ТСФ",
		GENITIVE = "униформы лейтенанта спецназа ВМС ТСФ",
		DATIVE = "униформе лейтенанта спецназа ВМС ТСФ",
		ACCUSATIVE = "униформу лейтенанта спецназа ВМС ТСФ",
		INSTRUMENTAL = "униформой лейтенанта спецназа ВМС ТСФ",
		PREPOSITIONAL = "униформе лейтенанта спецназа ВМС ТСФ",
	)

/obj/item/clothing/under/solgov/rep
	name = "Sol Federation representative's uniform"
	desc = "Официальная форма для дипломатических встреч Транс-Солнечной Федерации."
	icon_state = "solgovr"
	item_color = "solgovr"

/obj/item/clothing/under/solgov/rep/get_ru_names()
	return alist(
		NOMINATIVE = "униформа представителя ТСФ",
		GENITIVE = "униформы представителя ТСФ",
		DATIVE = "униформе представителя ТСФ",
		ACCUSATIVE = "униформу представителя ТСФ",
		INSTRUMENTAL = "униформой представителя ТСФ",
		PREPOSITIONAL = "униформе представителя ТСФ",
	)
