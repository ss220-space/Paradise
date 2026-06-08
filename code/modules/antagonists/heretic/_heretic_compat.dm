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
