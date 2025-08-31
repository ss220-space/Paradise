/datum/martial_combo/mr_chang/steal_card
	name = "Бонусную карту, пожалуйста!"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Забираете у цели любой предмет, находящийся в слоте ID-карты."

/datum/martial_combo/mr_chang/steal_card/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	var/mob/living/carbon/human/T = target
	if(!istype(T))
		return MARTIAL_COMBO_FAIL

	var/obj/item/I = T.get_item_by_slot(ITEM_SLOT_ID)
	if(istype(I))
		T.drop_item_ground(I)
		user.put_in_hands(I, ignore_anim = FALSE)
		user.say(pick("В+аша б+онусная к+арта!", "5000 б+аллов сп+исано!", "Приним+аем к+арты всех б+анков!", \
						"Н+аше л+учшее предлож+ение!", "Безнал+ичный расч+ёт!", "Хват+ай! Беспл+атно!!"))
		var/attack_verb = pick("кэшбекнул[genderize_ru(user.gender, "", "а", "о", "и")]", \
		"уценил[genderize_ru(user.gender, "", "а", "о", "и")]", \
		"сторговал[genderize_ru(user.gender, "", "а", "о", "и")]")
		target.visible_message(span_warning("[user] [attack_verb] [target]!"), \
						span_userdanger("[user] [attack_verb] вас!"))
		var/sound = pick('sound/weapons/mr_chang/mr_chang_steal_card_1.mp3', 'sound/weapons/mr_chang/mr_chang_steal_card_2.mp3', \
						'sound/weapons/mr_chang/mr_chang_steal_card_3.mp3', 'sound/weapons/mr_chang/mr_chang_steal_card_4.mp3')
		playsound(get_turf(user), sound, 50, TRUE, -1)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Steal Card", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	else
		return MARTIAL_COMBO_FAIL
