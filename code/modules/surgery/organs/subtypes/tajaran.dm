/obj/item/organ/internal/liver/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Эта принадлежала таярану."
	ru_names = list(
		NOMINATIVE = "печень таярана",
		GENITIVE = "печени таярана",
		DATIVE = "печени таярана",
		ACCUSATIVE = "печень таярана",
		INSTRUMENTAL = "печенью таярана",
		PREPOSITIONAL = "печени таярана"
	)
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_liver"
	alcohol_intensity = 1.4

/obj/item/organ/internal/eyes/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran eyeballs"
	desc = "Парный орган, отвечающий за зрение - восприятие света и его трансформацию в видимое изображение. Эти принадлежали таярану."
	ru_names = list(
		NOMINATIVE = "глаза таярана",
		GENITIVE = "глаз таярана",
		DATIVE = "глазам таярана",
		ACCUSATIVE = "глаза таярана",
		INSTRUMENTAL = "глазами таярана",
		PREPOSITIONAL = "глазах таярана"
	)
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_eyes"
	colourblind_matrix = MATRIX_TAJ_CBLIND //The colour matrix parameter that the mob will recieve when they get the disability.
	replace_colours = TRITANOPIA_COLOR_REPLACE
	see_in_dark = 8

/obj/item/organ/internal/ears/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали таярану."
	ru_names = list(
		NOMINATIVE = "уши таярана",
		GENITIVE = "ушей таярана",
		DATIVE = "ушам таярана",
		ACCUSATIVE = "уши таярана",
		INSTRUMENTAL = "ушами таярана",
		PREPOSITIONAL = "ушах таярана"
	)

/obj/item/organ/internal/eyes/tajaran/farwa //Being the lesser form of Tajara, Farwas have an utterly incurable version of their colourblindness.
	species_type = /datum/species/monkey/tajaran
	name = "farwa eyeballs"
	desc = "Парный орган, отвечающий за зрение - восприятие света и его трансформацию в видимое изображение. Эти принадлежали фарве."
	ru_names = list(
		NOMINATIVE = "глаза фарвы",
		GENITIVE = "глаз фарвы",
		DATIVE = "глазам фарвы",
		ACCUSATIVE = "глаза фарвы",
		INSTRUMENTAL = "глазами фарвы",
		PREPOSITIONAL = "глазах фарвы"
	)
	colourmatrix = MATRIX_TAJ_CBLIND
	see_in_dark = 8
	replace_colours = TRITANOPIA_COLOR_REPLACE

/obj/item/organ/internal/heart/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran heart"
	desc = "Орган, качающий кровь или её заменяющую субстанцию по организму гуманоида. Это принадлежало таярану."
	ru_names = list(
		NOMINATIVE = "сердце таярана",
		GENITIVE = "сердца таярана",
		DATIVE = "сердцу таярана",
		ACCUSATIVE = "сердце таярана",
		INSTRUMENTAL = "сердцем таярана",
		PREPOSITIONAL = "сердце таярана"
	)
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_heart-on"
	item_base = "tajaran_heart"

/obj/item/organ/internal/brain/tajaran
	species_type = /datum/species/tajaran
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Этот принадлежал таярану."
	ru_names = list(
		NOMINATIVE = "мозг таярана",
		GENITIVE = "мозга таярана",
		DATIVE = "мозгу таярана",
		ACCUSATIVE = "мозг таярана",
		INSTRUMENTAL = "мозгом таярана",
		PREPOSITIONAL = "мозге таярана"
	)
	icon = 'icons/obj/species_organs/tajaran.dmi'
	icon_state = "brain2"
	item_state = "tajaran_brain"
	mmi_icon = 'icons/obj/species_organs/tajaran.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/lungs/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали таярану."
	ru_names = list(
		NOMINATIVE = "лёгкие таярана",
		GENITIVE = "лёгких таярана",
		DATIVE = "лёгким таярана",
		ACCUSATIVE = "лёгкие таярана",
		INSTRUMENTAL = "лёгкими таярана",
		PREPOSITIONAL = "лёгких таярана"
	)
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_lungs"

/obj/item/organ/internal/kidneys/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали таярану."
	ru_names = list(
		NOMINATIVE = "почки таярана",
		GENITIVE = "почек таярана",
		DATIVE = "почкам таярана",
		ACCUSATIVE = "почки таярана",
		INSTRUMENTAL = "почками таярана",
		PREPOSITIONAL = "почках таярана"
	)
	icon = 'icons/obj/species_organs/tajaran.dmi'
	item_state = "tajaran_kidneys"

/obj/item/organ/external/tail/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran tail"
	desc = "Хвост. Этот принадлежал таярану."
	ru_names = list(
		NOMINATIVE = "хвост таярана",
		GENITIVE = "хвоста таярана",
		DATIVE = "хвосту таярана",
		ACCUSATIVE = "хвост таярана",
		INSTRUMENTAL = "хвостом таярана",
		PREPOSITIONAL = "хвосте таярана"
	)
	icon_name = "tajtail_s"
	max_damage = 20
	min_broken_damage = 15
