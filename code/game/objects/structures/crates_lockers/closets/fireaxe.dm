//I still dont think this should be a closet but whatever
/obj/structure/closet/fireaxecabinet
	name = "fire axe cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	icon_state = "fireaxe_full_0hits"
	icon_closed = "fireaxe_full_0hits"
	icon_opened = "fireaxe_full_open"
	anchored = TRUE
	density = FALSE
	no_overlays = TRUE
	armor = list(MELEE = 50, BULLET = 20, LASER = 0, ENERGY = 100, BOMB = 10, RAD = 100, FIRE = 90, ACID = 50)
	var/obj/item/twohanded/fireaxe/fireaxe
	var/localopened = FALSE //Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	opened = TRUE
	var/hitstaken = FALSE
	locked = TRUE
	var/smashed = FALSE
	var/operating = FALSE
	var/has_axe = null // Use a string over a boolean value to make the sprite names more readable


/obj/structure/closet/fireaxecabinet/Destroy()
	if(!obj_integrity)
		if(fireaxe)
			fireaxe.forceMove(loc)
			fireaxe = null
		else
			QDEL_NULL(fireaxe)
	return ..()


/obj/structure/closet/fireaxecabinet/populate_contents()
	fireaxe = new(src)
	has_axe = "full"
	update_icon(UPDATE_ICON_STATE)	// So its initial icon doesn't show it without the fireaxe


/obj/structure/closet/fireaxecabinet/examine(mob/user)
	. = ..()
	if(!smashed)
		. += span_notice("Use a multitool to lock/unlock it.")
	else
		. += span_notice("It is damaged beyond repair.")


/obj/structure/closet/fireaxecabinet/multitool_act(mob/living/user, obj/item/I)
	if(smashed)
		return FALSE

	. = TRUE
	if(locked)
		to_chat(user, span_warning("Resetting circuitry..."))
		if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || smashed || !locked)
			return .
		locked = FALSE
		to_chat(user, span_caution("You disable the locking modules."))
		update_icon(UPDATE_ICON_STATE)
		return .

	if(localopened)
		add_fingerprint(user)
		operate_panel()
		return .

	to_chat(user, span_warning("Resetting circuitry..."))
	playsound(user, 'sound/machines/lockenable.ogg', 50, TRUE)
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || smashed || locked)
		return .

	locked = TRUE
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_caution("You re-enable the locking modules."))


/obj/structure/closet/fireaxecabinet/attackby(obj/item/I, mob/living/user, params)
	. = ATTACK_CHAIN_BLOCKED_ALL
	add_fingerprint(user)

	if(isrobot(user) || locked)
		if(smashed || localopened)
			if(localopened)
				operate_panel()
			return .

		user.do_attack_animation(src)
		playsound(user, 'sound/effects/glasshit.ogg', 100, TRUE) //We don't want this playing every time
		if(I.force < 15)
			to_chat(user, span_notice("The cabinet's protective glass glances off the hit."))
			return .

		hitstaken++
		if(hitstaken == 4)
			playsound(user, 'sound/effects/glassbr3.ogg', 100, TRUE) //Break cabinet, receive goodies. Cabinet's fucked for life after that.
			smashed = TRUE
			locked = FALSE
			localopened = TRUE
		update_icon(UPDATE_ICON_STATE)
		return .

	if(istype(I, /obj/item/twohanded/fireaxe) && localopened)
		if(!fireaxe)
			var/obj/item/twohanded/fireaxe/placed_axe = I
			if(HAS_TRAIT(placed_axe, TRAIT_WIELDED))
				to_chat(user, span_warning("Unwield [placed_axe] first."))
				return .
			if(!user.drop_transfer_item_to_loc(placed_axe, src))
				to_chat(user, span_warning("[placed_axe] stays stuck to your hands!"))
				return .
			fireaxe = placed_axe
			has_axe = "full"
			to_chat(user, span_notice("You place [placed_axe] back in the [name]."))
			update_icon(UPDATE_ICON_STATE)
			return .

		if(smashed)
			return .

		operate_panel()
		return .

	if(smashed)
		return .

	operate_panel()


