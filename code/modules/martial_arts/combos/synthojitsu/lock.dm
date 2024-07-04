/datum/martial_combo/synthojitsu/lock
	name = "Lock"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Allows user to neck-grab opponent quickly"

/datum/martial_combo/synthojitsu/lock/perform_combo(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/MA)
	var/old_grab_state = user.grab_state
	var/grabbed = target.grabbedby(user, supress_message = TRUE)
	if(grabbed)
		if(old_grab_state < GRAB_NECK)
			target.grippedby(user, grab_state_override = GRAB_NECK) //Instant neck grab
		add_attack_logs(user, target, "Melee attacked with martial-art [src] : neck grabbed", ATKLOG_ALL)
		user.adjust_nutrition(-25)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
