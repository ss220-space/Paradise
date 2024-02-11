/datum/affiliate/gorlex
	name = "Gorlex Maraduers"
	desc = "Вы - наёмный солдат Gorlex Marauders,\n\
			засланный на станцию NanoTrasen для создания хаоса за счёт ликвидации высокопоставленных\n\
			членов экипажа, помощи иным агентам и нанесения ущерба репутации NT. \n\
			Как вам стоит работать: вам выдело 30 минут на подготовку, далее\n\
			- начинайте устранять цели, чем больше хаоса - тем лучше; при наличии иных агентов можете кооперировать совместные действия.\n\
			После выполнения всех поставленных задач незамедлительно уничтожьте главную улику указывающую на причастность Gorlex Maraduers. \n\
			Особые условия: вам установлен особый имплант, помогающий идентифицировать солдат Gorlex Maraduers - пользуйтесь этим.\n\
			Корпорация предоставляет вам возможность купить кроваво-красные скафандры со значительной скидкой.\n\
			Стандартные цели: ликвидировать несколько высокопоставленных целей, самоликвидация."
	hij_desc = "Вы - наёмный солдат Gorlex Marauders, засланный на станцию NT с особой целью:\n\
			активировать системы самоуничтожения станции. \n\
			Как вам стоит работать: вам выделено 40-60 минут на подготовку и предоставлен обширный арсенал для закупки всего необходимого. \n\
			Особые условия: вам установлен особый имплант, помогающий идентифицировать солдат Gorlex Maraduers - пользуйтесь этим;\n\
			Вам предоставлен код от системы самоуничтожения станции, а также система отслеживания диска ядерной аутенфикации;\n\
			Каждый наёмник Gorlex Maraduers будет обязан помочь вам;\n\
			Возможны помехи от агентов других корпораций - действуейте на свое усмотрение."
	cats_to_exclude = (CATEGORY_STEALTH_ITEMS|CATEGORY_STEALTH_WEAPONS)
	objectives = list(/datum/objective/assassinate/headofstaff,
						/datum/objective/assassinate/headofstaff,
						/datum/objective/assassinate/procedure,
						/datum/objective/die
						)
