// Upgrade for ore satchels that make it collect ore in 3x3 area
/obj/item/mining_satchel_upgrade
	desc = "Улучшение сумок для руды, позволяющее собирать руду в области 3x3"
	name = "mining satchel upgrade"
	icon = 'icons/obj/mining_satchel_upgrade.dmi' //НАЙТИ СПРАЙТЕРА И ПОПРОСИТЬ СПРАЙТ
	icon_state = "mining_upgrade0"
	origin_tech = "materials=3;engineering=2"
	w_class = WEIGHT_CLASS_TINY

/obj/item/mining_satchel_upgrade/get_ru_names()
	return list(
		NOMINATIVE = "улучшение сумок для руды",
		GENITIVE = "улучшения сумок для руды",
		DATIVE = "улучшению сумок для руды",
		ACCUSATIVE = "улучшение сумок для руды",
		INSTRUMENTAL = "улучшением сумок для руды",
		PREPOSITIONAL = "улучшении сумок для руды",
	)
