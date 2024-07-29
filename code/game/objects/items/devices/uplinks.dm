/// List of all uplinks in the world.
GLOBAL_LIST_EMPTY(world_uplinks)


/obj/item/uplink
	/// Uplink TC amount. Specified on initialization by different uplink types.
	var/uses = 100
	/// Used to temporarily hide TC while using frame virus.
	var/hidden_crystals = 0
	/// List of categories with items inside.
	var/list/uplink_cats
	/// List of all items in total.
	var/list/uplink_items
	/// Used to log buyed items and showing it in scoreboard.
	var/purchase_log = ""
	/// Same as above, logs buyer name in text format.
	var/uplink_owner = ""
	/// Same as above, logs spent telecrystals.
	var/used_TC = 0
	/// Species of uplink owner.
	var/race
	/// Job assigned to uplink owner.
	var/job
	/// Allows or blocks ordering of certain items. Specified on initialization by different uplink types.
	var/uplink_type = UPLINK_TYPE_TRAITOR
	/// If set, the uplink will show the option to become a contractor through this variable.
	var/datum/antagonist/contractor/contractor
	/// Whether the uplink is jammed and cannot be used to order items.
	var/is_jammed = FALSE


/obj/item/uplink/Initialize(mapload, uplink_type, uses)
	. = ..()
	src.uses = uses ? uses : src.uses
	src.uplink_type = uplink_type ? uplink_type : src.uplink_type
	uplink_items = get_uplink_items(src, generate_discounts = TRUE)
	GLOB.world_uplinks += src


/obj/item/uplink/Destroy()
	GLOB.world_uplinks -= src
	return ..()


/obj/item/uplink/ui_host()
	return loc


 /**
  * Build the item lists for use with the UI
  * Generates a list of items for use in the UI, based on job and other parameters.
  *
  * Arguments:
  * * user - User to check.
  */
/obj/item/uplink/proc/generate_item_lists(mob/user)
	if(!job)
		job = user.mind?.assigned_role
	if(!race)
		race = user.dna?.species.name

	var/list/uplink_items_by_category = list()
	for(var/datum/uplink_item/uplink_item as anything in uplink_items)
		if(!uplink_items_by_category[uplink_item.category])
			uplink_items_by_category[uplink_item.category] = list()
		uplink_items_by_category[uplink_item.category] += uplink_item
	var/list/cats = list()

	for(var/category in uplink_items_by_category)
		cats[++cats.len] = list("cat" = category, "items" = list())
		for(var/datum/uplink_item/uplink_item as anything in uplink_items_by_category[category])
			if(length(uplink_item.job) && !uplink_item.job.Find(job) && uplink_type != UPLINK_TYPE_ADMIN)
				continue
			if(length(uplink_item.race) && !uplink_item.race.Find(race) && uplink_type != UPLINK_TYPE_ADMIN)
				continue
			cats[cats.len]["items"] += list(list("name" = sanitize(uplink_item.name), "desc" = sanitize(uplink_item.description()), "cost" = uplink_item.cost, "hijack_only" = uplink_item.hijack_only, "obj_path" = ref(uplink_item), "refundable" = uplink_item.refundable))

	uplink_cats = cats

/**
 * Return random item from uplink_item list.
 */
/obj/item/uplink/proc/chooseRandomItem()
	if(uses <= 0)
		return

	var/list/random_items = list()

	for(var/datum/uplink_item/uplink_item as anything in uplink_items)
		if(uplink_item.cost <= uses && uplink_item.limited_stock != 0)
			random_items += uplink_item

	return safepick(random_items)


/**
 * Handles buying an item, spending TC and updating TGUI.
 *
 * Arguments:
 * * uplink_item - purchased item entry.
 * * buyer - mob who performs the transaction.
 */
/obj/item/uplink/proc/buy(datum/uplink_item/uplink_item, mob/buyer)
	if(is_jammed)
		to_chat(buyer, span_warning("[src] seems to be jammed - it cannot be used here!"))
		return FALSE
	if(!uplink_item)
		return FALSE
	if(uplink_item.limited_stock == 0)
		to_chat(buyer, span_warning("You have redeemed this offer already."))
		return FALSE
	uplink_item.buy(src, buyer)
	SStgui.update_uis(src)
	return TRUE


/obj/item/uplink/proc/mass_purchase(datum/uplink_item/uplink_item, mob/user, quantity = 1)
	// jamming check happens in ui_act
	if(!uplink_item)
		return
	if(quantity <= 0)
		return
	if(uplink_item.limited_stock == 0)
		return
	if(uplink_item.limited_stock > 0 && uplink_item.limited_stock < quantity)
		quantity = uplink_item.limited_stock
	var/list/bought_things = list()
	for(var/i in 1 to quantity)
		var/item = uplink_item.buy(src, user, put_in_hands = FALSE)
		if(isnull(item))
			break
		bought_things += item
	return bought_things

