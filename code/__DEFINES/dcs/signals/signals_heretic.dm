/// Heretic signals

/// From /obj/effect/proc_holder/spell/touch/mansus_grasp/cast_on_hand_hit : (mob/living/source, mob/living/target)
#define COMSIG_HERETIC_MANSUS_GRASP_ATTACK "mansus_grasp_attack"
	/// Default behavior is to use the hand, so return this to block the mansus fist from being consumed after use.
	#define COMPONENT_BLOCK_HAND_USE (1<<0)
/// From /obj/effect/proc_holder/spell/touch/mansus_grasp/cast_on_secondary_hand_hit : (mob/living/source, atom/target)
#define COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY "mansus_grasp_attack_secondary"
	/// Default behavior is to continue attack chain and do nothing else, so return this to use up the hand after use.
	#define COMPONENT_USE_HAND (1<<0)

/// From /obj/item/melee/sickly_blade/afterattack : (mob/living/source, mob/living/target)
#define COMSIG_HERETIC_BLADE_ATTACK "blade_attack"
/// From /obj/item/melee/sickly_blade/ranged_interact_with_atom (without proximity) : (mob/living/source, mob/living/target)
#define COMSIG_HERETIC_RANGED_BLADE_ATTACK "ranged_blade_attack"

/// For [/datum/status_effect/protective_blades] to signal when it is triggered
#define COMSIG_BLADE_BARRIER_TRIGGERED "blade_barrier_triggered"

/// From the Cosmic-path hunter rifle (/obj/item/gun/...) when its projectile hits a target.
#define COMSIG_LIONHUNTER_ON_HIT "lionhunter_on_hit"

/// Sent on a mob right before they cast a spell. Used by some heretic buffs to react/intercept.
/// NOTE: master220 does not yet emit this anywhere; the listeners compile but won't fire until wired in the runtime pass.
#define COMSIG_MOB_BEFORE_SPELL_CAST "mob_before_spell_cast"

/// From tg's attack chain: sent on an atom when it is attacked. Used by blade-shield reaction and curse retaliation.
/// NOTE: master220 does not emit this in its attack chain yet; listeners compile but won't fire until wired in the runtime pass.
#define COMSIG_ATOM_WAS_ATTACKED "atom_was_attacked"
