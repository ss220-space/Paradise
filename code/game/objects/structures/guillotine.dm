#define GUILLOTINE_BLADE_MAX_SHARP  10 // This is maxiumum sharpness that will decapitate without failure
#define GUILLOTINE_DECAP_MIN_SHARP  7  // Minimum amount of sharpness for decapitation. Any less and it will just deal brute damage
#define GUILLOTINE_ANIMATION_LENGTH 9 // How many deciseconds the animation is
#define GUILLOTINE_BLADE_RAISED     1
#define GUILLOTINE_BLADE_RAISING    2
#define GUILLOTINE_BLADE_DROPPING   3
#define GUILLOTINE_BLADE_DROPPED    4
#define GUILLOTINE_BLADE_SHARPENING 5

#define GUILLOTINE_HEAD_OFFSET      16 // How much we need to move the player to center their head
#define GUILLOTINE_LAYER_DIFF       1.2 // How much to increase/decrease a head when it's buckled/unbuckled
#define GUILLOTINE_ACTIVATE_DELAY   30 // Delay for executing someone
#define GUILLOTINE_WRENCH_DELAY     10

#define GUILLOTINE_ACTION_INUSE      1
#define GUILLOTINE_ACTION_WRENCH     2

/obj/structure/guillotine
	name = "guillotine"
	desc = "A large structure used to remove the heads of traitors and treasonists."
	icon = 'icons/obj/guillotine.dmi'
	icon_state = "guillotine_raised"
	can_buckle = TRUE
	anchored = TRUE
	density = FALSE
	buckle_lying = 0
	buckle_prevents_pull = TRUE
	layer = ABOVE_MOB_LAYER
	var/blade_status = GUILLOTINE_BLADE_RAISED
	var/blade_sharpness = GUILLOTINE_BLADE_MAX_SHARP // How sharp the blade is
	var/kill_count = 0
	var/force_clap = FALSE //You WILL clap if I want you to
	var/current_action = NONE// What's currently happening to the guillotine


/obj/structure/guillotine/examine(mob/user)
	. = ..()
	var/msg = ""
	msg += "It is [anchored ? "wrenched to the floor." : "unsecured. A wrench should fix that."]<br/>"

	if(blade_status == GUILLOTINE_BLADE_RAISED)
		msg += "The blade is raised, ready to fall, and"

		if(blade_sharpness >= GUILLOTINE_DECAP_MIN_SHARP)
			msg += "<span class='danger'> looks sharp enough to decapitate without any resistance.</span>"
		else
			msg += " doesn't look particularly sharp. Perhaps a whetstone can be used to sharpen it."
	else
		msg += "The blade is hidden inside the stocks."

	if(has_buckled_mobs())
		msg += "<br/>"
		msg += "Someone appears to be strapped in. You can help them out, or you can harm them by activating the guillotine."
	. += "<span class='notice'>[msg]</span>"


/obj/structure/guillotine/update_icon_state()
	switch(blade_status)
		if(GUILLOTINE_BLADE_DROPPED)
			icon_state = "guillotine"
		if(GUILLOTINE_BLADE_RAISED)
			icon_state = "guillotine_raised"
		if(GUILLOTINE_BLADE_RAISING)
			icon_state = "guillotine_raise"
		if(GUILLOTINE_BLADE_DROPPING)
			icon_state = "guillotine_drop"


/obj/structure/guillotine/update_overlays()
	. = ..()
	switch(kill_count)
		if(1)
			. += mutable_appearance(icon, "guillotine_bloody_overlay")
		if(2)
			. += mutable_appearance(icon, "guillotine_bloodier_overlay")
		if(3 to INFINITY)
			. += mutable_appearance(icon, "guillotine_bloodiest_overlay")


