/**
Black Rain Group (BRG) account
Required for some PDA applications created by BRG.
Stores your account balance, photos, and other necessary variables.
*/
/datum/brg_account
	// base information for account
	var/datum/money_account/owner
	// profile photo, mirrored from the owner's ID photo record
	var/photo

	//RainDrop-specific account data
	// current rating sum
	var/rating_total = 0
	// amount of ratings
	var/rating_count = 0
	// created offers
	var/list/datum/rainDrop_offer/created_offers = list()
	// taken offers
	var/list/datum/rainDrop_offer/taken_offers = list()

/datum/brg_account/New(datum/money_account/owner_account)
	owner = owner_account
	set_photo()

/datum/brg_account/proc/set_photo()
	if(photo)
		return
	var/datum/data/record/general_record = GLOB.data_core.find_general_record_by_name(owner.owner_name)
	if(general_record)
		photo = general_record.fields["photo-south"]

/datum/brg_account/proc/get_account_info()
	var/list/member = list()
	set_photo()

	// Base account information
	member["name"] = owner.owner_name
	member["account_number"] = owner.account_number
	member["account_balance"] = owner.money
	member["photo"] = photo
	// RainDrop-specific account information
	member["rating"] = get_rating()
	member["rating_count"] = rating_count
	member["completed_count"] = get_completed_count()

	return member

/datum/brg_account/proc/get_rating()
	if(!rating_count)
		return 0

	return round(rating_total / rating_count, 0.1)

/datum/brg_account/proc/add_rating(value)
	value = clamp(value, 0, 5)

	rating_total += value
	rating_count++

/// Number of jobs this account has successfully completed as an executor.
/datum/brg_account/proc/get_completed_count()
	var/count = 0
	var/list/jobs = taken_offers
	for(var/datum/rainDrop_offer/offer as anything in jobs)
		if(offer.status == RAINDROP_STATUS_COMPLETED)
			count++
	return count

/// Number of orders this account currently has open or in progress as a client.
/datum/brg_account/proc/get_active_orders_count()
	var/count = 0
	var/list/orders = created_offers
	for(var/datum/rainDrop_offer/offer as anything in orders)
		if(offer.status == RAINDROP_STATUS_OPEN || offer.status == RAINDROP_STATUS_TAKEN || offer.status == RAINDROP_STATUS_SUBMITTED)
			count++
	return count
