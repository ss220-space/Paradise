/datum/martial_combo/cqc/consecutive
	name = "Последовательный CQC"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Ориентированный на урон удар, огромный физических урон и гигантский удар по выносливости."

/datum/martial_combo/cqc/consecutive/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat)
		target.visible_message("<span class='warning'>[user] последовательно бьет [target] в живот, шею и спину!</span>", \
							"<span class='userdanger'>[user] последовательно бьет вас в живот, шею и спину!</span>")
		playsound(get_turf(target), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
		var/obj/item/I = target.get_active_hand()
		if(I && target.drop_item())
			user.put_in_hands(I)
		target.adjustStaminaLoss(50)
		target.apply_damage(25, BRUTE)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : Consecutive", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
