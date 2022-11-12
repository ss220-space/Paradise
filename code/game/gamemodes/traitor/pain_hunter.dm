//задача на принесение боли
/datum/objective/pain_hunter
	martyr_compatible = 1
	var/damage_need = 200
	var/damage_type = BRUTE
	var/damage_target = 0

/datum/objective/pain_hunter/proc/take_damage(var/take_damage, var/take_damage_type)
	if (damage_type != take_damage_type)
		return
	damage_target += take_damage
	update_explain_text()

/datum/objective/pain_hunter/New(text)
	. = ..()
	update_explain_text()

/datum/objective/pain_hunter/Destroy()
	var/check_other_hunter = FALSE
	for(var/datum/objective/pain_hunter/objective in GLOB.all_objectives)
		if (target == objective.target)
			check_other_hunter = TRUE
			break
	if(!check_other_hunter)
		SSticker.mode.victims.Remove(target)
	. = ..()

/datum/objective/pain_hunter/find_target()
	..()
	if(target && target.current)
		random_type()
		update_explain_text()
		if (!(target in SSticker.mode.victims))
			SSticker.mode.victims.Add(target)
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/pain_hunter/proc/update_explain_text()
	explanation_text = "Преподать урок и лично нанести [target.current.real_name], [target.assigned_role], не менее [damage_need] [damage_explain()] урона. Цель должна выжить. \nТекущий урон: [damage_target]/[damage_need]"

/datum/objective/pain_hunter/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD)
			return FALSE
		if(issilicon(target.current))
			return FALSE
		if(!iscarbon(target.current))
			return FALSE
		var/mob/living/carbon/body = target.current
		switch (damage_type)
			if(BRUTE)
				return body.getBruteLoss() >= damage_target
			if(BURN)
				return body.getFireLoss() >= damage_target
			//if(TOX)
			//	return body.getToxLoss() >= damage_target
	return FALSE

/datum/objective/pain_hunter/proc/random_type()
	damage_need = rand(2, 8) * 100
	damage_type = BRUTE
	if (prob(30))
		damage_type = BURN
		var/damage_procent = damage_need * 0.75	//уменьшаем урон, так как данным тип уроне сделать сложнее.
		damage_need = damage_procent - damage_procent % 50	//Вычитаем для красивых ровных чисел.
		//if (prob(30))
		//	damage_type = TOX
		//	damage_procent = damage_need * 0.5
		//	damage_need = (damage_procent > 100 ? damage_procent : 100) - (damage_procent > 100 ? (damage_procent % 50) : 0)

/datum/objective/pain_hunter/proc/damage_explain()
	var/damage_explain = damage_type
	switch(damage_type)
		if(BRUTE)
			damage_explain = "грубого"
		if(BURN)
			damage_explain = "ожогового"
		if(TOX)
			damage_explain = "токсичного"
	return damage_explain
