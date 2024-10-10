/obj/effect/proc_holder/spell/inflict_handler
	name = "Inflict Handler"
	desc = "Это заклинание ослепляет и/или уничтожает/повреждает/лечит и/или ослабляет/оглушает цель." // я честно хз как это перевести нормально

	var/amt_weakened = 0
	var/amt_paralysis = 0
	var/amt_stunned = 0

	//set to negatives for healing
	var/amt_dam_fire = 0
	var/amt_dam_brute = 0
	var/amt_dam_oxy = 0
	var/amt_dam_tox = 0

	var/amt_eye_blind = 0
	var/amt_eye_blurry = 0

	var/destroys = "none" //can be "none", "gib" or "disintegrate"

	var/summon_type = null //this will put an obj at the target's location


/obj/effect/proc_holder/spell/inflict_handler/create_new_targeting()
	return new /datum/spell_targeting/self // Dummy value since it is never used for this spell... why is this even a spell


/obj/effect/proc_holder/spell/inflict_handler/cast(list/targets, mob/user = usr)

	for(var/mob/living/target in targets)
		switch(destroys)
			if("gib")
				target.gib()
			if("disintegrate")
				target.dust()

		if(!target)
			continue
		//damage
		var/update = NONE
		if(amt_dam_brute > 0)
			if(amt_dam_fire >= 0)
				update |= target.take_overall_damage(amt_dam_brute, amt_dam_fire)
			else if(amt_dam_fire < 0)
				update |= target.take_overall_damage(amt_dam_brute, 0)
				update |= target.heal_overall_damage(0, amt_dam_fire)
		else if(amt_dam_brute < 0)
			if(amt_dam_fire > 0)
				update |= target.take_overall_damage(0, amt_dam_fire)
				update |= target.heal_overall_damage(amt_dam_brute, 0)
			else if(amt_dam_fire <= 0)
				update |= target.heal_overall_damage(amt_dam_brute, amt_dam_fire)
		update |= target.adjustToxLoss(amt_dam_tox, FALSE)
		update |= target.adjustOxyLoss(amt_dam_oxy, FALSE)
		if(update)
			target.updatehealth("Spell Inflict Handler")
		//disabling
		target.Weaken(amt_weakened)
		target.Paralyse(amt_paralysis)
		target.Stun(amt_stunned)

		target.AdjustEyeBlind(amt_eye_blind)
		target.AdjustEyeBlurry(amt_eye_blurry)
		//summoning
		if(summon_type)
			new summon_type(target.loc, target)

