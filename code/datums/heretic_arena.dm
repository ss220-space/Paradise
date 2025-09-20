GLOBAL_LIST_EMPTY(heretic_arenas)

// Invisible effect that doesnt exist outside of containing the prox monitor
/obj/effect/abstract/heretic_arena
	icon = null
	icon_state = null
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE
	/// Proximity monitor that handles the effects we are looking for
	var/datum/component/proximity_monitor/advanced/heretic_arena/arena


/obj/effect/abstract/heretic_arena/Initialize(mapload, range, duration, caster)
	. = ..()
	arena = new(list(src, range))
	QDEL_IN(src, duration)
	arena.set_caster(caster)
	GLOB.heretic_arenas += src


/obj/effect/abstract/heretic_arena/Destroy(force)
	QDEL_NULL(arena)
	GLOB.heretic_arenas -= src
	. = ..()


/datum/component/proximity_monitor/advanced/heretic_arena
	/// Reference to the caster, the spell collapses if they leave the arena
	var/arena_caster
	/// List of mobs inside our arena
	var/list/contained_mobs = list()
	/// List of border walls we have placed on the edges of the monitor
	var/list/border_walls = list()
	/// List of blades we've so generously handed out to the participants
	var/list/welfare_blades = list()
	/// List of immunities given to our combatants
	var/static/list/given_immunities = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_NO_SLIP_ALL,
		TRAIT_NO_BREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESIST_COLD,
		TRAIT_RESIST_HEAT,
		TRAIT_SHOCKIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STUNIMMUNE,
		TRAIT_FORCED_GRAVITY,
	)


/datum/component/proximity_monitor/advanced/heretic_arena/Initialize(atom/_parent, range, _ignore_if_not_on_turf)
	. = ..()
	recalculate_field(full_recalc = TRUE)
	var/list/things_in_range = range(range)
	for(var/mob/living/carbon/human/human_in_range in things_in_range)
		human_in_range.add_traits(given_immunities, HERETIC_ARENA_TRAIT)
		contained_mobs += human_in_range
		if(!isheretic(human_in_range))
			var/obj/item/melee/sickly_blade/training/new_blade = new(get_turf(human_in_range))
			welfare_blades += new_blade
			INVOKE_ASYNC(human_in_range, TYPE_PROC_REF(/mob, put_in_hands), new_blade)
			human_in_range.mind?.add_antag_datum(/datum/antagonist/heretic_arena_participant)

		human_in_range.apply_status_effect(/datum/status_effect/arena_tracker)
		RegisterSignal(human_in_range, COMSIG_CAN_Z_MOVE, PROC_REF(on_try_z_move))
		RegisterSignal(human_in_range, COMSIG_LADDER_TRAVEL, PROC_REF(on_try_ladder))
		//RegisterSignal(human_in_range, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move))
		RegisterSignal(human_in_range, COMSIG_MOVABLE_POST_TELEPORT, PROC_REF(on_teleport))


/datum/component/proximity_monitor/advanced/heretic_arena/Destroy()
	for(var/mob/living/carbon/human/mob in contained_mobs)
		mob.remove_traits(given_immunities, HERETIC_ARENA_TRAIT)
		mob.remove_status_effect(/datum/status_effect/arena_tracker)
		UnregisterSignal(mob, list(COMSIG_CAN_Z_MOVE, COMSIG_LADDER_TRAVEL/*, COMSIG_MOVABLE_PRE_MOVE*/, COMSIG_MOVABLE_POST_TELEPORT))
		if(mob.mind?.has_antag_datum(/datum/antagonist/heretic_arena_participant))
			mob.mind.remove_antag_datum(/datum/antagonist/heretic_arena_participant)

	for(var/turf/to_restore in border_walls)
		to_restore.ChangeTurf(border_walls[to_restore])

	for(var/obj/to_refund as anything in welfare_blades)
		qdel(to_refund)

	arena_caster = null
	return ..()


/datum/component/proximity_monitor/advanced/heretic_arena/setup_edge_turf(turf/target)
	if(edge_is_a_field) // If the edge is considered a field, set it up like one
		setup_field_turf(target)

	var/old_turf = target.type
	target.ChangeTurf(/turf/simulated/wall/indestructible/heretic_wall)
	border_walls += target
	border_walls[target] += old_turf


/datum/component/proximity_monitor/advanced/heretic_arena/field_edge_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(!isliving(movable))
		return
	var/mob/living/living_mob = movable
	addtimer(CALLBACK(living_mob, TYPE_PROC_REF(/mob/living, remove_status_effect), /datum/status_effect/arena_tracker), 10 SECONDS)
	living_mob.remove_traits(given_immunities, HERETIC_ARENA_TRAIT)
	if(living_mob == arena_caster)
		QDEL_IN(parent, 3 SECONDS)


