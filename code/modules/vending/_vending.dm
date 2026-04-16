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

/// Maximum credits dump threshold
#define CREDITS_DUMP_THRESHOLD 100
/// The amount of credits collected by the vending machine when someone buys the product.
#define VENDING_CREDITS_COLLECTION_AMOUNT 0.2

// Names for default vending categories
#define CATEGORY_NAME_GENERIC "Товары"
#define CATEGORY_NAME_PREMIUM "Премиум"
#define CATEGORY_NAME_CONTRABAND "Контрабанда"

/**
 *  Datum used to hold information about a product in a vending machine.
 */
/datum/data/vending_product
	name = "generic"
	/// Shorter name of the product (for Grid layout in TGUI)
	var/short_name = ""
	/// Description of the vending product
	var/desc = ""
	/// Typepath of the product that is created when this record "sells"
	var/product_path = null
	/// How many of this product we currently have
	var/amount = 0
	/// How many we can store at maximum
	var/max_amount = 0
	/// The price of the item
	var/price
	/**
	 * The category the product was in, if any.
	 * Sourced directly from product_categories.
	 */
	var/category
	/// Whether the product can be recolored by the GAGS system
	var/colorable

/obj/machinery/vending
	name = "Vendomat"
	desc = "Обычный торговый автомат."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "generic_off"
	anchored = TRUE
	density = TRUE
	max_integrity = 300
	integrity_failure = 100
	armor = list(MELEE = 20, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 70)
	abstract_type = /obj/machinery/vending

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
	idle_power_usage = 10
	var/vend_power_usage = 150

	// Vending-related
	/// No sales pitches if off
	var/active = TRUE
	/// If off, vendor is busy and unusable until current action finishes
	var/vend_ready = TRUE
	/// How long vendor takes to vend one item.
	var/vend_delay = 0.2 SECONDS
	/// Item currently being bought
	var/datum/data/vending_product/currently_vending = null

	/**
	 * List of products this machine sells
	 *
	 * form should be list(/type/path = amount, /type/path2 = amount2)
	 */
	var/list/products = list()

	/**
	 * List of products this machine sells, categorized.
	 * Can only be used as an alternative to `products`, not alongside it.
	 * Be aware that categories will be inherited by children object,
	 * and will override it's `products` list if children's categories aren't set to `null`.
	 *
	 * Form should be list(
	 ** 	"name" = "Category Name",
	 ** 	"icon" = "UI Icon (Font Awesome)",
	 ** 	"products" = list(/type/path = amount, ...),
	 * )
	 */
	var/list/product_categories = null

	/**
	 * List of products this machine sells when you hack it
	 *
	 * form should be list(/type/path = amount, /type/path2 = amount2)
	 */
	var/list/contraband = list()

	/**
	 * List of premium products this machine sells
	 *
	 * form should be list(/type/path = amount, /type/path2 = amount2)
	 */
	var/list/premium = list()

	// List of vending_product items available.
	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/premium_records = list()

	// Stuff relating vocalizations
	/// List of ads the vendor will say time to time.
	var/list/slogan_list = list()
	///List of ads to display in UI. Built from `slogan_list` upon Iniitialize()
	var/list/ads_list = list()
	/**
	 * "Спас+ибо за пок+упку!" type phrases, which are said when someone buys something.
	 *
	 * Place "+" before stressed syllables for better Text-to-speech pronunciation.
	 */
	var/vend_reply
	/// If true, prevent saying sales pitches
	var/shut_up = FALSE
	/// can we access the hidden inventory?
	var/extended_inventory = FALSE
	var/last_reply = 0
	/// When did we last pitch?
	var/last_slogan = 0
	/// How long until we can pitch again?
	var/slogan_delay = 4500

	/// The type of refill canisters used by this machine.
	var/obj/item/vending_refill/refill_canister = null

	// Things that can go wrong
	/// Allows people to access a vendor that's normally access restricted.
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

	/// Default price of items if not overridden
	var/default_price = PAYCHECK_MIN
	/// Default price of premium items if not overridden
	var/default_premium_price = PAYCHECK_LOWER

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
		/datum/vendor_crit/embed,
		/datum/vendor_crit/pin,
		/datum/vendor_crit/shatter,
		/datum/vendor_crit/pop_head,
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
	/// How many credits does this vending machine have? 20% of all sales go to this pool, and are given freely when the machine is restocked, or successfully tilted. Lost on deconstruction.
	var/credits_contained = 0
	/**
	  * Is this item on station or not
	  *
	  * if it doesn't originate from off-station during mapload, all_products_free gets automatically set to TRUE if it was unset previously.
	  */
	var/onstation = TRUE
	/**
	 * DO NOT APPLY THIS GLOBALLY. For mapping var edits only.
	 * A variable to change on a per instance basis that allows the instance to avoid having onstation set for them during mapload.
	 * Setting this to TRUE means that the vending machine is treated as if it were still onstation if it spawns off-station during mapload.
	 * Useful to specify an off-station machine that will be affected by machine-brand intelligence for whatever reason.
	 */
	var/onstation_override = FALSE
	/**
	 * If this is set to TRUE, all products sold by the vending machine are free (cost nothing).
	 * If unset, this will get automatically set to TRUE during init if the machine originates from off-station during mapload.
	 * Defaults to null, set it to TRUE or FALSE explicitly on a per-machine basis if you want to force it to be a certain value.
	 */
	var/all_products_free
	/**
	 * If this is set to TRUE, the free item distribution process will not drop products, but the machine can still tilt.
	 * Otherwise, free buy works normally.
	 */
	var/vandal_secure = FALSE