/obj/structure/guillotine/attack_hand(mob/user)

	// Currently being used by something
	if(current_action)
		return

	switch(blade_status)
		if(GUILLOTINE_BLADE_RAISING, GUILLOTINE_BLADE_DROPPING)
			return
		if(GUILLOTINE_BLADE_DROPPED)
			add_fingerprint(user)
			blade_status = GUILLOTINE_BLADE_RAISING
			update_icon(UPDATE_ICON_STATE)
			addtimer(CALLBACK(src, PROC_REF(raise_blade)), GUILLOTINE_ANIMATION_LENGTH)
			return
		if(GUILLOTINE_BLADE_RAISED)
			if(has_buckled_mobs())
				if(user.a_intent == INTENT_HARM)
					user.visible_message("<span class='warning'>[user] begins to pull the lever!</span>",
						                 "<span class='warning'>You begin to the pull the lever.</span>")
					current_action = GUILLOTINE_ACTION_INUSE

					if(do_after(user, GUILLOTINE_ACTIVATE_DELAY, src) && blade_status == GUILLOTINE_BLADE_RAISED)
						add_fingerprint(user)
						current_action = NONE
						blade_status = GUILLOTINE_BLADE_DROPPING
						update_icon(UPDATE_ICON_STATE)
						playsound(src, 'sound/items/unsheath.ogg', 100, 1)
						addtimer(CALLBACK(src, PROC_REF(drop_blade), user), GUILLOTINE_ANIMATION_LENGTH - 2) // Minus two so we play the sound and decap faster
					else
						current_action = NONE
				else
					add_fingerprint(user)
					unbuckle_all_mobs()
			else
				add_fingerprint(user)
				blade_status = GUILLOTINE_BLADE_DROPPING
				update_icon(UPDATE_ICON_STATE)
				playsound(src, 'sound/items/unsheath.ogg', 100, 1)
				addtimer(CALLBACK(src, PROC_REF(drop_blade)), GUILLOTINE_ANIMATION_LENGTH)


/obj/structure/guillotine/proc/raise_blade()
	blade_status = GUILLOTINE_BLADE_RAISED
	update_icon(UPDATE_ICON_STATE)


/obj/structure/guillotine/proc/drop_blade(mob/user)
	if(has_buckled_mobs() && blade_sharpness)
		var/mob/living/carbon/human/H = buckled_mobs[1]

		if(!H)
			blade_status = GUILLOTINE_BLADE_DROPPED
			update_icon(UPDATE_ICON_STATE)
			return

		var/obj/item/organ/external/head/head = H.get_organ(BODY_ZONE_HEAD)

		if(QDELETED(head))
			blade_status = GUILLOTINE_BLADE_DROPPED
			update_icon(UPDATE_ICON_STATE)
			return

		playsound(src, 'sound/weapons/bladeslice.ogg', 100, 1)
		if(blade_sharpness >= GUILLOTINE_DECAP_MIN_SHARP || head.brute_dam >= 100)
			head.droplimb()
			add_attack_logs(user, H, "beheaded with [src]")
			H.regenerate_icons()
			unbuckle_all_mobs()
			kill_count++
			update_icon(UPDATE_OVERLAYS)

			if(force_clap)
				// The crowd is pleased
				// The delay is to make large crowds have a longer lasting applause
				var/delay_offset = 0
				for(var/mob/living/carbon/human/HM in viewers(src, 7))
					addtimer(CALLBACK(HM, TYPE_PROC_REF(/mob, emote), "clap"), delay_offset * 0.3)
					delay_offset++
		else
			H.apply_damage(15 * blade_sharpness, BRUTE, head)
			add_attack_logs(user, H, "non-fatally dropped the blade on with [src]")
			H.emote("scream")

		if(blade_sharpness > 1)
			blade_sharpness -= 1

	blade_status = GUILLOTINE_BLADE_DROPPED
	update_icon(UPDATE_ICON_STATE)


