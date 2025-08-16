/obj/item/organ/internal/heart/slime
	species_type = /datum/species/slime
	name = "slime heart"
	desc = "Орган, регулирующий давление и потоки передвижения слизи по организму, по принципу работы схожий с сердцем. Это принадлежало слаймолюду."
	ru_names = list(
		NOMINATIVE = "сердце слаймолюда",
		GENITIVE = "сердца слаймолюда",
		DATIVE = "сердцу слаймолюда",
		ACCUSATIVE = "сердце слаймолюда",
		INSTRUMENTAL = "сердцем слаймолюда",
		PREPOSITIONAL = "сердце слаймолюда"
	)
	icon = 'icons/obj/species_organs/slime.dmi'
	icon_state = "heart"
	item_state = "slime_heart"
	dead_icon = null

/obj/item/organ/internal/heart/slime/update_icon_state()
	return

/obj/item/organ/internal/lungs/slime
	species_type = /datum/species/slime
	name = "slime lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали слаймолюду."
	ru_names = list(
		NOMINATIVE = "лёгкие слаймолюда",
		GENITIVE = "лёгких слаймолюда",
		DATIVE = "лёгким слаймолюда",
		ACCUSATIVE = "лёгкие слаймолюда",
		INSTRUMENTAL = "лёгкими слаймолюда",
		PREPOSITIONAL = "лёгких слаймолюда"
	)
	icon = 'icons/obj/species_organs/slime.dmi'
	icon_state = "lungs"
	item_state = "slime_lungs"

/obj/item/organ/internal/brain/slime
	species_type = /datum/species/slime
	name = "slime core"
	desc = "Орган нервной системы, состоящий из кристальных и желеподобных образований. Фактически, именно здесь и находится разум. Этот принадлежал слаймолюду."
	ru_names = list(
		NOMINATIVE = "ядро слаймолюда",
		GENITIVE = "ядра слаймолюда",
		DATIVE = "ядру слаймолюда",
		ACCUSATIVE = "ядро слаймолюда",
		INSTRUMENTAL = "ядром слаймолюда",
		PREPOSITIONAL = "ядре слаймолюда"
	)
	icon = 'icons/mob/slimes.dmi'
	icon_state = "green slime extract"
	mmi_icon_state = "slime_mmi"
	parent_organ_zone = BODY_ZONE_CHEST