/// Prevents using ladders
/datum/component/proximity_monitor/advanced/heretic_arena/proc/on_try_ladder(mob/climber)
	SIGNAL_HANDLER
	return LADDER_TRAVEL_BLOCK


/// If we try to enter a space turf that has a mirage, we will block the movement
/*
/datum/component/proximity_monitor/advanced/heretic_arena/proc/on_pre_move(atom/movable/mover, atom/newloc)
	if(locate(/atom/movable/mirage_holder) in newloc.contents)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
*/


/// Blocks Z movement to new z levels
/datum/component/proximity_monitor/advanced/heretic_arena/proc/on_try_z_move(atom/movable/source, turf/start, turf/destination)
	SIGNAL_HANDLER
	if(start.z == destination.z)
		return

	return COMPONENT_CANT_Z_MOVE


/// If our caster teleports away (after winning presumably) we'll collapse the arena so that it doens't needlessly linger
/datum/component/proximity_monitor/advanced/heretic_arena/proc/on_teleport(atom/teleportee, atom/destination)
	if(teleportee != arena_caster)
		return

	qdel(parent)


/datum/component/proximity_monitor/advanced/heretic_arena/proc/set_caster(atom/caster)
	arena_caster = caster


/turf/simulated/wall/indestructible/heretic_wall
	name = "жуткая стена"
	desc = "Стена, не дающая овцам сбежать от волка. \
			Она излучает злобную энергию — трогать её, вероятно, неразумно."
	icon_state = "eldritch_forcewall"
	opacity = FALSE


/turf/simulated/wall/indestructible/heretic_wall/get_ru_names()
	return list(
		NOMINATIVE = "жуткая стена",
		GENITIVE = "жуткой стены",
		DATIVE = "жуткой стене",
		ACCUSATIVE = "жуткую стену",
		INSTRUMENTAL = "жуткой стеной",
		PREPOSITIONAL = "жуткой стене",
	)


/turf/simulated/wall/indestructible/heretic_wall/CanAllowThrough(atom/movable/mover, border_dir)
	if(!isliving(mover))
		return ..()

	var/mob/living/living_mover = mover
	var/datum/status_effect/arena_tracker/tracker = living_mover.has_status_effect(/datum/status_effect/arena_tracker)
	if(tracker?.arena_victor)
		return TRUE


/turf/simulated/wall/indestructible/heretic_wall/Bumped(atom/movable/bumped_atom)
	. = ..()
	if(!isliving(bumped_atom))
		return

	var/mob/living/living_mob = bumped_atom
	var/atom/target = get_edge_target_turf(living_mob, get_dir(src, get_step_away(living_mob, src)))
	living_mob.throw_at(target, 4, 5)
	to_chat(living_mob, span_userdanger("Стена отталкивает вас с огромной силой!"))


/// Called when you crit somebody to update your crown
/datum/status_effect/arena_tracker/proc/on_crit_somebody()
	owner.cut_overlay(crown_overlay)
	crown_overlay = mutable_appearance('icons/effects/crown.dmi', "arena_victor", -HALO_LAYER)
	crown_overlay.pixel_z = 24
	owner.add_overlay(crown_overlay)
	owner.remove_traits(list(TRAIT_ELDRITCH_ARENA_PARTICIPANT, TRAIT_NO_TELEPORT), TRAIT_STATUS_EFFECT(id))

	// The mansus celebrates your efforts
	if(isheretic(owner))
		owner.heal_overall_damage(60, 60, 60)
		owner.adjustToxLoss(-60, forced = TRUE) // Slime heretics everywhere...
		owner.adjustOxyLoss(-60)
		if(ishuman(owner))
			var/mob/living/carbon/human/human_owner = owner
			for(var/obj/item/organ/external/bodypart as anything in human_owner.bodyparts)
				bodypart.mend_fracture()
				bodypart.stop_internal_bleeding()


	if(arena_victor) // No need to spam if we've already killed at least 1 person
		return

	if(isheretic(owner))
		to_chat(owner, span_big(span_purple("Мансус доволен вашим выступлением, теперь вы свободны.")))
	else
		to_chat(owner, span_big(span_purple("Вы хорошо постарались, теперь вы можете идти.")))

	arena_victor = TRUE

/**
 * Status applied to every mob in the heretic arena.
 * Tracks the last person to damage owner.
 * When owner enters crit, we send a signal to last_attacker status so they can leave the arena
 */

