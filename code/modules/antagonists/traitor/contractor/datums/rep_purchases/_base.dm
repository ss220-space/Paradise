/**
  * # Rep Purchase
  *
  * Describes something that can be purchased with Contractor Rep.
  */
/datum/rep_purchase
	/// The display name of the purchase.
	var/name = ""
	/// The description of the purchase.
	var/description = "This shouldn't appear."
	/// The price in Contractor Rep of the purchase.
	var/cost = 0
	/// How many times the purchase can be made.
	/// -1 means infinite stock.
	var/stock = -1
	/// Can this item be refunded?
	var/refundable = FALSE

/**
  * Attempts to perform the purchase.
  *
  * Returns TRUE or FALSE depending on whether the purchase succeeded.
  *
  * Arguments:
  * * hub - The contractor hub.
  * * user - The user who is making the purchase.
  */
/datum/rep_purchase/proc/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	. = FALSE
	if(hub.owner.current != user)
		to_chat(user, "<span class='warning'>You were not recognized as this hub's original user.</span>")
		return
	if(hub.rep < cost)
		to_chat(user, "<span class='warning'>You do not have enough Rep.</span>")
		return
	if(stock == 0)
		to_chat(user, "<span class='warning'>This item is out of stock.</span>")
		return
	else if(stock > 0)
		stock--
	hub.rep -= cost
	on_buy(hub, user)
	return TRUE

/**
  * Attempts to perform the refund.
  *
  * Returns TRUE or FALSE depending on whether the refund succeeded.
  *
  * Arguments:
  * * hub - The contractor hub.
  * * item - The refunded item.
  * * user - The user who is making the refund.
  */
/datum/rep_purchase/proc/refund(datum/contractor_hub/hub, obj/item/item, mob/living/carbon/human/user)
	return

/**
  * Called when the purchase was made successfully.
  *
  * Arguments:
  * * hub - The contractor hub.
  * * user - The user who made the purchase.
  */
/datum/rep_purchase/proc/on_buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	return

/**
  * # Rep Purchase - Item
  *
  * Describes an item that can be purchased with Contractor Rep.
  */
/datum/rep_purchase/item
	/// The typepath of the item to instantiate and give to the buyer on purchase.
	var/obj/item/item_type = null
	/// Alternative path for refunds
	var/refund_path = null

/datum/rep_purchase/item/on_buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	..()
	var/obj/item/I = new item_type(user)
	user.put_in_hands(I)


/datum/rep_purchase/item/refund(datum/contractor_hub/hub, obj/item/item, mob/living/carbon/human/user)
	. = FALSE
	if(!refundable)
		return
	var/path = refund_path || item_type
	if(!istype(item) || item.type != path || !item.check_uplink_validity())
		return
	if(hub.owner.current != user)
		to_chat(user, span_warning("You were not recognized as this hub's original user."))
		return
	if(initial(stock) <= stock)
		to_chat(user, span_warning("There are too many things of this type in the hub. Don't overload the market!"))
		return
	else if(stock > -1)
		stock++
	hub.rep += cost
	on_refund(hub, item, user)
	return TRUE

/**
  * Called when the refund was made successfully.
  *
  * Arguments:
  * * hub - The contractor hub.
  * * item - The refunded item.
  * * user - The user who made the refund.
  */
/datum/rep_purchase/item/proc/on_refund(datum/contractor_hub/hub, obj/item/item, mob/living/carbon/human/user)
	to_chat(user, span_notice("[item] refunded."))
	qdel(item)