/obj/structure/guillotine/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/whetstone))
		add_fingerprint(user)
		if(blade_status == GUILLOTINE_BLADE_SHARPENING)
			to_chat(user, span_warning("The blade is already sharpening by someone else."))
			return ATTACK_CHAIN_PROCEED
		if(blade_status != GUILLOTINE_BLADE_RAISED)
			to_chat(user, span_warning("You need to raise the blade in order to sharpen it."))
			return ATTACK_CHAIN_PROCEED
		if(blade_sharpness >= GUILLOTINE_BLADE_MAX_SHARP)
			to_chat(user, span_warning("The blade is sharp enough."))
			return ATTACK_CHAIN_PROCEED
		blade_status = GUILLOTINE_BLADE_SHARPENING
		if(!do_after(user, 0.7 SECONDS, src, category = DA_CAT_TOOL) || blade_status != GUILLOTINE_BLADE_SHARPENING)
			blade_status = GUILLOTINE_BLADE_RAISED
			return ATTACK_CHAIN_PROCEED
		blade_status = GUILLOTINE_BLADE_RAISED
		blade_sharpness++
		playsound(loc, 'sound/items/screwdriver.ogg', 100, TRUE)
		user.visible_message(
			span_notice("[user] sharpens the large blade of the guillotine."),
			span_notice("You sharpen the large blade of the guillotine."),
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/structure/guillotine/wrench_act(mob/user, obj/item/I)
	if(current_action)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	current_action = GUILLOTINE_ACTION_WRENCH
	if(!I.use_tool(src, user, GUILLOTINE_WRENCH_DELAY, volume = I.tool_volume))
		current_action = NONE
		return
	if(has_buckled_mobs())
		to_chat(user, "<span class='warning'>Can't unfasten, someone's strapped in!</span>")
		return

	current_action = NONE
	to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [src].</span>")
	set_anchored(!anchored)
	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
	dir = SOUTH

/obj/structure/guillotine/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		WELDER_SLICING_SUCCESS_MESSAGE
		var/turf/T = get_turf(src)
		if(blade_sharpness == GUILLOTINE_BLADE_MAX_SHARP)
			new /obj/item/stack/sheet/plasteel(T, 3)
		else
			new /obj/item/stack/sheet/plasteel(T, 2) //prevents reconstructing to sharpen the guillotine without additional plasteel
		new /obj/item/stack/sheet/wood(T, 20)
		new /obj/item/stack/cable_coil(T, 10)
		qdel(src)


/obj/structure/guillotine/is_user_buckle_possible(mob/living/target, mob/user, check_loc = TRUE)
	if(!anchored)
		to_chat(user, span_warning("The [src] needs to be wrenched to the floor!"))
		return FALSE

	if(!ishuman(target))
		to_chat(user, span_warning("It doesn't look like [target.p_they()] can fit into this properly!"))
		return FALSE // Can't decapitate non-humans

	if(blade_status != GUILLOTINE_BLADE_RAISED)
		to_chat(user, span_warning("You need to raise the blade before buckling someone in!"))
		return FALSE

	return ..(target, user, FALSE)


/obj/structure/guillotine/post_buckle_mob(mob/living/target)
	target.pixel_y += -GUILLOTINE_HEAD_OFFSET // Offset their body so it looks like they're in the guillotine
	target.layer += GUILLOTINE_LAYER_DIFF


/obj/structure/guillotine/post_unbuckle_mob(mob/living/target)
	target.pixel_y -= -GUILLOTINE_HEAD_OFFSET // Move their body back
	target.layer -= GUILLOTINE_LAYER_DIFF


#undef GUILLOTINE_BLADE_MAX_SHARP
#undef GUILLOTINE_DECAP_MIN_SHARP
#undef GUILLOTINE_ANIMATION_LENGTH
#undef GUILLOTINE_BLADE_RAISED
#undef GUILLOTINE_BLADE_RAISING
#undef GUILLOTINE_BLADE_DROPPING
#undef GUILLOTINE_BLADE_DROPPED
#undef GUILLOTINE_BLADE_SHARPENING
#undef GUILLOTINE_HEAD_OFFSET
#undef GUILLOTINE_LAYER_DIFF
#undef GUILLOTINE_ACTIVATE_DELAY
#undef GUILLOTINE_WRENCH_DELAY
#undef GUILLOTINE_ACTION_INUSE
#undef GUILLOTINE_ACTION_WRENCH
