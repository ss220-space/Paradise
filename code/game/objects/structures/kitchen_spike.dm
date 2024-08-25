
//////Kitchen Spike

/obj/structure/kitchenspike_frame
	name = "meatspike frame"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spikeframe"
	desc = "The frame of a meat spike."
	density = TRUE
	anchored = FALSE
	max_integrity = 200


/obj/structure/kitchenspike_frame/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/rods))
		add_fingerprint(user)
		var/obj/item/stack/rods/rods = I
		if(!rods.use(4))
			to_chat(user, span_warning("You need at least four rods to add the meat spikes."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You add meat spikes to the frame."))
		var/obj/structure/kitchenspike/spikes = new(loc)
		transfer_fingerprints_to(spikes)
		spikes.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/kitchenspike_frame/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return .
	add_fingerprint(user)
	set_anchored(!anchored)
	to_chat(user, span_notice("You [anchored ? "" : "un"]wrench [src] [anchored ? "into place" : "from the floor"]."))


/obj/structure/kitchenspike
	name = "meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals."
	density = TRUE
	anchored = TRUE
	buckle_lying = 0
	can_buckle = TRUE
	max_integrity = 250


/obj/structure/kitchenspike/Destroy()
	unbuckle_all_mobs(force = TRUE)
	return ..()


/obj/structure/kitchenspike/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !isliving(grabbed_thing))
		return .
	if(has_buckled_mobs())
		to_chat(grabber, span_danger("The spike already has something on it, finish collecting its meat first!"))
		return .
	if(!do_after(grabber, 12 SECONDS, src, NONE) || !grabber || !grabbed_thing || grabber.pulling != grabbed_thing)
		return .
	if(!spike(grabbed_thing))
		return .
	add_fingerprint(grabber)
	grabbed_thing.visible_message(
		span_danger("[grabber] slams [grabbed_thing] onto the meat spike!"),
		span_userdanger("[grabber] slams you onto the meat spike!"),
		span_italics("You hear a squishy wet noise."),
	)


/obj/structure/kitchenspike/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(has_buckled_mobs())
		to_chat(user, span_warning("You can't do that while something's on the spike!"))
		return .
	if(!I.use_tool(src, user, 2 SECONDS, volume = 100) || has_buckled_mobs())
		return .
	to_chat(user, span_notice("You pry the spikes out of the frame."))
	deconstruct(TRUE)


/obj/structure/kitchenspike/proc/spike(mob/living/victim)
	if(!istype(victim))
		return FALSE
	if(has_buckled_mobs()) //to prevent spam/queing up attacks
		return FALSE
	if(victim.buckled)
		return FALSE
	victim.forceMove(loc)
	return buckle_mob(victim, force = TRUE, check_loc = FALSE)


/obj/structure/kitchenspike/is_user_buckle_possible(mob/living/target, mob/user, check_loc = TRUE)
	return FALSE	//Don't want them getting put on the rack other than by spiking


/obj/structure/kitchenspike/user_unbuckle_mob(mob/living/target, mob/living/user)
	if(target != user)
		target.visible_message(
			span_notice("[user] tries to pull [target] free of [src]!"),
			span_notice("[user] is trying to pull you off [src], opening up fresh wounds!"),
			span_italics("You hear a squishy wet noise."),
		)
		if(!do_after(user, 30 SECONDS, src))
			if(target?.buckled)
				target.visible_message(
					span_notice("[user] fails to free [target]!"),
					span_notice("[user] fails to pull you off of [src].")
				)
			return
	else
		target.visible_message(
			span_warning("[target] struggles to break free from [src]!"),
			span_notice("You struggle to break free from [src], exacerbating your wounds! (Stay still for two minutes.)"),
			span_italics("You hear a wet squishing noise.."),
		)
		target.adjustBruteLoss(30)
		if(!do_after(target, 2 MINUTES, src))
			if(target?.buckled)
				to_chat(target, span_warning("You fail to free yourself!"))
			return
	return ..()


/obj/structure/kitchenspike/post_buckle_mob(mob/living/carbon/human/target)
	playsound(loc, 'sound/effects/splat.ogg', 25, TRUE)
	target.emote("scream")
	if(ishuman(target))
		target.add_splatter_floor()
	target.adjustBruteLoss(30)
	target.setDir(SOUTH)
	var/matrix/m180 = matrix(target.transform)
	m180.Turn(180)
	animate(target, transform = m180, time = 0.3 SECONDS)
	target.pixel_x = target.base_pixel_x
	target.pixel_y = target.base_pixel_y + PIXEL_Y_OFFSET_LYING


/obj/structure/kitchenspike/post_unbuckle_mob(mob/living/target)
	target.adjustBruteLoss(30)
	target.emote("scream")
	var/matrix/m180 = matrix(target.transform)
	m180.Turn(180)
	animate(target, transform = m180, time = 0.3 SECONDS)
	target.pixel_x = target.base_pixel_x + target.body_position_pixel_x_offset
	target.pixel_y = target.base_pixel_y + target.body_position_pixel_y_offset
	target.AdjustWeakened(20 SECONDS)


/obj/structure/kitchenspike/deconstruct(disassembled = TRUE)
	if(disassembled)
		var/obj/F = new /obj/structure/kitchenspike_frame(loc)
		transfer_fingerprints_to(F)
	else
		new /obj/item/stack/sheet/metal(loc, 4)
	new /obj/item/stack/rods(loc, 4)
	qdel(src)

