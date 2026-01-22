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

/obj/item/card/id/lifetime
	name = "Lifetime ID Card"
	desc = "Модифицированная ID-карта, которую выдают лишь тем людям, что посвятили свои жизни высшим интересам Nanotrasen. Она сияет голубым."
	icon_state = "lifetimeid"
