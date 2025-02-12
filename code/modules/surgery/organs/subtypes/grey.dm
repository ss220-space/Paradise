/obj/item/organ/internal/liver/grey
	species_type = /datum/species/grey
	name = "grey liver"
	desc = "Маленькая печень серого цвета - орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма."
	ru_names = list(
		NOMINATIVE = "печень серого",
		GENITIVE = "печени серого",
		DATIVE = "печени серого",
		ACCUSATIVE = "печень серого",
		INSTRUMENTAL = "печенью серого",
		PREPOSITIONAL = "печени серого"
	)
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_liver"
	alcohol_intensity = 1.4

/obj/item/organ/internal/brain/grey
	species_type = /datum/species/grey
	desc = "A large brain"
	icon = 'icons/obj/species_organs/grey.dmi'
	icon_state = "brain2"
	item_state = "grey_brain"
	mmi_icon = 'icons/obj/species_organs/grey.dmi'
	mmi_icon_state = "mmi_full"
	smart_mind = TRUE // nerd brains show us sci-hud and research scanner

/obj/item/organ/internal/brain/grey/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	M.add_language(LANGUAGE_GREY)

/obj/item/organ/internal/brain/grey/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	M.remove_language(LANGUAGE_GREY)
	. = ..()

/obj/item/organ/internal/eyes/grey
	species_type = /datum/species/grey
	name = "grey eyeballs"
	desc = "Парный орган, отвечающий за зрение - восприятие света и его трансформацию в видимое изображение. Даже в таком виде они выглядят абсолютно пустыми и безэмоциональными."
	ru_names = list(
		NOMINATIVE = "глаза серого",
		GENITIVE = "глаз серого",
		DATIVE = "глазам серого",
		ACCUSATIVE = "глаза серого",
		INSTRUMENTAL = "глазами серого",
		PREPOSITIONAL = "глазах серого"
	)
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_eyes"
	see_in_dark = 3
	examine_mod = EXAMINE_INSTANT // Insta carbon examine

/obj/item/organ/internal/heart/grey
	species_type = /datum/species/grey
	name = "grey heart"
	desc = "Орган, качающий кровь или её заменяющую субстанцию по организму гуманоида. Это принадлежало серому."
	ru_names = list(
		NOMINATIVE = "сердце серого",
		GENITIVE = "сердца серого",
		DATIVE = "сердцу серого",
		ACCUSATIVE = "сердце серого",
		INSTRUMENTAL = "сердцем серого",
		PREPOSITIONAL = "сердце серого"
	)
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_heart-on"
	item_base = "grey_heart"

/obj/item/organ/internal/lungs/grey
	species_type = /datum/species/grey
	name = "grey lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали серому."
	ru_names = list(
		NOMINATIVE = "лёгкие серого",
		GENITIVE = "лёгких серого",
		DATIVE = "лёгким серого",
		ACCUSATIVE = "лёгкие серого",
		INSTRUMENTAL = "лёгкими серого",
		PREPOSITIONAL = "лёгких серого"
	)
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_lungs"

/obj/item/organ/internal/kidneys/grey
	species_type = /datum/species/grey
	name = "grey kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали серому."
	ru_names = list(
		NOMINATIVE = "почки серого",
		GENITIVE = "почек серого",
		DATIVE = "почкам серого",
		ACCUSATIVE = "почки",
		INSTRUMENTAL = "почками серого",
		PREPOSITIONAL = "почках серого"
	)
	icon = 'icons/obj/species_organs/grey.dmi'
	item_state = "grey_kidneys"
