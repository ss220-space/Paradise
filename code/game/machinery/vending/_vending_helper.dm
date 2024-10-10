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

