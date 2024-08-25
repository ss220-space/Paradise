/**
 * This is the proc that handles the order of an item_attack.
 *
 * The order of procs called is:
 * * [/atom/proc/tool_attack_chain]
 * * [/obj/item/proc/pre_attackby]
 * * [/atom/proc/attackby]
 * * [/obj/item/proc/afterattack]
 *
 * All the procs in the attack chain SHOULD return one of the two core bitflags:
 * * ATTACK_CHAIN_PROCEED - to proceed into the next step
 * * ATTACK_CHAIN_BLOCKED - to stop attack chain on the current step (will not affect afterattack, since it has a separate flag)
 *
 * Optional bitflags:
 * * ATTACK_CHAIN_SUCCESS - indicates that something meaningful was done on one of the previous steps; basically additional to ATTACK_CHAIN_BLOCKED flag, we are checking to proceed, in some of the children overrides
 * * ATTACK_CHAIN_NO_AFTERATTACK - completely skips afterattack
 *
 * Returns a combination of all the bitflags we get on every step of the chain.
 */
/obj/item/proc/melee_attack_chain(mob/user, atom/target, params)
	. = ATTACK_CHAIN_PROCEED

	var/user_type = "[user.type]"
	var/item_type = "[type]"
	var/target_type = "[target.type]"

	var/tool_chain_result = tool_attack_chain(user, target, params)
	if(!(tool_chain_result & ATTACK_CHAIN_CORE_RETURN_BITFLAGS))
		CRASH("tool_attack_chain() must return one of the core ATTACK_CHAIN_* bitflags, please consult code/__DEFINES/combat.dm; user = [user_type]; item = [item_type]; target = [target_type]")

	. |= tool_chain_result
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		mark_target(target)
		return .

	var/pre_attackby_result = pre_attackby(target, user, params)
	if(!(pre_attackby_result & ATTACK_CHAIN_CORE_RETURN_BITFLAGS))
		mark_target(target)
		CRASH("pre_attackby() must return one of the core ATTACK_CHAIN_* bitflags, please consult code/__DEFINES/combat.dm; user = [user_type]; item = [item_type]; target = [target_type]")

	. |= pre_attackby_result
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		mark_target(target)
		return .

	var/attackby_result = target.attackby(src, user, params)
	if(!(attackby_result & ATTACK_CHAIN_CORE_RETURN_BITFLAGS))
		mark_target(target)
		CRASH("attackby() must return one of the core ATTACK_CHAIN_* bitflags, please consult code/__DEFINES/combat.dm; user = [user_type]; item = [item_type]; target = [target_type]")

	. |= attackby_result
	// yes a lot of QDELETED checks but attackby is a longest spaghetti code in the entire game
	if((. & ATTACK_CHAIN_NO_AFTERATTACK) || QDELETED(src) || QDELETED(target) || QDELETED(user))
		mark_target(target)
		return .

	afterattack(target, user, TRUE, params)
	mark_target(target)

/// Used to mark a target for the demo system during a melee attack chain, call this before return
/obj/item/proc/mark_target(atom/target)
	SSdemo.mark_dirty(src)
	if(isturf(target))
		SSdemo.mark_turf(target)
	else
		SSdemo.mark_dirty(target)

