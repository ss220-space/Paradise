/datum/component/lunge_attack
	var/lunge_speed
	var/lunge_range
	var/cooldown_time
	var/lunge_dual_attack = TRUE
	var/lunge_trait = TRAIT_CANT_LUNGE

/datum/component/lunge_attack/Initialize(lunge_speed = 1, lunge_range = 4, cooldown_time = 6 SECONDS, dual_attack = FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.lunge_speed = lunge_speed
	src.lunge_range = lunge_range
	src.cooldown_time = cooldown_time
	src.lunge_dual_attack = dual_attack

/datum/component/lunge_attack/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))
	RegisterSignal(parent, COMSIG_LUNGE_DUAL_STRIKE, PROC_REF(do_dual_strike))

/datum/component/lunge_attack/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_AFTERATTACK, COMSIG_LUNGE_DUAL_STRIKE))

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
	
	user.throw_at(target, lunge_range, lunge_speed, parent, spin = FALSE, callback = CALLBACK(src, PROC_REF(lunge_ended), user))
	
	ADD_TRAIT(user, lunge_trait, src)
	addtimer(CALLBACK(src, PROC_REF(reset_lunge), user), cooldown_time)

/datum/component/lunge_attack/proc/on_impact(mob/living/user, atom/hit)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_MOVABLE_IMPACT)

	if(user.throwing)
		user.throwing.finalize(hit = TRUE)

	if(isliving(hit) && hit != user)
		handle_lunge_attack(user, hit)

/datum/component/lunge_attack/proc/handle_lunge_attack(mob/living/user, mob/living/target)
	var/obj/item/weapon = parent

	if(!HAS_TRAIT(weapon, TRAIT_CLEAVE_BLOCKED))
		if(SEND_SIGNAL(weapon, COMSIG_ITEM_AFTERATTACK, target, user, FALSE, null, TRUE))
			return

	weapon.melee_attack_chain(user, target)

	if(lunge_dual_attack)
		var/obj/item/offhand_weapon = user.get_inactive_hand()
		if(offhand_weapon && offhand_weapon != weapon)
			SEND_SIGNAL(offhand_weapon, COMSIG_LUNGE_DUAL_STRIKE, user, target)

/datum/component/lunge_attack/proc/do_dual_strike(obj/item/source, mob/living/user, atom/target)
	SIGNAL_HANDLER
	if(!user || !target || !user.Adjacent(target))
		return
		
	var/obj/item/I = parent
	I.melee_attack_chain(user, target)

/datum/component/lunge_attack/proc/lunge_ended(mob/living/user)
	UnregisterSignal(user, COMSIG_MOVABLE_IMPACT)
	user.remove_status_effect(STATUS_EFFECT_LUNGING)

/datum/component/lunge_attack/proc/reset_lunge(mob/living/user)
	if(!QDELETED(user))
		REMOVE_TRAIT(user, lunge_trait, src)
		user.balloon_alert(user, "выпад готов")
