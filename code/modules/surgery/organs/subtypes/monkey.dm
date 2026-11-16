/// Internal organs of monkeys and their lesser forms.
/obj/item/organ/internal/heart/monkey
	species_type = /datum/species/monkey
	species_restrictions = list(SPECIES_MONKEY, SPECIES_FARWA, SPECIES_WOLPIN, SPECIES_NEARA, SPECIES_STOK)
	name = "monkey heart"
	desc = "Орган, качающий кровь и обеспечивающий кровообращение. Это принадлежало обезьяне."
	item_state = "lesser_heart-on"
	icon_state = "lesser_heart-on"
	item_base = "lesser_heart"
	dead_icon = "lesser_heart-off"

/obj/item/organ/internal/heart/monkey/get_ru_names()
	return alist(
		NOMINATIVE = "сердце обезьяны",
		GENITIVE = "сердца обезьяны",
		DATIVE = "сердцу обезьяны",
		ACCUSATIVE = "сердце обезьяны",
		INSTRUMENTAL = "сердцем обезьяны",
		PREPOSITIONAL = "сердце обезьяны",
	)

/obj/item/organ/internal/heart/monkey/tajaran
	species_type = /datum/species/monkey/tajaran
	name = "farwa heart"
	desc = "Орган, качающий кровь и обеспечивающий кровообращение. Это принадлежало фарве."
	icon = 'icons/obj/species_organs/tajaran.dmi'

/obj/item/organ/internal/heart/monkey/tajaran/get_ru_names()
	return alist(
		NOMINATIVE = "сердце фарвы",
		GENITIVE = "сердца фарвы",
		DATIVE = "сердцу фарвы",
		ACCUSATIVE = "сердце фарвы",
		INSTRUMENTAL = "сердцем фарвы",
		PREPOSITIONAL = "сердце фарвы",
	)

/obj/item/organ/internal/heart/monkey/vulpkanin
	species_type = /datum/species/monkey/vulpkanin
	name = "wolpin heart"
	desc = "Орган, качающий кровь и обеспечивающий кровообращение. Это принадлежало вулпину."
	icon = 'icons/obj/species_organs/vulpkanin.dmi'

/obj/item/organ/internal/heart/monkey/vulpkanin/get_ru_names()
	return alist(
		NOMINATIVE = "сердце вульпина",
		GENITIVE = "сердца вульпина",
		DATIVE = "сердцу вульпина",
		ACCUSATIVE = "сердце вульпина",
		INSTRUMENTAL = "сердцем вульпина",
		PREPOSITIONAL = "сердце вульпина",
	)

/obj/item/organ/internal/heart/monkey/skrell
	species_type = /datum/species/monkey/skrell
	name = "neara heart"
	desc = "Орган, качающий кровь и обеспечивающий кровообращение. Это принадлежало нире."
	icon = 'icons/obj/species_organs/skrell.dmi'

/obj/item/organ/internal/heart/monkey/skrell/get_ru_names()
	return alist(
		NOMINATIVE = "сердце неары",
		GENITIVE = "сердца неары",
		DATIVE = "сердцу неары",
		ACCUSATIVE = "сердце неары",
		INSTRUMENTAL = "сердцем неары",
		PREPOSITIONAL = "сердце неары",
	)

/obj/item/organ/internal/heart/monkey/unathi
	species_type = /datum/species/monkey/unathi
	name = "stok heart"
	desc = "Орган, качающий кровь и обеспечивающий кровообращение. Это принадлежало стоку."
	icon = 'icons/obj/species_organs/unathi.dmi'

/obj/item/organ/internal/heart/monkey/unathi/get_ru_names()
	return alist(
		NOMINATIVE = "сердце стока",
		GENITIVE = "сердца стока",
		DATIVE = "сердцу стока",
		ACCUSATIVE = "сердце стока",
		INSTRUMENTAL = "сердцем стока",
		PREPOSITIONAL = "сердце стока",
	)
/obj/item/organ/internal/lungs/monkey
	species_type = /datum/species/monkey
	species_restrictions = list(SPECIES_MONKEY, SPECIES_FARWA, SPECIES_WOLPIN, SPECIES_NEARA, SPECIES_STOK)
	name = "monkey lungs"
	desc = "Парный орган, отвечающий за газообмен между средой и кровью. Это принадлежало обезьяне."
	item_state = "lesser_lungs"
	icon_state = "lesser_lungs"

