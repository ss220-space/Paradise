/datum/component/lunge_attack
	var/lunge_speed
	var/lunge_range
	var/cooldown_time
	// Dual Strike is activated ONLY IF both items in your hands have this component and their corresponding variable is set to TRUE.
	var/lunge_dual_attack = FALSE
	var/lunge_trait = TRAIT_CANT_LUNGE

/datum/component/lunge_attack/Initialize(
		lunge_speed = 1, 
		lunge_range = 4, 
		cooldown_time = 6 SECONDS, 
		lunge_dual_attack = FALSE,
		...
	)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.lunge_speed = lunge_speed
	src.lunge_range = lunge_range
	src.cooldown_time = cooldown_time
	src.lunge_dual_attack = lunge_dual_attack

/datum/component/lunge_attack/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))
	RegisterSignal(parent, COMSIG_LUNGE_DUAL_STRIKE, PROC_REF(do_dual_strike))

/datum/component/lunge_attack/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_AFTERATTACK, COMSIG_LUNGE_DUAL_STRIKE))

/datum/component/lunge_attack/InheritComponent(
		datum/component/lunge_attack/C, 
		i_am_original, 
		lunge_speed, 
		lunge_range, 
		cooldown_time, 
		lunge_dual_attack
	)

	if(!i_am_original)
		return
	if(lunge_speed)
		src.lunge_speed = lunge_speed
	if(lunge_range)
		src.lunge_range = lunge_range
	if(cooldown_time)
		src.cooldown_time = cooldown_time
	if(!isnull(lunge_dual_attack))
		src.lunge_dual_attack = lunge_dual_attack

/datum/component/lunge_attack/proc/on_afterattack(obj/item/source, atom/target, mob/living/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(user.a_intent != INTENT_DISARM)
		return

	if(HAS_TRAIT(user, lunge_trait) || IS_HORIZONTAL(user) || user.incapacitated())
		return

	var/dist = get_dist(user, target)
	if(dist <= 1)
		return

	perform_lunge(user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/lunge_attack/proc/perform_lunge(mob/living/user, atom/target)
	user.apply_status_effect(STATUS_EFFECT_LUNGING)
	
	RegisterSignal(user, COMSIG_MOVABLE_IMPACT, PROC_REF(on_impact))
	
	user.throw_at(target, lunge_range, lunge_speed, parent, spin = FALSE, callback = CALLBACK(src, PROC_REF(lunge_ended), user, target))
	
	ADD_TRAIT(user, lunge_trait, UNIQUE_TRAIT_SOURCE(src))
	addtimer(CALLBACK(src, PROC_REF(reset_lunge), user), cooldown_time)

/datum/component/lunge_attack/proc/on_impact(mob/living/user, atom/hit)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_MOVABLE_IMPACT)

	if(user.throwing)
		user.throwing.finalize(hit)

	if(isliving(hit) && hit != user)
		INVOKE_ASYNC(src, PROC_REF(handle_lunge_attack), user, hit)

/datum/component/lunge_attack/proc/handle_lunge_attack(mob/living/user, atom/target)
	if(QDELETED(src) || QDELETED(user))
		return

	var/obj/item/weapon = parent
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

/datum/component/lunge_attack/proc/do_dual_strike(obj/item/source, mob/living/user, atom/target)
	SIGNAL_HANDLER
	if(!lunge_dual_attack)
		return

	if(!user || !target || !user.Adjacent(target))
		return
		
	var/obj/item/I = parent
	INVOKE_ASYNC(I, TYPE_PROC_REF(/obj/item, melee_attack_chain), user, target)

/datum/component/lunge_attack/proc/lunge_ended(mob/living/user, atom/target)
	UnregisterSignal(user, COMSIG_MOVABLE_IMPACT)
	user.remove_status_effect(STATUS_EFFECT_LUNGING)
	
	if(!HAS_TRAIT(user, TRAIT_LUNGE_HAS_ATTACKED))
		INVOKE_ASYNC(src, PROC_REF(handle_lunge_attack), user, target)
	REMOVE_TRAIT(user, TRAIT_LUNGE_HAS_ATTACKED, UNIQUE_TRAIT_SOURCE(src))

/datum/component/lunge_attack/proc/reset_lunge(mob/living/user)
	if(!QDELETED(user))
		REMOVE_TRAIT(user, lunge_trait, UNIQUE_TRAIT_SOURCE(src))
		REMOVE_TRAIT(user, TRAIT_LUNGE_HAS_ATTACKED, UNIQUE_TRAIT_SOURCE(src))
		user.balloon_alert(user, "выпад готов")
