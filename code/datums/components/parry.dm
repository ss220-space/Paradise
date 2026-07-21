/datum/component/parry
	/// the world.time we last parried at
	var/time_parried
	/// the max time since `time_parried` that the shield is still considered "active"
	var/parry_time_out_time

	/// the flat amount of damage the shield user takes per non-perfect parry
	var/stamina_constant
	/// stamina_coefficient * damage * time_since_time_parried = stamina damage taken per non perfect parry
	var/stamina_coefficient
	/// the attack types that are considered for parrying
	var/parryable_attack_types
	/// the time between parry attempts
	var/parry_cooldown
	///Do we wish to mute the parry sound?
	var/no_parry_sound
	/// Text to be shown to users who examine the parent. Will list which type of attacks it can parry.
	var/examine_text
	/// Does this item have a require a condition to meet before being able to parry? This is for two handed weapons that can parry. (Default: FALSE)
	var/requires_two_hands = FALSE
	/// Does this item require activation? This is for activation based items or energy weapons.
	var/requires_activation = FALSE
	var/timer_id
	COOLDOWN_DECLARE(click_cd)
	COOLDOWN_DECLARE(parry_cd)
	var/datum/callback/block_callback
	var/linked_alert

/datum/component/parry/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(dropped))
	RegisterSignal(parent, COMSIG_ITEM_HIT_REACT, PROC_REF(attempt_parry))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_parent_examined))

/datum/component/parry/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)
	UnregisterSignal(parent, COMSIG_ITEM_HIT_REACT)
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)
	var/obj/item/item_parent = parent
	if(ismob(item_parent.loc))
		UnregisterSignal(item_parent.loc, COMSIG_CARBON_PARRY)

/datum/component/parry/Initialize(_stamina_constant = 0, _stamina_coefficient = 0, _parry_time_out_time = PARRY_DEFAULT_TIMEOUT, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = 2 SECONDS, _no_parry_sound = FALSE, _requires_two_hands = FALSE, _requires_activation = FALSE, _block_callback = null)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	parry_time_out_time = _parry_time_out_time
	stamina_constant = _stamina_constant
	stamina_coefficient = _stamina_coefficient
	parry_cooldown = _parry_cooldown
	no_parry_sound = _no_parry_sound
	requires_two_hands = _requires_two_hands
	requires_activation = _requires_activation
	parryable_attack_types = _parryable_attack_types
	block_callback = _block_callback

	var/static/alist/attack_types_english = alist(
		ITEM_ATTACK = "melee attacks",
		UNARMED_ATTACK = "unarmed attacks",
		PROJECTILE_ATTACK = "projectiles",
		THROWN_PROJECTILE_ATTACK = "thrown projectiles",
		LEAP_ATTACK = "leap attacks"
	)
	var/list/attack_list = list()
	for(var/attack_type, attack_text in attack_types_english)
		if(attack_type & _parryable_attack_types)
			attack_list += attack_text


	examine_text = span_notice("It's able to <b>parry</b> [english_list(attack_list)].")

/datum/component/parry/proc/equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	if(slot & ITEM_SLOT_HANDS)
		RegisterSignal(user, COMSIG_CARBON_PARRY, PROC_REF(start_parry))
		ADD_TRAIT(user, TRAIT_PUSHIMMUNE, UNIQUE_TRAIT_SOURCE(src))
	else
		UnregisterSignal(user, COMSIG_CARBON_PARRY)
		REMOVE_TRAIT(user, TRAIT_PUSHIMMUNE, UNIQUE_TRAIT_SOURCE(src))

/datum/component/parry/proc/dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_CARBON_PARRY)
	REMOVE_TRAIT(user, TRAIT_PUSHIMMUNE, UNIQUE_TRAIT_SOURCE(src))

/datum/component/parry/proc/start_parry(mob/living/mob_user)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, click_cd))
		return

	COOLDOWN_START(src, click_cd, 0.5 SECONDS)
	if(!COOLDOWN_FINISHED(src, parry_cd))
		return

	if(mob_user.stat != CONSCIOUS)
		return
	if(mob_user.incapacitated())
		return
	if(requires_two_hands && !HAS_TRAIT(parent, TRAIT_WIELDED)) // If our item has special conditions before being able to parry.
		return
	if(requires_activation && !HAS_TRAIT(parent, TRAIT_ITEM_ACTIVE)) // If our item requires an activation to be able to parry. [E-sword / Teleshield, etc.]
		return
	if(timer_id)
		stop_parry(mob_user)
		return
	time_parried = world.time
	mob_user.changeNext_move(CLICK_CD_PARRY)
	mob_user.do_attack_animation(mob_user, used_item = parent)
	timer_id = addtimer(CALLBACK(src, PROC_REF(stop_parry), mob_user), parry_time_out_time, TIMER_STOPPABLE)
	linked_alert = mob_user.throw_alert(UID(), /atom/movable/screen/alert/parry)

/datum/component/parry/proc/stop_parry(mob/living/mob_user)
	if(timer_id)
		deltimer(timer_id)
	timer_id = null
	mob_user.clear_alert(UID())
	linked_alert = null
	COOLDOWN_START(src, parry_cd,  parry_cooldown)

/datum/component/parry/proc/attempt_parry(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, damage = 0, attack_type = ITEM_ATTACK)
	SIGNAL_HANDLER
	if(!timer_id)
		return
	var/was_perfect = FALSE
	if(!(attack_type & parryable_attack_types))
		return
	var/time_since_parry = world.time - time_parried

	var/armor_penetration_flat = 0

	if(isitem(hitby))
		var/obj/item/hitby_item = hitby
		armor_penetration_flat = max(hitby_item.armour_penetration, 0)

	if(armor_penetration_flat >= 100)
		return

	var/stamina_damage = stamina_coefficient * (((time_since_parry / parry_time_out_time)) * (damage + armor_penetration_flat)) + stamina_constant

	if(!no_parry_sound)
		var/sound_to_play
		if(attack_type == PROJECTILE_ATTACK)
			sound_to_play = SFX_RICOCHET
		else
			sound_to_play = 'sound/weapons/parry.ogg'

		playsound(owner, sound_to_play, clamp(stamina_damage, 40, 120))

	if(time_since_parry <= parry_time_out_time * 0.5) // a perfect parry
		was_perfect = TRUE

	block_callback?.Invoke(hitby)

	owner.adjustStaminaLoss(stamina_damage)
	if(owner.getStaminaLoss() < 100)
		if(!was_perfect)
			return COMPONENT_BLOCK_SUCCESSFUL
		return (COMPONENT_BLOCK_SUCCESSFUL | COMPONENT_BLOCK_PERFECT)

/datum/component/parry/proc/on_parent_examined(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += examine_text

/atom/movable/screen/alert/parry
	name = "Parry"
	desc = "You are ready to block enemy attack!"
	icon_state = "parry"
