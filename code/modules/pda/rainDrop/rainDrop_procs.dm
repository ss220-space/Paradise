// global list of every RainDrop offer that currently exists (any status, never pruned in-round)
GLOBAL_LIST_EMPTY(rainDrop_offers)

/// Finds a money account by its account number. Used for RainDrop P2P transfers where the
/// caller only has the recipient's account number, not a reference to their data.
/proc/get_rainDrop_account_with_number(account_number)
	var/list/all_accounts = GLOB.all_money_accounts
	for(var/datum/money_account/account as anything in all_accounts)
		if(account.account_number == account_number)
			return account

/// Posts a new order to the board. Money is frozen from the client immediately so
/// the reward is guaranteed to exist when someone eventually completes the job.
/proc/create_rainDrop_offer(
	datum/brg_account/client,
	title,
	description,
	reward,
)
	if(!client || !client.owner)
		return FALSE

	title = trim(strip_html(title, RAINDROP_TITLE_MAX_LEN))
	description = trim(strip_html(description, RAINDROP_DESC_MAX_LEN))
	if(!length(title) || !length(description))
		return FALSE

	reward = isnum(reward) ? reward : text2num(reward)
	if(!isnum(reward))
		return FALSE
	reward = round(clamp(reward, RAINDROP_MIN_REWARD, RAINDROP_MAX_REWARD))

	if(client.owner.money < reward)
		return FALSE

	// freeze the money in escrow until the order is completed, cancelled or disputed
	client.owner.money -= reward
	client.owner.makeTransactionLog(reward, "RainDrop: заказ \"[title]\"", "RainDrop", "Эскроу RainDrop")

	var/datum/rainDrop_offer/offer = new(
		title,
		description,
		reward,
		client,
	)

	client.created_offers += offer
	GLOB.rainDrop_offers += offer
	return offer

/// An executor takes an open order.
/proc/take_rainDrop_offer(
	datum/rainDrop_offer/offer,
	datum/brg_account/worker,
)
	if(!offer || !worker || !istype(offer))
		return FALSE
	if(offer.status != RAINDROP_STATUS_OPEN)
		return FALSE
	if(offer.client == worker)
		return FALSE

	offer.worker = worker
	offer.status = RAINDROP_STATUS_TAKEN
	worker.taken_offers += offer

	if(offer.client?.owner)
		offer.client.owner.notify_pda_owner("RainDrop: заказ \"[offer.title]\" взял в работу [worker.owner.owner_name].", TRUE)

	return TRUE

/// Executor marks the order as done and hands it back to the client for a final check.
/proc/submit_rainDrop_offer(
	datum/rainDrop_offer/offer,
	datum/brg_account/actor,
)
	if(!offer || !actor || !istype(offer))
		return FALSE
	if(offer.status != RAINDROP_STATUS_TAKEN)
		return FALSE
	if(offer.worker != actor)
		return FALSE

	offer.status = RAINDROP_STATUS_SUBMITTED

	if(offer.client?.owner)
		offer.client.owner.notify_pda_owner("RainDrop: заказ \"[offer.title]\" сдан на проверку.", TRUE)

	return TRUE

/// Client confirms the job is done, pays the executor out of the frozen reward and leaves a rating.
/proc/complete_rainDrop_offer(
	datum/rainDrop_offer/offer,
	datum/brg_account/actor,
	rating,
)
	if(!offer || !actor || !istype(offer))
		return FALSE
	if(offer.status != RAINDROP_STATUS_SUBMITTED)
		return FALSE
	if(offer.client != actor)
		return FALSE
	if(!offer.worker)
		return FALSE

	var/payment = offer.get_executor_reward()

	if(offer.worker.owner)
		offer.worker.owner.money += payment
		offer.worker.owner.makeTransactionLog(payment, "RainDrop: оплата за \"[offer.title]\"", "RainDrop", "RainDrop", FALSE)
		offer.worker.owner.notify_pda_owner("RainDrop: заказ \"[offer.title]\" принят, начислено [payment] кр.", TRUE)

	offer.status = RAINDROP_STATUS_COMPLETED
	offer.completed_at = world.time

	rating = isnum(rating) ? rating : text2num(rating)
	if(!isnum(rating))
		rating = 5
	rating = clamp(rating, 0, 5)
	offer.review_rating = rating
	offer.worker.add_rating(rating)

	return TRUE

