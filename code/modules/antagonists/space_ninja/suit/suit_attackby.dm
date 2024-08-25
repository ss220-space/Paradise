/obj/item/clothing/suit/space/space_ninja/attackby(obj/item/I, mob/ninja, params)
	if(ninja != affecting)//Safety, in case you try doing this without wearing the suit/being the person with the suit.
		return ..()

	if(istype(I, /obj/item/stack/sheet/mineral/uranium))
		add_fingerprint(ninja)
		var/obj/item/stack/sheet/mineral/uranium/uranium_stack = I
		if(a_boost.charge_counter >= a_boost.charge_max)
			to_chat(ninja, span_warning("The suit's uranium storage is full."))
			return ATTACK_CHAIN_PROCEED
		if(!uranium_stack.use(a_transfer))
			to_chat(ninja, span_warning("You need at least [a_transfer] sheet\s of uranium to reload the storage."))
			return ATTACK_CHAIN_PROCEED
		a_boost.action_ready = TRUE
		a_boost.toggle_button_on_off()
		a_boost.recharge_action()
		to_chat(ninja, span_notice("The suit's adrenaline boost is now reloaded."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/stack/ore/bluespace_crystal))
		add_fingerprint(ninja)
		var/obj/item/stack/ore/bluespace_crystal/crystal_stack = I
		if(heal_chems.charge_counter >= heal_chems.charge_max)
			to_chat(ninja, span_warning("The suit's bluespace crystal storage is full."))
			return ATTACK_CHAIN_PROCEED
		if(!crystal_stack.use(a_transfer))
			to_chat(ninja, span_warning("You need at least [a_transfer] bluespace crystals to reload the storage."))
			return ATTACK_CHAIN_PROCEED
		heal_chems.action_ready = TRUE
		heal_chems.toggle_button_on_off()
		heal_chems.recharge_action()
		to_chat(ninja, span_notice("The suit's restorative cocktail is now reloaded."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/stock_parts/cell))
		add_fingerprint(ninja)
		var/obj/item/stock_parts/cell/new_cell = I
		var/obj/item/stock_parts/cell/old_cell = cell
		if(old_cell.maxcharge >= 100000)
			to_chat(ninja, span_warning("Upgrade limit reached! Further cell upgrade's aren't possible."))
			return ATTACK_CHAIN_PROCEED
		if(new_cell.rigged)
			to_chat(ninja, span_warning("This cell is hazardous and can explode! Suit's safety system doesn't allow you to put it inside self."))
			return ATTACK_CHAIN_PROCEED
		if(new_cell.maxcharge <= old_cell.maxcharge)
			to_chat(ninja, span_warning("This [new_cell.name] is identical to [old_cell]."))
			return ATTACK_CHAIN_PROCEED
		to_chat(ninja, span_notice("Higher maximum capacity detected.\nUpgrading..."))
		if(!do_after(ninja, s_delay, src) || QDELETED(new_cell))
			to_chat(ninja, span_warning("Procedure interrupted. Protocol terminated."))
			return ATTACK_CHAIN_PROCEED
		if(!ninja.drop_transfer_item_to_loc(new_cell, src))
			return ATTACK_CHAIN_PROCEED
		new_cell.self_recharge = FALSE
		new_cell.maxcharge = min(new_cell.maxcharge, 80000)
		if(new_cell.maxcharge >= 80000)
			to_chat(ninja, span_danger("Upgrade limit reached! Further cell upgrade's won't be possible."))
		new_cell.charge = min(new_cell.charge + old_cell.charge, new_cell.maxcharge)
		cell = new_cell
		var/datum/antagonist/ninja/ninja_datum = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
		ninja_datum?.cell = cell
		old_cell.charge = 0
		ninja.put_in_hands(old_cell)
		old_cell.add_fingerprint(ninja)
		old_cell.corrupt()
		old_cell.update_icon()
		to_chat(ninja, span_notice("Upgrade complete. Maximum capacity: <b>[round(cell.maxcharge/100)]</b>%"))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()
