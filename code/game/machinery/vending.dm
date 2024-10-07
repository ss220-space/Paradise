// Vendor flick sequence bitflags
/// Machine is not using vending/denying overlays
#define FLICK_NONE 0
/// Machine is currently vending wares, and will not update its icon, unless its stat change.
#define FLICK_VEND 1
/// Machine is currently denying wares, and will not update its icon, unless its stat change.
#define FLICK_DENY 2

// Using these to decide how a vendor crush should be handled after crushing a carbon.
/// Just jump ship, the crit handled everything it needs to.
#define VENDOR_CRUSH_HANDLED 0
/// Throw the vendor at the target's tile.
#define VENDOR_THROW_AT_TARGET 1
/// Don't actually throw at the target, just tip it in place.
#define VENDOR_TIP_IN_PLACE 2


/**
 *  Datum used to hold information about a product in a vending machine
 */
/datum/data/vending_product
	name = "generic"
	///Typepath of the product that is created when this record "sells"
	var/product_path = null
	///How many of this product we currently have
	var/amount = 0
	///How many we can store at maximum
	var/max_amount = 0
	var/price = 0  // Price to buy one

/obj/machinery/vending
	name = "\improper Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "generic_off"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE
	max_integrity = 300
	integrity_failure = 100
	armor = list(melee = 20, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 70)

	// All the overlay controlling variables
	/// Overlay of vendor maintenance panel.
	var/panel_overlay = ""
	/// Overlay of a vendor screen, will not apply of stat is NOPOWER.
	var/screen_overlay = ""
	/// Lightmask used when vendor is working properly.
	var/lightmask_overlay = ""
	/// Damage overlay applied if vendor is damaged enough.
	var/broken_overlay = ""
	/// Special lightmask for broken overlay. If vendor is BROKEN, but not dePOWERED we will see this, instead of `lightmask_overlay`.
	var/broken_lightmask_overlay = ""
	/// Overlay applied when machine is vending goods.
	var/vend_overlay = ""
	/// Special lightmask that will override default `lightmask_overlay`, while machine is vending goods.
	var/vend_lightmask = ""
	/// Amount of time until vending sequence is reseted.
	var/vend_overlay_time = 5 SECONDS
	/// Overlay applied when machine is denying its wares.
	var/deny_overlay = ""
	/// Special lightmask that will override default `lightmask_overlay`, while machine is denying its wares.
	var/deny_lightmask = ""
	/// Amount of time until denying sequence is reseted.
	var/deny_overlay_time = 1.5 SECONDS
	/// Flags used to correctly manipulate with vend/deny sequences.
	var/flick_sequence = FLICK_NONE
	/// If `TRUE` machine will only react to BROKEN/NOPOWER stat, when updating overlays.
	var/skip_non_primary_icon_updates = FALSE

	// Power
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	var/vend_power_usage = 150

	// Vending-related
	/// No sales pitches if off
	var/active = TRUE
	/// If off, vendor is busy and unusable until current action finishes
	var/vend_ready = TRUE
	/// How long vendor takes to vend one item.
	var/vend_delay = 1 SECONDS
	/// Item currently being bought
	var/datum/data/vending_product/currently_vending = null

	// To be filled out at compile time
	var/list/products	= list()	// For each, use the following pattern:
	var/list/contraband	= list()	// list(/type/path = amount,/type/path2 = amount2)
	var/list/premium 	= list()	// No specified amount = only one in stock
	var/list/prices     = list()	// Prices for each item, list(/type/path = price), items not in the list don't have a price.

	// List of vending_product items available.
	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/coin_records = list()
	var/list/imagelist = list()

	/// Unimplemented list of ads that are meant to show up somewhere, but don't.
	var/list/ads_list = list()

	// Stuff relating vocalizations
	/// List of slogans the vendor will say, optional
	var/list/slogan_list = list()
	var/vend_reply				//Thank you for shopping!
	/// If true, prevent saying sales pitches
	var/shut_up = FALSE
	///can we access the hidden inventory?
	var/extended_inventory = FALSE
	var/last_reply = 0
	var/last_slogan = 0			//When did we last pitch?
	var/slogan_delay = 6000		//How long until we can pitch again?

	//The type of refill canisters used by this machine.
	var/obj/item/vending_refill/refill_canister = null

	// Things that can go wrong
	/// Allows people to access a vendor that's normally access restricted.
	emagged = 0
	/// Shocks people like an airlock
	var/seconds_electrified = 0
	/// Fire items at customers! We're broken!
	var/shoot_inventory = FALSE
	/// How hard are we firing the items?
	var/shoot_speed = 3
	/// How often are we firing the items? (prob(...))
	var/shoot_chance = 2

	/// If true, enforce access checks on customers. Disabled by messing with wires.
	var/scan_id = TRUE
	/// Holder for a coin inserted into the vendor
	var/obj/item/coin/coin
	var/datum/wires/vending/wires = null

	/// boolean, whether this vending machine can accept people inserting items into it, used for coffee vendors
	var/item_slot = FALSE
	/// the actual item inserted
	var/obj/item/inserted_item = null

	/// blocks further flickering while true
	var/flickering = FALSE
	/// do I look unpowered, even when powered?
	var/force_no_power_icon_state = FALSE

	var/light_range_on = 1
	var/light_power_on = 0.5

	/// If this vending machine can be tipped or not
	var/tiltable = TRUE
	/// If this vendor is currently tipped
	var/tilted = FALSE
	/// If tilted, this variable should always be the rotation that was applied when we were tilted. Stored for the purposes of unapplying it.
	var/tilted_rotation = 0
	/// Amount of damage to deal when tipped
	var/squish_damage = 30  // yowch
	/// Factor of extra damage to deal when triggering a crit
	var/crit_damage_factor = 2
	/// Factor of extra damage to deal when you knock it over onto yourself
	var/self_knockover_factor = 1.5
	/// All possible crits that could be applied. We only need to build this up once
	var/static/list/all_possible_crits = list()
	/// Possible crit effects from this vending machine tipping.
	var/list/possible_crits = list(
		// /datum/vendor_crit/pop_head, //too much i think
		/datum/vendor_crit/embed,
		/datum/vendor_crit/pin,
		/datum/vendor_crit/shatter,
		/datum/vendor_crit/lucky
	)
	/// number of shards to apply when a crit embeds
	var/num_shards = 4
	/// How long to wait before resetting the warning cooldown
	var/hit_warning_cooldown_length = 10 SECONDS
	/// Cooldown for warning cooldowns
	COOLDOWN_DECLARE(last_hit_time)
	/// If the vendor should tip on anyone who walks by. Mainly used for brand intelligence
	var/aggressive = FALSE

/obj/machinery/vending/Initialize(mapload)
	. = ..()
	var/build_inv = FALSE
	if(!refill_canister)
		build_inv = TRUE
	else
		component_parts = list()
		var/obj/item/circuitboard/vendor/V = new
		V.set_type(replacetext(initial(name), "\improper", ""))
		component_parts += V
		component_parts += new refill_canister
		RefreshParts()

	wires = new(src)
	if(build_inv) //non-constructable vending machine
		build_inventory(products, product_records)
		build_inventory(contraband, hidden_records)
		build_inventory(premium, coin_records)
	for(var/datum/data/vending_product/R in (product_records + coin_records + hidden_records))
		var/obj/item/I = R.product_path
		var/pp = path2assetID(R.product_path)
		imagelist[pp] = "[icon2base64(icon(initial(I.icon), initial(I.icon_state), SOUTH, 1, FALSE))]"
	if(LAZYLEN(slogan_list))
		// So not all machines speak at the exact same time.
		// The first time this machine says something will be at slogantime + this random value,
		// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is created.
		last_slogan = world.time + rand(0, slogan_delay)

	if(!length(all_possible_crits))
		for(var/typepath in subtypesof(/datum/vendor_crit))
			all_possible_crits[typepath] = new typepath()

	update_icon(UPDATE_OVERLAYS)

/obj/machinery/vending/examine(mob/user)
	. = ..()
	if(tilted)
		. += span_warning("It's been tipped over and won't be usable unless it's righted.")
		if(Adjacent(user))
			. += span_notice("You can <b>Alt-Click</b> it to right it.")
	if(aggressive)
		. += span_warning("Its product lights seem to be blinking ominously...")

/obj/machinery/vending/AltClick(mob/user)
	if(!tilted || !Adjacent(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	untilt(user)

/obj/machinery/vending/Destroy()
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
	QDEL_NULL(coin)
	QDEL_NULL(inserted_item)
	return ..()

/obj/machinery/vending/RefreshParts()         //Better would be to make constructable child
	if(!component_parts)
		return

	product_records = list()
	hidden_records = list()
	coin_records = list()
	if(refill_canister)
		build_inventory(products, product_records, start_empty = TRUE)
		build_inventory(contraband, hidden_records, start_empty = TRUE)
		build_inventory(premium, coin_records, start_empty = TRUE)
	for(var/obj/item/vending_refill/VR in component_parts)
		restock(VR)


/obj/machinery/vending/update_icon(updates = ALL)
	if(skip_non_primary_icon_updates && !(stat & (NOPOWER|BROKEN)))
		return ..(NONE)
	return ..()


/obj/machinery/vending/update_overlays()
	. = ..()

	underlays.Cut()

	if((stat & NOPOWER) || force_no_power_icon_state)
		if(broken_overlay && (stat & BROKEN))
			. += broken_overlay

		if(panel_overlay && panel_open)
			. += panel_overlay
		return

	if(stat & BROKEN)
		if(broken_overlay)
			. += broken_overlay
		if(broken_lightmask_overlay)
			underlays += emissive_appearance(icon, broken_lightmask_overlay, src)
		if(panel_overlay && panel_open)
			. += panel_overlay
		return

	if(screen_overlay)
		. += screen_overlay

	var/lightmask_used = FALSE
	if(vend_overlay && (flick_sequence & FLICK_VEND))
		. += vend_overlay
		if(vend_lightmask)
			lightmask_used = TRUE
			. += vend_lightmask

	else if(deny_overlay && (flick_sequence & FLICK_DENY))
		. +=  deny_overlay
		if(deny_lightmask)
			lightmask_used = TRUE
			. += deny_lightmask

	if(!lightmask_used && lightmask_overlay)
		underlays += emissive_appearance(icon, lightmask_overlay, src)

	if(panel_overlay && panel_open)
		. += panel_overlay


/obj/machinery/vending/power_change(forced = FALSE)
	. = ..()
	if(stat & NOPOWER)
		set_light_on(FALSE)
	else
		set_light(light_range_on, light_power_on, l_on = TRUE)
	if(.)
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/vending/extinguish_light(force = FALSE)
	if(light_on)
		set_light_on(FALSE)
		underlays.Cut()


/obj/machinery/vending/proc/flick_vendor_overlay(flick_flag = FLICK_NONE)
	if(flick_sequence & (FLICK_VEND|FLICK_DENY))
		return
	if((flick_flag & FLICK_VEND) && !vend_overlay)
		return
	if((flick_flag & FLICK_DENY) && !deny_overlay)
		return
	flick_sequence = flick_flag
	update_icon(UPDATE_OVERLAYS)
	skip_non_primary_icon_updates = TRUE
	var/flick_time = (flick_flag & FLICK_VEND) ? vend_overlay_time : (flick_flag & FLICK_DENY) ? deny_overlay_time : 0
	addtimer(CALLBACK(src, PROC_REF(flick_reset)), flick_time)


/obj/machinery/vending/proc/flick_reset()
	skip_non_primary_icon_updates = FALSE
	flick_sequence = FLICK_NONE
	update_icon(UPDATE_OVERLAYS)


/*
 * Reimp, flash the screen on and off repeatedly.
 */
/obj/machinery/vending/flicker()
	if(flickering)
		return FALSE

	if(stat & (BROKEN|NOPOWER))
		return FALSE

	flickering = TRUE
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/vending, flicker_event))

	return TRUE

/*
 * Proc to be called by invoke_async in the above flicker() proc.
 */
/obj/machinery/vending/proc/flicker_event()
	var/amount = rand(5, 15)

	for(var/i in 1 to amount)
		force_no_power_icon_state = TRUE
		update_icon(UPDATE_OVERLAYS)
		sleep(rand(1, 3))

		force_no_power_icon_state = FALSE
		update_icon(UPDATE_OVERLAYS)
		sleep(rand(1, 10))
	update_icon(UPDATE_OVERLAYS)
	flickering = FALSE

/**
 *  Build src.produdct_records from the products lists
 *
 *  src.products, src.contraband, src.premium, and src.prices allow specifying
 *  products that the vending machine is to carry without manually populating
 *  src.product_records.
 */
/obj/machinery/vending/proc/build_inventory(list/productlist, list/recordlist, start_empty = FALSE)
	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		if(isnull(amount))
			amount = 0

		var/atom/temp = typepath
		var/datum/data/vending_product/R = new /datum/data/vending_product()
		R.name = initial(temp.name)
		R.product_path = typepath
		if(!start_empty)
			R.amount = amount
		R.max_amount = amount
		R.price = (typepath in prices) ? prices[typepath] : 0
		recordlist += R
/**
  * Refill a vending machine from a refill canister
  *
  * This takes the products from the refill canister and then fills the products,contraband and premium product categories
  *
  * Arguments:
  * * canister - the vending canister we are refilling from
  */
/obj/machinery/vending/proc/restock(obj/item/vending_refill/canister)
	if(!canister.products)
		canister.products = products.Copy()
	if(!canister.contraband)
		canister.contraband = contraband.Copy()
	if(!canister.premium)
		canister.premium = premium.Copy()
	. = 0
	. += refill_inventory(canister.products, product_records)
	. += refill_inventory(canister.contraband, hidden_records)
	. += refill_inventory(canister.premium, coin_records)
/**
  * Refill our inventory from the passed in product list into the record list
  *
  * Arguments:
  * * productlist - list of types -> amount
  * * recordlist - existing record datums
  */
/obj/machinery/vending/proc/refill_inventory(list/productlist, list/recordlist)
	. = 0
	for(var/R in recordlist)
		var/datum/data/vending_product/record = R
		var/diff = min(record.max_amount - record.amount, productlist[record.product_path])
		if (diff)
			productlist[record.product_path] -= diff
			record.amount += diff
			. += diff
/**
  * Set up a refill canister that matches this machines products
  *
  * This is used when the machine is deconstructed, so the items aren't "lost"
  */
/obj/machinery/vending/proc/update_canister()
	if(!component_parts)
		return

	var/obj/item/vending_refill/R = locate() in component_parts
	if(!R)
		CRASH("Constructible vending machine did not have a refill canister")

	R.products = unbuild_inventory(product_records)
	R.contraband = unbuild_inventory(hidden_records)
	R.premium = unbuild_inventory(coin_records)

/**
  * Given a record list, go through and and return a list of type -> amount
  */
/obj/machinery/vending/proc/unbuild_inventory(list/recordlist)
	. = list()
	for(var/R in recordlist)
		var/datum/data/vending_product/record = R
		.[record.product_path] += record.amount

/obj/machinery/vending/deconstruct(disassembled = TRUE)
	eject_item()
	if(!refill_canister) //the non constructable vendors drop metal instead of a machine frame.
		new /obj/item/stack/sheet/metal(loc, 3)
		qdel(src)
	else
		..()


/obj/machinery/vending/attackby(obj/item/I, mob/user, params)
	if(tilted)
		if(user.a_intent == INTENT_HELP)
			to_chat(user, span_warning("[src] is tipped over and non-functional! You'll need to right it first."))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ..()

	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/coin))
		add_fingerprint(user)
		if(!length(premium))
			to_chat(user, span_warning("[src] does not accept coins."))
			return ATTACK_CHAIN_PROCEED
		if(coin)
			to_chat(user, span_warning("There is already a coin in this machine!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		coin = I
		to_chat(user, span_notice("You insert [I] into [src]."))
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, refill_canister))
		add_fingerprint(user)
		if(stat & (BROKEN|NOPOWER))
			to_chat(user, span_notice("[src] does not respond."))
			return ATTACK_CHAIN_PROCEED
		if(!panel_open)
			to_chat(user, span_warning("You should probably unscrew the service panel first!"))
			return ATTACK_CHAIN_PROCEED

		var/obj/item/vending_refill/canister = I
		if(canister.get_part_rating() == 0)
			to_chat(user, span_warning("The [canister.name] is empty!"))
			return ATTACK_CHAIN_PROCEED

		// instantiate canister if needed
		var/transferred = restock(canister)
		if(transferred)
			to_chat(user, span_notice("You loaded [transferred] items in [src]."))
			return ATTACK_CHAIN_PROCEED_SUCCESS

		to_chat(user, span_warning("There's nothing to restock!"))
		return ATTACK_CHAIN_PROCEED

	if(item_slot_check(user, I))
		add_fingerprint(user)
		insert_item(user, I)
		return ATTACK_CHAIN_BLOCKED_ALL

	try_tilt(I, user)
	return ..()

/obj/machinery/vending/proc/try_tilt(obj/item/I, mob/user)
	if(tiltable && !tilted && I.force)
		if(resistance_flags & INDESTRUCTIBLE)
			// no goodies, but also no tilts
			return
		if(COOLDOWN_FINISHED(src, last_hit_time))
			visible_message(span_warning("[src] seems to sway a bit!"))
			to_chat(user, span_userdanger("You might want to think twice about doing that again, [src] looks like it could come crashing down!"))
			COOLDOWN_START(src, last_hit_time, hit_warning_cooldown_length)
			return

		switch(rand(1, 100))
			if(1 to 5)
				freebie(user, 3)
			if(6 to 15)
				freebie(user, 2)
			if(16 to 25)
				freebie(user, 1)
			if(26 to 75)
				return
			if(76 to 90)
				tilt(user)
			if(91 to 100)
				tilt(user, crit = TRUE)

/obj/machinery/vending/proc/freebie(mob/user, num_freebies)
	visible_message(span_notice("[num_freebies] free goodie\s tumble[num_freebies > 1 ? "" : "s"] out of [src]!"))
	for(var/i in 1 to num_freebies)
		for(var/datum/data/vending_product/R in shuffle(product_records))
			if(R.amount <= 0)
				continue
			var/dump_path = R.product_path
			if(!dump_path)
				continue
			new dump_path(get_turf(src))
			R.amount--
			break

/obj/machinery/vending/HasProximity(atom/movable/AM)
	if(!aggressive  || tilted || !tiltable)
		return

	if(isliving(AM) && prob(25))
		AM.visible_message(
			span_warning("[src] suddenly topples over onto [AM]!"),
			span_userdanger("[src] topples over onto you without warning!")
		)
	tilt(AM, prob(5), FALSE)
	aggressive = FALSE
	//Not making same mistakes as offs did.
	// Don't make this brob more than 5%

/obj/machinery/vending/crowbar_act(mob/user, obj/item/I)
	if(!component_parts)
		return
	. = TRUE
	if(tilted)
		to_chat(user, span_warning("You'll need to right it first!"))
		return
	default_deconstruction_crowbar(user, I)

/obj/machinery/vending/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(tilted)
		to_chat(user, span_warning("You'll need to right it first!"))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	wires.Interact(user)

/obj/machinery/vending/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(tilted)
		to_chat(user, span_warning("You'll need to right it first!"))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(anchored)
		panel_open = !panel_open
		panel_open ? SCREWDRIVER_OPEN_PANEL_MESSAGE : SCREWDRIVER_CLOSE_PANEL_MESSAGE
		update_icon()
		SStgui.update_uis(src)

/obj/machinery/vending/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(tilted)
		to_chat(user, span_warning("You'll need to right it first!"))
		return
	if(I.use_tool(src, user, 0, volume = 0))
		wires.Interact(user)

/obj/machinery/vending/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(tilted)
		to_chat(user, span_warning("The fastening bolts aren't on the ground, you'll need to right it first!"))
		return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	default_unfasten_wrench(user, I, time = 60)

/obj/machinery/vending/ex_act(severity)
	. = ..()
	if(QDELETED(src) || (resistance_flags & INDESTRUCTIBLE) || tilted || !tiltable)
		return
	var/tilt_prob = 0
	switch(severity)
		if(EXPLODE_LIGHT)
			tilt_prob = 10
		if(EXPLODE_HEAVY)
			tilt_prob = 50
		if(EXPLODE_DEVASTATE)
			tilt_prob = 80
	if(prob(tilt_prob))
		tilt()

//Override this proc to do per-machine checks on the inserted item, but remember to call the parent to handle these generic checks before your logic!
/obj/machinery/vending/proc/item_slot_check(mob/user, obj/item/I)
	if(!item_slot)
		return FALSE
	if(inserted_item)
		to_chat(user, "<span class='warning'>There is something already inserted!</span>")
		return FALSE
	return TRUE

/* Example override for item_slot_check proc:
/obj/machinery/vending/example/item_slot_check(mob/user, obj/item/I)
	if(!..())
		return FALSE
	if(!istype(I, /obj/item/toy))
		to_chat(user, "<span class='warning'>[I] isn't compatible with this machine's slot.</span>")
		return FALSE
	return TRUE
*/

/obj/machinery/vending/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	if(!istype(W))
		return FALSE
	if(!W.works_from_distance)
		return FALSE
	if(!component_parts || !refill_canister)
		return FALSE

	var/moved = 0
	if(panel_open || W.works_from_distance)
		if(W.works_from_distance)
			to_chat(user, display_parts(user))
		for(var/I in W)
			if(istype(I, refill_canister))
				moved += restock(I)
	else
		to_chat(user, display_parts(user))
	if(moved)
		to_chat(user, "[moved] items restocked.")
		W.play_rped_sound()
	return TRUE

/obj/machinery/vending/on_deconstruction()
	update_canister()
	. = ..()

/obj/machinery/vending/proc/insert_item(mob/user, obj/item/I)
	if(!item_slot || inserted_item)
		return
	if(!user.drop_transfer_item_to_loc(I, src))
		to_chat(user, "<span class='warning'>[I] is stuck to your hand, you can't seem to put it down!</span>")
		return
	inserted_item = I
	to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
	SStgui.update_uis(src)