/obj/machinery/vending/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат",
		GENITIVE = "торгового автомата",
		DATIVE = "торговому автомату",
		ACCUSATIVE = "торговый автомат",
		INSTRUMENTAL = "торговым автоматом",
		PREPOSITIONAL = "торговом автомате",
	)

/**
 * Initialize the vending machine
 *
 * Builds the vending machine inventory, sets up slogans and other such misc work
 *
 * This also sets the onstation var to:
 * * FALSE — if the machine was maploaded on a zlevel that doesn't pass the is_station_level check
 * * TRUE — all other cases
 */
/obj/machinery/vending/Initialize(mapload)
	. = ..()

	var/build_inv = FALSE
	if(!refill_canister)
		build_inv = TRUE
	else
		component_parts = list()
		var/obj/item/circuitboard/vendor/V = new
		V.set_type(initial(name))
		component_parts += V
		component_parts += new refill_canister
		RefreshParts()

	wires = new(src)

	if(build_inv) //non-constructable vending machine
		build_inventories()

	if(LAZYLEN(slogan_list))
		// So not all machines speak at the exact same time.
		// The first time this machine says something will be at slogantime + this random value,
		// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is created.
		last_slogan = world.time + rand(0, slogan_delay)

		// deleting "+" symbols which are used by TTS only.
		for(var/advertisement in slogan_list)
			ads_list += replacetext(advertisement, "+", "")

	if(mapload) //check if it was initially created off station during mapload.
		if(!is_station_level(z))
			if(!onstation_override)
				onstation = FALSE
				if(isnull(all_products_free)) // Only auto-set the free products var if we haven't explicitly assigned a value to it yet.
					all_products_free = TRUE
			var/obj/item/circuitboard/vendor/circuit = locate(/obj/item/circuitboard/vendor) in component_parts
			if(circuit)
				circuit.all_products_free = all_products_free //sync up the circuit so the pricing schema is carried over if it's reconstructed.

	if(!length(all_possible_crits))
		for(var/typepath in subtypesof(/datum/vendor_crit))
			all_possible_crits[typepath] = new typepath()

	AddElement( \
		/datum/element/falling_hazard, \
		damage = 80, \
		hardhat_safety = FALSE, \
		crushes = TRUE, \
		impact_sound = 'sound/effects/vending_hit.ogg', \
		)

	update_icon(UPDATE_OVERLAYS)

/obj/machinery/vending/click_alt(mob/user)
	if(!tilted)
		return NONE
	untilt(user)
	return CLICK_ACTION_SUCCESS

/obj/machinery/vending/Destroy()
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
	QDEL_NULL(inserted_item)
	QDEL_NULL(proximity_monitor)
	return ..()

/// Better would be to make constructable child
/obj/machinery/vending/RefreshParts()
	if(!component_parts)
		return

	build_products_from_categories()

	product_records = list()
	hidden_records = list()
	premium_records = list()

	build_inventories(start_empty = TRUE)

	for(var/obj/item/vending_refill/installed_refill in component_parts)
		restock(installed_refill)

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

/obj/machinery/vending/examine(mob/user)
	. = ..()
	if(tilted)
		. += span_warning("Он лежит на боку и не будет функционировать до тех пор, пока его не поднимут.")
		if(Adjacent(user))
			. += span_notice("Используйте <b>Alt+ЛКМ</b>, чтобы поднять автомат.")
	if(aggressive)
		. += span_warning("Его индикаторы зловеще мигают...")
	if(credits_contained < PAYCHECK_LOWER && credits_contained > 0)
		. += span_notice("Судя по объёму отсутствующих товаров, в отсеке для наличных должно быть <b>немного</b> кредитов.")
	else if(credits_contained >= PAYCHECK_LOWER)
		. += span_notice("Судя по объёму отсутствующих товаров, в отсеке для наличных должно быть <b>много</b> кредитов.")
		/**
		 * Intentionally leaving out a case for zero credits as it should be covered by the vending machine's stock being full,
		 * or covered by first case if items were returned.
		 */

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

/obj/machinery/vending/proc/create_proximity_monitor()
	proximity_monitor = new(src)

