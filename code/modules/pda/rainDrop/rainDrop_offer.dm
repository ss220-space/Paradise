/// Single freelance order
/datum/rainDrop_offer
	// order title
	var/title
	// order description
	var/description
	// full reward amount
	var/reward = 0
	// creator account
	var/datum/rainDrop_account/client
	// executor account
	var/datum/rainDrop_account/worker
	// current status
	var/status = RAINDROP_STATUS_OPEN
	// creation timestamp
	var/created_at
	// completion timestamp
	var/completed_at
	// client review
	var/review_rating = null

/datum/rainDrop_offer/New(
	title_text,
	description_text,
	reward_amount,
	datum/rainDrop_account/client_account
)
	title = title_text
	description = description_text
	reward = reward_amount
	client = client_account
	created_at = world.time

/datum/rainDrop_offer/proc/get_executor_reward()
	return round(reward * 0.8)

/datum/rainDrop_offer/proc/get_cancel_refund()
	return round(reward * 0.8)

/datum/rainDrop_offer/proc/get_dispute_client_refund()
	return round(reward * 0.4)

/datum/rainDrop_offer/proc/get_dispute_worker_reward()
	return round(reward * 0.2)

/datum/rainDrop_offer/proc/get_offer_data()
	var/list/data = list()

	data["id"] = UID()
	data["title"] = title
	data["description"] = description
	data["reward"] = reward
	data["status"] = status
	data["created_at"] = created_at

	if(client)
		data["client"] = client.get_account_info()

	if(worker)
		data["worker"] = worker.get_account_info()

	return data
