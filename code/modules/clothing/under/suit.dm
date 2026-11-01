/obj/item/clothing/under/suit
	icon = 'icons/clothing/uniforms/suit.dmi'
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

/obj/item/clothing/under/suit/mafia
	name = "mafia outfit"
	desc = "Мистер Сальери передаёт вам привет."
	icon_state = "mafia"
	item_state = "mafia"
	item_color = "mafia"

/obj/item/clothing/under/suit/mafia/get_ru_names()
	return alist(
		NOMINATIVE = "одежда мафии",
		GENITIVE = "одежды мафии",
		DATIVE = "одежде мафии",
		ACCUSATIVE = "одежду мафии",
		INSTRUMENTAL = "одеждой мафии",
		PREPOSITIONAL = "одежде мафии",
	)

/obj/item/clothing/under/suit/mafia/vest
	name = "mafia vest"
	desc = "Серьёзные проблемы часто требуют серьёзных решений."
	icon_state = "mafiavest"
	item_state = "mafiavest"
	item_color = "mafiavest"

/obj/item/clothing/under/suit/mafia/vest/get_ru_names()
	return alist(
		NOMINATIVE = "жилет мафии",
		GENITIVE = "жилета мафии",
		DATIVE = "жилету мафии",
		ACCUSATIVE = "жилет мафии",
		INSTRUMENTAL = "жилетом мафии",
		PREPOSITIONAL = "жилете мафии",
	)

/obj/item/clothing/under/suit/mafia/white
	name = "white mafia outfit"
	desc = "Клин выбивается клином."
	icon_state = "mafiawhite"
	item_state = "mafiawhite"
	item_color = "mafiawhite"

/obj/item/clothing/under/suit/mafia/white/get_ru_names()
	return alist(
		NOMINATIVE = "белая одежда мафии",
		GENITIVE = "белой одежды мафии",
		DATIVE = "белой одежде мафии",
		ACCUSATIVE = "белую одежду мафии",
		INSTRUMENTAL = "белой одеждой мафии",
		PREPOSITIONAL = "белой одежде мафии",
	)

/obj/item/clothing/under/suit/mafia/sue
	name = "mafia vest"
	desc = "Мафией не становятся, ей рождаются."
	icon_state = "suevest"
	item_state = "suevest"
	item_color = "suevest"

/obj/item/clothing/under/suit/mafia/sue/get_ru_names()
	return alist(
		NOMINATIVE = "жилет мафии",
		GENITIVE = "жилета мафии",
		DATIVE = "жилету мафии",
		ACCUSATIVE = "жилет мафии",
		INSTRUMENTAL = "жилетом мафии",
		PREPOSITIONAL = "жилете мафии",
	)

/obj/item/clothing/under/suit/mafia/tan
	name = "leather mafia outfit"
	desc = "Большой барабан хорошо звучит только издалека."
	icon_state = "mafiatan"
	item_state = "mafiatan"
	item_color = "mafiatan"

/obj/item/clothing/under/suit/mafia/tan/get_ru_names()
	return alist(
		NOMINATIVE = "кожаная одежда мафии",
		GENITIVE = "кожаной одежды мафии",
		DATIVE = "кожаной одежде мафии",
		ACCUSATIVE = "кожаную одежду мафии",
		INSTRUMENTAL = "кожаной одеждой мафии",
		PREPOSITIONAL = "кожаной одежде мафии",
	)

/obj/item/clothing/under/suit/noble_clothes
	name = "noble clothes"
	desc = "До величественности им самую малость не хватает."
	icon_state = "noble_clothes"
	item_color = "noble_clothes"
	item_state = "noble_clothes"

/obj/item/clothing/under/suit/noble_clothes/get_ru_names()
	return alist(
		NOMINATIVE = "одежда знати",
		GENITIVE = "одежды знати",
		DATIVE = "одежде знати",
		ACCUSATIVE = "одежду знати",
		INSTRUMENTAL = "одеждой знати",
		PREPOSITIONAL = "одежде знати",
	)

