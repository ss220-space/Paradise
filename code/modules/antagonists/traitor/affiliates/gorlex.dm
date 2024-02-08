/datum/affiliate/gorlex
	name = "Gorlex Maraduers"
	desc = "Вы - внешний агент Gorlex Marauders,\n\
			посланный на станцию для вызова хаоса за счет уничтожения высокопоставленных\n\
			членов экипажа для помощи иным агентам и нанесения ущерба репутации НТ. \n\
			Как вам стоит работать: Подготовка в течении получаса, далее\n\
			- открытое противостояния совмество с другими агентами (если они есть) и смертью в бою. \n\
			Особые условия: У вас установлен особый имплант, что позволяет видеть других агентов вашей организации;\n\
			Вы можете покупать кроваво-красные скафандры со значительной скидкой;\n\
			Вам недоступна вкладка Stealth \n\
			Стандартные цели: Убийство нескольких высокопоставленных членов экипажа, после - доблестная смерть."
	hij_desc = "Вы - внешний агент Gorlex Marauders, посланный на станцию с особой целью:\n\
			активация её системы самоуничтожения. \n\
			Как вам стоит работать: Подготовка в течении 40-60 минут и открытые сражения. \n\
			Особые условия: У вас установлен особый имплант, что позволяет видеть других агентов вашей организации;\n\
			Вам известен код от системы самоуничтожения станции;\n\
			Вам будет предоставлена система отслеживания диска ядерной аутенфикации;\n\
			Каждый агент вашей организации будет обязан помочь вам;\n\
			Другие агенты Синдиката могут и, скорее всего, будут пытаться помешать вам."
	cats_to_exclude = (CATEGORY_STEALTH_ITEMS|CATEGORY_STEALTH_WEAPONS)
	objectives = list(/datum/objective/assassinate/headofstaff,
						/datum/objective/assassinate/headofstaff,
						/datum/objective/assassinate/procedure,
						/datum/objective/die
						)
