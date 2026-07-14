//TG style Janicart

/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "This is the alpha and omega of sanitation."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	density = TRUE
	container_type = OPENCONTAINER
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/storage/bag/trash/mybag = null
	var/obj/item/mop/mymop = null
	var/obj/item/reagent_containers/spray/cleaner/myspray = null
	var/obj/item/lightreplacer/myreplacer = null
	var/signs = 0
	var/const/max_signs = 4

/obj/structure/janitorialcart/Initialize(mapload)
	. = ..()
	create_reagents(100)
	GLOB.janitorial_equipment += src
	register_context()

/obj/structure/janitorialcart/Destroy()
	GLOB.janitorial_equipment -= src
	QDEL_NULL(mybag)
	QDEL_NULL(mymop)
	QDEL_NULL(myspray)
	QDEL_NULL(myreplacer)
	return ..()

/obj/structure/janitorialcart/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	if(istype(held_item, /obj/item/mop))
		if(!mymop)
			context[SCREENTIP_CONTEXT_LMB] = "Put [held_item]"
		context[SCREENTIP_CONTEXT_RMB] = "Wet [held_item]"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/storage/bag/trash) && !mybag)
		context[SCREENTIP_CONTEXT_LMB] = "Put [held_item]"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/lightreplacer) && !myreplacer)
		context[SCREENTIP_CONTEXT_LMB] = "Put [held_item]"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/reagent_containers/spray/cleaner) && !myspray)
		context[SCREENTIP_CONTEXT_LMB] = "Put [held_item]"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/caution) && signs < max_signs)
		context[SCREENTIP_CONTEXT_LMB] = "Put [held_item]"
		return CONTEXTUAL_SCREENTIP_SET

	if(is_reagent_container(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Fill cart bucket"
		return CONTEXTUAL_SCREENTIP_SET

	if(!held_item)
		context[SCREENTIP_CONTEXT_LMB] = "Take equipment"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item?.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Empty cart bucket"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item?.tool_behaviour == TOOL_WRENCH)
		if(anchored)
			context[SCREENTIP_CONTEXT_LMB] = "Unanchore"
		else
			context[SCREENTIP_CONTEXT_LMB] = "Anchore"
		return CONTEXTUAL_SCREENTIP_SET

	return .

/obj/structure/janitorialcart/proc/put_in_cart(obj/item/I, mob/user)
	. = user.drop_transfer_item_to_loc(I, src)
	if(.)
		to_chat(user, span_notice("You put [I] into [src]."))

/obj/structure/janitorialcart/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/janitorialcart/attackby_secondary(obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(weapon, /obj/item/mop))
		if(weapon.reagents.total_volume >= weapon.reagents.maximum_volume)
			balloon_alert(user, "already soaked!")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		reagents.trans_to(weapon, weapon.reagents.maximum_volume)
		balloon_alert(user, "doused mop")
		playsound(src, 'sound/effects/slosh.ogg', 25, vary = TRUE)

	if(is_reagent_container(weapon) || istype(weapon, /obj/item/mop))
		update_appearance(UPDATE_OVERLAYS)
		return SECONDARY_ATTACK_CONTINUE_CHAIN // skip attack animations when refilling cart

	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/structure/janitorialcart/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || I.is_robot_module())
		return ..()

	var/fail_msg = span_notice("There is already one of those in [src].")


	if(istype(I, /obj/item/mop))
		if(mymop)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_BLOCKED_ALL
		add_fingerprint(user)
		if(!put_in_cart(I, user))
			return ..()
		mymop = I
		SStgui.update_uis(src)
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/storage/bag/trash))
		add_fingerprint(user)
		if(mybag)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		mybag = I
		SStgui.update_uis(src)
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/lightreplacer))
		add_fingerprint(user)
		if(myreplacer)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		myreplacer = I
		SStgui.update_uis(src)
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/reagent_containers/spray/cleaner))
		add_fingerprint(user)
		if(myspray)
			to_chat(user, fail_msg)
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		myspray = I
		SStgui.update_uis(src)
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(is_reagent_container(I))
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED // skip attack animation when refilling cart

	if(istype(I, /obj/item/caution))
		add_fingerprint(user)
		if(signs >= max_signs)
			to_chat(user, span_notice("The [name] cannot hold any more signs."))
			return ATTACK_CHAIN_PROCEED
		if(!put_in_cart(I, user))
			return ..()
		signs++
		SStgui.update_uis(src)
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(mybag?.can_be_inserted(I, stop_messages = TRUE))
		mybag.handle_item_insertion(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/janitorialcart/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("The [name]'s bucket is empty."))
		return .
	user.visible_message(
		span_notice("[user] starts to empty the contents of [src]'s bucket."),
		span_notice("You start to empty the contents of [src]'s bucket..."),
	)
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || !reagents || !reagents.total_volume)
		return .
	user.visible_message(
		span_notice("[user] empties the contents of [src]'s bucket onto the floor."),
		span_notice("You have emptied the contents of [src]'s bucket onto the floor."),
	)
	reagents.reaction(loc)
	reagents.clear_reagents()