/obj/machinery/vending/proc/eject_item(mob/user)
	if(!item_slot || !inserted_item)
		return
	var/put_on_turf = TRUE
	if(user && iscarbon(user) && user.Adjacent(src))
		inserted_item.forceMove_turf()
		if(user.put_in_hands(inserted_item, ignore_anim = FALSE))
			put_on_turf = FALSE
	if(put_on_turf)
		var/turf/T = get_turf(src)
		inserted_item.forceMove(T)
	inserted_item = null
	SStgui.update_uis(src)

/obj/machinery/vending/emag_act(mob/user)
	emagged = TRUE
	if(user)
		to_chat(user, "You short out the product lock on [src]")

/obj/machinery/vending/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/vending/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/vending/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	if(tilted)
		to_chat(user, span_warning("[src] is tipped over and non-functional! You'll need to right it first."))
		return

	if(..())
		return TRUE

	if(src.seconds_electrified != 0)
		if(src.shock(user, 100))
			add_fingerprint(user)
			return

	add_fingerprint(user)
	ui_interact(user)
	wires.Interact(user)

/obj/machinery/vending/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		var/estimated_height = 100 + min(length(product_records) * 34, 500)
		if(length(prices) > 0)
			estimated_height += 100 // to account for the "current user" interface
		ui = new(user, src, "Vending",  name)
		ui.open()

/obj/machinery/vending/ui_data(mob/user)
	var/list/data = list()
	var/datum/money_account/A = null
	data["guestNotice"] = "No valid ID card detected. Wear your ID, or present cash.";
	data["userMoney"] = 0
	data["user"] = null
	if(issilicon(user) && !istype(user, /mob/living/silicon/robot/drone) && !istype(user, /mob/living/silicon/pai))
		A = get_card_account(user)
		data["user"] = list()
		data["user"]["name"] = A.owner_name
		data["userMoney"] = A.money
		data["user"]["job"] = "Silicon"
	if(ishuman(user))
		A = get_card_account(user)
		var/mob/living/carbon/human/H = user
		var/obj/item/stack/spacecash/S = H.get_active_hand()
		if(istype(S))
			data["userMoney"] = S.amount
			data["guestNotice"] = "Accepting Cash. You have: [S.amount] credits."
		else if(istype(H))
			var/obj/item/card/id/C = H.get_id_card()
			if(istype(A))
				data["user"] = list()
				data["user"]["name"] = A.owner_name
				data["userMoney"] = A.money
				data["user"]["job"] = (istype(C) && C.rank) ? C.rank : "No Job"
			else
				data["guestNotice"] = "Unlinked ID detected. Present cash to pay.";
	data["stock"] = list()
	for (var/datum/data/vending_product/R in product_records + coin_records + hidden_records)
		data["stock"][R.name] = R.amount
	data["extended_inventory"] = extended_inventory
	data["vend_ready"] = vend_ready
	data["coin_name"] = coin ? coin.name : FALSE
	data["panel_open"] = panel_open ? TRUE : FALSE
	data["speaker"] = shut_up ? FALSE : TRUE
	data["item_slot"] = item_slot // boolean
	data["inserted_item_name"] = inserted_item ? inserted_item.name : FALSE
	return data


/obj/machinery/vending/ui_static_data(mob/user)
	var/list/data = list()
	data["chargesMoney"] = length(prices) > 0 ? TRUE : FALSE
	data["product_records"] = list()
	var/i = 1
	for (var/datum/data/vending_product/R in product_records)
		var/list/data_pr = list(
			path = replacetext(replacetext("[R.product_path]", "/obj/item/", ""), "/", "-"),
			name = R.name,
			price = (R.product_path in prices) ? prices[R.product_path] : 0,
			max_amount = R.max_amount,
			req_coin = FALSE,
			is_hidden = FALSE,
			inum = i
		)
		data["product_records"] += list(data_pr)
		i++
	data["coin_records"] = list()
	for (var/datum/data/vending_product/R in coin_records)
		var/list/data_cr = list(
			path = replacetext(replacetext("[R.product_path]", "/obj/item/", ""), "/", "-"),
			name = R.name,
			price = (R.product_path in prices) ? prices[R.product_path] : 0,
			max_amount = R.max_amount,
			req_coin = TRUE,
			is_hidden = FALSE,
			inum = i,
			premium = TRUE
		)
		data["coin_records"] += list(data_cr)
		i++
	data["hidden_records"] = list()
	for (var/datum/data/vending_product/R in hidden_records)
		var/list/data_hr = list(
			path = replacetext(replacetext("[R.product_path]", "/obj/item/", ""), "/", "-"),
			name = R.name,
			price = (R.product_path in prices) ? prices[R.product_path] : 0,
			max_amount = R.max_amount,
			req_coin = FALSE,
			is_hidden = TRUE,
			inum = i,
			premium = TRUE
		)
		data["hidden_records"] += list(data_hr)
		i++
	data["imagelist"] = imagelist
	return data

/obj/machinery/vending/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(issilicon(usr) && !isrobot(usr))
		to_chat(usr, span_warning("The vending machine refuses to interface with you, as you are not in its target demographic!"))
		return
	switch(action)
		if("toggle_voice")
			if(panel_open)
				shut_up = !shut_up
				. = TRUE
		if("eject_item")
			eject_item(usr)
			. = TRUE
		if("remove_coin")
			if(!coin)
				to_chat(usr, span_warning("There is no coin in this machine."))
				return
			if(istype(usr, /mob/living/silicon))
				to_chat(usr, span_warning("You lack hands."))
				return
			to_chat(usr, span_notice("You remove [coin] from [src]."))
			coin.forceMove_turf()
			usr.put_in_hands(coin, ignore_anim = FALSE)
			coin = null
			. = TRUE
		if("vend")
			if(!vend_ready)
				to_chat(usr, span_warning("The vending machine is busy!"))
				return
			if(panel_open)
				to_chat(usr, span_warning("The vending machine cannot dispense products while its service panel is open!"))
				return
			var/key = text2num(params["inum"])
			var/list/display_records = product_records + coin_records
			if(extended_inventory)
				display_records = product_records + coin_records + hidden_records
			if(key < 1 || key > length(display_records))
				to_chat(usr, span_warning("ERROR: invalid inum passed to vendor. Report this bug."))
				return
			var/datum/data/vending_product/R = display_records[key]
			if(!istype(R))
				to_chat(usr, span_warning("ERROR: unknown vending_product record. Report this bug."))
				return
			var/list/record_to_check = product_records + coin_records
			if(extended_inventory)
				record_to_check = product_records + coin_records + hidden_records
			if(!R || !istype(R) || !R.product_path)
				to_chat(usr, span_warning("ERROR: unknown product record. Report this bug."))
				return
			if(R in hidden_records)
				if(!extended_inventory)
					// Exploit prevention, stop the user purchasing hidden stuff if they haven't hacked the machine.
					to_chat(usr, span_warning("ERROR: machine does not allow extended_inventory in current state. Report this bug."))
					return
			else if (!(R in record_to_check))
				// Exploit prevention, stop the user
				message_admins("Vending machine exploit attempted by [ADMIN_LOOKUPFLW(usr)]!")
				return
			if (R.amount <= 0)
				to_chat(usr, "Sold out of [R.name].")
				flick_vendor_overlay(FLICK_VEND)
				return

			vend_ready = FALSE // From this point onwards, vendor is locked to performing this transaction only, until it is resolved.

			if(!(ishuman(usr) || issilicon(usr)) || R.price <= 0)
				// Either the purchaser is not human nor silicon, or the item is free.
				// Skip all payment logic.
				vend(R, usr)
				add_fingerprint(usr)
				vend_ready = TRUE
				. = TRUE
				return

			// --- THE REST OF THIS PROC IS JUST PAYMENT LOGIC ---
			if(!GLOB.vendor_account || GLOB.vendor_account.suspended)
				to_chat(usr, "Vendor account offline. Unable to process transaction.")
				flick_vendor_overlay(FLICK_DENY)
				vend_ready = TRUE
				return

			currently_vending = R
			var/paid = FALSE

			if(istype(usr.get_active_hand(), /obj/item/stack/spacecash))
				var/obj/item/stack/spacecash/S = usr.get_active_hand()
				paid = pay_with_cash(S, usr, currently_vending.price, currently_vending.name)
			else if(get_card_account(usr))
				// Because this uses H.get_id_card(), it will attempt to use:
				// active hand, inactive hand, wear_id, pda, and then w_uniform ID in that order
				// this is important because it lets people buy stuff with someone else's ID by holding it while using the vendor
				paid = pay_with_card(usr, currently_vending.price, currently_vending.name)
			else if(usr.can_advanced_admin_interact())
				to_chat(usr, span_notice("Vending object due to admin interaction."))
				paid = TRUE
			else
				to_chat(usr, span_warning("Payment failure: you have no ID or other method of payment."))
				vend_ready = TRUE
				flick_vendor_overlay(FLICK_DENY)
				. = TRUE // we set this because they shouldn't even be able to get this far, and we want the UI to update.
				return
			if(paid)
				vend(currently_vending, usr)
				. = TRUE
			else
				to_chat(usr, span_warning("Payment failure: unable to process payment."))
				vend_ready = TRUE
	if(.)
		add_fingerprint(usr)




/obj/machinery/vending/proc/vend(datum/data/vending_product/R, mob/user)
	if(!allowed(user) && !user.can_admin_interact() && !emagged && scan_id)	//For SECURE VENDING MACHINES YEAH
		to_chat(user, span_warning("Access denied."))//Unless emagged of course
		flick_vendor_overlay(FLICK_DENY)
		vend_ready = TRUE
		return

	if(!R.amount)
		to_chat(user, span_warning("The vending machine has ran out of that product."))
		vend_ready = TRUE
		return

	vend_ready = FALSE //One thing at a time!!

	if(coin_records.Find(R))
		if(!coin)
			to_chat(user, span_notice("You need to insert a coin to get this item."))
			vend_ready = TRUE
			return
		if(coin.string_attached)
			if(prob(50))
				to_chat(user, span_notice("You successfully pull the coin out before [src] could swallow it."))
			else
				to_chat(user, span_notice("You weren't able to pull the coin out fast enough, the machine ate it, string and all."))
				QDEL_NULL(coin)
		else
			QDEL_NULL(coin)

	R.amount--

	if(((last_reply + (vend_delay + 200)) <= world.time) && vend_reply)
		speak(src.vend_reply)
		last_reply = world.time

	use_power(vend_power_usage)	//actuators and stuff
	flick_vendor_overlay(FLICK_VEND)	//Show the vending animation if needed
	playsound(get_turf(src), 'sound/machines/machine_vend.ogg', 50, TRUE)
	addtimer(CALLBACK(src, PROC_REF(delayed_vend), R, user), vend_delay)


/obj/machinery/vending/proc/delayed_vend(datum/data/vending_product/R, mob/user)
	do_vend(R, user)
	vend_ready = TRUE
	currently_vending = null


/**
 * Override this proc to add handling for what to do with the vended product
 * when you have a inserted item and remember to include a parent call for this generic handling
 */
/obj/machinery/vending/proc/do_vend(datum/data/vending_product/R, mob/user)
	if(!item_slot || !inserted_item)
		var/put_on_turf = TRUE
		var/obj/item/vended = new R.product_path(drop_location())
		if(istype(vended) && user && iscarbon(user) && user.Adjacent(src))
			if(user.put_in_hands(vended, ignore_anim = FALSE))
				put_on_turf = FALSE
		if(put_on_turf)
			var/turf/T = get_turf(src)
			vended.forceMove(T)
		return TRUE
	return FALSE

/* Example override for do_vend proc:
/obj/machinery/vending/example/do_vend(datum/data/vending_product/R)
	if(..())
		return
	var/obj/item/vended = new R.product_path()
	if(inserted_item.force == initial(inserted_item.force)
		inserted_item.force += vended.force
	inserted_item.damtype = vended.damtype
	qdel(vended)
*/

/obj/machinery/vending/process()
	if(stat & (BROKEN|NOPOWER))
		return

	if(!active)
		return

	if(src.seconds_electrified > 0)
		src.seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(((last_slogan + src.slogan_delay) <= world.time) && (LAZYLEN(slogan_list)) && (!shut_up) && prob(5))
		var/slogan = pick(src.slogan_list)
		speak(slogan)
		last_slogan = world.time

	if(shoot_inventory && prob(shoot_chance))
		throw_item()


/obj/machinery/vending/proc/speak(message)
	if(stat & NOPOWER)
		return
	if(!message)
		return

	atom_say(message)


/obj/machinery/vending/obj_break(damage_flag)
	if(stat & BROKEN)
		return

	stat |= BROKEN
	update_icon(UPDATE_OVERLAYS)

	var/dump_amount = 0
	var/found_anything = TRUE
	while (found_anything)
		found_anything = FALSE
		for(var/record in shuffle(product_records))
			var/datum/data/vending_product/R = record
			if(R.amount <= 0) //Try to use a record that actually has something to dump.
				continue
			var/dump_path = R.product_path
			if(!dump_path)
				continue
			R.amount--
			// busting open a vendor will destroy some of the contents
			if(found_anything && prob(80))
				continue

			var/obj/O = new dump_path(loc)
			step(O, pick(GLOB.alldirs))
			found_anything = TRUE
			dump_amount++
			if(dump_amount >= 16)
				return


//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7, src)
	if(!target)
		return 0

	for(var/datum/data/vending_product/R in product_records)
		if(R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if(!dump_path)
			continue

		R.amount--
		throw_item = new dump_path(loc)
		break
	if(!throw_item)
		return
	throw_item.throw_at(target, 16, 3)
	visible_message("<span class='danger'>[src] launches [throw_item.name] at [target.name]!</span>")


/obj/machinery/vending/shove_impact(mob/living/target, mob/living/attacker)
	if(HAS_TRAIT(target, TRAIT_FLATTENED))
		return
	if(!HAS_TRAIT(attacker, TRAIT_PACIFISM) || !GLOB.pacifism_after_gt)
		add_attack_logs(attacker, target, "shoved into a vending machine ([src])")
		tilt(target, from_combat = TRUE)
		target.visible_message(
			span_danger("[attacker] slams [target] into [src]!"),
			span_userdanger("You get slammed into [src] by [attacker]!"),
			span_danger(">You hear a loud crunch.")
		)
	else
		attacker.visible_message(
			span_notice("[attacker] lightly presses [target] against [src]."),
			span_userdanger("You lightly press [target] against [src], you don't want to hurt [target.p_them()]!")
			)
	return TRUE

/**
 * Select a random valid crit.
 */
/obj/machinery/vending/proc/choose_crit(mob/living/carbon/victim)
	if(!length(possible_crits))
		return
	for(var/crit_path in shuffle(possible_crits))
		var/datum/vendor_crit/C = all_possible_crits[crit_path]
		if(C.is_valid(src, victim))
			return C

/obj/machinery/vending/proc/handle_squish_carbon(mob/living/carbon/victim, damage_to_deal, crit, from_combat)

	// Damage points to "refund", if a crit already beats the shit out of you we can shelve some of the extra damage.
	var/crit_rebate = 0

	var/should_throw_at_target = TRUE

	var/datum/vendor_crit/critical_attack = choose_crit(victim)
	if(!from_combat && crit && critical_attack)
		crit_rebate = critical_attack.tip_crit_effect(src, victim)
		if(critical_attack.harmless)
			tilt_over(critical_attack.fall_towards_mob ? victim : null)
			return VENDOR_CRUSH_HANDLED

		should_throw_at_target = critical_attack.fall_towards_mob
		add_attack_logs(null, victim, "critically crushed by [src] causing [critical_attack]")

	else
		victim.visible_message(
			span_danger("[victim] is crushed by [src]!"),
			span_userdanger("[src] crushes you!"),
			span_warning("You hear a loud crunch!")
		)
		add_attack_logs(null, victim, "crushed by [src]")

	// 30% chance to spread damage across the entire body, 70% chance to target two limbs in particular
	damage_to_deal = max(damage_to_deal - crit_rebate, 0)
	if(prob(30))
		victim.apply_damage(damage_to_deal, BRUTE, spread_damage = TRUE)
	else
		var/picked_zone
		var/num_parts_to_pick = 2
		for(var/i = 1 to num_parts_to_pick)
			picked_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)
			victim.apply_damage((damage_to_deal) * (1 / num_parts_to_pick), BRUTE, picked_zone)

	victim.AddElement(/datum/element/tilt_protection, 80 SECONDS) // use "/datum/element/squish" when people are ready for that.
	if(victim.has_pain())
		victim.emote("scream")

	return should_throw_at_target ? VENDOR_THROW_AT_TARGET : VENDOR_TIP_IN_PLACE

/**
 * Tilts the machine onto the atom passed in.
 *
 * Arguments:
 * * target_atom - The thing the machine is falling on top of
 * * crit - if true, some special damage effects might happen.
 * * from_combat - If true, hold off on some of the additional damage and extra effects.
 */

/obj/machinery/vending/proc/tilt(atom/target_atom, crit = FALSE, from_combat = FALSE)
	if(QDELETED(src) || !has_gravity(src) || !tiltable || tilted)
		return

	tilted = TRUE
	set_anchored(FALSE)
	layer = ABOVE_MOB_LAYER

	var/should_throw_at_target = TRUE

	. = FALSE

	if(!target_atom || !in_range(target_atom, src))
		tilt_over()
		return
	for(var/mob/living/victim in get_turf(target_atom))
		// Damage to deal outright
		var/damage_to_deal = squish_damage
		if(!from_combat)
			if(crit)
				// increase damage if you knock it over onto yourself
				damage_to_deal *= crit_damage_factor
			else
				damage_to_deal *= self_knockover_factor

		if(iscarbon(victim))
			var/throw_spec = handle_squish_carbon(target_atom, damage_to_deal, crit, from_combat)
			switch(throw_spec)
				if(VENDOR_CRUSH_HANDLED)
					return TRUE
				if(VENDOR_THROW_AT_TARGET)
					should_throw_at_target = TRUE
				if(VENDOR_TIP_IN_PLACE)
					should_throw_at_target = FALSE
		else
			victim.visible_message(
				span_danger("[victim] is crushed by [src]!"),
				span_userdanger("[src] falls on top of you, crushing you!"),
				span_warning("You hear a loud crunch!")
			)
			victim.apply_damage(damage_to_deal, BRUTE)
			add_attack_logs(null, victim, "crushed by [src]")

		. = TRUE
		victim.Weaken(4 SECONDS)
		victim.Knockdown(8 SECONDS)

		playsound(victim, "sound/effects/blobattack.ogg", 40, TRUE)
		playsound(victim, "sound/effects/splat.ogg", 50, TRUE)

		tilt_over(should_throw_at_target ? target_atom : null)

/obj/machinery/vending/proc/tilt_over(mob/victim)
	visible_message( span_danger("[src] tips over!"))
	playsound(src, "sound/effects/bang.ogg", 100, TRUE)
	var/picked_rotation = pick(90, 270)
	tilted_rotation = picked_rotation
	var/matrix/to_turn = turn(transform, tilted_rotation)
	animate(src, transform = to_turn, 0.2 SECONDS)

	if(victim && get_turf(victim) != get_turf(src))
		throw_at(get_turf(victim), 1, 1, spin = FALSE)

/obj/machinery/vending/proc/untilt(mob/user)
	if(!tilted)
		return

	if(user)
		user.visible_message(
			"[user] begins to right [src].",
			"You begin to right [src]."
		)
		if(!do_after(user, 7 SECONDS, src))
			return
		user.visible_message(
			span_notice("[user] rights [src]."),
			span_notice("You right [src]."),
			span_notice(">You hear a loud clang.")
		)

	unbuckle_all_mobs(TRUE)

	tilted = FALSE
	layer = initial(layer)

	var/matrix/to_turn = turn(transform, -tilted_rotation)
	animate(src, transform = to_turn, 0.2 SECONDS)

/obj/machinery/vending/assist

	icon_state = "generic_off"
	panel_overlay = "generic_panel"
	screen_overlay = "generic"
	lightmask_overlay = "generic_lightmask"
	broken_overlay = "generic_broken"
	broken_lightmask_overlay = "generic_broken_lightmask"

	products = list(	/obj/item/assembly/prox_sensor = 5,/obj/item/assembly/igniter = 3,/obj/item/assembly/signaler = 4,
						/obj/item/wirecutters = 1, /obj/item/cartridge/signal = 4)
	contraband = list(/obj/item/flashlight = 5,/obj/item/assembly/timer = 2, /obj/item/assembly/voice = 2, /obj/item/assembly/health = 2)
	ads_list = list("Only the finest!","Have some tools.","The most robust equipment.","The finest gear in space!")
	refill_canister = /obj/item/vending_refill/assist

