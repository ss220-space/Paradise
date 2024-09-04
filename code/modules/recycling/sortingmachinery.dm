/obj/structure/bigDelivery
	name = "large parcel"
	desc = "A big wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	density = TRUE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/wrapped
	var/init_welded = FALSE
	var/giftwrapped = FALSE
	var/sortTag = 0
	var/cc_tag


/obj/structure/bigDelivery/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposal_handling))


/obj/structure/bigDelivery/Destroy()
	var/turf/our_turf = get_turf(src)
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(our_turf)
	wrapped = null
	return ..()


/obj/structure/bigDelivery/proc/disposal_handling(disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER

	if(!hasmob && sortTag)
		disposal_holder.destinationTag = sortTag


/obj/structure/bigDelivery/ex_act(severity)
	for(var/atom/movable/thing as anything in contents)
		thing.ex_act()
		CHECK_TICK
	..()


/obj/structure/bigDelivery/examine(mob/user)
	. = ..()
	if(sortTag)
		. += span_notice("The package will be addressed to the [GLOB.TAGGERLOCATIONS[sortTag]] on [station_name()].")
	if(cc_tag)
		. += span_notice("The package will be addressed to the [cc_tag] on Centomm.")


/obj/structure/bigDelivery/attack_hand(mob/user)
	var/turf/our_turf = get_turf(src)
	playsound(our_turf, 'sound/items/poster_ripped.ogg', 50, TRUE)
	if(wrapped)
		wrapped.forceMove(our_turf)
		if(istype(wrapped, /obj/structure/closet))
			var/obj/structure/closet/closet = wrapped
			closet.add_fingerprint(user)
			closet.welded = init_welded
		wrapped = null
	for(var/atom/movable/thing as anything in src)
		thing.add_fingerprint(user)
		thing.forceMove(our_turf)
	qdel(src)


/obj/structure/bigDelivery/update_icon_state()
	if(!wrapped)
		icon_state = initial(icon_state)
		return
	var/holding_crate = istype(wrapped, /obj/structure/closet/crate)
	if(giftwrapped)
		icon_state = holding_crate ? "giftcrate" : "giftcloset"
		return
	icon_state = "delivery[holding_crate ? "crate" : "closet"][(sortTag || cc_tag) ? "_labeled" : ""]"	// label should be an overlay


/obj/structure/bigDelivery/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_pen(I))
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/destTagger))
		add_fingerprint(user)
		var/obj/item/destTagger/tagger = I
		if(sortTag == tagger.currTag && cc_tag == tagger.currcc_tag)
			to_chat(user, span_warning("The package is already tagged this way."))
			return ATTACK_CHAIN_PROCEED
		if(tagger.currcc_tag)
			to_chat(user, span_notice("*[uppertext(tagger.currcc_tag)]*"))
			cc_tag = tagger.currcc_tag
		else
			to_chat(user, span_notice("*[uppertext(GLOB.TAGGERLOCATIONS[tagger.currTag])]*"))
			sortTag = tagger.currTag
		update_icon(UPDATE_ICON_STATE)
		playsound(loc, 'sound/machines/twobeep.ogg', 100, TRUE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/shippingPackage))
		add_fingerprint(user)
		var/obj/item/shippingPackage/shipping = I
		if(shipping.sealed)
			to_chat(user, span_warning("The package is sealed."))
			return ATTACK_CHAIN_PROCEED
		if(!user.temporarily_remove_item_from_inventory(shipping))
			return ..()
		sortTag = shipping.sortTag
		update_icon(UPDATE_ICON_STATE)
		to_chat(user, span_notice("You have ripped the label off the shipping package and affix it to this one."))
		playsound(loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
		qdel(shipping)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/wrapping_paper))
		add_fingerprint(user)
		var/obj/item/stack/wrapping_paper/paper = I
		if(giftwrapped)
			to_chat(user, span_warning("The package is already giftwrapped."))
			return ATTACK_CHAIN_PROCEED
		var/create_tube = paper.get_amount() - 3 == 0
		if(!paper.use(3))
			to_chat(user, span_warning("You need at least three lengths of wrapping paper."))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] has wrapped the package in festive paper."),
			span_notice("You have wrapped the package in festive paper."),
		)
		giftwrapped = TRUE
		update_icon(UPDATE_ICON_STATE)
		if(create_tube)
			var/obj/item/c_tube/tube = new(user.drop_location())
			tube.add_fingerprint(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/smallDelivery
	name = "small parcel"
	desc = "A small wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrateSmall"
	item_state = "deliverypackage"
	var/obj/item/wrapped
	var/giftwrapped = FALSE
	var/sortTag = 0


/obj/item/smallDelivery/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposal_handling))