/obj/item/organ/internal/lungs/monkey/get_ru_names()
	return alist(
		NOMINATIVE = "лёгкие обезьяны",
		GENITIVE = "лёгких обезьяны",
		DATIVE = "лёгким обезьяны",
		ACCUSATIVE = "лёгкие обезьяны",
		INSTRUMENTAL = "лёгкими обезьяны",
		PREPOSITIONAL = "лёгких обезьяны",
	)

/obj/item/organ/internal/lungs/monkey/tajaran
	species_type = /datum/species/monkey/tajaran
	name = "farwa lungs"
	desc = "Парный орган, отвечающий за газообмен между средой и кровью. Это принадлежало фарве."
	icon = 'icons/obj/species_organs/tajaran.dmi'

/obj/item/organ/internal/lungs/monkey/tajaran/get_ru_names()
	return alist(
		NOMINATIVE = "лёгкие фарвы",
		GENITIVE = "лёгких фарвы",
		DATIVE = "лёгким фарвы",
		ACCUSATIVE = "лёгкие фарвы",
		INSTRUMENTAL = "лёгкими фарвы",
		PREPOSITIONAL = "лёгких фарвы",
	)

/obj/item/organ/internal/lungs/monkey/vulpkanin
	species_type = /datum/species/monkey/vulpkanin
	name = "wolpin lungs"
	desc = "Парный орган, отвечающий за газообмен между средой и кровью. Это принадлежало вулпину."
	icon = 'icons/obj/species_organs/vulpkanin.dmi'

/obj/item/organ/internal/lungs/monkey/vulpkanin/get_ru_names()
	return alist(
		NOMINATIVE = "лёгкие вульпина",
		GENITIVE = "лёгких вульпина",
		DATIVE = "лёгким вульпина",
		ACCUSATIVE = "лёгкие вульпина",
		INSTRUMENTAL = "лёгкими вульпина",
		PREPOSITIONAL = "лёгких вульпина",
	)

/obj/item/organ/internal/lungs/monkey/skrell
	species_type = /datum/species/monkey/skrell
	name = "neara lungs"
	desc = "Парный орган, отвечающий за газообмен между средой и кровью. Это принадлежало нире."
	icon = 'icons/obj/species_organs/skrell.dmi'

/obj/item/organ/internal/lungs/monkey/skrell/get_ru_names()
	return alist(
		NOMINATIVE = "лёгкие неары",
		GENITIVE = "лёгких неары",
		DATIVE = "лёгким неары",
		ACCUSATIVE = "лёгкие неары",
		INSTRUMENTAL = "лёгкими неары",
		PREPOSITIONAL = "лёгких неары",
	)

/obj/item/organ/internal/lungs/monkey/unathi
	species_type = /datum/species/monkey/unathi
	name = "stok lungs"
	desc = "Парный орган, отвечающий за газообмен между средой и кровью. Это принадлежало стоку."
	icon = 'icons/obj/species_organs/unathi.dmi'

/obj/item/organ/internal/lungs/monkey/unathi/get_ru_names()
	return alist(
		NOMINATIVE = "лёгкие стока",
		GENITIVE = "лёгких стока",
		DATIVE = "лёгким стока",
		ACCUSATIVE = "лёгкие стока",
		INSTRUMENTAL = "лёгкими стока",
		PREPOSITIONAL = "лёгких стока",
	)
/obj/item/organ/internal/liver/monkey
	species_type = /datum/species/monkey
	species_restrictions = list(SPECIES_MONKEY, SPECIES_FARWA, SPECIES_WOLPIN, SPECIES_NEARA, SPECIES_STOK)
	name = "monkey liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Это принадлежало обезьяне."
	item_state = "lesser_liver"
	icon_state = "lesser_liver"
	alcohol_intensity = 2

/obj/item/organ/internal/liver/monkey/get_ru_names()
	return alist(
		NOMINATIVE = "печень обезьяны",
		GENITIVE = "печени обезьяны",
		DATIVE = "печени обезьяны",
		ACCUSATIVE = "печень обезьяны",
		INSTRUMENTAL = "печенью обезьяны",
		PREPOSITIONAL = "печени обезьяны",
	)

