/datum/element/lunge_attack
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	var/lunge_speed
	var/lunge_range
	var/cooldown_time
	var/lunge_dual_attack = FALSE

/datum/element/lunge_attack/Attach(obj/item/target, lunge_speed = 1, lunge_range = 4, cooldown_time = 6 SECONDS, lunge_dual_attack = FALSE)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.lunge_speed = lunge_speed
	src.lunge_range = lunge_range
	src.cooldown_time = cooldown_time
	src.lunge_dual_attack = lunge_dual_attack

	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))
	RegisterSignal(target, COMSIG_LUNGE_DUAL_STRIKE, PROC_REF(do_dual_strike))

/datum/element/lunge_attack/Detach(obj/item/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_AFTERATTACK, COMSIG_LUNGE_DUAL_STRIKE))

/datum/element/lunge_attack/proc/on_afterattack(obj/item/source, atom/target, mob/living/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(user.a_intent != INTENT_DISARM)
		return

	if(HAS_TRAIT(user, TRAIT_CANT_LUNGE) || IS_HORIZONTAL(user) || user.incapacitated())
		return

	if(user.Adjacent(target))
		return

	perform_lunge(source, user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/element/lunge_attack/proc/perform_lunge(obj/item/source, mob/living/user, atom/target)
	user.apply_status_effect(STATUS_EFFECT_LUNGING)
	
	RegisterSignal(user, COMSIG_MOVABLE_IMPACT, PROC_REF(on_impact), override = TRUE)
	
	user.throw_at(target, lunge_range, lunge_speed, source, spin = FALSE, callback = CALLBACK(src, PROC_REF(lunge_ended), source, user, target))
	
	ADD_TRAIT(user, TRAIT_CANT_LUNGE, UNIQUE_TRAIT_SOURCE(src))
	addtimer(CALLBACK(src, PROC_REF(reset_lunge), user), cooldown_time)

/datum/element/lunge_attack/proc/on_impact(mob/living/user, atom/hit)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_MOVABLE_IMPACT)

	if(user.throwing)
		user.throwing.finalize(hit)

	if(isliving(hit) && hit != user)
		var/obj/item/weapon = user.get_active_hand()
		if(weapon)
			INVOKE_ASYNC(src, PROC_REF(handle_lunge_attack), weapon, user, hit)

/datum/element/lunge_attack/proc/handle_lunge_attack(obj/item/weapon, mob/living/user, atom/target)
	if(QDELETED(user) || QDELETED(weapon))
		return

	ADD_TRAIT(user, TRAIT_LUNGE_HAS_ATTACKED, UNIQUE_TRAIT_SOURCE(src))

	var/atom/final_target = target
	
	if(target == get_turf(user))
		var/turf/next_tile = get_step(user, user.dir)
		if(next_tile)
			final_target = next_tile
	
	if(!HAS_TRAIT(weapon, TRAIT_CLEAVE_BLOCKED))
		if(SEND_SIGNAL(weapon, COMSIG_ITEM_AFTERATTACK, final_target, user, FALSE, null, TRUE))
			return

	if(user.Adjacent(final_target))
		weapon.melee_attack_chain(user, final_target)

	if(lunge_dual_attack)
		var/obj/item/offhand_weapon = user.get_inactive_hand()
		if(offhand_weapon && offhand_weapon != weapon)
			SEND_SIGNAL(offhand_weapon, COMSIG_LUNGE_DUAL_STRIKE, user, final_target)

/datum/element/lunge_attack/proc/do_dual_strike(obj/item/source, mob/living/user, atom/target)
	SIGNAL_HANDLER
	if(!lunge_dual_attack)
		return

	if(!user || !target || !user.Adjacent(target))
		return
		
	INVOKE_ASYNC(source, TYPE_PROC_REF(/obj/item, melee_attack_chain), user, target)

/datum/element/lunge_attack/proc/lunge_ended(obj/item/source, mob/living/user, atom/target)
	UnregisterSignal(user, COMSIG_MOVABLE_IMPACT)
	user.remove_status_effect(STATUS_EFFECT_LUNGING)
	
	if(!HAS_TRAIT(user, TRAIT_LUNGE_HAS_ATTACKED))
		INVOKE_ASYNC(src, PROC_REF(handle_lunge_attack), source, user, target)
	REMOVE_TRAIT(user, TRAIT_LUNGE_HAS_ATTACKED, UNIQUE_TRAIT_SOURCE(src))

/datum/element/lunge_attack/proc/reset_lunge(mob/living/user)
	if(QDELETED(user))
		return
	REMOVE_TRAIT(user, TRAIT_CANT_LUNGE, UNIQUE_TRAIT_SOURCE(src))
	REMOVE_TRAIT(user, TRAIT_LUNGE_HAS_ATTACKED, UNIQUE_TRAIT_SOURCE(src))
	user.balloon_alert(user, "выпад готов")
