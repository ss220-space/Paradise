/obj/item/card/id/captains_spare
	name = "captain's spare ID"
	icon_state = "gold"
	item_state = "gold-id"
	assignment = JOB_TITLE_RU_CAPTAIN

/obj/item/card/id/captains_spare/get_ru_names()
	return list(
		NOMINATIVE = "запасная ID-карта Капитана",
		GENITIVE = "запасной ID-карты Капитана",
		DATIVE = "запасной ID-карте Капитана",
		ACCUSATIVE = "запасную ID-карту Капитана",
		INSTRUMENTAL = "запасной ID-картой Капитана",
		PREPOSITIONAL = "запасной ID-карте Капитана",
	)

/obj/item/card/id/captains_spare/Initialize(mapload)
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/card/id/silver
	desc = "Идентификационная карта персонала \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника. \
			Уникальная серебряная отделка подчёркивает высокий статус владельца."
	icon_state = "silver"
	item_state = "silver-id"

/obj/item/card/id/gold
	desc = "Идентификационная карта персонала \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника. \
			Уникальная золотая отделка подчёркивает власть и могущество владельца."
	icon_state = "gold"
	item_state = "gold-id"

/obj/item/card/id/gold/battle
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	access = list(ACCESS_CAPTAIN_REAL)

/obj/item/card/id/gold/battle/ComponentInitialize()
	AddElement(/datum/element/high_value_item)

/obj/item/card/id/gold/battle/Initialize(mapload)
	GLOB.poi_list += src
	. = ..()

/obj/item/card/id/gold/battle/Destroy()
	GLOB.poi_list -= src
	. = ..()

/obj/item/card/id/admin
	name = "admin ID card"
	desc = "Идентификационная карта для Администрации. Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника. \
			А ещё для плотного щитспауна."
	icon_state = "admin"
	item_state = "gold-id"
	assignment = "Магистр щитспауна"
	untrackable = 1

/obj/item/card/id/admin/get_ru_names()
	return list(
		NOMINATIVE = "ID-карта Администрации",
		GENITIVE = "ID-карты Администрации",
		DATIVE = "ID-карте Администрации",
		ACCUSATIVE = "ID-карту Администрации",
		INSTRUMENTAL = "ID-картой Администрации",
		PREPOSITIONAL = "ID-карте Администрации",
	)

/obj/item/card/id/admin/Initialize(mapload)
	access = get_absolutely_all_accesses()
	. = ..()
	
/obj/item/card/id/lifetime
	name = "Lifetime ID Card"
	desc = "Модифицированная ID-карта, которую выдают лишь тем людям, что посвятили свои жизни высшим интересам \"Нанотрейзен\". Она сияет голубым."
	icon_state = "lifetimeid"

/obj/item/card/id/library_owl
	name = "Slavka ID"
	assignment = "Сыч Вячеслав"
	access = list(ACCESS_LIBRARY)

/obj/item/card/id/punpun
	name = "Pun Pun ID"
	assignment = "Пун Пун"
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)
