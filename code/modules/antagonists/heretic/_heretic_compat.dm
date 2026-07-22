/// master220 compatibility shims for the tg-derived heretic code. Small adapter procs that bridge API-name
/// differences between the heretic source and master220, kept here so core files stay clean.


/mob/living/proc/adjustOrganLoss(slot, amount, maximum, required_organ_flag)
	return FALSE

/mob/living/carbon/adjustOrganLoss(slot, amount, maximum, required_organ_flag = NONE)
	var/obj/item/organ/affected_organ = get_organ_slot(slot)
	if(!affected_organ || HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	if(required_organ_flag && !(affected_organ.status & required_organ_flag))
		return FALSE
	if(amount >= 0)
		return affected_organ.internal_receive_damage(amount)
	affected_organ.heal_internal_damage(-amount)
	return TRUE

/mob/living/carbon/get_organ_loss(slot, required_organ_flag)
	var/obj/item/organ/affected_organ = get_organ_slot(slot)
	if(!affected_organ)
		return 0
	if(required_organ_flag && !(affected_organ.status & required_organ_flag))
		return 0
	return affected_organ.damage

/// Returns whether the given organ is robotic. tg helper not present in master220.
/proc/isroboticorgan(obj/item/organ/checked_organ)
	return checked_organ?.is_robotic()

/// tg's dismember() on a limb maps to master220's droplimb().
/obj/item/organ/external/proc/dismember()
	return droplimb()

/// tg's set_organ_damage(amount) - master220 organs have a `damage` var + max_damage.
/obj/item/organ/proc/set_organ_damage(amount, required_organ_flag)
	damage = clamp(amount, 0, max_damage)


/// tg "can this mob give up / be finished off" check. master220 approximation: in crit or dead.
/mob/living/proc/CanSuccumb()
	return (stat == UNCONSCIOUS || stat == DEAD)


/mob/living/proc/cause_hallucination(hallucination_type, reason, duration = 30 SECONDS, affects_us = TRUE, affects_others = FALSE)
	if(affects_us)
		fire_eldritch_hallucination(src, duration)
	if(affects_others)
		for(var/mob/living/carbon/nearby in view(7, src) - src)
			fire_eldritch_hallucination(nearby, duration)

/// Fires guaranteed hallucinations on a carbon RIGHT NOW and keeps them coming for the duration.
/proc/fire_eldritch_hallucination(mob/living/carbon/who, duration = 30 SECONDS)
	if(!iscarbon(who))
		return
	INVOKE_ASYNC(who, TYPE_PROC_REF(/mob/living, hallucinate_living), pickweight(GLOB.minor_medium_hallutinations))
	new /obj/effect/hallucination/delusion(who.loc, who, null, duration, FALSE)
	who.Hallucinate(max(duration, 120 SECONDS))

/datum/hallucination/delusion/preset/moon
/datum/hallucination/delusion/preset/heretic/gate


/// tg AdjustAllImmobility (stun/knockdown/immobilize); master220 closest = AdjustImmobilized.
/mob/living/proc/AdjustAllImmobility(amount, ignore_canstun = FALSE)
	return AdjustImmobilized(amount, ignore_canstun)

/// tg "does this mob need a heart to live"; master220 approximation: carbons do.
/mob/living/carbon/proc/needs_heart()
	return TRUE

/// Strips every held and worn item off the mob, returning what came off.
/mob/living/proc/unequip_everything()
	. = get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD)
	for(var/obj/item/stripped as anything in .)
		drop_item_ground(stripped, force = TRUE, silent = TRUE)

/// tg's is_centcomm(z); master220 treats centcom as an admin z-level.
/proc/is_centcomm(z)
	return is_admin_level(z)

/// tg timed-examine hook; master220 examine is instant. Base returns 0; heretic influence overrides it
/// for flavor but master220 won't honor the delay (runtime polish).
/atom/proc/get_examine_time()
	return 0

/atom/proc/rust_heretic_act(strength)
	return

/obj/structure/rust_heretic_act(strength)
	take_damage(500, BRUTE, MELEE, TRUE)

/obj/machinery/rust_heretic_act(strength)
	take_damage(500 + strength * 200, BRUTE, BOMB, TRUE)

/obj/machinery/door/window/rust_heretic_act(strength)
	obj_flags |= NODECONSTRUCT
	return ..()

/obj/machinery/door/airlock/rust_heretic_act(strength)
	obj_flags |= NODECONSTRUCT
	return ..()

/obj/machinery/door/firedoor/rust_heretic_act(strength)
	obj_flags |= NODECONSTRUCT
	return ..()

/// Wrapper proc that passes our mob's rust_strength to the target we are rusting.
/mob/proc/do_rust_heretic_act(atom/target)
	var/datum/antagonist/heretic/heretic_data = GET_HERETIC(src)
	target.rust_heretic_act(heretic_data?.rust_strength)

/mob/living/silicon/rust_heretic_act(strength)
	adjustBruteLoss(500)

/mob/living/simple_animal/bot/rust_heretic_act(strength)
	adjustBruteLoss(400)

/obj/mecha/rust_heretic_act(strength)
	take_damage(500, BRUTE)

