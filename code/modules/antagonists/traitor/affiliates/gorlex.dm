/datum/affiliate/gorlex
	name = "Gorlex Maraduers"
	affil_info = list("Группировка специализирующаяся на налетах.",
					"Основная специализация - массовые убийства.",
					"Стандартные цели:",
					"Убить важных корпоративных крыс",
					"Убить рядовых корпоративных крыс",
					"Умереть героем")
	tgui_icon = "gorlex"
	slogan = "Давайте, вошли и вышли, приключение на 20 минут."
	hij_desc = "Вы - наёмный солдат Gorlex Marauders, засланный на станцию NT с особой целью:\n\
			активировать системы самоуничтожения станции. \n\
			Вам предоставлен обширный арсенал для закупки всего необходимого, однако ваши средства ограничены. \n\
			Вам установлен особый имплант, помогающий идентифицировать солдат Gorlex Maraduers - пользуйтесь этим;\n\
			Вам предоставлен код от системы самоуничтожения станции, а также система отслеживания диска ядерной аутентификации;\n\
			Каждый наёмник Gorlex Maraduers будет обязан помочь вам;\n\
			Возможны помехи от агентов других корпораций - действуйте на свое усмотрение."
	hij_obj = /datum/objective/nuclear/traitor
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
		if(/datum/species/human)
			return 1
		if(/datum/species/machine)
			return 0.2
		if(/datum/species/slime)
			return 0.2
	return 0

/datum/affiliate/gorlex/give_bonus_objectives(datum/mind/mind)
	if(!can_take_bonus_objectives)
		return

	var/datum/antagonist/traitor/traitor = mind?.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor)
		return

	traitor.add_objective(/datum/objective/assassinate)
	traitor.add_objective(/datum/objective/assassinate)
