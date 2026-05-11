// global RainDrop offers
GLOBAL_LIST_EMPTY(rainDrop_offers)

/// Create offer
/proc/create_rainDrop_offer(
	datum/rainDrop_account/client,
	title,
	description,
	reward
)
	if(!client)
		return FALSE
	if(reward <= 0)
		return FALSE
	if(client.owner.money < reward)
		return FALSE

	// freeze money
	client.owner.money -= reward
	var/datum/rainDrop_offer/offer = new(
		title,
		description,
		reward,
		client
	)

	client.created_offers += offer
	GLOB.rainDrop_offers += offer
	return offer

/// Take offer
/proc/take_rainDrop_offer(
	datum/rainDrop_offer/offer,
	datum/rainDrop_account/worker
)
	if(!offer || !worker)
		return FALSE
	if(offer.status != RAINDROP_STATUS_OPEN)
		return FALSE
	if(offer.client == worker)
		return FALSE

	offer.worker = worker
	offer.status = RAINDROP_STATUS_TAKEN
	worker.taken_offers += offer

	return TRUE

/// Complete order successfully
/proc/complete_rainDrop_offer(
	datum/rainDrop_offer/offer,
	rating
)
	if(!offer)
		return FALSE
	if(offer.status != RAINDROP_STATUS_TAKEN)
		return FALSE
	if(!offer.worker)
		return FALSE

	var/payment = offer.get_executor_reward()

	offer.worker.owner.money += payment
	offer.status = RAINDROP_STATUS_COMPLETED
	offer.completed_at = world.time
	rating = clamp(rating, 0, 5)
	offer.review_rating = rating
	offer.worker.add_rating(rating)

	return TRUE

/// Cancel order
/proc/cancel_rainDrop_offer(
	datum/rainDrop_offer/offer
)
	if(!offer)
		return FALSE
	if( offer.status != RAINDROP_STATUS_OPEN && offer.status != RAINDROP_STATUS_TAKEN)
		return FALSE

	var/refund = offer.get_cancel_refund()

	offer.client.owner.money += refund
	offer.status = RAINDROP_STATUS_CANCELLED

	return TRUE

/// Dispute order
/proc/dispute_rainDrop_offer(
	datum/rainDrop_offer/offer
)
	if(!offer)
		return FALSE
	if(offer.status != RAINDROP_STATUS_TAKEN)
		return FALSE

	var/client_refund = offer.get_dispute_client_refund()
	var/worker_reward = offer.get_dispute_worker_reward()

	offer.client.owner.money += client_refund

	if(offer.worker)
		offer.worker.owner.money += worker_reward

	offer.status = RAINDROP_STATUS_DISPUTED

	return TRUE