/// Client withdraws an order. Only possible while nobody has taken it yet — once an
/// executor has committed to the job, either side has to go through a dispute instead.
/proc/cancel_rainDrop_offer(
	datum/rainDrop_offer/offer,
	datum/brg_account/actor,
)
	if(!offer || !actor || !istype(offer))
		return FALSE
	if(offer.client != actor)
		return FALSE
	if(offer.status != RAINDROP_STATUS_OPEN)
		return FALSE

	var/refund = offer.get_cancel_refund()

	if(offer.client.owner)
		offer.client.owner.money += refund
		offer.client.owner.makeTransactionLog(refund, "RainDrop: отмена заказа \"[offer.title]\"", "RainDrop", "RainDrop", FALSE)

	offer.status = RAINDROP_STATUS_CANCELLED

	return TRUE

/// Either side escalates a stuck order (executor stalling, client withholding payment, etc).
/// The frozen reward is split between both parties; the platform keeps the remainder as
/// the cost of arbitration, which also discourages using disputes to game the payout.
/proc/dispute_rainDrop_offer(
	datum/rainDrop_offer/offer,
	datum/brg_account/actor,
)
	if(!offer || !actor || !istype(offer))
		return FALSE
	if(offer.client != actor && offer.worker != actor)
		return FALSE
	if(offer.status != RAINDROP_STATUS_TAKEN && offer.status != RAINDROP_STATUS_SUBMITTED)
		return FALSE

	var/client_refund = offer.get_dispute_client_refund()
	var/worker_reward = offer.get_dispute_worker_reward()

	if(offer.client?.owner)
		offer.client.owner.money += client_refund
		offer.client.owner.makeTransactionLog(client_refund, "RainDrop: спор по заказу \"[offer.title]\"", "RainDrop", "RainDrop", FALSE)
		offer.client.owner.notify_pda_owner("RainDrop: по заказу \"[offer.title]\" открыт спор.", TRUE)

	if(offer.worker?.owner)
		offer.worker.owner.money += worker_reward
		offer.worker.owner.makeTransactionLog(worker_reward, "RainDrop: спор по заказу \"[offer.title]\"", "RainDrop", "RainDrop", FALSE)
		offer.worker.owner.notify_pda_owner("RainDrop: по заказу \"[offer.title]\" открыт спор.", TRUE)

	offer.status = RAINDROP_STATUS_DISPUTED

	return TRUE

/// Direct peer-to-peer payment between two RainDrop accounts, independent of the job board.
/proc/transfer_rainDrop_money(
	datum/brg_account/sender,
	target_account_number,
	amount,
	note,
)
	if(!sender || !sender.owner)
		return FALSE

	var/account_number = isnum(target_account_number) ? target_account_number : text2num(target_account_number)
	if(!isnum(account_number))
		return FALSE

	var/datum/money_account/target = get_rainDrop_account_with_number(account_number)
	if(!target)
		return FALSE
	if(target == sender.owner)
		return FALSE

	amount = isnum(amount) ? amount : text2num(amount)
	if(!isnum(amount))
		return FALSE
	amount = round(clamp(amount, RAINDROP_TRANSFER_MIN, RAINDROP_TRANSFER_MAX))
	if(sender.owner.money < amount)
		return FALSE

	note = trim(strip_html(note, RAINDROP_NOTE_MAX_LEN))
	var/purpose = length(note) ? "RainDrop: перевод (\"[note]\")" : "RainDrop: перевод"

	sender.owner.money -= amount
	sender.owner.makeTransactionLog(amount, purpose, "RainDrop", target.owner_name)

	target.money += amount
	target.makeTransactionLog(amount, purpose, "RainDrop", sender.owner.owner_name, FALSE)
	target.notify_pda_owner("RainDrop: [sender.owner.owner_name] перевёл(а) вам [amount] кр.[length(note) ? " Комментарий: \"[note]\"" : ""]", TRUE)

	return TRUE