/obj/item/clothing/under/suit/vice
	name = "vice officer's jumpsuit"
	desc = "Это стандартная одежда красавчика-офицера, которую можно было видеть на Голо-Видении."
	icon_state = "vice"
	item_state = "gy_suit"
	item_color = "vice"

/obj/item/clothing/under/suit/vice/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон вице-офицера",
		GENITIVE = "комбинезона вице-офицера",
		DATIVE = "комбинезону вице-офицера",
		ACCUSATIVE = "комбинезон вице-офицера",
		INSTRUMENTAL = "комбинезоном вице-офицера",
		PREPOSITIONAL = "комбинезоне вице-офицера",
	)

/obj/item/clothing/under/suit/jacket
	name = "black suit"
	desc = "Чёрный костюм и красный галстук. Очень строго."
	icon_state = "black_suit"
	item_state = "bl_suit"
	item_color = "black_suit"

/obj/item/clothing/under/suit/jacket/get_ru_names()
	return alist(
		NOMINATIVE = "чёрный костюм",
		GENITIVE = "чёрного костюма",
		DATIVE = "чёрному костюму",
		ACCUSATIVE = "чёрный костюм",
		INSTRUMENTAL = "чёрным костюмом",
		PREPOSITIONAL = "чёрном костюме",
	)

/obj/item/clothing/under/suit/jacket/really_black
	name = "executive suit"
	desc = "Парадный чёрный костюм с красным галстуком, для лучших членов экипажа."
	icon_state = "really_black_suit"
	item_color = "really_black_suit"

/obj/item/clothing/under/suit/jacket/really_black/get_ru_names()
	return alist(
		NOMINATIVE = "официальный костюм",
		GENITIVE = "официального костюма",
		DATIVE = "официальному костюму",
		ACCUSATIVE = "официальный костюм",
		INSTRUMENTAL = "официальным костюмом",
		PREPOSITIONAL = "официальном костюме",
	)

/obj/item/clothing/under/suit/jacket/female
	name = "women\'s executive suit"
	desc = "Парадный брючный костюм, для лучших членов экипажа."
	icon_state = "black_suit_fem"
	item_state = "black_suit_fem"
	item_color = "black_suit_fem"

/obj/item/clothing/under/suit/jacket/female/get_ru_names()
	return alist(
		NOMINATIVE = "официальный женский костюм",
		GENITIVE = "официального женского костюма",
		DATIVE = "официальному женскому костюму",
		ACCUSATIVE = "официальный женский костюм",
		INSTRUMENTAL = "официальным женским костюмом",
		PREPOSITIONAL = "официальном женском костюме",
	)

/obj/item/clothing/under/suit/jacket/red
	name = "red suit"
	desc = "Красный костюм с синим галстуком. Немного формальный."
	icon_state = "red_suit"
	item_state = "r_suit"
	item_color = "red_suit"

/obj/item/clothing/under/suit/jacket/red/get_ru_names()
	return alist(
		NOMINATIVE = "красный костюм",
		GENITIVE = "красного костюма",
		DATIVE = "красному костюму",
		ACCUSATIVE = "красный костюм",
		INSTRUMENTAL = "красным костюмом",
		PREPOSITIONAL = "красном костюме",
	)

/obj/item/clothing/under/suit/jacket/red/skirt
	name = "red jumpskirt"
	desc = "Красная юбка с синим галстуком. Немного формальная."
	icon_state = "red_suitf"
	item_color = "red_suitf"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
	)

/obj/item/clothing/under/suit/jacket/red/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "красная юбка",
		GENITIVE = "красной юбки",
		DATIVE = "красной юбке",
		ACCUSATIVE = "красную юбку",
		INSTRUMENTAL = "красной юбкой",
		PREPOSITIONAL = "красной юбке",
	)

/obj/item/clothing/under/suit/jacket/navy
	name = "navy suit"
	desc = "Тёмно-синий костюм и красный галстук, для лучших членов экипажа."
	icon_state = "navy_suit"
	item_state = "navy_suit"
	item_color = "navy_suit"

