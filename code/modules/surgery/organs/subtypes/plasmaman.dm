/obj/item/organ/internal/liver/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Эта принадлежала плазмолюду."
	ru_names = list(
		NOMINATIVE = "печень плазмолюда",
		GENITIVE = "печени плазмолюда",
		DATIVE = "печени плазмолюда",
		ACCUSATIVE = "печень плазмолюда",
		INSTRUMENTAL = "печенью плазмолюда",
		PREPOSITIONAL = "печени плазмолюда"
	)
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_liver"

/obj/item/organ/internal/eyes/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman eyeballs"
	desc = "Парный орган, отвечающий за зрение - восприятие света и его трансформацию в видимое изображение. Эти принадлежали плазмолюду."
	ru_names = list(
		NOMINATIVE = "глаза плазмолюда",
		GENITIVE = "глаз плазмолюда",
		DATIVE = "глазам плазмолюда",
		ACCUSATIVE = "глаза плазмолюда",
		INSTRUMENTAL = "глазами плазмолюда",
		PREPOSITIONAL = "глазах плазмолюда"
	)
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_eyes"

/obj/item/organ/internal/ears/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали плазмолюду."
	ru_names = list(
		NOMINATIVE = "уши плазмолюда",
		GENITIVE = "ушей плазмолюда",
		DATIVE = "ушам плазмолюда",
		ACCUSATIVE = "уши плазмолюда",
		INSTRUMENTAL = "ушами плазмолюда",
		PREPOSITIONAL = "ушах плазмолюда"
	)

/obj/item/organ/internal/heart/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman heart"
	desc = "Орган, выполняющий роль катализатора в процессе выщелачивания плазмы из поступающих в организм газов. Это принадлежало плазмолюду."
	ru_names = list(
		NOMINATIVE = "сердце плазмолюда",
		GENITIVE = "сердца плазмолюда",
		DATIVE = "сердцу плазмолюда",
		ACCUSATIVE = "сердце плазмолюда",
		INSTRUMENTAL = "сердцем плазмолюда",
		PREPOSITIONAL = "сердце плазмолюда"
	)
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_heart-on"
	item_base = "plasmaman_heart"

/obj/item/organ/internal/brain/plasmaman
	species_type = /datum/species/plasmaman
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Этот принадлежал плазмолюду."
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	icon_state = "brain2"
	item_state = "plasmaman_brain"
	mmi_icon = 'icons/obj/species_organs/plasmaman.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/kidneys/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали плазмолюду."
	ru_names = list(
		NOMINATIVE = "почки плазмолюда",
		GENITIVE = "почек плазмолюда",
		DATIVE = "почкам плазмолюда",
		ACCUSATIVE = "почки плазмолюда",
		INSTRUMENTAL = "почками плазмолюда",
		PREPOSITIONAL = "почках плазмолюда"
	)
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_kidneys"

/obj/item/organ/internal/lungs/plasmaman
	name = "plasma filter"
	desc = "Парный орган, отвечающий за фильтрацию плазмы из атмосферы внешней среды и её последующее выщелачивание в плазмоносные каналы. Эти принадлежали плазмолюду."
	ru_names = list(
		NOMINATIVE = "лёгкие плазмолюда",
		GENITIVE = "лёгких плазмолюда",
		DATIVE = "лёгким плазмолюда",
		ACCUSATIVE = "лёгкие плазмолюда",
		INSTRUMENTAL = "лёгкими плазмолюда",
		PREPOSITIONAL = "лёгких плазмолюда"
	)
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	icon_state = "lungs"
	item_state = "plasmaman_lungs"
	safe_oxygen_min = 0 //We don't breath this
	safe_toxins_min = 16 //We breathe THIS!
	safe_toxins_max = 0