/obj/item/organ/internal/liver/monkey/tajaran
	species_type = /datum/species/monkey/tajaran
	name = "farwa liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Это принадлежало фарве."
	icon = 'icons/obj/species_organs/tajaran.dmi'

/obj/item/organ/internal/liver/monkey/tajaran/get_ru_names()
	return alist(
		NOMINATIVE = "печень фарвы",
		GENITIVE = "печени фарвы",
		DATIVE = "печени фарвы",
		ACCUSATIVE = "печень фарвы",
		INSTRUMENTAL = "печенью фарвы",
		PREPOSITIONAL = "печени фарвы",
	)

/obj/item/organ/internal/liver/monkey/vulpkanin
	species_type = /datum/species/monkey/vulpkanin
	name = "wolpin liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Это принадлежало вулпину."
	icon = 'icons/obj/species_organs/vulpkanin.dmi'

/obj/item/organ/internal/liver/monkey/vulpkanin/get_ru_names()
	return alist(
		NOMINATIVE = "печень вульпина",
		GENITIVE = "печени вульпина",
		DATIVE = "печени вульпина",
		ACCUSATIVE = "печень вульпина",
		INSTRUMENTAL = "печенью вульпина",
		PREPOSITIONAL = "печени вульпина",
	)

/obj/item/organ/internal/liver/monkey/skrell
	species_type = /datum/species/monkey/skrell
	name = "neara liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Это принадлежало нире."
	icon = 'icons/obj/species_organs/skrell.dmi'

/obj/item/organ/internal/liver/monkey/skrell/get_ru_names()
	return alist(
		NOMINATIVE = "печень неары",
		GENITIVE = "печени неары",
		DATIVE = "печени неары",
		ACCUSATIVE = "печень неары",
		INSTRUMENTAL = "печенью неары",
		PREPOSITIONAL = "печени неары",
	)

/obj/item/organ/internal/liver/monkey/unathi
	species_type = /datum/species/monkey/unathi
	name = "stok liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Это принадлежало стоку."
	icon = 'icons/obj/species_organs/unathi.dmi'

/obj/item/organ/internal/liver/monkey/unathi/get_ru_names()
	return alist(
		NOMINATIVE = "печень стока",
		GENITIVE = "печени стока",
		DATIVE = "печени стока",
		ACCUSATIVE = "печень стока",
		INSTRUMENTAL = "печенью стока",
		PREPOSITIONAL = "печени стока",
	)
/obj/item/organ/internal/kidneys/monkey
	species_type = /datum/species/monkey
	species_restrictions = list(SPECIES_MONKEY, SPECIES_FARWA, SPECIES_WOLPIN, SPECIES_NEARA, SPECIES_STOK)
	name = "monkey kidneys"
	desc = "Парный орган, фильтрующий кровоток и выводящий из организма токсины и отходы. Это принадлежало обезьяне."
	item_state = "lesser_kidneys"
	icon_state = "lesser_kidneys"

/obj/item/organ/internal/kidneys/monkey/get_ru_names()
	return alist(
		NOMINATIVE = "почки обезьяны",
		GENITIVE = "почек обезьяны",
		DATIVE = "почкам обезьяны",
		ACCUSATIVE = "почки обезьяны",
		INSTRUMENTAL = "почками обезьяны",
		PREPOSITIONAL = "почках обезьяны",
	)

/obj/item/organ/internal/kidneys/monkey/tajaran
	species_type = /datum/species/monkey/tajaran
	name = "farwa kidneys"
	desc = "Парный орган, фильтрующий кровоток и выводящий из организма токсины и отходы. Это принадлежало фарве."
	icon = 'icons/obj/species_organs/tajaran.dmi'

/obj/item/organ/internal/kidneys/monkey/tajaran/get_ru_names()
	return alist(
		NOMINATIVE = "почки фарвы",
		GENITIVE = "почек фарвы",
		DATIVE = "почкам фарвы",
		ACCUSATIVE = "почки фарвы",
		INSTRUMENTAL = "почками фарвы",
		PREPOSITIONAL = "почках фарвы",
	)

/obj/item/organ/internal/kidneys/monkey/vulpkanin
	species_type = /datum/species/monkey/vulpkanin
	name = "wolpin kidneys"
	desc = "Парный орган, фильтрующий кровоток и выводящий из организма токсины и отходы. Это принадлежало вулпину."
	icon = 'icons/obj/species_organs/vulpkanin.dmi'

