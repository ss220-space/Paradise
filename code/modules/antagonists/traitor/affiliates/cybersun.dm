/datum/affiliate/cybersun
	name = "Cybersun Industries"
	desc = "Вы - агент CyberSun Industries, очередная игрушка в руках корпорации. По принуждению или \n\
			из-за обещанных материальных благ вы согласились выполнить некоторые задания для неё. \n\
			Как вам стоит работать: наниматель не предоставил вам конкретных указаний, действуйте на свое усмотрение.\n\
			Особые условия: Корпорация предоставляет вам скидку на собственную продукцию - щедро, не так ли?;\n\
			Вам доступен специальный модуль улучшения, который предоставляет киборгу NT модули Киберсана. \n\
			Стандартные цели: выкрасть высокотехнологичную продукцию NT (ИИ / боевой мех / научные исследования), устранить цель, побег."
	objectives = list(list(/datum/objective/steal = 50, /datum/objective/steal/ai = 50),
						/datum/objective/mecha_hijack,
						/datum/objective/download_data,
						/datum/objective/maroon,
						/datum/objective/escape,
						)

/obj/item/CIndy_patcher
	icon = 'icons/obj/module.dmi'
	icon_state = "syndicate_cyborg_upgrade"
