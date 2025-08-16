/obj/item/organ/external/head/vulpkanin
	species_type = /datum/species/vulpkanin

/obj/item/organ/external/head/vulpkanin/wolpin
	species_type = /datum/species/monkey/vulpkanin

/obj/item/organ/internal/liver/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Эта принадлежала вульпканину."
	ru_names = list(
		NOMINATIVE = "печень вульпканина",
		GENITIVE = "печени вульпканина",
		DATIVE = "печени вульпканина",
		ACCUSATIVE = "печень вульпканина",
		INSTRUMENTAL = "печенью вульпканина",
		PREPOSITIONAL = "печени вульпканина"
	)
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	item_state = "vulpkanin_liver"
	alcohol_intensity = 1.4

/obj/item/organ/internal/eyes/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin eyeballs"
	desc = "Парный орган, отвечающий за зрение - восприятие света и его трансформацию в видимое изображение. Эти принадлежали вульпканину."
	ru_names = list(
		NOMINATIVE = "глаза вульпканина",
		GENITIVE = "глаз вульпканина",
		DATIVE = "глазам вульпканина",
		ACCUSATIVE = "глаза вульпканина",
		INSTRUMENTAL = "глазами вульпканина",
		PREPOSITIONAL = "глазах вульпканина"
	)
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	item_state = "vulpkanin_eyes"
	colourblind_matrix = MATRIX_VULP_CBLIND //The colour matrix parameter that the mob will recieve when they get the disability.
	replace_colours = PROTANOPIA_COLOR_REPLACE
	see_in_dark = 8

/obj/item/organ/internal/eyes/vulpkanin/wolpin //Being the lesser form of Vulpkanin, Wolpins have an utterly incurable version of their colourblindness.
	species_type = /datum/species/monkey/vulpkanin
	name = "wolpin eyeballs"
	desc = "Парный орган, отвечающий за зрение - восприятие света и его трансформацию в видимое изображение. Эти принадлежали вульпину."
	ru_names = list(
		NOMINATIVE = "глаза вульпина",
		GENITIVE = "глаз вульпина",
		DATIVE = "глазам вульпина",
		ACCUSATIVE = "глаза вульпина",
		INSTRUMENTAL = "глазами вульпина",
		PREPOSITIONAL = "глазах вульпина"
	)
	colourmatrix = MATRIX_VULP_CBLIND
	see_in_dark = 8
	replace_colours = PROTANOPIA_COLOR_REPLACE

/obj/item/organ/internal/ears/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали вульпканину."
	ru_names = list(
		NOMINATIVE = "уши вульпканина",
		GENITIVE = "ушей вульпканина",
		DATIVE = "ушам вульпканина",
		ACCUSATIVE = "уши вульпканина",
		INSTRUMENTAL = "ушами вульпканина",
		PREPOSITIONAL = "ушах вульпканина"
	)

/obj/item/organ/internal/heart/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin heart"
	desc = "Орган, качающий кровь или её заменяющую субстанцию по организму гуманоида. Это принадлежало вульпканину."
	ru_names = list(
		NOMINATIVE = "сердце вульпканина",
		GENITIVE = "сердца вульпканина",
		DATIVE = "сердцу вульпканина",
		ACCUSATIVE = "сердце вульпканина",
		INSTRUMENTAL = "сердцем вульпканина",
		PREPOSITIONAL = "сердце вульпканина"
	)
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	item_state = "vulpkanin_heart-on"
	item_base = "vulpkanin_heart"

/obj/item/organ/internal/brain/vulpkanin
	species_type = /datum/species/vulpkanin
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Этот принадлежал вульпканину."
	ru_names = list(
		NOMINATIVE = "мозг вульпканина",
		GENITIVE = "мозга вульпканина",
		DATIVE = "мозгу вульпканина",
		ACCUSATIVE = "мозг вульпканина",
		INSTRUMENTAL = "мозгом вульпканина",
		PREPOSITIONAL = "мозге вульпканина"
	)
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	icon_state = "brain2"
	item_state = "vulpkanin_brain"
	mmi_icon = 'icons/obj/species_organs/vulpkanin.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/lungs/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали вульпканину."
	ru_names = list(
		NOMINATIVE = "лёгкие вульпканина",
		GENITIVE = "лёгких вульпканина",
		DATIVE = "лёгким вульпканина",
		ACCUSATIVE = "лёгкие вульпканина",
		INSTRUMENTAL = "лёгкими вульпканина",
		PREPOSITIONAL = "лёгких вульпканина"
	)
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	item_state = "vulpkanin_lungs"

/obj/item/organ/internal/kidneys/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали вульпканину."
	ru_names = list(
		NOMINATIVE = "почки вульпканина",
		GENITIVE = "почек вульпканина",
		DATIVE = "почкам вульпканина",
		ACCUSATIVE = "почки вульпканина",
		INSTRUMENTAL = "почками вульпканина",
		PREPOSITIONAL = "почках вульпканина"
	)
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	item_state = "vulpkanin_kidneys"

/obj/item/organ/external/tail/vulpkanin
	species_type = /datum/species/vulpkanin
	name = "vulpkanin tail"
	desc = "Хвост. Этот принадлежал вульпканину."
	ru_names = list(
		NOMINATIVE = "хвост вульпканина",
		GENITIVE = "хвоста вульпканина",
		DATIVE = "хвосту вульпканина",
		ACCUSATIVE = "хвост вульпканина",
		INSTRUMENTAL = "хвостом вульпканина",
		PREPOSITIONAL = "хвосте вульпканина"
	)
	icon_name = "vulptail_s"
	max_damage = 25
	min_broken_damage = 15
