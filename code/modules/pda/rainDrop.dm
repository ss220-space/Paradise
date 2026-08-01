/datum/data/pda/app/rainDrop
	name = "RainDrop"
	icon = "briefcase"
	title = "RainDrop"
	template = "pda_rainDrop"

	/// RainDrop account of whoever is currently logged in on this PDA.
	/// Cached so the app stays logged in even if the ID card is pulled back out.
	var/datum/brg_account/last_login_owner

/datum/data/pda/app/rainDrop/update_ui(mob/user, list/data)
	var/datum/brg_account/owner_rainDrop_account = login_in_messenger(data)
	if(!owner_rainDrop_account)
		return

	data["account"] = owner_rainDrop_account.get_account_info()
	data["world_time"] = world.time

	var/list/offers = list()
	var/list/all_offers = GLOB.rainDrop_offers
	for(var/datum/rainDrop_offer/offer as anything in all_offers)
		offers += list(offer.get_offer_data())

	data["offers"] = offers

/datum/data/pda/app/rainDrop/ui_act(action, list/params)
	if(!last_login_owner)
		return

	switch(action)
		if("create_offer")
			var/title = params["title"]
			var/description = params["description"]
			var/reward = params["reward"]
			create_rainDrop_offer(last_login_owner, title, description, reward)
			return TRUE

		if("take_offer")
			var/datum/rainDrop_offer/offer = locateUID(params["id"])
			take_rainDrop_offer(offer, last_login_owner)
			return TRUE

		if("submit_offer")
			var/datum/rainDrop_offer/offer = locateUID(params["id"])
			submit_rainDrop_offer(offer, last_login_owner)
			return TRUE

		if("complete_offer")
			var/datum/rainDrop_offer/offer = locateUID(params["id"])
			var/rating = params["rating"]
			complete_rainDrop_offer(offer, last_login_owner, rating)
			return TRUE

		if("cancel_offer")
			var/datum/rainDrop_offer/offer = locateUID(params["id"])
			cancel_rainDrop_offer(offer, last_login_owner)
			return TRUE

		if("dispute_offer")
			var/datum/rainDrop_offer/offer = locateUID(params["id"])
			dispute_rainDrop_offer(offer, last_login_owner)
			return TRUE

		if("transfer_money")
			var/target = params["target"]
			var/amount = params["amount"]
			var/note = params["note"]
			transfer_rainDrop_money(last_login_owner, target, amount, note)
			return TRUE

		if("logout")
			last_login_owner = null
			return TRUE

// Logs in and returns the RainDrop account tied to whoever's ID is (or was) in the PDA, or null.
/datum/data/pda/app/rainDrop/proc/login_in_messenger(list/data)
	if(!pda.id && !last_login_owner)
		return null

	var/datum/money_account/owner_money_account = get_account_with_name(pda.owner)
	if(!owner_money_account)
		return null

	data["targets"] = get_all_targets(owner_money_account)

	var/datum/brg_account/owner_rainDrop_account = owner_money_account.brg_profile
	if(!owner_rainDrop_account)
		return null

	// cache the login so pulling the ID back out doesn't kick the user from the app
	last_login_owner = owner_rainDrop_account
	return owner_rainDrop_account

// Builds the list of accounts available as P2P transfer targets, excluding the caller's own account.
/datum/data/pda/app/rainDrop/proc/get_all_targets(datum/money_account/exclude_account)
	var/list/all_targets = list()
	var/list/all_accounts = GLOB.all_money_accounts
	for(var/datum/money_account/target_account as anything in all_accounts)
		if(target_account == exclude_account)
			continue
		all_targets += list(list(
			"name" = target_account.owner_name,
			"account_number" = target_account.account_number,
		))
	return all_targets
