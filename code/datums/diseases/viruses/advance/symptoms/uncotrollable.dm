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
	severity = 4

/datum/symptom/aggression/Activate(datum/disease/virus/advance/A)
	..()
	var/mob/living/carbon/human/aggressor = A.affected_mob
	if(!istype(aggressor))
		return

	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		var/mob/living/possible_victim = GetLivingTarget(7, aggressor)
		switch(A.stage)
			if(2, 3)
				to_chat(aggressor, span_alert(pick(\
					"You can't control yourself",\
					"It's been a while since you last time punched someone",\
					"You feel anger and anxiety",\
					"You admit that [possible_victim ? possible_victim : "that bastard"] have a punchable face"\
				)))
			if(4)
				to_chat(aggressor, span_alert(pick(\
					"You think about choking [possible_victim ? possible_victim : "someone"] and you [span_danger("LIKE IT!")]",\
					"I fucking hate these people!",\
					"You never heard the crack of someone\'s skull, let\'s fix that"\
				)))
			if(5)
				switch(rand(1, 2))
					if(1)
						to_chat(aggressor, span_danger(pick(\
							"HAHAHAHA I LOVE THEIR SQUEEK WHEN THEY GET HURT!!",\
							"NNGHHH FUCK!!",\
							"VIOLENCE VIOLENCE VIOLENCE VIOLENCE VIOLENCE!!",\
							"FUCKING FUCK SHIT AND FUCKHEADS BULLSHIT WHORES 'N BITCHES!!"\
						)))
					if(2)
						aggressor.say(pick("ААААААААААА!!!!", "ГРРР!!!", "СУКА!! БЛЯТЬ!!!", "ЁБАНЫЕ ГОВНЮКИ!!", "ВАААААААГХХ!!"))

	if(A.stage >= 5 && prob(50))
		if(aggressor.incapacitated())
			aggressor.visible_message(span_danger("[aggressor] spasms and twitches!"))
			return
		aggressor.visible_message(span_danger("[aggressor] thrashes around violently!"))

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
	return

/datum/symptom/aggression/proc/UnarmedAttack(mob/living/carbon/human/aggressor)
	var/mob/living/victim = GetLivingTarget(1, aggressor)
	if(istype(victim))
		aggressor.dna?.species?.harm(aggressor, victim)

/datum/symptom/aggression/proc/GunAttack(mob/living/carbon/human/aggressor, obj/item/gun/attacking_item)
	var/mob/living/victim = GetLivingTarget(7, aggressor)
	if(istype(victim))
		attacking_item.process_fire(victim, aggressor)

/datum/symptom/aggression/proc/WeaponAttack(mob/living/carbon/human/aggressor, obj/item/attacking_item)
	var/mob/living/victim = GetLivingTarget(1, aggressor)
	if(istype(victim))
		attacking_item.attack(victim, aggressor)

/datum/symptom/proc/GetLivingTarget(distance, mob/living/carbon/human/aggressor)
	var/list/victims = oview(distance, aggressor) - aggressor
	var/length = victims.len
	var/mob/living/victim
	for(var/i = 0, i < length, i++)
		victim = pick_n_take(victims)
		if(istype(victim) && victim.stat == CONSCIOUS)
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
	severity = 4

/datum/symptom/obsession/Activate(datum/disease/virus/advance/A)
	..()
	var/mob/living/carbon/human/possesed = A.affected_mob
	if(!istype(possesed))
		return

	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		switch(A.stage)
			if(2, 3)
				to_chat(possesed, span_alert(pick("You can't control yourself",\
					"You notice your actions differ from your thoughts",\
					"Why did I do that?",\
					"What just happened?"\
				)))
			if(4, 5)
				possesed.emote(pick("twitch_s", "twitch", "drool","blink_r"))
				to_chat(possesed, span_alert(pick("Everything falls out of hand",\
					"It's almost like something is controlling your body",\
					"You feel an urge to do something",\
					"You can't control yourself!"\
				)))

	if(A.stage >= 5 && prob(30))
		if(possesed.incapacitated())
			possesed.visible_message(span_danger("[possesed] twitches!"))
			return

		var/obj/item/item = possesed.get_item_by_slot(slot_r_hand)
		if(!item)
			item = possesed.get_item_by_slot(slot_l_hand)
		if(!item)
			item = TakeItem(possesed)
		if(!item)
			return

		if(istype(item, /obj/item/gun))
			var/obj/item/gun/gun = item
			UseGun(possesed, gun)
		else
			item.attack_self(possesed)
			if(item != possesed.get_active_hand())
				possesed.swap_hand()
			possesed.throw_item(locate(/turf) in shuffle(view(3, possesed)))


	return

/datum/symptom/obsession/proc/TakeItem(mob/living/carbon/human/H)
	var/list/targets = orange(1, H)
	var/obj/item/target = locate(/obj/item) in shuffle(targets)
	if(istype(target) && target.Adjacent(H) && !target.anchored)
		target.forceMove(get_turf(H))
		H.put_in_hands(target)
		return target

/datum/symptom/obsession/proc/UseGun(mob/living/carbon/human/aggressor, obj/item/gun/attacking_item)
	var/list/targets = range(7, aggressor)
	var/turf/target = locate(/turf) in shuffle(targets)
	if(istype(target))
		attacking_item.process_fire(target, aggressor)