/**
 * Called on the item to check if it has any of the tool's behavior
 *
 * Arguments:
 * * mob/user - The mob holding the tool
 * * atom/target - The atom about to be tooled
 * * params - click params such as alt/shift etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/obj/item/proc/tool_attack_chain(mob/user, atom/target, params)
	. = ATTACK_CHAIN_PROCEED
	if(!tool_behaviour)
		return .
	if(target.tool_act(user, src, tool_behaviour))
		return ATTACK_CHAIN_BLOCKED


// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	var/signal_ret = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user)
	if(signal_ret & COMPONENT_NO_INTERACT)
		return FALSE
	if(signal_ret & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	SSdemo.mark_dirty(src)


/obj/item/attack_self_tk(mob/user)
	attack_self(user)


/**
 * Called on the item before it hits something
 *
 * Arguments:
 * * atom/target - The atom about to be hit
 * * mob/living/user - The mob doing the htting
 * * params - click params such as alt/shift etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/obj/item/proc/pre_attackby(atom/target, mob/living/user, params)
	. = ATTACK_CHAIN_PROCEED
	var/signal_out = SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACKBY, target, user, params)
	if(signal_out & COMPONENT_NO_AFTERATTACK)
		. |= ATTACK_CHAIN_NO_AFTERATTACK
	if(signal_out & COMPONENT_CANCEL_ATTACK_CHAIN)
		return .|ATTACK_CHAIN_BLOCKED
	var/is_hot = is_hot(src)
	if(is_hot && target.reagents && !ismob(target))
		to_chat(user, span_notice("You heat [target] with [src]."))
		target.reagents.temperature_reagents(is_hot)


/**
 * Called on an object being hit by an item
 *
 * Arguments:
 * * obj/item/I - The item hitting this atom
 * * mob/user - The wielder of this item
 * * params - click params such as alt/shift etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/atom/proc/attackby(obj/item/I, mob/user, params)
	. = ATTACK_CHAIN_PROCEED
	var/signal_out = SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, I, user, params)
	if(signal_out & COMPONENT_CANCEL_ATTACK_CHAIN)
		. |= ATTACK_CHAIN_BLOCKED
	if(signal_out & COMPONENT_NO_AFTERATTACK)
		. |= ATTACK_CHAIN_NO_AFTERATTACK


/obj/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .
	if(obj_flags & IGNORE_HITS)
		return .
	. |= I.attack_obj(src, user, params)


/mob/living/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .
	if(attempt_harvest(I, user))
		return .|ATTACK_CHAIN_BLOCKED_ALL
	user.changeNext_move(I.attack_speed)
	. |= I.attack(src, user, params, user.zone_selected)


/**
 * Called from [/mob/living/proc/attackby]
 *
 * Arguments:
 * * mob/living/target - The mob being hit by this item
 * * mob/living/user - The mob hitting with this item
 * * params - Click params of this attack
 * * def_zone - Bodypart zone, targeted by the wielder of this item
 * * skip_attack_anim - If TRUE will not animate hitting mob's attack
 */
/obj/item/proc/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	var/signal_out = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, target, user, params, def_zone)

	if(signal_out & COMPONENT_NO_AFTERATTACK)
		. |= ATTACK_CHAIN_NO_AFTERATTACK

	if(signal_out & COMPONENT_CANCEL_ATTACK_CHAIN)
		return .|ATTACK_CHAIN_BLOCKED

	if(signal_out & COMPONENT_SKIP_ATTACK)
		return .

	if(item_flags & NOBLUDGEON)
		return .

	if(try_item_eat(target, user))
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(force && (HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt))
		to_chat(user, span_warning("You don't want to harm other living beings!"))
		return .

	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, target, params, def_zone)

	if(!force)
		playsound(target.loc, 'sound/weapons/tap.ogg', get_clamped_volume(), TRUE, -1)
	else
		add_attack_logs(user, target, "Attacked with [name] ([uppertext(user.a_intent)]) ([uppertext(damtype)]), DMG: [force])", (target.ckey && force > 0 && damtype != STAMINA) ? null : ATKLOG_ALMOSTALL)
		if(hitsound)
			playsound(target.loc, hitsound, get_clamped_volume(), TRUE, -1)

	target.lastattacker = user.real_name
	target.lastattackerckey = user.ckey

	if(!skip_attack_anim)
		user.do_attack_animation(target)

	add_fingerprint(user)
	. |= target.proceed_attack_results(src, user, params, def_zone)