/obj/machinery/vending/proc/remove_proximity_monitor()
	QDEL_NULL(proximity_monitor)

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
 * Build the inventory of the vending machine from it's product and record lists
 *
 * This builds up a full set of /datum/data/vending_product from the product list of the vending machine type
 * Arguments:
 * * productlist - the list of products that need to be converted
 * * recordlist - the list containing /datum/data/vending_product datums
 * * categories - account list in the format of product_categories to source category from
 * * startempty - should we set vending_product record amount from the product list (so it's prefilled at roundstart)
 * * premium - Whether the ending products shall have premium or default prices
 */
/obj/machinery/vending/proc/build_inventory(list/productlist, list/recordlist, list/categories, start_empty = FALSE, premium = FALSE)
	var/list/product_to_category = list()
	for(var/list/category as anything in categories)
		var/list/products = category["products"]
		for(var/product_key in products)
			product_to_category[product_key] = category

	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		if(isnull(amount))
			amount = 0

		var/obj/item/item = new typepath(src)
		var/datum/data/vending_product/new_record = new /datum/data/vending_product()
		new_record.name = DECLENT_RU_CAP(item, NOMINATIVE)
		new_record.short_name = capitalize(item.get_short_name())
		new_record.desc = item.desc
		qdel(item)
		new_record.product_path = typepath
		if(!start_empty)
			new_record.amount = amount
		new_record.max_amount = amount

		var/custom_price = initial(item.custom_price)
		if(!premium)
			new_record.price = custom_price || default_price
		else
			var/custom_premium_price = initial(item.custom_premium_price)
			new_record.price = custom_premium_price || default_premium_price

		new_record.colorable = !!(item.greyscale_config && item.greyscale_colors)
		new_record.category = product_to_category[typepath]
		recordlist += new_record

/**
 * Builds all available inventories for the vendor - standard, contraband and premium
 * Arguments:
 * start_empty - bool to pass into build_inventory that determines whether a product entry starts with available stock or not
 */
/obj/machinery/vending/proc/build_inventories(start_empty)
	build_inventory(products, product_records, product_categories, start_empty)
	build_inventory(contraband, hidden_records, create_categories_from(CATEGORY_NAME_CONTRABAND, "mask", contraband), start_empty, premium = TRUE)
	build_inventory(premium, premium_records, create_categories_from(CATEGORY_NAME_PREMIUM, "star", premium), start_empty, premium = TRUE)

/**
 * Returns a list of data about the category
 * Arguments:
 * name - string for the name of the category
 * icon - string for the fontawesome icon to use in the UI for the category
 * products - list of products available in the category
 */
/obj/machinery/vending/proc/create_categories_from(name, icon, products)
	return list(list(
		"name" = name,
		"icon" = icon,
		"products" = products,
	))

/// Populates list of products with categorized products
/obj/machinery/vending/proc/build_products_from_categories()
	if(isnull(product_categories))
		return

	products = list()

	for(var/list/category in product_categories)
		var/list/category_products = category["products"]
		for(var/product_key in category_products)
			products[product_key] += category_products[product_key]

/**
 * Refill a vending machine from a refill canister
 *
 * This takes the products from the refill canister and then fills the products, contraband and premium product categories
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

	if(isnull(canister.product_categories) && !isnull(product_categories))
		canister.product_categories = product_categories.Copy()

	if(!isnull(canister.product_categories))
		var/list/products_unwrapped = list()
		for(var/list/category as anything in canister.product_categories)
			var/list/products = category["products"]
			for(var/product_key in products)
				products_unwrapped[product_key] += products[product_key]

		. += refill_inventory(products_unwrapped, product_records)
	else
		. += refill_inventory(canister.products, product_records)

	. += refill_inventory(canister.contraband, hidden_records)
	. += refill_inventory(canister.premium, premium_records)

	return .

/**
 * Refill our inventory from the passed in product list into the record list
 *
 * Arguments:
 * * productlist - list of types -> amount
 * * recordlist - existing record datums
 */
/obj/machinery/vending/proc/refill_inventory(list/productlist, list/recordlist)
	. = 0
	for(var/datum/data/vending_product/record as anything in recordlist)
		var/diff = min(record.max_amount - record.amount, productlist[record.product_path])
		if(diff)
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

	var/obj/item/vending_refill/installed_refill = locate() in component_parts
	if(!installed_refill)
		CRASH("Constructible vending machine did not have a refill canister")

	unbuild_inventory_into(product_records, installed_refill.products, installed_refill.product_categories)

	installed_refill.contraband = unbuild_inventory(hidden_records)
	installed_refill.premium = unbuild_inventory(premium_records)

/**
 * Given a record list, go through and and return a list of type -> amount
 */
/obj/machinery/vending/proc/unbuild_inventory(list/recordlist)
	. = list()
	for(var/datum/data/vending_product/record as anything in recordlist)
		.[record.product_path] += record.amount

/**
 * Unbuild product_records into categorized product lists to the machine's refill canister.
 * Does not handle contraband/premium products, only standard stock and any other categories used by the vendor(see: ClothesMate).
 * If a product has no category, puts it into standard stock category.
 * Arguments:
 * product_records - list of products of the vendor
 * products - list of products of the refill canister
 * product_categories - list of product categories of the refill canister
 */
/obj/machinery/vending/proc/unbuild_inventory_into(list/product_records, list/products, list/product_categories)
	products?.Cut()
	product_categories?.Cut()

	var/others_have_category = null

	var/list/categories_to_index = list()

	for(var/datum/data/vending_product/record as anything in product_records)
		var/list/category = record.category
		var/has_category = !isnull(category)

		if(!check_category_consistency(record, others_have_category, has_category))
			continue

		if(has_category)
			handle_categorized_product(record, product_categories, categories_to_index)
		else
			products[record.product_path] = record.amount

/obj/machinery/vending/proc/check_category_consistency(product_record, others_have_category, has_category)
	var/datum/data/vending_product/record = product_record
	if(isnull(others_have_category))
		return TRUE

	if(others_have_category == has_category)
		return TRUE

	if(has_category)
		WARNING("[record.product_path] in [type] has a category, but other products don't")
	else
		WARNING("[record.product_path] in [type] does not have a category, but other products do")

	return FALSE

/obj/machinery/vending/proc/handle_categorized_product(product_record, list/product_categories, list/categories_to_index)
	var/datum/data/vending_product/record = product_record
	var/list/category = record.category
	var/index = categories_to_index.Find(category)

	if(!index)
		categories_to_index += list(category)
		index = categories_to_index.len

		var/list/category_clone = category.Copy()
		category_clone["products"] = list("[record.product_path]" = record.amount)
		product_categories += list(category_clone)
	else
		var/list/category_in_list = product_categories[index]
		var/list/products_in_category = category_in_list["products"]
		products_in_category[record.product_path] += record.amount

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
			balloon_alert(user, "автомат опрокинут!")
			return ATTACK_CHAIN_BLOCKED_ALL
		return ..()

	if(istype(I, refill_canister))
		add_fingerprint(user)
		if(stat & (BROKEN|NOPOWER))
			balloon_alert(user, "автомат не работает!")
			return ATTACK_CHAIN_PROCEED
		if(!panel_open)
			balloon_alert(user, "техпанель открыта!")
			return ATTACK_CHAIN_PROCEED

		var/obj/item/vending_refill/canister = I
		if(canister.get_part_rating() == 0)
			balloon_alert(user, "набор пополнения пуст!")
			return ATTACK_CHAIN_PROCEED

		/// Instantiate canister if needed
		var/transferred = restock(canister)
		if(transferred)
			balloon_alert(user, "набор пополнения вставлен")
			return ATTACK_CHAIN_PROCEED_SUCCESS

		balloon_alert(user, "нечего пополнять!")
		return ATTACK_CHAIN_PROCEED

	if(item_slot_check(user, I))
		add_fingerprint(user)
		insert_item(user, I)
		return ATTACK_CHAIN_BLOCKED_ALL

	. = ..()
	try_tilt(I, user)

/obj/machinery/vending/proc/try_tilt(obj/item/I, mob/user)
	if(tiltable && !tilted && I.force)
		if(resistance_flags & INDESTRUCTIBLE)
			return // no goodies, but also no tilts
		if(COOLDOWN_FINISHED(src, last_hit_time))
			visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] странно покачивается..."))
			to_chat(user, span_userdanger("Кажется, что [declent_ru(NOMINATIVE)] так и норовит упасть!"))
			COOLDOWN_START(src, last_hit_time, hit_warning_cooldown_length)
			return

		switch(rand(1, 100))
			if(1 to 5)
				freebie(user, 3)
			if(6 to 15)
				freebie(user, 2)
			if(16 to 50)
				freebie(user, 1)
			if(50 to 75)
				return
			if(76 to 90)
				tilt(user)
			if(91 to 100)
				tilt(user, crit = TRUE)

