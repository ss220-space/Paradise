/*
//////////////////////////////////////

Damage Converter

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Reduced transmittablity
	Intense Level.

Bonus
	Slowly converts brute/fire damage to toxin.

//////////////////////////////////////
*/

/datum/symptom/damage_converter

	name = "Toxic Compensation"
	id = "damage_converter"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -2
	level = 4

/datum/symptom/damage_converter/Activate(datum/disease/virus/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				Convert(M)
	return

/datum/symptom/damage_converter/proc/Convert(mob/living/M)

	var/get_damage = rand(1, 2)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		var/list/parts = H.get_damaged_organs(1, 1, AFFECT_ORGANIC_ORGAN) //1,1 because it needs inputs.

		if(!length(parts))
			return
		var/healed = 0
		var/update_health = STATUS_UPDATE_NONE
		var/update_damage_icon = NONE
		for(var/obj/item/organ/external/bodypart as anything in parts)
			var/brute_was = bodypart.brute_dam
			var/burn_was = bodypart.burn_dam
			update_damage_icon |= bodypart.heal_damage(get_damage, get_damage, updating_health = FALSE)
			if(bodypart.brute_dam != brute_was || bodypart.burn_dam != burn_was)
				update_health |= STATUS_UPDATE_HEALTH
				healed += max(((bodypart.brute_dam - brute_was) + (bodypart.burn_dam - burn_was)), get_damage)

		if(healed)
			update_health |= H.apply_damage(healed, TOX)
		if(update_health)
			H.updatehealth("[name]")
		if(update_damage_icon)
			H.UpdateDamageIcon()

	else
		if(M.getFireLoss() > 0 || M.getBruteLoss() > 0)
			var/update = NONE
			update |= M.heal_overall_damage(get_damage, get_damage, FALSE)
			update |= M.heal_damage_type(get_damage, TOX, FALSE)
			if(update)
				M.updatehealth("damage converter symptom")
		else
			return

	return 1




