/datum/martial_combo/mimejutsu/silent_palm
	name = "Ладонь Тишины"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Использование энергии пантомимы для отбрасывания цели."

/datum/martial_combo/mimejutsu/silent_palm/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.stat && !target.stunned && !target.IsWeakened())
		target.visible_message("<span class='danger'>[user] едва коснул[genderize_ru(user.gender,"ся","ась","ось","ись")] [target] своей ладонью!</span>", \
						"<span class='userdanger'>[user] наводит свою ладонь на ваше лицо!</span>")

		var/atom/throw_target = get_edge_target_turf(target, get_dir(target, get_step_away(target, user)))
		target.throw_at(throw_target, 200, 4, user)
	return MARTIAL_COMBO_DONE_BASIC_HIT
