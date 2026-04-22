/datum/component/stances
	var/list/stance_data

/datum/component/stances/Initialize(list/stance_data_override = null)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(islist(stance_data_override))
		stance_data = stance_data_override

	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_item_attack))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_OBJ, PROC_REF(on_item_attack_obj))

/datum/component/stances/Destroy(force = FALSE)
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_OBJ))
	return ..()

/datum/component/stances/proc/get_stance(mob/living/user)
	if(!user)
		return null
	var/list/data = stance_data?[user.a_intent]
	if(!islist(data))
		data = stance_data?[INTENT_HARM]
	return data

/datum/component/stances/proc/should_apply_stance(mob/living/user)
	return TRUE

/datum/component/stances/proc/apply_stance_stats(mob/living/user)
	if(!user || !should_apply_stance(user))
		return
	var/list/stance = get_stance(user)
	if(!stance)
		return
	var/obj/item/item_parent = parent
	item_parent.force = stance["force"]
	item_parent.armour_penetration = stance["armour_penetration"]

/datum/component/stances/proc/reset_stats()
	var/obj/item/item_parent = parent
	item_parent.force = initial(item_parent.force)
	item_parent.armour_penetration = initial(item_parent.armour_penetration)

/datum/component/stances/proc/on_item_attack(datum/source, mob/living/target, mob/living/user, params, def_zone)
	SIGNAL_HANDLER
	var/obj/item/item_parent = parent
	if(!user || !user.is_in_hands(item_parent))
		return
	apply_stance_stats(user)

/datum/component/stances/proc/on_item_attack_obj(datum/source, obj/object, mob/living/user, params)
	SIGNAL_HANDLER
	var/obj/item/item_parent = parent
	if(!user || !user.is_in_hands(item_parent))
		return
	apply_stance_stats(user)

// MARK: SABER

/datum/component/stances/saber
	var/mob/living/current_holder

	COOLDOWN_DECLARE(help_block_disabled_cd)

	var/static/list/saber_stance_data = list(
		INTENT_HELP = list(
			"force" = 25,
			"armour_penetration" = -10,
			"melee_block" = 35,
			"ballistic_block" = 80,
			"energy_block" = 100,
			"reflect_energy" = TRUE,
		),
		INTENT_DISARM = list(
			"force" = 30,
			"armour_penetration" = 75,
			"melee_block" = 20,
			"ballistic_block" = 60,
			"energy_block" = 80,
			"reflect_energy" = FALSE,
		),
		INTENT_HARM = list(
			"force" = 45,
			"armour_penetration" = 20,
			"melee_block" = 20,
			"ballistic_block" = 60,
			"energy_block" = 80,
			"reflect_energy" = FALSE,
		),
		INTENT_GRAB = list(
			"force" = 30,
			"armour_penetration" = 20,
			"melee_block" = 75,
			"ballistic_block" = 25,
			"energy_block" = 50,
			"reflect_energy" = FALSE,
		),
	)