/**
 * Dispenses free items from the standard stock.
 * Arguments:
 * freebies - number of free items to vend
 */
/obj/machinery/vending/proc/freebie(mob/user, num_freebies)
	if(vandal_secure)
		visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] дребезжит, но ничего не выдаёт!"))
		return

	visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] товар[declension_ru(num_freebies, "", "ы", "ы")] из своего ассортимента[credits_contained > 0 ? " и купюры" : ""]!"))

	for(var/i in 1 to num_freebies)
		playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
		for(var/datum/data/vending_product/record in shuffle(product_records))

			if(record.amount <= 0)
				continue
			var/dump_path = record.product_path
			if(!dump_path)
				continue
			new dump_path(get_turf(src))
			record.amount--
			break

	deploy_credits()

/obj/machinery/vending/HasProximity(atom/movable/movable)
	if(!aggressive || tilted || !tiltable)
		return

	if(!isliving(movable) || !prob(25))
		return

	movable.visible_message(
		span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] внезапно опрокидывается на [movable.declent_ru(ACCUSATIVE)]!"),
		span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] обрушивается на вас без предупреждения!")
	)
	tilt(movable, prob(5), FALSE)
	aggressive = FALSE
	remove_proximity_monitor()
	// Not making same mistakes as offs did.
	// Don't make this prob more than 5%

/obj/machinery/vending/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!component_parts)
		return
	default_deconstruction_crowbar(user, I)

/obj/machinery/vending/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(tilted)
		balloon_alert(user, "автомат опрокинут!")
		return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	default_unfasten_wrench(user, I, time = 60)

/obj/machinery/vending/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!anchored)
		balloon_alert(user, "автомат не прикручен!")
		return

	panel_open = !panel_open
	if(panel_open)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
	update_icon()
	SStgui.update_uis(src)