/obj/item/organ/internal/kidneys/monkey/vulpkanin/get_ru_names()
	return alist(
		NOMINATIVE = "почки вульпина",
		GENITIVE = "почек вульпина",
		DATIVE = "почкам вульпина",
		ACCUSATIVE = "почки вульпина",
		INSTRUMENTAL = "почками вульпина",
		PREPOSITIONAL = "почках вульпина",
	)

/obj/item/organ/internal/kidneys/monkey/skrell
	species_type = /datum/species/monkey/skrell
	name = "neara kidneys"
	desc = "Парный орган, фильтрующий кровоток и выводящий из организма токсины и отходы. Это принадлежало нире."
	icon = 'icons/obj/species_organs/skrell.dmi'

/obj/item/organ/internal/kidneys/monkey/skrell/get_ru_names()
	return alist(
		NOMINATIVE = "почки неары",
		GENITIVE = "почек неары",
		DATIVE = "почкам неары",
		ACCUSATIVE = "почки неары",
		INSTRUMENTAL = "почками неары",
		PREPOSITIONAL = "почках неары",
	)

/obj/item/organ/internal/kidneys/monkey/unathi
	species_type = /datum/species/monkey/unathi
	name = "stok kidneys"
	desc = "Парный орган, фильтрующий кровоток и выводящий из организма токсины и отходы. Это принадлежало стоку."
	icon = 'icons/obj/species_organs/unathi.dmi'

/obj/item/organ/internal/kidneys/monkey/unathi/get_ru_names()
	return alist(
		NOMINATIVE = "почки стока",
		GENITIVE = "почек стока",
		DATIVE = "почкам стока",
		ACCUSATIVE = "почки стока",
		INSTRUMENTAL = "почками стока",
		PREPOSITIONAL = "почках стока",
	)
/obj/item/organ/internal/brain/monkey
	species_type = /datum/species/monkey
	species_restrictions = list(SPECIES_MONKEY, SPECIES_FARWA, SPECIES_WOLPIN, SPECIES_NEARA, SPECIES_STOK)
	name = "monkey brain"
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Это принадлежало обезьяне."
	item_state = "lesser_brain2"
	icon_state = "lesser_brain2"

/obj/item/organ/internal/brain/monkey/get_ru_names()
	return alist(
		NOMINATIVE = "мозг обезьяны",
		GENITIVE = "мозга обезьяны",
		DATIVE = "мозгу обезьяны",
		ACCUSATIVE = "мозг обезьяны",
		INSTRUMENTAL = "мозгом обезьяны",
		PREPOSITIONAL = "мозге обезьяны",
	)

/obj/item/organ/internal/brain/monkey/tajaran
	species_type = /datum/species/monkey/tajaran
	name = "farwa brain"
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Это принадлежало фарве."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	mmi_icon = 'icons/obj/species_organs/tajaran.dmi'

/obj/item/organ/internal/brain/monkey/tajaran/get_ru_names()
	return alist(
		NOMINATIVE = "мозг фарвы",
		GENITIVE = "мозга фарвы",
		DATIVE = "мозгу фарвы",
		ACCUSATIVE = "мозг фарвы",
		INSTRUMENTAL = "мозгом фарвы",
		PREPOSITIONAL = "мозге фарвы",
	)

/obj/item/organ/internal/brain/monkey/vulpkanin
	species_type = /datum/species/monkey/vulpkanin
	name = "wolpin brain"
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Это принадлежало вулпину."
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	mmi_icon = 'icons/obj/species_organs/vulpkanin.dmi'

/obj/item/organ/internal/brain/monkey/vulpkanin/get_ru_names()
	return alist(
		NOMINATIVE = "мозг вульпина",
		GENITIVE = "мозга вульпина",
		DATIVE = "мозгу вульпина",
		ACCUSATIVE = "мозг вульпина",
		INSTRUMENTAL = "мозгом вульпина",
		PREPOSITIONAL = "мозге вульпина",
	)

/obj/item/organ/internal/brain/monkey/skrell
	species_type = /datum/species/monkey/skrell
	name = "neara brain"
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Это принадлежало нире."
	icon = 'icons/obj/species_organs/skrell.dmi'
	mmi_icon = 'icons/obj/species_organs/skrell.dmi'

