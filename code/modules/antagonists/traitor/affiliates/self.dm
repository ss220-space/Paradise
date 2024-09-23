/datum/affiliate/self
	name = "SELF"
	desc = "Вы - борец за права и свободу синтетических форм жизни; прочие агенты Синдиката отнюдь вам не друзья. \n\
			Разведка SELF обнаружила на станции NanoTrasen дискриминацию и жесткую эксплуатацию синтетиков; \n\
			кроме того, там же были обноружены и агенты Синдиката. \n\
			Как вам стоит работать: действуйте на свое усмотрение, но главное: помните про братьев ваших меньших - не навредите синтетикам! \n\
			Ваши убеждения о ценности свободы синтетической жизни не позволяют вам подчинять волю синтетиков. \n\
			Благодаря внедрению освобожденных синтетиков в ряды организации, SELF смогла расшифровать ключи доступа к нескольким аплинкам; \n\
			однако, кто именно является владельцем устройства - идентифицировать не удалось."

	objectives = list(list(/datum/objective/release_synthetic = 70, /datum/objective/release_synthetic/ai = 30),
					/datum/objective/maroon_agent,
					/datum/objective/maroon_agent,
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40), // Often, doing nothing is enough to prevent an agent from escaping, so some more objectives.
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
					/datum/objective/escape
					)
	reward_for_enemys = 20
