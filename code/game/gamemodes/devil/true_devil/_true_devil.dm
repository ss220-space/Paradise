// This is used primarily for having hands.
/mob/living/carbon/true_devil
	name = "True Devil"
	desc = "A pile of infernal energy, taking a vaguely humanoid form."
	icon = 'icons/mob/32x64.dmi'
	icon_state = "true_devil"
	gender = NEUTER
	health = 350
	maxHealth = 350
	mobility_flags = MOBILITY_FLAGS_DEFAULT
	sight = SEE_TURFS|SEE_OBJS
	status_flags = CANPUSH
	universal_understand = TRUE
	universal_speak = TRUE //The devil speaks all languages meme
	var/ascended = FALSE
	var/mob/living/oldform

/mob/living/carbon/true_devil/New(loc, mob/living/carbon/dna_source)
	if(dna_source)
		dna = dna_source.dna.Clone()
	else
		dna = new

	new /obj/item/organ/internal/brain(src)
	new /obj/item/organ/internal/ears(src)
	..()

// Determines if mob has and can use his hands like a human
/mob/living/carbon/true_devil/real_human_being()
	return TRUE


/mob/living/carbon/true_devil/proc/convert_to_archdevil()
	maxHealth = 5000 // not an IMPOSSIBLE amount, but still near impossible.
	ascended = TRUE
	health = maxHealth
	icon_state = "arch_devil"

/mob/living/carbon/true_devil/proc/set_name()
	name = mind.devilinfo.truename
	real_name = name

/mob/living/carbon/true_devil/Login()
	..()
	var/list/messages = list()
	if(mind.devilinfo)
		messages.Add(mind.devilinfo.announce_laws(src))
	messages.Add(mind.prepare_announce_objectives())
	to_chat(mind.current, chat_box_red(messages.Join("<br>")))


/mob/living/carbon/true_devil/death(gibbed)
	. = ..(gibbed)
	drop_l_hand()
	drop_r_hand()


/mob/living/carbon/true_devil/examine(mob/user)
	var/msg = "This is [bicon(src)] <b>[src]</b>!\n"

	//Left hand items
	if(l_hand && !(l_hand.item_flags & ABSTRACT))
		if(l_hand.blood_DNA)
			msg += "<span class='warning'>It is holding [bicon(l_hand)] [l_hand.gender == PLURAL? "some" : "a"] blood-stained [l_hand.name] in its left hand!</span>\n"
		else
			msg += "It is holding [bicon(l_hand)] \a [l_hand] in its left hand.\n"

	//Right hand items
	if(r_hand && !(r_hand.item_flags & ABSTRACT))
		if(r_hand.blood_DNA)
			msg += "<span class='warning'>It is holding [bicon(r_hand)] [r_hand.gender == PLURAL? "some" : "a"] blood-stained [r_hand.name] in its right hand!</span>\n"
		else
			msg += "It is holding [bicon(r_hand)] \a [r_hand] in its right hand.\n"

	//Braindead
	if(!client && stat != DEAD)
		msg += "<span class='deadsay'>The devil seems to be in deep contemplation.</span>\n"

	//Damaged
	if(stat == DEAD)
		msg += "<span class='deadsay'>The hellfire seems to have been extinguished, for now at least.</span>\n"
	else if(health < (maxHealth/10))
		msg += "<span class='warning'>You can see hellfire inside of it's gaping wounds.</span>\n"
	else if(health < (maxHealth/2))
		msg += "<span class='warning'>You can see hellfire inside of it's wounds.</span>\n"

	. = list(msg)


/mob/living/carbon/true_devil/IsAdvancedToolUser()
	return TRUE

/mob/living/carbon/true_devil/assess_threat()
	return 666

/mob/living/carbon/true_devil/flash_eyes(intensity = 1, override_blindness_check, affect_silicon, visual, type = /atom/movable/screen/fullscreen/flash)
	if(mind && has_bane(BANE_LIGHT))
		mind.disrupt_spells(-500)
		return ..() //flashes don't stop devils UNLESS it's their bane.


/mob/living/carbon/true_devil/proceed_attack_results(obj/item/I, mob/living/user, params, def_zone)
	. = ATTACK_CHAIN_PROCEED_SUCCESS

	send_item_attack_message(I, user, def_zone)
	if(!I.force)
		return .

	apply_damage(I.force * check_weakness(I, user), I.damtype, def_zone, sharp = is_sharp(I), used_weapon = I)
	if(QDELETED(src))
		return ATTACK_CHAIN_BLOCKED_ALL


/mob/living/carbon/true_devil/UnarmedAttack(atom/A, proximity)
	if(!can_unarmed_attack())
		return
	if(!ishuman(A))
		// `attack_hand` on mobs assumes the attacker is a human
		// I am the worst
		A.attack_hand(src)
		// If the devil wants to actually attack, they have the pitchfork.


/mob/living/carbon/true_devil/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE


/mob/living/carbon/true_devil/singularity_act()
	if(ascended)
		return 0
	return ..()

/mob/living/carbon/true_devil/attack_ghost(mob/dead/observer/user as mob)
	if(ascended || user.mind.soulOwner == src.mind)
		var/mob/living/simple_animal/imp/S = new(get_turf(loc))
		S.key = user.key
		S.mind.assigned_role = "MODE"
		S.mind.special_role = "Imp"
		var/datum/objective/newobjective = new
		newobjective.explanation_text = "Try to get a promotion to a higher infernal rank."
		S.mind.objectives += newobjective
		to_chat(S,S.playstyle_string)
		to_chat(S,"<B>Objective #1</B>: [newobjective.explanation_text]")
		return
	else
		return ..()

/mob/living/carbon/true_devil/resist_fire()
	//They're immune to fire.

/mob/living/carbon/true_devil/attack_hand(mob/living/carbon/human/M)
	if(..())
		switch(M.a_intent)
			if(INTENT_HARM)
				var/damage = rand(1, 5)
				playsound(loc, "punch", 25, 1, -1)
				visible_message("<span class='danger'>[M] has punched [src]!</span>", \
						"<span class='userdanger'>[M] has punched [src]!</span>")
				adjustBruteLoss(damage)
				add_attack_logs(M, src, "attacked")
			if(INTENT_DISARM)
				if(body_position == STANDING_UP && !ascended) //No stealing the arch devil's pitchfork.
					if(prob(5))
						// Weaken knocks people over
						// Paralyse knocks people out
						// It's Paralyse for parity though
						// Weaken(4 SECONDS)
						Paralyse(4 SECONDS)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						add_attack_logs(M, src, "pushed")
						visible_message("<span class='danger'>[M] has pushed down [src]!</span>", \
							"<span class='userdanger'>[M] has pushed down [src]!</span>")
					else
						if(prob(25))
							drop_from_active_hand()
							playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
							visible_message("<span class='danger'>[M] has disarmed [src]!</span>", \
							"<span class='userdanger'>[M] has disarmed [src]!</span>")
						else
							playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
							visible_message("<span class='danger'>[M] has attempted to disarm [src]!</span>")

/mob/living/carbon/true_devil/handle_breathing()
	// devils do not need to breathe

/mob/living/carbon/true_devil/is_literate()
	return TRUE

/mob/living/carbon/true_devil/ex_act(severity, ex_target)
	if(!ascended)
		var/b_loss
		switch (severity)
			if (1)
				b_loss = 500
			if (2)
				b_loss = 150
			if(3)
				b_loss = 30
		if(has_bane(BANE_LIGHT))
			b_loss *=2
		adjustBruteLoss(b_loss)
	return ..()

