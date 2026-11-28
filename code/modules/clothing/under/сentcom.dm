/obj/item/clothing/under/rank/centcom
	icon = 'icons/obj/clothing/uniforms/cargo.dmi'
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

/obj/item/clothing/under/rank/centcom/official
	name = "CentComm officer's jumpsuit"
	desc = "Комбинезон, который носят офицеры Центрального Командования."
	icon_state = "officer"
	item_state = "g_suit"
	item_color = "officer"

/obj/item/clothing/under/rank/centcom/official/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон офицера Центрального Командования",
		GENITIVE = "комбинезона офицера Центрального Командования",
		DATIVE = "комбинезону офицера Центрального Командования",
		ACCUSATIVE = "комбинезон офицера Центрального Командования",
		INSTRUMENTAL = "комбинезоном офицера Центрального Командования",
		PREPOSITIONAL = "комбинезоне офицера Центрального Командования",
	)

/obj/item/clothing/under/rank/centcom/official/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/centcom/commander
	desc = "Комбинезон, который носят высококлассные командиры флота."
	name = "CentComm officer's jumpsuit"
	icon_state = "centcom"
	item_state = "dg_suit"
	item_color = "centcom"

/obj/item/clothing/under/rank/centcom/commander/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон офицера Центрального Командования",
		GENITIVE = "комбинезона офицера Центрального Командования",
		DATIVE = "комбинезону офицера Центрального Командования",
		ACCUSATIVE = "комбинезон офицера Центрального Командования",
		INSTRUMENTAL = "комбинезоном офицера Центрального Командования",
		PREPOSITIONAL = "комбинезоне офицера Центрального Командования",
	)

/obj/item/clothing/under/rank/centcom/lieutenant
	desc = "Золотая отделка на чёрной, как космос, ткани. Эта униформа обозначает звание \"Лейтенант-коммандер\" и несёт на левом плече нашивку АКН Трурль. Носится исключительно офицерами флота \"Нанотрейзен\". Оснащён экзотическими материалами для защиты."
	name = "Nanotrasen Naval Officer Uniform"
	icon_state = "navy_gold"
	item_state = "navy_gold"
	item_color = "navy_gold"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 30, ACID = 30)
	displays_id = 0

/obj/item/clothing/under/rank/centcom/lieutenant/get_ru_names()
	return alist(
		NOMINATIVE = "униформа офицера Флота \"Нанотрейзен\"",
		GENITIVE = "униформы офицера Флота \"Нанотрейзен\"",
		DATIVE = "униформе офицера Флота \"Нанотрейзен\"",
		ACCUSATIVE = "униформу офицера Флота \"Нанотрейзен\"",
		INSTRUMENTAL = "униформой офицера Флота \"Нанотрейзен\"",
		PREPOSITIONAL = "униформе офицера Флота \"Нанотрейзен\"",
	)

/obj/item/clothing/under/rank/centcom/lieutenant/skirt
	desc = "Золотая отделка на чёрной, как космос, ткани. Эта юбка обозначает звание \"Лейтенант-коммандер\" и несёт на левом плече нашивку АКН Трурль. Носится исключительно офицерами флота \"Нанотрейзен\". Оснащён экзотическими материалами для защиты."
	name = "Nanotrasen Naval Officer Skirt"
	icon_state = "navy_goldf"
	item_state = "navy_goldf"
	item_color = "navy_goldf"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
	)

/obj/item/clothing/under/rank/centcom/lieutenant/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "юбка офицера Флота \"Нанотрейзен\"",
		GENITIVE = "юбки офицера Флота \"Нанотрейзен\"",
		DATIVE = "юбке офицера Флота \"Нанотрейзен\"",
		ACCUSATIVE = "юбку офицера Флота \"Нанотрейзен\"",
		INSTRUMENTAL = "юбкой офицера Флота \"Нанотрейзен\"",
		PREPOSITIONAL = "юбке офицера Флота \"Нанотрейзен\"",
	)

