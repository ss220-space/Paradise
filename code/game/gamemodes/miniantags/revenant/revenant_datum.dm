/datum/antagonist/revenant
	name = "Revenant"
	roundend_category = "revenants"
	job_rank = SPECIAL_ROLE_REVENANT
	special_role = SPECIAL_ROLE_REVENANT
	wiki_page_name = "Revenant"
	russian_wiki_name = "Ревенант"
	antag_menu_name = "Ревенант"

/datum/antagonist/revenant/give_objectives()
	. = ..()
	var/list/objectives = list(
		/datum/objective/revenant_essence,
		/datum/objective/revenant_puresouls,
		/datum/objective/revenant_lamp,
	)
	add_objective(pick(objectives))
	add_objective(/datum/objective/revenantFluff)

/datum/antagonist/revenant/greet()
	var/list/messages = list()
	SEND_SOUND(owner.current, sound('sound/effects/ghost.ogg'))
	messages.Add(span_deadsay(span_fontsize3(span_bold("Вы — ревенант."))))
	messages.Add("<b>Ваш некогда обычный дух был наполнен чужеродной энергией и превращён в ревенанта.</b>")
	messages.Add("<b>Вы не мёртвы, не живы, а где-то посередине. Вы способны на ограниченное взаимодействие с обоими мирами.</b>")
	messages.Add("<b>Вы неуязвимы и невидимы для всех, кроме других призраков. Большинство способностей раскроют вас, сделав уязвимым.</b>")
	messages.Add("<b>Чтобы существовать, вы должны высасывать жизненную эссенцию из людей. Эта эссенции — ваш ресурс и здоровье, она питает все ваши способности.</b>")
	messages.Add("<b><i>Вы не помните ничего из своих прошлых жизней, а также не будете помнить ничего из этой после своей смерти.</i></b>")
	return messages

/datum/objective/revenant_essence
	needs_target = FALSE
	var/targetAmount = 100

/datum/objective/revenant_essence/New()
	targetAmount = rand(350,600)
	explanation_text = "Поглотите [targetAmount] единиц[DECL_U_Y_0(targetAmount)] эссенции у людей."
	..()

/datum/objective/revenant_essence/check_completion()
	var/total_essence = 0

	for(var/datum/mind/player in get_owners())
		if(!istype(player.current, /mob/living/simple_animal/revenant) || QDELETED(player.current))
			continue

		var/mob/living/simple_animal/revenant/revenant = player.current
		total_essence += revenant.essence_accumulated

	if(total_essence < targetAmount)
		return FALSE

	return TRUE

/datum/objective/revenant_puresouls
	needs_target = FALSE
	var/souls_needed = 0

/datum/objective/revenant_puresouls/New(text, datum/team/team_to_join)
	souls_needed = rand(2, 5)
	explanation_text = "Поглотите [souls_needed] чист[DECL_YU_YH_YH(souls_needed)] душ[DECL_U_Y_0(souls_needed)]"
	. = ..()

/datum/objective/revenant_puresouls/check_completion()
	var/total_souls = 0

	for(var/datum/mind/player in get_owners())
		if(!istype(player.current, /mob/living/simple_animal/revenant) || QDELETED(player.current))
			continue

		var/mob/living/simple_animal/revenant/revenant = player.current
		total_souls += revenant.perfectsouls

	if(total_souls < souls_needed)
		return FALSE

	return TRUE

/datum/objective/revenant_lamp
	needs_target = FALSE
	var/lamps_amount = 0

/datum/objective/revenant_lamp/New()
	lamps_amount = rand(1,3)
	explanation_text = "Создайте [lamps_amount] маяк[DECL_0_A_OV(lamps_amount)] души на станции. Маяки не должны быть уничтожены."
	..()

/datum/objective/revenant_lamp/check_completion()
	var/total_lamps = 0

	for(var/datum/mind/player in get_owners())
		if(!istype(player.current, /mob/living/simple_animal/revenant) || QDELETED(player.current))
			continue

		var/mob/living/simple_animal/revenant/revenant = player.current
		var/datum/action/cooldown/spell/aoe/revenant/soul_lamp/lamp_spell = locate() in revenant.mob_spell_list
		total_lamps += length(lamp_spell.spawned_lamps)

	if(total_lamps < lamps_amount)
		return FALSE

	return TRUE

/datum/objective/revenantFluff
	needs_target = FALSE
	antag_menu_name = "Задача ревенанта"

/datum/objective/revenantFluff/New()
	var/list/explanationTexts = list(
		"Помогайте существующим угрозам и усугубляйте их в критические моменты.", \
		"Вызовите как можно больше хаоса и гнева, не будучи убитыми.", \
		"Повредите и сделайте как можно большую часть станции разрушеной и непригодной для использования.", \
		"Отключите как можно больше машин и вызовите сбои в их работе.", \
		"Убедитесь, что любое святое оружие приведено в негодность.", \
		"Мешайте экипажу, пытаясь остаться незамеченным..", \
		"Сделайте экипаж как можно более несчастным.", \
		"Сделайте клоуна как можно более несчастным.", \
		"Сделайте капитана как можно более несчастным.", \
		"Сделайте ИИ как можно более несчастным.", \
		"Раздражайте тех, кто вас больше всего оскорбляет.", \
		"Шепчите шутки о призраках в головы людей.", \
		"Помогайте экипажу в критических ситуациях, но принимайте оплату в душах.", \
		"По возможности предотвращайте применение энергетического оружия."
	)
	explanation_text = pick(explanationTexts)
	..()

/datum/objective/revenantFluff/check_completion()
	return TRUE

