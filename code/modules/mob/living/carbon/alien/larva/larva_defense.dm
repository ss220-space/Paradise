/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/M)
	if(..())
		var/damage = rand(1, 9)
		if(prob(90))
			playsound(loc, SFX_PUNCH, 25, TRUE, -1)
			add_attack_logs(M, src, "Melee attacked with fists")
			visible_message(span_danger("[DECLENT_RU_CAP(M, NOMINATIVE)] ударил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!"), \
					span_userdanger("[DECLENT_RU_CAP(M, NOMINATIVE)] ударил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!!"))
			if((stat != DEAD) && (damage > 4.9))
				Paralyse(rand(10 SECONDS, 20 SECONDS))

			adjustBruteLoss(damage)
		else
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
			visible_message(span_danger("[DECLENT_RU_CAP(M, NOMINATIVE)] промахивается по [declent_ru(PREPOSITIONAL)]!"), \
					span_userdanger("[DECLENT_RU_CAP(M, NOMINATIVE)] промахивается по [declent_ru(PREPOSITIONAL)]!"))
