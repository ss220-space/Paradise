// Upgrade for ore satchels that make it collect ore in 3x3 area
/obj/item/mining_satchel_upgrade
	name = "mining satchel upgrade"
	desc = "Магнитное улучшение сумок для руды, позволяющее собирать руду в области 3 на 3 вокруг пользователя."
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

/obj/item/storage/bag/ore/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(istype(item, /obj/item/mining_satchel_upgrade) && aoe == 0)
		if(aoe)
			to_chat(user, span_notice("Сумка уже улучшена!"))
			return .

		add_fingerprint(user)
		to_chat(user, span_notice("Вы улучшили сумку для руды!"))
		playsound(user, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)
		aoe = TRUE
		desc += " Сумка улучшена."
		qdel(item)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return .
