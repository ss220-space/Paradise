/obj/item/organ/internal/liver/vox
	species_type = /datum/species/vox
	name = "vox liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Эта принадлежала воксу."
	ru_names = list(
		NOMINATIVE = "печень вокса",
		GENITIVE = "печени вокса",
		DATIVE = "печени вокса",
		ACCUSATIVE = "печень вокса",
		INSTRUMENTAL = "печенью вокса",
		PREPOSITIONAL = "печени вокса"
	)
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_liver"
	alcohol_intensity = 1.6
	sterile = TRUE

/obj/item/organ/internal/eyes/vox
	species_type = /datum/species/vox
	name = "vox eyeballs"
	desc = "Парный орган, отвечающий за зрение - восприятие света и его трансформацию в видимое изображение. Эти принадлежали воксу."
	ru_names = list(
		NOMINATIVE = "глаза вокса",
		GENITIVE = "глаз вокса",
		DATIVE = "глазам вокса",
		ACCUSATIVE = "глаза вокса",
		INSTRUMENTAL = "глазами вокса",
		PREPOSITIONAL = "глазах вокса"
	)
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_eyes"
	sterile = TRUE

/obj/item/organ/internal/ears/vox
	species_type = /datum/species/vox
	name = "vox ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали воксу."
	ru_names = list(
		NOMINATIVE = "уши вокса",
		GENITIVE = "ушей вокса",
		DATIVE = "ушам вокса",
		ACCUSATIVE = "уши вокса",
		INSTRUMENTAL = "ушами вокса",
		PREPOSITIONAL = "ушах вокса"
	)

/obj/item/organ/internal/heart/vox
	species_type = /datum/species/vox
	name = "vox heart"
	desc = "Орган, качающий кровь или её заменяющую субстанцию по организму гуманоида. Это принадлежало воксу."
	ru_names = list(
		NOMINATIVE = "сердце вокса",
		GENITIVE = "сердца вокса",
		DATIVE = "сердцу вокса",
		ACCUSATIVE = "сердце вокса",
		INSTRUMENTAL = "сердцем вокса",
		PREPOSITIONAL = "сердце вокса"
	)
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_heart-on"
	item_base = "vox_heart"
	sterile = TRUE

/obj/item/organ/internal/brain/vox
	species_type = /datum/species/vox
	name = "cortical stack"
	desc = "Двойной мозг, мозжечок которого является органическим, а кора представляется сложным электронным устройством. Фактически, именно здесь и находится разум вокса."
	ru_names = list(
		NOMINATIVE = "мозговой стек",
		GENITIVE = "мозгового стека",
		DATIVE = "мозговому стеку",
		ACCUSATIVE = "мозговой стек",
		INSTRUMENTAL = "мозговым стеком",
		PREPOSITIONAL = "мозговом стеке"
	)
	icon = 'icons/obj/species_organs/vox.dmi'
	icon_state = "cortical-stack"
	item_state = "vox_cortical-stack"
	mmi_icon = 'icons/obj/species_organs/vox.dmi'
	mmi_icon_state = "mmi_full"
	sterile = TRUE

/obj/item/organ/internal/kidneys/vox
	species_type = /datum/species/vox
	name = "vox kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали воксу."
	ru_names = list(
		NOMINATIVE = "почки вокса",
		GENITIVE = "почек вокса",
		DATIVE = "почкам вокса",
		ACCUSATIVE = "почки вокса",
		INSTRUMENTAL = "почками вокса",
		PREPOSITIONAL = "почках вокса"
	)
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_kidneys"
	sterile = TRUE

/obj/item/organ/internal/lungs/vox
	name = "vox lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали воксу."
	ru_names = list(
		NOMINATIVE = "лёгкие вокса",
		GENITIVE = "лёгких вокса",
		DATIVE = "лёгким вокса",
		ACCUSATIVE = "лёгкие вокса",
		INSTRUMENTAL = "лёгкими вокса",
		PREPOSITIONAL = "лёгких вокса"
	)
	icon = 'icons/obj/species_organs/vox.dmi'
	icon_state = "lungs"
	item_state = "vox_lungs"

	safe_oxygen_min = 0 //We don't breathe this
	safe_oxygen_max = 0.05 //This is toxic to us
	safe_nitro_min = 16 //We breathe THIS!
	oxy_damage_type = TOX //And it poisons us

/obj/item/organ/external/tail/vox
	species_type = /datum/species/vox
	name = "vox tail"
	desc = "Хвост. Этот принадлежал воксу."
	ru_names = list(
		NOMINATIVE = "хвост вокса",
		GENITIVE = "хвоста вокса",
		DATIVE = "хвосту вокса",
		ACCUSATIVE = "хвост вокса",
		INSTRUMENTAL = "хвостом вокса",
		PREPOSITIONAL = "хвосте вокса"
	)
	icon_name = "voxtail_s"
	max_damage = 25
	min_broken_damage = 20
