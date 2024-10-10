/obj/effect/proc_holder/spell/touch
	invocation_type = "none" // You scream on connecting, not summoning
	/// What type of item this spell summons
	var/hand_path = /obj/item/melee/touch_attack
	/// Link to the spawned item
	var/obj/item/melee/touch_attack/attached_hand = null
	/// Special message shown on item gain
	var/on_gain_message = span_notice("Вы направляете силу заклинания в свою руку.")
	/// Special message shown on item withdrowal
	var/on_withdraw_message = span_notice("Вы лишаете руку силы заклинания.")


/obj/effect/proc_holder/spell/touch/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/touch/Click()
	if(HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		to_chat(usr, span_warning("Вы не можете управлять своими руками!"))
		return FALSE
	if(attached_hand)
		discharge_hand(usr, TRUE)
		return FALSE
	charge_hand(usr)


/obj/effect/proc_holder/spell/touch/proc/charge_hand(mob/living/carbon/user)

	var/obj/item/melee/touch_attack/new_hand = new hand_path(src, user)

	if(user.put_in_hands(new_hand, qdel_on_fail = TRUE))
		RegisterSignal(user, COMSIG_MOB_KEY_DROP_ITEM_DOWN, PROC_REF(discharge_hand))

		attached_hand = new_hand

		if(on_gain_message)
			to_chat(user, on_gain_message)

		if(on_withdraw_message)
			new_hand.on_withdraw_message = on_withdraw_message
	else
		to_chat(user, span_warning("Ваши руки заняты!"))


/obj/effect/proc_holder/spell/touch/proc/discharge_hand(atom/target, any_hand = FALSE)
	SIGNAL_HANDLER

	var/mob/living/carbon/user = action.owner
	if(!istype(attached_hand))
		return

	if(!any_hand && attached_hand != user.get_active_hand())
		return

	attached_hand.is_withdraw = TRUE
	QDEL_NULL(attached_hand)
	return COMPONENT_CANCEL_DROP


/obj/effect/proc_holder/spell/touch/disintegrate
	name = "Disintegrate"
	desc = "Это заклинание заряжает вашу руку энергией, которая может быть использована для дезинтеграции жертв."
	hand_path = /obj/item/melee/touch_attack/disintegrate

	school = "evocation"
	base_cooldown = 60 SECONDS
	clothes_req = TRUE
	cooldown_min = 20 SECONDS //100 deciseconds reduction per rank

	action_icon_state = "gib"


/obj/effect/proc_holder/spell/touch/flesh_to_stone
	name = "Flesh to Stone"
	desc = "Это заклинание заряжает вашу руку силой, способной превращать жертв в неподвижные каменные изваяния."
	hand_path = /obj/item/melee/touch_attack/fleshtostone

	school = "transmutation"
	base_cooldown = 60 SECONDS
	clothes_req = TRUE
	cooldown_min = 20 SECONDS //100 deciseconds reduction per rank

	action_icon_state = "statue"

