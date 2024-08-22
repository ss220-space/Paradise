/**
  * # Smart Fridge
  *
  * Stores items of a specified type.
  */
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "smartfridge"
	layer = 2.9
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	/// The maximum number of items the fridge can hold. Multiplicated by the matter bin component's rating.
	var/max_n_of_items = 1500
	/// Associative list (/text => /number) tracking the amounts of a specific item held by the fridge.
	var/list/item_quants
	/// How long in ticks the fridge is electrified for. Decrements every process.
	var/seconds_electrified = 0
	/// Whether the fridge should randomly shoot held items at a nearby living target or not.
	var/shoot_inventory = FALSE
	/// Whether the fridge requires ID scanning. Used for the secure variant of the fridge.
	var/scan_id = TRUE
	/// Whether the fridge is considered secure. Used for wiring and display.
	var/is_secure = FALSE
	/// Whether the fridge can dry its' contents. Used for display.
	var/can_dry = FALSE
	/// Whether the fridge is currently drying. Used by [drying racks][/obj/machinery/smartfridge/drying_rack].
	var/drying = FALSE
	/// Whether the fridge's contents are visible on the world icon.
	var/visible_contents = TRUE
	/// The wires controlling the fridge.
	var/datum/wires/smartfridge/wires
	/// Typecache of accepted item types, init it in [/obj/machinery/smartfridge/Initialize].
	var/list/accepted_items_typecache
	/// Associative list (/obj/item => /number) representing the items the fridge should initially contain.
	var/list/starting_items
	/// Overlay used to visualize contents for default smartfringe.
	var/contents_overlay = "smartfridge"
	/// Overlay used to visualize broken status.
	var/broken_overlay = "smartfridge_broken"
	/// Additional overlay on top, like hazard symbol for smartfringe in virology.
	var/icon_addon
	/// Used to calculate smartfridge fullness while updating overlays.
	var/fill_level
	/// Lightmask used for emissive appearance if smartfringe has a light source.
	var/icon_lightmask = "smartfridge"
	/// Default light range, when on.
	var/light_range_on = 1
	/// Default light power, when on.
	var/light_power_on = 0.5


/obj/machinery/smartfridge/Initialize(mapload)
	. = ..()
	item_quants = list()
	// Reagents
	create_reagents()
	reagents.set_reacting(FALSE)
	// Components
	component_parts = list()
	var/obj/item/circuitboard/smartfridge/board = new(null)
	board.set_type(null, type)
	component_parts += board
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	RefreshParts()
	// Wires
	if(is_secure)
		wires = new/datum/wires/smartfridge/secure(src)
	else
		wires = new/datum/wires/smartfridge(src)
	//Add starting items
	if(mapload && starting_items)
		for(var/typekey in starting_items)
			var/amount = starting_items[typekey] || 1
			while(amount--)
				var/obj/item/newitem = new typekey(src)
				item_quants[newitem.name] += 1
	update_icon(UPDATE_OVERLAYS)
	// Accepted items
	accepted_items_typecache = typecacheof(list(
		/obj/item/reagent_containers/food/snacks/grown,
		/obj/item/seeds,
		/obj/item/grown,
		/obj/item/slimepotion,
	))

/obj/machinery/smartfridge/RefreshParts()
	max_n_of_items = 0
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_n_of_items += 1500 * B.rating

/obj/machinery/smartfridge/Destroy()
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
	for(var/atom/movable/A in contents)
		A.forceMove(loc)
	return ..()

/obj/machinery/smartfridge/process()
	if(stat & (BROKEN|NOPOWER))
		return
	if(seconds_electrified > 0)
		seconds_electrified--
	if(shoot_inventory && prob(2))
		throw_item()


/obj/machinery/smartfridge/extinguish_light(force = FALSE)
	set_light_on(FALSE)
	underlays.Cut()