/obj/item/clothing/under/rank/centcom/captain
	desc = "Золотая отделка на чёрной, как космос, ткани. Эта униформа обозначает звание \"Капитан\" и несёт на левом плече нашивку АКН Трурль. Носится исключительно офицерами флота \"Нанотрейзен\". Оснащён экзотическими материалами для защиты."
	name = "Nanotrasen Naval Captain Uniform"
	icon_state = "navy_gold"
	item_state = "navy_gold"
	item_color = "navy_gold"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 30, ACID = 30)
	displays_id = 0

/obj/item/clothing/under/rank/centcom/captain/get_ru_names()
	return alist(
		NOMINATIVE = "униформа капитана Флота \"Нанотрейзен\"",
		GENITIVE = "униформы капитана Флота \"Нанотрейзен\"",
		DATIVE = "униформе капитана Флота \"Нанотрейзен\"",
		ACCUSATIVE = "униформу капитана Флота \"Нанотрейзен\"",
		INSTRUMENTAL = "униформой капитана Флота \"Нанотрейзен\"",
		PREPOSITIONAL = "униформе капитана Флота \"Нанотрейзен\"",
	)

/obj/item/clothing/under/rank/centcom/captain/solgov
	name = "Trans-Solar Federation commander's uniform"
	desc = "Золотая отделка на чёрной, как космос, ткани. Эта униформа обозначает звание \"Командир\" и несёт на левом плече нашивку АКН Трурль. Носится исключительно командирами Транс-Солнечной Федерации. Оснащён экзотическими материалами для защиты."

/obj/item/clothing/under/rank/centcom/captain/solgov/get_ru_names()
	return alist(
		NOMINATIVE = "униформа командира Транс-Солнечной Федерации",
		GENITIVE = "униформы командира Транс-Солнечной Федерации",
		DATIVE = "униформе командира Транс-Солнечной Федерации",
		ACCUSATIVE = "униформу командира Транс-Солнечной Федерации",
		INSTRUMENTAL = "униформой командира Транс-Солнечной Федерации",
		PREPOSITIONAL = "униформе командира Транс-Солнечной Федерации",
	)

/obj/item/clothing/under/rank/centcom/diplomatic
	desc = "Очень цветасто и официально выглядящая униформа Дипломатической Корпорации \"Нанотрейзен\"."
	name = "Nanotrasen Diplomatic Uniform"
	icon_state = "presidente"
	item_state = "g_suit"
	item_color = "presidente"
	displays_id = 0

/obj/item/clothing/under/rank/centcom/diplomatic/get_ru_names()
	return alist(
		NOMINATIVE = "парадная униформа дипломата \"Нанотрейзен\"",
		GENITIVE = "парадной униформы дипломата \"Нанотрейзен\"",
		DATIVE = "парадной униформе дипломата \"Нанотрейзен\"",
		ACCUSATIVE = "парадную униформу дипломата \"Нанотрейзен\"",
		INSTRUMENTAL = "парадной униформой дипломата \"Нанотрейзен\"",
		PREPOSITIONAL = "парадной униформе дипломата \"Нанотрейзен\"",
		)

// Blueshield for CentCom person
/obj/item/clothing/under/rank/centcom/blueshield
	desc = "Золотая отделка на чёрной, как космос, ткани. Эта униформа имеет обозначение \"Личная Охрана\" на левом плече. Оснащён экзотическими материалами для защиты."
	name = "Formal Blueshield's Uniform"
	icon_state = "officer"
	item_state = "g_suit"
	item_color = "officer"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 30, ACID = 30)
	displays_id = 0

/obj/item/clothing/under/rank/centcom/blueshield/get_ru_names()
	return alist(
		NOMINATIVE = "парадная униформа Синего Щита",
		GENITIVE = "парадной униформы Синего Щита",
		DATIVE = "парадной униформе Синего Щита",
		ACCUSATIVE = "парадную униформу Синего Щита",
		INSTRUMENTAL = "парадной униформой Синего Щита",
		PREPOSITIONAL = "парадной униформе Синего Щита",
	)