/obj/machinery/vending/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	wires.Interact(user)

/obj/machinery/vending/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(I.use_tool(src, user, 0, volume = 0))
		wires.Interact(user)

/obj/machinery/vending/ex_act(severity, target)
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

/// Override this proc to do per-machine checks on the inserted item, but remember to call the parent to handle these generic checks before your logic!
/obj/machinery/vending/proc/item_slot_check(mob/user, obj/item/I)
	if(!item_slot)
		return FALSE
	if(inserted_item)
		balloon_alert(user, "внутри уже что-то есть!")
		return FALSE
	return TRUE

/* Example override for item_slot_check proc:
/obj/machinery/vending/example/item_slot_check(mob/user, obj/item/I)
	if(!..())
		return FALSE
	if(!istype(I, /obj/item/toy))
		to_chat(user, span_warning("[I] isn't compatible with this machine's slot."))
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
		balloon_alert(user, "пополнено [moved] товар[DECL_CREDIT(moved)]")
		W.play_rped_sound()
	return TRUE

/obj/machinery/vending/on_deconstruction()
	update_canister()
	. = ..()

/obj/machinery/vending/proc/insert_item(mob/user, obj/item/I)
	if(!item_slot || inserted_item)
		return
	if(!user.drop_transfer_item_to_loc(I, src))
		to_chat(user, span_warning("[DECLENT_RU_CAP(I, NOMINATIVE)] будто бы приклеен[GEND_A_O_Y(I)] к вашей руке! Вы не можете [GEND_HIS_HER(I)] скинуть!"))
		return
	inserted_item = I
	balloon_alert(user, "предмет вставлен")
	to_chat(user, span_notice("Вы вставили [I.declent_ru(ACCUSATIVE)] в [declent_ru(GENITIVE)]."))
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
		balloon_alert(user, "взломано")

/obj/machinery/vending/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/vending/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/vending/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	if(tilted)
		balloon_alert(user, "не работает!")
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
		ui = new(user, src, "Vending", DECLENT_RU_CAP(src, NOMINATIVE))
		ui.open()

/obj/machinery/vending/ui_static_data(mob/user)
	var/list/data = list()
	if(ads_list.len)
		data["ad"] = ads_list[rand(1, ads_list.len)]

	data["all_products_free"] = all_products_free
	data["product_records"] = list()

	var/list/categories = list()

	data["product_records"] = collect_records_for_static_data(product_records, categories)
	data["premium_records"] = collect_records_for_static_data(premium_records, categories, premium = TRUE)
	data["hidden_records"] = collect_records_for_static_data(hidden_records, categories, hidden = TRUE)

	data["categories"] = categories

	return data

/obj/machinery/vending/proc/collect_records_for_static_data(list/records, list/categories, premium, hidden, index)
	var/static/list/default_category = list(
		"name" = CATEGORY_NAME_GENERIC,
		"icon" = "cart-shopping",
	)

	var/list/out_records = list()

	for(var/datum/data/vending_product/product_record as anything in records)
		var/obj/item/item = new product_record.product_path(src)
		var/list/static_record = list(
			path = replacetext(replacetext("[product_record.product_path]", "/obj/item/", ""), "/", "-"),
			name = DECLENT_RU_CAP(item, NOMINATIVE),
			short_name = capitalize(item.get_short_name()),
			desc = item.desc,
			colorable = product_record.colorable,
			price = product_record.price,
			ref = product_record.UID()
		)

		static_record["icon"] = initial(item.icon)
		static_record["icon_state"] = initial(item.icon_state)

		var/list/category = product_record.category || default_category
		if(!isnull(category))
			if(!(category["name"] in categories))
				categories[category["name"]] = list(
					"icon" = category["icon"],
				)

			static_record["category"] = category["name"]

		if(premium)
			static_record["req_coin"] = TRUE

		out_records += list(static_record)

	return out_records

/obj/machinery/vending/ui_data(mob/user)
	var/list/data = list()
	var/datum/money_account/money_account = null

	data["user"] = null
	if(ishuman(user))
		money_account = get_card_account(user)
		var/mob/living/carbon/human/H = user
		var/obj/item/card/id/id_card = H.get_id_card()
		var/obj/item/stack/spacecash/cash = H.get_active_hand()
		if(istype(money_account))
			data["user"] = list()
			data["user"]["name"] = money_account.owner_name
			data["user"]["cash"] = istype(cash) ? cash.amount : money_account.money
			data["user"]["job"] = (istype(id_card) && id_card.rank) ? id_card.rank : "Должность не определена"
	data["stock"] = list()
	for(var/datum/data/vending_product/product_record in product_records + premium_records + hidden_records)
		data["stock"][product_record.name] = product_record.amount
	data["extended_inventory"] = extended_inventory
	data["vend_ready"] = vend_ready
	data["panel_open"] = panel_open ? TRUE : FALSE
	data["speaker"] = shut_up ? FALSE : TRUE
	data["item_slot"] = item_slot // boolean
	data["inserted_item_name"] = inserted_item ? DECLENT_RU_CAP(inserted_item, NOMINATIVE) : FALSE

	if(prob(10) && ads_list.len)
		data["ad"] = ads_list[rand(1, ads_list.len)]

	return data

/obj/machinery/vending/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(issilicon(usr) && !isrobot(usr))
		to_chat(usr, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] отказывается взаимодействовать с вами, поскольку вы не входите в его целевую аудиторию!"))
		return
	switch(action)
		if("toggle_voice")
			if(panel_open)
				shut_up = !shut_up
				. = TRUE
		if("eject_item")
			eject_item(usr)
			. = TRUE

		if("select_colors")
			. = select_colors(params)

		if("vend")
			. = vend_action(params)

	if(.)
		add_fingerprint(usr)

/obj/machinery/vending/proc/can_vend(user)
	. = FALSE

	if(!vend_ready)
		balloon_alert(usr, "торговый автомат занят!")
		return

	if(panel_open)
		balloon_alert(usr, "техпанель открыта!")
		return

	return TRUE

/obj/machinery/vending/proc/select_colors(list/params)
	. = TRUE
	if(!can_vend(usr))
		return
	var/datum/data/vending_product/product = locateUID(params["ref"])
	var/atom/fake_atom = product.product_path

	var/list/allowed_configs = list()
	var/config = initial(fake_atom.greyscale_config)
	if(!config)
		return
	allowed_configs += "[config]"
	if(ispath(fake_atom, /obj/item))
		var/obj/item/item = new fake_atom(null)
		var/list/worn = item.greyscale_config_worn
		var/list/species = item.greyscale_config_worn_species

		for(var/new_config in worn)
			allowed_configs += "[worn[new_config]]"

		for(var/new_config in species)
			allowed_configs += "[species[new_config]]"

		if(initial(item.greyscale_config_inhand_left))
			allowed_configs += "[initial(item.greyscale_config_inhand_left)]"

		if(initial(item.greyscale_config_inhand_right))
			allowed_configs += "[initial(item.greyscale_config_inhand_right)]"
		qdel(item)

	var/datum/greyscale_modify_menu/menu = new(
		src, usr, allowed_configs, CALLBACK(src, PROC_REF(vend_greyscale), params),
		starting_icon_state=initial(fake_atom.icon_state),
		starting_config=initial(fake_atom.greyscale_config),
		starting_colors=initial(fake_atom.greyscale_colors)
	)
	menu.ui_interact(usr)

/obj/machinery/vending/proc/vend_greyscale(list/params, datum/greyscale_modify_menu/menu)
	if(usr != menu.user)
		return

	if(!menu.target.ui_status(usr) == UI_INTERACTIVE)
		return

	vend_action(params, menu.split_colors)

/obj/machinery/vending/proc/vend_action(list/params, list/greyscale_colors)
	if(!can_vend(usr))
		return

	var/list/records_to_check = product_records + premium_records
	if(extended_inventory)
		records_to_check = product_records + premium_records + hidden_records

	var/datum/data/vending_product/product_record = locateUID(params["ref"])

	if(!istype(product_record))
		to_chat(usr, span_warning("ОШИБКА: [declent_ru(NOMINATIVE)] содержит неизвестный товар. Сообщите о баге."))
		return
	if(!product_record || !product_record.product_path)
		to_chat(usr, span_warning("ОШИБКА: [declent_ru(NOMINATIVE)] содержит неизвестную позицию с товаром. Сообщите о баге."))
		return
	if(product_record in hidden_records)
		if(!extended_inventory)
			// Exploit prevention, stop the user purchasing hidden stuff if they haven't hacked the machine.
			to_chat(usr, span_warning("ОШИБКА: [declent_ru(NOMINATIVE)] не может расширить ассортимент в текущем состоянии. Сообщите о баге."))
			return
	else if(!(product_record in records_to_check))
		// Exploit prevention, stop the user
		message_admins("Vending machine exploit attempted by [ADMIN_LOOKUPFLW(usr)]!")
		return
	if(product_record.amount <= 0)
		to_chat(usr, "Товар \"[product_record.name]\" закончился!")
		flick_vendor_overlay(FLICK_VEND)
		return
	if(!allowed(usr) && !usr.can_admin_interact() && !emagged && scan_id)
		balloon_alert(usr, "в доступе отказано!")
		flick_vendor_overlay(FLICK_DENY)
		return

	vend_ready = FALSE // From this point onwards, vendor is locked to performing this transaction only, until it is resolved.

	if(!(ishuman(usr) || issilicon(usr)) || product_record.price <= 0 || all_products_free)
		// Either the purchaser is not human nor silicon, or the item is free.
		// Skip all payment logic.
		vend(product_record, usr)
		add_fingerprint(usr)
		vend_ready = TRUE
		. = TRUE
		return

	if(issilicon(usr))
		to_chat(usr, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] отказывается продавать вам товар, поскольку вы не входите в его целевую аудиторию!"))
		vend_ready = TRUE
		. = TRUE
		return

	// --- THE REST OF THIS PROC IS JUST PAYMENT LOGIC ---
	if(!GLOB.vendor_account || GLOB.vendor_account.suspended)
		to_chat(usr, "Удалённый сервер торговых автоматов отключён. Не удается обработать операцию.")
		flick_vendor_overlay(FLICK_DENY)
		vend_ready = TRUE
		return

	currently_vending = product_record
	var/paid = FALSE

	if(is_cash(usr.get_active_hand()))
		var/obj/item/stack/spacecash/cash = usr.get_active_hand()
		paid = pay_with_cash(cash, usr, currently_vending.price, currently_vending.name)
	else if(get_card_account(usr))
		// Because this uses H.get_id_card(), it will attempt to use:
		// active hand, inactive hand, wear_id, pda, and then w_uniform ID in that order
		// this is important because it lets people buy stuff with someone else's ID by holding it while using the vendor
		paid = pay_with_card(usr, currently_vending.price, currently_vending.name)
	else if(usr.can_advanced_admin_interact())
		to_chat(usr, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] выдаёт товар в результате вмешательства администратора."))
		paid = TRUE
	else
		to_chat(usr, span_warning("Сбой платежа: у вас нет ID-карты или другого способа оплаты."))
		vend_ready = TRUE
		flick_vendor_overlay(FLICK_DENY)
		. = TRUE // we set this because they shouldn't even be able to get this far, and we want the UI to update.
		return
	if(paid)
		credits_contained += round(currently_vending.price * VENDING_CREDITS_COLLECTION_AMOUNT)
		vend(currently_vending, usr)
		. = TRUE
	else
		to_chat(usr, span_warning("Сбой платежа: не удаётся обработать платеж."))
		vend_ready = TRUE

/obj/machinery/vending/proc/vend(datum/data/vending_product/product_record, mob/user, list/greyscale_colors)
	if(!allowed(user) && !user.can_admin_interact() && !emagged && scan_id)	//For SECURE VENDING MACHINES YEAH
		to_chat(user, span_warning("В доступе отказано!"))//Unless emagged of course
		flick_vendor_overlay(FLICK_DENY)
		vend_ready = TRUE
		return

	if(!product_record.amount)
		to_chat(user, span_warning("В [declent_ru(PREPOSITIONAL)] закончился выбранный товар."))
		vend_ready = TRUE
		return

	vend_ready = FALSE //One thing at a time!!

	product_record.amount--

	if(((last_reply + (vend_delay + 200)) <= world.time) && vend_reply)
		speak(src.vend_reply)
		last_reply = world.time

	use_power(vend_power_usage)	//actuators and stuff
	flick_vendor_overlay(FLICK_VEND)	//Show the vending animation if needed
	playsound(get_turf(src), 'sound/machines/machine_vend.ogg', 50, TRUE)
	addtimer(CALLBACK(src, PROC_REF(delayed_vend), product_record, user, greyscale_colors), vend_delay)

/obj/machinery/vending/proc/delayed_vend(datum/data/vending_product/product_record, mob/user, list/greyscale_colors)
	do_vend(product_record, user, greyscale_colors)
	vend_ready = TRUE
	currently_vending = null

/**
 * Override this proc to add handling for what to do with the vended product
 * when you have a inserted item and remember to include a parent call for this generic handling
 */
