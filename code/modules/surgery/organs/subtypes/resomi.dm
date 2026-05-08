/obj/item/organ/internal/liver/resomi
	species_type = /datum/species/resomi
	name = "resomi liver"
	desc = "Печень резоми. Крошечная, но эффективно перерабатывает питательные вещества для поддержания их бешеного метаболизма."

/obj/item/organ/internal/liver/resomi/get_ru_names()
	return list(
		NOMINATIVE = "печень резоми",
		GENITIVE = "печени резоми",
		DATIVE = "печени резоми",
		ACCUSATIVE = "печень резоми",
		INSTRUMENTAL = "печенью резоми",
		PREPOSITIONAL = "печени резоми",
	)

/obj/item/organ/internal/eyes/resomi
	species_type = /datum/species/resomi
	name = "resomi eyes"
	desc = "Пара глаз резоми. Они устроены так, чтобы улавливать мельчайшие движения на высокой скорости."

/obj/item/organ/internal/eyes/resomi/generate_icon(mob/living/carbon/human/HA)
	var/icon/eyes_icon = new /icon('icons/mob/sprite_accessories/resomi/resomi_eyes.dmi', "resomi_eyes_s")
	eyes_icon.Blend(eye_colour, ICON_ADD)
	return eyes_icon

/obj/item/organ/internal/eyes/resomi/get_ru_names()
	return list(
		NOMINATIVE = "глаза резоми",
		GENITIVE = "глаз резоми",
		DATIVE = "глазам резоми",
		ACCUSATIVE = "глаза резоми",
		INSTRUMENTAL = "глазами резоми",
		PREPOSITIONAL = "глазах резоми",
	)

/obj/item/organ/internal/ears/resomi
	species_type = /datum/species/resomi
	name = "resomi ears"
	desc = "Слуховой аппарат резоми. Включает в себя структуры для управления всеми четырьмя внешними ушными раковинами."

/obj/item/organ/internal/ears/resomi/get_ru_names()
	return list(
		NOMINATIVE = "уши резоми",
		GENITIVE = "ушей резоми",
		DATIVE = "ушам резоми",
		ACCUSATIVE = "уши резоми",
		INSTRUMENTAL = "ушами резоми",
		PREPOSITIONAL = "ушах резоми",
	)

/obj/item/organ/internal/heart/resomi
	species_type = /datum/species/resomi
	name = "resomi heart"
	desc = "Сердце резоми. Бьется невероятно часто, обеспечивая циркуляцию крови в их хрупком теле."

/obj/item/organ/internal/heart/resomi/get_ru_names()
	return list(
		NOMINATIVE = "сердце резоми",
		GENITIVE = "сердца резоми",
		DATIVE = "сердцу резоми",
		ACCUSATIVE = "сердце резоми",
		INSTRUMENTAL = "сердцем резоми",
		PREPOSITIONAL = "сердце резоми",
	)

/obj/item/organ/internal/brain/resomi
	species_type = /datum/species/resomi
	name = "resomi brain"
	desc = "Мозг резоми. Крайне плотная нейронная структура, позволяющая этим существам обрабатывать информацию на огромной скорости."

/obj/item/organ/internal/brain/resomi/get_ru_names()
	return list(
		NOMINATIVE = "мозг резоми",
		GENITIVE = "мозга резоми",
		DATIVE = "мозгу резоми",
		ACCUSATIVE = "мозг резоми",
		INSTRUMENTAL = "мозгом резоми",
		PREPOSITIONAL = "мозге резоми",
	)

/obj/item/organ/internal/lungs/resomi
	species_type = /datum/species/resomi
	name = "resomi lungs"
	desc = "Пара легких резоми. Адаптированы для эффективного поглощения кислорода даже в разреженной и холодной атмосфере."

/obj/item/organ/internal/lungs/resomi/get_ru_names()
	return list(
		NOMINATIVE = "легкие резоми",
		GENITIVE = "легких резоми",
		DATIVE = "легким резоми",
		ACCUSATIVE = "легкие резоми",
		INSTRUMENTAL = "легкими резоми",
		PREPOSITIONAL = "легких резоми",
	)

/obj/item/organ/internal/kidneys/resomi
	species_type = /datum/species/resomi
	name = "resomi kidneys"
	desc = "Пара почек резоми. Очень маленькие и уязвимые для токсинов."

/obj/item/organ/internal/kidneys/resomi/get_ru_names()
	return list(
		NOMINATIVE = "почки резоми",
		GENITIVE = "почек резоми",
		DATIVE = "почкам резоми",
		ACCUSATIVE = "почки резоми",
		INSTRUMENTAL = "почками резоми",
		PREPOSITIONAL = "почках резоми",
	)

/obj/item/organ/internal/appendix/resomi
	species_type = /datum/species/resomi
	name = "resomi appendix"
	desc = "Аппендикс резоми. Рудиментарный орган, сохранившийся с тех времен, когда их предки ели более грубую пищу."

/obj/item/organ/internal/appendix/resomi/get_ru_names()
	return list(
		NOMINATIVE = "аппендикс резоми",
		GENITIVE = "аппендикса резоми",
		DATIVE = "аппендиксу резоми",
		ACCUSATIVE = "аппендикс резоми",
		INSTRUMENTAL = "аппендиксом резоми",
		PREPOSITIONAL = "аппендиксе резоми",
	)