/// The equivalent of the standard version of [/obj/item/proc/attack] but for object targets.
/obj/item/proc/attack_obj(obj/object, mob/living/user, params)
	. = ATTACK_CHAIN_PROCEED

	var/signal_out = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_OBJ, object, user, params)

	if(signal_out & COMPONENT_NO_AFTERATTACK)
		. |= ATTACK_CHAIN_NO_AFTERATTACK

	if(signal_out & COMPONENT_CANCEL_ATTACK_CHAIN)
		return .|ATTACK_CHAIN_BLOCKED

	if(signal_out & COMPONENT_SKIP_ATTACK)
		return .

	if(item_flags & NOBLUDGEON)
		return .

	add_fingerprint(user)
	user.do_attack_animation(object)
	user.changeNext_move(attack_speed)
	. |= object.proceed_attack_results(src, user, params)


/**
 * Called from [/obj/item/proc/attack] and [/obj/item/proc/attack_obj]
 *
 * Arguments:
 * * obj/item/I - The item hitting this atom
 * * mob/living/user - The wielder of this item
 * * params - Click params of this attack
 * * def_zone - Bodypart zone, targeted by the wielder of this item
 */
/atom/movable/proc/proceed_attack_results(obj/item/I, mob/living/user, params, def_zone)
	return ATTACK_CHAIN_PROCEED_SUCCESS


/obj/proceed_attack_results(obj/item/I, mob/living/user, params)
	. = ATTACK_CHAIN_PROCEED_SUCCESS
	if(!I.force)
		user.visible_message(
			span_warning("[user] gently pokes [src] with [I]."),
			span_warning("You gently poke [src] with [I]."),
		)
		return .
	user.visible_message(
		span_danger("[user] has hit [src] with [I]!"),
		span_danger("You have hit [src] with [I]!"),
	)
	take_damage(I.force, I.damtype, MELEE, TRUE, get_dir(user, src), I.armour_penetration)
	if(QDELETED(src))	// thats a pretty common behavior with objects, when they take damage
		return ATTACK_CHAIN_BLOCKED_ALL


/mob/living/proceed_attack_results(obj/item/I, mob/living/user, params, def_zone)
	. = ATTACK_CHAIN_PROCEED_SUCCESS

	send_item_attack_message(I, user, def_zone)
	if(!I.force)
		return .

	var/apply_damage_result = apply_damage(I.force, I.damtype, def_zone, sharp = is_sharp(I), used_weapon = I)
	// if we are hitting source with real weapon and any brute damage was done, we apply victim's blood everywhere
	if(apply_damage_result && I.damtype == BRUTE && prob(33))
		I.add_mob_blood(src)
		add_splatter_floor()
		if(get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
			user.add_mob_blood(src)

	if(QDELETED(src))	// rare, but better be safe
		return ATTACK_CHAIN_BLOCKED_ALL


/// Return sound volumet between 10 and 100, depending on the item weight class
/obj/item/proc/get_clamped_volume()
	if(!w_class)
		return 0
	if(force)
		// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
		return clamp((force + w_class) * 4, 30, 100)
	// Multiply the item's weight class by 6, then clamp the value between 10 and 100
	return clamp(w_class * 6, 10, 100)


/// Sends a default message feedback about being attacked by other mob
/mob/living/proc/send_item_attack_message(obj/item/I, mob/living/user, def_zone)
	if(I.item_flags & SKIP_ATTACK_MESSAGE)
		return

	if(!I.force)
		visible_message(
			span_warning("[user] gently taps [src] with [I]."),
			span_warning("[user] gently taps you with [I]."),
			ignored_mobs = user,
		)
		to_chat(user, span_warning("You gently tap [src] with [I]."))
		return

	var/message_verb = "attacked"
	if(length(I.attack_verb))
		message_verb = "[pick(I.attack_verb)]"

	visible_message(
		span_danger("[user] has [message_verb] [src] with [I]!"),
		span_userdanger("[user] has [message_verb] you with [I]!"),
		ignored_mobs = user,
	)
	to_chat(user, span_danger("You have [message_verb] [src] with [I]!"))
