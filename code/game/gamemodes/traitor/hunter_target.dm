/datum/hunter_target	//цель тритора для "особых случаев"
	var/datum/mind/hunter = null	//ссылка на охотника
	var/datum/objective/pain_hunter/objective = null	//ссылка на задачу с которой на него охотятся
	var/damage_type = BRUTE
	//var/damage_count = 0

/datum/hunter_target/proc/take_damage(var/damage)
	objective.damage_target += damage
	objective.update_explain_text()

//задача на принесение боли
/datum/objective/pain_hunter
	martyr_compatible = 1
	var/damage_need = 200
	var/damage_type = BRUTE
	var/damage_target = 0

/datum/objective/pain_hunter/find_target()
	..()
	if(target && target.current)
		message_admins("Дошел до таргета")
		random_type()
		update_target_datum()
		update_explain_text()
	else
		message_admins("Дошел до элсе таргета")
		explanation_text = "Free Objective"
	return target

/datum/objective/pain_hunter/proc/update_target_datum()
	target.hunter_target = new /datum/hunter_target
	target.hunter_target.objective = src
	target.hunter_target.hunter = owner
	target.hunter_target.damage_type = damage_type


/datum/objective/pain_hunter/proc/update_explain_text()
	message_admins("Обновлен")
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
			if(TOX)
				return body.getToxLoss() >= damage_target
	return FALSE

/datum/objective/pain_hunter/proc/random_type()
	damage_need = rand(2, 8) * 100
	damage_type = BRUTE
	if (prob(30))
		damage_type = BURN
		damage_need = (damage_need * 0.75) - (damage_need % 50)	//уменьшаем урон, так как его сделать сложнее. Также сокращяем для красивых цифр.
		if (prob(30))
			damage_type = TOX
			damage_need = (damage_need * 0.5 > 100 ? damage_need * 0.5 : 100) - damage_need > 100 ? (damage_need % 50) : 0

/datum/objective/pain_hunter/proc/damage_explain()
	var/damage_explain = damage_type
	switch(damage_type)
		if(BRUTE)
			damage_explain = "грубого"
		if(BURN)
			damage_explain = "жженого"
		if(TOX)
			damage_explain = "токсичного"
	return damage_explain
