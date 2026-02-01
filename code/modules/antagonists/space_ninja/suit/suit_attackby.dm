/obj/item/clothing/suit/space/space_ninja/attackby(obj/item/I, mob/ninja, params)
	if(ninja != affecting)//Safety, in case you try doing this without wearing the suit/being the person with the suit.
		return ..()

	if(istype(I, /obj/item/stack/sheet/mineral/uranium))
		add_fingerprint(ninja)
		var/obj/item/stack/sheet/mineral/uranium/uranium_stack = I
		if(a_boost.charge_counter >= a_boost.charge_max)
			balloon_alert(ninja, "отсек полон!")
			return ATTACK_CHAIN_PROCEED
		if(!uranium_stack.use(a_transfer))
			to_chat(ninja, span_warning("Вам нужно как минимум [a_transfer] лист[DECL_CREDIT(a_transfer)] урана для восполнения запаса адреналина."))
			return ATTACK_CHAIN_PROCEED
		a_boost.action_ready = TRUE
		a_boost.toggle_button_on_off()
		a_boost.recharge_action()
		balloon_alert(ninja, "пополнено")
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/stack/ore/bluespace_crystal))
		add_fingerprint(ninja)
		var/obj/item/stack/ore/bluespace_crystal/crystal_stack = I
		if(heal_chems.charge_counter >= heal_chems.charge_max)
			balloon_alert(ninja, "отсек полон!")
			return ATTACK_CHAIN_PROCEED
		if(!crystal_stack.use(a_transfer))
			to_chat(ninja, span_warning("Вам нужно как минимум [a_transfer] блюспейс-кристалл[DECL_CREDIT(a_transfer)] для восполнения запаса химикатов."))
			return ATTACK_CHAIN_PROCEED
		heal_chems.action_ready = TRUE
		heal_chems.toggle_button_on_off()
		heal_chems.recharge_action()
		balloon_alert(ninja, "пополнено")
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(iscell(I))
		add_fingerprint(ninja)
		var/obj/item/stock_parts/cell/new_cell = I
		var/obj/item/stock_parts/cell/old_cell = cell
		if(old_cell.maxcharge >= 100000)
			to_chat(ninja, span_warning("Достигнут лимит обновлений! Дальнейшее обновление батареи невозможно."))
			return ATTACK_CHAIN_PROCEED
		if(new_cell.rigged)
			to_chat(ninja, span_warning("Эта батарея опасна и может взорваться! Система безопасности костюма не позволяет поместить её внутрь."))
			return ATTACK_CHAIN_PROCEED
		if(new_cell.maxcharge <= old_cell.maxcharge)
			to_chat(ninja, span_warning("[DECLENT_RU_CAP(new_cell, NOMINATIVE)] идентична [old_cell.declent_ru(DATIVE)]."))
			return ATTACK_CHAIN_PROCEED
		to_chat(ninja, span_notice("Батарея большей мощности обнаружена. Установка..."))
		if(!do_after(ninja, s_delay, src) || QDELETED(new_cell))
			balloon_alert(ninja, "процедура прервана!")
			return ATTACK_CHAIN_PROCEED
		if(!ninja.drop_transfer_item_to_loc(new_cell, src))
			return ATTACK_CHAIN_PROCEED
		new_cell.self_recharge = FALSE
		new_cell.maxcharge = min(new_cell.maxcharge, 80000)
		if(new_cell.maxcharge >= 80000)
			to_chat(ninja, span_danger("Достигнут лимит обновлений! Дальнейшее обновление батареи невозможно."))
		new_cell.charge = min(new_cell.charge + old_cell.charge, new_cell.maxcharge)
		cell = new_cell
		var/datum/antagonist/ninja/ninja_datum = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
		ninja_datum?.cell = cell
		old_cell.charge = 0
		ninja.put_in_hands(old_cell)
		old_cell.add_fingerprint(ninja)
		old_cell.corrupt()
		old_cell.update_icon()
		to_chat(ninja, span_notice("Обновление батареи завершено. Максимальная ёмкость: <b>[round(cell.maxcharge/100)]</b>%"))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()