/obj/machinery/vending/proc/do_vend(datum/data/vending_product/product_record, mob/user, list/greyscale_colors)
	if(!item_slot || !inserted_item)
		var/put_on_turf = TRUE
		var/obj/item/vended = new product_record.product_path(drop_location())
		if(greyscale_colors)
			vended.set_greyscale_colors(greyscale_colors)
		if(istype(vended) && user && iscarbon(user) && user.Adjacent(src))
			if(user.put_in_hands(vended, ignore_anim = FALSE))
				put_on_turf = FALSE
		if(put_on_turf)
			var/turf/T = get_turf(src)
			vended.forceMove(T)
		return TRUE
	return FALSE

/* Example override for do_vend proc:
/obj/machinery/vending/example/do_vend(datum/data/vending_product/product_record)
	if(..())
		return
	var/obj/item/vended = new product_record.product_path()
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

	// Pitch to the people! Really sell it!
	if(((last_slogan + src.slogan_delay) <= world.time) && (LAZYLEN(slogan_list)) && (!shut_up) && prob(10))
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

	atom_say(message, use_tts = FALSE)

/obj/machinery/vending/obj_break(damage_flag)
	if(stat & BROKEN)
		return

	stat |= BROKEN
	update_icon(UPDATE_OVERLAYS)

	if(vandal_secure)
		return

	var/dump_amount = 0
	var/found_anything = TRUE
	while(found_anything)
		found_anything = FALSE
		for(var/record in shuffle(product_records))
			var/datum/data/vending_product/product_record = record
			if(product_record.amount <= 0) //Try to use a record that actually has something to dump.
				continue
			var/dump_path = product_record.product_path
			if(!dump_path)
				continue
			product_record.amount--
			// busting open a vendor will destroy some of the contents
			if(found_anything && prob(80))
				continue

			var/obj/O = new dump_path(loc)
			step(O, pick(GLOB.alldirs))
			found_anything = TRUE
			dump_amount++
			if(dump_amount >= 16)
				return

/**
 * Drop credits when the vendor is attacked.
 */
