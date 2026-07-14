#define CART_HAS_MINIMUM_REAGENT_VOLUME !(reagents.total_volume < 1)
/obj/structure/mopbucket
	desc = "Fill it with water, but don't forget a mop!"
	name = "mop bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = TRUE
	container_type = OPENCONTAINER
	var/obj/item/mop/mymop = null
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	/// The icon used for the water overlay
	var/water_icon = "mopbucket_water"

/obj/structure/mopbucket/Initialize(mapload)
	. = ..()
	create_reagents(100)
	GLOB.janitorial_equipment += src
	register_context()

/obj/structure/mopbucket/full/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/water, 100)

/obj/structure/mopbucket/Destroy()
	GLOB.janitorial_equipment -= src
	QDEL_NULL(mymop)
	return ..()

/obj/structure/mopbucket/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	if(istype(held_item, /obj/item/mop))
		if(!mymop)
			context[SCREENTIP_CONTEXT_LMB] = "Put [held_item]"
		context[SCREENTIP_CONTEXT_RMB] = "Wet [held_item]"
		return CONTEXTUAL_SCREENTIP_SET

	if(is_reagent_container(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Fill mop bucket"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item?.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Empty bucket"
		return CONTEXTUAL_SCREENTIP_SET

	if(!held_item && mymop)
		context[SCREENTIP_CONTEXT_LMB] = "Take [mymop]"
		return CONTEXTUAL_SCREENTIP_SET

	return .

/obj/structure/mopbucket/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += span_notice("[get_examine_icon(user)] [src] contains [reagents.total_volume] units of water left.")

/obj/structure/mopbucket/attackby(obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	if(user.a_intent == INTENT_HARM || weapon.is_robot_module())
		return ..()

	if(is_reagent_container(weapon))
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED // skip attack animation when refilling cart

	if(istype(weapon, /obj/item/mop))
		if(mymop)
			to_chat(user, span_notice("There is already [mymop] in [src]."))
			return ATTACK_CHAIN_BLOCKED_ALL
		add_fingerprint(user)
		if(!put_in_cart(weapon, user))
			return ..()
		mymop = weapon
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/mop_bucket/attackby_secondary(obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(weapon, /obj/item/mop))
		if(weapon.reagents.total_volume >= weapon.reagents.maximum_volume)
			balloon_alert(user, "already soaked!")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(!CART_HAS_MINIMUM_REAGENT_VOLUME)
			balloon_alert(user, "empty!")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		reagents.trans_to(weapon, weapon.reagents.maximum_volume)
		balloon_alert(user, "doused mop")
		playsound(src, 'sound/effects/slosh.ogg', 25, vary = TRUE)

	if(is_reagent_container(weapon) || istype(weapon, /obj/item/mop))
		update_appearance(UPDATE_OVERLAYS)
		return SECONDARY_ATTACK_CONTINUE_CHAIN // skip attack animations when refilling cart

	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/structure/mopbucket/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("The [name] is empty."))
		return .
	user.visible_message(
		span_notice("[user] starts to empty [src]."),
		span_notice("You start to empty [src]..."),
	)
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || !reagents || !reagents.total_volume)
		return .
	user.visible_message(
		span_notice("[user] empties the contents of [src] onto the floor."),
		span_notice("You have emptied the contents of [src] onto the floor."),
	)
	reagents.reaction(loc)
	reagents.clear_reagents()

/obj/structure/mopbucket/proc/put_in_cart(obj/item/I, mob/user)
	. = user.drop_transfer_item_to_loc(I, src)
	if(.)
		to_chat(user, span_notice("You put [I] into [src]."))

/obj/structure/mopbucket/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/mopbucket/update_overlays()
	. = ..()
	if(mymop)
		. += "mopbucket_mop"
	if(reagents.total_volume > 0)
		var/mutable_appearance/reagentsImage = mutable_appearance(icon, "mopbucket_reagents0")
		reagentsImage.alpha = 150
		switch((reagents.total_volume / reagents.maximum_volume) * 100)
			if(1 to 25)
				reagentsImage.icon_state = "mopbucket_reagents1"
			if(26 to 50)
				reagentsImage.icon_state = "mopbucket_reagents2"
			if(51 to 75)
				reagentsImage.icon_state = "mopbucket_reagents3"
			if(76 to 100)
				reagentsImage.icon_state = "mopbucket_reagents4"
		reagentsImage.color = get_color_matrix_from_reagents(reagents.reagent_list)
		. += reagentsImage

/obj/structure/mopbucket/attack_hand(mob/living/user)
	. = ..()
	if(mymop)
		mymop.forceMove_turf()
		user.put_in_hands(mymop, ignore_anim = FALSE)
		to_chat(user, span_notice("You take [mymop] from [src]."))
		mymop = null
		update_icon(UPDATE_OVERLAYS)

#undef CART_HAS_MINIMUM_REAGENT_VOLUME
