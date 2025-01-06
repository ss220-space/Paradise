/datum/objective/devil

/datum/objective/devil/soulquantity
	needs_target = FALSE
	explanation_text = "You shouldn't see this text.  Error:DEVIL1"
	antag_menu_name = "Завладеть душами"
	target_amount = 4

/datum/objective/devil/soulquantity/New()
	target_amount = pick(6, 7, 8)
	update_explanation_text()

/datum/objective/devil/proc/update_explanation_text()
	//Intentionally empty

/datum/objective/devil/soulquantity/update_explanation_text()
	explanation_text = "Purchase, and retain control over at least [target_amount] souls."

/datum/objective/devil/soulquantity/check_completion()
	var/count = 0
	for(var/S in owner.devilinfo.soulsOwned)
		var/datum/mind/L = S
		if(L.soulOwner == owner)
			count++
	return count >= target_amount



/datum/objective/devil/soulquality
	needs_target = FALSE
	explanation_text = "You shouldn't see this text.  Error:DEVIL2"
	antag_menu_name = "Заключить контракты"
	var/contractType
	var/contractName

/datum/objective/devil/soulquality/New()
	contractType = pick(CONTRACT_POWER, CONTRACT_WEALTH, CONTRACT_PRESTIGE, CONTRACT_MAGIC, CONTRACT_REVIVE, CONTRACT_KNOWLEDGE)
	target_amount = pick(1, 2)
	switch(contractType)
		if(CONTRACT_POWER)
			contractName = "на силу"
		if(CONTRACT_WEALTH)
			contractName = "на богатство"
		if(CONTRACT_PRESTIGE)
			contractName = "на престиж"
		if(CONTRACT_MAGIC)
			contractName = "на магию"
		if(CONTRACT_REVIVE)
			contractName = "на возраждение"
		if(CONTRACT_KNOWLEDGE)
			contractName = "на знание"
	update_explanation_text()

/datum/objective/devil/soulquality/update_explanation_text()
	explanation_text = "Убедить смертных подписать как минимум [target_amount] контрактов [contractName]."

/datum/objective/devil/soulquality/check_completion()
	var/count = 0
	for(var/S in owner.devilinfo.soulsOwned)
		var/datum/mind/L = S
		if(L.soulOwner != L && L.damnation_type == contractType)
			count++
	return count >= target_amount



/datum/objective/devil/sintouch
	needs_target = FALSE
	explanation_text = "You shouldn't see this text.  Error:DEVIL3"
	antag_menu_name = "Осквернить души"

/datum/objective/devil/sintouch/New()
	target_amount = pick(4, 5)
	explanation_text = "Убедитесь, что хотя бы [target_amount] было осквернено грехом."

/datum/objective/devil/sintouch/check_completion()
	return target_amount <= SSticker.mode.sintouched.len



/datum/objective/devil/buy_target
	explanation_text = "You shouldn't see this text.  Error:DEVIL4"
	antag_menu_name = "Завладеть душой"


/datum/objective/devil/buy_target/New()
	find_target()
	update_explanation_text()

/datum/objective/devil/buy_target/update_explanation_text()
	if(target)
		explanation_text = "Купите и сохраните душу [target.name], [target.assigned_role]."
	else
		explanation_text = "Свободная цель."

/datum/objective/devil/buy_target/check_completion()
	return target.soulOwner == owner


/datum/objective/devil/outsell
	explanation_text = "You shouldn't see this text.  Error:DEVIL5"
	antag_menu_name = "Конкуренция за души"

/datum/objective/devil/outsell/update_explanation_text()
	explanation_text = "Приобретите и сохраните контроль над большим количеством душ, чем [target.devilinfo.truename], известным смертным как [target.name], [target.assigned_role]."

/datum/objective/devil/outsell/check_completion()
	var/selfcount = 0
	for(var/S in owner.devilinfo.soulsOwned)
		var/datum/mind/L = S
		if(L.soulOwner == owner)
			selfcount++
	var/targetcount = 0
	for(var/S in target.devilinfo.soulsOwned)
		var/datum/mind/L = S
		if(L.soulOwner == target)
			targetcount++
	return selfcount > targetcount
