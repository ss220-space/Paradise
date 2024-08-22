/obj/item/stack/tape_roll
	name = "tape roll"
	desc = "A roll of sticky tape. Possibly for taping ducks... or was that ducts?"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "taperoll"
	singular_name = "tape roll"
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	amount = 25
	max_amount = 25
	/// Delay for tape to apply
	var/apply_tape_delay = 5 SECONDS
	/// If `TRUE` removes targets's mask on apply
	var/drop_mask = FALSE


/obj/item/stack/tape_roll/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!ishuman(target)) //What good is a duct tape mask if you are unable to speak?
		return .
	if(!drop_mask && target.wear_mask)
		to_chat(user, span_warning("Remove [target.p_their()] mask first!"))
		return .
	if(get_amount() < 2)
		to_chat(user, span_warning("You'll need more tape for this!"))
		return .
	if(!target.check_has_mouth())
		to_chat(user, span_warning("[target.p_they(TRUE)] [target.p_have()] no mouth to tape over!"))
		return .
	user.visible_message(
		span_warning("[user] is taping [target]'s mouth closed!"),
		span_notice("You try to tape [target == user ? "your own" : "[target]'s"] mouth shut!"),
		span_italics("You hear tape ripping."),
	)
	if(!do_after(user, apply_tape_delay, target) || !target.check_has_mouth() || get_amount() < 2)
		return .
	if(drop_mask && target.wear_mask)
		target.drop_item_ground(target.wear_mask)
	if(target.wear_mask)	// in case mask has NODROP
		to_chat(user, span_notice("[target == user ? user : target]'s mouth is covered!"))
		return .
	if(!use(2))
		to_chat(user, span_notice("You don't have enough tape!"))
		return .
	. |= ATTACK_CHAIN_SUCCESS
	user.visible_message(
		span_warning("[user] tapes [target]'s mouth shut!"),
		span_notice("You cover [target == user ? "your own" : "[target]'s"] mouth with a piece of duct tape.[target == user ? null : " That will shut them up."]"),
	)
	var/obj/item/clothing/mask/muzzle/tapegag/tapegag = new(null)
	tapegag.add_fingerprint(user)
	target.equip_to_slot_if_possible(tapegag, ITEM_SLOT_MASK, qdel_on_fail = TRUE)


/obj/item/stack/tape_roll/update_icon_state()
	var/amount = get_amount()
	if((amount <= 2) && (amount > 0))
		icon_state = "[initial(icon_state)]"
	if((amount <= 4) && (amount > 2))
		icon_state = "[initial(icon_state)]2"
	if((amount <= 6) && (amount > 4))
		icon_state = "[initial(icon_state)]3"
	if((amount > 6))
		icon_state = "[initial(icon_state)]4"
	else
		icon_state = "[initial(icon_state)]4"


/obj/item/stack/tape_roll/thick
	name = "incredibly thick tape roll"
	desc = "Incredibly thick duct tape, suspiciously black in appearance. It is quite uncomfortable to hold it as it sticks to your hands."
	icon_state = "thick_taperoll"
	singular_name = "incridibly dence tape roll"
	amount = 40
	max_amount = 40
	apply_tape_delay = 1 SECONDS
	drop_mask = TRUE

