/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M)
	if(..())
		switch(M.a_intent)
			if(INTENT_HARM)
				var/damage = rand(1, 9)
				if(prob(90))
					playsound(loc, SFX_PUNCH, 25, TRUE, -1)
					visible_message(
						span_danger("[DECLENT_RU_CAP(M, NOMINATIVE)] ударил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!"),
						span_userdanger("[DECLENT_RU_CAP(M, NOMINATIVE)] ударил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!")
					)
					if((stat != DEAD) && (damage > 9||prob(5)))//Regular humans have a very small chance of weakening an alien.
						Paralyse(4 SECONDS)
						visible_message(
							span_danger("[DECLENT_RU_CAP(M, NOMINATIVE)] ослабил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!"),
							span_userdanger("[DECLENT_RU_CAP(M, NOMINATIVE)] ослабил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!"),
							span_danger("Вы слышите, как кто-то упал.")
						)
					adjustBruteLoss(damage)
					add_attack_logs(M, src, "Melee attacked with fists")
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
					visible_message(span_danger("[DECLENT_RU_CAP(M, NOMINATIVE)] попытал[GEND_SYA_AS_OS_IS(M)] ударить [declent_ru(ACCUSATIVE)]!"))

			if(INTENT_DISARM)
				if(body_position != LYING_DOWN)
					if(prob(50))
						drop_from_active_hand()
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
						visible_message(
							span_danger("[DECLENT_RU_CAP(M, NOMINATIVE)] обезоружил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!"),
							span_userdanger("[DECLENT_RU_CAP(M, NOMINATIVE)] обезоружил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!")
						)
					else
						playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
						visible_message(span_danger("[DECLENT_RU_CAP(M, NOMINATIVE)] попытал[GEND_SYA_AS_OS_IS(M)] обезоружить [declent_ru(ACCUSATIVE)]!"))

/mob/living/carbon/alien/humanoid/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()

/mob/living/carbon/alien/humanoid/resist_grab(moving_resist = FALSE)
	if(pulledby.grab_state)
		visible_message(
			span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] легко вырыва[PLUR_ET_YUT(src)]ся из захвата [pulledby.declent_ru(GENITIVE)]!"),
			span_danger("Вы легко вырываетесь из захвата [pulledby.declent_ru(GENITIVE)]!"),
			ignored_mobs = pulledby,
		)
		to_chat(pulledby, span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] вырвал[GEND_SYA_AS_OS_IS(src)] из Вашего захвата!"))
	pulledby.stop_pulling()
	return FALSE

