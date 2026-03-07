/datum/action/innate/borer
	background_icon_state = "bg_alien"
	var/cost

/datum/action/innate/borer/talk_to_host
	name = "Разговор с хозяином"
	desc = "Отправьте тихое сообщение своему хозяину."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_host/Activate()
	var/mob/living/simple_animal/borer/borer = owner
	borer.Communicate()

/datum/action/innate/borer/toggle_hide
	name = "Переключить Скрытность"
	desc = "Спрячьтесь под предметами. Включается или выключается."
	button_icon_state = "borer_hiding_false"

/datum/action/innate/borer/toggle_hide/Activate()
	var/mob/living/simple_animal/borer/borer = owner
	borer.hide_borer()
	button_icon_state = "borer_hiding_[borer.hiding ? "true" : "false"]"
	UpdateButtonIcon()

/datum/action/innate/borer/talk_to_borer
	name = "Пообщаться с Борером"
	desc = "Мысленно пообщайтесь со своим паразитом."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_borer/Activate()
	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()
	borer.host = owner
	borer.host.borer_comm()

/datum/action/innate/borer/talk_to_brain
	name = "Беседа с запертым разумом"
	desc = "Установите мысленную связь с порабощенным разумом вашего носителя."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_brain/Activate()
	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()
	borer.host = owner
	borer.host.trapped_mind_comm()

/datum/action/innate/borer/take_control
	name = "Захватить контроль"
	desc = "Установите полную связь с мозгом вашего хозяина."
	button_icon_state = "borer_brain"

/datum/action/innate/borer/take_control/Activate()
	var/mob/living/simple_animal/borer/borer = owner
	borer.bond_brain()

/datum/action/innate/borer/give_back_control
	name = "Отдать контроль"
	desc = "Отдать контроль своему хозяину."
	button_icon_state = "borer_leave"

/datum/action/innate/borer/give_back_control/Activate()
	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()
	borer.host = owner
	borer.host.release_control()

/datum/action/innate/borer/leave_body
	name = "Оставить носителя"
	desc = "Оставьте своего хозяина одного."
	button_icon_state = "borer_leave"

/datum/action/innate/borer/leave_body/Activate()
	var/mob/living/simple_animal/borer/borer = owner
	borer.release_host()

/datum/action/innate/borer/make_chems
	name = "Выделить химикаты"
	desc = "Введите в кровь хозяина химические вещества.."
	button_icon_state = "fleshmend"

/datum/action/innate/borer/make_chems/Activate()
	var/mob/living/simple_animal/borer/borer = owner
	borer.secrete_chemicals()

/datum/action/innate/borer/make_larvae
	name = "Оставить потомство"
	desc = "Создайте молодых червей."
	button_icon_state = "borer_reproduce"
	cost = 100

/datum/action/innate/borer/make_larvae/Activate()
	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()

	if(!borer)
		return

	if(borer.chemicals < cost)
		to_chat(borer.host, "Вам требуется [cost] химикат[DECL_CREDIT(cost)] для размножения!")
		return

	borer.chemicals -= cost

	borer.host.visible_message(
		span_danger("[borer.host] яростно блюёт, изрыгая рвотные массы вместе с извивающимся, похожим на слизня существом!"),
		span_danger("Ваш хозяин дёргается и вздрагивает, когда вы быстро выводите личинку из своего слизнеподобного тела.")
		)

	var/turf/turf = get_turf(borer.host)
	turf.add_vomit_floor()

	new /mob/living/simple_animal/borer(turf, borer.generation + 1)
	SEND_SIGNAL(borer, COMSIG_BORER_REPRODUCE, turf)

	return

/datum/action/innate/borer/torment
	name = "Агония"
	desc = "Накажите своего хозяина."
	button_icon_state = "blind"
	cost = 70

