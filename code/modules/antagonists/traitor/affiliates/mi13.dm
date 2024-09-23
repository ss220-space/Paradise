/datum/affiliate/mi13
	name = "MI13"
	desc = "Вы - элитный агент MI13, глаза и уши Синдиката. \n\
			Вы были внедрены в труктуру NanoTrasen для поиска и получения секретных сведений; однако возможно, что придется испачкать перчатки в крови. \n\
			Как вам стоит работать: действуйте скрытно и осторожно, не вызывайте подозрений со стороны службы безопасности станции. \n\
			Если вы и решитесь пойти на открытую конфронтацию - не забудьте прибрать следы, сменить тройку на двойку не будет ошибкой. \n\
			Особые условия: агентам Корпорации не положено тяжелое и шумное снаряжение, однако набор \"Бонда\" уже ваш - не забудье забрать его."
	objectives = list(/datum/objective/steal/documents,
					list(/datum/objective/swap_docs = 80, /datum/objective/swap_docs/get_both = 20),
					list(/datum/objective/steal = 30, /datum/objective/maroon = 70),
					/datum/objective/steal,
					/datum/objective/steal,
					/datum/objective/escape
					)

/datum/affiliate/mi13/finalize_affiliate(datum/mind/owner)
	. = ..()
	uplink.uses = 50
