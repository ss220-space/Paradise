/datum/subscription/salary_modifier
	/// Percentage change in salary
	subscription_name = "Корректировка заработной платы"
	description = "Изменение коэффициента оплаты труда в соответствии с должностными инструкциями. За разъяснениями, согласованием или отменой параметра обращайтесь к Главе Персонала."
	interval = FREQUENCY_SALARY
	secure = TRUE

	var/modifier = 0
	// This is necessary for dynamic changes and so that the search knows who to look for a subscription from | Whose salary is being modified?
	var/datum/money_account/target_account

/datum/subscription/salary_modifier/New(datum/money_account/subscriber, extra_params)
	target_account = subscriber

	modifier = extra_params ? extra_params["modifier"] : 0
	modifier = text2num(modifier)
	modifier = clamp(modifier, -50, 50)

	var/datum/job/curr_job = subscriber.linked_job
	var/base_paycheck = curr_job?.paycheck || 0

	if(modifier <= 0)
		subscriber_account = target_account
		recipient_account = GLOB.station_account
		cost = abs(base_paycheck * (modifier / 100))
	else
		subscriber_account = GLOB.station_account
		recipient_account = target_account
		cost = base_paycheck * (modifier / 100)

	..(subscriber_account, null)

/datum/subscription/salary_modifier/proc/update_modifier(new_modifier)
	new_modifier = text2num(new_modifier)
	new_modifier = clamp(new_modifier, -50, 50)

	if(new_modifier == modifier)
		return TRUE

	modifier = new_modifier

	var/datum/job/user_job = target_account?.linked_job
	var/base_paycheck = user_job?.paycheck || 0

	if(modifier < 0)
		recipient_account = GLOB.station_account
		subscriber_account = target_account
		cost = abs(base_paycheck * (modifier / 100))
	else
		recipient_account = target_account
		subscriber_account = GLOB.station_account
		cost = base_paycheck * (modifier / 100)

	active = TRUE

	return TRUE