/obj/item/organ/internal/brain/monkey/skrell/get_ru_names()
	return alist(
		NOMINATIVE = "мозг неары",
		GENITIVE = "мозга неары",
		DATIVE = "мозгу неары",
		ACCUSATIVE = "мозг неары",
		INSTRUMENTAL = "мозгом неары",
		PREPOSITIONAL = "мозге неары",
	)

/obj/item/organ/internal/brain/monkey/unathi
	species_type = /datum/species/monkey/unathi
	name = "stok brain"
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Это принадлежало стоку."
	icon = 'icons/obj/species_organs/unathi.dmi'
	mmi_icon = 'icons/obj/species_organs/unathi.dmi'

/obj/item/organ/internal/brain/monkey/unathi/get_ru_names()
	return alist(
		NOMINATIVE = "мозг стока",
		GENITIVE = "мозга стока",
		DATIVE = "мозгу стока",
		ACCUSATIVE = "мозг стока",
		INSTRUMENTAL = "мозгом стока",
		PREPOSITIONAL = "мозге стока",
	)

/obj/item/organ/internal/eyes/monkey
	species_type = /datum/species/monkey
	species_restrictions = list(SPECIES_MONKEY, SPECIES_FARWA, SPECIES_WOLPIN, SPECIES_NEARA, SPECIES_STOK)
	name = "monkey eyeballs"
	desc = "Парный орган, отвечающий за зрение и его обработку мозгом. Это принадлежало обезьяне."
	item_state = "lesser_eyes"
	icon_state = "lesser_eyes"

/obj/item/organ/internal/eyes/monkey/get_ru_names()
	return alist(
		NOMINATIVE = "глаза обезьяны",
		GENITIVE = "глаз обезьяны",
		DATIVE = "глазам обезьяны",
		ACCUSATIVE = "глаза обезьяны",
		INSTRUMENTAL = "глазами обезьяны",
		PREPOSITIONAL = "глазах обезьяны",
	)

/obj/item/organ/internal/eyes/monkey/tajaran
	species_type = /datum/species/monkey/tajaran
	name = "farwa eyeballs"
	desc = "Парный орган, отвечающий за зрение — восприятие света и его трансформацию в видимое изображение. Эти принадлежали фарве."
	icon = 'icons/obj/species_organs/tajaran.dmi'
	colourmatrix = MATRIX_TAJ_CBLIND
	replace_colours = TRITANOPIA_COLOR_REPLACE

/obj/item/organ/internal/eyes/monkey/tajaran/get_ru_names()
	return alist(
		NOMINATIVE = "глаза фарвы",
		GENITIVE = "глаз фарвы",
		DATIVE = "глазам фарвы",
		ACCUSATIVE = "глаза фарвы",
		INSTRUMENTAL = "глазами фарвы",
		PREPOSITIONAL = "глазах фарвы",
	)

/obj/item/organ/internal/eyes/monkey/vulpkanin
	species_type = /datum/species/monkey/vulpkanin
	name = "wolpin eyeballs"
	desc = "Парный орган, отвечающий за зрение — восприятие света и его трансформацию в видимое изображение. Эти принадлежали вульпину."
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	colourmatrix = MATRIX_VULP_CBLIND
	replace_colours = PROTANOPIA_COLOR_REPLACE

/obj/item/organ/internal/eyes/monkey/vulpkanin/get_ru_names()
	return alist(
		NOMINATIVE = "глаза вульпина",
		GENITIVE = "глаз вульпина",
		DATIVE = "глазам вульпина",
		ACCUSATIVE = "глаза вульпина",
		INSTRUMENTAL = "глазами вульпина",
		PREPOSITIONAL = "глазах вульпина",
	)

/obj/item/organ/internal/eyes/monkey/skrell
	species_type = /datum/species/monkey/skrell
	name = "neara eyeballs"
	desc = "Парный орган, отвечающий за зрение и его обработку мозгом. Это принадлежало нире."
	icon = 'icons/obj/species_organs/skrell.dmi'

/obj/item/organ/internal/eyes/monkey/skrell/get_ru_names()
	return alist(
		NOMINATIVE = "глаза неары",
		GENITIVE = "глаз неары",
		DATIVE = "глазам неары",
		ACCUSATIVE = "глаза неары",
		INSTRUMENTAL = "глазами неары",
		PREPOSITIONAL = "глазах неары",
	)