/obj/item/clothing/under/suit/jacket/navy/get_ru_names()
	return alist(
		NOMINATIVE = "тёмно-синий костюм",
		GENITIVE = "тёмно-синего костюма",
		DATIVE = "тёмно-синему костюму",
		ACCUSATIVE = "тёмно-синий костюм",
		INSTRUMENTAL = "тёмно-синим костюмом",
		PREPOSITIONAL = "тёмно-синем костюме",
	)

/obj/item/clothing/under/suit/jacket/tan
	name = "tan suit"
	desc = "Бежевый костюм с жёлтым галстуком. Элегантно, но обыденно."
	icon_state = "tan_suit"
	item_state = "tan_suit"
	item_color = "tan_suit"

/obj/item/clothing/under/suit/jacket/tan/get_ru_names()
	return alist(
		NOMINATIVE = "бежевый костюм",
		GENITIVE = "бежевого костюма",
		DATIVE = "бежевому костюму",
		ACCUSATIVE = "бежевый костюм",
		INSTRUMENTAL = "бежевым костюмом",
		PREPOSITIONAL = "бежевом костюме",
	)

/obj/item/clothing/under/suit/jacket/burgundy
	name = "burgundy suit"
	desc = "Малиновый костюм и чёрный галстук. Немного формальный."
	icon_state = "burgundy_suit"
	item_state = "burgundy_suit"
	item_color = "burgundy_suit"

/obj/item/clothing/under/suit/jacket/burgundy/get_ru_names()
	return alist(
		NOMINATIVE = "малиновый костюм",
		GENITIVE = "малинового костюма",
		DATIVE = "малиновому костюму",
		ACCUSATIVE = "малиновый костюм",
		INSTRUMENTAL = "малиновым костюмом",
		PREPOSITIONAL = "малиновом костюме",
	)

/obj/item/clothing/under/suit/jacket/charcoal
	name = "charcoal suit"
	desc = "Угольного цвета костюм и синий галстук. Очень профессионально."
	icon_state = "charcoal_suit"
	item_state = "charcoal_suit"
	item_color = "charcoal_suit"

/obj/item/clothing/under/suit/jacket/charcoal/get_ru_names()
	return alist(
		NOMINATIVE = "угольный костюм",
		GENITIVE = "угольного костюма",
		DATIVE = "угольному костюму",
		ACCUSATIVE = "угольный костюм",
		INSTRUMENTAL = "угольным костюмом",
		PREPOSITIONAL = "угольном костюме",
	)

/obj/item/clothing/under/suit/jacket/checkered
	name = "checkered suit"
	desc = "Неплохой костюмчик у тебя. Жалко будет, если с ним что-то стрясётся, да?"
	icon_state = "checkered_suit"
	item_state = "checkered_suit"
	item_color = "checkered_suit"

/obj/item/clothing/under/suit/jacket/checkered/get_ru_names()
	return alist(
		NOMINATIVE = "клетчатый костюм",
		GENITIVE = "клетчатого костюма",
		DATIVE = "клетчатому костюму",
		ACCUSATIVE = "клетчатый костюм",
		INSTRUMENTAL = "клетчатым костюмом",
		PREPOSITIONAL = "клетчатом костюме",
	)

/obj/item/clothing/under/suit/gimmick/captain
	name = "captain's suit"
	desc = "Зелёный костюм и жёлтый галстук. Олицетворяет авторитет."
	icon_state = "green_suit"
	item_state = "dg_suit"
	item_color = "green_suit"

/obj/item/clothing/under/suit/gimmick/captain/get_ru_names()
	return alist(
		NOMINATIVE = "капитанский костюм",
		GENITIVE = "капитанского костюма",
		DATIVE = "капитанскому костюму",
		ACCUSATIVE = "капитанский костюм",
		INSTRUMENTAL = "капитанским костюмом",
		PREPOSITIONAL = "капитанском костюме",
	)

/obj/item/clothing/under/suit/gimmick/head_of_personnel
	name = "head of personnel's suit"
	desc = "Бирюзовый костюм и жёлтый галстук. Властный, но безвкусный ансамбль."
	icon_state = "teal_suit"
	item_state = "g_suit"
	item_color = "teal_suit"

