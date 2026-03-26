// ======================================================================================
//								    Additional Tools
// ======================================================================================
/proc/find_subscription_with_type(subscriber_account_name, subscription_type)
	for(var/datum/subscription/checked_sub as anything in GLOB.all_subscriptions)
		if(checked_sub.subscription_type_path == subscription_type && checked_sub.subscriber_account.owner_name == subscriber_account_name)
			return checked_sub

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

	// Find a template in the catalog of available subscriptions
	var/datum/subscription/template = locate(subscription_type) in GLOB.available_subscriptions

	if(!template)
		CRASH("Subscription type [subscription_type] not found in catalog - forgot to register it?")

	find_existhing(subscriber_account, subscription_type, template)

	var/datum/subscription/new_sub = new subscription_type(subscriber_account, extra_params)

	if(!is_subscription(new_sub) || !new_sub.active)
		to_chat(usr, span_warning("Критическая ошибка: не удалось создать или активировать подписку."))
		return FALSE

	to_chat(usr, span_good("Подписка '[new_sub.subscription_name]' успешно оформлена."))
	return TRUE

/proc/find_existhing(datum/money_account/subscriber_account, subscription_type, datum/subscription/template)
	var/datum/subscription/existing = find_subscription_with_type(subscriber_account.owner_name, subscription_type)

	if(existing)
		if(existing.active)
			to_chat(usr, span_warning("У вас уже есть активная подписка '[template.subscription_name]'."))
			return FALSE
		else
			existing.resub()
			if(existing.active)
				to_chat(usr, span_warning("Подписка '[template.subscription_name]' была ранее оформлена и восстановлена."))
				return TRUE
			else
				to_chat(usr, span_warning("Не удалось восстановить подписку '[template.subscription_name]'."))
				return FALSE

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