/obj/machinery/vending/boozeomat
	name = "\improper Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."

	icon_state = "boozeomat_off"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	panel_overlay = "boozeomat_panel"
	screen_overlay = "boozeomat"
	lightmask_overlay = "boozeomat_lightmask"
	broken_overlay = "boozeomat_broken"
	broken_lightmask_overlay = "boozeomat_broken_lightmask"
	deny_overlay = "boozeomat_deny"

	products = list(/obj/item/reagent_containers/food/drinks/bottle/gin = 5,
					/obj/item/reagent_containers/food/drinks/bottle/whiskey = 5,
					/obj/item/reagent_containers/food/drinks/bottle/tequila = 5,
					/obj/item/reagent_containers/food/drinks/bottle/vodka = 5,
					/obj/item/reagent_containers/food/drinks/bottle/vermouth = 5,
					/obj/item/reagent_containers/food/drinks/bottle/rum = 5,
					/obj/item/reagent_containers/food/drinks/bottle/wine = 5,
					/obj/item/reagent_containers/food/drinks/bottle/arrogant_green_rat = 3,
					/obj/item/reagent_containers/food/drinks/bottle/cognac = 5,
					/obj/item/reagent_containers/food/drinks/bottle/kahlua = 5,
					/obj/item/reagent_containers/food/drinks/bottle/champagne = 5,
					/obj/item/reagent_containers/food/drinks/bottle/aperol = 5,
					/obj/item/reagent_containers/food/drinks/bottle/jagermeister = 5,
					/obj/item/reagent_containers/food/drinks/bottle/schnaps = 5,
					/obj/item/reagent_containers/food/drinks/bottle/sheridan = 5,
					/obj/item/reagent_containers/food/drinks/bottle/bluecuracao = 5,
					/obj/item/reagent_containers/food/drinks/bottle/sambuka = 5,
					/obj/item/reagent_containers/food/drinks/bottle/bitter = 3,
					/obj/item/reagent_containers/food/drinks/cans/beer = 6,
					/obj/item/reagent_containers/food/drinks/cans/non_alcoholic_beer = 6,
					/obj/item/reagent_containers/food/drinks/cans/ale = 6,
					/obj/item/reagent_containers/food/drinks/cans/synthanol = 15,
					/obj/item/reagent_containers/food/drinks/bottle/orangejuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/tomatojuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/limejuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/cream = 4,
					/obj/item/reagent_containers/food/drinks/cans/tonic = 8,
					/obj/item/reagent_containers/food/drinks/cans/cola = 8,
					/obj/item/reagent_containers/food/drinks/cans/sodawater = 15,
					/obj/item/reagent_containers/food/drinks/drinkingglass = 30,
					/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass = 30,
					/obj/item/reagent_containers/food/drinks/ice = 9)
	contraband = list(/obj/item/reagent_containers/food/drinks/tea = 10,
					  /obj/item/reagent_containers/food/drinks/bottle/fernet = 5)
	vend_delay = 15
	slogan_list = list("Надеюсь, никто не попросит меня о чёртовой кружке чая…","Алкоголь — друг человека. Вы же не бросите друга?","Очень рад вас обслужить!","Никто на этой станции не хочет выпить?")
	ads_list = list("Выпьем!","Бухло пойдёт вам на пользу!","Алкоголь — друг человека.","Очень рад вас обслужить!","Хотите отличного холодного пива?","Ничто так не лечит, как бухло!","Пригубите!","Выпейте!","Возьмите пивка!","Пиво пойдёт вам на пользу!","Только лучший алкоголь!","Бухло лучшего качества с 2053 года!","Вино со множеством наград!","Максимум алкоголя!","Мужчины любят пиво","Тост: «За прогресс!»")
	refill_canister = /obj/item/vending_refill/boozeomat

/obj/machinery/vending/boozeomat/syndicate_access
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/vending/coffee
	name = "\improper Solar's Best Hot Drinks"
	desc = "A vending machine which dispenses hot drinks."
	ads_list = list("Выпейте!","Выпьем!","На здоровье!","Не хотите горячего супчику?","Я бы убил за чашечку кофе!","Лучшие зёрна в галактике","Для Вас — только лучшие напитки","М-м-м-м… Ничто не сравнится с кофе","Я люблю кофе, а Вы?","Кофе помогает работать!","Возьмите немного чайку","Надеемся, Вы предпочитаете лучшее!","Отведайте наш новый шоколад!","Admin conspiracies")

	icon_state = "coffee_off"
	panel_overlay = "coffee_panel"
	screen_overlay = "coffee"
	lightmask_overlay = "coffee_lightmask"
	broken_overlay = "coffee_broken"
	broken_lightmask_overlay = "coffee_broken_lightmask"
	vend_overlay = "coffee_vend"
	vend_lightmask = "coffee_vend_lightmask"

	item_slot = TRUE
	vend_delay = 34
	products = list(/obj/item/reagent_containers/food/drinks/coffee = 25,
		/obj/item/reagent_containers/food/drinks/tea = 25,
		/obj/item/reagent_containers/food/drinks/h_chocolate = 25,
		/obj/item/reagent_containers/food/drinks/chocolate = 10,
		/obj/item/reagent_containers/food/drinks/chicken_soup = 10,
		/obj/item/reagent_containers/food/drinks/weightloss = 10,
		/obj/item/reagent_containers/food/drinks/mug = 15,
		/obj/item/reagent_containers/food/drinks/mug/novelty = 5)
	contraband = list(/obj/item/reagent_containers/food/drinks/ice = 10)
	prices = list(/obj/item/reagent_containers/food/drinks/coffee = 25,
		/obj/item/reagent_containers/food/drinks/tea = 25,
		/obj/item/reagent_containers/food/drinks/h_chocolate = 25,
		/obj/item/reagent_containers/food/drinks/chocolate = 25,
		/obj/item/reagent_containers/food/drinks/chicken_soup = 30,
		/obj/item/reagent_containers/food/drinks/weightloss = 50,
		/obj/item/reagent_containers/food/drinks/mug = 50,
		/obj/item/reagent_containers/food/drinks/mug/novelty = 100,
		/obj/item/reagent_containers/food/drinks/ice = 40)
	refill_canister = /obj/item/vending_refill/coffee

/obj/machinery/vending/coffee/free
	prices = list()

/obj/machinery/vending/coffee/item_slot_check(mob/user, obj/item/I)
	if(!(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks)))
		return FALSE
	if(!..())
		return FALSE
	if(!I.is_open_container())
		to_chat(user, "<span class='warning'>You need to open [I] before inserting it.</span>")
		return FALSE
	return TRUE

/obj/machinery/vending/coffee/do_vend(datum/data/vending_product/R, mob/user)
	if(..())
		return
	var/obj/item/reagent_containers/food/drinks/vended = new R.product_path()

	if(istype(vended, /obj/item/reagent_containers/food/drinks/mug))
		var/put_on_turf = TRUE
		if(user && iscarbon(user) && user.Adjacent(src))
			vended.forceMove_turf()
			if(user.put_in_hands(vended, ignore_anim = FALSE))
				put_on_turf = FALSE
		if(put_on_turf)
			var/turf/T = get_turf(src)
			vended.forceMove(T)
		return

	vended.reagents.trans_to(inserted_item, vended.reagents.total_volume)
	if(vended.reagents.total_volume)
		var/put_on_turf = TRUE
		if(user && iscarbon(user) && user.Adjacent(src))
			vended.forceMove_turf()
			if(user.put_in_hands(vended, ignore_anim = FALSE))
				put_on_turf = FALSE
		if(put_on_turf)
			var/turf/T = get_turf(src)
			vended.forceMove(T)
	else
		qdel(vended)


/obj/machinery/vending/snack
	name = "\improper Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	slogan_list = list("Попробуйте наш новый батончик с нугой!","Вдвое больше калорий за полцены!")
	ads_list = list("The healthiest!","Award-winning chocolate bars!","Mmm! So good!","Oh my god it's so juicy!","Have a snack.","Snacks are good for you!","Have some more Getmore!","Best quality snacks straight from mars.","We love chocolate!","Try our new jerky!")

	icon_state = "snack_off"
	panel_overlay = "snack_panel"
	screen_overlay = "snack"
	lightmask_overlay = "snack_lightmask"
	broken_overlay = "snack_broken"
	broken_lightmask_overlay = "snack_broken_lightmask"

	products = list(/obj/item/reagent_containers/food/snacks/candy/candybar = 6,
					/obj/item/reagent_containers/food/drinks/dry_ramen = 6,
					/obj/item/reagent_containers/food/snacks/doshik = 6,
					/obj/item/reagent_containers/food/snacks/doshik_spicy = 6,
					/obj/item/reagent_containers/food/snacks/chips =6,
					/obj/item/reagent_containers/food/snacks/sosjerky = 6,
					/obj/item/reagent_containers/food/snacks/no_raisin = 6,
					/obj/item/reagent_containers/food/snacks/pistachios =6,
					/obj/item/reagent_containers/food/snacks/spacetwinkie = 6,
					/obj/item/reagent_containers/food/snacks/cheesiehonkers = 6,
					/obj/item/reagent_containers/food/snacks/tastybread = 6
					)
	contraband = list(/obj/item/reagent_containers/food/snacks/syndicake = 6)
	prices = list(/obj/item/reagent_containers/food/snacks/candy/candybar = 20,
					/obj/item/reagent_containers/food/drinks/dry_ramen = 30,
					/obj/item/reagent_containers/food/snacks/doshik = 30,
					/obj/item/reagent_containers/food/snacks/doshik_spicy = 150,
					/obj/item/reagent_containers/food/snacks/chips =25,
					/obj/item/reagent_containers/food/snacks/sosjerky = 30,
					/obj/item/reagent_containers/food/snacks/no_raisin = 20,
					/obj/item/reagent_containers/food/snacks/pistachios = 35,
					/obj/item/reagent_containers/food/snacks/spacetwinkie = 30,
					/obj/item/reagent_containers/food/snacks/cheesiehonkers = 25,
					/obj/item/reagent_containers/food/snacks/tastybread = 30,
					/obj/item/reagent_containers/food/snacks/syndicake = 50)
	refill_canister = /obj/item/vending_refill/snack

/obj/machinery/vending/snack/free
	prices = list()

/obj/machinery/vending/chinese
	name = "\improper Mr. Chang"
	desc = "A self-serving Chinese food machine, for all your Chinese food needs."
	slogan_list = list("Попробуйте 5000 лет культуры!","Мистер Чанг, одобрен для безопасного потребления в более чем 10 секторах!","Китайская кухня отлично подходит для вечернего свидания или одинокого вечера!","Вы не ошибетесь, если попробуете настоящую китайскую кухню от мистера Чанга.!")

	icon_state = "chang_off"
	panel_overlay = "chang_panel"
	screen_overlay = "chang"
	lightmask_overlay = "chang_lightmask"
	broken_overlay = "chang_broken"
	broken_lightmask_overlay = "chang_broken_lightmask"

	products = list(
		/obj/item/reagent_containers/food/snacks/chinese/chowmein = 6,
		/obj/item/reagent_containers/food/snacks/chinese/tao = 6,
		/obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball = 6,
		/obj/item/reagent_containers/food/snacks/chinese/newdles = 6,
		/obj/item/reagent_containers/food/snacks/chinese/rice = 6,
		/obj/item/reagent_containers/food/snacks/fortunecookie = 6,
		/obj/item/storage/box/crayfish_bucket = 5,
	)

	contraband = list(
		/obj/item/poster/cheng = 5,
		/obj/item/storage/box/mr_cheng = 3,
		/obj/item/clothing/head/rice_hat = 3,
	)

	prices = list(
		/obj/item/reagent_containers/food/snacks/chinese/chowmein = 50,
		/obj/item/reagent_containers/food/snacks/chinese/tao = 50,
		/obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball = 50,
		/obj/item/reagent_containers/food/snacks/chinese/newdles = 50,
		/obj/item/reagent_containers/food/snacks/chinese/rice = 50,
		/obj/item/reagent_containers/food/snacks/fortunecookie = 50,
		/obj/item/storage/box/crayfish_bucket = 250,
		/obj/item/storage/box/mr_cheng = 200,
	)

	refill_canister = /obj/item/vending_refill/chinese

/obj/machinery/vending/chinese/free
	prices = list()

/obj/machinery/vending/cola
	name = "\improper Robust Softdrinks"
	desc = "A soft drink vendor provided by Robust Industries, LLC."

	icon_state = "cola-machine_off"
	panel_overlay = "cola-machine_panel"
	screen_overlay = "cola-machine"
	lightmask_overlay = "cola-machine_lightmask"
	broken_overlay = "cola-machine_broken"
	broken_lightmask_overlay = "cola-machine_broken_lightmask"

	slogan_list = list("Роб+аст с+офтдринкс: крепче, чем тулбоксом по голове!")
	ads_list = list("Освежает!","Надеюсь, вас одолела жажда!","Продано больше миллиона бутылок!","Хотите пить? Почему бы не взять колы?","Пожалуйста, купите напиток","Выпьем!","Лучшие напитки во всём космосе")
	products = list(
		/obj/item/reagent_containers/food/drinks/cans/cola = 10,
		/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind = 10,
		/obj/item/reagent_containers/food/drinks/cans/dr_gibb = 10,
		/obj/item/reagent_containers/food/drinks/cans/starkist = 10,
		/obj/item/reagent_containers/food/drinks/cans/space_up = 10,
		/obj/item/reagent_containers/food/drinks/cans/grape_juice = 10,
		/obj/item/reagent_containers/food/drinks/cans/energy = 10,
		/obj/item/reagent_containers/food/drinks/cans/energy/trop = 10,
		/obj/item/reagent_containers/food/drinks/cans/energy/milk = 10,
		/obj/item/reagent_containers/food/drinks/cans/energy/grey = 10)
	contraband = list(/obj/item/reagent_containers/food/drinks/cans/thirteenloko = 5, /obj/item/reagent_containers/food/drinks/zaza = 1)
	prices = list(
		/obj/item/reagent_containers/food/drinks/cans/cola = 20,
		/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind = 20,
		/obj/item/reagent_containers/food/drinks/cans/dr_gibb = 20,
		/obj/item/reagent_containers/food/drinks/cans/starkist = 20,
		/obj/item/reagent_containers/food/drinks/cans/space_up = 20,
		/obj/item/reagent_containers/food/drinks/cans/grape_juice = 20,
		/obj/item/reagent_containers/food/drinks/cans/energy = 40,
		/obj/item/reagent_containers/food/drinks/cans/energy/trop = 40,
		/obj/item/reagent_containers/food/drinks/cans/energy/milk = 40,
		/obj/item/reagent_containers/food/drinks/cans/energy/grey = 40,
		/obj/item/reagent_containers/food/drinks/cans/thirteenloko = 80,
		/obj/item/reagent_containers/food/drinks/zaza = 200)
	refill_canister = /obj/item/vending_refill/cola

/obj/machinery/vending/cola/free
	prices = list()

/obj/machinery/vending/cart
	name = "\improper PTech"
	desc = "Cartridges for PDA's."
	slogan_list = list("Карточки в дорогу!")

	icon_state = "cart_off"
	panel_overlay = "cart_panel"
	screen_overlay = "cart"
	lightmask_overlay = "cart_lightmask"
	broken_overlay = "cart_broken"
	broken_lightmask_overlay = "cart_broken_lightmask"
	deny_overlay = "cart_deny"

	products = list(/obj/item/pda =10,/obj/item/eftpos = 6,/obj/item/cartridge/medical = 10,/obj/item/cartridge/chemistry = 10,
					/obj/item/cartridge/engineering = 10,/obj/item/cartridge/atmos = 10,/obj/item/cartridge/janitor = 10,
					/obj/item/cartridge/signal/toxins = 10,/obj/item/cartridge/signal = 10)
	contraband = list(/obj/item/cartridge/clown = 1,/obj/item/cartridge/mime = 1)
	prices = list(/obj/item/pda =300,/obj/item/eftpos = 200,/obj/item/cartridge/medical = 200,/obj/item/cartridge/chemistry = 150,/obj/item/cartridge/engineering = 100,
					/obj/item/cartridge/atmos = 75,/obj/item/cartridge/janitor = 100,/obj/item/cartridge/signal/toxins = 150,
					/obj/item/cartridge/signal = 75)
	refill_canister = /obj/item/vending_refill/cart

/obj/machinery/vending/cart/free
	prices = list()

/obj/machinery/vending/liberationstation
	name = "\improper Liberation Station"
	desc = "An overwhelming amount of <b>ancient patriotism</b> washes over you just by looking at the machine."

	icon_state = "liberationstation_off"
	panel_overlay = "liberationstation_panel"
	screen_overlay = "liberationstation"
	lightmask_overlay = "liberationstation_lightmask"
	broken_overlay = "liberationstation_broken"
	broken_lightmask_overlay = "liberationstation_broken_lightmask"

	req_access = list(ACCESS_SECURITY)
	slogan_list = list("Liberation Station: Your one-stop shop for all things second amendment!","Be a patriot today, pick up a gun!","Quality weapons for cheap prices!","Better dead than red!")
	ads_list = list("Float like an astronaut, sting like a bullet!","Express your second amendment today!","Guns don't kill people, but you can!","Who needs responsibilities when you have guns?")
	vend_reply = "Remember the name: Liberation Station!"
	products = list(/obj/item/gun/projectile/automatic/pistol/deagle/gold = 2,/obj/item/gun/projectile/automatic/pistol/deagle/camo = 2,
					/obj/item/gun/projectile/automatic/pistol/m1911 = 2,/obj/item/gun/projectile/automatic/proto = 2,
					/obj/item/gun/projectile/shotgun/automatic/combat = 2,/obj/item/gun/projectile/automatic/gyropistol = 1,
					/obj/item/gun/projectile/shotgun = 2,/obj/item/gun/projectile/automatic/ar = 2)
	premium = list(/obj/item/ammo_box/magazine/smgm9mm = 2,/obj/item/ammo_box/magazine/m50 = 4,/obj/item/ammo_box/magazine/m45 = 2,/obj/item/ammo_box/magazine/m75 = 2)
	contraband = list(/obj/item/clothing/under/patriotsuit = 1,/obj/item/bedsheet/patriot = 3)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF


/obj/machinery/vending/toyliberationstation
	name = "\improper Syndicate Donksoft Toy Vendor"
	desc = "An ages 8 and up approved vendor that dispenses toys. If you were to find the right wires, you can unlock the adult mode setting!"

	icon_state = "syndi_off"
	panel_overlay = "syndi_panel"
	screen_overlay = "syndi"
	lightmask_overlay = "syndi_lightmask"
	broken_overlay = "syndi_broken"
	broken_lightmask_overlay = "syndi_broken_lightmask"

	slogan_list = list("Get your cool toys today!","Trigger a valid hunter today!","Quality toy weapons for cheap prices!","Give them to HoPs for all access!","Give them to HoS to get permabrigged!")
	ads_list = list("Feel robust with your toys!","Express your inner child today!","Toy weapons don't kill people, but valid hunters do!","Who needs responsibilities when you have toy weapons?","Make your next murder FUN!")
	vend_reply = "Come back for more!"
	products = list(/obj/item/gun/projectile/automatic/toy = 10,
					/obj/item/gun/projectile/automatic/toy/pistol= 10,
					/obj/item/gun/projectile/shotgun/toy = 10,
					/obj/item/toy/sword = 10,
					/obj/item/ammo_box/foambox = 20,
					/obj/item/toy/foamblade = 10,
					/obj/item/toy/syndicateballoon = 10,
					/obj/item/clothing/suit/syndicatefake = 5,
					/obj/item/clothing/head/syndicatefake = 5) //OPS IN DORMS oh wait it's just an assistant
	contraband = list(/obj/item/gun/projectile/shotgun/toy/crossbow= 10,   //Congrats, you unlocked the +18 setting!
					  /obj/item/gun/projectile/automatic/c20r/toy/riot = 10,
					  /obj/item/gun/projectile/automatic/l6_saw/toy/riot = 10,
  					  /obj/item/gun/projectile/automatic/sniper_rifle/toy = 10,
					  /obj/item/ammo_box/foambox/riot = 20,
					  /obj/item/toy/katana = 10,
					  /obj/item/twohanded/dualsaber/toy = 5,
					  /obj/item/deck/cards/syndicate = 10) //Gambling and it hurts, making it a +18 item
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF


/obj/machinery/vending/cigarette
	name = "ShadyCigs Deluxe"
	desc = "If you want to get cancer, might as well do it in style."
	slogan_list = list("Космосигареты весьма хороши на вкус, какими они и должны быть","I'd rather toolbox than switch.","Затянитесь!","Не верьте исследованиям — курите!")
	ads_list = list("Наверняка не очень-то и вредно для Вас!","Не верьте учёным!","На здоровье!","Не бросайте курить, купите ещё!","Затянитесь!","Никотиновый рай","Лучшие сигареты с 2150 года","Сигареты с множеством наград")
	vend_delay = 34

	icon_state = "cigs_off"
	panel_overlay = "cigs_panel"
	screen_overlay = "cigs"
	lightmask_overlay = "cigs_lightmask"
	broken_overlay = "cigs_broken"
	broken_lightmask_overlay = "cigs_broken_lightmask"

	products = list(/obj/item/storage/fancy/cigarettes/cigpack_robust = 12,
					/obj/item/storage/fancy/cigarettes/cigpack_uplift = 6,
					/obj/item/storage/fancy/cigarettes/cigpack_random = 6,
					/obj/item/reagent_containers/food/pill/patch/nicotine = 10,
					/obj/item/storage/box/matches = 10,
					/obj/item/lighter/random = 4,
					/obj/item/storage/fancy/rollingpapers = 5,
					/obj/item/lighter/zippo = 4,
					/obj/item/clothing/mask/cigarette/cigar/havana = 2,
					/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1
					)
	contraband = list( /obj/item/clothing/mask/cigarette/pipe/oldpipe = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_med = 1
					)
	prices = list(/obj/item/storage/fancy/cigarettes/cigpack_robust = 180,
					/obj/item/storage/fancy/cigarettes/cigpack_uplift = 240,
					/obj/item/storage/fancy/cigarettes/cigpack_random = 360,
					/obj/item/reagent_containers/food/pill/patch/nicotine = 70,
					/obj/item/storage/box/matches = 10,
					/obj/item/lighter/random = 60,
					/obj/item/storage/fancy/rollingpapers = 20,
					/obj/item/clothing/mask/cigarette/pipe/oldpipe = 250,
					/obj/item/lighter/zippo = 250,
					/obj/item/clothing/mask/cigarette/cigar/havana = 1000,
					/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 700,
					/obj/item/storage/fancy/cigarettes/cigpack_med = 500
					)
	refill_canister = /obj/item/vending_refill/cigarette

/obj/machinery/vending/cigarette/free
	prices = list()

/obj/machinery/vending/cigarette/syndicate
	products = list(/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 7,
					/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_robust = 2,
					/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_midori = 1,
					/obj/item/storage/box/matches = 10,
					/obj/item/lighter/zippo = 4,
					/obj/item/storage/fancy/rollingpapers = 5)

/obj/machinery/vending/cigarette/syndicate/free
	prices = list()


