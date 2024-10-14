#define CYBERSUN_DISCOUNT 0.8

/datum/affiliate/cybersun
	name = AFFIL_CYBERSUN
	affil_info = list("Одна из ведущих корпораций занимающихся передовыми исследованиями.",
					"Стандартные цели:",
					"Украсть технологии",
					"Украсть определенное количество ценных вещей",
					"Убить определенное количество членов экипажа",
					"Угнать мех или под",
					"Завербовать нового агента вколов ему модифицированный имплант \"Mindslave\".")
	slogan = "Сложно быть во всём лучшими, но у нас получается."
	hij_desc = "Вы - наёмный агент Cybersun Industries, засланный на станцию NT с особой целью:\n\
				Взломать искусственный интеллект станции специальным, предоставленным вам, устройством. \n\
				После взлома, искусственный интеллект попытается уничтожить станцию. \n\
				Ваша задача ему с этим помочь;\n\
				Ваше выживание опционально;\n\
				Возможны помехи от агентов других корпораций - действуйте на свое усмотрение."
	hij_obj = /datum/objective/make_ai_malf
	normal_objectives = 4
	objectives = list(list(/datum/objective/steal = 60, /datum/objective/steal/ai = 20, /datum/objective/new_mini_traitor = 20),
						/datum/objective/download_data,
//						/datum/objective/mecha_or_pod_hijack,
						/datum/objective/escape,
						)

/datum/affiliate/cybersun/finalize_affiliate()
	. = ..()
	for(var/path in subtypesof(/datum/uplink_item/implants))
		add_discount_item(path, CYBERSUN_DISCOUNT)
	add_discount_item(/datum/uplink_item/device_tools/hacked_module, 2/3)

/datum/affiliate/cybersun/give_default_objective()
	if(prob(40))
		if(length(active_ais()) && prob(100 / length(GLOB.player_list)))
			traitor.add_objective(/datum/objective/destroy)

		else if(prob(5))
			traitor.add_objective(/datum/objective/debrain)

		else if(prob(15))
			traitor.add_objective(/datum/objective/protect)

		else if (prob(5))
			traitor.add_objective(/datum/objective/mecha_or_pod_hijack)

		else
			traitor.add_objective(/datum/objective/maroon)

	else
		traitor.add_objective(/datum/objective/steal)

#undef CYBERSUN_DISCOUNT
