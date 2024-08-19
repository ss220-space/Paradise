/datum/martial_art/wrestling
	name = "Wrestling"
	weight = 3
	has_explaination_verb = TRUE
	has_dirslash = FALSE

//	combo refence since wrestling uses a different format to sleeping carp and plasma fist.
//	Clinch "G"
//	Suplex "GD"
//	Advanced grab "G"

/datum/martial_art/wrestling/harm_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	var/old_grab_state = attacker.grab_state
	var/grab_success = defender.grabbedby(attacker, supress_message = TRUE)
	if(grab_success && old_grab_state == GRAB_PASSIVE && prob(50))
		defender.grippedby(attacker)
		defender.visible_message("<span class='danger'>[attacker] has [defender] in a clinch!</span>", \
								"<span class='userdanger'>[attacker] has [defender] in a clinch!</span>")
	else
		defender.visible_message("<span class='danger'>[attacker] fails to get [defender] in a clinch!</span>", \
								"<span class='userdanger'>[attacker] fails to get [defender] in a clinch!</span>")
	return TRUE


/datum/martial_art/wrestling/proc/Suplex(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)

	D.visible_message("<span class='danger'>[A] suplexes [D]!</span>", \
								"<span class='userdanger'>[A] suplexes [D]!</span>")
	D.forceMove(A.loc)
	var/armor_block = D.run_armor_check(null, "melee")
	D.apply_damage(30, BRUTE, null, armor_block)
	objective_damage(A, D, 30, BRUTE)
	D.apply_effect(12 SECONDS, KNOCKDOWN, armor_block)
	add_attack_logs(A, D, "Melee attacked with [src] (SUPLEX)")

	A.SpinAnimation(10,1)

	D.SpinAnimation(10,1)
	spawn(3)
		armor_block = A.run_armor_check(null, "melee")
		A.apply_effect(8 SECONDS, KNOCKDOWN, armor_block)
	return

/datum/martial_art/wrestling/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(A.pulling && A.pulling == D && A.grab_state > GRAB_PASSIVE && A.pull_hand != A.hand)
		Suplex(A, D)
		return TRUE
	harm_act(A, D)
	return TRUE

/datum/martial_art/wrestling/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.grabbedby(A, supress_message = TRUE)
	D.visible_message("<span class='danger'>[A] holds [D] down!</span>", \
								"<span class='userdanger'>[A] holds [D] down!</span>")
	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")
	D.apply_damage(10, STAMINA, affecting, armor_block)
	return TRUE

/datum/martial_art/wrestling/give_explaination(user = usr)
	to_chat(usr, "<b><i>You flex your muscles and have a revelation...</i></b>")
	to_chat(usr, "<span class='notice'>Clinch</span>: Grab. Passively gives you a 50% chance to immediately aggressively grab someone.")
	to_chat(usr, "<span class='notice'>Suplex</span>: Disarm someone you are grabbing. Suplexes your target to the floor. Greatly injures them and leaves both you and your target on the floor.")
	to_chat(usr, "<span class='notice'>Advanced grab</span>: Grab. Passively causes 10 stamina damage when grabbing someone.")
