/// List of all uplinks in the world.
GLOBAL_LIST_EMPTY(world_uplinks)

#define INTELLIGANCE_DATA_COOLDOWN 5 MINUTES

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
	/// Affiliate assigned of uplink owner
	var/datum/affiliate/affiliate
	/// Allows or blocks ordering of certain items. Specified on initialization by different uplink types.
	var/uplink_type = UPLINK_TYPE_TRAITOR
	/// If set, the uplink will show the option to become a contractor through this variable.
	var/datum/antagonist/contractor/contractor
	/// Whether the uplink is jammed and cannot be used to order items.
	var/is_jammed = FALSE
	/// Can be bonus objectives taken on this uplink
	var/can_bonus_objectives = FALSE
	/// Cooldown for getting intelligence data (alive antags)
	COOLDOWN_DECLARE(intelligence_data)
	/// TRUE if you can ask intelligence data in uplink. TRUE for all MI13
	var/get_intelligence_data = FALSE

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

			if((length(uplink_item.affiliate) && !uplink_item.affiliate.Find(affiliate?.name) && uplink_type != UPLINK_TYPE_ADMIN))
				continue

			if((length(uplink_item.exclude_from_affiliate) && uplink_item.exclude_from_affiliate.Find(affiliate?.name) && uplink_type != UPLINK_TYPE_ADMIN))
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
		ui = new(user, src, "Uplink", "Аплинк")
		ui.open()


/obj/item/uplink/hidden/ui_data(mob/user)
	var/list/data = list()

	data["crystals"] = uses
	data["modal"] = ui_modal_data(src)
	data["cart"] = generate_tgui_cart()
	data["cart_price"] = calculate_cart_tc()
	data["lucky_numbers"] = lucky_numbers
	data["affiliate"] = affiliate.name
	data["can_bonus_objectives"] = can_bonus_objectives
	data["can_get_intelligence_data"] = get_intelligence_data || uplink_type == UPLINK_TYPE_ADMIN

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

		if ("give_bonus_objectives")
			if (can_bonus_objectives)
				can_bonus_objectives = FALSE
				affiliate.give_bonus_objectives()
				uses += 20
				SStgui.update_uis(src)
				visible_message("[src] beeps: Additional objectives and bonus TK have been sent.")
				playsound(src, "sound/machines/boop.ogg", 50, TRUE)
			else if (affiliate.can_take_bonus_objectives)
				visible_message("[src] beeps: You have already requested additional objectives.")
				playsound(src, "sound/machines/boop.ogg", 50, TRUE)
			else
				visible_message("[src] beeps: Your affiliate don't want to give you additional objectives.")
				playsound(src, "sound/machines/boop.ogg", 50, TRUE)

		if("intel_data")
			if (!COOLDOWN_FINISHED(src, intelligence_data))
				visible_message("[src] beeps: There is no new intelligence yet.")
				playsound(src, "sound/machines/boop.ogg", 50, TRUE)
			else
				visible_message("[src] beeps: Intelligence data has been sent.")
				playsound(src, "sound/machines/boop.ogg", 50, TRUE)
				show_intelligence_data(ui.user)
				COOLDOWN_START(src, intelligence_data, INTELLIGANCE_DATA_COOLDOWN)

