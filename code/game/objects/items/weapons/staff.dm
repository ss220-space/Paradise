/obj/item/twohanded/staff
	name = "wizards staff"
	desc = "Apparently a staff used by the wizard."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	armour_penetration = 100
	attack_verb = list("bludgeoned", "whacked", "disciplined")
	resistance_flags = FLAMMABLE

/obj/item/twohanded/staff/broom
	name = "broom"
	desc = "Used for sweeping, and flying into the night while cackling. Black cat not included."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "broom"
	item_state = "broom0"


/obj/item/twohanded/staff/broom/update_icon_state()
	item_state = "[initial(icon_state)][HAS_TRAIT(src, TRAIT_WIELDED)]"
	update_equipped_item(update_speedmods = FALSE)


/obj/item/twohanded/staff/broom/wield(obj/item/source, mob/living/carbon/user)
	force =  5
	attack_verb = list("rammed into", "charged at")
	if(!user)
		return

	update_icon(UPDATE_ICON_STATE)
	if(user.mind && (user.mind in SSticker.mode.wizards))
		ADD_TRAIT(user, TRAIT_MOVE_FLYING, ITEM_BROOM_TRAIT)
		user.say("QUID 'ITCH")

	to_chat(user, span_notice("You hold [src] between your legs."))


/obj/item/twohanded/staff/broom/unwield(obj/item/source, mob/living/carbon/user)
	force = 3
	attack_verb = list("bludgeoned", "whacked", "cleaned")
	if(!user)
		return
	update_icon(UPDATE_ICON_STATE)
	REMOVE_TRAIT(user, TRAIT_MOVE_FLYING, ITEM_BROOM_TRAIT)


/obj/item/twohanded/staff/broom/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/mask/horsehead))
		if(loc == user && !user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		var/obj/item/twohanded/staff/broom/horsebroom/broom = new(drop_location())
		broom.add_fingerprint(user)
		qdel(I)
		qdel(src)
		user.put_in_hands(broom, ignore_anim = FALSE)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/twohanded/staff/broom/horsebroom
	name = "broomstick horse"
	desc = "Saddle up!"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "horsebroom"
	item_state = "horsebroom0"


/obj/item/twohanded/staff/stick
	name = "stick"
	desc = "A great tool to drag someone else's drinks across the bar."
	icon_state = "stick"
	item_state = "stick"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