/**
 * Handles refunding of the item in user's active hand.
 *
 * Arguments:
 * * user - who refunds the item.
 */
/obj/item/uplink/proc/refund(mob/user)
	var/obj/item/hold_item = user.get_active_hand()
	if(!hold_item || !hold_item.check_uplink_validity()) // Make sure there's actually something in the hand before even bothering to check
		return FALSE

	for(var/datum/uplink_item/uplink_item as anything in uplink_items)
		var/path = uplink_item.refund_path || uplink_item.item
		if(hold_item.type != path || !uplink_item.refundable)
			continue

		var/cost =  uplink_item.cost

		if(uplink_item.item_to_refund_cost?[hold_item.UID()])
			cost = uplink_item.item_to_refund_cost[hold_item.UID()]

		uses += cost
		used_TC -= cost
		to_chat(user, span_notice("[hold_item] refunded."))
		qdel(hold_item)
		return

	// If we are here, we didnt refund
	to_chat(user, span_warning("[hold_item] is not refundable."))


// HIDDEN UPLINK - Can be stored in anything but the host item has to have a trigger for it.
/* How to create an uplink in 3 easy steps!

 1. All obj/item 's have a hidden_uplink var. By default it's null. Give the item one with "new(src)", it must be in it's contents. Feel free to add "uses".

 2. Code in the triggers. Use check_trigger for this, I recommend closing the item's menu with "usr << browse(null, "window=windowname") if it returns true.
 The var/value is the value that will be compared with the var/target. If they are equal it will activate the menu.

 3. If you want the menu to stay until the users locks his uplink, add an active_uplink_check(mob/user) in your interact/attack_hand proc.
 Then check if it's true, if true return. This will stop the normal menu appearing and will instead show the uplink menu.
*/
/obj/item/uplink/hidden
	name = "hidden uplink"
	desc = "There is something wrong if you're examining this."
	/// Whether uplink is currently open.
	var/active = FALSE
	/// An assoc list of references (the variable called reference on an uplink item) and its value being how many of the item
	var/list/shopping_cart
	/// A cached version of shopping_cart containing all the data for the tgui side
	var/list/cached_cart
	/// A list of 3 categories and item indexes in uplink_cats, to show as recommendedations
	var/list/lucky_numbers


/obj/item/uplink/hidden/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(delayed_check)), 0.2 SECONDS)


/obj/item/uplink/hidden/proc/delayed_check()
	if(!isitem(loc))	// The hidden uplink MUST be inside an obj/item's contents.
		qdel(src)


/**
 * Toggles the uplink on and off. Normally this will bypass the item's normal functions and go to the uplink menu, if activated.
 */
/obj/item/uplink/hidden/proc/toggle()
	active = !active


/**
 * Directly trigger the uplink. Turn on if it isn't already.
 */
/obj/item/uplink/hidden/proc/trigger(mob/user)
	if(!active)
		toggle()
	interact(user)


/**
 * Checks to see if the value meets the target. Like a frequency being a traitor_frequency, in order to unlock a headset.
 * If true, it accesses trigger() and returns `TRUE`. If it fails, it returns `FALSE`. Use this to see if you need to close the current item's menu.
 *
 * Arguments:
 * * user - who performs the validation.
 * * value - checked value.
 * * target - target value to check with.
 */
/obj/item/uplink/hidden/proc/check_trigger(mob/user, value, target)
	if(is_jammed)
		to_chat(user, span_warning("[src] seems to be jammed - it cannot be used here!"))
		return FALSE
	if(value == target)
		trigger(user)
		return TRUE
	return FALSE

/obj/item/uplink/hidden/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/uplink/hidden/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Uplink", name)
		ui.open()


/obj/item/uplink/hidden/ui_data(mob/user)
	var/list/data = list()

	data["crystals"] = uses
	data["modal"] = ui_modal_data(src)
	data["cart"] = generate_tgui_cart()
	data["cart_price"] = calculate_cart_tc()
	data["lucky_numbers"] = lucky_numbers

	if(contractor)
		var/list/contractor_data = list(
			available = uses >= contractor.tc_cost && world.time < contractor.offer_deadline && \
			(SSticker?.mode?.contractor_accepted< CONTRACTOR_MAX_ACCEPTED || contractor.is_admin_forced),
			affordable = uses >= contractor.tc_cost,
			accepted = !isnull(contractor.contractor_uplink),
			time_left = contractor.offer_deadline - world.time,
			available_offers = CONTRACTOR_MAX_ACCEPTED - SSticker?.mode?.contractor_accepted,
			is_admin_forced = contractor.is_admin_forced,
		)
		data["contractor"] = contractor_data

	return data


