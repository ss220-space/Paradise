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
/obj/item/proc/melee_attack_chain(mob/user, atom/target, list/modifiers, list/attack_modifiers = list())
	. = ATTACK_CHAIN_PROCEED

	var/user_type = "[user.type]"
	var/item_type = "[type]"
	var/target_type = "[target.type]"

	var/tool_chain_result = tool_attack_chain(user, target, modifiers)

	var/is_right_clicking = LAZYACCESS(modifiers, RIGHT_CLICK)
	if(!(tool_chain_result & ATTACK_CHAIN_CORE_RETURN_BITFLAGS))
		CRASH("tool_attack_chain() must return one of the core ATTACK_CHAIN_* bitflags, please consult code/__DEFINES/combat.dm; user = [user_type]; item = [item_type]; target = [target_type]")

	. |= tool_chain_result
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		mark_target(target)
		return .

	var/pre_attackby_result

	if(is_right_clicking)
		switch(pre_attack_secondary(target, user, modifiers, attack_modifiers))
			if(SECONDARY_ATTACK_CALL_NORMAL)
				pre_attackby_result = pre_attackby(target, user, modifiers, attack_modifiers)
			if(SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				return TRUE
			if(SECONDARY_ATTACK_CONTINUE_CHAIN)
				EMPTY_BLOCK_GUARD // Normal behavior
			else
				CRASH("pre_attack_secondary must return an SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")
	else
		pre_attackby_result = pre_attackby(target, user, modifiers, attack_modifiers)

	if(!(pre_attackby_result & ATTACK_CHAIN_CORE_RETURN_BITFLAGS))
		mark_target(target)
		CRASH("pre_attackby() must return one of the core ATTACK_CHAIN_* bitflags, please consult code/__DEFINES/combat.dm; user = [user_type]; item = [item_type]; target = [target_type]")

	. |= pre_attackby_result
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		mark_target(target)
		return .

	var/attackby_result

	if(is_right_clicking)
		switch(target.attackby_secondary(src, user, modifiers, attack_modifiers))
			if(SECONDARY_ATTACK_CALL_NORMAL)
				attackby_result = target.attackby(src, user, modifiers, attack_modifiers)
			if(SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				return TRUE
			if(SECONDARY_ATTACK_CONTINUE_CHAIN)
				EMPTY_BLOCK_GUARD // Normal behavior
			else
				CRASH("attackby_secondary must return an SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")
	else
		attackby_result = target.attackby(src, user, modifiers, attack_modifiers)

	if(!(attackby_result & ATTACK_CHAIN_CORE_RETURN_BITFLAGS))
		mark_target(target)
		CRASH("attackby() must return one of the core ATTACK_CHAIN_* bitflags, please consult code/__DEFINES/combat.dm; user = [user_type]; item = [item_type]; target = [target_type]")

	. |= attackby_result
	// yes a lot of QDELETED checks but attackby is a longest spaghetti code in the entire game
	if((. & ATTACK_CHAIN_NO_AFTERATTACK) || QDELETED(src) || QDELETED(target) || QDELETED(user))
		mark_target(target)
		return .

	afterattack(target, user, TRUE, modifiers, .)
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
/obj/item/proc/tool_attack_chain(mob/user, atom/target, list/modifiers)
	. = ATTACK_CHAIN_PROCEED
	if(target.base_item_interaction(user, src, modifiers))
		return ATTACK_CHAIN_BLOCKED

// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	var/signal_ret = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user)
	if(signal_ret & COMPONENT_NO_INTERACT)
		return FALSE
	if(signal_ret & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	SSdemo.mark_dirty(src)

/// Called when the item is in the active hand, and right-clicked. Intended for alternate or opposite functions, such as lowering reagent transfer amount. At the moment, there is no verb or hotkey.
/obj/item/proc/attack_self_secondary(mob/user, list/modifiers)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF_SECONDARY, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

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
/obj/item/proc/pre_attackby(atom/target, mob/living/user, modifiers)
	. = ATTACK_CHAIN_PROCEED
	var/signal_out = SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACKBY, target, user, modifiers)
	if(signal_out & COMPONENT_NO_AFTERATTACK)
		. |= ATTACK_CHAIN_NO_AFTERATTACK
	if(signal_out & COMPONENT_CANCEL_ATTACK_CHAIN)
		return .|ATTACK_CHAIN_BLOCKED
	var/temperature = get_temperature()
	if(temperature && target.reagents && !ismob(target) && !istype(target, /obj/item/clothing/mask/cigarette))
		to_chat(user, span_notice("Вы нагрели [target.declent_ru(ACCUSATIVE)] с помощью [declent_ru(GENITIVE)]."))
		target.reagents.temperature_reagents(temperature)

/**
 * Called on the item before it hits something, when right clicking.
 *
 * Arguments:
 * * atom/target - The atom about to be hit
 * * mob/living/user - The mob doing the htting
 * * list/modifiers - click params such as alt/shift etc
 * * list/attack_modifiers - attack modifiers such as force, damage type, etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/obj/item/proc/pre_attack_secondary(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	var/signal_result = SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACK_SECONDARY, target, user, modifiers, attack_modifiers) | SEND_SIGNAL(user, COMSIG_USER_PRE_ITEM_ATTACK_SECONDARY, src, target, modifiers, attack_modifiers)

	if(signal_result & COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(signal_result & COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CALL_NORMAL

/**
 * Called on an object being hit by an item
 *
 * Arguments:
 * * obj/item/item - The item hitting this atom
 * * mob/user - The wielder of this item
 * * params - click params such as alt/shift etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/atom/proc/attackby(obj/item/item, mob/user, modifiers)
	. = ATTACK_CHAIN_PROCEED
	var/signal_out = SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, item, user, modifiers)
	if(signal_out & COMPONENT_CANCEL_ATTACK_CHAIN)
		. |= ATTACK_CHAIN_BLOCKED
	if(signal_out & COMPONENT_NO_AFTERATTACK)
		. |= ATTACK_CHAIN_NO_AFTERATTACK

/**
 * Called on an object being right-clicked on by an item
 *
 * Arguments:
 * * obj/item/weapon - The item hitting this atom
 * * mob/user - The wielder of this item
 * * list/modifiers - click params such as alt/shift etc
 * * list/attack_modifiers - attack modifiers such as force, damage type, etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/atom/proc/attackby_secondary(obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	var/signal_result = SEND_SIGNAL(src, COMSIG_ATOM_ATTACKBY_SECONDARY, weapon, user, modifiers, attack_modifiers)

	if(signal_result & COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(signal_result & COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CALL_NORMAL

/obj/attackby(obj/item/item, mob/living/user, list/modifiers)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .
	if(obj_flags & IGNORE_HITS)
		return .
	. |= item.attack_obj(src, user, modifiers)

/mob/living/attackby(obj/item/item, mob/living/user, list/modifiers)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .
	if(attempt_harvest(item, user))
		return .|ATTACK_CHAIN_BLOCKED_ALL
	if(item.sharp && item.damtype == BRUTE && !(HAS_TRAIT(item, TRAIT_SURGICAL) && body_position == LYING_DOWN && user.a_intent == INTENT_HELP) && !issyringe(item) && !isbot(src) && !(HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt))
		new /obj/effect/temp_visual/dir_setting/bloodsplatter(loc, get_angle(user, src), get_blood_color())
	user.changeNext_move(item.attack_speed)
	. |= item.attack(src, user, modifiers, user.zone_selected)

/mob/living/attackby_secondary(obj/item/weapon, mob/living/user, list/modifiers, list/attack_modifiers)
	var/result = weapon.attack_secondary(src, user, modifiers, attack_modifiers)

	// Normal attackby updates click cooldown, so we have to make up for it
	if(result != SECONDARY_ATTACK_CALL_NORMAL)
		if(weapon.secondary_attack_speed)
			user.changeNext_move(weapon.secondary_attack_speed)
		else
			user.changeNext_move(weapon.attack_speed)

	return result

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
/obj/item/proc/attack(mob/living/target, mob/living/user, list/modifiers, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	var/signal_out = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, target, user, modifiers, def_zone)

	if(signal_out & COMPONENT_NO_AFTERATTACK)
		. |= ATTACK_CHAIN_NO_AFTERATTACK

	if(signal_out & COMPONENT_CANCEL_ATTACK_CHAIN)
		return .|ATTACK_CHAIN_BLOCKED

	if(signal_out & COMPONENT_SKIP_ATTACK)
		return .

	if(item_flags & NOBLUDGEON)
		return .

	if(force && (HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt))
		to_chat(user, span_warning("Вы не хотите причинять кому-либо вред!"))
		return .

	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, target, modifiers, def_zone)

	if(!force)
		playsound(target.loc, 'sound/weapons/tap.ogg', get_clamped_volume(), TRUE, -1)
	else
		add_attack_logs(user, target, "Attacked with [name] ([uppertext(user.a_intent)]) ([uppertext(damtype)]), DMG: [force])", (target.ckey && force > 0 && damtype != STAMINA) ? null : ATKLOG_ALMOSTALL)
		if(COOLDOWN_FINISHED(src, sound_cooldown) && hitsound)   // Prevent stacking sounds when using cleave attacks
			playsound(target.loc, hitsound, get_clamped_volume(), TRUE, -1)
			COOLDOWN_START(src, sound_cooldown, 0.05 SECONDS) // Attack speed below 0.05 sec will not play sound on every hit

	target.lastattacker = user.real_name
	target.lastattackerckey = user.ckey
	if(force && target == user && user.client)
		user.client.give_award(/datum/award/achievement/misc/selfouch, user)

	if(!skip_attack_anim)
		user.do_attack_animation(target)

	add_fingerprint(user)
	. |= target.proceed_attack_results(src, user, modifiers, def_zone)

/// The equivalent of [/obj/item/proc/attack] but for alternate attacks, AKA right clicking
/obj/item/proc/attack_secondary(mob/living/victim, mob/living/user, list/modifiers, list/attack_modifiers)
	var/signal_result = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SECONDARY, victim, user, modifiers, attack_modifiers)

	if(signal_result & COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(signal_result & COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CALL_NORMAL

/// The equivalent of the standard version of [/obj/item/proc/attack] but for object targets.
/obj/item/proc/attack_obj(obj/object, mob/living/user, list/modifiers)
	. = ATTACK_CHAIN_PROCEED

	var/signal_out = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_OBJ, object, user, modifiers)

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
	. |= object.proceed_attack_results(src, user, modifiers)

/**
 * Called from [/obj/item/proc/attack] and [/obj/item/proc/attack_obj]
 *
 * Arguments:
 * * obj/item/item - The item hitting this atom
 * * mob/living/user - The wielder of this item
 * * params - Click params of this attack
 * * def_zone - Bodypart zone, targeted by the wielder of this item
 */
/atom/movable/proc/proceed_attack_results(obj/item/item, mob/living/user, list/modifiers, def_zone)
	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/proceed_attack_results(obj/item/item, mob/living/user, list/modifiers)
	. = ATTACK_CHAIN_PROCEED_SUCCESS
	if(!item.force)
		user.visible_message(
			span_warning("[user] аккуратно тыкнул[GEND_A_O_I(user)] [declent_ru(ACCUSATIVE)] [item.declent_ru(INSTRUMENTAL)]."),
			span_warning("Вы аккуратно тыкнули [declent_ru(ACCUSATIVE)] [item.declent_ru(INSTRUMENTAL)]."),
		)
		return .
	user.visible_message(
		span_danger("[user] ударил[GEND_A_O_I(user)] [declent_ru(ACCUSATIVE)] [item.declent_ru(INSTRUMENTAL)]!"),
		span_danger("Вы ударили [declent_ru(ACCUSATIVE)] [item.declent_ru(INSTRUMENTAL)]!"),
	)
	take_damage(item.get_final_force(user), item.damtype, MELEE, TRUE, get_dir(user, src), item.armour_penetration)
	if(QDELETED(src)) // thats a pretty common behavior with objects, when they take damage
		return ATTACK_CHAIN_BLOCKED_ALL

/mob/living/proceed_attack_results(obj/item/item, mob/living/user, list/modifiers, def_zone)
	. = ATTACK_CHAIN_PROCEED_SUCCESS

	send_item_attack_message(item, user, def_zone)
	if(!item.force)
		return .

	var/apply_damage_result = apply_damage(item.get_final_force(user), item.damtype, def_zone, sharp = item.sharp, used_weapon = item)
	// if we are hitting source with real weapon and any brute damage was done, we apply victim's blood everywhere
	if(apply_damage_result && item.damtype == BRUTE && prob(33))
		item.add_mob_blood(src)
		add_splatter_floor()
		if(get_dist(user, src) <= 1) //people with TK won't get smeared with blood
			user.add_mob_blood(src)

	if(QDELETED(src)) // rare, but better be safe
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
/mob/living/proc/send_item_attack_message(obj/item/item, mob/living/user, def_zone)
	if(item.item_flags & SKIP_ATTACK_MESSAGE)
		return

	if(!item.force)
		visible_message(
			span_warning("[user] аккуратно тыкнул[GEND_A_O_I(user)] [declent_ru(ACCUSATIVE)] [item.declent_ru(INSTRUMENTAL)]."),
			span_warning("[user] аккуратно тыкнул[GEND_A_O_I(user)] вас [item.declent_ru(INSTRUMENTAL)]."),
			ignored_mobs = user,
		)
		to_chat(user, span_warning("Вы аккуратно тыкнули [declent_ru(ACCUSATIVE)] [item.declent_ru(INSTRUMENTAL)]."))
		return

	var/message_verb = "атаковал"
	if(length(item.attack_verb))
		message_verb = "[pick(item.attack_verb)]"

	visible_message(
		span_danger("[user] [message_verb][GEND_A_O_I(user)] [declent_ru(ACCUSATIVE)] [item.declent_ru(INSTRUMENTAL)]!"),
		span_userdanger("[user] [message_verb][GEND_A_O_I(user)] вас [item.declent_ru(INSTRUMENTAL)]!"),
		ignored_mobs = user,
	)
	to_chat(user, span_danger("Вы [message_verb]и [declent_ru(ACCUSATIVE)] [item.declent_ru(INSTRUMENTAL)]!"))

/// Applies slowdown for a period of time after performing cleave attack, used for cleave component
/mob/living/proc/apply_afterswing_slowdown(mob/living/user, afterswing_slowdown, slowdown_duration)
	if(afterswing_slowdown == 0)
		return

	if(!ishuman(user)) // we dont want cyborgs to slowdown after swinging
		return

	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/afterswing_slowdown, multiplicative_slowdown = afterswing_slowdown)
	addtimer(CALLBACK(src, PROC_REF(remove_movespeed_modifier), /datum/movespeed_modifier/afterswing_slowdown), slowdown_duration, TIMER_UNIQUE|TIMER_OVERRIDE)

/*
/mob/living/basic/attackby(obj/item/item, mob/living/user)
	if(!attack_threshold_check(item.force, item.damtype, MELEE, FALSE))
		playsound(loc, 'sound/weapons/tap.ogg', item.get_clamped_volume(), TRUE, -1)
	else
		return ..()
*/