/obj/machinery/vending/cigarette/beach //Used in the lavaland_biodome_beach.dmm ruin
	name = "\improper ShadyCigs Ultra"
	desc = "Now with extra premium products!"
	ads_list = list("Наверняка не очень-то и вредно для Вас!","Допинг проведёт через безденежье лучше, чем деньги через бездопингье!","На здоровье!")
	slogan_list = list("Включи, настрой, получи!","С химией жить веселей!","Затянитесь!","Сохраняй улыбку на устах и песню в своём сердце!")
	products = list(/obj/item/storage/fancy/cigarettes = 5,
					/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_robust = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_midori = 3,
					/obj/item/storage/box/matches = 10,
					/obj/item/lighter/random = 4,
					/obj/item/storage/fancy/rollingpapers = 5)
	premium = list(/obj/item/clothing/mask/cigarette/cigar/havana = 2,
				   /obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
				   /obj/item/lighter/zippo = 3)
	prices = list()

/obj/machinery/vending/medical
	name = "\improper NanoMed Plus"
	desc = "Medical drug dispenser."

	icon_state = "med_off"
	panel_overlay = "med_panel"
	screen_overlay = "med"
	lightmask_overlay = "med_lightmask"
	broken_overlay = "med_broken"
	broken_lightmask_overlay = "med_broken_lightmask"
	deny_overlay = "med_deny"

	ads_list = list("Иди и спаси несколько жизней!","Лучшее снаряжение для вашего медотдела","Только лучшие инструменты","Натуральные химикаты!","Эта штука спасает жизни","Может сами примете?","Пинг!")
	req_access = list(ACCESS_MEDICAL)
	products = list(/obj/item/reagent_containers/syringe = 12, /obj/item/reagent_containers/food/pill/patch/styptic = 4, /obj/item/reagent_containers/food/pill/patch/silver_sulf = 4, /obj/item/reagent_containers/applicator/brute = 3, /obj/item/reagent_containers/applicator/burn = 3,
					/obj/item/reagent_containers/glass/bottle/charcoal = 4, /obj/item/reagent_containers/glass/bottle/epinephrine = 4, /obj/item/reagent_containers/glass/bottle/diphenhydramine = 4,
					/obj/item/reagent_containers/glass/bottle/salicylic = 4, /obj/item/reagent_containers/glass/bottle/potassium_iodide = 3, /obj/item/reagent_containers/glass/bottle/saline = 5,
					/obj/item/reagent_containers/glass/bottle/morphine = 4, /obj/item/reagent_containers/glass/bottle/ether = 4, /obj/item/reagent_containers/glass/bottle/atropine = 3,
					/obj/item/reagent_containers/glass/bottle/oculine = 2, /obj/item/reagent_containers/glass/bottle/toxin = 4, /obj/item/reagent_containers/syringe/antiviral = 6,
					/obj/item/reagent_containers/syringe/insulin = 6, /obj/item/reagent_containers/syringe/calomel = 10, /obj/item/reagent_containers/syringe/heparin = 4, /obj/item/reagent_containers/hypospray/autoinjector = 5, /obj/item/reagent_containers/food/pill/salbutamol = 10,
					/obj/item/reagent_containers/food/pill/mannitol = 10, /obj/item/reagent_containers/food/pill/mutadone = 5, /obj/item/stack/medical/bruise_pack/advanced = 4, /obj/item/stack/medical/ointment/advanced = 4, /obj/item/stack/medical/bruise_pack = 4,
					/obj/item/stack/medical/ointment = 4, /obj/item/stack/medical/splint = 4, /obj/item/reagent_containers/glass/beaker = 4, /obj/item/reagent_containers/dropper = 4, /obj/item/healthanalyzer = 4,
					/obj/item/healthupgrade = 4, /obj/item/reagent_containers/hypospray/safety = 2, /obj/item/sensor_device = 2, /obj/item/pinpointer/crew = 2, /obj/item/reagent_containers/iv_bag/slime = 1)
	contraband = list(/obj/item/reagent_containers/glass/bottle/sulfonal = 1, /obj/item/reagent_containers/glass/bottle/pancuronium = 1)
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/medical

/obj/machinery/vending/medical/syndicate_access
	name = "\improper SyndiMed Plus"

	icon_state = "syndi-big-med_off"
	panel_overlay = "syndi-big-med_panel"
	screen_overlay = "syndi-big-med"
	lightmask_overlay = "med_lightmask"
	broken_overlay = "med_broken"
	broken_lightmask_overlay = "med_broken_lightmask"
	deny_overlay = "syndi-big-med_deny"

	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/vending/medical/syndicate_access/beamgun
	premium = list(/obj/item/gun/medbeam = 1)

/obj/machinery/vending/plasmaresearch
	name = "\improper Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"

	icon_state = "generic_off"
	panel_overlay = "generic_panel"
	screen_overlay = "generic"
	lightmask_overlay = "generic_lightmask"
	broken_overlay = "generic_broken"
	broken_lightmask_overlay = "generic_broken_lightmask"

	products = list(/obj/item/assembly/prox_sensor = 8, /obj/item/assembly/igniter = 8, /obj/item/assembly/signaler = 8,
					/obj/item/wirecutters = 1, /obj/item/assembly/timer = 8)
	contraband = list(/obj/item/flashlight = 5, /obj/item/assembly/voice = 3, /obj/item/assembly/health = 3, /obj/item/assembly/infra = 3)


/obj/machinery/vending/wallmed
	name = "\improper NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	ads_list = list("Иди и спаси несколько жизней!","Лучшее снаряжение для вашего медотдела","Только лучшие инструменты","Натуральные химикаты!","Эта штука спасает жизни","Может сами примете?","Пинг!")

	icon_state = "wallmed_off"
	panel_overlay = "wallmed_panel"
	screen_overlay = "wallmed"
	lightmask_overlay = "wallmed_lightmask"
	broken_overlay = "wallmed_broken"
	broken_lightmask_overlay = "wallmed_broken_lightmask"
	deny_overlay = "wallmed_deny"

	density = FALSE //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(/obj/item/stack/medical/bruise_pack = 2, /obj/item/stack/medical/ointment = 2, /obj/item/reagent_containers/hypospray/autoinjector = 4, /obj/item/healthanalyzer = 1)
	contraband = list(/obj/item/reagent_containers/syringe/charcoal = 4, /obj/item/reagent_containers/syringe/antiviral = 4, /obj/item/reagent_containers/food/pill/tox = 1)
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/wallmed
	tiltable = FALSE

/obj/machinery/vending/wallmed/syndicate
	name = "\improper SyndiWallMed"
	desc = "<b>EVIL</b> wall-mounted Medical Equipment dispenser."

	icon_state = "wallmed_off"
	panel_overlay = "wallmed_panel"
	screen_overlay = "syndimed"
	lightmask_overlay = "wallmed_lightmask"
	broken_overlay = "wallmed_broken"
	broken_lightmask_overlay = "wallmed_broken_lightmask"
	deny_overlay = "syndimed_deny"

	broken_lightmask_overlay = "wallmed_broken_lightmask"
	ads_list = list("Иди и оборви несколько жизней!","Лучшее снаряжение для вашего корабля","Только лучшие инструменты","Натуральные химикаты!","Эта штука спасает жизни","Может сами примете?","Пинг!")
	req_access = list(ACCESS_SYNDICATE)
	products = list(/obj/item/stack/medical/bruise_pack = 2,/obj/item/stack/medical/ointment = 2,/obj/item/reagent_containers/hypospray/autoinjector = 4,/obj/item/healthanalyzer = 1)
	contraband = list(/obj/item/reagent_containers/syringe/charcoal = 4,/obj/item/reagent_containers/syringe/antiviral = 4,/obj/item/reagent_containers/food/pill/tox = 1)


/obj/machinery/vending/security
	name = "\improper SecTech"
	desc = "A security equipment vendor."
	ads_list = list("Круши черепа капиталистов!","Отбей несколько голов!","Не забывай, вредительство - полезно!","Твое оружие здесь.","Наручники!","Стоять, подонок!","Не бей меня, брат!","Убей их, брат.","Почему бы не съесть пончик?")

	icon_state = "sec_off"
	panel_overlay = "sec_panel"
	screen_overlay = "sec"
	lightmask_overlay = "sec_lightmask"
	broken_overlay = "sec_broken"
	broken_lightmask_overlay = "sec_broken_lightmask"
	deny_overlay = "sec_deny"

	req_access = list(ACCESS_SECURITY)
	products = list(/obj/item/restraints/handcuffs = 8,/obj/item/restraints/handcuffs/cable/zipties = 8,/obj/item/grenade/flashbang = 4,/obj/item/flash = 5,
					/obj/item/reagent_containers/food/snacks/donut = 12,/obj/item/storage/box/evidence = 6,/obj/item/flashlight/seclite = 4,/obj/item/restraints/legcuffs/bola/energy = 7,
					/obj/item/clothing/mask/muzzle/safety = 4, /obj/item/storage/box/swabs = 6, /obj/item/storage/box/fingerprints = 6, /obj/item/eftpos/sec = 4, /obj/item/storage/belt/security/webbing = 2, /obj/item/grenade/smokebomb = 8,
					)
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2,/obj/item/storage/fancy/donut_box = 2,/obj/item/hailer = 5)
	prices = list(/obj/item/storage/belt/security/webbing = 2000,/obj/item/grenade/smokebomb = 250)
	refill_canister = /obj/item/vending_refill/security

/obj/machinery/vending/security/training
	name = "\improper SecTech Training"
	desc = "A security training equipment vendor."
	ads_list = list("Соблюдай чистоту на стрельбище!","Даже я стреляю лучше тебя!","Почему так косо, бухой что ли?!","Техника безопасности нам не писана, да?","1 из 10 попаданий... А ты хорош!","Инструктор это твой папочка!","Эй, ты куда целишься?!")

	icon_state = "sectraining_off"
	panel_overlay = "sec_panel"
	screen_overlay = "sec"
	lightmask_overlay = "sec_lightmask"
	broken_overlay = "sec_broken"
	broken_lightmask_overlay = "sectraining_broken_lightmask"
	deny_overlay = "sec_deny"

	req_access = list(ACCESS_SECURITY)
	products = list(/obj/item/clothing/ears/earmuffs = 2, /obj/item/gun/energy/laser/practice = 2, /obj/item/gun/projectile/automatic/toy/pistol/enforcer = 2,
				    /obj/item/gun/projectile/shotgun/toy = 2, /obj/item/gun/projectile/automatic/toy = 2)
	contraband = list(/obj/item/toy/figure/secofficer = 1)
	refill_canister = /obj/item/vending_refill/security


