/datum/affiliate/gorlex
	name = "Gorlex Maraduers"
	desc = "Вы - наёмный солдат Gorlex Marauders,\n\
			засланный на станцию NanoTrasen для создания хаоса за счёт ликвидации высокопоставленных\n\
			членов экипажа, помощи иным агентам и нанесения ущерба репутации NT. \n\
			Как вам стоит работать: вам выдено 20 минут на подготовку, далее\n\
			- начинайте устранять цели, чем больше хаоса - тем лучше; при наличии иных агентов можете кооперировать совместные действия.\n\
			После выполнения всех поставленных задач незамедлительно уничтожьте главную улику, указывающую на причастность Gorlex Maraduers. \n\
			Особые условия: вам установлен особый имплант, помогающий идентифицировать солдат Gorlex Maraduers - пользуйтесь этим.\n\
			Корпорация предоставляет вам возможность купить кроваво-красные скафандры со значительной скидкой.\n\
			Стандартные цели: Убивать важных корпоративных крыс, убивать рядовых корпоративных крыс, умереть героем."
	tgui_icon = "gorlex"
	hij_desc = "Вы - наёмный солдат Gorlex Marauders, засланный на станцию NT с особой целью:\n\
			активировать системы самоуничтожения станции. \n\
			Вам предоставлен обширный арсенал для закупки всего необходимого, однако ваши средства ограничены. \n\
			Вам установлен особый имплант, помогающий идентифицировать солдат Gorlex Maraduers - пользуйтесь этим;\n\
			Вам предоставлен код от системы самоуничтожения станции, а также система отслеживания диска ядерной аутентификации;\n\
			Каждый наёмник Gorlex Maraduers будет обязан помочь вам;\n\
			Возможны помехи от агентов других корпораций - действуйте на свое усмотрение."
	objectives = list(/datum/objective/assassinate/headofstaff,
						/datum/objective/assassinate/headofstaff,
						/datum/objective/assassinate/procedure,
						list(/datum/objective/assassinate = 85, /datum/objective/destroy = 15),
						/datum/objective/assassinate,
						/datum/objective/die
						)
	can_take_bonus_objectives = FALSE

/datum/affiliate/gorlex/finalize_affiliate(datum/mind/owner)
	. = ..()
	add_discount_item(/datum/uplink_item/device_tools/stims, 0.7)
	add_discount_item(/datum/uplink_item/suits/hardsuit, 0.75)

	var/datum/atom_hud/antag/gorlhud = GLOB.huds[ANTAG_HUD_AFFIL_GORLEX]
	gorlhud.join_hud(owner.current)
	set_antag_hud(owner.current, "hudaffilgorlex")

/datum/affiliate/gorlex/get_weight(mob/living/carbon/human/H)
	switch (H.dna.species.type)
		if (/datum/species/human)
			return 1
		if (/datum/species/machine)
			return 0.2
		if (/datum/species/slime)
			return 0.2
	return 0

/datum/affiliate/gorlex/give_bonus_objectives(datum/mind/mind)
	if (!can_take_bonus_objectives)
		return
	var/datum/antagonist/traitor/traitor = mind?.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor)
		return
	traitor.add_objective(new /datum/objective/assassinate)
	traitor.add_objective(new /datum/objective/assassinate)
