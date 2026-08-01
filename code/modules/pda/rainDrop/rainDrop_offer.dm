/// Single freelance order posted through the RainDrop PDA app.
/datum/rainDrop_offer
	// order title
	var/title
	// order description
	var/description
	// full reward amount, frozen from the client's account the moment the order is posted
	var/reward = 0
	// creator account
	var/datum/brg_account/client
	// executor account
	var/datum/brg_account/worker
	// current status, one of the RAINDROP_STATUS_* defines
	var/status = RAINDROP_STATUS_OPEN
	// creation timestamp, world.time
	var/created_at
	// completion timestamp, world.time
	var/completed_at
	// client review, 0 to 5
	var/review_rating = null

/datum/rainDrop_offer/New(
	title_text,
	description_text,
	reward_amount,
	datum/brg_account/client_account
)
	title = title_text
	description = description_text
	reward = reward_amount
	client = client_account
	created_at = world.time

/// Amount actually paid out to the executor once the client confirms the job is done.
/datum/rainDrop_offer/proc/get_executor_reward()
	return round(reward * RAINDROP_EXECUTOR_CUT)

/// Amount refunded to the client if they withdraw an order nobody has taken yet.
/datum/rainDrop_offer/proc/get_cancel_refund()
	return round(reward * RAINDROP_CANCEL_REFUND_CUT)

/// Client's share of the frozen reward if the order ends in a dispute.
/datum/rainDrop_offer/proc/get_dispute_client_refund()
	return round(reward * RAINDROP_DISPUTE_CLIENT_CUT)

/// Executor's share of the frozen reward if the order ends in a dispute.
/datum/rainDrop_offer/proc/get_dispute_worker_reward()
	return round(reward * RAINDROP_DISPUTE_WORKER_CUT)

/datum/rainDrop_offer/proc/get_offer_data()
	var/list/data = list()

	data["id"] = UID()
	data["title"] = title
	data["description"] = description
	data["reward"] = reward
	data["status"] = status
	data["created_at"] = created_at
	data["review_rating"] = review_rating

	if(client)
		data["client"] = client.get_account_info()

	if(worker)
		data["worker"] = worker.get_account_info()

	return data
