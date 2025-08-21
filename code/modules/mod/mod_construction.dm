/obj/item/mod/construction
	desc = "Деталь модсьюта, используемая при его строительстве. Вы можете установить это в оболочку модсьюта."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "rack_parts"

/obj/item/mod/construction/helmet
	name = "MOD helmet"
	desc = "Универсальный каркас шлема, используемый в создрании модсьютов. Бесполезен вне оболочки."
	icon_state = "helmet"

/obj/item/mod/construction/helmet/get_ru_names()
	return list(
		NOMINATIVE = "шлем для модсьюта",
		GENITIVE = "шлема для модсьюта",
		DATIVE = "шлему для модсьюта",
		ACCUSATIVE = "шлем для модсьюта",
		INSTRUMENTAL = "шлемом для модсьюта",
		PREPOSITIONAL = "шлеме для модсьюта"
	)

/obj/item/mod/construction/chestplate
	name = "MOD chestplate"
	desc = "Тяжелая металлическая бронепластина, используемая в создрании модсьютов. Бесполезна вне оболочки."
	icon_state = "chestplate"

/obj/item/mod/construction/chestplate/get_ru_names()
	return list(
		NOMINATIVE = "нагрудник для модсьюта",
		GENITIVE = "нагрудника для модсьюта",
		DATIVE = "нагруднику для модсьюта",
		ACCUSATIVE = "шлем для модсьюта",
		INSTRUMENTAL = "нагрудником для модсьюта",
		PREPOSITIONAL = "нагруднике для модсьюта"
	)

/obj/item/mod/construction/gauntlets
	name = "MOD gauntlets"
	desc = "Пара уродливых электрических перчаток, используемых в создании модсьютов. Бесполезны вне оболочки."
	icon_state = "gauntlets"

/obj/item/mod/construction/gauntlets/get_ru_names()
	return list(
		NOMINATIVE = "перчатки для модсьюта",
		GENITIVE = "перчаток для модсьюта",
		DATIVE = "перчаткам для модсьюта",
		ACCUSATIVE = "перчатки для модсьюта",
		INSTRUMENTAL = "перчатками для модсьюта",
		PREPOSITIONAL = "перчатках для модсьюта"
	)

/obj/item/mod/construction/boots
	name = "MOD boots"
	desc = "Пара электрических сапог, используемых в создании модсьютов. Бесполезны вне оболочки."
	icon_state = "boots"

/obj/item/mod/construction/boots/get_ru_names()
	return list(
		NOMINATIVE = "ботинки для модсьюта",
		GENITIVE = "ботинок для модсьюта",
		DATIVE = "ботинкам для модсьюта",
		ACCUSATIVE = "ботинки для модсьюта",
		INSTRUMENTAL = "ботинками для модсьюта",
		PREPOSITIONAL = "ботинках для модсьюта"
	)
