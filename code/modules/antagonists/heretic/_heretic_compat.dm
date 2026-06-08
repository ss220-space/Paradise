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
