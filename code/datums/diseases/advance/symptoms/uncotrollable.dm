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
		var/mob/living/possible_victim = GetLivingTarget(7, aggressor)
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
						if(attacking_item.force > 5)
							WeaponAttack(aggressor, attacking_item)
						else
							UnarmedAttack(aggressor)

	if(A.stage >=5 && prob(SYMPTOM_ACTIVATION_PROB * 5))
		aggressor.say(pick("AAARRGGHHH!!!!", "GRR!!!", "FUCK!! FUUUUUUCK!!!", "FUCKING SHITCOCK!!", "WROOAAAGHHH!!"))
	return

/datum/symptom/aggression/proc/UnarmedAttack(mob/living/carbon/human/aggressor)
	var/mob/living/victim = GetLivingTarget(1, aggressor)
	if(istype(victim))
		aggressor.dna?.species?.harm(aggressor, victim)

/datum/symptom/aggression/proc/GunAttack(mob/living/carbon/human/aggressor, obj/item/gun/attacking_item)
	var/mob/living/victim = GetLivingTarget(7, aggressor)
	if(istype(victim) && victim.stat == CONSCIOUS)
		attacking_item.process_fire(victim, aggressor)

/datum/symptom/aggression/proc/WeaponAttack(mob/living/carbon/human/aggressor, obj/item/attacking_item)
	var/mob/living/victim = GetLivingTarget(1, aggressor)
	if(istype(victim))
		attacking_item.attack(victim, aggressor)

/datum/symptom/proc/GetLivingTarget(distance, mob/living/carbon/human/aggressor)
	var/list/victims = oview(distance, aggressor) - aggressor
	var/mob/living/victim = locate(/mob/living) in shuffle(victims)
	return victim

/*
//////////////////////////////////////

Uncontrollable Actions

//////////////////////////////////////
*/

/datum/symptom/obsession

	name = "Uncontrollable Actions"
	id = "obsession"
	stealth = -4
	resistance = 1
	stage_speed = 0
	transmittable = -1
	level = 6

/datum/symptom/obsession/Activate(datum/disease/advance/A)
	..()
	var/mob/living/carbon/human/possesed = A.affected_mob
	if(!istype(possesed))
		return

	if(prob(SYMPTOM_ACTIVATION_PROB * 15))
		switch(A.stage)
			if(2, 3)
				to_chat(possesed, {"<span class='alert'>[pick(\
					"You can't control yourself",\
					"1",\
					"2",\
					"3"\
					)]</span>"}
				)
			if(4)
				to_chat(possesed, {"<span class='alert'>[pick(\
					"4",\
					"5",\
					"6"\
					)]</span>"}
				)
			if(5)
				to_chat(possesed, {"<span class='danger'>[pick(\
					"7",\
					"8",\
					"9",\
					"10"\
					)]</span>"}
				)
				if(possesed.incapacitated())
					possesed.visible_message("<span class='danger'>[possesed] 12345!</span>")
					return
				possesed.visible_message("<span class='danger'>[possesed] 1234567890!</span>")

				var/obj/item/item = possesed.get_item_by_slot(slot_r_hand)
				if(!item)
					item = possesed.get_item_by_slot(slot_l_hand)
				if(!item)
					item = TakeItem(possesed)

				if(istype(item, /obj/item/gun))
					var/obj/item/gun/gun = item
					UseGun(possesed, gun)
				else
					item.attack_self(possesed)
	return

/datum/symptom/obsession/proc/TakeItem(mob/living/carbon/human/H)
	var/list/targets = range(1, H)
	var/obj/item/target = locate(/obj/item) in shuffle(targets)
	if(istype(target))
		target.forceMove(get_turf(H))
		H.put_in_hands(target)

/datum/symptom/obsession/proc/UseGun(mob/living/carbon/human/aggressor, obj/item/gun/attacking_item)
	var/list/targets = range(7, aggressor)
	var/turf/target = locate(/turf) in shuffle(targets)
	if(istype(target))
		attacking_item.process_fire(target, aggressor)

