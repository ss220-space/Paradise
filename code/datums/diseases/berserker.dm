/datum/disease/berserker
	name = "Берсерк"
	desc = "Ругань, крики, неконтролируемые нападения на окружающих членов экипажа."
	agent = "Зубчатые кристаллы"
	cure_text = "Галоперидол"
	max_stages = 2
	stage_prob = 5
	cures = list("haloperidol")
	cure_prob = 10
	severity = DANGEROUS
	can_immunity = FALSE
	visibility_flags = HIDDEN_PANDEMIC

/datum/disease/berserker/stage_act()
	if(!..())
		return FALSE

	if(affected_mob.reagents.has_reagent("thc"))
		to_chat(affected_mob, span_notice("Вы расслабляетесь."))
		cure()
		return
	switch(stage)
		if(1)
			if(prob(5))
				affected_mob.emote(pick("twitch_s", "grumble"))
			if(prob(5))
				var/speak = pick("Грр", "Блять...", "Ёбаный...", "Ебать этот... блять...")
				affected_mob.say(speak)
		if(2)
			if(prob(5))
				affected_mob.emote(pick("twitch_s", "scream"))
			if(prob(5))
				var/speak = pick("ААААРГХ!!!!", "ГРРР!!!", "ЕБАТЬ!! БЛЯТЬ!!!", "ЁБАННЫЙ, СУКА!!", "ВРОООАААГХ!!")
				affected_mob.say(speak)
			if(prob(15))
				affected_mob.visible_message(span_danger("[affected_mob] дёрга[pluralize_ru(affected_mob.gender,"ется", "ются")] в конвульсиях!"))
				affected_mob.drop_l_hand()
				affected_mob.drop_r_hand()
			if(prob(33))
				if(affected_mob.incapacitated())
					affected_mob.visible_message(span_danger("[affected_mob] бьётся в судорогах и дёрга[pluralize_ru(affected_mob.gender,"ется", "ются")]!"))
					return
				affected_mob.visible_message(span_danger("[affected_mob] яростно меч[pluralize_ru(affected_mob.gender,"ется", "ются")]!"))
				for(var/mob/living/carbon/M in range(1, affected_mob))
					if(M == affected_mob)
						continue
					var/damage = rand(1, 5)
					if(prob(80))
						playsound(affected_mob.loc, "punch", 25, TRUE, -1)
						affected_mob.visible_message(span_danger("[affected_mob] ударя[pluralize_ru(affected_mob.gender,"ет", "ют")] [M.declent_ru(ACCUSATIVE)] своими конвульсиями!"))
						M.adjustBruteLoss(damage)
					else
						playsound(affected_mob.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
						affected_mob.visible_message(span_danger("[affected_mob] не попада[pluralize_ru(affected_mob.gender,"ет", "ют")] по [M.declent_ru(ACCUSATIVE)] своими конвульсиями!"))