/obj/item/smallDelivery/Destroy()
	QDEL_NULL(wrapped)
	return ..()


/obj/item/smallDelivery/proc/disposal_handling(disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER

	if(!hasmob && sortTag)
		disposal_holder.destinationTag = sortTag


/obj/item/smallDelivery/ex_act(severity)
	for(var/atom/movable/thing as anything in contents)
		thing.ex_act()
		CHECK_TICK
	..()


/obj/item/smallDelivery/emp_act(severity)
	..()
	for(var/atom/movable/thing as anything in contents)
		thing.emp_act(severity)


/obj/item/smallDelivery/attack_self(mob/user)
	if(wrapped) //sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.forceMove(drop_location())
		user.put_in_hands(wrapped)
		wrapped = null
	playsound(loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
	qdel(src)


/obj/item/smallDelivery/update_icon_state()
	if(!wrapped)
		icon_state = initial(icon_state)
		return
	var/weight_number
	if(wrapped.w_class < 1)
		weight_number = 1
	else if(wrapped.w_class > 5)
		weight_number = 5
	else
		weight_number = wrapped.w_class
	if(giftwrapped)
		icon_state = "giftcrate[weight_number]"
		return
	icon_state = "deliverycrate[weight_number][sortTag ? "_labeled" : ""]"	// label should be an overlay


/obj/item/smallDelivery/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/destTagger))
		add_fingerprint(user)
		var/obj/item/destTagger/tagger = I
		if(sortTag == tagger.currTag)
			to_chat(user, span_warning("The package is already tagged this way."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("*[uppertext(GLOB.TAGGERLOCATIONS[tagger.currTag])]*"))
		sortTag = tagger.currTag
		update_icon(UPDATE_ICON_STATE)
		playsound(loc, 'sound/machines/twobeep.ogg', 100, TRUE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/shippingPackage))
		add_fingerprint(user)
		var/obj/item/shippingPackage/shipping = I
		if(shipping.sealed)
			to_chat(user, span_warning("The package is sealed."))
			return ATTACK_CHAIN_PROCEED
		if(!user.temporarily_remove_item_from_inventory(shipping))
			return ..()
		sortTag = shipping.sortTag
		update_icon(UPDATE_ICON_STATE)
		to_chat(user, span_notice("You have ripped the label off the shipping package and affix it to this one."))
		playsound(loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
		qdel(shipping)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/wrapping_paper))
		add_fingerprint(user)
		var/obj/item/stack/wrapping_paper/paper = I
		if(giftwrapped)
			to_chat(user, span_warning("The package is already giftwrapped."))
			return ATTACK_CHAIN_PROCEED
		var/create_tube = paper.get_amount() - 1 == 0
		if(!paper.use(1))
			to_chat(user, span_warning("You need at least one length of wrapping paper."))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] has wrapped the package in festive paper."),
			span_notice("You have wrapped the package in festive paper."),
		)
		giftwrapped = TRUE
		update_icon(UPDATE_ICON_STATE)
		if(create_tube)
			var/obj/item/c_tube/tube = new(user.drop_location())
			tube.add_fingerprint(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/stack/packageWrap
	name = "package wrapper"
	icon = 'icons/obj/items.dmi'
	icon_state = "deliveryPaper"
	singular_name = "package wrapper"
	item_flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	resistance_flags = FLAMMABLE
	var/static/list/no_wrap = typecacheof(list(
		/obj/item/shippingPackage,
		/obj/item/smallDelivery,
		/obj/structure/bigDelivery,
		/obj/item/evidencebag,
		/obj/structure/closet/body_bag,
		/obj/item/twohanded/required,
		/obj/item/storage,
		/obj/item/mecha_parts/chassis
	))


/obj/item/stack/packageWrap/afterattack(obj/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(!istype(target))	//this really shouldn't be necessary (but it is).	-Pete
		return
	if(is_type_in_typecache(target, no_wrap))
		to_chat(user, span_warning("The [target.name] cannot be wrapped."))
		return
	if(target.anchored)
		to_chat(user, span_warning("The [target.name] should not be anchored."))
		return
	if(!isturf(target.loc))	// saves from a lot of checks later
		to_chat(user, span_warning("The [target.name] should be on the ground to start wrapping."))
		return

	var/create_tube = FALSE
	if(isitem(target))
		var/obj/item/item = target
		create_tube = get_amount() - 1 == 0
		if(!use(1))
			to_chat(user, span_warning("You need at least one length of wrapping paper."))
			return
		user.visible_message(
			span_notice("[user] has packaged [item] using the wrapping paper."),
			span_notice("You have packaged [item] using the wrapping paper."),
		)
		var/obj/item/smallDelivery/package = new(get_turf(target))	//Aaannd wrap it up!
		package.w_class = item.w_class
		package.wrapped = item
		item.forceMove(package)
		package.add_fingerprint(user)
		item.add_fingerprint(user)
		package.update_icon(UPDATE_ICON_STATE)

	else if(istype(target, /obj/structure/closet))
		var/obj/structure/closet/container = target
		if(container.opened)
			to_chat(user, span_warning("The [container.name] should be closed."))
			return
		var/current_amount = get_amount()
		create_tube = current_amount - 3 == 0
		if(current_amount < 3)
			to_chat(user, span_warning("You need at least three lengths of wrapping paper."))
			return
		user.visible_message(
			span_notice("[user] starts to package [container] using the wrapping paper."),
			span_notice("You start to package [container] using the wrapping paper..."),
		)
		if(!do_after(user, 3 SECONDS, container, max_interact_count = 1) || container.opened || !isturf(target.loc) || QDELETED(src) || !use(3))
			return
		user.visible_message(
			span_notice("[user] has packaged [container] using the wrapping paper."),
			span_notice("You have packaged [container] using the wrapping paper."),
		)
		var/obj/structure/bigDelivery/package = new(get_turf(container))
		package.init_welded = container.welded
		package.wrapped = container
		container.forceMove(package)
		package.add_fingerprint(user)
		container.add_fingerprint(user)
		package.update_icon(UPDATE_ICON_STATE)
		if(!istype(container, /obj/structure/closet/crate))
			container.welded = TRUE

	else
		to_chat(user, span_warning("The object you are trying to wrap is unsuitable for the sorting machinery."))
		return

	user.visible_message(
		span_notice("[user] has wrapped [target]."),
		span_notice("You have wrapped [target]."),
	)
	add_attack_logs(user, target, "used [name]", ATKLOG_ALL)

	if(create_tube) //if we used our last wrapping paper, drop a cardboard tube
		var/obj/item/c_tube/tube = new(user.drop_location())
		tube.add_fingerprint(user)


/obj/item/destTagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon = 'icons/obj/device.dmi'
	icon_state = "dest_tagger"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_TINY
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	//The whole system for the sorttype var is determined based on the order of this list,
	//disposals must always be 1, since anything that's untagged will automatically go to disposals, or sorttype = 1 --Superxpdude
	var/currTag = 1

	var/currcc_tag

/obj/item/destTagger/attack_self(mob/user)
	ui_interact(user)

/obj/item/destTagger/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DestinationTagger", name)
		ui.open()

/obj/item/destTagger/ui_data(mob/user)
	var/list/data = list()
	data["selected_destination_id"] = clamp(currTag, 1, length(GLOB.TAGGERLOCATIONS))
	data["selected_centcom_id"] = currcc_tag
	return data

/obj/item/destTagger/ui_static_data(mob/user)
	var/list/static_data = list()
	static_data["destinations"] = list()
	for(var/destination_index in 1 to length(GLOB.TAGGERLOCATIONS))
		var/list/destination_data = list(
			"name" = GLOB.TAGGERLOCATIONS[destination_index],
			"id"   = destination_index,
		)
		static_data["destinations"] += list(destination_data)
	for(var/dep in SScargo_quests.centcomm_departaments)
		var/datum/quest_customer/customer = dep
		static_data["centcom_destinations"] += list(list(
			"name" = customer.departament_name,
		))
	for(var/dep in SScargo_quests.plasma_departaments) /// Plasma deps is a CC deps too
		var/datum/quest_customer/customer = dep
		static_data["centcom_destinations"] += list(list(
			"name" = customer.departament_name,
		))

	for(var/corp in SScargo_quests.corporations)
		var/datum/quest_customer/customer = corp
		static_data["corporation_destinations"] += list(list(
			"name" = customer.departament_name,
		))
	return static_data

/obj/item/destTagger/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("select_destination")
			var/destination_id = clamp(text2num(params["destination"]), 1, length(GLOB.TAGGERLOCATIONS))
			if(currTag != destination_id)
				currTag = destination_id
				playsound(src, "terminal_type", 25, TRUE)
			currcc_tag = null

		if("select_cc_destination")
			if(currcc_tag != params["destination"])
				currcc_tag = params["destination"]
				playsound(src, "terminal_type", 25, TRUE)

	add_fingerprint(usr)


/obj/item/shippingPackage
	name = "Shipping package"
	desc = "A pre-labeled package for shipping an item to coworkers."
	icon = 'icons/obj/storage.dmi'
	icon_state = "shippack"
	var/obj/item/wrapped = null
	var/sortTag = 0
	var/sealed = FALSE


/obj/item/shippingPackage/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposal_handling))