/obj/machinery/vending/security/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || !powered())
		return ..()

	if(istype(I, /obj/item/security_voucher))
		add_fingerprint(user)
		var/static/list/available_kits = list(
			"Dominator Kit" = /obj/item/storage/box/dominator_kit,
			"Enforcer Kit" = /obj/item/storage/box/enforcer_kit,
		)
		var/weapon_kit = tgui_input_list(user, "Select a weaponary kit:", "Weapon kits", available_kits)
		if(!weapon_kit || !Adjacent(user) || QDELETED(I) || I.loc != user)
			return ATTACK_CHAIN_BLOCKED_ALL
		if(!user.drop_transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_BLOCKED_ALL
		qdel(I)
		sleep(0.5 SECONDS)
		playsound(loc, 'sound/machines/machine_vend.ogg', 50, TRUE)
		var/path = available_kits[weapon_kit]
		var/obj/item/box = new path(loc)
		if(Adjacent(user))
			user.put_in_hands(box, ignore_anim = FALSE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/security_voucher
	name = "security voucher"
	desc = "A token to redeem a weapon kit. Use it on a SecTech."
	icon_state = "security_voucher"
	w_class = WEIGHT_CLASS_SMALL

/obj/machinery/vending/hydronutrients
	name = "\improper NutriMax"
	desc = "A plant nutrients vendor"
	slogan_list = list("Вам не надо удобрять почву естественным путём — разве это не чудесно?","Теперь на 50% меньше вони!","Растения тоже люди!")
	ads_list = list("Мы любим растения!","Может сами примете?","Самые зелёные кнопки на свете.","Мы любим большие растения.","Мягкая почва…")

	icon_state = "nutri_off"
	panel_overlay = "nutri_panel"
	screen_overlay = "nutri"
	lightmask_overlay = "nutri_lightmask"
	broken_overlay = "nutri_broken"
	broken_lightmask_overlay = "nutri_broken_lightmask"
	deny_overlay = "nutri_deny"

	products = list(/obj/item/reagent_containers/glass/bottle/nutrient/ez = 20,/obj/item/reagent_containers/glass/bottle/nutrient/l4z = 13,/obj/item/reagent_containers/glass/bottle/nutrient/rh = 6,/obj/item/reagent_containers/spray/pestspray = 20,
					/obj/item/reagent_containers/syringe = 5,/obj/item/storage/bag/plants = 5,/obj/item/cultivator = 3,/obj/item/shovel/spade = 3,/obj/item/plant_analyzer = 4)
	contraband = list(/obj/item/reagent_containers/glass/bottle/ammonia = 10,/obj/item/reagent_containers/glass/bottle/diethylamine = 5)
	refill_canister = /obj/item/vending_refill/hydronutrients

/obj/machinery/vending/hydroseeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	slogan_list = list("THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!","Hands down the best seed selection on the station!","Also certain mushroom varieties available, more for experts! Get certified today!")
	ads_list = list("Мы любим растения!","Вырасти урожай!","Расти, малыш, расти-и-и-и!","Ды-а, сына!")

	icon_state = "seeds_off"
	panel_overlay = "seeds_panel"
	screen_overlay = "seeds"
	lightmask_overlay = "seeds_lightmask"
	broken_overlay = "seeds_broken"
	broken_lightmask_overlay = "seeds_broken_lightmask"

	products = list(/obj/item/seeds/aloe =3,
					/obj/item/seeds/ambrosia = 3,
					/obj/item/seeds/apple = 3,
					/obj/item/seeds/banana = 3,
					/obj/item/seeds/berry = 3,
					/obj/item/seeds/cabbage = 3,
					/obj/item/seeds/carrot = 3,
					/obj/item/seeds/cherry = 3,
					/obj/item/seeds/chanter = 3,
					/obj/item/seeds/chili = 3,
					/obj/item/seeds/cocoapod = 3,
					/obj/item/seeds/coffee = 3,
					/obj/item/seeds/comfrey =3,
					/obj/item/seeds/corn = 3,
					/obj/item/seeds/cotton = 3,
					/obj/item/seeds/nymph =3,
					/obj/item/seeds/eggplant = 3,
					/obj/item/seeds/garlic = 3,
					/obj/item/seeds/grape = 3,
					/obj/item/seeds/grass = 3,
					/obj/item/seeds/lemon = 3,
					/obj/item/seeds/lime = 3,
					/obj/item/seeds/onion = 3,
					/obj/item/seeds/orange = 3,
					/obj/item/seeds/peanuts = 3,
					/obj/item/seeds/peas =3,
					/obj/item/seeds/pineapple = 3,
					/obj/item/seeds/poppy = 3,
					/obj/item/seeds/geranium = 3,
					/obj/item/seeds/lily = 3,
					/obj/item/seeds/potato = 3,
					/obj/item/seeds/pumpkin = 3,
					/obj/item/seeds/replicapod = 3,
					/obj/item/seeds/wheat/rice = 3,
					/obj/item/seeds/soya = 3,
					/obj/item/seeds/sugarcane = 3,
					/obj/item/seeds/sunflower = 3,
					/obj/item/seeds/tea = 3,
					/obj/item/seeds/tobacco = 3,
					/obj/item/seeds/tomato = 3,
					/obj/item/seeds/cucumber = 3,
					/obj/item/seeds/tower = 3,
					/obj/item/seeds/watermelon = 3,
					/obj/item/seeds/wheat = 3,
					/obj/item/seeds/soya/olive = 3,
					/obj/item/seeds/whitebeet = 3,
					/obj/item/seeds/shavel = 3,
					/obj/item/seeds/redflower = 3,
					/obj/item/seeds/flowerlamp = 3,
					/obj/item/seeds/carnation = 3,
					/obj/item/seeds/tulp = 3,
					/obj/item/seeds/chamomile = 3,
					/obj/item/seeds/rose = 3
					)
	contraband = list(/obj/item/seeds/cannabis = 3,
					  /obj/item/seeds/amanita = 2,
					  /obj/item/seeds/fungus = 3,
					  /obj/item/seeds/glowshroom = 2,
					  /obj/item/seeds/liberty = 2,
					  /obj/item/seeds/nettle = 2,
					  /obj/item/seeds/plump = 2,
					  /obj/item/seeds/reishi = 2,
					  /obj/item/seeds/starthistle = 2,
					  /obj/item/seeds/random = 2,
					  /obj/item/seeds/moonlight = 2,
					  /obj/item/seeds/coca = 2)
	premium = list(/obj/item/reagent_containers/spray/waterflower = 1)
	refill_canister = /obj/item/vending_refill/hydroseeds

/obj/machinery/vending/magivend
	name = "\improper MagiVend"
	desc = "A magic vending machine."

	icon_state = "magivend_off"
	panel_overlay = "magivend_panel"
	screen_overlay = "magivend"
	lightmask_overlay = "magivend_lightmask"
	broken_overlay = "magivend_broken"
	broken_lightmask_overlay = "magivend_broken_lightmask"

	slogan_list = list("Sling spells the proper way with MagiVend!","Be your own Houdini! Use MagiVend!")
	vend_delay = 15
	vend_reply = "Have an enchanted evening!"
	ads_list = list("FJKLFJSD","AJKFLBJAKL","1234 LOONIES LOL!",">MFW","Kill them fuckers!","GET DAT FUKKEN DISK","HONK!","EI NATH","Destroy the station!","Admin conspiracies since forever!","Space-time bending hardware!")
	products = list(/obj/item/clothing/head/wizard = 5,
					/obj/item/clothing/suit/wizrobe = 5,
					/obj/item/clothing/head/wizard/red = 5,
					/obj/item/clothing/suit/wizrobe/red = 5,
					/obj/item/clothing/shoes/sandal = 5,
					/obj/item/clothing/suit/wizrobe/clown = 5,
					/obj/item/clothing/head/wizard/clown = 5,
					/obj/item/clothing/mask/gas/clownwiz = 5,
					/obj/item/clothing/shoes/clown_shoes/magical = 5,
					/obj/item/clothing/suit/wizrobe/mime = 5,
					/obj/item/clothing/head/wizard/mime = 5,
					/obj/item/clothing/mask/gas/mime/wizard = 5,
					/obj/item/clothing/head/wizard/marisa = 5,
					/obj/item/clothing/suit/wizrobe/marisa = 5,
					/obj/item/clothing/shoes/sandal/marisa = 5,
					/obj/item/twohanded/staff/broom = 5,
					/obj/item/clothing/head/wizard/black = 5,
					/obj/item/clothing/head/wizard/fluff/dreamy = 5,
					/obj/item/twohanded/staff = 10,
					/obj/item/clothing/head/helmet/space/plasmaman/wizard = 5,
					/obj/item/clothing/under/plasmaman/wizard = 5,
					/obj/item/tank/internals/plasmaman/belt/full = 5,
					/obj/item/clothing/mask/breath = 5,
					/obj/item/tank/internals/emergency_oxygen/double/vox = 5,
					/obj/item/clothing/mask/breath/vox = 5)
	contraband = list(/obj/item/reagent_containers/glass/bottle/wizarditis = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	tiltable = FALSE


/obj/machinery/vending/autodrobe
	name = "\improper AutoDrobe"
	desc = "A vending machine for costumes."

	icon_state = "theater_off"
	panel_overlay = "theater_panel"
	screen_overlay = "theater"
	lightmask_overlay = "theater_lightmask"
	broken_overlay = "theater_broken"
	broken_lightmask_overlay = "theater_broken_lightmask"
	deny_overlay = "theater_deny"

	slogan_list = list("Dress for success!","Suited and booted!","It's show time!","Why leave style up to fate? Use AutoDrobe!")
	vend_delay = 15
	vend_reply = "Thank you for using AutoDrobe!"
	products = list(/obj/item/clothing/suit/chickensuit = 1,
					/obj/item/clothing/head/chicken = 1,
					/obj/item/clothing/under/gladiator = 1,
					/obj/item/clothing/head/helmet/gladiator = 1,
					/obj/item/clothing/under/gimmick/rank/captain/suit = 1,
					/obj/item/clothing/head/flatcap = 1,
					/obj/item/clothing/suit/storage/labcoat/mad = 1,
					/obj/item/clothing/glasses/gglasses = 1,
					/obj/item/clothing/shoes/jackboots = 1,
					/obj/item/clothing/under/schoolgirl = 1,
					/obj/item/clothing/under/blackskirt = 1,
					/obj/item/clothing/neck/cloak/toggle/owlwings = 1,
					/obj/item/clothing/under/owl = 1,
					/obj/item/clothing/mask/gas/owl_mask = 1,
					/obj/item/clothing/neck/cloak/toggle/owlwings/griffinwings = 1,
					/obj/item/clothing/under/griffin = 1,
					/obj/item/clothing/shoes/griffin = 1,
					/obj/item/clothing/head/griffin = 1,
					/obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/under/suit_jacket = 1,
					/obj/item/clothing/head/that =1,
					/obj/item/clothing/under/kilt = 1,
					/obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/glasses/monocle =1,
					/obj/item/clothing/head/bowlerhat = 1,
					/obj/item/cane = 1,
					/obj/item/clothing/under/sl_suit = 1,
					/obj/item/clothing/mask/fakemoustache = 1,
					/obj/item/clothing/suit/bio_suit/plaguedoctorsuit = 1,
					/obj/item/clothing/head/plaguedoctorhat = 1,
					/obj/item/clothing/mask/gas/plaguedoctor = 1,
					/obj/item/clothing/suit/apron = 1,
					/obj/item/clothing/under/waiter = 1,
					/obj/item/clothing/suit/jacket/miljacket = 1,
					/obj/item/clothing/suit/jacket/miljacket/white = 1,
					/obj/item/clothing/suit/jacket/miljacket/desert = 1,
					/obj/item/clothing/suit/jacket/miljacket/navy = 1,
					/obj/item/clothing/under/pirate = 1,
					/obj/item/clothing/suit/pirate_brown = 1,
					/obj/item/clothing/suit/pirate_black =1,
					/obj/item/clothing/under/pirate_rags =1,
					/obj/item/clothing/head/pirate = 1,
					/obj/item/clothing/head/bandana = 1,
					/obj/item/clothing/head/bandana = 1,
					/obj/item/clothing/under/soviet = 1,
					/obj/item/clothing/head/ushanka = 1,
					/obj/item/clothing/suit/imperium_monk = 1,
					/obj/item/clothing/mask/gas/cyborg = 1,
					/obj/item/clothing/suit/holidaypriest = 1,
					/obj/item/clothing/head/wizard/marisa/fake = 1,
					/obj/item/clothing/suit/wizrobe/marisa/fake = 1,
					/obj/item/clothing/under/sundress = 1,
					/obj/item/clothing/head/witchwig = 1,
					/obj/item/twohanded/staff/broom = 1,
					/obj/item/clothing/suit/wizrobe/fake = 1,
					/obj/item/clothing/head/wizard/fake = 1,
					/obj/item/twohanded/staff = 3,
					/obj/item/clothing/mask/gas/clown_hat/sexy = 1,
					/obj/item/clothing/under/rank/clown/sexy = 1,
					/obj/item/clothing/under/rank/clown/clussy = 1,
					/obj/item/clothing/mask/gas/mime/sexy = 1,
					/obj/item/clothing/under/sexymime = 1,
					/obj/item/clothing/mask/face/bat = 1,
					/obj/item/clothing/mask/face/bee = 1,
					/obj/item/clothing/mask/face/bear = 1,
					/obj/item/clothing/mask/face/raven = 1,
					/obj/item/clothing/mask/face/jackal = 1,
					/obj/item/clothing/mask/face/fox = 1,
					/obj/item/clothing/mask/face/tribal = 1,
					/obj/item/clothing/mask/face/rat = 1,
					/obj/item/clothing/suit/apron/overalls = 1,
					/obj/item/clothing/head/rabbitears =1,
					/obj/item/clothing/head/sombrero = 1,
					/obj/item/clothing/neck/poncho = 3,
					/obj/item/clothing/accessory/blue = 1,
					/obj/item/clothing/accessory/red = 1,
					/obj/item/clothing/accessory/black = 1,
					/obj/item/clothing/accessory/horrible = 1,
					/obj/item/clothing/under/maid = 1,
					/obj/item/clothing/under/janimaid = 1,
					/obj/item/clothing/under/jester = 1,
					/obj/item/clothing/head/jester = 1,
					/obj/item/clothing/under/pennywise = 1,
					/obj/item/clothing/mask/gas/clown_hat/pennywise = 1,
					/obj/item/clothing/head/rockso = 1,
					/obj/item/clothing/mask/gas/clown_hat/rockso = 1,
					/obj/item/clothing/under/rockso = 1,
					/obj/item/clothing/under/pants/camo = 1,
					/obj/item/clothing/mask/bandana = 1,
					/obj/item/clothing/mask/bandana/black = 1,
					/obj/item/clothing/shoes/singery = 1,
					/obj/item/clothing/under/singery = 1,
					/obj/item/clothing/shoes/singerb = 1,
					/obj/item/clothing/under/singerb = 1,
					/obj/item/clothing/suit/hooded/carp_costume = 1,
					/obj/item/clothing/suit/hooded/bee_costume = 1,
					/obj/item/clothing/suit/snowman = 1,
					/obj/item/clothing/head/snowman = 1,
					/obj/item/clothing/head/cueball = 1,
					/obj/item/clothing/under/red_chaps = 1,
					/obj/item/clothing/under/white_chaps = 1,
					/obj/item/clothing/under/tan_chaps = 1,
					/obj/item/clothing/under/brown_chaps = 1,
					/obj/item/clothing/under/scratch = 1,
					/obj/item/clothing/under/victdress = 1,
					/obj/item/clothing/under/victdress/red = 1,
					/obj/item/clothing/suit/victcoat = 1,
					/obj/item/clothing/suit/victcoat/red = 1,
					/obj/item/clothing/under/victsuit = 1,
					/obj/item/clothing/under/victsuit/redblk = 1,
					/obj/item/clothing/under/victsuit/red = 1,
					/obj/item/clothing/suit/tailcoat = 1,
					/obj/item/clothing/under/tourist_suit = 1,
					/obj/item/clothing/suit/draculacoat = 1,
					/obj/item/clothing/head/zepelli = 1,
					/obj/item/clothing/under/redhawaiianshirt = 1,
					/obj/item/clothing/under/pinkhawaiianshirt = 1,
					/obj/item/clothing/under/bluehawaiianshirt = 1,
					/obj/item/clothing/under/orangehawaiianshirt = 1,
					/obj/item/clothing/under/ussptracksuit_red = 4,
					/obj/item/clothing/under/ussptracksuit_blue = 4,
					/obj/item/clothing/under/dress50s = 3)
	contraband = list(/obj/item/clothing/suit/judgerobe = 1,
					/obj/item/clothing/head/powdered_wig = 1,
					/obj/item/gun/magic/wand = 1,
					/obj/item/clothing/mask/balaclava =1,
					/obj/item/clothing/under/syndicate/blackops_civ = 1,
					/obj/item/clothing/glasses/thermal_fake = 1,
					/obj/item/clothing/mask/horsehead = 2)
	premium = list(/obj/item/clothing/suit/hgpirate = 1,
					/obj/item/clothing/head/hgpiratecap = 1,
					/obj/item/clothing/head/helmet/roman/fake = 1,
					/obj/item/clothing/head/helmet/roman/legionaire/fake = 1,
					/obj/item/clothing/under/roman = 1,
					/obj/item/clothing/shoes/roman = 1,
					/obj/item/shield/riot/roman/fake = 1,
					/obj/item/clothing/under/cuban_suit = 1,
					/obj/item/clothing/head/cuban_hat = 1,
					/obj/item/clothing/under/ussptracksuit_black = 1,
					/obj/item/clothing/under/ussptracksuit_white = 1,
					/obj/item/clothing/under/steampunkdress = 1,
					/obj/item/clothing/suit/hooded/hijab = 1)
	refill_canister = /obj/item/vending_refill/autodrobe

/obj/machinery/vending/dinnerware
	name = "\improper Plasteel Chef's Dinnerware Vendor"
	desc = "A kitchen and restaurant equipment vendor."
	ads_list = list("Mm, food stuffs!","Food and food accessories.","Get your plates!","You like forks?","I like forks.","Woo, utensils.","You don't really need these...")

	icon_state = "dinnerware_off"
	panel_overlay = "dinnerware_panel"
	screen_overlay = "dinnerware"
	lightmask_overlay = "dinnerware_lightmask"
	broken_overlay = "dinnerware_broken"
	broken_lightmask_overlay = "dinnerware_broken_lightmask"

	products = list(/obj/item/storage/bag/tray = 8,/obj/item/kitchen/utensil/fork = 6,
					/obj/item/kitchen/knife = 3,/obj/item/kitchen/rollingpin = 2,
					/obj/item/kitchen/sushimat = 3,
					/obj/item/reagent_containers/food/drinks/drinkingglass = 8, /obj/item/clothing/suit/chef/classic = 2, /obj/item/storage/belt/chef = 2,
					/obj/item/reagent_containers/food/condiment/pack/ketchup = 5,
					/obj/item/reagent_containers/food/condiment/pack/hotsauce = 5,
					/obj/item/reagent_containers/food/condiment/saltshaker =5,
					/obj/item/reagent_containers/food/condiment/peppermill =5,
					/obj/item/reagent_containers/food/condiment/herbs = 2,
					/obj/item/whetstone = 2, /obj/item/mixing_bowl = 10,
					/obj/item/kitchen/mould/bear = 1, /obj/item/kitchen/mould/worm = 1,
					/obj/item/kitchen/mould/bean = 1, /obj/item/kitchen/mould/ball = 1,
					/obj/item/kitchen/mould/cane = 1, /obj/item/kitchen/mould/cash = 1,
					/obj/item/kitchen/mould/coin = 1, /obj/item/kitchen/mould/loli = 1,
					/obj/item/kitchen/cutter = 2, /obj/item/eftpos = 4)
	contraband = list(/obj/item/kitchen/rollingpin = 2, /obj/item/kitchen/knife/butcher = 2)
	refill_canister = /obj/item/vending_refill/dinnerware

/obj/machinery/vending/dinnerware/old
	products = list(/obj/item/storage/bag/tray = 1, /obj/item/kitchen/utensil/fork = 2,
					/obj/item/kitchen/knife = 0, /obj/item/kitchen/rollingpin = 0,
					/obj/item/kitchen/sushimat = 1,
					/obj/item/reagent_containers/food/drinks/drinkingglass = 2,
					/obj/item/clothing/suit/chef/classic = 1,
					/obj/item/storage/belt/chef = 0, /obj/item/reagent_containers/food/condiment/pack/ketchup = 1,
					/obj/item/reagent_containers/food/condiment/pack/hotsauce = 0,/obj/item/reagent_containers/food/condiment/saltshaker = 1,
					/obj/item/reagent_containers/food/condiment/peppermill = 2,/obj/item/whetstone = 1,
					/obj/item/mixing_bowl = 3,/obj/item/kitchen/mould/bear = 1,
					/obj/item/kitchen/mould/worm = 0,/obj/item/kitchen/mould/bean = 0,
					/obj/item/kitchen/mould/ball = 1,/obj/item/kitchen/mould/cane = 1,
					/obj/item/kitchen/mould/cash = 0,/obj/item/kitchen/mould/coin = 0,
					/obj/item/kitchen/mould/loli = 1,/obj/item/kitchen/cutter = 0, /obj/item/eftpos = 1)

/obj/machinery/vending/sovietsoda
	name = "\improper BODA"
	desc = "Old sweet water vending machine."

	icon_state = "sovietsoda_off"
	panel_overlay = "sovietsoda_panel"
	screen_overlay = "sovietsoda"
	lightmask_overlay = "sovietsoda_lightmask"
	broken_overlay = "sovietsoda_broken"
	broken_lightmask_overlay = "sovietsoda_broken_lightmask"

	ads_list = list("For Tsar and Country.","Have you fulfilled your nutrition quota today?","Very nice!","We are simple people, for this is all we eat.","If there is a person, there is a problem. If there is no person, then there is no problem.")
	products = list(/obj/item/reagent_containers/food/drinks/drinkingglass/soda = 30)
	contraband = list(/obj/item/reagent_containers/food/drinks/drinkingglass/cola = 20)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/sovietsoda

/obj/machinery/vending/tool
	name = "\improper YouTool"
	desc = "Tools for tools."

	icon_state = "tool_off"
	panel_overlay = "tool_panel"
	screen_overlay = "tool"
	lightmask_overlay = "tool_lightmask"
	broken_overlay = "tool_broken"
	broken_lightmask_overlay = "tool_broken_lightmask"
	deny_overlay = "tool_deny"

	products = list(/obj/item/stack/cable_coil/random = 10,
					/obj/item/crowbar = 5,
					/obj/item/weldingtool = 3,
					/obj/item/wirecutters = 5,
					/obj/item/wrench = 5,
					/obj/item/analyzer = 5,
					/obj/item/t_scanner = 5,
					/obj/item/screwdriver = 5,
					/obj/item/clothing/gloves/color/fyellow = 2
					)
	contraband = list(/obj/item/weldingtool/hugetank = 2,
					/obj/item/clothing/gloves/color/yellow = 1
					)
	prices = list(/obj/item/stack/cable_coil/random = 30,
					/obj/item/crowbar = 50,/obj/item/weldingtool = 50,
					/obj/item/wirecutters = 50,
					/obj/item/wrench = 50,
					/obj/item/analyzer = 30,
					/obj/item/t_scanner = 30,
					/obj/item/screwdriver = 50,
					/obj/item/clothing/gloves/color/fyellow = 250,
					/obj/item/weldingtool/hugetank = 200,
					/obj/item/clothing/gloves/color/yellow = 500
	)
	refill_canister = /obj/item/vending_refill/youtool
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF


/obj/machinery/vending/engivend
	name = "\improper Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"

	icon_state = "engivend_off"
	panel_overlay = "engivend_panel"
	screen_overlay = "engivend"
	lightmask_overlay = "engivend_lightmask"
	broken_overlay = "engivend_broken"
	broken_lightmask_overlay = "engivend_broken_lightmask"
	deny_overlay = "engivend_deny"

	req_access = list(11,24) // Engineers and atmos techs can use this
	products = list(/obj/item/clothing/glasses/meson = 2,/obj/item/multitool = 4,/obj/item/airlock_electronics = 10,/obj/item/firelock_electronics = 10,/obj/item/firealarm_electronics = 10,/obj/item/apc_electronics = 10,/obj/item/airalarm_electronics = 10,/obj/item/access_control = 10,/obj/item/assembly/control/airlock = 10,/obj/item/stock_parts/cell/high = 10,/obj/item/camera_assembly = 10)
	contraband = list(/obj/item/stock_parts/cell/potato = 3)
	premium = list(/obj/item/storage/belt/utility = 3)
	refill_canister = /obj/item/vending_refill/engivend

/obj/machinery/vending/engineering
	name = "\improper Robco Tool Maker"
	desc = "Everything you need for do-it-yourself station repair."

	icon_state = "engi_off"
	panel_overlay = "engi_panel"
	screen_overlay = "engi"
	lightmask_overlay = "engi_lightmask"
	broken_overlay = "engi_broken"
	broken_lightmask_overlay = "engi_broken_lightmask"
	deny_overlay = "engi_deny"
	deny_lightmask = "engi_deny_lightmask"

	req_access = list(ACCESS_ENGINE_EQUIP)
	products = list(/obj/item/clothing/under/rank/chief_engineer = 4,/obj/item/clothing/under/rank/engineer = 4,/obj/item/clothing/shoes/workboots = 4,/obj/item/clothing/head/hardhat = 4,
					/obj/item/storage/belt/utility = 4,/obj/item/clothing/glasses/meson = 4,/obj/item/clothing/gloves/color/yellow = 4, /obj/item/screwdriver = 12,
					/obj/item/crowbar = 12,/obj/item/wirecutters = 12,/obj/item/multitool = 12,/obj/item/wrench = 12,/obj/item/t_scanner = 12,
					/obj/item/stack/cable_coil = 8, /obj/item/stock_parts/cell = 8, /obj/item/weldingtool = 8,/obj/item/clothing/head/welding = 8,
					/obj/item/light/tube = 10,/obj/item/clothing/suit/fire = 4, /obj/item/stock_parts/scanning_module = 5,/obj/item/stock_parts/micro_laser = 5,
					/obj/item/stock_parts/matter_bin = 5,/obj/item/stock_parts/manipulator = 5)
	refill_canister = /obj/item/vending_refill/engineering

/obj/machinery/vending/robotics
	name = "\improper Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."

	icon_state = "robotics_off"
	panel_overlay = "robotics_panel"
	screen_overlay = "robotics"
	lightmask_overlay = "robotics_lightmask"
	broken_overlay = "robotics_broken"
	broken_lightmask_overlay = "robotics_broken_lightmask"
	deny_overlay = "robotics_deny"
	deny_lightmask = "robotics_deny_lightmask"

	req_access = list(ACCESS_ROBOTICS)
	products = list(/obj/item/clothing/suit/storage/labcoat = 4,/obj/item/clothing/under/rank/roboticist = 4,/obj/item/stack/cable_coil = 4,/obj/item/flash = 4,
					/obj/item/stock_parts/cell/high = 12, /obj/item/assembly/prox_sensor = 3,/obj/item/assembly/signaler = 3,/obj/item/healthanalyzer = 3,
					/obj/item/scalpel = 2,/obj/item/circular_saw = 2,/obj/item/tank/internals/anesthetic = 2,/obj/item/clothing/mask/breath/medical = 5,
					/obj/item/screwdriver = 5,/obj/item/crowbar = 5)
	refill_canister = /obj/item/vending_refill/robotics

/obj/machinery/vending/robotics/nt
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/robotics/nt/durand
	products = list(/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay = 3,
		/obj/item/mecha_parts/mecha_equipment/repair_droid = 3,
		/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster = 3,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot = 3,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg = 3)

/obj/machinery/vending/robotics/nt/gygax
	products = list(/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay = 3,
	/obj/item/mecha_parts/mecha_equipment/repair_droid = 3,
	/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster = 3,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion = 3,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy = 3)

/obj/machinery/vending/sustenance
	name = "\improper Sustenance Vendor"
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement."
	slogan_list = list("Enjoy your meal.","Enough calories to support strenuous labor.")
	ads_list = list("The healthiest!","Award-winning chocolate bars!","Mmm! So good!","Oh my god it's so juicy!","Have a snack.","Snacks are good for you!","Have some more Getmore!","Best quality snacks straight from mars.","We love chocolate!","Try our new jerky!")

	icon_state = "sustenance_off"
	panel_overlay = "snack_panel"
	screen_overlay = "snack"
	lightmask_overlay = "snack_lightmask"
	broken_overlay = "snack_broken"
	broken_lightmask_overlay = "snack_broken_lightmask"

	broken_lightmask_overlay = "snack_broken_lightmask"
	products = list(/obj/item/reagent_containers/food/snacks/tofu = 24,
					/obj/item/reagent_containers/food/drinks/ice = 12,
					/obj/item/reagent_containers/food/snacks/candy/candy_corn = 6)
	contraband = list(/obj/item/kitchen/knife = 6,
					  /obj/item/reagent_containers/food/drinks/coffee = 12,
					  /obj/item/tank/internals/emergency_oxygen = 6,
					  /obj/item/clothing/mask/breath = 6)
	refill_canister = /obj/item/vending_refill/sustenance

/obj/machinery/vending/sustenance/additional
	desc = "Какого этот автомат тут оказался?!"
	products = list(/obj/item/reagent_containers/food/snacks/tofu = 12,
					/obj/item/reagent_containers/food/drinks/ice = 6,
					/obj/item/reagent_containers/food/snacks/candy/candy_corn = 6)
	contraband = list(/obj/item/kitchen/knife=2)

/obj/machinery/vending/hatdispenser
	name = "\improper Hatlord 9000"
	desc = "It doesn't seem the slightest bit unusual. This frustrates you immensely."

	icon_state = "hats_off"
	panel_overlay = "hats_panel"
	screen_overlay = "hats"
	lightmask_overlay = "hats_lightmask"
	broken_overlay = "hats_broken"
	broken_lightmask_overlay = "hats_broken_lightmask"

	ads_list = list("Warning, not all hats are dog/monkey compatible. Apply forcefully with care.","Apply directly to the forehead.","Who doesn't love spending cash on hats?!","From the people that brought you collectable hat crates, Hatlord!")
	products = list(/obj/item/clothing/head/bowlerhat = 10,
					/obj/item/clothing/head/beaverhat = 10,
					/obj/item/clothing/head/boaterhat = 10,
					/obj/item/clothing/head/fedora = 10,
					/obj/item/clothing/head/fez = 10,
					/obj/item/clothing/head/beret = 10)
	contraband = list(/obj/item/clothing/head/bearpelt = 5)
	premium = list(/obj/item/clothing/head/soft/rainbow = 1)
	refill_canister = /obj/item/vending_refill/hatdispenser

/obj/machinery/vending/suitdispenser
	name = "\improper Suitlord 9000"
	desc = "You wonder for a moment why all of your shirts and pants come conjoined. This hurts your head and you stop thinking about it."

	icon_state = "suits_off"
	panel_overlay = "suits_panel"
	screen_overlay = "suits"
	lightmask_overlay = "suits_lightmask"
	broken_overlay = "suits_broken"
	broken_lightmask_overlay = "suits_broken_lightmask"

	ads_list = list("Pre-Ironed, Pre-Washed, Pre-Wor-*BZZT*","Blood of your enemies washes right out!","Who are YOU wearing?","Look dapper! Look like an idiot!","Dont carry your size? How about you shave off some pounds you fat lazy- *BZZT*")
	products = list(
		/obj/item/clothing/under/color/black = 10,
		/obj/item/clothing/under/color/blue = 10,
		/obj/item/clothing/under/color/green = 10,
		/obj/item/clothing/under/color/grey = 10,
		/obj/item/clothing/under/color/pink = 10,
		/obj/item/clothing/under/color/red = 10,
		/obj/item/clothing/under/color/white = 10,
		/obj/item/clothing/under/color/yellow = 10,
		/obj/item/clothing/under/color/lightblue = 10,
		/obj/item/clothing/under/color/aqua = 10,
		/obj/item/clothing/under/color/purple = 10,
		/obj/item/clothing/under/color/lightgreen = 10,
		/obj/item/clothing/under/color/lightblue = 10,
		/obj/item/clothing/under/color/lightbrown = 10,
		/obj/item/clothing/under/color/brown = 10,
		/obj/item/clothing/under/color/yellowgreen = 10,
		/obj/item/clothing/under/color/darkblue = 10,
		/obj/item/clothing/under/color/lightred = 10,
		/obj/item/clothing/under/color/darkred = 10,
		/obj/item/clothing/under/colour/skirt = 10
		)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 5,/obj/item/clothing/under/color/orange = 5, /obj/item/clothing/under/syndicate/tacticool/skirt = 5)
	premium = list(/obj/item/clothing/under/rainbow = 1)
	refill_canister = /obj/item/vending_refill/suitdispenser

/obj/machinery/vending/shoedispenser
	name = "\improper Shoelord 9000"
	desc = "Wow, hatlord looked fancy, suitlord looked streamlined, and this is just normal. The guy who designed these must be an idiot."

	icon_state = "shoes_off"
	icon_state = "shoes_off"
	panel_overlay = "shoes_panel"
	screen_overlay = "shoes"
	lightmask_overlay = "shoes_lightmask"
	broken_overlay = "shoes_broken"
	broken_lightmask_overlay = "shoes_broken_lightmask"

	ads_list = list("Put your foot down!","One size fits all!","IM WALKING ON SUNSHINE!","No hobbits allowed.","NO PLEASE WILLY, DONT HURT ME- *BZZT*")
	products = list(/obj/item/clothing/shoes/black = 10,/obj/item/clothing/shoes/brown = 10,/obj/item/clothing/shoes/blue = 10,/obj/item/clothing/shoes/green = 10,/obj/item/clothing/shoes/yellow = 10,/obj/item/clothing/shoes/purple = 10,/obj/item/clothing/shoes/red = 10,/obj/item/clothing/shoes/white = 10,/obj/item/clothing/shoes/sandal=10)
	contraband = list(/obj/item/clothing/shoes/orange = 5)
	premium = list(/obj/item/clothing/shoes/rainbow = 1)
	refill_canister = /obj/item/vending_refill/shoedispenser

/obj/machinery/vending/syndicigs
	name = "\improper Suspicious Cigarette Machine"
	desc = "Smoke 'em if you've got 'em."
	slogan_list = list("Космосигареты на вкус хороши, какими они и должны быть.","I'd rather toolbox than switch.","Затянитесь!","Не верьте исследованиям — курите сегодня!")
	ads_list = list("Наверняка не очень-то и вредно для Вас!","Не верьте учёным!","На здоровье!","Не бросайте курить, купите ещё!","Затянитесь!","Никотиновый рай.","Лучшие сигареты с 2150 года.","Сигареты с множеством наград.")
	vend_delay = 34

	icon_state = "cigs_off"
	panel_overlay = "cigs_panel"
	screen_overlay = "cigs"
	lightmask_overlay = "cigs_lightmask"
	broken_overlay = "cigs_broken"
	broken_lightmask_overlay = "cigs_broken_lightmask"

	products = list(/obj/item/storage/fancy/cigarettes/syndicate = 10,/obj/item/lighter/random = 5)


/obj/machinery/vending/syndisnack
	name = "\improper Getmore Chocolate Corp"
	desc = "A modified snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars"
	slogan_list = list("Try our new nougat bar!","Twice the calories for half the price!")
	ads_list = list("The healthiest!","Award-winning chocolate bars!","Mmm! So good!","Oh my god it's so juicy!","Have a snack.","Snacks are good for you!","Have some more Getmore!","Best quality snacks straight from mars.","We love chocolate!","Try our new jerky!")

	icon_state = "snack_off"
	panel_overlay = "snack_panel"
	screen_overlay = "snack"
	lightmask_overlay = "snack_lightmask"
	broken_overlay = "snack_broken"
	broken_lightmask_overlay = "snack_broken_lightmask"

	products = list(/obj/item/reagent_containers/food/snacks/chips =6,/obj/item/reagent_containers/food/snacks/sosjerky = 6,
					/obj/item/reagent_containers/food/snacks/syndicake = 6, /obj/item/reagent_containers/food/snacks/cheesiehonkers = 6)

/obj/machinery/vending/syndierobotics
	name = "Синди Робо-ДеЛюкс!"
	desc = "Всё что нужно, чтобы сделать личного железного друга из ваших врагов!"
	ads_list = list("Make them beep-boop like a robot should!","Robotisation is NOT a crime!","Nyoom!")

	icon_state = "robotics_off"
	panel_overlay = "robotics_panel"
	screen_overlay = "robotics"
	lightmask_overlay = "robotics_lightmask"
	broken_overlay = "robotics_broken"
	broken_lightmask_overlay = "robotics_broken_lightmask"
	deny_overlay = "robotics_deny"
	deny_lightmask = "robotics_deny_lightmask"

	req_access = list(ACCESS_SYNDICATE)
	products = list(/obj/item/robot_parts/robot_suit = 2,
					/obj/item/robot_parts/chest = 2,
					/obj/item/robot_parts/head = 2,
					/obj/item/robot_parts/l_arm = 2,
					/obj/item/robot_parts/r_arm = 2,
					/obj/item/robot_parts/l_leg = 2,
					/obj/item/robot_parts/r_leg = 2,
					/obj/item/stock_parts/cell/high = 6,
					/obj/item/crowbar = 2,
					/obj/item/flash = 4,
					/obj/item/stack/cable_coil = 4,
					/obj/item/mmi/syndie = 2,
					/obj/item/robotanalyzer = 2)

//don't forget to change the refill size if you change the machine's contents!
/obj/machinery/vending/clothing
	name = "\improper ClothesMate" //renamed to make the slogan rhyme
	desc = "A vending machine for clothing."

	icon_state = "clothes_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	slogan_list = list("Dress for success!","Prepare to look swagalicious!","Look at all this free swag!","Why leave style up to fate? Use the ClothesMate!")
	vend_delay = 15
	vend_reply = "Thank you for using the ClothesMate!"
	products = list(/obj/item/clothing/head/that = 2,
					/obj/item/clothing/head/fedora = 1,
					/obj/item/clothing/glasses/monocle = 1,
					/obj/item/clothing/under/suit_jacket/navy = 2,
					/obj/item/clothing/under/kilt = 1,
					/obj/item/clothing/under/overalls = 1,
					/obj/item/clothing/under/suit_jacket/really_black = 2,
					/obj/item/clothing/suit/storage/lawyer/blackjacket = 2,
					/obj/item/clothing/under/pants/galifepants = 3,
					/obj/item/clothing/under/pants/sandpants = 3,
					/obj/item/clothing/under/pants/jeans = 3,
					/obj/item/clothing/under/pants/classicjeans = 2,
					/obj/item/clothing/under/pants/camo = 1,
					/obj/item/clothing/under/pants/blackjeans = 2,
					/obj/item/clothing/under/pants/khaki = 2,
					/obj/item/clothing/under/pants/white = 2,
					/obj/item/clothing/under/pants/red = 1,
					/obj/item/clothing/under/pants/black = 2,
					/obj/item/clothing/under/pants/tan = 2,
					/obj/item/clothing/under/pants/blue = 1,
					/obj/item/clothing/under/pants/track = 1,
					/obj/item/clothing/suit/jacket/miljacket = 1,
					/obj/item/clothing/head/beanie = 3,
					/obj/item/clothing/head/beanie/black = 3,
					/obj/item/clothing/head/beanie/red = 3,
					/obj/item/clothing/head/beanie/green = 3,
					/obj/item/clothing/head/beanie/darkblue = 3,
					/obj/item/clothing/head/beanie/purple = 3,
					/obj/item/clothing/head/beanie/yellow = 3,
					/obj/item/clothing/head/beanie/orange = 3,
					/obj/item/clothing/head/beanie/cyan = 3,
					/obj/item/clothing/head/beanie/christmas = 3,
					/obj/item/clothing/head/beanie/striped = 3,
					/obj/item/clothing/head/beanie/stripedred = 3,
					/obj/item/clothing/head/beanie/stripedblue = 3,
					/obj/item/clothing/head/beanie/stripedgreen = 3,
					/obj/item/clothing/head/beanie/rasta = 3,
					/obj/item/clothing/accessory/scarf/red = 1,
					/obj/item/clothing/accessory/scarf/green = 1,
					/obj/item/clothing/accessory/scarf/darkblue = 1,
					/obj/item/clothing/accessory/scarf/purple = 1,
					/obj/item/clothing/accessory/scarf/yellow = 1,
					/obj/item/clothing/accessory/scarf/orange = 1,
					/obj/item/clothing/accessory/scarf/lightblue = 1,
					/obj/item/clothing/accessory/scarf/white = 1,
					/obj/item/clothing/accessory/scarf/black = 1,
					/obj/item/clothing/accessory/scarf/zebra = 1,
					/obj/item/clothing/accessory/scarf/christmas = 1,
					/obj/item/clothing/accessory/stripedredscarf = 1,
					/obj/item/clothing/accessory/stripedbluescarf = 1,
					/obj/item/clothing/accessory/stripedgreenscarf = 1,
					/obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/under/sundress = 2,
					/obj/item/clothing/under/stripeddress = 1,
					/obj/item/clothing/under/sailordress = 1,
					/obj/item/clothing/under/redeveninggown = 1,
					/obj/item/clothing/under/blacktango = 1,
					/obj/item/clothing/suit/jacket = 3,
					/obj/item/clothing/suit/jacket/motojacket = 3,
					/obj/item/clothing/glasses/regular = 2,
					/obj/item/clothing/glasses/sunglasses_fake = 2,
					/obj/item/clothing/head/sombrero = 1,
					/obj/item/clothing/neck/poncho = 1,
					/obj/item/clothing/suit/ianshirt = 1,
					/obj/item/clothing/shoes/laceup = 2,
					/obj/item/clothing/shoes/black = 4,
					/obj/item/clothing/shoes/sandal = 1,
					/obj/item/clothing/shoes/leather_boots = 3,
					/obj/item/clothing/gloves/brown_short_gloves = 3,
					/obj/item/clothing/gloves/fingerless = 2,
					/obj/item/storage/belt/fannypack = 1,
					/obj/item/storage/belt/fannypack/blue = 1,
					/obj/item/storage/belt/fannypack/red = 1,
					/obj/item/clothing/neck/mantle = 2,
					/obj/item/clothing/neck/mantle/old = 1,
					/obj/item/clothing/neck/mantle/regal = 2,
					/obj/item/clothing/neck/cloak/grey = 1)

	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 1,
					/obj/item/clothing/under/syndicate/tacticool/skirt = 1,
					/obj/item/clothing/mask/balaclava = 1,
					/obj/item/clothing/under/syndicate/blackops_civ = 1,
					/obj/item/clothing/head/ushanka = 1,
					/obj/item/clothing/under/soviet = 1,
					/obj/item/storage/belt/fannypack/black = 1)

	premium = list(/obj/item/clothing/under/suit_jacket/checkered = 1,
				   /obj/item/clothing/head/mailman = 1,
				   /obj/item/clothing/under/rank/mailman = 1,
				   /obj/item/clothing/suit/jacket/leather = 1,
				   /obj/item/clothing/under/pants/mustangjeans = 1)

	refill_canister = /obj/item/vending_refill/clothing

/obj/machinery/vending/artvend
	name = "\improper ArtVend"
	desc = "A vending machine for art supplies."
	slogan_list = list("Stop by for all your artistic needs!","Color the floors with crayons, not blood!","Don't be a starving artist, use ArtVend. ","Don't fart, do art!")
	ads_list = list("Just like Kindergarten!","Now with 1000% more vibrant colors!","Screwing with the janitor was never so easy!","Creativity is at the heart of every spessman.")
	vend_delay = 15

	icon_state = "artvend_off"
	panel_overlay = "artvend_panel"
	screen_overlay = "artvend"
	lightmask_overlay = "artvend_lightmask"
	broken_overlay = "artvend_broken"
	broken_lightmask_overlay = "artvend_broken_lightmask"

	products = list(
		/obj/item/toy/crayon/spraycan = 2,
		/obj/item/stack/cable_coil/random = 10,
		/obj/item/camera = 4,
		/obj/item/camera_film = 6,
		/obj/item/storage/photo_album = 2,
		/obj/item/stack/wrapping_paper = 4,
		/obj/item/stack/tape_roll = 5,
		/obj/item/stack/packageWrap = 4,
		/obj/item/storage/fancy/crayons = 4,
		/obj/item/storage/fancy/glowsticks_box = 3,
		/obj/item/hand_labeler = 4,
		/obj/item/paper = 10,
		/obj/item/c_tube = 10,
		/obj/item/pen = 5,
		/obj/item/pen/blue = 5,
		/obj/item/pen/red = 5)
	contraband = list(
		/obj/item/toy/crayon/mime = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/weaponcrafting/receiver = 1
)
	premium = list(/obj/item/poster/random_contraband = 5
	)
	prices = list(
		/obj/item/toy/crayon/spraycan = 50,
		/obj/item/stack/cable_coil/random = 30,
		/obj/item/camera = 20,
		/obj/item/camera_film = 10,
		/obj/item/storage/photo_album = 10,
		/obj/item/stack/wrapping_paper = 20,
		/obj/item/stack/tape_roll = 20,
		/obj/item/stack/packageWrap = 10,
		/obj/item/storage/fancy/crayons = 35,
		/obj/item/storage/fancy/glowsticks_box = 100,
		/obj/item/hand_labeler = 30,
		/obj/item/paper = 5,
		/obj/item/c_tube = 10,
		/obj/item/pen = 5,
		/obj/item/pen/blue = 10,
		/obj/item/pen/red = 10,
		/obj/item/toy/crayon/mime = 50,
		/obj/item/toy/crayon/rainbow = 50,
		/obj/item/weaponcrafting/receiver = 250
	)

/obj/machinery/vending/crittercare
	name = "\improper CritterCare"
	desc = "A vending machine for pet supplies."
	slogan_list = list("Stop by for all your animal's needs!","Cuddly pets deserve a stylish collar!","Pets in space, what could be more adorable?","Freshest fish eggs in the system!","Rocks are the perfect pet, buy one today!")
	ads_list = list("House-training costs extra!","Now with 1000% more cat hair!","Allergies are a sign of weakness!","Dogs are man's best friend. Remember that Vulpkanin!"," Heat lamps for Unathi!"," Vox-y want a cracker?")
	vend_delay = 15

	icon_state = "crittercare_off"
	panel_overlay = "crittercare_panel"
	screen_overlay = "crittercare"
	lightmask_overlay = "crittercare_lightmask"
	broken_overlay = "crittercare_broken"
	broken_lightmask_overlay = "crittercare_broken_lightmask"

	products = list(
		/obj/item/clothing/accessory/petcollar = 5,
		/obj/item/storage/firstaid/aquatic_kit/full = 5,
		/obj/item/fish_eggs/goldfish = 5,
		/obj/item/fish_eggs/clownfish = 5,
		/obj/item/fish_eggs/shark = 5,
		/obj/item/fish_eggs/feederfish = 10,
		/obj/item/fish_eggs/salmon = 5,
		/obj/item/fish_eggs/catfish = 5,
		/obj/item/fish_eggs/glofish = 5,
		/obj/item/fish_eggs/electric_eel = 5,
		/obj/item/fish_eggs/crayfish = 5,
		/obj/item/fish_eggs/shrimp = 10,
		/obj/item/toy/pet_rock = 5,
		/obj/item/pet_carrier/normal = 3,
		/obj/item/pet_carrier = 5,
		/obj/item/reagent_containers/food/condiment/animalfeed = 5,
		/obj/item/reagent_containers/glass/pet_bowl = 3,
	)

	prices = list(
		/obj/item/clothing/accessory/petcollar = 50,
		/obj/item/storage/firstaid/aquatic_kit/full = 60,
		/obj/item/fish_eggs/goldfish = 10,
		/obj/item/fish_eggs/clownfish = 10,
		/obj/item/fish_eggs/shark = 10,
		/obj/item/fish_eggs/feederfish = 5,
		/obj/item/fish_eggs/salmon = 10,
		/obj/item/fish_eggs/catfish = 10,
		/obj/item/fish_eggs/glofish = 10,
		/obj/item/fish_eggs/electric_eel = 10,
		/obj/item/fish_eggs/crayfish = 50,
		/obj/item/fish_eggs/shrimp = 5,
		/obj/item/toy/pet_rock = 100,
		/obj/item/pet_carrier/normal = 250,
		/obj/item/pet_carrier = 100,
		/obj/item/reagent_containers/food/condiment/animalfeed = 100,
		/obj/item/reagent_containers/glass/pet_bowl = 50,
	)

	contraband = list(/obj/item/fish_eggs/babycarp = 5)
	premium = list(/obj/item/toy/pet_rock/fred = 1, /obj/item/toy/pet_rock/roxie = 1)
	refill_canister = /obj/item/vending_refill/crittercare

/obj/machinery/vending/crittercare/free
	prices = list()

/obj/machinery/vending/clothing/departament
	name = "\improper Broken Departament ClothesMate"
	desc = "Автомат-помощник по выдаче одежды отдела."
	slogan_list = list(
		"Одежда успешного работника!", "Похвала на глаза!", "Ну наконец-то нормально оделся!",
		"Одевай одежду, надевай еще и шляпку!", "Вот это гордость такое надевать!", "Выглядишь отпадно!",
		"Я бы и сам такое носил!", "А я думал, куда она подевалась...", "О, это была моя любимая!",
		"Производитель рекомендует этот фасон", "Ваша талия идеально сочетается с ней!",
		"Ваши глаза так и блистают с ней!", "Как же ты здорово выглядишь!", "И не скажешь что тебе не идёт!",
		"Ну жених!", "Постой на картонке, возможно найдем что поинтереснее!", "Бери-бери, не глазей!",
		"Возвраты не берем!", "Ну как на тебя шили!", "Только не стирайте в машинке.", "У нас лучшая одежда! То что вы взяли было не самым лучшим",
		"Не переживайте! Если моль её поела, значит она качественная!", "Вам идеально подошла бы другая одежда, но и эта подойдет!",
		"Выглядите стильно. По депортаменски!", "Вы теперь выглядите отделанным! Ну одежда отдела у вас!",
		"Отдел будет вам доволен, если вы нарядитесь в это!", "Ну красавец!"
		)
	vend_delay = 15
	vend_reply = "Спасибо за использование автомата-помощника в выборе одежды отдела!"
	products = list()
	contraband = list()
	premium = list()
	refill_canister = null

/obj/machinery/vending/clothing/departament/security
	name = "\improper Departament Security ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Отдела Службы Безопасности."

	icon_state = "clothes-dep-sec_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-sec"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-sec_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_SEC_DOORS)
	products = list(
		/obj/item/clothing/head/soft/sec		= 10,
		/obj/item/clothing/head/soft/sec/corp	= 10,
		/obj/item/clothing/head/beret/sec		= 10,
		/obj/item/clothing/head/beret/sec/black	= 10,
		/obj/item/clothing/head/officer		 	= 10,
		/obj/item/clothing/head/beret/brigphys  = 5,
		/obj/item/clothing/head/soft/brigphys   = 5,
		/obj/item/clothing/head/helmet/lightweighthelmet = 10,

		/obj/item/clothing/under/rank/security			= 10,
		/obj/item/clothing/under/rank/security/skirt 	= 10,
		/obj/item/clothing/under/rank/security/formal 	= 5,
		/obj/item/clothing/under/rank/security/corp 	= 5,
		/obj/item/clothing/under/rank/security2 		= 5,
		/obj/item/clothing/under/rank/dispatch 			= 5,

		/obj/item/clothing/suit/tracksuit/red				= 5,
		/obj/item/clothing/suit/hooded/wintercoat/security	= 5,
		/obj/item/clothing/suit/jacket/pilot	= 5,
		/obj/item/clothing/suit/armor/vest/sec_rps	= 5,
		/obj/item/clothing/suit/armor/secjacket = 5,

		/obj/item/clothing/mask/balaclava 		= 10,
		/obj/item/clothing/mask/bandana/red 	= 10,
		/obj/item/clothing/mask/bandana/black 	= 10,
		/obj/item/clothing/mask/secscarf 		= 10,

		/obj/item/clothing/gloves/color/black	= 10,
		/obj/item/clothing/gloves/color/red	= 10,

		/obj/item/clothing/shoes/jackboots 				= 10,
		/obj/item/clothing/shoes/jackboots/jacksandals 	= 10,
		/obj/item/clothing/shoes/jackboots/cross 		= 10,

		/obj/item/radio/headset/headset_sec		= 10, //No EARBANGPROTECT. Hehe...

		/obj/item/clothing/glasses/hud/security/sunglasses/tacticool = 5,

		/obj/item/clothing/accessory/scarf/black 	= 10,
		/obj/item/clothing/accessory/scarf/red 		= 10,
		/obj/item/clothing/neck/poncho/security     = 10,
		/obj/item/clothing/neck/cloak/security      = 10,
		/obj/item/clothing/accessory/armband/sec 	= 10,

		/obj/item/storage/backpack/security 		= 5,
		/obj/item/storage/backpack/satchel_sec 		= 5,
		/obj/item/storage/backpack/duffel/security 	= 5,

		//For trainings
		/obj/item/clothing/under/shorts/red			= 10,
		/obj/item/clothing/under/shorts/black		= 5,
		/obj/item/clothing/under/pants/red 			= 10,
		/obj/item/clothing/under/pants/track 		= 5,

		//For brig physician
		/obj/item/clothing/under/rank/security/brigphys = 3,
		/obj/item/clothing/under/rank/security/brigphys/skirt 	= 3,
		/obj/item/clothing/suit/storage/suragi_jacket/medsec = 3,
		/obj/item/clothing/suit/storage/brigdoc = 3,
		/obj/item/clothing/under/rank/security/brigmedical = 3,
		/obj/item/clothing/under/rank/security/brigmedical/skirt = 3
		)


	refill_canister = /obj/item/vending_refill/clothing/security