/obj/machinery/vending/proc/deploy_credits()
	if(credits_contained <= 0)
		return ""

	var/credits_to_remove = min(CREDITS_DUMP_THRESHOLD, round(credits_contained))
	var/obj/item/stack/spacecash/cash = new(loc)
	cash.amount = credits_to_remove
	credits_contained = max(0, credits_contained - credits_to_remove)

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7, src)
	if(!target)
		return 0

	for(var/datum/data/vending_product/product_record in product_records)
		if(product_record.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		if(product_record.price > 0) // Don't try not free item
			continue
		var/dump_path = product_record.product_path
		if(!dump_path)
			continue

		product_record.amount--
		throw_item = new dump_path(loc)
		break
	if(!throw_item)
		return
	throw_item.throw_at(target, 16, 3)
	visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] метнул [throw_item.declent_ru(ACCUSATIVE)] в [target]!"))

/obj/machinery/vending/shove_impact(mob/living/target, mob/living/attacker)
	if(HAS_TRAIT(target, TRAIT_FLATTENED))
		return
	if(!HAS_TRAIT(attacker, TRAIT_PACIFISM) || !GLOB.pacifism_after_gt)
		add_attack_logs(attacker, target, "shoved into a vending machine ([src])")
		tilt(target, from_combat = TRUE)
		target.visible_message(
			span_danger("[attacker] толка[PLUR_ET_YUT(attacker)] [target] в [declent_ru(ACCUSATIVE)]!"),
			span_userdanger("[attacker] впечатыва[PLUR_ET_YUT(attacker)] вас в [declent_ru(ACCUSATIVE)]!"),
			span_danger("Вы слышите громкий хруст.")
		)
	else
		attacker.visible_message(
			span_notice("[attacker] слегка прижима[PLUR_ET_YUT(attacker)] [target] к [declent_ru(DATIVE)]."),
			span_userdanger("Вы слегка прижимаете [target] к [declent_ru(DATIVE)], вы же не хотите причинить [GEND_HIM_HER(target)] боль!")
			)
	return TRUE

