//Used by the gang of the same name. Uses combos. Basic attacks bypass armor and never miss
/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	weight = 9
	deflection_chance = 100
	no_guns = TRUE
	no_guns_message = "Use of ranged weaponry would bring dishonor to the clan."
	reroute_deflection = FALSE
	has_explaination_verb = TRUE
	grab_speed = 2 SECONDS
	grab_resist_chances = list(
		MARTIAL_GRAB_AGGRESSIVE = 40,
		MARTIAL_GRAB_NECK = 10,
		MARTIAL_GRAB_KILL = 5,
	)
	combos = list(/datum/martial_combo/sleeping_carp/back_kick, /datum/martial_combo/sleeping_carp/elbow_drop, /datum/martial_combo/sleeping_carp/head_kick, /datum/martial_combo/sleeping_carp/stomach_knee, /datum/martial_combo/sleeping_carp/wrist_wrench)

/datum/martial_art/the_sleeping_carp/can_use(mob/living/carbon/human/H)
	if(H.reagents && length(H.reagents.addiction_list))
		return FALSE
	return ..()

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	MARTIAL_ARTS_ACT_CHECK
	var/old_grab_state = attacker.grab_state
	var/grab_success = defender.grabbedby(attacker, supress_message = TRUE)
	if(grab_success && old_grab_state == GRAB_PASSIVE)
		defender.grippedby(attacker) //Instant aggressive grab
		add_attack_logs(attacker, defender, "Melee attacked with martial-art [src] : Grabbed", ATKLOG_ALL)
	return TRUE

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("punches", "kicks", "chops", "hits", "slams")
	D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verb] you!</span>")

	var/damage = rand(10,15)
	D.apply_damage(damage, BRUTE)
	objective_damage(A, D, damage, BRUTE)

	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, 1, -1)
	if(prob(50))
		A.say(pick("HUAH!", "HYA!", "CHOO!", "WUO!", "KYA!", "HUH!", "HIYOH!", "CARP STRIKE!", "CARP BITE!"))
	if(prob(D.getBruteLoss()) && D.body_position != LYING_DOWN)
		D.visible_message("<span class='warning'>[D] stumbles and falls!</span>", "<span class='userdanger'>The blow sends you to the ground!</span>")
		D.Weaken(6 SECONDS)
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Punched", ATKLOG_ALL)
	return TRUE

/datum/martial_art/the_sleeping_carp/explaination_header(user)
	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>")
