
/// Новая способность
/datum/action/changeling/toggle_superstrength
	name = "Суперсила"
	desc = "Мобилизуем все ресурсы организма для временного усиления мускулатуры. Снижает синтез химикатов."
	helptext = "Увеличивает силу до сверхчеловеческого уровня, но снижает скорость восстановления химикатов на 50%."
	button_icon_state = "muscular"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 0

	/// Активна ли способность

	/// На сколько снижается синтез (0.5 = 50% от нормального)
	var/chem_reduction = 0.5
	/// Добавляем трейт для дополнительного усиления (если нужно)
	var/strength_trait = TRAIT_STRONG_MUSCLES

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
	// Добавляем трейт для дополнительного усиления (если в системе это нужно)
	ADD_TRAIT(user, strength_trait, CHANGELING_TRAIT)

	// Отправляем сигнал для увеличения уровня силы до 5 (сверхчеловек)
	// Второй параметр - уровень силы, третий - источник
	SEND_SIGNAL(user, COMSIG_STRENGTH_LEVEL_UP, 5, CHANGELING_TRAIT)

	// Применяем модификатор синтеза химикатов
	var/datum/antagonist/changeling/changeling = user.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		changeling.chem_recharge_rate *= chem_reduction
		changeling.chem_recharge_slowdown += chem_reduction

	active = TRUE
	button_icon_state = "muscular_active"
	UpdateButtonIcon()

	// Визуальный эффект
	user.visible_message(
		span_warning("Мышцы [user] неестественно вздуваются!"),
		span_notice("Чувствую как сила переполняет каждую клетку моего тела!")
	)


/datum/action/changeling/toggle_superstrength/proc/deactivate(mob/living/carbon/user)
	// Убираем трейт
	REMOVE_TRAIT(user, strength_trait, CHANGELING_TRAIT)

	// Отправляем сигнал для уменьшения уровня силы
	// Возвращаем уровень по умолчанию
	SEND_SIGNAL(user, COMSIG_REDUCE_STRENGTH, 5, CHANGELING_TRAIT)

	// Восстанавливаем нормальный синтез химикатов
	var/datum/antagonist/changeling/changeling = user.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		changeling.chem_recharge_rate /= chem_reduction
		changeling.chem_recharge_slowdown -= chem_reduction

	active = FALSE
	button_icon_state = "muscular"
	UpdateButtonIcon()

	// Визуальный эффект
	user.visible_message(
		span_notice("Мышцы [user] возвращаются к нормальному состоянию."),
		span_notice("Мышечное напряжение спадает.")
	)

	return TRUE

/// Обработчик при потере способности (например, при смерти или смене формы)
/datum/action/changeling/toggle_superstrength/proc/handle_owner_change(mob/user)
	if(active)
		deactivate(user)
