/**
Black Rain Group (BRG) account
Required for some PDA applications created by BRG.
Stores your account balance, photos, and other necessary variables.
*/

/datum/brg_account
	// base information for account
	var/datum/money_account/owner
	var/photo
	// for bank app
	var/list/subscriptions = list()

/datum/brg_account/New(datum/money_account/owner_account)
	owner = owner_account
	set_photo()

/datum/brg_account/proc/set_photo()
	if(!!photo)
		return
	var/datum/data/record/general_record = GLOB.data_core.find_general_record_by_name(owner.owner_name)
	if(general_record)
		photo = general_record.fields["photo-south"]

/datum/brg_account/proc/get_account_info()
	var/list/member = list()

	// if the account doesnt have a photo, or if the photo is updated, refreshed
	set_photo()

	member["name"] = owner.owner_name
	member["account_number"] = owner.account_number
	member["photo"] = photo

	return member

///Iterates through the input list,
///checking whether the account exists in the given list.
/proc/check_brg_account_in_list(datum/brg_account/checked_account, list/checked_list)
	for(var/datum/brg_account/selected_account as anything in checked_list)
		if(selected_account.owner.account_number == checked_account.owner.account_number)
			return TRUE
	return FALSE

// =================== SUBS METHODS ======================

/// Adds a subscription to the account list
/datum/brg_account/proc/add_subscription(datum/subscription/new_sub)
	if(!new_sub || !is_subscription(new_sub))
		return FALSE

	// Check for duplicates of the same types
	for(var/datum/subscription/existing in subscriptions)
		if(!existing || !existing.active)
			continue

		// If the type matches AND the receiver matches, it's a duplicate
		if(existing.subscription_type_path == new_sub.subscription_type_path && \
			existing.recipient_account == new_sub.recipient_account)
			return FALSE

	subscriptions += new_sub
	return TRUE

/// Delete a subscription from the account list
/datum/brg_account/proc/remove_subscription(datum/subscription/sub_to_remove)
	if(!sub_to_remove)
		return
	subscriptions -= sub_to_remove

/// Return a list of active subscriptions
/datum/brg_account/proc/get_active_subscriptions()
	var/list/active_subs = list()
	for(var/datum/subscription/sub as anything in subscriptions)
		if(sub && sub.active)
			active_subs += sub
	return active_subs

/// Return a list of all subscriptions
/datum/brg_account/proc/get_all_subscriptions()
	return subscriptions

/// Check for an active subscription of specific type
/datum/brg_account/proc/has_subscription_type(path_type)
	if(!path_type)
		return FALSE
	for(var/datum/subscription/sub as anything in subscriptions)
		if(sub && sub.active && sub.subscription_type_path == path_type)
			return TRUE
	return FALSE
