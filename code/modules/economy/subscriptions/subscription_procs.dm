// ======================================================================================
//								    Additional Tools
// ======================================================================================
/proc/find_subscription_with_name(subscriber_account_name, target_subscription_name)
	for(var/datum/subscription/check_subscription as anything in GLOB.all_subscriptions)
		if(check_subscription.subscription_name ==  target_subscription_name && check_subscription.subscriber_account.owner_name == subscriber_account_name)
			return check_subscription
	return

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
	// 9 rounds of testing
	if(!subscriber_account || !is_money_account(subscriber_account))
		to_chat(usr, span_warning("Ошибка: неверный аккаунт подписчика."))
		return FALSE

	if(!subscription_type || !ispath(subscription_type,/datum/subscription))
		to_chat(usr, span_warning("Ошибка: неверный тип подписки."))
		return FALSE

	if(subscriber_account.suspended)
		to_chat(usr, span_warning("Ошибка: аккаунт #[subscriber_account.account_number] заблокирован."))
		return FALSE

	/// Find a template in the catalog of available subscriptions
	var/datum/subscription/template = locate(subscription_type) in GLOB.available_subscriptions

	if(!template)
		to_chat(usr, span_warning("Ошибка: подписка типа [subscription_type] не найдена в каталоге."))
		return FALSE

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

	var/datum/subscription/new_sub = new subscription_type(subscriber_account, extra_params)

	if(!new_sub || !is_subscription(new_sub) || !new_sub.active)
		to_chat(usr, span_warning("Критическая ошибка: не удалось создать или активировать подписку."))
		return FALSE

	to_chat(usr, span_good("Подписка '[new_sub.subscription_name]' успешно оформлена."))
	return TRUE

/**
 * This process is one of the basic ones; if you don’t add your subscription
 * as a test one, it won’t be displayed!
*/
/datum/controller/subsystem/subscriptions_subsystem/proc/initialize_catalog()
	GLOB.available_subscriptions.Cut()
	/// Because this is a DEMONSTRATION SUBSCRIPTION (the one that is not active, but which shows what subscriptions exist),
	/// you must make sure that this subscription has sender and recipient accounts GLOB.station_account
	GLOB.available_subscriptions += new /datum/subscription/station_donations(GLOB.station_account)
	GLOB.available_subscriptions += new /datum/subscription/salary_modifier(GLOB.station_account)
