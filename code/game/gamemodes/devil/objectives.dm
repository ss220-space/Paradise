/datum/objective/devil

/datum/objective/devil/sacrifice
	var/list/target_minds = list()
	needs_target = FALSE
	check_cryo = FALSE
	explanation_text = 'meow'

/datum/objective/devil/sacrifice/New()
	get_targets()

	for(var/datum/mind/mind in target_minds)
		LAZYADD(explanation_text, "Принесите в жертву [mind.name], [mind.assigned_role]")

/datum/objective/devil/sacrifice/proc/get_targets()
	var/list/command_minds = list()
	var/list/security_minds = list()
	var/list/other_minds = list()

	var/list/command_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_RD, JOB_TITLE_CMO, JOB_TITLE_HOP, JOB_TITLE_HOS, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_JUDGE)
	var/list/security_roles = list(JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

	for(var/datum/mind/mind in SSticker.minds)
		if(mind == owner)
			continue

		if(!ishuman(mind.current) || mind.current.stat == DEAD || mind.offstation_role)
			continue

		if(mind.assigned_role in command_roles)
			LAZYADD(command_minds, mind)

		else if(mind.assigned_role in security_roles)
			LAZYADD(security_minds, mind)

		else
			LAZYADD(other_minds, mind)

	LAZYADD(target_minds, safepick(command_minds))
	LAZYADD(target_minds, security_minds.Copy(1, 4))
	LAZYADD(target_minds, other_minds.Copy(1, 9))

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