/obj/machinery/vending/clothing/departament/medical
	name = "\improper Departament Medical ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Медицинского Отдела."

	icon_state = "clothes-dep-med_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-med"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-med_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_MEDICAL)
	products = list(
		/obj/item/clothing/head/beret/med  			= 10,
		/obj/item/clothing/head/soft/paramedic		= 5,
		/obj/item/clothing/head/surgery/purple 		= 10,
		/obj/item/clothing/head/surgery/blue 		= 10,
		/obj/item/clothing/head/surgery/green 		= 10,
		/obj/item/clothing/head/surgery/lightgreen 	= 10,
		/obj/item/clothing/head/surgery/black 		= 10,
		/obj/item/clothing/head/headmirror 			= 10,

		/obj/item/clothing/under/rank/medical 				= 10,
		/obj/item/clothing/under/rank/medical/skirt 		= 10,
		/obj/item/clothing/under/rank/medical/intern 		= 10,
		/obj/item/clothing/under/rank/medical/intern/skirt 	= 10,
		/obj/item/clothing/under/rank/medical/intern/assistant 			= 10,
		/obj/item/clothing/under/rank/medical/intern/assistant/skirt 	= 10,
		/obj/item/clothing/under/rank/medical/blue 			= 10,
		/obj/item/clothing/under/rank/medical/green 		= 10,
		/obj/item/clothing/under/rank/medical/purple 		= 10,
		/obj/item/clothing/under/rank/medical/lightgreen 	= 10,
		/obj/item/clothing/under/medigown 					= 10,
		/obj/item/clothing/under/rank/nursesuit				= 10,
		/obj/item/clothing/under/rank/nurse					= 10,
		/obj/item/clothing/under/rank/orderly				= 10,
		/obj/item/clothing/under/rank/medical/paramedic		= 5,
		/obj/item/clothing/under/rank/medical/paramedic/skirt			= 5,

		/obj/item/clothing/suit/storage/labcoat 	= 10,
		/obj/item/clothing/suit/storage/suragi_jacket/medic = 10,
		/obj/item/clothing/suit/apron/surgical 		= 10,
		/obj/item/clothing/suit/storage/fr_jacket 	= 5,
		/obj/item/clothing/suit/hooded/wintercoat/medical	= 5,

		/obj/item/clothing/mask/surgical 		= 10,

		/obj/item/clothing/gloves/color/latex 	= 10,
		/obj/item/clothing/gloves/color/latex/nitrile	= 10,

		/obj/item/clothing/shoes/white 			= 10,
		/obj/item/clothing/shoes/sandal/white 	= 10,

		/obj/item/radio/headset/headset_med 	= 10,

		/obj/item/clothing/accessory/scarf/white 		= 10,
		/obj/item/clothing/accessory/scarf/lightblue 	= 10,
		/obj/item/clothing/accessory/stethoscope		= 10,
		/obj/item/clothing/accessory/armband/med 		= 10,
		/obj/item/clothing/accessory/armband/medgreen 	= 10,

		/obj/item/storage/backpack/satchel_med 		= 5,
		/obj/item/storage/backpack/medic 			= 5,
		/obj/item/storage/backpack/duffel/medical 	= 5,

		/obj/item/clothing/under/rank/virologist	= 2,
		/obj/item/clothing/under/rank/virologist/skirt = 2,
		/obj/item/clothing/suit/storage/labcoat/virologist = 2,
		/obj/item/clothing/suit/storage/suragi_jacket/virus = 2,
		/obj/item/storage/backpack/satchel_vir		= 2,
		/obj/item/storage/backpack/virology			= 2,
		/obj/item/storage/backpack/duffel/virology	= 2,

		/obj/item/clothing/under/rank/chemist		= 2,
		/obj/item/clothing/under/rank/chemist/skirt	= 2,
		/obj/item/clothing/suit/storage/labcoat/chemist = 2,
		/obj/item/clothing/suit/storage/suragi_jacket/chem 	= 2,
		/obj/item/storage/backpack/satchel_chem 	= 2,
		/obj/item/storage/backpack/chemistry		= 2,
		/obj/item/storage/backpack/duffel/chemistry	= 2,

		/obj/item/clothing/under/rank/geneticist	= 2,
		/obj/item/clothing/under/rank/geneticist/skirt = 2,
		/obj/item/clothing/suit/storage/labcoat/genetics = 2,
		/obj/item/clothing/suit/storage/suragi_jacket/genetics = 2,
		/obj/item/storage/backpack/satchel_gen 		= 2,
		/obj/item/storage/backpack/genetics			= 2,
		/obj/item/storage/backpack/duffel/genetics	= 2,

		/obj/item/clothing/under/rank/psych				= 2,
		/obj/item/clothing/under/rank/psych/turtleneck	= 2,
		/obj/item/clothing/under/rank/psych/skirt	= 2,

		/obj/item/clothing/suit/storage/labcoat/mortician 	= 2,
		/obj/item/clothing/under/rank/medical/mortician  	= 2,
		)


	refill_canister = /obj/item/vending_refill/clothing/medical

