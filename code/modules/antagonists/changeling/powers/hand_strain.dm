// Определим константу для источника трейта генокрада
#define CHANGELING_HAND_STRAIN_TRAIT "changeling_hand_strain"

/datum/action/changeling/hand_strain
	name = "Перенапряжение руки"
	desc = "Позволяет намертво вцепиться в предмет в активной руке."
	helptext = "Позволяет прикрепить предмет в активной руке, предотвращая его выпадение. Повторное использование отпускает предмет."
	button_icon_state = "limb_throw"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 5
	req_stat = UNCONSCIOUS

	/// Текущий прикрепленный предмет
	var/obj/item/attached_item = null
	/// Флаг для предотвращения рекурсии
	var/releasing = FALSE

/datum/action/changeling/hand_strain/Remove(mob/user)
	release_item()
	. = ..()

/datum/action/changeling/hand_strain/sting_action(mob/living/carbon/user)
	. = ..()
	if(!.)
		return FALSE

	// Проверяем активную руку
	var/obj/item/held_item
	if(user.hand) // 1 - левая рука, 0 - правая рука
		held_item = user.l_hand
	else
		held_item = user.r_hand

	if(!held_item)
		to_chat(user, span_warning("В активной руке нет предмета!"))
		return FALSE

	// Если уже есть прикрепленный предмет
	if(attached_item)
		// Если это тот же предмет - отпускаем его
		if(held_item == attached_item)
			release_item()
			to_chat(user, span_notice("Вы отпускаете [attached_item.name]."))
		else
			// Отпускаем старый и прикрепляем новый
			release_item()
			attach_item(held_item)
			to_chat(user, span_notice("Вы отпускаете старый предмет и намертво вцепляетесь в [held_item.name]!"))
	else
		// Прикрепляем новый предмет
		attach_item(held_item)
		to_chat(user, span_notice("Вы намертво вцепились в [held_item.name]. Не отпустите его!"))

	return TRUE

/// Прикрепить предмет к руке
/datum/action/changeling/hand_strain/proc/attach_item(obj/item/I)
	if(!I || !owner)
		return

	// Если у предмета уже есть NODROP от другого источника, игнорируем его
	if(HAS_TRAIT_FROM(I, TRAIT_NODROP, ANTIDROP_TRAIT))
		to_chat(owner, span_warning("[I.name] уже невозможно выпустить из-за импланта антидроп!"))
		return

	attached_item = I

	// Добавляем трейт NODROP с нашим источником
	ADD_TRAIT(attached_item, TRAIT_NODROP, CHANGELING_HAND_STRAIN_TRAIT)

	// Регистрируем сигналы для отслеживания
	RegisterSignal(attached_item, COMSIG_ITEM_DROPPED, .proc/on_item_dropped)
	RegisterSignal(attached_item, COMSIG_QDELETING, .proc/on_item_deleted)

	// Визуальные эффекты
	owner.visible_message(
		span_warning("Сухожилия на руке [owner] напрягаются, сжимая [I]!"),
		span_notice("Ваши сухожилия напрягаются, сжимая [I].")
	)

	// Звуковой эффект (опционально)
	playsound(owner, 'sound/weapons/thudswoosh.ogg', 30, TRUE)

/// Отпустить предмет
/datum/action/changeling/hand_strain/proc/release_item()
	if(!attached_item || releasing)
		return

	releasing = TRUE

	// Удаляем трейт NODROP нашего источника
	REMOVE_TRAIT(attached_item, TRAIT_NODROP, CHANGELING_HAND_STRAIN_TRAIT)

	// Отписываемся от сигналов
	UnregisterSignal(attached_item, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING))

	attached_item = null
	releasing = FALSE

/// Если предмет пытаются выбросить - предотвращаем это
/datum/action/changeling/hand_strain/proc/on_item_dropped(obj/item/I, mob/dropper)
	SIGNAL_HANDLER

	if(releasing || !attached_item || attached_item != I)
		return

	// Возвращаем предмет в руку
	to_chat(dropper, span_warning("Вы пытаетесь отпустить [I], но ваша рука не слушается!"))

	if(dropper.put_in_active_hand(I))
		return TRUE

/// Если предмет уничтожается - очищаем ссылку
/datum/action/changeling/hand_strain/proc/on_item_deleted(datum/source)
	SIGNAL_HANDLER

	if(source == attached_item)
		UnregisterSignal(attached_item, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING))
		attached_item = null

#undef CHANGELING_HAND_STRAIN_TRAIT