/obj/structure/closet/fireaxecabinet/attack_hand(mob/user)
	if(locked)
		to_chat(user, span_warning("The cabinet won't budge!"))
		return

	if(localopened && fireaxe)
		fireaxe.forceMove_turf()
		user.put_in_hands(fireaxe, ignore_anim = FALSE)
		to_chat(user, span_notice("You take [fireaxe] from [src]."))
		has_axe = "empty"
		fireaxe = null

		add_fingerprint(user)
		update_icon(UPDATE_ICON_STATE)
		return

	if(smashed)
		return

	operate_panel()


/obj/structure/closet/fireaxecabinet/attack_tk(mob/user)
	if(localopened && fireaxe)
		fireaxe.forceMove(loc)
		to_chat(user, span_notice("You telekinetically remove \the [fireaxe]."))
		has_axe = "empty"
		fireaxe = null
		update_icon(UPDATE_ICON_STATE)
		return
	attack_hand(user)


/obj/structure/closet/fireaxecabinet/attack_ai(mob/user)
	if(smashed)
		to_chat(user, span_warning("The security of the cabinet is compromised."))
		return

	locked = !locked
	if(locked)
		to_chat(user, span_warning("Cabinet locked."))
	else
		to_chat(user, span_notice("Cabinet unlocked."))

/obj/structure/closet/fireaxecabinet/shove_impact(mob/living/target, mob/living/attacker)
	// no, you can't shove people into a fireaxe cabinet either
	return FALSE

/obj/structure/closet/fireaxecabinet/proc/operate_panel()
	if(operating)
		return
	operating = TRUE
	localopened = !localopened
	do_animate()
	operating = FALSE


/obj/structure/closet/fireaxecabinet/proc/do_animate()
	if(!localopened)
		flick("fireaxe_[has_axe]_closing", src)
	else
		flick("fireaxe_[has_axe]_opening", src)
	sleep(1 SECONDS)
	update_icon(UPDATE_ICON_STATE)


/obj/structure/closet/fireaxecabinet/update_icon_state()
	if(localopened && !smashed)
		icon_state = "fireaxe_[has_axe]_open"
	else
		icon_state = "fireaxe_[has_axe]_[hitstaken]hits"


/obj/structure/closet/fireaxecabinet/open()
	return


/obj/structure/closet/fireaxecabinet/close()
	return


/obj/structure/closet/fireaxecabinet/welder_act(mob/user, obj/item/I) //A bastion of sanity in a sea of madness
	return



//mining "fireaxe"
/obj/structure/fishingrodcabinet
	name = "fishing cabinet"
	desc = "There is a small label that reads \"Fo* Em**gen*y u*e *nly\". All the other text is scratched out and replaced with various fish weights."
	icon = 'icons/obj/closet.dmi'
	icon_state = "fishingrod"
	anchored = TRUE
	var/obj/item/twohanded/fishingrod/olreliable //what the fuck?


/obj/structure/fishingrodcabinet/Initialize(mapload)
	. = ..()
	olreliable = new(src)
	update_icon(UPDATE_OVERLAYS)


/obj/structure/fishingrodcabinet/update_overlays()
	. = ..()
	if(olreliable)
		. += "rod"


/obj/structure/fishingrodcabinet/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/twohanded/fishingrod))
		var/obj/item/twohanded/fishingrod/rod = I
		if(HAS_TRAIT(rod, TRAIT_WIELDED))
			to_chat(user, span_warning("Unwield [rod] first."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(rod, src))
			return ..()
		olreliable = rod
		to_chat(user, span_notice("You place [rod] back in [src]."))
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/fishingrodcabinet/attack_hand(mob/user)
	if(!olreliable)
		return ..()

	add_fingerprint(user)
	olreliable.forceMove_turf()
	user.put_in_hands(olreliable, ignore_anim = FALSE)
	to_chat(user, span_notice("You take [olreliable] from [src]."))
	olreliable = null
	update_icon(UPDATE_OVERLAYS)

