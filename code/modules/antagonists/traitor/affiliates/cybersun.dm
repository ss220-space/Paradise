/datum/affiliate/cybersun
	name = "Cybersun Industries"
	desc = "Вы - очередная игрушка в руках CyberSun Industries. По принуждению или \n\
			из-за обещаний материальных благ вы согласились выполнить некоторые задания для неё. \n\
			Как вам стоит работать: Нет особых предпочтений. \n\
			Особые условия: Словно насмешка над вами, вам предоставлена скидка на продукции вашего Нанимателя;\n\
			Вам доступен специальный модуль улучшения, что предоставляет киборгу НТ модули Киберсана. \n\
			Стандартные цели: Кража высокотехнологичной продукции NT (ИИ, боевые мехи, иные важные предметы),\n\
			устранение, кража технологий"
	cats_to_exclude = CATEGORY_DANGEROUS
	objectives = list(list(/datum/objective/steal = 50, /datum/objective/steal/ai = 50),
						/datum/objective/mecha_hijack,
						/datum/objective/download_data,
						/datum/objective/maroon,
						/datum/objective/escape,
						)

/obj/item/CIndy_patcher
	icon = 'icons/obj/module.dmi'
	icon_state = "syndicate_cyborg_upgrade"