/obj/machinery/smartfridge/obj_break(damage_flag)
	..()
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/smartfridge/power_change()
	. = ..()
	if(stat & NOPOWER)
		set_light_on(FALSE)
	else
		set_light(light_range_on, light_power_on, l_on = TRUE)
	if(.)
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/smartfridge/update_overlays()
	. = ..()
	underlays.Cut()
	if(panel_open)
		. += "[icon_state]_panel"
	if(stat & (BROKEN|NOPOWER))
		. += "[icon_state]_off"
		if(icon_addon)
			. += "[icon_addon]"
		if(stat & BROKEN)
			. += "[broken_overlay]"
		return
	if(visible_contents)
		update_fridge_contents()
		if(fill_level)
			. += "[contents_overlay][fill_level]"
	if(icon_addon)
		. += "[icon_addon]"
	if(icon_lightmask && light)
		underlays += emissive_appearance(icon, "[icon_lightmask]_lightmask", src)


/obj/machinery/smartfridge/proc/update_fridge_contents()
	switch(length(contents))
		if(0)
			fill_level = null
		if(1 to 25)
			fill_level = 1
		if(26 to 75)
			fill_level = 2
		if(76 to INFINITY)
			fill_level = 3

//// broken smartfridge for decorations
/obj/machinery/smartfridge/broken

/obj/machinery/smartfridge/broken/Initialize(mapload)
	. = ..()
	stat = BROKEN
	update_icon(UPDATE_OVERLAYS)

// Interactions
/obj/machinery/smartfridge/screwdriver_act(mob/living/user, obj/item/I)
	. = default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	if(!.)
		return
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/smartfridge/wrench_act(mob/living/user, obj/item/I)
	. = default_unfasten_wrench(user, I)
	if(.)
		power_change()

/obj/machinery/smartfridge/crowbar_act(mob/living/user, obj/item/I)
	. = default_deconstruction_crowbar(user, I)

/obj/machinery/smartfridge/wirecutter_act(mob/living/user, obj/item/I)
	if(panel_open)
		attack_hand(user)
		return TRUE
	return ..()

/obj/machinery/smartfridge/multitool_act(mob/living/user, obj/item/I)
	if(panel_open)
		attack_hand(user)
		return TRUE
	return ..()


