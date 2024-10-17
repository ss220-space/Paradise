/datum/affiliate/hematogenic
	name = AFFIL_HEMATOGENIC
	affil_info = list("Фармацевтическая мега корпорация подозревающаяся в связях с вампирами.",
					"Стандартные цели:",
					"Собрать образцы крови полной различной духовной энергии",
					"Украсть передовые медицинские технологии",
					"Сделать одного из членов экипажа вампиром",
					"Украсть что-то ценное или убить кого-то")
	slogan = "Мы с тобой одной крови."
	hij_desc = "Вы - опытный наёмный агент Hematogenic Industries.\n\
				Основатель Hematogenic Industries высоко оценил ваши прошлые заслуги, а потому, дал вам возможность купить инжектор наполненный его собственной кровью... \n\
				Вас предупредили, что после инъекции вы будете продолжительное время испытывать сильный голод. \n\
				Ваша задача - утолить этот голод.\n\
				Возможны помехи от агентов других корпораций - действуйте на свое усмотрение."
	hij_obj = /datum/objective/blood/ascend
	normal_objectives = 2
	objectives = list(/datum/objective/harvest_blood,
					/datum/objective/steal/hypo_or_defib,
					list(/datum/objective/steal = 50, /datum/objective/steal/hypo_or_defib = 30, /datum/objective/new_mini_vampire = 20),
					/datum/objective/escape
					)

/datum/affiliate/hematogenic/get_weight(mob/living/carbon/human/H)
	return (!ismachineperson(H) && H.mind?.assigned_role != JOB_TITLE_CHAPLAIN) * 2

/datum/affiliate/hematogenic/give_default_objective()
	if(prob(60))
		if(prob(5))
			traitor.add_objective(/datum/objective/debrain)

		else if(prob(10))
			traitor.add_objective(/datum/objective/protect)

		else
			traitor.add_objective(/datum/objective/maroon)

	else
		traitor.add_objective(/datum/objective/steal)
