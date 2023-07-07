/datum/martial_combo/mr_chang/steal_card
	name = "Bonus card please!"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Забирает у цели любой предмет, находящийся в слоте ID-карты и помещает его в руку атакующего."
	combo_text_override = "Grab, switch hands, Disarm"

/datum/martial_combo/cqc/slam/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	//if(!target.IsWeakened() && !target.resting && !target.lying)
	target.visible_message("<span class='warning'>[user] slams [target] into the ground!</span>", \
						"<span class='userdanger'>[user] slams you into the ground!</span>")
	user.say("Bonus card please!")
	playsound(get_turf(user), 'sound/weapons/slam.ogg', 50, 1, -1)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Steal Card", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
