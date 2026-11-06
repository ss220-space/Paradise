// Upgrade for ore satchels that make it collect ore in 3x3 area
/obj/item/mining_satchel_upgrade
	name = "mining satchel upgrade"
	desc = "Магнитное улучшение сумок для руды, позволяющее собирать руду в области 3 на 3 вокруг пользователя."
	icon = 'icons/obj/mining_satchel_upgrade.dmi'
	icon_state = "mining_upgrade0"
	origin_tech = "materials=3;engineering=2"
	w_class = WEIGHT_CLASS_TINY

/obj/item/mining_satchel_upgrade/get_ru_names()
	return alist(
		NOMINATIVE = "магнитное улучшение сумок для руды",
		GENITIVE = "магнитного улучшения сумок для руды",
		DATIVE = "магнитному улучшению сумок для руды",
		ACCUSATIVE = "магнитное улучшение сумок для руды",
		INSTRUMENTAL = "магнитным улучшением сумок для руды",
		PREPOSITIONAL = "магнитном улучшении сумок для руды",
	)

/obj/item/mining_satchel_upgrade/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .

	if(!istype(interacting_with, /obj/item/storage/bag/ore))
		to_chat(user, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] можно крепить только на сумки для руды!"))
		return ITEM_INTERACT_FAILURE

	var/obj/item/storage/bag/ore/ore_bag = interacting_with
	if(ore_bag.aoe)
		to_chat(user, span_notice("[DECLENT_RU_CAP(ore_bag, NOMINATIVE)] уже улучшена!"))
		return ITEM_INTERACT_FAILURE

	add_fingerprint(user)
	to_chat(user, span_notice("Вы улучшили [ore_bag.declent_ru(ACCUSATIVE)] рудным магнитом!"))
	playsound(user, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)
	ore_bag.aoe = TRUE
	qdel(src)
	return ITEM_INTERACT_SUCCESS
