// RainDrop user account
/datum/rainDrop_account
	// linked bank account
	var/datum/money_account/owner
	// profile photo
	var/photo
	// current rating sum
	var/rating_total = 0
	// amount of ratings
	var/rating_count = 0
	// created offers
	var/list/datum/rainDrop_offer/created_offers = list()
	// taken offers
	var/list/datum/rainDrop_offer/taken_offers = list()

/datum/rainDrop_account/New(datum/money_account/owner_account)
	src.owner = owner_account

/datum/rainDrop_account/proc/set_photo()
	if(!!photo)
		return
	var/datum/data/record/general_record = GLOB.data_core.find_general_record_by_name(owner.owner_name)
	if(general_record)
		src.photo = general_record.fields["photo-south"]

/datum/rainDrop_account/proc/get_rating()
	if(!rating_count)
		return 0

	return round(rating_total / rating_count, 0.1)

/datum/rainDrop_account/proc/add_rating(value)
	value = clamp(value, 0, 5)

	rating_total += value
	rating_count++

/datum/rainDrop_account/proc/get_account_info()
	var/list/data = list()

	set_photo()

	data["name"] = owner.owner_name
	data["account_number"] = owner.account_number
	data["photo"] = photo
	data["rating"] = get_rating()
	data["rating_count"] = rating_count

	return data
