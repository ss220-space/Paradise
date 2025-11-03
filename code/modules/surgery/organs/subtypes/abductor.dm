/obj/item/organ/internal/heart/grey/abductor
	species_type = /datum/species/abductor
	name = "abductor heart"
	desc = "Орган, качающий кровь или её заменяющую субстанцию по организму гуманоида. Это принадлежало абдуктору."

/obj/item/organ/internal/heart/grey/abductor/get_ru_names()
	return list(
		NOMINATIVE = "сердце абдуктора",
		GENITIVE = "сердца абдуктора",
		DATIVE = "сердцу абдуктора",
		ACCUSATIVE = "сердце абдуктора",
		INSTRUMENTAL = "сердцем абдуктора",
		PREPOSITIONAL = "сердце абдуктора"
	)

/obj/item/organ/internal/liver/grey/abductor
	species_type = /datum/species/abductor
	name = "abductor liver"
	alcohol_intensity = 1

/obj/item/organ/internal/liver/grey/abductor/get_ru_names()
	return list(
		NOMINATIVE = "печень абдуктора",
		GENITIVE = "печени абдуктора",
		DATIVE = "печени абдуктора",
		ACCUSATIVE = "печень абдуктора",
		INSTRUMENTAL = "печенью абдуктора",
		PREPOSITIONAL = "печени абдуктора"
	)

/obj/item/organ/internal/kidneys/grey/abductor
	species_type = /datum/species/abductor
	name = "abductor kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали абдуктору."

/obj/item/organ/internal/kidneys/grey/abductor/get_ru_names()
	return list(
		NOMINATIVE = "почки абдуктора",
		GENITIVE = "почек абдуктора",
		DATIVE = "почкам абдуктора",
		ACCUSATIVE = "почки абдуктора",
		INSTRUMENTAL = "почками абдуктора",
		PREPOSITIONAL = "почках абдуктора"
	)

/obj/item/organ/internal/brain/abductor
	species_type = /datum/species/abductor
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Этот принадлежал абдуктору."
	icon_state = "brain-x"
	item_state = "grey_brain"
	mmi_icon_state = "mmi_alien"

/obj/item/organ/internal/brain/abductor/get_ru_names()
	return list(
		NOMINATIVE = "мозг абдуктора",
		GENITIVE = "мозга абдуктора",
		DATIVE = "мозгу абдуктора",
		ACCUSATIVE = "мозг абдуктора",
		INSTRUMENTAL = "мозгом абдуктора",
		PREPOSITIONAL = "мозге абдуктора"
	)

/obj/item/organ/internal/eyes/grey/abductor
	species_type = /datum/species/abductor
	name = "abductor eyeballs"

/obj/item/organ/internal/eyes/grey/abductor/get_ru_names()
	return list(
		NOMINATIVE = "глаза абдуктора",
		GENITIVE = "глаз абдуктора",
		DATIVE = "глазам абдуктора",
		ACCUSATIVE = "глаза абдуктора",
		INSTRUMENTAL = "глазами абдуктора",
		PREPOSITIONAL = "глазах абдуктора"
	)

/obj/item/organ/internal/ears/grey/abductor
	species_type = /datum/species/abductor
	name = "abductor ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали абдуктору."

/obj/item/organ/internal/ears/grey/abductor/get_ru_names()
	return list(
		NOMINATIVE = "уши абдуктора",
		GENITIVE = "ушей абдуктора",
		DATIVE = "ушам абдуктора",
		ACCUSATIVE = "уши абдуктора",
		INSTRUMENTAL = "ушами абдуктора",
		PREPOSITIONAL = "ушах абдуктора"
	)
