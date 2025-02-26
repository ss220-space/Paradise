/**
  * # Smart Fridge
  *
  * Stores items of a specified type.
  */
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
	desc = "Это холодильник. Он умный. Просто удивительно, да?"
	ru_names = list(
		NOMINATIVE = "холодильник SmartFridge",
		GENITIVE = "холодильника SmartFridge",
		DATIVE = "холодильнику SmartFridge",
		ACCUSATIVE = "холодильник SmartFridge",
		INSTRUMENTAL = "холодильником SmartFridge",
		PREPOSITIONAL = "холодильнике SmartFridge"
	)
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
				item_quants[newitem.declent_ru(NOMINATIVE)] += 1
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
		balloon_alert(user, "невозможно!")
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK

	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		SStgui.update_uis(src)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		balloon_alert(user, "не работает!")
		return ATTACK_CHAIN_PROCEED

	if(load(I, user))
		user.visible_message(
			span_notice("[user] загрузил[pluralize_ru(user.gender, "", "а", "о", "и")] [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы загрузили [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."),
		)
		balloon_alert(user, "загружено внутрь")
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
				span_notice("[user] загрузил[pluralize_ru(user.gender, "", "а", "о", "и")] содержимое [storage.declent_ru(GENITIVE)] в [declent_ru(ACCUSATIVE)]."),
				span_notice("Вы загрузили содержимое [storage.declent_ru(GENITIVE)] в [declent_ru(ACCUSATIVE)]."),
			)
			balloon_alert(user, "содержимое загружено")
			SStgui.update_uis(src)
			update_icon(UPDATE_OVERLAYS)
		var/failed = length(storage.contents)
		if(failed)
			to_chat(user, span_notice("[failed] предмет[declension_ru(failed, "", "а", "ов")] не был[declension_ru(failed, "", "и", "и")] загружен[declension_ru(failed, "", "ы", "ы")]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	balloon_alert(user, "не подходит!")
	return ATTACK_CHAIN_PROCEED


/obj/machinery/smartfridge/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/smartfridge/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		balloon_alert(user, "не работает!")
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
		balloon_alert(user, "не работает!")
		return TRUE

	var/obj/item/storage/box/pillbottles/P = over_object
	if(!length(P.contents))
		balloon_alert(user, "нечего выгружать!")
		return TRUE

	add_fingerprint(user)
	var/items_loaded = 0
	for(var/obj/G in P.contents)
		if(load(G, user))
			G.add_fingerprint(user)
			items_loaded++
	if(items_loaded)
		user.visible_message(
			span_notice("[user] загрузил[pluralize_ru(user.gender, "", "а", "о", "и")] содержимое [P.declent_ru(GENITIVE)] в [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы загрузили содержимое [P.declent_ru(GENITIVE)] в [declent_ru(ACCUSATIVE)]."))
		balloon_alert(user, "содержимое загружено")
		update_icon(UPDATE_OVERLAYS)
	var/failed = length(P.contents)
	if(failed)
		to_chat(user, span_notice("[failed] предмет[declension_ru(failed, "", "а", "ов")] не был[declension_ru(failed, "", "и", "и")] загружен[declension_ru(failed, "", "ы", "ы")]."))
	return TRUE

/obj/machinery/smartfridge/ui_interact(mob/user, datum/tgui/ui = null)
	user.set_machine(src)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smartfridge", capitalize(declent_ru(NOMINATIVE)))
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
				to_chat(usr, span_warning("Отказано в доступе."))
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
					if(O.declent_ru(NOMINATIVE) == K)
						O.forceMove(get_turf(src))
						adjust_item_drop_location(O)
						user.put_in_hands(O, ignore_anim = FALSE)
						update_icon(UPDATE_OVERLAYS)
						break
			else
				for(var/obj/O in contents)
					if(O.declent_ru(NOMINATIVE) == K)
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
		balloon_alert(user, "хранилище переполнено!")
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

	item_quants[I.declent_ru(NOMINATIVE)] += 1
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
			if(I.declent_ru(NOMINATIVE) == O)
				I.forceMove(loc)
				throw_item = I
				update_icon(UPDATE_OVERLAYS)
				break
	if(!throw_item)
		return FALSE

	INVOKE_ASYNC(throw_item, TYPE_PROC_REF(/atom/movable, throw_at), target, 16, 3, src)
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] кидает [throw_item.declent_ru(ACCUSATIVE)] в [target]!"))
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
	desc = "Это холодильник. Он умный. Подозрительно умный."
	ru_names = list(
		NOMINATIVE = "подозрительный холодильник SmartFridge",
		GENITIVE = "подозрительного холодильника SmartFridge",
		DATIVE = "подозрительному холодильнику SmartFridge",
		ACCUSATIVE = "подозрительный холодильник SmartFridge",
		INSTRUMENTAL = "подозрительным холодильником SmartFridge",
		PREPOSITIONAL = "подозрительном холодильнике SmartFridge"
	)
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
		balloon_alert(user, "механизм блокировки взломан!")

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
	desc = "Это холодильник, предназначенный для растений и их плодов."
	ru_names = list(
		NOMINATIVE = "ботанический холодильник",
		GENITIVE = "ботанического холодильника",
		DATIVE = "ботаническому холодильнику",
		ACCUSATIVE = "ботанический холодильник",
		INSTRUMENTAL = "ботаническим холодильником",
		PREPOSITIONAL = "ботаническом холодильнике"
	)
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
	desc = "Это холодильник, предназначенный для хранения медикаментов и химикатов."
	ru_names = list(
		NOMINATIVE = "медицинский холодильник",
		GENITIVE = "медицинского холодильника",
		DATIVE = "медицинскому холодильнику",
		ACCUSATIVE = "медицинский холодильник",
		INSTRUMENTAL = "медицинским холодильником",
		PREPOSITIONAL = "медицинском холодильнике"
	)
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
	desc = "Это холодильник, предназначенный для хранения слаймовых экстрактов."
	ru_names = list(
		NOMINATIVE = "холодильник для слаймовых экстрактов",
		GENITIVE = "холодильника для слаймовых экстрактов",
		DATIVE = "холодильнику для слаймовых экстрактов",
		ACCUSATIVE = "холодильник для слаймовых экстрактов",
		INSTRUMENTAL = "холодильником для слаймовых экстрактов",
		PREPOSITIONAL = "холодильнике для слаймовых экстрактов"
	)
	req_access = list(ACCESS_RESEARCH)

/obj/machinery/smartfridge/secure/extract/syndie
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
	desc = "Это холодильник, предназначенный для хранения медикаментов и химикатов."
	ru_names = list(
		NOMINATIVE = "химический холодильник",
		GENITIVE = "химического холодильника",
		DATIVE = "химическому холодильнику",
		ACCUSATIVE = "химический холодильник",
		INSTRUMENTAL = "химическим холодильником",
		PREPOSITIONAL = "химическом холодильнике"
	)
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

	name = "\improper Secure Refrigerated Organ Storage"
	desc = "Это холодильник, предназначенный для хранения органов, конечностей, имплантов и капельниц."
	ru_names = list(
		NOMINATIVE = "холодильник для органов",
		GENITIVE = "холодильника для органов",
		DATIVE = "холодильнику для органов",
		ACCUSATIVE = "холодильник для органов",
		INSTRUMENTAL = "холодильником для органов",
		PREPOSITIONAL = "холодильнике для органов"
	)
	req_access = list(ACCESS_SURGERY)
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
	desc = "Машина, предназначенная для хранения различного рода дискет."
	ru_names = list(
		NOMINATIVE = "хранилище для дискет",
		GENITIVE = "хранилища для дискет",
		DATIVE = "хранилищу для дискет",
		ACCUSATIVE = "хранилище для дискет",
		INSTRUMENTAL = "хранилищем для дискет",
		PREPOSITIONAL = "хранилище для дискет"
	)
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
	desc = "Это холодильник, предназначенный для хранения образцов вирусов."
	ru_names = list(
		NOMINATIVE = "холодильник для вирусных образцов",
		GENITIVE = "холодильника для вирусных образцов",
		DATIVE = "холодильнику для вирусных образцов",
		ACCUSATIVE = "холодильник для вирусных образцов",
		INSTRUMENTAL = "холодильником для вирусных образцов",
		PREPOSITIONAL = "холодильнике для вирусных образцов"
	)
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
	desc = "Это холодильник, предназначенный для хранения напитков."
	ru_names = list(
		NOMINATIVE = "холодильник для напитков",
		GENITIVE = "холодильника для напитков",
		DATIVE = "холодильнику для напитков",
		ACCUSATIVE = "холодильник для напитков",
		INSTRUMENTAL = "холодильником для напитков",
		PREPOSITIONAL = "холодильнике для напитков"
	)

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
	desc = "Это холодильник, предназначенный для хранения органов, конечностей, имплантов и капельниц."
	ru_names = list(
		NOMINATIVE = "холодильник для еды",
		GENITIVE = "холодильника для еды",
		DATIVE = "холодильнику для еды",
		ACCUSATIVE = "холодильник для еды",
		INSTRUMENTAL = "холодильником для еды",
		PREPOSITIONAL = "холодильнике для еды"
	)

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
	desc = "Деревянная стойка, предназначенная для просушки растительных продуктов, еды и кожи."
	ru_names = list(
		NOMINATIVE = "сушильная стойка",
		GENITIVE = "сушильной стойки",
		DATIVE = "сушильной стойке",
		ACCUSATIVE = "сушильную стойку",
		INSTRUMENTAL = "сушильной стойкой",
		PREPOSITIONAL = "сушильной стойке"
	)
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "drying-rack_off"
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 200
	can_dry = TRUE
	visible_contents = FALSE
	var/primitive = FALSE //used for energy consuming stuff
	var/drying_timer = 0
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
	if(primitive)
		return

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
			if(!primitive)
				use_power = drying ? ACTIVE_POWER_USE : IDLE_POWER_USE
			update_icon(UPDATE_OVERLAYS)

/obj/machinery/smartfridge/drying_rack/update_overlays()
	. = list()
	if(drying)
		. += "drying-rack_drying"
	if(length(contents))
		. += "drying-rack_filled"


/obj/machinery/smartfridge/drying_rack/process()
	if(!drying)//no need to update if we don't dry
		return
	if(drying_timer)
		drying_timer--
		if(!drying_timer) //if it went to zero, dry and reset
			drying_timer = initial(drying_timer)
			if(rack_dry())
				update_icon(UPDATE_OVERLAYS)
	else // no timer
		if(rack_dry())
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

/obj/machinery/smartfridge/drying_rack/ash
	name = "primitive drying rack"
	desc = "Примитивная самодельная сушилка, предназначенная для просушки растительных продуктов, еды и кожи."
	ru_names = list(
		NOMINATIVE = "примитивная сушилка",
		GENITIVE = "примитивной сушилки",
		DATIVE = "примитивной сушилке",
		ACCUSATIVE = "примитивную сушилку",
		INSTRUMENTAL = "примитивной сушилкой",
		PREPOSITIONAL = "примитивной сушилке",
	)
	gender = FEMALE
	icon_state = "primitive-drying-rack"
	use_power = NO_POWER_USE
	can_dry = FALSE //trust me
	drying = TRUE
	idle_power_usage = 0
	active_power_usage = 0
	drying_timer = 8
	primitive = TRUE

/obj/machinery/smartfridge/drying_rack/ash/update_overlays()
	overlays.Cut()
	if(length(contents))
		overlays += "primitive-drying-rack_leather"

/obj/machinery/smartfridge/drying_rack/ash/on_deconstruction()
	new /obj/item/stack/sheet/wood(loc, 2)
	new /obj/item/stack/sheet/sinew(loc, 1)
	..()