/obj/machinery/vending/clothing/departament/engineering
	name = "\improper Departament Engineering ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Инженерного Отдела."

	icon_state = "clothes-dep-eng_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-eng"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-eng_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_ENGINE_EQUIP)
	products = list(
		/obj/item/clothing/head/hardhat = 10,
		/obj/item/clothing/head/hardhat/orange = 10,
		/obj/item/clothing/head/hardhat/red = 10,
		/obj/item/clothing/head/hardhat/dblue = 10,
		/obj/item/clothing/head/beret/eng = 10,

		/obj/item/clothing/under/rank/engineer = 10,
		/obj/item/clothing/under/rank/engineer/skirt = 10,
		/obj/item/clothing/under/rank/engineer/trainee/assistant = 10,
		/obj/item/clothing/under/rank/engineer/trainee/assistant/skirt = 10,

		/obj/item/clothing/suit/storage/hazardvest = 10,
		/obj/item/clothing/suit/storage/suragi_jacket/eng = 5,
		/obj/item/clothing/suit/hooded/wintercoat/engineering = 5,

		/obj/item/clothing/mask/gas  = 10,
		/obj/item/clothing/mask/bandana/red 	= 10,
		/obj/item/clothing/mask/bandana/orange 	= 10,
		/obj/item/clothing/mask/bandana/red 	= 10,

		/obj/item/clothing/gloves/color/orange	= 10,
		/obj/item/clothing/gloves/color/fyellow = 3,

		/obj/item/clothing/shoes/workboots 		= 10,

		/obj/item/radio/headset/headset_eng 	= 10,

		/obj/item/clothing/accessory/scarf/yellow	= 10,
		/obj/item/clothing/accessory/scarf/orange	= 10,
		/obj/item/clothing/accessory/armband/engine = 10,

		/obj/item/storage/backpack/industrial = 5,
		/obj/item/storage/backpack/satchel_eng = 5,
		/obj/item/storage/backpack/duffel/engineering = 5,

		/obj/item/clothing/under/rank/atmospheric_technician = 3,
		/obj/item/clothing/under/rank/atmospheric_technician/skirt = 3,
		/obj/item/clothing/head/beret/atmos = 3,
		/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos = 5,
		/obj/item/clothing/suit/storage/suragi_jacket/atmos = 5,
		/obj/item/storage/backpack/duffel/atmos = 3.
		)


	refill_canister = /obj/item/vending_refill/clothing/engineering

/obj/machinery/vending/clothing/departament/science
	name = "\improper Departament Science ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Научного Отдела."

	icon_state = "clothes-dep-sci_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-sci"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-sci_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_RESEARCH)
	products = list(
		/obj/item/clothing/head/beret/purple_normal = 10,
		/obj/item/clothing/head/beret/purple = 10,

		/obj/item/clothing/under/rank/scientist = 10,
		/obj/item/clothing/under/rank/scientist/skirt = 10,
		/obj/item/clothing/under/rank/scientist/student = 10,
		/obj/item/clothing/under/rank/scientist/student/skirt = 10,
		/obj/item/clothing/under/rank/scientist/student/assistant = 10,
		/obj/item/clothing/under/rank/scientist/student/assistant/skirt = 10,

		/obj/item/clothing/suit/storage/labcoat/science = 10,
		/obj/item/clothing/suit/storage/labcoat 		= 10,
		/obj/item/clothing/suit/storage/suragi_jacket/sci = 5,
		/obj/item/clothing/suit/hooded/wintercoat/medical/science = 5,

		/obj/item/clothing/gloves/color/latex 	= 10,
		/obj/item/clothing/gloves/color/white 	= 10,
		/obj/item/clothing/gloves/color/purple 	= 10,

		/obj/item/clothing/shoes/white 			= 10,
		/obj/item/clothing/shoes/slippers 		= 10,
		/obj/item/clothing/shoes/sandal/white 	= 10,

		/obj/item/radio/headset/headset_sci 		= 10,
		/obj/item/clothing/accessory/armband/science = 10,
		/obj/item/clothing/accessory/armband/yb 	= 10,
		/obj/item/clothing/accessory/scarf/purple 	= 10,

		/obj/item/storage/backpack/science 			= 5,
		/obj/item/storage/backpack/satchel_tox 		= 5,
		/obj/item/storage/backpack/duffel/science 	= 5,

		/obj/item/clothing/head/soft/black 		= 10,
		/obj/item/clothing/under/rank/roboticist 	= 10,
		/obj/item/clothing/under/rank/roboticist/skirt = 10,
		/obj/item/clothing/gloves/fingerless 	= 10,
		/obj/item/clothing/shoes/black 			= 10,
		)


	refill_canister = /obj/item/vending_refill/clothing/science

/obj/machinery/vending/clothing/departament/cargo
	name = "\improper Departament Cargo ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Отдела Поставок."

	icon_state = "clothes-dep-car_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-car"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-car_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_MINING)
	products = list(
		/obj/item/clothing/head/soft = 10,

		/obj/item/clothing/under/rank/cargotech 		= 10,
		/obj/item/clothing/under/rank/cargotech/skirt 	= 10,
		/obj/item/clothing/under/rank/cargotech/alt		= 5,
		/obj/item/clothing/under/rank/miner/lavaland 	= 10,
		/obj/item/clothing/under/overalls 				= 10,
		/obj/item/clothing/under/rank/miner/alt			= 5,


		/obj/item/clothing/mask/bandana/black 	= 10,
		/obj/item/clothing/mask/bandana/orange 	= 10,

		/obj/item/clothing/gloves/color/brown/cargo = 10,
		/obj/item/clothing/gloves/color/light_brown = 10,
		/obj/item/clothing/gloves/fingerless 	= 10,
		/obj/item/clothing/gloves/color/black 	= 10,

		/obj/item/clothing/shoes/brown = 10,
		/obj/item/clothing/shoes/workboots/mining = 10,
		/obj/item/clothing/shoes/jackboots 				= 10,
		/obj/item/clothing/shoes/jackboots/jacksandals 	= 10,

		/obj/item/radio/headset/headset_cargo = 10,

		/obj/item/clothing/accessory/armband/cargo = 10,

		/obj/item/storage/backpack/cargo = 10,
		/obj/item/storage/backpack/explorer = 5,
		/obj/item/storage/backpack/satchel_explorer = 5,
		/obj/item/storage/backpack/duffel = 5,

		/obj/item/clothing/under/pants/tan 		= 10,
		/obj/item/clothing/under/pants/track 	= 10,

		/obj/item/clothing/suit/storage/cargotech = 5,

		/obj/item/clothing/suit/hooded/wintercoat/cargo	= 5,
		/obj/item/clothing/suit/hooded/wintercoat/miner	= 5,
		)


	refill_canister = /obj/item/vending_refill/clothing/cargo


/obj/machinery/vending/clothing/departament/law
	name = "\improper Departament Law ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Юридического Отдела."

	icon_state = "clothes-dep-sec_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-sec"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-sec_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_LAWYER)
	products = list(
		/obj/item/clothing/under/rank/internalaffairs = 10,
		/obj/item/clothing/under/lawyer/female = 10,
		/obj/item/clothing/under/lawyer/black = 10,
		/obj/item/clothing/under/lawyer/red = 10,
		/obj/item/clothing/under/lawyer/blue = 10,
		/obj/item/clothing/under/lawyer/bluesuit = 10,
		/obj/item/clothing/under/lawyer/purpsuit = 10,
		/obj/item/clothing/under/lawyer/oldman = 10,
		/obj/item/clothing/under/blackskirt 	= 10,

		/obj/item/clothing/suit/storage/internalaffairs  = 10,
		/obj/item/clothing/suit/storage/lawyer/bluejacket = 5,
		/obj/item/clothing/suit/storage/lawyer/purpjacket = 5,
		/obj/item/clothing/under/suit_jacket = 5,
		/obj/item/clothing/under/suit_jacket/really_black = 5,
		/obj/item/clothing/under/suit_jacket/female = 5,
		/obj/item/clothing/under/suit_jacket/red = 5,
		/obj/item/clothing/under/suit_jacket/navy = 5,
		/obj/item/clothing/under/suit_jacket/tan = 5,
		/obj/item/clothing/under/suit_jacket/burgundy = 5,
		/obj/item/clothing/under/suit_jacket/charcoal = 5,

		/obj/item/clothing/gloves/color/white 	= 10,
		/obj/item/clothing/gloves/fingerless	= 10,

		/obj/item/clothing/shoes/laceup  		= 10,
		/obj/item/clothing/shoes/centcom 		= 10,
		/obj/item/clothing/shoes/brown 			= 10,
		/obj/item/clothing/shoes/sandal/fancy 	= 10,

		/obj/item/radio/headset/headset_iaa  	= 10,


		/obj/item/clothing/accessory/blue 		= 10,
		/obj/item/clothing/accessory/red 		= 10,
		/obj/item/clothing/accessory/black 		= 10,
		/obj/item/clothing/accessory/waistcoat	= 5,

		/obj/item/storage/backpack/satchel 	= 10,
		/obj/item/storage/briefcase			= 5,
		)


	refill_canister = /obj/item/vending_refill/clothing/law


/obj/machinery/vending/clothing/departament/service
	name = "\improper Departament Service ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Сервисного отдела."
	req_access = list()
	products = list()
	refill_canister = /obj/item/vending_refill/

/obj/machinery/vending/clothing/departament/service/chaplain
	name = "\improper Departament Service ClothesMate Chaplain"
	desc = "Автомат-помощник по выдаче одежды Сервисного отдела церкви."

	icon_state = "clothes-dep-car_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-car"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-car_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_CHAPEL_OFFICE)
	products = list(
		/obj/item/clothing/under/rank/chaplain = 5,
		/obj/item/clothing/under/rank/chaplain/skirt = 5,
		/obj/item/clothing/suit/witchhunter = 2,
		/obj/item/clothing/head/witchhunter_hat = 2,
		/obj/item/clothing/suit/armor/riot/knight/templar = 1,
		/obj/item/clothing/head/helmet/riot/knight/templar = 1,
		/obj/item/clothing/under/wedding/bride_white = 1,
		/obj/item/clothing/suit/hooded/chaplain_hoodie = 2,
		/obj/item/radio/headset/headset_service = 5,
		/obj/item/clothing/suit/hooded/nun = 2,
		/obj/item/clothing/suit/holidaypriest = 2,
		/obj/item/clothing/head/bishopmitre = 2,
		/obj/item/clothing/neck/cloak/bishop = 2,
		/obj/item/clothing/head/blackbishopmitre = 2,
		/obj/item/clothing/neck/cloak/bishopblack = 2,
		/obj/item/storage/backpack/cultpack = 5,
		/obj/item/clothing/shoes/black = 5,
		/obj/item/clothing/shoes/laceup = 2,
		/obj/item/clothing/gloves/ring/gold = 2,
		/obj/item/clothing/gloves/ring/silver = 2
	)
	refill_canister = /obj/item/vending_refill/clothing/service/chaplain


/obj/machinery/vending/clothing/departament/service/botanical
	name = "\improper Departament Service ClothesMate Botanical"
	desc = "Автомат-помощник по выдаче одежды Сервисного отдела ботаники."
	req_access = list(ACCESS_HYDROPONICS)
	products = list(
		/obj/item/clothing/under/rank/hydroponics = 5,
		/obj/item/clothing/under/rank/hydroponics/skirt = 5,
		/obj/item/clothing/suit/storage/suragi_jacket/botany = 3,
		/obj/item/clothing/suit/apron = 4,
		/obj/item/clothing/suit/apron/overalls = 2,
		/obj/item/clothing/suit/hooded/wintercoat/hydro = 5,
		/obj/item/clothing/mask/bandana/botany = 4,
		/obj/item/clothing/accessory/scarf/green = 2,
		/obj/item/clothing/head/flatcap = 2,
		/obj/item/radio/headset/headset_service = 5,
		/obj/item/clothing/gloves/botanic_leather = 5,
		/obj/item/clothing/gloves/fingerless = 3,
		/obj/item/clothing/gloves/color/brown = 3,
		/obj/item/storage/backpack/botany = 5,
		/obj/item/storage/backpack/satchel_hyd = 5,
		/obj/item/storage/backpack/duffel/hydro = 5,
		/obj/item/clothing/shoes/brown = 4,
		/obj/item/clothing/shoes/sandal = 2,
		/obj/item/clothing/shoes/leather = 2
	)
	refill_canister = /obj/item/vending_refill/clothing/service/botanical

/obj/machinery/vending/nta
	name = "NT Ammunition"
	desc = "A special equipment vendor."
	ads_list = list("Возьми патрон!","Не забывай, снаряжаться - полезно!","Бжж-Бзз-з!.","Обезопасить, Удержать, Сохранить!","Стоять, снярядись на задание!")

	icon_state = "nta_base"
	panel_overlay = "nta_panel"
	screen_overlay = "nta"
	lightmask_overlay = "nta_lightmask"
	broken_overlay = "nta_broken"
	broken_lightmask_overlay = "nta_lightmask"
	vend_overlay = "nta_vend"
	deny_overlay = "nta_deny"
	vend_overlay_time = 3 SECONDS

	req_access = list(ACCESS_SECURITY)
	products = list(
		/obj/item/grenade/flashbang = 4,
		/obj/item/flash = 5,
		/obj/item/flashlight/seclite = 4,
		/obj/item/restraints/legcuffs/bola/energy = 8,

		/obj/item/ammo_box/shotgun = 4,
		/obj/item/ammo_box/shotgun/buck = 4,
		/obj/item/ammo_box/shotgun/rubbershot = 4,
		/obj/item/ammo_box/shotgun/stunslug = 5,
		/obj/item/ammo_box/shotgun/ion = 2,
		/obj/item/ammo_box/shotgun/laserslug = 5,
		/obj/item/ammo_box/speedloader/shotgun = 8,

		/obj/item/ammo_box/magazine/lr30mag = 12,
		/obj/item/ammo_box/magazine/enforcer = 8,
		/obj/item/ammo_box/magazine/enforcer/lethal = 8,
		/obj/item/ammo_box/magazine/sp8 = 8,

		/obj/item/ammo_box/magazine/laser = 12,
		/obj/item/ammo_box/magazine/wt550m9 = 20,
		/obj/item/ammo_box/magazine/m556 = 12,
		/obj/item/ammo_box/a40mm = 4,

		/obj/item/ammo_box/c46x30mm = 8,
		/obj/item/ammo_box/inc46x30mm = 4,
		/obj/item/ammo_box/tox46x30mm = 4,
		/obj/item/ammo_box/ap46x30mm = 4,
		/obj/item/ammo_box/laserammobox = 4
	)
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2,/obj/item/storage/fancy/donut_box = 2,/obj/item/grenade/clusterbuster/apocalypsefake = 1)
	refill_canister = /obj/item/vending_refill/nta
	tiltable = FALSE //no ert tilt

/obj/machinery/vending/nta/ertarmory
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/machinery/vending/nta/ertarmory/update_overlays()
	. = list()

	underlays.Cut()

	. += base_icon_state

	if(panel_open)
		. += "nta_panel"

	if((stat & NOPOWER) || force_no_power_icon_state)
		. += "nta_off"
		return

	if(stat & BROKEN)
		. += "nta_broken"
	else
		if(flick_sequence & FLICK_VEND)
			. += vend_overlay

		else if(flick_sequence & FLICK_DENY)
			. += deny_overlay

	underlays += emissive_appearance(icon, "nta_lightmask", src)


/obj/machinery/vending/nta/ertarmory/blue
	name = "NT ERT Medium Gear & Ammunition"
	desc = "A ERT Medium equipment vendor."
	ads_list = list("Круши черепа синдиката!","Не забывай, спасать - полезно!","Бжж-Бзз-з!.","Обезопасить, Удержать, Сохранить!","Стоять, снярядись на задание!")

	icon_state = "nta_base"
	base_icon_state = "nta-blue"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-blue_deny"

	req_access = list(ACCESS_CENT_SECURITY)
	products = list(
		/obj/item/gun/energy/gun = 3,
		/obj/item/gun/energy/ionrifle/carbine = 1,
		/obj/item/gun/projectile/automatic/lasercarbine = 3,
		/obj/item/ammo_box/magazine/laser = 6,
		/obj/item/suppressor = 4,
		/obj/item/ammo_box/speedloader/shotgun = 4,
		/obj/item/gun/projectile/automatic/sfg = 3,
		/obj/item/ammo_box/magazine/sfg9mm = 6,
		/obj/item/gun/projectile/shotgun/automatic/combat = 3,
		/obj/item/ammo_box/shotgun = 4,
		/obj/item/ammo_box/shotgun/buck = 4,
		/obj/item/ammo_box/shotgun/dragonsbreath = 2
	)
	contraband = list(/obj/item/storage/fancy/donut_box = 2)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/nta/ertarmory/red
	name = "NT ERT Heavy Gear & Ammunition"
	desc = "A ERT Heavy equipment vendor."
	ads_list = list("Круши черепа синдиката!","Не забывай, спасать - полезно!","Бжж-Бзз-з!.","Обезопасить, Удержать, Сохранить!","Стоять, снярядись на задание!")

	icon_state = "nta_base"
	base_icon_state = "nta-red"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-red_deny"

	req_access = list(ACCESS_CENT_SECURITY)
	products = list(
		/obj/item/gun/projectile/automatic/ar = 3,
		/obj/item/ammo_box/magazine/m556 = 6,
		/obj/item/gun/projectile/automatic/m52 = 3,
		/obj/item/ammo_box/magazine/m52mag = 6,
		/obj/item/gun/energy/sniperrifle = 1,
		/obj/item/gun/energy/lasercannon = 3,
		/obj/item/gun/energy/xray = 2,
		/obj/item/gun/energy/immolator/multi = 2,
		/obj/item/gun/energy/gun/nuclear = 3,
		/obj/item/storage/lockbox/t4 = 3,
		/obj/item/grenade/smokebomb = 3,
		/obj/item/grenade/frag = 4
	)
	contraband = list(/obj/item/storage/fancy/donut_box = 2)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/nta/ertarmory/green
	name = "NT ERT Light Gear & Ammunition"
	desc = "A ERT Light equipment vendor."
	ads_list = list("Круши черепа синдиката!","Не забывай, спасать - полезно!","Бжж-Бзз-з!.","Обезопасить, Удержать, Сохранить!","Стоять, снярядись на задание!")

	icon_state = "nta_base"
	base_icon_state = "nta-green"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-green_deny"

	req_access = list(ACCESS_CENT_SECURITY)
	products = list(
		/obj/item/restraints/handcuffs = 5,
		/obj/item/restraints/handcuffs/cable/zipties = 5,
		/obj/item/grenade/flashbang = 3,
		/obj/item/flash = 2,
		/obj/item/gun/energy/gun/advtaser = 4,
		/obj/item/gun/projectile/automatic/pistol/enforcer = 6,
		/obj/item/storage/box/barrier = 2,
		/obj/item/gun/projectile/shotgun/riot = 3,
		/obj/item/ammo_box/shotgun/rubbershot = 6,
		/obj/item/ammo_box/shotgun/beanbag = 4,
		/obj/item/ammo_box/shotgun/tranquilizer = 4,
		/obj/item/ammo_box/speedloader/shotgun = 4,
		/obj/item/gun/projectile/automatic/wt550 = 3,
		/obj/item/ammo_box/magazine/wt550m9 = 6,
		/obj/item/gun/energy/dominator/sibyl = 2,
		/obj/item/melee/baton/telescopic = 4
	)
	contraband = list(/obj/item/storage/fancy/donut_box = 2)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/nta/ertarmory/green/cc_jail
	name = "NT CentComm prison guards' Gear & Ammunition"
	desc = "An equipment vendor for CentComm corrections officers."
	products = list(/obj/item/restraints/handcuffs=5,
		/obj/item/restraints/handcuffs/cable/zipties=5,
		/obj/item/grenade/flashbang=3,
		/obj/item/flash=3,
		/obj/item/restraints/legcuffs/bola/energy=3,
		/obj/item/gun/energy/gun/advtaser=6,
		/obj/item/gun/projectile/automatic/pistol/enforcer=6,
		/obj/item/storage/box/barrier=2,
		/obj/item/gun/projectile/shotgun/riot=2,
		/obj/item/ammo_box/shotgun/rubbershot=4,
		/obj/item/ammo_box/shotgun=2,
		/obj/item/ammo_box/magazine/enforcer=6,
		/obj/item/gun/energy/dominator/sibyl=3)
	contraband = list(/obj/item/storage/fancy/donut_box=2,
		/obj/item/ammo_box/shotgun/buck=4,
		/obj/item/ammo_box/magazine/enforcer/lethal=4)