/obj/item/uplink/hidden/ui_static_data(mob/user)
	var/list/data = list()

	// Actual items
	if(!uplink_cats)
		generate_item_lists(user)
	if(!lucky_numbers) // Make sure these are generated AFTER the categories, otherwise shit will get messed up
		shuffle_lucky_numbers()
	data["cats"] = uplink_cats

	// Exploitable info
	var/list/exploitable = list()
	for(var/datum/data/record/L in GLOB.data_core.general)
		exploitable += list(list(
			"name" = html_encode(L.fields["name"]),
			"sex" = html_encode(L.fields["sex"]),
			"age" = html_encode(L.fields["age"]),
			"species" = html_encode(L.fields["species"]),
			"rank" = html_encode(L.fields["rank"]),
			"fingerprint" = html_encode(L.fields["fingerprint"]),
			"exploit_record" = html_encode(L.fields["exploit_record"]),
		))

	data["exploitable"] = exploitable

	return data

/obj/item/uplink/hidden/proc/calculate_cart_tc()
	. = 0
	for(var/reference in shopping_cart)
		var/datum/uplink_item/item = locate(reference) in uplink_items
		var/purchase_amt = shopping_cart[reference]
		. += item.cost * purchase_amt

/obj/item/uplink/hidden/proc/generate_tgui_cart(update = FALSE)
	if(!update)
		return cached_cart

	if(!length(shopping_cart))
		shopping_cart = null
		cached_cart = null
		return cached_cart

	cached_cart = list()
	for(var/reference in shopping_cart)
		var/datum/uplink_item/I = locate(reference) in uplink_items
		cached_cart += list(list(
			"name" = sanitize(I.name),
			"desc" = sanitize(I.description()),
			"cost" = I.cost,
			"hijack_only" = I.hijack_only,
			"obj_path" = ref(I),
			"amount" = shopping_cart[reference],
			"limit" = I.limited_stock))

/obj/item/uplink/hidden/interact(mob/user)

	ui_interact(user)


/obj/item/uplink/hidden/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE
	if(tgui_act_modal(action, params))
		return

	switch(action)
		if("lock")
			toggle()
			uses += hidden_crystals
			hidden_crystals = 0
			SStgui.close_uis(src)
			for(var/reference in shopping_cart)
				if(shopping_cart[reference] == 0) // I know this isn't lazy, but this should runtime on purpose if we can't access this for some reason
					remove_from_cart(reference)

		if("refund")
			refund(ui.user)

		if("buyRandom")
			var/datum/uplink_item/uplink_item = chooseRandomItem()
			return buy(uplink_item, ui.user)

		if("buyItem")
			var/datum/uplink_item/uplink_item = locate(params["item"]) in uplink_items
			return buy(uplink_item, ui.user)

		if("add_to_cart")
			var/datum/uplink_item/uplink_item = locate(params["item"]) in uplink_items
			if(LAZYIN(shopping_cart, params["item"]))
				to_chat(ui.user, span_warning("[uplink_item.name] is already in your cart!"))
				return
			var/startamount = 1
			if(uplink_item.limited_stock == 0)
				startamount = 0
			LAZYSET(shopping_cart, params["item"], startamount)
			generate_tgui_cart(TRUE)

		if("remove_from_cart")
			remove_from_cart(params["item"])

		if("set_cart_item_quantity")
			var/amount = text2num(params["quantity"])
			LAZYSET(shopping_cart, params["item"], max(amount, 0))
			generate_tgui_cart(TRUE)

		if("purchase_cart")
			if(!LAZYLEN(shopping_cart)) // sanity check
				return
			if(calculate_cart_tc() > uses)
				to_chat(ui.user, span_warning("[src] buzzes, it doesn't contain enough telecrystals!</span>"))
				return
			if(is_jammed)
				to_chat(ui.user, span_warning("[src] seems to be jammed - it cannot be used here!</span>"))
				return

			// Buying of the uplink stuff
			var/list/bought_things = list()
			for(var/reference in shopping_cart)
				var/datum/uplink_item/item = locate(reference) in uplink_items
				var/purchase_amt = shopping_cart[reference]
				if(purchase_amt <= 0)
					continue
				bought_things += mass_purchase(item, ui.user, purchase_amt)

			// Check how many of them are items
			var/list/obj/item/items_for_crate = list()
			for(var/obj/item/thing in bought_things)
				// because sometimes you can buy items like crates from surpluses and stuff
				// the crates will already be on the ground, so we dont need to worry about them
				if(isitem(thing))
					items_for_crate += thing

			// If we have more than 2 of them, put them in a crate
			if(length(items_for_crate) > 2)
				var/obj/structure/closet/crate/C = new(get_turf(src))
				for(var/obj/item/item as anything in items_for_crate)
					item.forceMove(C)
			// Otherwise, just put the items in their hands
			else if(length(items_for_crate))
				for(var/obj/item/item as anything in items_for_crate)
					ui.user.put_in_any_hand_if_possible(item)

			empty_cart()
			SStgui.update_uis(src)

		if("empty_cart")
			empty_cart()

		if("shuffle_lucky_numbers")
			// lets see paul allen's random uplink item
			shuffle_lucky_numbers()

