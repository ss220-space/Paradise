// Basically they are for the firing range
/obj/structure/target_stake
	name = "target stake"
	desc = "A thin platform with negatively-magnetized wheels."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_stake"
	density = TRUE
	flags = CONDUCT
	pull_push_slowdown = 1.3
	/// The current pinned target
	var/obj/item/target/pinned_target
	/// Recursion avoidance
	var/currently_moving = FALSE


/obj/structure/target_stake/Destroy()
	QDEL_NULL(pinned_target)
	return ..()


/obj/structure/target_stake/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(currently_moving)
		return FALSE
	. = ..()
	// Move the pinned target along with the stake
	if(!pinned_target)
		return .
	pinned_target.currently_moving = TRUE
	. = pinned_target.Move(newloc, direct)
	pinned_target?.set_glide_size(glide_size)
	pinned_target?.currently_moving = FALSE
	if(!. && loc && pinned_target && pinned_target.loc != loc)
		pinned_target.forceMove(loc)


/obj/structure/target_stake/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	// Putting objects on the stake. Most importantly, targets
	if(istype(I, /obj/item/target))
		add_fingerprint(user)
		var/obj/item/target/target = I
		if(pinned_target)
			to_chat(user, span_warning("The [pinned_target.name] is already pinned to [src]."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(target, loc))
			return ..()
		set_density(FALSE)
		target.set_density(FALSE)
		target.layer = 3.1
		target.stake = src
		pinned_target = target
		to_chat(user, span_notice("You slide [target] into [src]."))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/target_stake/attack_hand(mob/user)
	// taking pinned targets off!
	if(!pinned_target)
		return ..()

	to_chat(user, span_notice("You take [pinned_target] out of the stake."))
	add_fingerprint(user)
	pinned_target.add_fingerprint(user)
	set_density(TRUE)
	pinned_target.set_density(initial(density))
	pinned_target.layer = initial(pinned_target.layer)
	user.put_in_hands(pinned_target, ignore_anim = FALSE)
	pinned_target.stake = null
	pinned_target = null

