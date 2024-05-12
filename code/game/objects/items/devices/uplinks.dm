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
		to_chat(buyer, span_warning("You have redeemed this discount already."))
		return FALSE
	uplink_item.buy(src, buyer)
	if(uplink_item.limited_stock > 0) // only decrement it if it's actually limited
		uplink_item.limited_stock--
	SStgui.update_uis(src)
	return TRUE


/**
 * Handles refunding of the item in user's active hand.
 *
 * Arguments:
 * * user - who refunds the item.
 */
/obj/item/uplink/proc/refund(mob/user)
	var/obj/item/hold_item = user.get_active_hand()
	if(!hold_item) // Make sure there's actually something in the hand before even bothering to check
		return FALSE

	for(var/datum/uplink_item/uplink_item as anything in uplink_items)
		var/path = uplink_item.refund_path || uplink_item.item
		var/cost = uplink_item.refund_amount || uplink_item.cost
		if(hold_item.type == path && uplink_item.refundable && hold_item.check_uplink_validity())
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


/obj/item/uplink/hidden/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Uplink", name, 900, 600, master_ui, state)
		ui.open()


/obj/item/uplink/hidden/ui_data(mob/user)
	var/list/data = list()

	data["crystals"] = uses
	data["modal"] = ui_modal_data(src)

	if(contractor)
		var/list/contractor_data = list(
			available = uses >= contractor.tc_cost && world.time < contractor.offer_deadline,
			affordable = uses >= contractor.tc_cost,
			accepted = !isnull(contractor.contractor_uplink),
			time_left = contractor.offer_deadline - world.time,
		)
		data["contractor"] = contractor_data

	return data


/obj/item/uplink/hidden/ui_static_data(mob/user)
	var/list/data = list()

	// Actual items
	if(!uplink_cats)
		generate_item_lists(user)
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


/obj/item/uplink/hidden/interact(mob/user)

	ui_interact(user)


/obj/item/uplink/hidden/ui_act(action, list/params)
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

		if("refund")
			refund(usr)

		if("buyRandom")
			var/datum/uplink_item/uplink_item = chooseRandomItem()
			return buy(uplink_item, usr)

		if("buyItem")
			var/datum/uplink_item/uplink_item = locate(params["item"]) in uplink_items
			return buy(uplink_item, usr)


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

