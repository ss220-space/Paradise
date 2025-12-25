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

/obj/item/storage/bag/ore/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mining_satchel_upgrade) && src.aoe == 0)
		add_fingerprint(user)
		to_chat(user, span_notice("Вы улучшили сумку для руды!"))
		playsound(user, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)
		src.aoe = TRUE
		src.desc += " Сумка улучшена."
		qdel(I)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	if(istype(I, /obj/item/mining_satchel_upgrade) && src.aoe == 1)
		to_chat(user, span_notice("Сумка уже улучшена!"))
		return ..()
	return ..()