/obj/machinery/vending/nta/ertarmory/yellow
	name = "NT ERT Death Wish Gear & Ammunition"
	desc = "A ERT Death Wish equipment vendor."
	ads_list = list("Круши черепа ВСЕХ!","Не забывай, УБИВАТЬ - полезно!","УБИВАТЬ УБИВАТЬ УБИВАТЬ УБИВАТЬ!.","УБИВАТЬ, Удержать, УБИВАТЬ!","Стоять, снярядись на УБИВАТЬ!")

	icon_state = "nta_base"
	base_icon_state = "nta-yellow"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-yellow_deny"

	req_access = list(ACCESS_CENT_SECURITY)
	products = list(
		/obj/item/gun/projectile/automatic/gyropistol = 8,
		/obj/item/ammo_box/magazine/m75 = 12,
		/obj/item/gun/projectile/automatic/l6_saw = 6,
		/obj/item/ammo_box/magazine/mm556x45/ap = 12,
		/obj/item/gun/projectile/automatic/shotgun/bulldog = 6,
		/obj/item/gun/energy/immolator = 6,
		/obj/item/storage/backpack/duffel/syndie/ammo/shotgun = 12,
		/obj/item/gun/energy/xray = 8,
		/obj/item/gun/energy/pulse/destroyer/annihilator = 8,
		/obj/item/grenade/clusterbuster/inferno = 3,
		/obj/item/grenade/clusterbuster/emp = 3
	)
	contraband = list(/obj/item/storage/fancy/donut_box = 2)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/nta/ertarmory/medical
	name = "NT ERT Medical Gear"
	desc = "A ERT medical equipment vendor."
	ads_list = list("Лечи раненых от рук синдиката!","Не забывай, лечить - полезно!","Бжж-Бзз-з!.","Перевязать, Оперировать, Выписать!","Стоять, снярядись медикаментами на задание!")

	icon_state = "nta_base"
	base_icon_state = "nta-medical"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-medical_deny"

	req_access = list(ACCESS_CENT_MEDICAL)
	products = list(
		/obj/item/storage/firstaid/tactical = 2,
		/obj/item/reagent_containers/applicator/dual = 2,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis = 4,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis = 2,
		/obj/item/storage/belt/medical/surgery/loaded = 2,
		/obj/item/storage/belt/medical/response_team = 3,
		/obj/item/storage/pill_bottle/ert = 4,
		/obj/item/reagent_containers/food/pill/mannitol = 10,
		/obj/item/reagent_containers/food/pill/salbutamol = 10,
		/obj/item/reagent_containers/food/pill/morphine = 8,
		/obj/item/reagent_containers/food/pill/charcoal = 10,
		/obj/item/reagent_containers/food/pill/mutadone = 8,
		/obj/item/storage/pill_bottle/patch_pack = 4,
		/obj/item/reagent_containers/food/pill/patch/silver_sulf = 10,
		/obj/item/reagent_containers/food/pill/patch/styptic = 10,
		/obj/item/storage/toolbox/surgery = 2,
		/obj/item/scalpel/laser/manager = 2,
		/obj/item/reagent_containers/applicator/brute = 4,
		/obj/item/reagent_containers/applicator/burn = 4,
		/obj/item/healthanalyzer/advanced = 4,
		/obj/item/roller/holo = 2
	)
	contraband = list()
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/nta/ertarmory/engineer
	name = "NT ERT Engineer Gear"
	desc = "A ERT engineering equipment vendor."
	ads_list = list("Чини станцию от рук синдиката!","Не забывай, чинить - полезно!","Бжж-Бзз-з!.","Починить, Заварить, Трубить!","Стоять, снярядись на починку труб!")

	icon_state = "nta_base"
	base_icon_state = "nta-engi"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-engi_deny"

	req_access = list(ACCESS_CENT_GENERAL)
	products = list(
		/obj/item/storage/belt/utility/chief/full = 2,
		/obj/item/clothing/mask/gas/welding = 4,
		/obj/item/weldingtool/experimental = 3,
		/obj/item/crowbar/power = 3,
		/obj/item/screwdriver/power  = 3,
		/obj/item/extinguisher/mini = 3,
		/obj/item/multitool = 3,
		/obj/item/rcd/preloaded = 2,
		/obj/item/rcd_ammo  = 8,
		/obj/item/stack/cable_coil = 4
	)
	contraband = list(/obj/item/clothing/head/welding/flamedecal = 1,
		/obj/item/storage/fancy/donut_box = 2,
		/obj/item/clothing/head/welding/flamedecal/white  = 1,
		/obj/item/clothing/head/welding/flamedecal/blue = 1
		)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/nta/ertarmory/janitor
	name = "NT ERT Janitor Gear"
	desc = "A ERT ccleaning equipment vendor."
	ads_list = list("Чисть станцию от рук синдиката!","Не забывай, чистить - полезно!","Вилкой чисти!.","Помыть, Постирать, Оттереть!","Стоять, снярядись клинерами!")

	icon_state = "nta_base"
	base_icon_state = "nta-janitor"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-janitor_deny"

	req_access = list(ACCESS_CENT_GENERAL)
	products = list(
		/obj/item/storage/belt/janitor/ert = 2,
		/obj/item/clothing/shoes/galoshes = 2,
		/obj/item/grenade/chem_grenade/antiweed = 2,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/obj/item/storage/bag/trash = 2,
		/obj/item/storage/box/lights/mixed = 4,
		/obj/item/melee/flyswatter= 1,
		/obj/item/soap/ert = 2,
		/obj/item/grenade/chem_grenade/cleaner = 4,
		/obj/item/clothing/mask/gas = 3,
		/obj/item/watertank/janitor  = 4,
		/obj/item/lightreplacer = 2
	)
	contraband = list(/obj/item/grenade/clusterbuster/cleaner = 1, /obj/item/storage/fancy/donut_box = 2, )
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/pai
	name = "\improper RoboFriends"
	desc = "Wonderful vendor of PAI friends"

	icon_state = "paivend_off"
	panel_overlay = "paivend_panel"
	screen_overlay = "paivend"
	lightmask_overlay = "paivend_lightmask"
	broken_overlay = "paivend_broken"
	broken_lightmask_overlay = "paivend_broken_lightmask"

	ads_list = list("А вы любите нас?","Мы твои друзья!","Эта покупка войдет в историю","Я ПАИ простой, купишь меня, а я тебе друга!","Спасибо за покупку.")
	resistance_flags = FIRE_PROOF
	products = list(
		/obj/item/paicard = 10,
		/obj/item/pai_cartridge/female = 10,
		/obj/item/pai_cartridge/doorjack = 5,
		/obj/item/pai_cartridge/memory = 5,
		/obj/item/pai_cartridge/reset = 5,
		/obj/item/robot_parts/l_arm = 1,
		/obj/item/robot_parts/r_arm = 1
	)
	contraband = list(
		/obj/item/pai_cartridge/syndi_emote = 1,
		/obj/item/pai_cartridge/snake = 1
	)
	prices = list(
		/obj/item/paicard = 200,
		/obj/item/robot_parts/l_arm = 550,
		/obj/item/robot_parts/r_arm = 550,
		/obj/item/pai_cartridge/female = 150,
		/obj/item/pai_cartridge/doorjack = 400,
		/obj/item/pai_cartridge/syndi_emote = 650,
		/obj/item/pai_cartridge/snake = 600,
		/obj/item/pai_cartridge/reset = 500,
		/obj/item/pai_cartridge/memory = 350
	)
	refill_canister = /obj/item/vending_refill/pai

/obj/machinery/vending/security/ert
	name = "NT ERT Consumables Gear"
	desc = "A consumable equipment for different situations."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta

	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "sec_off"
	panel_overlay = "sec_panel"
	screen_overlay = "sec"
	lightmask_overlay = "sec_lightmask"
	broken_overlay = "sec_broken"
	broken_lightmask_overlay = "sec_broken_lightmask"
	deny_overlay = "sec_deny"

	density = FALSE
	products = list(
		/obj/item/restraints/handcuffs = 10,
		/obj/item/flashlight/seclite = 10,
		/obj/item/shield/riot/tele = 10,
		/obj/item/storage/box/flare = 5,
		/obj/item/storage/box/bodybags = 5,
		/obj/item/storage/box/bola = 5,
		/obj/item/grenade/smokebomb = 10,
		/obj/item/grenade/barrier = 15,
		/obj/item/grenade/flashbang = 10,
		/obj/item/grenade/plastic/c4_shaped/flash = 5,
		/obj/item/flash = 5,
		/obj/item/storage/box/evidence = 5,
		/obj/item/storage/box/swabs = 5,
		/obj/item/storage/box/fingerprints = 5)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/ntc
	req_access = list(ACCESS_CENT_GENERAL)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta

	icon_state = "nta_base"
	panel_overlay = "nta_panel"
	screen_overlay = "nta"
	lightmask_overlay = "nta_lightmask"
	broken_overlay = "nta_broken"
	broken_lightmask_overlay = "nta_lightmask"
	vend_overlay = "nta_vend"
	deny_overlay = "nta_deny"
	vend_overlay_time = 3 SECONDS

/obj/machinery/vending/ntc/update_overlays()
	. = list()

	underlays.Cut()

	. += base_icon_state

	if(panel_open)
		. += "nta_panel"

	if((stat & NOPOWER) || force_no_power_icon_state)
		. += "nta_off"
		return

	if(stat & BROKEN)
		. += "nta_broken"
	else
		if(flick_sequence & FLICK_VEND)
			. += vend_overlay

		else if(flick_sequence & FLICK_DENY)
			. += deny_overlay

	underlays += emissive_appearance(icon, "nta_lightmask", src)

/obj/machinery/vending/ntc/medal
	name = "NT Cargo Encouragement"
	desc = "A encourage vendor with many of medal types."
	icon = 'icons/obj/storage.dmi'
	icon_state = "medalbox"
	products = list(
		/obj/item/clothing/accessory/medal = 5,
		/obj/item/clothing/accessory/medal/engineering = 5,
		/obj/item/clothing/accessory/medal/security = 5,
		/obj/item/clothing/accessory/medal/science = 5,
		/obj/item/clothing/accessory/medal/service = 5,
		/obj/item/clothing/accessory/medal/medical = 5,
		/obj/item/clothing/accessory/medal/legal = 5,
		/obj/item/clothing/accessory/medal/silver = 5,
		/obj/item/clothing/accessory/medal/silver/leadership = 5,
		/obj/item/clothing/accessory/medal/silver/valor = 5,
		/obj/item/clothing/accessory/medal/gold = 5,
		/obj/item/clothing/accessory/medal/gold/heroism = 5
	)

/obj/machinery/vending/ntc/medical
	name = "NT Cargo Medical Gear"
	desc = "A some medical equipment vendor for cargo."

	icon_state = "nta_base"
	base_icon_state = "nta-medical"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-medical_deny"

	products = list(
		/obj/item/storage/box/hardsuit/medical/responseteam = 10,
		/obj/item/storage/box/hardsuit/medical = 10,
		/obj/item/clothing/glasses/hud/health/night = 10,
		/obj/item/bodyanalyzer/advanced = 10,
		/obj/item/storage/firstaid/tactical = 10,
		/obj/item/gun/medbeam = 10,
		/obj/item/defibrillator/compact/loaded = 10,
		/obj/item/handheld_defibrillator = 10,
		/obj/item/vending_refill/medical = 10)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/ntc/engineering
	name = "NT Cargo Engineering Gear"
	desc = "A some engineering equipment vendor for cargo."

	icon_state = "nta_base"
	base_icon_state = "nta-engi"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-engi_deny"

	products = list(
		/obj/item/storage/box/hardsuit/engineering/response_team = 10,
		/obj/item/storage/box/hardsuit/engineering = 10,
		/obj/item/clothing/glasses/meson/sunglasses = 10,
		/obj/item/clothing/gloves/color/yellow = 10,
		/obj/item/storage/belt/utility/chief/full = 10,
		/obj/item/rcd/combat = 10,
		/obj/item/rcd_ammo/large = 20,
		/obj/item/grenade/chem_grenade/metalfoam = 30
	)

/obj/machinery/vending/ntc/janitor
	name = "NT Cargo Janitor Gear"
	desc = "A some janitor equipment vendor for cargo."

	icon_state = "nta_base"
	base_icon_state = "nta-janitor"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-janitor_deny"

	products = list(
		/obj/item/storage/box/hardsuit/janitor/response_team = 10,
		/obj/item/storage/belt/janitor/ert = 10,
		/obj/item/clothing/shoes/galoshes = 10,
		/obj/item/reagent_containers/spray/cleaner = 20,
		/obj/item/watertank/janitor = 10,
		/obj/item/soap/ert = 10,
		/obj/item/storage/bag/trash/bluespace = 10,
		/obj/item/lightreplacer/bluespace = 10,
		/obj/item/scythe/tele = 20,
		/obj/item/grenade/chem_grenade/cleaner = 30,
		/obj/item/grenade/clusterbuster/cleaner = 30,
		/obj/item/grenade/chem_grenade/antiweed = 30,
		/obj/item/grenade/clusterbuster/antiweed = 30
	)

/obj/machinery/vending/ntcrates
	name = "NT Cargo Preset Gear"
	desc = "A already preset of equipments vendor for cargo."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta

	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "magivend_off"
	panel_overlay = "magivend_panel"
	screen_overlay = "magivend"
	lightmask_overlay = "magivend_lightmask"
	broken_overlay = "magivend_broken"
	broken_lightmask_overlay = "magivend_broken_lightmask"

	products = list(
		/obj/structure/closet/crate/trashcart/NTdelivery = 100,
		/obj/structure/closet/crate/secure/gear = 100,
		/obj/structure/closet/crate/secure/weapon = 100,
		/obj/item/storage/backpack/duffel/security/riot = 100,
		/obj/item/storage/backpack/duffel/security/war = 100,
		/obj/item/storage/backpack/duffel/hydro/weed = 100,
		/obj/item/storage/backpack/duffel/security/spiders = 100,
		/obj/item/storage/backpack/duffel/security/blob = 100,
		/obj/item/storage/backpack/duffel/engineering/building_event = 100
	)

/obj/machinery/vending/ntc/ert
	name = "NT Response Team Base Gear"
	desc = "A ERT Base equipment vendor"

	icon_state = "nta_base"
	base_icon_state = "nta-blue"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-blue_deny"

	products = list(
		/obj/item/storage/box/responseteam/amber/commander = 100,
		/obj/item/storage/box/responseteam/amber/security = 100,
		/obj/item/storage/box/responseteam/amber/engineer = 100,
		/obj/item/storage/box/responseteam/amber/medic = 100,
		/obj/item/storage/box/responseteam/amber/janitor = 100,
		/obj/item/storage/box/responseteam/red/commander = 100,
		/obj/item/storage/box/responseteam/red/security = 100,
		/obj/item/storage/box/responseteam/red/engineer = 100,
		/obj/item/storage/box/responseteam/red/medic = 100,
		/obj/item/storage/box/responseteam/red/janitor = 100)

/obj/machinery/vending/ntc_resources
	name = "NT Matter Сompression Vendor"
	desc = "Its vendor use advanced technology of matter compression and can have a many volume of resources."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta

	icon_state = "engi_off"
	panel_overlay = "engi_panel"
	screen_overlay = "engi"
	lightmask_overlay = "engi_lightmask"
	broken_overlay = "engi_broken"
	broken_lightmask_overlay = "engi_broken_lightmask"
	deny_overlay = "engi_deny"
	deny_lightmask = "engi_deny_lightmask"

	products = list(/obj/item/stack/sheet/mineral/diamond/fifty = 50,
		/obj/item/stack/sheet/mineral/gold/fifty = 50,
		/obj/item/stack/sheet/glass/fifty = 50,
		/obj/item/stack/sheet/metal/fifty = 50,
		/obj/item/stack/sheet/mineral/plasma/fifty = 50,
		/obj/item/stack/sheet/mineral/silver/fifty = 50,
		/obj/item/stack/sheet/mineral/titanium/fifty = 50,
		/obj/item/stack/sheet/mineral/uranium/fifty = 50)
	contraband = list(/obj/item/stack/sheet/mineral/tranquillite/fifty = 50,
		/obj/item/stack/sheet/mineral/bananium/fifty = 50,
		/obj/item/stack/sheet/mineral/sandstone/fifty = 50,
		/obj/item/stack/sheet/mineral/abductor/fifty = 50)

/obj/machinery/vending/mech/ntc
	icon = 'icons/obj/machines/vending.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/mech/ntc/exousuit
	name = "NT Exosuit Bluespace Transporter"
	desc = "Fabricator with advanced technology of bluespace transporting of resources."
	icon = 'icons/obj/machines/robotics.dmi'
	icon_state = "fab-idle"
	products = list(
		/obj/mecha/combat/durand = 10,
		/obj/mecha/combat/gygax = 10,
		/obj/mecha/combat/phazon = 10,
		/obj/mecha/medical/odysseus = 10,
		/obj/mecha/working/ripley = 10,
		/obj/mecha/working/ripley/firefighter = 10,
		/obj/mecha/working/clarke = 10)

/obj/machinery/vending/mech/ntc/equipment
	name = "NT Exosuit Bluespace Transporter"
	desc = "Fabricator with advanced technology of bluespace transporting of resources."

	icon_state = "engivend_off"
	panel_overlay = "engivend_panel"
	screen_overlay = "engivend"
	lightmask_overlay = "engivend_lightmask"
	broken_overlay = "engivend_broken"
	broken_lightmask_overlay = "engivend_broken_lightmask"
	deny_overlay = "engivend_deny"

	products = list(
		/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster = 10,
		/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster = 10,
		/obj/item/mecha_parts/mecha_equipment/repair_droid = 10,
		/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay = 10,
		/obj/item/mecha_parts/mecha_equipment/generator/nuclear = 10
	)

/obj/machinery/vending/mech/ntc/weapon
	name = "NT Exosuit Bluespace Transporter"
	desc = "Fabricator with advanced technology of bluespace transporting of resources."

	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "liberationstation_off"
	panel_overlay = "liberationstation_panel"
	screen_overlay = "liberationstation"
	lightmask_overlay = "liberationstation_lightmask"
	broken_overlay = "liberationstation_broken"
	broken_lightmask_overlay = "liberationstation_broken_lightmask"

	products = list(
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/dual = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/medium = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/heavy = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/amlg = 10,
	)

/obj/machinery/vending/mech/ntc/tools
	name = "NT Exosuit Bluespace Transporter"
	desc = "Fabricator with advanced technology of bluespace transporting of resources."

	icon_state = "tool_off"
	panel_overlay = "tool_panel"
	screen_overlay = "tool"
	lightmask_overlay = "tool_lightmask"
	broken_overlay = "tool_broken"
	broken_lightmask_overlay = "tool_broken_lightmask"
	deny_overlay = "tool_deny"

	products = list(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp = 10,
		/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill = 10,
		/obj/item/mecha_parts/mecha_equipment/mining_scanner = 10,
		/obj/item/mecha_parts/mecha_equipment/rcd = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma = 10,
		/obj/item/mecha_parts/mecha_equipment/extinguisher = 10,
		/obj/item/mecha_parts/mecha_equipment/cable_layer = 10,
		/obj/item/mecha_parts/mecha_equipment/wormhole_generator = 10,
	)

#undef FLICK_NONE
#undef FLICK_VEND
#undef FLICK_DENY

#undef VENDOR_CRUSH_HANDLED
#undef VENDOR_THROW_AT_TARGET
#undef VENDOR_TIP_IN_PLACE
