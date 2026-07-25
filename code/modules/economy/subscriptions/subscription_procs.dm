
// Finds the active subscription of a specific subscriber by type.
// Used to check if the account already has a subscription of that type.
/proc/find_subscription_with_type(datum/money_account/subscriber_account, subscription_type)
	if(!subscriber_account || !subscriber_account.brg_profile)
		return null

	var/datum/brg_account/brg = subscriber_account.brg_profile
	for(var/datum/subscription/sub as anything in brg.subscriptions)
		if(sub.active && sub.subscription_type_path == subscription_type)
			return sub
	return null

// Finds a specific salary_modifier subscription for a target account by owner name.
// Used to get salary modification settings regardless of the specific subscriber.
/proc/find_subscription_salary_modifier_spec(target_account_name, subscription_type)
	for(var/datum/subscription/salary_modifier/sub in GLOB.all_subscriptions)
		if(!sub || !sub.target_account)
			continue

		if(sub.subscription_type_path == subscription_type && sub.target_account.owner_name == target_account_name)
			return sub

	return null

/proc/create_subscription(
	datum/money_account/subscriber_account,
	subscription_type,
	extra_params
)
	validate_subscription_inputs(subscriber_account, subscription_type)

	var/datum/subscription/template = locate(subscription_type) in GLOB.available_subscriptions
	if(!template)
		CRASH("Subscription type [subscription_type] not found")

	var/datum/subscription/existing = find_subscription_with_type(subscriber_account, subscription_type)

	if(existing)
		if(existing.active)
			to_chat(usr, span_warning("У вас уже есть активная подписка '[template.subscription_name]'."))
			return FALSE
		existing.resub()
		if(existing.active)
			to_chat(usr, span_warning("Подписка восстановлена."))
			return TRUE
		return FALSE

	var/datum/subscription/new_sub = new subscription_type(subscriber_account, extra_params)

	if(!is_subscription(new_sub) || !new_sub.active)
		to_chat(usr, span_warning("Ошибка создания подписки."))
		return FALSE

	to_chat(usr, span_good("Подписка '[new_sub.subscription_name]' оформлена."))
	return TRUE

/proc/validate_subscription_inputs(datum/money_account/subscriber_account, subscription_type)
	if(!is_money_account(subscriber_account))
		to_chat(usr, span_warning("Ошибка: неверный аккаунт подписчика."))
		return FALSE

	if(!subscription_type)
		CRASH("Invalid subscription type: [subscription_type]")

	if(subscriber_account.suspended)
		to_chat(usr, span_warning("Ошибка: аккаунт #[subscriber_account.account_number] заблокирован."))
		return FALSE

/**
 * This process is one of the basic ones; if you don’t add your subscription
 * as a test one, it won’t be displayed!
*/
/datum/controller/subsystem/subscriptions_subsystem/proc/initialize_catalog()
	GLOB.available_subscriptions.Cut()
	// Because this is a DEMONSTRATION SUBSCRIPTION (the one that is not active, but which shows what subscriptions exist),
	// you must make sure that this subscription has sender and recipient accounts GLOB.station_account
	GLOB.available_subscriptions += new /datum/subscription/station_donations(GLOB.station_account)
	GLOB.available_subscriptions += new /datum/subscription/salary_modifier(GLOB.station_account)
