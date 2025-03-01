/obj/item/organ/internal/liver/unathi
	species_type = /datum/species/unathi
	name = "unathi liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Эта принадлежала унатху."
	ru_names = list(
		NOMINATIVE = "печень унатха",
		GENITIVE = "печени унатха",
		DATIVE = "печени унатха",
		ACCUSATIVE = "печень унатха",
		INSTRUMENTAL = "печенью унатха",
		PREPOSITIONAL = "печени унатха"
	)
	icon = 'icons/obj/species_organs/unathi.dmi'
	item_state = "unathi_liver"
	alcohol_intensity = 0.8

/obj/item/organ/internal/eyes/unathi
	species_type = /datum/species/unathi
	name = "unathi eyeballs"
	desc = "Парный орган, отвечающий за зрение - восприятие света и его трансформацию в видимое изображение. Эти принадлежали унатху."
	ru_names = list(
		NOMINATIVE = "глаза унатха",
		GENITIVE = "глаз унатха",
		DATIVE = "глазам унатха",
		ACCUSATIVE = "глаза унатха",
		INSTRUMENTAL = "глазами унатха",
		PREPOSITIONAL = "глазах унатха"
	)
	icon = 'icons/obj/species_organs/unathi.dmi'
	item_state = "unathi_eyes"
	see_in_dark = 3

/obj/item/organ/internal/ears/unathi
	species_type = /datum/species/unathi
	name = "unathi ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали унатху."
	ru_names = list(
		NOMINATIVE = "уши унатха",
		GENITIVE = "ушей унатха",
		DATIVE = "ушам унатха",
		ACCUSATIVE = "уши унатха",
		INSTRUMENTAL = "ушами унатха",
		PREPOSITIONAL = "ушах унатха"
	)

/obj/item/organ/internal/heart/unathi
	species_type = /datum/species/unathi
	name = "unathi heart"
	desc = "Орган, качающий кровь или её заменяющую субстанцию по организму гуманоида. Это принадлежало унатху."
	ru_names = list(
		NOMINATIVE = "сердце унатха",
		GENITIVE = "сердца унатха",
		DATIVE = "сердцу унатха",
		ACCUSATIVE = "сердце унатха",
		INSTRUMENTAL = "сердцем унатха",
		PREPOSITIONAL = "сердце унатха"
	)
	icon = 'icons/obj/species_organs/unathi.dmi'
	item_state = "unathi_heart-on"
	item_base = "unathi_heart"

/obj/item/organ/internal/brain/unathi
	species_type = /datum/species/unathi
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Выглядит относительно маленьким. Этот принадлежал унатху."
	ru_names = list(
		NOMINATIVE = "мозг унатха",
		GENITIVE = "мозга унатха",
		DATIVE = "мозгу унатха",
		ACCUSATIVE = "мозг унатха",
		INSTRUMENTAL = "мозгом унатха",
		PREPOSITIONAL = "мозге унатха"
	)
	icon = 'icons/obj/species_organs/unathi.dmi'
	icon_state = "brain2"
	item_state = "unathi_brain"
	mmi_icon = 'icons/obj/species_organs/unathi.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/lungs/unathi
	species_type = /datum/species/unathi
	name = "unathi lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали унатху."
	ru_names = list(
		NOMINATIVE = "лёгкие унатха",
		GENITIVE = "лёгких унатха",
		DATIVE = "лёгким унатха",
		ACCUSATIVE = "лёгкие унатха",
		INSTRUMENTAL = "лёгкими унатха",
		PREPOSITIONAL = "лёгких унатха"
	)
	icon = 'icons/obj/species_organs/unathi.dmi'
	item_state = "unathi_lungs"

/obj/item/organ/internal/kidneys/unathi
	species_type = /datum/species/unathi
	name = "unathi kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали унатху."
	ru_names = list(
		NOMINATIVE = "почки унатха",
		GENITIVE = "почек унатха",
		DATIVE = "почкам унатха",
		ACCUSATIVE = "почки унатха",
		INSTRUMENTAL = "почками унатха",
		PREPOSITIONAL = "почках унатха"
	)
	icon = 'icons/obj/species_organs/unathi.dmi'
	item_state = "unathi_kidneys"

/obj/item/organ/external/tail/unathi
	species_type = /datum/species/unathi
	name = "unathi tail"
	desc = "Хвост. Этот принадлежал унатху."
	ru_names = list(
		NOMINATIVE = "хвост унатха",
		GENITIVE = "хвоста унатха",
		DATIVE = "хвосту унатха",
		ACCUSATIVE = "хвост унатха",
		INSTRUMENTAL = "хвостом унатха",
		PREPOSITIONAL = "хвосте унатха"
	)
	icon_name = "sogtail_s"
	max_damage = 30
	min_broken_damage = 20

/obj/item/organ/internal/lungs/unathi/ash_walker
	name = "ash walker lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали пеплоходцу."
	ru_names = list(
		NOMINATIVE = "лёгкие пеплоходца",
		GENITIVE = "лёгких пеплоходца",
		DATIVE = "лёгким пеплоходца",
		ACCUSATIVE = "лёгкие пеплоходца",
		INSTRUMENTAL = "лёгкими пеплоходца",
		PREPOSITIONAL = "лёгких пеплоходца"
	)
	safe_oxygen_min = 8 // can breathe on lavaland

/obj/item/organ/internal/eyes/unathi/ash_walker
	name = "ash walker eyes"
	desc = "Парный орган, отвечающий за зрение - восприятие света и его трансформацию в видимое изображение. Эти принадлежали пеплоходцу."
	ru_names = list(
		NOMINATIVE = "глаза пеплоходца",
		GENITIVE = "глаз пеплоходца",
		DATIVE = "глазам пеплоходца",
		ACCUSATIVE = "глаза пеплоходца",
		INSTRUMENTAL = "глазами пеплоходца",
		PREPOSITIONAL = "глазах пеплоходца"
	)
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	see_in_dark = 3

/obj/item/organ/internal/eyes/unathi/ash_walker_shaman
	name = "ash walker shaman eyes"
	desc = "Парный орган, отвечающий за зрение - восприятие света и его трансформацию в видимое изображение. Эти принадлежали шаману пеплоходцев."
	ru_names = list(
		NOMINATIVE = "глаза шамана пеплоходцев",
		GENITIVE = "глаз шамана пеплоходцев",
		DATIVE = "глазам шамана пеплоходцев",
		ACCUSATIVE = "глаза шамана пеплоходцев",
		INSTRUMENTAL = "глазами шамана пеплоходцев",
		PREPOSITIONAL = "глазах шамана пеплоходцев"
	)
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/organ/internal/eyes/unathi/ash_walker_shaman/insert(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(target)

/obj/item/organ/internal/eyes/unathi/ash_walker_shaman/remove(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.remove_hud_from(target)
