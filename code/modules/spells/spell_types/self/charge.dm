/datum/action/cooldown/spell/charge
	name = "Charge"
	desc = "This spell can be used to recharge a variety of things in your hands, from magical artifacts to electrical components. A creative wizard can even use it to grant magical power to a fellow magic user."
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 1 MINUTES
	cooldown_reduction_per_rank = 5 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "DIRI CEL"
	invocation_type = INVOCATION_WHISPER
	button_icon_state = "charge"

/datum/action/cooldown/spell/charge/cast(atom/cast_on)
	. = ..()
	var/charge_result = NONE
	var/atom/charge_target_name

	var/mob/living/living = cast_on

	if(living.pulling)
		charge_target_name = living.pulling.name
		charge_result = living.pulling.magic_charge_act(living)

	if(!(charge_result & RECHARGE_SUCCESSFUL))
		var/list/hand_items = list(living.get_active_hand(), living.get_inactive_hand())

		for(var/obj/item in hand_items)
			charge_target_name = item.name
			charge_result = item.magic_charge_act(living)

			if(charge_result & RECHARGE_SUCCESSFUL)
				break

	if(!(charge_result & RECHARGE_SUCCESSFUL))
		to_chat(living, span_notice("You feel magical power surging to your hands, but the feeling rapidly fades..."))
		return

	if(charge_result & RECHARGE_BURNOUT)
		to_chat(living, span_caution("[charge_target_name] is reacting poorly to the spell!"))
		return

	to_chat(living, span_notice("[charge_target_name] suddenly feels very warm!"))
