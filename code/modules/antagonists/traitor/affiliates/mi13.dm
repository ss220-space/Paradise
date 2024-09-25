/datum/affiliate/mi13
	name = "MI13"
	desc = "Вы - элитный агент MI13, глаза и уши Синдиката. \n\
			Вы были внедрены в структуру NanoTrasen для поиска и получения секретных сведений; однако возможно, что придется испачкать перчатки в крови. \n\
			Как вам стоит работать: действуйте скрытно и осторожно, не вызывайте подозрений со стороны службы безопасности станции. \n\
			Если вы и решитесь пойти на открытую конфронтацию - не забудьте прибрать следы, сменить тройку на двойку не будет ошибкой. \n\
			Особые условия: агентам Корпорации не положено тяжелое и шумное снаряжение, однако набор \"Бонда\" уже ваш - не забудье забрать его."
	objectives = list(/datum/objective/steal/documents,
					list(/datum/objective/steal = 30, /datum/objective/maroon = 70),
					list(/datum/objective/steal = 30, /datum/objective/maroon/blueshield = 70), // blueshield has revolver and CQC.
					/datum/objective/steal,
					/datum/objective/escape
					)

/datum/affiliate/mi13/finalize_affiliate(datum/mind/owner)
	. = ..()
	uplink.uses = 20
	owner.has_antag_datum(/datum/antagonist/traitor).assign_exchange_role()
