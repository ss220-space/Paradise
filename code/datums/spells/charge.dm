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
	for(var/mob/living/living in targets)
		var/list/hand_items = list(living.get_active_hand(), living.get_inactive_hand())
		var/charged_item = null

		if(living.pulling && (isliving(living.pulling)))
			var/mob/living/mob = living.pulling
			if(LAZYLEN(mob.mob_spell_list) || (mob.mind && LAZYLEN(mob.mind.spell_list)))
				for(var/obj/effect/proc_holder/spell/spell as anything in mob.mob_spell_list)
					spell.cooldown_handler.revert_cast()
				if(mob.mind)
					for(var/obj/effect/proc_holder/spell/spell as anything in mob.mind.spell_list)
						spell.cooldown_handler.revert_cast()
				to_chat(mob, span_notice("You feel raw magical energy flowing through you, it feels good!"))
			else
				to_chat(mob, span_notice("You feel very strange for a moment, but then it passes."))
				. = RECHARGE_BURNOUT
			charged_item = mob
			break
		for(var/obj/item in hand_items)
			if(item.contents)
				var/obj/item/stock_parts/cell/cell = locate() in item.contents
				if(!cell)
					continue
				. = cell.recharge_act(living)
				if(. & RECHARGE_NO_EFFECT)
					continue
				charged_item = cell
				break

			. = item.recharge_act(living)
			if(. & RECHARGE_NO_EFFECT)
				continue
			charged_item = item
			break

		if(!charged_item)
			to_chat(living, span_notice("You feel magical power surging to your hands, but the feeling rapidly fades..."))
			return
		switch(.)
			if(RECHARGE_BURNOUT)
				to_chat(living, span_caution("[charged_item] doesn't seem to be reacting to the spell..."))
			if(RECHARGE_SUCCESSFUL)
				to_chat(living, span_notice("[charged_item] suddenly feels very warm!"))
		return .