/datum/component/stances/saber/Initialize()
	. = ..(saber_stance_data)
	if(. == COMPONENT_INCOMPATIBLE)
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_HIT_REACT, PROC_REF(on_hit_react))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_POST_UNEQUIP, PROC_REF(on_post_unequip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(parent, COMSIG_SABER_TOGGLED, PROC_REF(on_saber_toggled))

	refresh_nodrop()

/datum/component/stances/saber/Destroy(force = FALSE)
	set_holder(null)
	UnregisterSignal(parent, list(COMSIG_ITEM_HIT_REACT, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_POST_UNEQUIP, COMSIG_ITEM_DROPPED, COMSIG_SABER_TOGGLED))
	return ..()

/datum/component/stances/saber/proc/is_active_saber()
	var/obj/item/item_parent = parent
	if(!item_parent)
		return FALSE
	if(!("active" in item_parent.vars))
		return FALSE
	return item_parent.vars["active"]

/datum/component/stances/saber/should_apply_stance(mob/living/user)
	var/obj/item/item_parent = parent
	return is_active_saber() && user && user.is_in_hands(item_parent)

/datum/component/stances/saber/proc/is_stimulated(mob/living/user)
	if(!user || !user.reagents)
		return FALSE
	return user.reagents.has_reagent("adrenaline") || user.reagents.has_reagent("methamphetamine")

/datum/component/stances/saber/proc/is_energy_projectile(obj/projectile/P)
	if(!P)
		return FALSE
	if(P.flag == ENERGY || P.flag == LASER)
		return TRUE
	return P.is_reflectable(REFLECTABILITY_ENERGY)

/datum/component/stances/saber/proc/is_help_block_disabled(mob/living/user)
	if(!user || user.a_intent != INTENT_HELP)
		return FALSE
	return !COOLDOWN_FINISHED(src, help_block_disabled_cd)

/datum/component/stances/saber/proc/should_reflect_energy(mob/living/user)
	if(!user || user.a_intent != INTENT_HELP)
		return FALSE
	if(!is_active_saber())
		return FALSE
	if(is_help_block_disabled(user))
		return FALSE
	if(is_stimulated(user))
		return FALSE
	var/obj/item/item_parent = parent
	if(!user.is_in_hands(item_parent))
		return FALSE

	var/list/stance = get_stance(user)
	return stance?["reflect_energy"]

/datum/component/stances/saber/proc/disable_help_blocks_if_needed(mob/living/user)
	if(!user || user.a_intent != INTENT_HELP)
		return
	if(!is_active_saber())
		return
	var/obj/item/item_parent = parent
	if(!user.is_in_hands(item_parent))
		return
	COOLDOWN_START(src, help_block_disabled_cd, 3 SECONDS)

/datum/component/stances/saber/proc/set_holder(mob/living/new_holder)
	if(current_holder == new_holder)
		return

	if(current_holder)
		UnregisterSignal(current_holder, list(
			COMSIG_MOB_ITEM_ATTACK,
			COMSIG_MOB_ATTACK_RANGED,
			COMSIG_LIVING_UNARMED_ATTACK,
			COMSIG_LIVING_STATUS_SLEEP,
			COMSIG_LIVING_STATUS_UNCONSCIOUS,
			COMSIG_QDELETING,
		))

	current_holder = new_holder

	if(current_holder)
		RegisterSignal(current_holder, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_holder_item_attack))
		RegisterSignal(current_holder, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_holder_ranged_attack))
		RegisterSignal(current_holder, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_holder_unarmed_attack))
		RegisterSignal(current_holder, COMSIG_LIVING_STATUS_SLEEP, PROC_REF(on_holder_sleeping))
		RegisterSignal(current_holder, COMSIG_LIVING_STATUS_UNCONSCIOUS, PROC_REF(on_holder_unconscious))
		RegisterSignal(current_holder, COMSIG_QDELETING, PROC_REF(on_holder_deleted))

/datum/component/stances/saber/proc/refresh_nodrop()
	var/obj/item/item_parent = parent
	if(!item_parent)
		return

	if(is_active_saber() && current_holder && current_holder.is_in_hands(item_parent))
		ADD_TRAIT(item_parent, TRAIT_NODROP, UNIQUE_TRAIT_SOURCE(src))
	else
		REMOVE_TRAIT(item_parent, TRAIT_NODROP, UNIQUE_TRAIT_SOURCE(src))

/datum/component/stances/saber/proc/refresh()
	refresh_nodrop()
	if(!is_active_saber())
		reset_stats()
		return
	if(current_holder)
		apply_stance_stats(current_holder)

/datum/component/stances/saber/proc/on_saber_toggled(datum/source, mob/user)
	SIGNAL_HANDLER
	refresh()

