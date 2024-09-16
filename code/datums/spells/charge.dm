/obj/effect/proc_holder/spell/charge
	name = "Charge"
	desc = "This spell can be used to recharge a variety of things in your hands, from magical artifacts to electrical components. A creative wizard can even use it to grant magical power to a fellow magic user."
	school = "transmutation"
	base_cooldown = 1 MINUTES
	clothes_req = FALSE
	human_req = FALSE
	invocation = "DIRI CEL"
	invocation_type = "whisper"
	cooldown_min = 40 SECONDS //50 deciseconds reduction per rank
	action_icon_state = "charge"


/obj/effect/proc_holder/spell/charge/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/charge/cast(list/targets, mob/user = usr)
	var/charged_item
	var/charge_result
	for(var/mob/living/living in targets)
		var/list/hand_items = list(living.get_active_hand(), living.get_inactive_hand())

		if(living.pulling)
			charge_result = pulling.magic_charge_act(pulling)
			if(charge_result & RECHARGE_NO_EFFECT)
				continue
			charged_item = pulling
			break

		for(var/obj/item in hand_items)
			charge_result = item.magic_charge_act(living)
			if(charge_result & RECHARGE_NO_EFFECT)
				continue
			charged_item = item
			break

	if(!charged_item)
		to_chat(user, span_notice("You feel magical power surging to your hands, but the feeling rapidly fades..."))
		return
	switch(charge_result)
		if(RECHARGE_BURNOUT)
			to_chat(user, span_caution("[charged_item] doesn't seem to be reacting to the spell..."))
		if(RECHARGE_SUCCESSFUL)
			to_chat(user, span_notice("[charged_item] suddenly feels very warm!"))