/**
 * Select a random valid crit.
 */
/obj/machinery/vending/proc/choose_crit(mob/living/carbon/victim)
	if(!length(possible_crits))
		return
	for(var/crit_path in shuffle(possible_crits))
		var/datum/vendor_crit/crit_type = all_possible_crits[crit_path]
		if(crit_type.is_valid(src, victim))
			return crit_type

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
			span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] давит [victim]!"),
			span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] давит вас!"),
			span_warning("Вы слышите громкий хруст!")
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
	if(QDELETED(src) || no_gravity(src) || !tiltable || tilted)
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
		var/was_alive = (victim.stat != DEAD)
		var/client/victim_client = victim.client
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
				span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] давит [victim]!"),
				span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] давит вас!"),
				span_warning("Вы слышите громкий хруст!")
			)
			victim.apply_damage(damage_to_deal, BRUTE)
			add_attack_logs(null, victim, "crushed by [src]")

		. = TRUE
		victim.Weaken(4 SECONDS)
		victim.Knockdown(8 SECONDS)
		if(was_alive && victim.stat == DEAD && victim_client)
			victim_client.give_award(/datum/award/achievement/misc/vendor_squish, victim) // good job losing a fight with an inanimate object idiot

		playsound(victim, 'sound/effects/blobattack.ogg', 40, TRUE)
		playsound(victim, 'sound/effects/splat.ogg', 50, TRUE)

		tilt_over(should_throw_at_target ? target_atom : null)

/obj/machinery/vending/proc/tilt_over(mob/victim)
	visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] опрокидывается!"))
	playsound(src, 'sound/effects/bang.ogg', 100, TRUE)
	var/picked_rotation = pick(90, 270)
	tilted_rotation = picked_rotation
	var/matrix/to_turn = turn(transform, tilted_rotation)
	animate(src, transform = to_turn, 0.2 SECONDS)

	if(victim && get_turf(victim) != get_turf(src))
		throw_at(get_turf(victim), 1, 1, spin = FALSE)
		SStgui.close_uis(wires)

/obj/machinery/vending/proc/untilt(mob/user)
	if(!tilted)
		return

	if(user)
		user.visible_message(
			"[user] начинает поднимать [declent_ru(ACCUSATIVE)].",
			"Вы начинаете поднимать [declent_ru(ACCUSATIVE)]."
		)
		if(!do_after(user, 7 SECONDS, src, max_interact_count = 1, cancel_on_max = TRUE))
			return
		user.visible_message(
			span_notice("[user] поднима[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы поднимаете [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы слышите громкий лязг.")
		)
	if(!tilted) //Sanity check
		return

	unbuckle_all_mobs(TRUE)

	tilted = FALSE
	layer = initial(layer)

	var/matrix/to_turn = turn(transform, -tilted_rotation)
	animate(src, transform = to_turn, 0.2 SECONDS)

#undef FLICK_NONE
#undef FLICK_VEND
#undef FLICK_DENY

#undef VENDOR_CRUSH_HANDLED
#undef VENDOR_THROW_AT_TARGET
#undef VENDOR_TIP_IN_PLACE
