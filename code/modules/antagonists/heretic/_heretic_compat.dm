/**
 * master220 compatibility shims for the tg-derived heretic code.
 *
 * Small adapter procs that bridge API-name differences between the heretic source
 * (Paradise-selfharm / tg) and master220. Kept in the heretic module so core files stay clean.
 */

// --- Organ damage API ---
// tg/selfharm uses mob.adjustOrganLoss(slot, amount, ...); master220 organs use
// internal_receive_damage(amount, silent) / heal_internal_damage(amount, robo_repair).

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

/// Returns whether the given organ is robotic. tg helper not present in master220.
/proc/isroboticorgan(obj/item/organ/checked_organ)
	return checked_organ?.is_robotic()

/// tg's dismember() on a limb maps to master220's droplimb().
/obj/item/organ/external/proc/dismember()
	return droplimb()

/// tg's set_organ_damage(amount) — master220 organs have a `damage` var + max_damage.
/obj/item/organ/proc/set_organ_damage(amount, required_organ_flag)
	damage = clamp(amount, 0, max_damage)

// --- Misc behaviour shims (master220 lacks these tg procs; no-ops for now, behaviour = runtime polish) ---

/// tg stun-absorption buff (blade path "Furious Steel"). No-op until ported; stun immunity won't apply yet.
/mob/living/proc/add_stun_absorption(source, message, self_message, examine_message, max_seconds_of_stuns_blocked, delete_after_passing_max, recharge_time)
	return TRUE

/// tg "can this mob give up / be finished off" check. master220 approximation: in crit or dead.
/mob/living/proc/CanSuccumb()
	return (stat == UNCONSCIOUS || stat == DEAD)

/// tg freezes an object solid. master220 lacks it; report "not frozen" so callers skip the freeze visual.
/obj/proc/freeze_add()
	return FALSE

// --- Hallucination compat ---
// master220 has a simple Hallucinate(amount) but not tg's typed cause_hallucination()/datum hallucinations.
// Map to the generic effect (ignoring the specific delusion type) and stub the referenced types.
// NOTE: the specific moon/gate delusion visuals are a runtime-polish TODO.
/mob/living/proc/cause_hallucination(hallucination_type, reason, duration = 10 SECONDS, affects_us = TRUE, affects_others = FALSE)
	if(affects_us)
		Hallucinate(duration)

/datum/hallucination/delusion/preset/moon
/datum/hallucination/delusion/preset/heretic/gate

// --- More master220 compat shims ---

/// tg AdjustAllImmobility (stun/knockdown/immobilize); master220 closest = AdjustImmobilized.
/mob/living/proc/AdjustAllImmobility(amount, ignore_canstun = FALSE)
	return AdjustImmobilized(amount, ignore_canstun)

/// tg calls this after editing turf air; master220 MILLA propagates automatically. No-op.
/turf/proc/air_update_turf(update = FALSE, update_visuals = FALSE)
	return

/// tg "does this mob need a heart to live"; master220 approximation: carbons do.
/mob/living/carbon/proc/needs_heart()
	return TRUE

/// tg unequip_everything strips a mob; master220 approximation drops held items (worn = runtime polish).
/mob/living/proc/unequip_everything()
	drop_all_held_items()

/// tg's is_centcomm(z); master220 treats centcom as an admin z-level.
/proc/is_centcomm(z)
	return is_admin_level(z)

/// tg timed-examine hook; master220 examine is instant. Base returns 0; heretic influence overrides it
/// for flavor but master220 won't honor the delay (runtime polish).
/atom/proc/get_examine_time()
	return 0

// tg cultblade "free_use" var (lets non-cultists wield without backlash). Behaviour wiring = runtime polish.
/obj/item/melee/cultblade
	var/free_use = FALSE

// --- Projectile helper ---
// tg's /obj/projectile/proc/is_hostile_projectile() isn't present in master220.
// A projectile counts as hostile here if it deals damage.
/obj/projectile/proc/is_hostile_projectile()
	return damage > 0

// --- Rust system base hooks ---
// Base no-op; specific atoms/turfs override rust_heretic_act() to define what rusting does to them.
// NOTE: the per-type rust-behaviour overrides (windows, machines, walls becoming rusted) are scattered
// across base files in tg/selfharm and are deferred to the Rust-path runtime polish; only the base
// hooks are provided here so the heretic code compiles. /turf rusting is handled by rust_turf.dm.
/atom/proc/rust_heretic_act(strength)
	return

/// Wrapper proc that passes our mob's rust_strength to the target we are rusting.
/mob/proc/do_rust_heretic_act(atom/target)
	var/datum/antagonist/heretic/heretic_data = mind?.has_antag_datum(/datum/antagonist/heretic)
	target.rust_heretic_act(heretic_data?.rust_strength)

// --- Misc compat ---
// tg gates phasing per-z via ZTRAIT_NOPHASE, which master220 doesn't have. Default to allowed.
/proc/is_phase_allowed(z)
	return TRUE

// tg objectives recompute their explanation_text via this hook; master220 sets it directly.
// Base no-op so heretic objective overrides (and calls on plain objectives) resolve.
/datum/objective/proc/update_explanation_text()
	return

// Russian "in the <dir>" helper used by the living-heart compass.
// (dir2rustext already exists in master220's type2type.dm; only this wrapper is missing.)
/proc/dir2rustext_where(direction)
	return "на [dir2rustext(direction)]е"

// --- Jaunt compat ---
// master220 defines its own /obj/effect/dummy/spell_jaunt (ethereal_jaunt.dm) but lacks the tg API
// the heretic jaunt spells (mirror_walk/space_crawl/ash_jaunt) use. Add the missing bits here.
// NOTE: full reconciliation of the two jaunt models is task #8 (runtime); this unblocks compile +
// gives working behaviour for the heretic flow which sets `jaunter` itself.
/obj/effect/dummy/spell_jaunt
	/// The movable currently jaunting inside this dummy (tg API).
	var/atom/movable/jaunter
	/// Icon state for the jaunter's position indicator (set by some heretic jaunt subtypes).
	var/phased_mob_icon_state

/// Ejects the jaunter to our turf and deletes the dummy.
/obj/effect/dummy/spell_jaunt/proc/eject_jaunter()
	if(!jaunter)
		return
	var/turf/eject_spot = get_turf(src)
	if(!eject_spot)
		return
	jaunter.forceMove(eject_spot)
	qdel(src)

/// TRUE if the given mob is currently inside a jaunt dummy.
/proc/is_jaunting(mob/living/possibly_jaunting)
	return istype(possibly_jaunting?.loc, /obj/effect/dummy/spell_jaunt)

// tg item visual-only equip hook; master220 uses equipped(). Base no-op so mutant-hand overrides compile.
// NOTE: master220 won't auto-call this, so mutant-hand visuals are cosmetic-TODO (runtime polish).
/obj/item/proc/visual_equipped(mob/user, slot, initial = FALSE)
	return

// tg helper: which body zones are covered by the mob's clothing. master220 lacks it; return none
// (so noticable organs are always considered visible — slight over-reveal, runtime polish).
/mob/living/carbon/proc/get_covered_body_zones()
	return list()

/// tg's get_held_items() — master220 exposes hands via get_active_hand()/get_inactive_hand().
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