/datum/action/innate/borer/torment/Activate()
	var/mob/living/simple_animal/borer/borer = isborer(owner) ? owner : owner.has_brain_worms()
	var/mob/living/carbon/host = borer.host

	var/total_cost = cost - (borer.antag_datum.borer_rank.rank_ability_amplifier * 10)

	if(borer.chemicals < total_cost)
		to_chat(owner, "Вам требуется [total_cost] химикат[DECL_CREDIT(total_cost)] для вызова психической агонии!")
		return

	borer.chemicals -= total_cost

	to_chat(owner, span_danger("Вы посылаете карающий всплеск психической агонии в мозг своего носителя."))
	var/target = borer.host_brain ? borer.host_brain : host
	to_chat(target, span_danger(span_fontsize3("Ужасная, жгучая агония пронзает вас насквозь, \
			вырывая беззвучный крик из глубин вашего разума!")))

	if(borer.host_brain?.host_resisting)
		borer.host_brain.resist()
		return

	host.adjustStaminaLoss(host.get_max_stamina())

/datum/action/innate/borer/sneak_mode
	name = "Скрытный режим"
	desc = "прячет твой статус на медецинских ИЛС."
	button_icon_state = "chameleon_skin"

/datum/action/innate/borer/sneak_mode/Activate()
	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()
	borer.host = owner
	borer.host.sneak_mode()

/datum/action/innate/borer/focus_menu
	name = "Меню Фокусов"
	desc = "Усиль своего хозяина."
	button_icon_state = "human_form"

/datum/action/innate/borer/focus_menu/Activate()
	var/mob/living/simple_animal/borer/borer = owner
	borer.focus_menu()

/datum/action/innate/borer/mend_host
	name = "Лечение"
	desc = "лечит хозяина в течении 10 секунд"
	button_icon_state = "revive"
	cost = 100

/datum/action/innate/borer/mend_host/Activate()
	var/mob/living/simple_animal/borer/borer = isborer(owner) ? owner : owner.has_brain_worms()
	if(!borer || !borer.host)
		return
	var/mob/living/carbon/host = borer.host

	var/total_cost = cost - (borer.antag_datum.borer_rank.rank_ability_amplifier * 15)

	if(borer.chemicals < total_cost)
		to_chat(owner, "Вам требуется [total_cost] химикат[DECL_CREDIT(total_cost)] для запуска регенерации!")
		return

	if(host.reagents.has_reagent("sugar"))
		to_chat(borer, span_warning("Сахар в крови носителя"))
		return

	if(host.has_status_effect(/datum/status_effect/mend_host))
		to_chat(owner, "Ваш носитель уже регенерирует!")
		return

	borer.chemicals -= total_cost
	host.apply_status_effect(/datum/status_effect/mend_host)

	to_chat(owner, "Вы помогаете телу носителя регенерировать.")


/datum/action/innate/borer/parasitism
	name = "Паразитоидизм"
	desc = "Стоимость - 50, В течении 60 секунд вы будете получать очки эволюции и химикаты за счёт хозяина."
	button_icon_state = "fake_death"
	cost = 50

/datum/action/innate/borer/parasitism/Activate()
	var/mob/living/simple_animal/borer/borer = isborer(owner) ? owner : owner.has_brain_worms()
	if(!borer || !borer.host)
		to_chat(owner, "Вы не находитесь внутри носителя!")
		return

	var/mob/living/carbon/host = borer.host

	if(host.stat == DEAD)
		to_chat(owner, "Носитель мёртв!")
		return

	if(host.health <= HEALTH_THRESHOLD_CRIT)
		to_chat(owner, "Носитель слишком слаб для активации режима эволюции!")
		return

	if(host.reagents.has_reagent("sugar"))
		to_chat(borer, span_warning("Сахар в крови носителя"))
		return

	if(borer.chemicals < cost)
		to_chat(owner, "Вам требуется [cost] химикат[DECL_CREDIT(cost)] для активации режима эволюции!")
		return

	if(host.has_status_effect(/datum/status_effect/parasitism))
		to_chat(owner, "вы уже питаетесь")
		return

	borer.chemicals -= cost

	host.apply_status_effect(/datum/status_effect/parasitism)

	to_chat(owner, span_danger("Носитель будет ослаблен в ближайшее время."))
	to_chat(host, span_danger("Паразит питается за вас счёт. Вы чувствуете истощение."))