/obj/item/uplink/hidden/proc/shuffle_lucky_numbers()
	lucky_numbers = list()
	for(var/i in 1 to 4)
		var/cate_number = rand(1, length(uplink_cats))
		var/item_number = rand(1, length(uplink_cats[cate_number]["items"]))
		lucky_numbers += list(list("cat" = cate_number - 1, "item" = item_number - 1)) // dm lists are 1 based, js lists are 0 based, gotta -1

/obj/item/uplink/hidden/proc/remove_from_cart(item_reference) // i want to make it eventually remove all instances
	LAZYREMOVE(shopping_cart, item_reference)
	generate_tgui_cart(TRUE)

/obj/item/uplink/hidden/proc/empty_cart()
	shopping_cart = null
	generate_tgui_cart(TRUE)


/**
  * Called in tgui_act() to process modal actions
  *
  * Arguments:
  * * action - The action passed by tgui
  * * params - The params passed by tgui
  */
/obj/item/uplink/hidden/proc/tgui_act_modal(action, list/params)
	. = TRUE
	var/id = params["id"]
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			if(id == "become_contractor")
				ui_modal_boolean(src, id, "")
				return
		if(UI_MODAL_ANSWER)
			if(id == "become_contractor")
				if(text2num(params["answer"]))
					var/datum/antagonist/contractor/C = usr?.mind?.has_antag_datum(/datum/antagonist/contractor)
					C?.become_contractor(usr, src)
				return
	return FALSE


/**
 * I placed this here because of how relevant it is.
 * You place this in your uplinkable item to check if an uplink is active or not.
 * If it is, it will display the uplink menu and return `TRUE`, else it'll return `FALSE`.
 * If it returns true, I recommend closing the item's normal menu with "user << browse(null, "window=name")"
 */
/obj/item/proc/active_uplink_check(mob/user)
	// Activates the uplink if it's active
	if(hidden_uplink?.active)
		hidden_uplink.trigger(user)
		return TRUE
	return FALSE


/**
 * PRESET UPLINKS
 * A collection of preset uplinks.
 *
 * Includes normal radio uplink, multitool uplink, implant uplink (not the implant tool) and a preset headset uplink.
 */

/obj/item/radio/uplink/Initialize(mapload)
	. = ..()
	hidden_uplink = new(src, choose_uplink(), get_uses_amount())
	icon_state = "radio"


/obj/item/radio/uplink/attack_self(mob/user)
	hidden_uplink?.trigger(user)


/obj/item/radio/uplink/proc/choose_uplink()
	return UPLINK_TYPE_TRAITOR


/obj/item/radio/uplink/proc/get_uses_amount()
	return 100


/obj/item/radio/uplink/nuclear/Initialize(mapload)
	. = ..()
	GLOB.nuclear_uplink_list += src


/obj/item/radio/uplink/nuclear/Destroy()
	GLOB.nuclear_uplink_list -= src
	return ..()


/obj/item/radio/uplink/nuclear/choose_uplink()
	return UPLINK_TYPE_NUCLEAR


/obj/item/radio/uplink/sst/choose_uplink()
	return UPLINK_TYPE_SST

/obj/item/radio/uplink/sst/get_uses_amount()
	var/danger = GLOB.player_list.len
	var/temp_danger = (danger + 9)
	danger = temp_danger - temp_danger % 10
	danger *= NUKESCALINGMODIFIER
	return ..() + round(danger/ NUKERS_COUNT) + danger % NUKERS_COUNT


/obj/item/radio/uplink/admin/choose_uplink()
	return UPLINK_TYPE_ADMIN


/obj/item/radio/uplink/admin/get_uses_amount()
	return 2500


/obj/item/multitool/uplink/Initialize(mapload)
	. = ..()
	hidden_uplink = new(src, UPLINK_TYPE_TRAITOR)


/obj/item/multitool/uplink/attack_self(mob/user)
	hidden_uplink?.trigger(user)


/obj/item/radio/headset/uplink
	traitor_frequency = 1445


/obj/item/radio/headset/uplink/Initialize(mapload)
	. = ..()
	hidden_uplink = new(src, UPLINK_TYPE_TRAITOR)