/obj/item/shippingPackage/Destroy()
	QDEL_NULL(wrapped)
	return ..()


/obj/item/shippingPackage/proc/disposal_handling(disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER

	if(!hasmob && sortTag && sealed)
		disposal_holder.destinationTag = sortTag


/obj/item/shippingPackage/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(is_pen(I))
		if(sealed)
			to_chat(user, span_warning("The package is sealed."))
			return ATTACK_CHAIN_PROCEED
		var/str = tgui_input_text(user, "Intended recipient?", "Address", max_length = MAX_NAME_LEN)
		if(!str || !length(str))
			to_chat(user, span_warning("Invalid name."))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] has addressed [src] to [str]."),
			span_notice("You have addressed [src] to [str]."),
		)
		name = "Shipping package (RE: [str])"
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(wrapped)
		to_chat(user, span_warning("The package is already contains something."))
		return ATTACK_CHAIN_PROCEED

	if(isstorage(I) || istype(I, /obj/item/shippingPackage) || I.w_class > WEIGHT_CLASS_NORMAL)
		to_chat(user, span_warning("The [I.name] cannot fit."))
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(I, src))
		return ATTACK_CHAIN_PROCEED

	user.visible_message(
		span_notice("[user] has put [I] into [src]."),
		span_notice("You have put [I] into [src]."),
	)
	wrapped = I
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/item/shippingPackage/attack_self(mob/user)
	if(sealed)
		wrapped.forceMove(drop_location())
		to_chat(user, span_notice("You have shredded [src], dropping the contents onto the floor."))
		playsound(loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
		user.temporarily_remove_item_from_inventory(src, force = TRUE)
		wrapped = null
		qdel(src)
		return

	if(wrapped)
		switch(tgui_alert(user, "Select an action:", "Shipping", list("Remove Object", "Seal Package", "Cancel")))
			if("Remove Object")
				to_chat(user, span_notice("You have shaked out [src]'s contents onto the floor."))
				wrapped.forceMove(drop_location())
				wrapped = null
			if("Seal Package")
				to_chat(user, span_notice("You have sealed [src], preparing it for delivery."))
				sealed = TRUE
				update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
		return

	if(tgui_alert(user, "Do you want to tear up the package?", "Shipping", list("Yes", "No")) == "Yes")
		to_chat(user, span_notice("You have shredded [src]."))
		playsound(loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
		user.temporarily_remove_item_from_inventory(src, force = TRUE)
		qdel(src)


/obj/item/shippingPackage/update_icon_state()
	icon_state = "shippack[sealed ? "_sealed" : ""]"


/obj/item/shippingPackage/update_desc(updates = ALL)
	. = ..()
	desc = "A pre-labeled package for shipping an item to coworkers."
	if(sortTag)
		desc += " The label says \"Deliver to [GLOB.TAGGERLOCATIONS[sortTag]]\"."
	if(!sealed)
		desc += " The package is not sealed."