/obj/structure/janitorialcart/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(isinspace())
		to_chat(user, span_warning("That was a dumb idea."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	set_anchored(!anchored)
	if(anchored)
		user.visible_message(
			span_notice("[user] tightens [name]'s casters."),
			span_notice("You have tightened [name]'s casters."),
			span_italics("You hear ratchet."),
		)
	else
		user.visible_message(
			span_notice("[user] loosens [name]'s casters."),
			span_notice("You have loosened [name]'s casters."),
			span_italics("You hear ratchet."),
		)

/obj/structure/janitorialcart/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(isnull(ui))
		ui = new(user, src, "Janicart", "Тележка уборщика")
		ui.open()

/obj/structure/janitorialcart/attack_hand(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/structure/janitorialcart/ui_data(mob/user)
	. = ..()
	.["mybag"] = mybag?.declent_ru(NOMINATIVE)
	.["mymop"] = mymop?.declent_ru(NOMINATIVE)
	.["myspray"] = myspray?.declent_ru(NOMINATIVE)
	.["myreplacer"] = myreplacer?.declent_ru(NOMINATIVE)
	.["signs"] = signs

/obj/structure/janitorialcart/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/living/user = ui.user
	if(!isliving(user))
		return

	switch(action)
		if("garbage")
			if(!mybag)
				return
			mybag.forceMove_turf()
			user.put_in_hands(mybag, ignore_anim = FALSE)
			to_chat(user, span_notice("You take [mybag] from [src]."))
			mybag = null
			. = TRUE

		if("mop")
			if(!mymop)
				return
			mymop.forceMove_turf()
			user.put_in_hands(mymop, ignore_anim = FALSE)
			to_chat(user, span_notice("You take [mymop] from [src]."))
			mymop = null
			. = TRUE

		if("spray")
			if(!myspray)
				return
			myspray.forceMove_turf()
			user.put_in_hands(myspray, ignore_anim = FALSE)
			to_chat(user, span_notice("You take [myspray] from [src]."))
			myspray = null
			. = TRUE

		if("replacer")
			if(!myreplacer)
				return
			myreplacer.forceMove_turf()
			user.put_in_hands(myreplacer, ignore_anim = FALSE)
			to_chat(user, span_notice("You take [myreplacer] from [src]."))
			myreplacer = null
			. = TRUE

		if("sign")
			if(!signs)
				return
			var/obj/item/caution/sign = locate() in src
			if(!sign)
				WARNING("Signs ([signs]) didn't match contents")
				signs = 0
				return
			sign.forceMove_turf()
			user.put_in_hands(sign, ignore_anim = FALSE)
			to_chat(user, span_notice("You take \a [sign] from [src]."))
			signs--
			. = TRUE

	update_appearance(UPDATE_OVERLAYS)

/obj/structure/janitorialcart/update_overlays()
	. = ..()
	if(mybag)
		. += "cart_garbage"
	if(mymop)
		. += "cart_mop"
	if(myspray)
		. += "cart_spray"
	if(myreplacer)
		. += "cart_replacer"
	if(signs)
		. += "cart_sign[signs]"
	if(reagents.total_volume > 0)
		var/mutable_appearance/reagentsImage = mutable_appearance(icon, "cart_reagents0")
		reagentsImage.alpha = 150
		switch((reagents.total_volume / reagents.maximum_volume) * 100)
			if(1 to 25)
				reagentsImage.icon_state = "cart_reagents1"
			if(26 to 50)
				reagentsImage.icon_state = "cart_reagents2"
			if(51 to 75)
				reagentsImage.icon_state = "cart_reagents3"
			if(76 to 100)
				reagentsImage.icon_state = "cart_reagents4"
		reagentsImage.color = get_color_matrix_from_reagents(reagents.reagent_list)
		. += reagentsImage

