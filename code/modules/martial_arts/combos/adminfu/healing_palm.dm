/datum/martial_combo/adminfu/healing_palm
	name = "Исцеляющая ладонь"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HELP)
	explaination_text = "Исцелить или возродить существо."
	combo_text_override = "Захват, смена рук, помощь"

/datum/martial_combo/adminfu/healing_palm/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	user.do_attack_animation(target)
	target.visible_message("<span class='warning'>[user] шлепает ладонью по лбу [target]!</span>")

		//its the staff of healing code..hush
	if(istype(target,/mob))
		var/old_stat = target.stat
		if(isanimal(target) && target.stat == DEAD)
			var/mob/living/simple_animal/O = target
			var/mob/living/simple_animal/P = new O.type(O.loc)
			P.real_name = O.real_name
			P.name = O.name
			if(O.mind)
				O.mind.transfer_to(P)
			else
				P.key = O.key
			qdel(O)
			target = P
		else
			target.revive()
			target.suiciding = 0
		if(!target.ckey)
			for(var/mob/dead/observer/ghost in GLOB.player_list)
				if(target.real_name == ghost.real_name)
					ghost.reenter_corpse()
					break
		if(old_stat != DEAD)
			to_chat(target, "<span class='notice'>Вы чувствуете себя изумительно!</span>")
		else
			to_chat(target, "<span class='notice'>Вы восстали, вы живы!!!</span>")
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
