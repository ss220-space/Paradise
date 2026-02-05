/datum/action/changeling/toggle_superstrength
	name = "Суперсила"
	desc = "Мобилизуем все ресурсы организма для временного усиления мускулатуры. Снижает синтез химикатов."
	helptext = "Увеличивает силу до сверхчеловеческого уровня, но снижает скорость восстановления химикатов на 50%."
	button_icon_state = "blood_swell"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 0

	/// Активна ли способность
	/// На сколько снижается синтез (0.5 = 50% от нормального)
	var/chem_reduction = 0.5
	/// Трейт для дополнительного усиления
	var/strength_trait = TRAIT_STRONG_MUSCLES
	/// Сохраняем исходный уровень силы (датум)
	var/datum/strength_level/backup_strength_level
	/// Сохраняем исходные очки силы
	var/backup_strength_points = 0
	var/backup_chem_recharge_rate = 0

/datum/action/changeling/toggle_superstrength/Remove(mob/user)
	if(active)
		deactivate(user)
	return ..()

/datum/action/changeling/toggle_superstrength/sting_action(mob/living/user)
	if(!iscarbon(user))
		return FALSE

	if(active)
		deactivate(user)
		to_chat(user, span_notice("Снижаем мышечную активность. Синтез химикатов восстановлен."))
	else
		activate(user)
		to_chat(user, span_notice("Мобилизуем ресурсы организма! Сила возрастает, но синтез химикатов замедляется."))

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]", "[active]"))
	return TRUE

/datum/action/changeling/toggle_superstrength/proc/activate(mob/living/carbon/user)
	if(!ishuman(user))
		to_chat(user, span_warning("Эта способность работает только в человеческой форме!"))
		return FALSE

	var/mob/living/carbon/human/human = user

	// Получаем компонент мышц
	var/datum/component/muscles/muscles = human.GetComponent(/datum/component/muscles)
	if(!muscles)
		// Если компонента нет, создаем его
		muscles = human.AddComponent(/datum/component/muscles)
		if(!muscles)
			to_chat(user, span_warning("Не удалось активировать суперсилу!"))
			return FALSE

	// Сохраняем текущий уровень силы и очки
	backup_strength_level = muscles.real_strength_level
	backup_strength_points = muscles.strength_points

	// Добавляем трейт для дополнительного усиления
	ADD_TRAIT(human, strength_trait, CHANGELING_TRAIT)

	// Устанавливаем сверхчеловеческую силу напрямую
	muscles.real_strength_level = new STRENGTH_LEVEL_SUPERHUMAN()
	muscles.strength_points = 0

	// Отправляем сигнал для обновления состояния (если нужно)
	SEND_SIGNAL(human, COMSIG_STRENGTH_LEVEL_UP, 5, CHANGELING_TRAIT)

	// Обновляем внешний вид
	human.update_body(TRUE)

// Применяем модификатор синтеза химикатов
	var/datum/antagonist/changeling/changeling = human.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		// Сохраняем исходную скорость синтеза
		backup_chem_recharge_rate = changeling.chem_recharge_rate

		// Устанавливаем новую скорость (уменьшаем на 50%)
		changeling.chem_recharge_rate = backup_chem_recharge_rate * chem_reduction

		// НЕ трогаем chem_recharge_slowdown, так как он может влиять иначе
		// changeling.chem_recharge_slowdown += chem_reduction // УБРАТЬ ЭТУ СТРОКУ

		// Отладочное сообщение
		to_chat(user, span_debug("Скорость синтеза: было [backup_chem_recharge_rate], стало [changeling.chem_recharge_rate]"))

	active = TRUE
	button_icon_state = "muscular_active"
	UpdateButtonIcon()

	// Визуальный эффект
	human.visible_message(
		span_warning("Мышцы [human] неестественно вздуваются!"),
		span_notice("Чувствую как сила переполняет каждую клетку моего тела!")
	)

	return TRUE

/datum/action/changeling/toggle_superstrength/proc/deactivate(mob/living/carbon/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human = user

	// Убираем трейт
	REMOVE_TRAIT(human, strength_trait, CHANGELING_TRAIT)

	// Получаем компонент мышц
	var/datum/component/muscles/muscles = human.GetComponent(/datum/component/muscles)
	if(muscles)
		// Если есть сохраненный уровень - восстанавливаем его
		if(backup_strength_level)
			muscles.real_strength_level = backup_strength_level
			muscles.strength_points = backup_strength_points
		else
			// Иначе устанавливаем стандартный уровень
			muscles.real_strength_level = new STRENGTH_LEVEL_DEFAULT()
			muscles.strength_points = 0

		// Обновляем внешний вид
		human.update_body(TRUE)


// Восстанавливаем нормальный синтез химикатов
	var/datum/antagonist/changeling/changeling = human.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		// Восстанавливаем исходную скорость синтеза
		changeling.chem_recharge_rate = backup_chem_recharge_rate

		// Сбрасываем slowdown, если его изменяли
		// changeling.chem_recharge_slowdown -= chem_reduction // УБРАТЬ ЭТУ СТРОКУ

		// Отладочное сообщение
		to_chat(user, span_debug("Скорость синтеза восстановлена: [changeling.chem_recharge_rate]"))

	active = FALSE
	button_icon_state = "blood_swell"
	UpdateButtonIcon()

	// Визуальный эффект
	human.visible_message(
		span_notice("Мышцы [human] возвращаются к нормальному состоянию."),
		span_notice("Мышечное напряжение спадает.")
	)

	return TRUE