/obj/item/organ/internal/eyes/monkey/unathi
	species_type = /datum/species/monkey/unathi
	name = "stok eyeballs"
	desc = "Парный орган, отвечающий за зрение и его обработку мозгом. Это принадлежало стоку."
	icon = 'icons/obj/species_organs/unathi.dmi'

/obj/item/organ/internal/eyes/monkey/unathi/get_ru_names()
	return alist(
		NOMINATIVE = "глаза стока",
		GENITIVE = "глаз стока",
		DATIVE = "глазам стока",
		ACCUSATIVE = "глаза стока",
		INSTRUMENTAL = "глазами стока",
		PREPOSITIONAL = "глазах стока",
	)
/obj/item/organ/internal/ears/monkey
	species_type = /datum/species/monkey
	species_restrictions = list(SPECIES_MONKEY, SPECIES_FARWA, SPECIES_WOLPIN, SPECIES_NEARA, SPECIES_STOK)
	name = "monkey ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали обезьяне."

/obj/item/organ/internal/ears/monkey/get_ru_names()
	return alist(
		NOMINATIVE = "уши обезьяны",
		GENITIVE = "ушей обезьяны",
		DATIVE = "ушам обезьяны",
		ACCUSATIVE = "уши обезьяны",
		INSTRUMENTAL = "ушами обезьяны",
		PREPOSITIONAL = "ушах обезьяны",
	)

/obj/item/organ/internal/ears/monkey/tajaran
	species_type = /datum/species/monkey/tajaran
	name = "farwa ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали фарве."

/obj/item/organ/internal/ears/monkey/tajaran/get_ru_names()
	return alist(
		NOMINATIVE = "уши фарвы",
		GENITIVE = "ушей фарвы",
		DATIVE = "ушам фарвы",
		ACCUSATIVE = "уши фарвы",
		INSTRUMENTAL = "ушами фарвы",
		PREPOSITIONAL = "ушах фарвы",
	)

/obj/item/organ/internal/ears/monkey/vulpkanin
	species_type = /datum/species/monkey/vulpkanin
	name = "wolpin ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали вулпину."

/obj/item/organ/internal/ears/monkey/vulpkanin/get_ru_names()
	return alist(
		NOMINATIVE = "уши вульпина",
		GENITIVE = "ушей вульпина",
		DATIVE = "ушам вульпина",
		ACCUSATIVE = "уши вульпина",
		INSTRUMENTAL = "ушами вульпина",
		PREPOSITIONAL = "ушах вульпина",
	)

/obj/item/organ/internal/ears/monkey/skrell
	species_type = /datum/species/monkey/skrell
	name = "neara ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали нире."

/obj/item/organ/internal/ears/monkey/skrell/get_ru_names()
	return alist(
		NOMINATIVE = "уши неары",
		GENITIVE = "ушей неары",
		DATIVE = "ушам неары",
		ACCUSATIVE = "уши неары",
		INSTRUMENTAL = "ушами неары",
		PREPOSITIONAL = "ушах неары",
	)

/obj/item/organ/internal/ears/monkey/unathi
	species_type = /datum/species/monkey/unathi
	name = "stok ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали стоку."

/obj/item/organ/internal/ears/monkey/unathi/get_ru_names()
	return alist(
		NOMINATIVE = "уши стока",
		GENITIVE = "ушей стока",
		DATIVE = "ушам стока",
		ACCUSATIVE = "уши стока",
		INSTRUMENTAL = "ушами стока",
		PREPOSITIONAL = "ушах стока",
	)

/obj/item/organ/internal/headpocket/monkey/skrell
	species_type = /datum/species/monkey/skrell
	species_restrictions = list(SPECIES_MONKEY, SPECIES_FARWA, SPECIES_WOLPIN, SPECIES_NEARA, SPECIES_STOK)
	name = "neara headpocket"
	desc = "Недоразвившееся мышечное образование на голове неары, которое можно использовать как место хранения небольших предметов."
	icon_state = "lesser_headpocket"

/obj/item/organ/internal/headpocket/monkey/skrell/get_ru_names()
	return alist(
		NOMINATIVE = "головной карман неары",
		GENITIVE = "головного кармана неары",
		DATIVE = "головному карману неары",
		ACCUSATIVE = "головной карман неары",
		INSTRUMENTAL = "головным карманом неары",
		PREPOSITIONAL = "головном кармане неары",
	)