/datum/component/stances/saber/on_item_attack(datum/source, mob/living/target, mob/living/user, params, def_zone)
	. = ..()
	disable_help_blocks_if_needed(user)

/datum/component/stances/saber/on_item_attack_obj(datum/source, obj/object, mob/living/user, params)
	. = ..()
	disable_help_blocks_if_needed(user)

/datum/component/stances/saber/proc/on_equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(isliving(user) && (slot & ITEM_SLOT_HANDS))
		set_holder(user)
		refresh()
		return

	if(current_holder == user)
		set_holder(null)
	refresh_nodrop()

/datum/component/stances/saber/proc/on_post_unequip(datum/source, force, atom/newloc, no_move, invdrop, silent, mob/user)
	SIGNAL_HANDLER
	if(current_holder == user)
		set_holder(null)
	refresh_nodrop()

/datum/component/stances/saber/proc/on_dropped(datum/source, mob/user, slot, silent)
	SIGNAL_HANDLER
	if(current_holder == user)
		set_holder(null)
	refresh_nodrop()

/datum/component/stances/saber/proc/on_holder_deleted(datum/source)
	SIGNAL_HANDLER
	set_holder(null)
	refresh_nodrop()

/datum/component/stances/saber/proc/on_holder_item_attack(datum/source, atom/target, params, def_zone)
	SIGNAL_HANDLER
	disable_help_blocks_if_needed(source)

/datum/component/stances/saber/proc/on_holder_ranged_attack(datum/source, atom/target, params)
	SIGNAL_HANDLER
	disable_help_blocks_if_needed(source)

/datum/component/stances/saber/proc/on_holder_unarmed_attack(datum/source, atom/target, proximity_flag)
	SIGNAL_HANDLER
	disable_help_blocks_if_needed(source)

/datum/component/stances/saber/proc/on_holder_sleeping(datum/source, amount)
	SIGNAL_HANDLER
	if(amount == 0)
		return
	if(!is_active_saber())
		return
	var/mob/living/L = source
	var/obj/item/item_parent = parent
	if(L && L.is_in_hands(item_parent))
		L.drop_item_ground(item_parent, force = TRUE, silent = TRUE)

/datum/component/stances/saber/proc/on_holder_unconscious(datum/source, amount, ignore_canstun)
	SIGNAL_HANDLER
	if(amount <= 0)
		return
	if(!is_active_saber())
		return
	var/mob/living/L = source
	var/obj/item/item_parent = parent
	if(L && L.is_in_hands(item_parent))
		L.drop_item_ground(item_parent, force = TRUE, silent = TRUE)

/datum/component/stances/saber/proc/on_hit_react(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, damage, attack_type)
	SIGNAL_HANDLER

	if(!is_active_saber())
		return
	if(!owner)
		return
	if(is_help_block_disabled(owner))
		return

	var/list/stance = get_stance(owner)
	if(!stance)
		return

	var/chance = 0
	if(isprojectile(hitby))
		if(is_stimulated(owner))
			return
		var/obj/projectile/P = hitby
		if(is_energy_projectile(P))
			chance = stance["energy_block"]
		else
			chance = stance["ballistic_block"]
	else
		chance = stance["melee_block"]

	if(chance <= 0 || !prob(chance))
		return

	if(attack_type == UNARMED_ATTACK && ishuman(hitby))
		var/mob/living/carbon/human/attacker = hitby
		if(attacker.a_intent != INTENT_HELP && !attacker.get_active_hand())
			owner.do_attack_animation(attacker)
			var/obj/item/item_parent = parent
			if(item_parent?.hitsound)
				playsound(attacker.loc, item_parent.hitsound, 50, TRUE, -1)
			var/obj/item/organ/external/hand_organ = attacker.get_organ(attacker.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
			hand_organ?.droplimb(disintegrate = DROPLIMB_SHARP, nodamage = TRUE)

	return COMPONENT_BLOCK_SUCCESSFUL
