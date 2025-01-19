/datum/objective/devil

/datum/objective/devil/sacrifice
	var/list/target_minds = list()
	needs_target = FALSE
	check_cryo = FALSE
	target_amount = 12
	explanation_text = "" 

/datum/objective/devil/sacrifice/proc/forge()
	if(!get_targets())
		return FALSE

	for(var/datum/mind/mind in target_minds)
		explanation_text += "Принесите в жертву [mind.name], [mind.assigned_role].\n<br>"

	return TRUE

/datum/objective/devil/sacrifice/proc/get_targets()
	var/list/command_minds = list()
	var/list/security_minds = list()
	var/list/other_minds = list()

	for(var/datum/mind/mind in SSticker.minds)
		if(mind == owner)
			continue

		if(!ishuman(mind.current) \
		|| mind.current.stat == DEAD \
		|| mind.offstation_role)
			continue

		if(LAZYIN(GLOB.command_positions, mind.assigned_role))
			LAZYADD(command_minds, mind)

		else if(LAZYIN(GLOB.security_positions, mind.assigned_role))
			LAZYADD(security_minds, mind)

		else
			LAZYADD(other_minds, mind)

	var/command_target_count = ceil(target_amount / 12)
	var/security_target_count = floor(target_amount / 4)
	var/other_target_count = target_amount - command_target_count - security_target_count

	if(LAZYLEN(command_minds) < command_target_count || LAZYLEN(security_minds) < security_target_count || LAZYLEN(other_minds) < other_target_count)
		return FALSE

	for(var/i in 1 to command_target_count)
		LAZYADD(target_minds, pick_n_take(command_minds))

	for(var/i in 1 to security_target_count)
		LAZYADD(target_minds, pick_n_take(security_minds))

	for(var/i in 1 to other_target_count)
		LAZYADD(target_minds, pick_n_take(other_minds))

	return TRUE

/datum/objective/devil/sacrifice/check_completion()
	var/list/collected_minds = list()

	for(var/datum/mind/mind as anything in target_minds)
		if(mind.hasSoul)
			continue

		LAZYADD(collected_minds, mind)

	return LAZYLEN(collected_minds) > target_amount

/datum/objective/devil/sintouch
	needs_target = FALSE
	explanation_text = "You shouldn't see this text.  Error:DEVIL3"

/datum/objective/devil/sintouch/New()
	target_amount = pick(4, 5)
	explanation_text = "Ensure at least [target_amount] mortals are sintouched."

/datum/objective/devil/sintouch/check_completion()
	return target_amount <= SSticker.mode.sintouched.len

/datum/objective/devil/ascend
	explanation_text = "Ascend to your true form."
	needs_target = FALSE

/datum/objective/devil/ascend/check_completion()
	return isdevil(owner)