/obj/item/uplink/proc/show_intelligence_data(mob/user)
	// Solo humanoid antags
	var/list/traitors = list()
	var/hijacks = 0
	var/list/datum/antagonist/vampire/vampires = list()
	var/clings = 0
	var/thiefs = 0
	var/ninjas = 0
	var/wizards = 0

	// Command humanoid antags
	var/blood_cultists = 0
	var/ratwar_cultists = 0
	var/nuclears = 0
	var/revolutions = 0
	var/shadowlings = 0

	// Bioterrors
	//var/blobs = GLOB.blobs.len
	var/terrors = 0
	var/xenos = 0
	var/dragons = 0
	var/carps = 0

	// Mix antags
	var/devils = 0
	var/malfs = 0
	var/borers = 0
	var/morphs = 0
	var/revenants = 0
	var/demons = 0
	var/demon_shadows = 0
	var/demon_electros = 0

	//var/seqs = 0

	for(var/mob/M in GLOB.player_list)
		if (!M.mind)
			continue

		if (M.stat == DEAD)
			continue

		if (!M.mind.special_role)
			continue

		if (istraitor(M))
			var/datum/antagonist/traitor/traitor = M.mind.has_antag_datum(/datum/antagonist/traitor)
			traitors[traitor.affiliate] ++
			if (traitor.owner.has_big_obj())
				hijacks++

		if (isvampire(M))
			var/datum/antagonist/vampire/vampire = M.mind.has_antag_datum(/datum/antagonist/vampire)
			vampires[vampire.subclass] += vampire

		clings += ischangeling(M)
		thiefs += isthief(M)
		ninjas += isninja(M)
		wizards += iswizard(M)

		blood_cultists += iscultist(M)
		ratwar_cultists += isclocker(M)
		nuclears += (M.mind in SSticker.mode.syndicates)
		revolutions += is_revolutionary(M)
		shadowlings += isshadowling(M)

		// blobs made before
		terrors += isterrorspider(M)
		xenos += isalien(M)
		dragons += isspacedragon(M)
		carps += isspacecarp(M)

		devils += isdevil(M)
		malfs += ismalfAI(M)
		borers += istype(M, /mob/living/simple_animal/borer)
		morphs += ismorph(M)
		revenants += istype(M, /mob/living/simple_animal/revenant)
		demons += isdemon(M)
		demon_shadows += istype(M, /mob/living/simple_animal/demon/shadow)
		demon_electros += istype(M, /mob/living/simple_animal/demon/pulse_demon)

	var/list/L = list()

	L.Add(tagB(span_red("Последние данные разведки MI13")))
//	L.Add("")

	if (traitors.len > 3 || traitors.len == 3 && prob(60))
		L.Add("Обнаружены агенты:")
		for (var/datum/affiliate/key in traitors)
			L.Add("	" + key.name + ": [traitors[key] + (prob(10) - prob(10))]")
		if (hijacks && prob(80 + hijacks * 5) || prob(2))
			L.Add(span_warning("Очень вероятно что среди них есть агенты с крайне разрушительными задачами."))

	if (vampires.len > 3 || vampires.len == 2 && prob(60) || vampires == 1 && prob(2))
		L.Add("Обнаружены вампиры:")
		for (var/datum/vampire_subclass/key in vampires)
			var/ascend = 0
			var/list/vamplist = vampires[key]
			for (var/datum/antagonist/vampire/vampire in vamplist)
				ascend += vampire.isAscended()

			L.Add("	" + key.name + ": [max(1, vamplist.len + (prob(10) - prob(10)))]" + (!ascend ? "" : " Количество высших этого класса - [ascend]."))

	if (clings > 3 || clings == 2 && prob(60) || clings == 1 && prob(20) || prob(1))
		L.Add("Обнаружены генокрады. Их примерное количество - [max(1, clings + (prob(10) - prob(10)))]")

	if (thiefs > 3 || thiefs == 2 && prob(60) || thiefs == 1 && prob(20) || prob(1))
		L.Add("Обнаружены члены гильдии воров. Их примерное количество - [max(1, thiefs + (prob(10) - prob(10)))]")

	if (ninjas && prob(50 + ninjas * 15) || prob(1))
		L.Add("Очень вероятна деятельность клана Паука.")

	if (wizards && prob(90) || prob(1))
		L.Add("Обнаружена активная деятельность Федерации Космических Волшебников. Примерное количество ее представителей на станции - [max(1, wizards + prob(5) - prob(5))]")

	if (blood_cultists > 3 && prob(30 + blood_cultists * 3))
		if (prob(90) && blood_cultists < 6 || prob(2))
			L.Add("Высокая вероятность наличия неизвестного культа на объекте! Будьте осторожны! Примерное количество культистов - [max(2, blood_cultists + rand(-2, 2))]")
		else
			L.Add("На объекте обнаружен культ крови! Будьте осторожны! Примерное количество культистов - [max(6, blood_cultists + rand(-3, 3))]")



	to_chat(user, chat_box_green(L.Join("<br>")))

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

#undef INTELLIGANCE_DATA_COOLDOWN
