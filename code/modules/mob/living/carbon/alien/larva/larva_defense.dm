/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/M)
	if(..())
		var/damage = rand(1, 9)
		if(prob(90))
			playsound(loc, SFX_PUNCH, 25, TRUE, -1)
			add_attack_logs(M, src, "Melee attacked with fists")
			visible_message(span_danger("[M] has kicked [src]!"), \
					span_userdanger("[M] has kicked [src]!"))
			if((stat != DEAD) && (damage > 4.9))
				Paralyse(rand(10 SECONDS, 20 SECONDS))

			adjustBruteLoss(damage)
		else
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
			visible_message(span_danger("[M] has attempted to kick [src]!"), \
					span_userdanger("[M] has attempted to kick [src]!"))
