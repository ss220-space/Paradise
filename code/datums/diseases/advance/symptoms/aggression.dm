/*
//////////////////////////////////////

Uncontrollable Aggression

//////////////////////////////////////
*/

/datum/symptom/aggression

	name = "Uncontrollable Aggression"
	id = "aggression"
	stealth = -4
	resistance = 2
	stage_speed = -3
	transmittable = 1
	level = 6

/datum/symptom/aggression/Activate(datum/disease/advance/A)
	..()
	var/mob/living/carbon/human/aggressor = A.affected_mob
	if(!istype(aggressor))
		return

	if(prob(SYMPTOM_ACTIVATION_PROB * 15))
		var/mob/living/possible_victim = GetTarget(7, aggressor)
		switch(A.stage)
			if(2, 3)
				to_chat(aggressor, {"<span class='alert'>[pick(\
					"You can't control yourself",\
					"It's been a while since you last time punched someone",\
					"You feel anger and anxiety",\
					"You admit that [possible_victim] have a punchable face"\
					)]</span>"}
				)
			if(4)
				to_chat(aggressor, {"<span class='alert'>[pick(\
					"You think about choking [possible_victim] and you <span class='danger'>LIKE IT!</span>",\
					"I fucking hate these people!",\
					"You never heard the crack of someone\'s skull, let\'s fix that"\
					)]</span>"}
				)
			if(5)
				to_chat(aggressor, {"<span class='danger'>[pick(\
					"HAHAHAHA I LOVE THEIR SQUEEK WHEN THEY GET HURT!!",\
					"NNGHHH FUCK!!",\
					"VIOLENCE VIOLENCE VIOLENCE VIOLENCE VIOLENCE!!",\
					"FUCKING FUCK SHIT AND FUCKHEADS BULLSHIT WHORES 'N BITCHES!!"\
					)]</span>"}
				)
				if(aggressor.incapacitated())
					aggressor.visible_message("<span class='danger'>[aggressor] spasms and twitches!</span>")
					return
				aggressor.visible_message("<span class='danger'>[aggressor] thrashes around violently!</span>")

				var/obj/item/attacking_item = aggressor.get_item_by_slot(slot_r_hand)
				if(!attacking_item)
					attacking_item = aggressor.get_item_by_slot(slot_l_hand)
				if(!attacking_item)
					UnarmedAttack(aggressor)
				else
					if(istype(attacking_item, /obj/item/gun))
						var/obj/item/gun/gun = attacking_item
						GunAttack(aggressor, gun)
					else
						if(attacking_item.force > 7)
							WeaponAttack(aggressor, attacking_item)
						else
							UnarmedAttack(aggressor)

	if(A.stage >=5 && prob(SYMPTOM_ACTIVATION_PROB * 5))
		aggressor.say(pick("AAARRGGHHH!!!!", "GRR!!!", "FUCK!! FUUUUUUCK!!!", "FUCKING SHITCOCK!!", "WROOAAAGHHH!!"))
	return

/datum/symptom/aggression/proc/UnarmedAttack(mob/living/carbon/human/aggressor)
	var/mob/living/victim = GetTarget(1, aggressor)
	if(istype(victim))
		aggressor.dna?.species?.harm(aggressor, victim)

/datum/symptom/aggression/proc/GunAttack(mob/living/carbon/human/aggressor, obj/item/gun/attacking_item)
	var/mob/living/victim = GetTarget(7, aggressor)
	if(istype(victim) && victim.stat == CONSCIOUS)
		attacking_item.process_fire(victim, aggressor)

/datum/symptom/aggression/proc/WeaponAttack(mob/living/carbon/human/aggressor, obj/item/attacking_item)
	var/mob/living/victim = GetTarget(1, aggressor)
	if(istype(victim))
		attacking_item.attack(victim, aggressor)

/datum/symptom/aggression/proc/GetTarget(distance, mob/living/carbon/human/aggressor)
	var/list/victims = oview(distance, aggressor) - aggressor
	var/mob/living/victim = locate(/mob/living) in shuffle(victims)
	return victim