/datum/status_effect/arena_tracker
	id = "arena_tracker"
	tick_interval = -1
	alert_type = null
	/// Tracks the last person who dealt damage to this mob
	var/datum/weakref/last_attacker
	/// If our mob is free to leave, set to true
	var/arena_victor = FALSE
	/// The overlay for our mob, changes color to indicate that they are a victor and are free to leave
	var/mutable_appearance/crown_overlay


/datum/status_effect/arena_tracker/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_IMPACT_ZONE, PROC_REF(on_impact_zone))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(damage_taken))
	owner.add_traits(list(TRAIT_ELDRITCH_ARENA_PARTICIPANT, TRAIT_NO_TELEPORT), TRAIT_STATUS_EFFECT(id))
	crown_overlay = mutable_appearance('icons/effects/crown.dmi', "arena_fighter", -HALO_LAYER)
	crown_overlay.pixel_z = 24
	owner.add_overlay(crown_overlay)
	return TRUE


/datum/status_effect/arena_tracker/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE)
	owner.remove_traits(list(TRAIT_ELDRITCH_ARENA_PARTICIPANT, TRAIT_NO_TELEPORT), TRAIT_STATUS_EFFECT(id))
	owner.cut_overlay(crown_overlay)
	crown_overlay = null


// If our last attacker is an arena participant, we let them know they've scored a critical hit
/datum/status_effect/arena_tracker/proc/on_enter_crit(mob/owner)
	if(!last_attacker)
		return // Safety check in case they somehow enter crit with *nobody* attacking them

	var/mob/living/our_attacker = last_attacker.resolve()
	if(!isliving(our_attacker) || our_attacker == owner) // We don't allow people to crit themselves as a valid way to escape
		return

	var/datum/status_effect/arena_tracker/their_tracker = our_attacker.has_status_effect(/datum/status_effect/arena_tracker)
	if(!their_tracker)
		return // Somebody killed us who isn't an arena participant

	their_tracker.on_crit_somebody()


/datum/status_effect/arena_tracker/proc/damage_taken(
	mob/living/source,
	damage_amount,
	damagetype,
	def_zone,
	blocked,
	sharp,
	used_weapon
)
	SIGNAL_HANDLER

	if(source.health <= HEALTH_THRESHOLD_CRIT) // I think it will work.
		on_enter_crit(source)

	if(isnull(used_weapon))
		return

	if(!isobj(used_weapon))
		return

	var/obj/attacking_object = used_weapon

	// Track being hit by a mob holding a stick
	if(ismob(attacking_object.loc))
		last_attacker = WEAKREF(attacking_object.loc)
		return

	// Edge case. If our used_weapon is a gun which the owner has dropped we need to find out who shot us
	// Track being hit by a mob shooting a stick
	if(!isprojectile(attacking_object))
		return

	var/obj/projectile/attacking_projectile = attacking_object
	if(ismob(attacking_projectile.firer))
		last_attacker = WEAKREF(attacking_projectile.firer)


///Called when impacted by something thrown at us, setting the last attacker to the person throwing the item.
/datum/status_effect/arena_tracker/proc/on_impact_zone(atom/source, mob/living/hitby, zone, blocked, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	// Track being hit by a mob throwing a stick
	if(!isitem(throwingdatum.thrownthing))
		return

	var/thrown_by = throwingdatum.thrower
	if(ismob(thrown_by))
		last_attacker = WEAKREF(thrown_by)


/datum/antagonist/heretic_arena_participant
	name = "Гладиатор"
	special_role = SPECIAL_ROLE_ARENA_FITER
	show_in_roundend = FALSE
	replace_banned = FALSE
	objectives = list()
	antag_hud_name = "brainwashed"
	//block_midrounds = FALSE


/datum/antagonist/heretic_arena_participant/on_gain()
	forge_objectives()
	return ..()


/datum/antagonist/heretic_arena_participant/proc/forge_objectives()
	var/datum/objective/survive = new /datum/objective
	survive.owner = owner
	survive.explanation_text = "Вы оказались в ловушке на арене. Единственный выход — убить кого-нибудь ещё. \
								Убить своего пленителя или предать друзей — выбор за вами."
	objectives += survive
	var/datum/objective/fight_to_escape = new /datum/objective
	fight_to_escape.owner = owner
	fight_to_escape.explanation_text = "Побег невозможен. Единственный выход — победить другого участника этой \
										битвы. Вам даровано оружие, дающее шанс на победу. Будет очень жаль, \
										если вы попытаетесь его сломать."
	objectives += fight_to_escape