/obj/item/clothing/under/suit/gimmick/head_of_personnel/get_ru_names()
	return alist(
		NOMINATIVE = "костюм главы персонала",
		GENITIVE = "костюма главы персонала",
		DATIVE = "костюму главы персонала",
		ACCUSATIVE = "костюм главы персонала",
		INSTRUMENTAL = "костюмом главы персонала",
		PREPOSITIONAL = "костюме главы персонала",
	)

/obj/item/clothing/under/suit/sl
	name = "amish suit"
	desc = "Этот костюм носили люди, принадлежащие к религиозным общинам консерваторов, пару сотен лет назад."
	icon_state = "sl_suit"
	item_color = "sl_suit"

/obj/item/clothing/under/suit/sl/get_ru_names()
	return alist(
		NOMINATIVE = "деревенский костюм",
		GENITIVE = "деревенского костюма",
		DATIVE = "деревенскому костюму",
		ACCUSATIVE = "деревенский костюм",
		INSTRUMENTAL = "деревенским костюмом",
		PREPOSITIONAL = "деревенском костюме",
	)

/obj/item/clothing/under/suit/red_chaps
	name = "red chaps"
	desc = "Стильные чапсы, которые заставляют тебя выглядеть как бандит."
	icon_state = "red_chaps"
	icon_state = "red_chaps"
	item_color = "red_chaps"
	over_shoes = TRUE

/obj/item/clothing/under/suit/red_chaps/get_ru_names()
	return alist(
		NOMINATIVE = "красные чапсы",
		GENITIVE = "красных чапсов",
		DATIVE = "красным чапсам",
		ACCUSATIVE = "красные чапсы",
		INSTRUMENTAL = "красными чапсами",
		PREPOSITIONAL = "красных чапсах",
	)

/obj/item/clothing/under/suit/white_chaps
	name = "white chaps"
	desc = "Стильные белые чапсы, которые заставляют тебя выглядеть как крутой парень из фильма."
	icon_state = "white_chaps"
	icon_state = "white_chaps"
	item_color = "white_chaps"
	over_shoes = TRUE

/obj/item/clothing/under/suit/white_chaps/get_ru_names()
	return alist(
		NOMINATIVE = "белые чапсы",
		GENITIVE = "белых чапсов",
		DATIVE = "белым чапсам",
		ACCUSATIVE = "белые чапсы",
		INSTRUMENTAL = "белыми чапсами",
		PREPOSITIONAL = "белых чапсах",
	)

/obj/item/clothing/under/suit/tan_chaps
	name = "tan chaps"
	desc = "Стильные чапсы, которые заставляют тебя выглядеть как реальный шериф."
	icon_state = "tan_chaps"
	icon_state = "tan_chaps"
	item_color = "tan_chaps"
	over_shoes = TRUE

/obj/item/clothing/under/suit/tan_chaps/get_ru_names()
	return alist(
		NOMINATIVE = "бежевые чапсы",
		GENITIVE = "бежевых чапсов",
		DATIVE = "бежевым чапсам",
		ACCUSATIVE = "бежевые чапсы",
		INSTRUMENTAL = "бежевыми чапсами",
		PREPOSITIONAL = "бежевых чапсах",
	)

/obj/item/clothing/under/suit/brown_chaps
	name = "brown chaps"
	desc = "Стильные чапсы, которые заставляют тебя выглядеть как реальный ковбой."
	icon_state = "brown_chaps"
	icon_state = "brown_chaps"
	item_color = "brown_chaps"
	over_shoes = TRUE

/obj/item/clothing/under/suit/brown_chaps/get_ru_names()
	return alist(
		NOMINATIVE = "коричневые чапсы",
		GENITIVE = "коричневых чапсов",
		DATIVE = "коричневым чапсам",
		ACCUSATIVE = "коричневые чапсы",
		INSTRUMENTAL = "коричневыми чапсами",
		PREPOSITIONAL = "коричневых чапсах",
	)
