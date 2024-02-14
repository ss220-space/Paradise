#define CYBERSUN_DISCOUNT 0.5

/datum/affiliate/cybersun
	name = "Cybersun Industries"
	desc = "Вы - агент CyberSun Industries, очередная игрушка в руках корпорации. По принуждению или \n\
			из-за обещанных материальных благ вы согласились выполнить некоторые задания для неё. \n\
			Как вам стоит работать: наниматель не предоставил вам конкретных указаний, действуйте на свое усмотрение.\n\
			Особые условия: Корпорация предоставляет вам скидку на собственную продукцию - щедро, не так ли?;\n\
			Вам доступен специальный модуль улучшения, который предоставляет киборгу NT модули Киберсана. \n\
			Стандартные цели: выкрасть высокотехнологичную продукцию NT (ИИ / боевой мех / научные исследования), устранить цель, побег."
	cats_to_exclude = CATEGORY_IMPLANTS
	objectives = list(list(/datum/objective/steal = 50, /datum/objective/steal/ai = 50),
						/datum/objective/mecha_hijack,
						/datum/objective/download_data,
						/datum/objective/maroon,
						/datum/objective/escape,
						)

/datum/affiliate/cybersun/finalize_affiliate()
	. = ..()
	for(var/path in subtypesof(/datum/uplink_item/implants))
		var/datum/uplink_item/new_item = new path
		new_item.cost = round(new_item.cost * CYBERSUN_DISCOUNT)
		new_item.category_flag = NO_CATEGORY
		uplink.uplink_items.Add(new_item)

/obj/item/CIndy_patcher
	icon = 'icons/obj/module.dmi'
	icon_state = "syndicate_cyborg_upgrade"

#undef CYBERSUN_DISCOUNT
