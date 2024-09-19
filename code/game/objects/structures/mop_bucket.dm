/obj/structure/mopbucket
	desc = "Fill it with water, but don't forget a mop!"
	name = "mop bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = TRUE
	container_type = OPENCONTAINER
	var/obj/item/mop/mymop = null
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

/obj/structure/mopbucket/Initialize(mapload)
	. = ..()
	create_reagents(100)
	GLOB.janitorial_equipment += src

/obj/structure/mopbucket/full/Initialize(mapload)
	. = ..()
	reagents.add_reagent("water", 100)

/obj/structure/mopbucket/Destroy()
	GLOB.janitorial_equipment -= src
	QDEL_NULL(mymop)
	return ..()

/obj/structure/mopbucket/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += span_info("[bicon(src)] [src] contains [reagents.total_volume] units of water left.")


/obj/structure/mopbucket/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || I.is_robot_module())
		return ..()

	if(istype(I, /obj/item/mop))
		add_fingerprint(user)
		var/obj/item/mop/mop = I
		mop.wet_mop(src, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


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
		var/image/reagentsImage = image(icon, src, "mopbucket_reagents0")
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
		reagentsImage.icon += mix_color_from_reagents(reagents.reagent_list)
		. += reagentsImage


/obj/structure/mopbucket/attack_hand(mob/living/user)
	. = ..()
	if(mymop)
		mymop.forceMove_turf()
		user.put_in_hands(mymop, ignore_anim = FALSE)
		to_chat(user, "<span class='notice'>You take [mymop] from [src].</span>")
		mymop = null
		update_icon(UPDATE_OVERLAYS)