/proc/dir2rustext_where(direction)
	return "на [dir2rustext(direction)]е"

/obj/effect/dummy/spell_jaunt/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!ismob(arrived) || arrived == jaunter)
		return
	jaunter = arrived
	if(!phased_mob_icon_state)
		return
	var/mob/mob_jaunter = arrived
	position_indicator = image(phased_mob_icon, src, phased_mob_icon_state, ABOVE_LIGHTING_PLANE)
	position_indicator.appearance_flags |= RESET_ALPHA
	SET_PLANE_EXPLICIT(position_indicator, ABOVE_LIGHTING_PLANE, src)
	RegisterSignal(mob_jaunter, COMSIG_MOB_LOGIN, PROC_REF(show_client_image), override = TRUE)
	show_client_image(mob_jaunter)

/// Shows our position indicator to the jaunter's client (re-shown on relog).
/obj/effect/dummy/spell_jaunt/proc/show_client_image(mob/show_to)
	SIGNAL_HANDLER
	show_to.client?.images |= position_indicator

/obj/effect/dummy/spell_jaunt/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != jaunter)
		return
	var/mob/mob_jaunter = jaunter
	mob_jaunter.client?.images -= position_indicator
	UnregisterSignal(mob_jaunter, COMSIG_MOB_LOGIN)
	jaunter = null
	position_indicator = null

/// Ejects the jaunter to our turf and deletes the dummy.
/obj/effect/dummy/spell_jaunt/proc/eject_jaunter()
	if(!jaunter)
		return
	var/turf/eject_spot = get_turf(src)
	if(!eject_spot)
		return
	var/atom/movable/exiting = jaunter
	jaunter.forceMove(eject_spot)
	SEND_SIGNAL(src, COMSIG_MOB_EJECTED_FROM_JAUNT, exiting)
	qdel(src)

/// TRUE if the given mob is currently inside a jaunt dummy.
/proc/is_jaunting(mob/living/possibly_jaunting)
	return istype(possibly_jaunting?.loc, /obj/effect/dummy/spell_jaunt)

/// tg's get_held_items() - master220 exposes hands via get_active_hand()/get_inactive_hand().
/mob/living/proc/get_held_items()
	. = list()
	var/obj/item/active = get_active_hand()
	var/obj/item/inactive = get_inactive_hand()
	if(active)
		. += active
	if(inactive)
		. += inactive

/// Returns the furthest unblocked turf from target_atom in `direction`, up to `range`.
/proc/get_freeway_ranged_target_turf(atom/target_atom, direction, range, min_range = 0)
	var/result_loc = get_turf(target_atom)
	for(var/moved_len = 0; moved_len < range; moved_len++)
		var/turf/checking = get_ranged_target_turf(target_atom, direction, moved_len + 1)
		var/blocked = iswallturf(checking)
		var/checked = 0
		for(var/obj/blocker in checking)
			if(checked++ > 20)
				break
			if(!blocker.density)
				continue
			blocked = TRUE
			break
		if(!blocked)
			result_loc = checking
			continue
		if(moved_len < min_range)
			return
		else
			break
	return result_loc

/// tg-style global visibility helper; master220 exposes this as atom/proc/can_see().
/proc/can_see(atom/source, atom/target, range = 5)
	return source?.can_see(target, length = range)

/// tg-style befriending (trimmed): registers the friend on the AI blackboard (so obeys_commands /
/// dont_target_friends see them) and announces it AFTER, so obeys_commands can hook the friend's speech.
/mob/living/proc/befriend(mob/living/new_friend)
	if(QDELETED(new_friend))
		return FALSE
	if(ai_controller)
		var/list/friends = ai_controller.blackboard[BB_FRIENDS_LIST] || list()
		if(new_friend in friends)
			return FALSE
		friends |= new_friend
		ai_controller.set_blackboard_key(BB_FRIENDS_LIST, friends)
	SEND_SIGNAL(src, COMSIG_LIVING_BEFRIENDED, new_friend)
	return TRUE

/// tg-style blackboard helpers used by some imported AI support datums.
/datum/ai_controller/proc/set_blackboard_key(key, value)
	blackboard[key] = value
	if(pawn)
		SEND_SIGNAL(pawn, COMSIG_AI_BLACKBOARD_KEY_SET(key))

/datum/ai_controller/proc/clear_blackboard_key(key)
	if(pawn)
		SEND_SIGNAL(pawn, COMSIG_AI_BLACKBOARD_KEY_CLEARED(key))
	blackboard -= key

/datum/ai_controller/proc/blackboard_key_exists(key)
	return !isnull(blackboard[key])

/datum/ai_behavior/proc/set_movement_target(datum/ai_controller/controller, atom/target)
	controller.current_movement_target = target


/datum/atom_hud/alternate_appearance/basic/heretic
	add_ghost_version = TRUE

/datum/atom_hud/alternate_appearance/basic/heretic/mob_should_see(mob/viewer)
	return IS_HERETIC_OR_MONSTER(viewer) || isobserver(viewer)


/obj/effect/proc_holder/spell/watchers_look/heretic
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