/obj/machinery/smartfridge/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/emag))
		to_chat(user, span_notice("The [name] smartly refuses [I]."))
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK

	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		SStgui.update_uis(src)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		to_chat(user, span_warning("The [name] is unpowered or broken."))
		return ATTACK_CHAIN_PROCEED

	if(load(I, user))
		user.visible_message(
			span_notice("[user] has added [I] into [src]."),
			span_notice("You have added [I] into [src]."),
		)
		SStgui.update_uis(src)
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/storage/bag) || istype(I, /obj/item/storage/box))
		var/obj/item/storage/storage = I
		var/items_loaded = 0
		for(var/obj/item/thing as anything in storage.contents)
			if(load(thing, user))
				thing.add_fingerprint(user)
				items_loaded++
		if(items_loaded)
			user.visible_message(
				span_notice("[user] has loaded [src] with [storage]."),
				span_notice("You have loaded [src] with [storage]."),
			)
			SStgui.update_uis(src)
			update_icon(UPDATE_OVERLAYS)
		var/failed = length(storage.contents)
		if(failed)
			to_chat(user, span_notice("[failed] item\s [failed == 1 ? "is" : "are"] refused."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	to_chat(user, span_warning("You cannot put [I] into [src]."))
	return ATTACK_CHAIN_PROCEED


/obj/machinery/smartfridge/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/smartfridge/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	wires.Interact(user)
	ui_interact(user)
	return ..()

//Drag pill bottle to fridge to empty it into the fridge
/obj/machinery/smartfridge/MouseDrop_T(obj/over_object, mob/user, params)
	if(!ishuman(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return TRUE
	if(!istype(over_object, /obj/item/storage/pill_bottle)) //Only pill bottles, please
		return TRUE
	if(stat & (BROKEN|NOPOWER))
		to_chat(user, "<span class='notice'>\The [src] is unpowered and useless.</span>")
		return TRUE

	var/obj/item/storage/box/pillbottles/P = over_object
	if(!length(P.contents))
		to_chat(user, "<span class='notice'>\The [P] is empty.</span>")
		return TRUE

	add_fingerprint(user)
	var/items_loaded = 0
	for(var/obj/G in P.contents)
		if(load(G, user))
			G.add_fingerprint(user)
			items_loaded++
	if(items_loaded)
		user.visible_message("<span class='notice'>[user] empties \the [P] into \the [src].</span>", "<span class='notice'>You empty \the [P] into \the [src].</span>")
		update_icon(UPDATE_OVERLAYS)
	var/failed = length(P.contents)
	if(failed)
		to_chat(user, "<span class='notice'>[failed] item\s [failed == 1 ? "is" : "are"] refused.</span>")
	return TRUE

/obj/machinery/smartfridge/ui_interact(mob/user, datum/tgui/ui = null)
	user.set_machine(src)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smartfridge", name)
		ui.open()

/obj/machinery/smartfridge/ui_data(mob/user)
	var/list/data = list()

	data["contents"] = null
	data["secure"] = is_secure
	data["can_dry"] = can_dry
	data["drying"] = drying

	var/list/items = list()
	for(var/i in 1 to length(item_quants))
		var/K = item_quants[i]
		var/count = item_quants[K]
		if(count > 0)
			items.Add(list(list("display_name" = html_encode(capitalize(K)), "vend" = i, "quantity" = count)))

	if(length(items))
		data["contents"] = items

	return data

/obj/machinery/smartfridge/ui_act(action, params)
	if(..())
		return

	. = TRUE

	var/mob/user = usr

	add_fingerprint(user)

	switch(action)
		if("vend")
			if(is_secure && !emagged && scan_id && !allowed(usr)) //secure fridge check
				to_chat(usr, "<span class='warning'>Access denied.</span>")
				return FALSE

			var/index = text2num(params["index"])
			var/amount = text2num(params["amount"])
			if(isnull(index) || !ISINDEXSAFE(item_quants, index) || isnull(amount))
				return FALSE
			var/K = item_quants[index]
			var/count = item_quants[K]
			if(count == 0) // Sanity check, there are probably ways to press the button when it shouldn't be possible.
				return FALSE

			item_quants[K] = max(count - amount, 0)

			var/i = amount
			if(i <= 0)
				return
			if(i == 1 && Adjacent(user) && !issilicon(user))
				for(var/obj/O in contents)
					if(O.name == K)
						O.forceMove(get_turf(src))
						adjust_item_drop_location(O)
						user.put_in_hands(O, ignore_anim = FALSE)
						update_icon(UPDATE_OVERLAYS)
						break
			else
				for(var/obj/O in contents)
					if(O.name == K)
						O.forceMove(loc)
						adjust_item_drop_location(O)
						update_icon(UPDATE_OVERLAYS)
						i--
						if(i <= 0)
							return TRUE


/**
  * Tries to load an item if it is accepted by [/obj/machinery/smartfridge/proc/accept_check].
  *
  * Arguments:
  * * I - The item to load.
  * * user - The user trying to load the item.
  */
/obj/machinery/smartfridge/proc/load(obj/item/I, mob/user)
	if(!accept_check(I))
		return FALSE

	if(length(contents) >= max_n_of_items)
		to_chat(user, span_notice("The [name] is full."))
		return FALSE

	if(isstorage(I.loc))
		var/obj/item/storage/storage = I.loc
		if(user)
			storage.remove_from_storage(I, user.drop_location())
			I.do_pickup_animation(src)
			I.forceMove(src)
		else
			storage.remove_from_storage(I, src)

	else if(ismob(I.loc))
		var/mob/holder = I.loc
		if(!holder.drop_transfer_item_to_loc(I, src))
			return FALSE

	else
		I.forceMove(src)

	item_quants[I.name] += 1
	return TRUE


/**
  * Tries to shoot a random at a nearby living mob.
  */
/obj/machinery/smartfridge/proc/throw_item()
	var/obj/item/throw_item = null
	var/mob/living/target = locate() in view(7, src)
	if(!target)
		return FALSE

	for(var/O in item_quants)
		if(item_quants[O] <= 0) //Try to use a record that actually has something to dump.
			continue
		item_quants[O]--
		for(var/obj/I in contents)
			if(I.name == O)
				I.forceMove(loc)
				throw_item = I
				update_icon(UPDATE_OVERLAYS)
				break
	if(!throw_item)
		return FALSE

	INVOKE_ASYNC(throw_item, TYPE_PROC_REF(/atom/movable, throw_at), target, 16, 3, src)
	visible_message("<span class='warning'>[src] launches [throw_item.name] at [target.name]!</span>")
	return TRUE

/**
  * Returns whether the smart fridge can accept the given item.
  *
  * By default checks if the item is in [the typecache][/obj/machinery/smartfridge/var/accepted_items_typecache].
  * Arguments:
  * * O - The item to check.
  */
/obj/machinery/smartfridge/proc/accept_check(obj/item/I)
	return is_type_in_typecache(I, accepted_items_typecache)

/**
  * # Syndie Fridge
  */
/obj/machinery/smartfridge/syndie
	name = "\improper Suspicious SmartFridge"
	icon_state = "smartfridge-syndie"
	contents_overlay = "smartfridge-syndie"


/**
  * # Secure Fridge
  *
  * Secure variant of the [Smart Fridge][/obj/machinery/smartfridge].
  * Can be emagged and EMP'd to short the lock.
  */
/obj/machinery/smartfridge/secure
	is_secure = TRUE

/obj/machinery/smartfridge/secure/emag_act(mob/user)
	emagged = TRUE
	if(user)
		to_chat(user, "<span class='notice'>You short out the product lock on \the [src].</span>")

/obj/machinery/smartfridge/secure/emp_act(severity)
	if(!emagged && prob(40 / severity))
		playsound(loc, 'sound/effects/sparks4.ogg', 60, TRUE)
		emagged = TRUE

/**
  * # Seed Storage
  *
  * Seeds variant of the [Smart Fridge][/obj/machinery/smartfridge].
  * Formerly known as MegaSeed Servitor, but renamed to avoid confusion with the [vending machine][/obj/machinery/vending/hydroseeds].
  */
/obj/machinery/smartfridge/seeds
	name = "\improper Seed Storage"
	desc = "When you need seeds fast!"
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "seeds_off"
	base_icon_state = "seeds"


/obj/machinery/smartfridge/seeds/Initialize(mapload)
	. = ..()
	accepted_items_typecache = typecacheof(list(
		/obj/item/seeds
	))


/obj/machinery/smartfridge/seeds/update_overlays()
	. = list()

	underlays.Cut()

	if(panel_open)
		. += "[base_icon_state]_panel"

	if((stat & NOPOWER))
		if(stat & BROKEN)
			. += "[base_icon_state]_broken"
		return

	if(stat & BROKEN)
		. += "[base_icon_state]_broken"
		underlays += emissive_appearance(icon, "[base_icon_state]_broken_lightmask", src)
	else
		. += base_icon_state
		underlays += emissive_appearance(icon, "[base_icon_state]_lightmask", src)


/**
  * # Refrigerated Medicine Storage
  *
  * Medical variant of the [Smart Fridge][/obj/machinery/smartfridge].
  */
/obj/machinery/smartfridge/medbay
	name = "\improper Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	icon_state = "smartfridge" //To fix the icon in the map editor.

/obj/machinery/smartfridge/medbay/Initialize(mapload)
	. = ..()
	accepted_items_typecache = typecacheof(list(
		/obj/item/reagent_containers/glass,
		/obj/item/reagent_containers/iv_bag,
		/obj/item/reagent_containers/applicator,
		/obj/item/storage/pill_bottle,
		/obj/item/reagent_containers/food/pill,
	))

/obj/machinery/smartfridge/medbay/syndie
	icon_state = "smartfridge-syndie"
	contents_overlay = "smartfridge-syndie"


/**
  * # Slime Extract Storage
  *
  * Secure, Xenobiology variant of the [Smart Fridge][/obj/machinery/smartfridge].
  */
/obj/machinery/smartfridge/secure/extract
	name = "\improper Slime Extract Storage"
	desc = "A refrigerated storage unit for slime extracts"
	req_access = list(ACCESS_RESEARCH)

/obj/machinery/smartfridge/secure/extract/syndie
	name = "\improper Suspicious Slime Extract Storage"
	desc = "A refrigerated storage unit for slime extracts"
	icon_state = "smartfridge-syndie"
	contents_overlay = "smartfridge-syndie"

/obj/machinery/smartfridge/secure/extract/Initialize(mapload)
	. = ..()
	if(is_taipan(z)) // Синдидоступ при сборке на тайпане
		req_access = list(ACCESS_SYNDICATE)
	accepted_items_typecache = typecacheof(list(
		/obj/item/slime_extract
	))

/**
  * # Secure Refrigerated Medicine Storage
  *
  * Secure, Medical variant of the [Smart Fridge][/obj/machinery/smartfridge].
  */
/obj/machinery/smartfridge/secure/medbay
	name = "\improper Secure Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	icon_state = "smartfridge" //To fix the icon in the map editor.
	req_access = list(ACCESS_MEDICAL, ACCESS_CHEMISTRY)

/obj/machinery/smartfridge/secure/medbay/Initialize(mapload)
	. = ..()
	accepted_items_typecache = typecacheof(list(
		/obj/item/reagent_containers/glass,
		/obj/item/reagent_containers/iv_bag,
		/obj/item/reagent_containers/applicator,
		/obj/item/storage/pill_bottle,
		/obj/item/reagent_containers/food/pill,
	))

/obj/machinery/smartfridge/secure/medbay/syndie
	icon_state = "smartfridge-syndie"
	contents_overlay = "smartfridge-syndie"
	req_access = list(ACCESS_SYNDICATE)

/**
  * # Smart Chemical Storage
  *
  * Secure, Chemistry variant of the [Smart Fridge][/obj/machinery/smartfridge].
  */
/obj/machinery/smartfridge/secure/chemistry
	name = "\improper Smart Chemical Storage"
	desc = "A refrigerated storage unit for medicine and chemical storage."
	icon_state = "smartfridge" //To fix the icon in the map editor.
	req_access = list(ACCESS_CHEMISTRY)


/obj/machinery/smartfridge/secure/chemistry/Initialize(mapload)
	. = ..()
	// Accepted items
	accepted_items_typecache = typecacheof(list(
		/obj/item/storage/pill_bottle,
		/obj/item/reagent_containers,
	))

/**
  * # Smart Chemical Storage (Preloaded)
  *
  * A [Smart Chemical Storage][/obj/machinery/smartfridge/secure/chemistry] but with some items already in.
  */
/obj/machinery/smartfridge/secure/chemistry/preloaded
	// I exist!

/obj/machinery/smartfridge/secure/chemistry/preloaded/Initialize(mapload)
	starting_items = list(
		/obj/item/reagent_containers/food/pill/epinephrine = 12,
		/obj/item/reagent_containers/food/pill/charcoal = 5,
		/obj/item/reagent_containers/glass/bottle/epinephrine = 1,
		/obj/item/reagent_containers/glass/bottle/charcoal = 1,
	)
	. = ..()

/**
  * # Smart Chemical Storage (Preloaded, Syndicate)
  *
  * A [Smart Chemical Storage (Preloaded)][/obj/machinery/smartfridge/secure/chemistry/preloaded] but with exclusive access to Syndicate.
  */
/obj/machinery/smartfridge/secure/chemistry/preloaded/syndicate
	req_access = list(ACCESS_SYNDICATE)
	icon_state = "smartfridge-syndie"
	contents_overlay = "smartfridge-syndie"


/obj/machinery/smartfridge/secure/medbay/organ
	req_access = list(ACCESS_SURGERY)
	name = "\improper Secure Refrigerated Organ Storage"
	desc = "A refrigerated storage unit for storing organs, limbs, implants and IV bags."
	opacity = TRUE
	contents_overlay = "smartfridge-organ"


/obj/machinery/smartfridge/secure/medbay/organ/Initialize(mapload)
	. = ..()
	accepted_items_typecache = typecacheof(list(
		/obj/item/organ,
		/obj/item/reagent_containers/iv_bag,
		/obj/item/robot_parts/l_arm,
		/obj/item/robot_parts/r_arm,
		/obj/item/robot_parts/l_leg,
		/obj/item/robot_parts/r_leg,
	))


/**
  * # Disk Compartmentalizer
  *
  * Disk variant of the [Smart Fridge][/obj/machinery/smartfridge].
  */
/obj/machinery/smartfridge/disks
	name = "disk compartmentalizer"
	desc = "A machine capable of storing a variety of disks. Denoted by most as the DSU (disk storage unit)."
	icon_state = "disktoaster_off"
	base_icon_state = "disktoaster"
	pass_flags = PASSTABLE
	visible_contents = FALSE
	icon_lightmask = "disktoaster"


/obj/machinery/smartfridge/disks/Initialize(mapload)
	. = ..()
	accepted_items_typecache = typecacheof(list(
		/obj/item/disk,
	))


/obj/machinery/smartfridge/disks/update_overlays()
	. = list()
	underlays.Cut()
	if(panel_open)
		. += "[base_icon_state]_panel"
	if(stat & (BROKEN|NOPOWER))
		if(stat & BROKEN)
			. += "[icon_state]_broken"
		return
	. += "[base_icon_state]"
	if(icon_lightmask && light)
		underlays += emissive_appearance(icon, "[icon_lightmask]_lightmask", src)


/**
  * # Smart Virus Storage
  *
  * Secure, Virology variant of the [Smart Chemical Storage][/obj/machinery/smartfridge/secure/chemistry].
  * Comes with some items.
  */
/obj/machinery/smartfridge/secure/chemistry/virology
	name = "\improper Smart Virus Storage"
	desc = "A refrigerated storage unit for volatile sample storage."
	icon_state = "smartfridge"
	req_access = list(ACCESS_VIROLOGY)
	icon_addon = "smartfridge-viro-overlay"

/obj/machinery/smartfridge/secure/chemistry/virology/Initialize(mapload)
	. = ..()
	accepted_items_typecache = typecacheof(list(
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/beaker,
	))


/**
  * # Smart Virus Storage (Preloaded)
  *
  * A [Smart Virus Storage][/obj/machinery/smartfridge/secure/chemistry/virology] but with some additional items.
  */
/obj/machinery/smartfridge/secure/chemistry/virology/preloaded
	// I exist!

/obj/machinery/smartfridge/secure/chemistry/virology/preloaded/Initialize(mapload)
	starting_items = list(
		/obj/item/reagent_containers/syringe/antiviral = 4,
		/obj/item/reagent_containers/glass/bottle/cold = 1,
		/obj/item/reagent_containers/glass/bottle/flu = 1,
		/obj/item/reagent_containers/glass/bottle/sneezing = 1,
		/obj/item/reagent_containers/glass/bottle/cough = 1,
		/obj/item/reagent_containers/glass/bottle/mutagen = 1,
		/obj/item/reagent_containers/glass/bottle/plasma = 1,
		/obj/item/reagent_containers/glass/bottle/diphenhydramine = 1
	)
	. = ..()

/**
  * # Smart Virus Storage (Preloaded, Syndicate)
  *
  * A [Smart Virus Storage (Preloaded)][/obj/machinery/smartfridge/secure/chemistry/virology/preloaded] but with exclusive access to Syndicate.
  */
/obj/machinery/smartfridge/secure/chemistry/virology/preloaded/syndicate
	icon_state = "smartfridge-syndie"
	contents_overlay = "smartfridge-syndie"
	req_access = list(ACCESS_SYNDICATE)


/**
  * # Drink Showcase
  *
  * Drink variant of the [Smart Fridge][/obj/machinery/smartfridge].
  */
/obj/machinery/smartfridge/drinks
	name = "\improper Drink Showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."

/obj/machinery/smartfridge/drinks/Initialize(mapload)
	. = ..()
	accepted_items_typecache = typecacheof(list(
		/obj/item/reagent_containers/glass,
		/obj/item/reagent_containers/food/drinks,
		/obj/item/reagent_containers/food/condiment,
	))

/**
  * # Dish Showcase
  *
  * Dish variant of the [Smart Fridge][/obj/machinery/smartfridge].
  */
/obj/machinery/smartfridge/dish
	name = "\improper Dish Showcase"
	desc = "A refrigerated storage unit for some delicious food."

/obj/machinery/smartfridge/dish/Initialize(mapload)
	. = ..()
	accepted_items_typecache = typecacheof(list(
		/obj/item/reagent_containers/food/condiment,
		/obj/item/kitchen,
		/obj/item/reagent_containers/glass,
		/obj/item/reagent_containers/food,
	))

/**
  * # Drying Rack
  *
  * Variant of the [Smart Fridge][/obj/machinery/smartfridge] for drying stuff.
  * Doesn't have components.
  */
/obj/machinery/smartfridge/drying_rack
	name = "drying rack"
	desc = "A wooden contraption, used to dry plant products, food and leather."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "drying-rack_off"
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 200
	can_dry = TRUE
	visible_contents = FALSE
	icon_lightmask = null

/obj/machinery/smartfridge/drying_rack/Initialize(mapload)
	. = ..()
	// Remove components, this is wood duh
	QDEL_LIST(component_parts)
	component_parts = null
	// Accepted items
	accepted_items_typecache = typecacheof(list(
		/obj/item/reagent_containers/food/snacks,
		/obj/item/stack/sheet/wetleather,
	))

/obj/machinery/smartfridge/drying_rack/on_deconstruction()
	new /obj/item/stack/sheet/wood(loc, 10)
	..()

/obj/machinery/smartfridge/drying_rack/RefreshParts()
	return

/obj/machinery/smartfridge/drying_rack/power_change(forced = FALSE)
	if(powered() && anchored)
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
		toggle_drying(forceoff =TRUE)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/smartfridge/drying_rack/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/machinery/smartfridge/drying_rack/exchange_parts()
	return

/obj/machinery/smartfridge/drying_rack/spawn_frame()
	return

/obj/machinery/smartfridge/drying_rack/crowbar_act(mob/living/user, obj/item/I)
	. = default_deconstruction_crowbar(user, I, TRUE)

/obj/machinery/smartfridge/drying_rack/emp_act(severity)
	..()
	atmos_spawn_air(LINDA_SPAWN_HEAT)

/obj/machinery/smartfridge/drying_rack/ui_act(action, params)
	. = ..()

	switch(action)
		if("drying")
			drying = !drying
			use_power = drying ? ACTIVE_POWER_USE : IDLE_POWER_USE
			update_icon(UPDATE_OVERLAYS)


/obj/machinery/smartfridge/drying_rack/update_overlays()
	. = list()
	if(drying)
		. += "drying-rack_drying"
	if(length(contents))
		. += "drying-rack_filled"


/obj/machinery/smartfridge/drying_rack/process()
	if(drying && rack_dry())//no need to update unless something got dried
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/smartfridge/drying_rack/accept_check(obj/item/O)
	. = ..()
	// If it's a food, reject non driable ones
	if(istype(O, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/S = O
		if(!S.dried_type)
			return FALSE

/**
  * Toggles the drying process.
  *
  * Arguments:
  * * forceoff - Whether to force turn off the drying rack.
  */
/obj/machinery/smartfridge/drying_rack/proc/toggle_drying(forceoff = FALSE)
	if(drying || forceoff)
		drying = FALSE
		use_power = IDLE_POWER_USE
	else
		drying = TRUE
		use_power = ACTIVE_POWER_USE
	update_icon(UPDATE_OVERLAYS)

/**
  * Called in [/obj/machinery/smartfridge/drying_rack/process] to dry the contents.
  */
/obj/machinery/smartfridge/drying_rack/proc/rack_dry()
	for(var/obj/item/reagent_containers/food/snacks/S in contents)
		if(S.dried_type == S.type)//if the dried type is the same as the object's type, don't bother creating a whole new item...
			S.color = "#ad7257"
			S.dry = TRUE
			item_quants[S.name]--
			S.forceMove(get_turf(src))
		else
			var/dried = S.dried_type
			new dried(loc)
			item_quants[S.name]--
			qdel(S)
			SStgui.update_uis(src)
		return TRUE
	for(var/obj/item/stack/sheet/wetleather/WL in contents)
		new /obj/item/stack/sheet/leather(loc, WL.amount)
		item_quants[WL.name]--
		qdel(WL)
		SStgui.update_uis(src)
		return TRUE
	return FALSE
