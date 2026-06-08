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

/// Sent on a carbon when they're about to gain a brain trauma : (datum/brain_trauma/trauma, resilience)
#define COMSIG_CARBON_GAIN_TRAUMA "carbon_gain_trauma"
	/// Return to block the trauma from being applied.
	#define COMSIG_CARBON_BLOCK_TRAUMA (1<<0)

// Heretic-used signals absent from master220. Defined so listeners compile.
// NOTE: master220 may not emit all of these yet — the corresponding behaviour needs runtime-pass wiring.
/// From a touch spell cast without a free hand (handless cast).
#define COMSIG_TOUCH_HANDLESS_CAST "spell_touch_handless_cast"
/// Sent on an organ that's about to be replaced by another.
#define COMSIG_ORGAN_BEING_REPLACED "organ_being_replaced"
/// Sent on a movable just after it teleports.
#define COMSIG_MOVABLE_POST_TELEPORT "movable_post_teleport"
/// Sent on a mob when it tries to access something locked (keyring / lock path).
#define COMSIG_MOB_TRIED_ACCESS "tried_access"
/// Sent on a mob when ejected from a jaunt.
#define COMSIG_MOB_EJECTED_FROM_JAUNT "spell_mob_eject_jaunt"

// More heretic-used signals absent from master220 (define for compile; runtime-emit may need wiring).
#define COMSIG_ATOM_HOLYATTACK "atom_holyattacked"
#define COMSIG_BEING_STRIPPED "try_strip"
#define COMSIG_CAN_Z_MOVE "movable_can_z_move"
#define COMSIG_GET_DREAMS "get_dreams"
#define COMSIG_ITEM_HARVESTED_SOMEBODY "item_harvested_somebody"
#define COMSIG_LADDER_TRAVEL "ladder-travel"
#define COMSIG_LIVING_CULT_SACRIFICED "living_cult_sacrificed"
#define COMSIG_MOB_ENSLAVED_TO "mob_enslaved_to"
#define COMSIG_MOB_SPELL_ACTIVATED "mob_spell_active"
/// Return flag for a cuff-prevent signal.
#define COMSIG_CARBON_CUFF_PREVENT (1<<0)
#define COMSIG_CARBON_POST_ATTACH_LIMB "carbon_post_attach_limb"
#define COMSIG_CARBON_POST_REMOVE_LIMB "carbon_post_remove_limb"
#define COMSIG_MOB_EQUIPPED_ITEM "mob_equipped_item"

/// Sent on a mob right before they cast a spell. Used by some heretic buffs to react/intercept.
/// NOTE: master220 does not yet emit this anywhere; the listeners compile but won't fire until wired in the runtime pass.
#define COMSIG_MOB_BEFORE_SPELL_CAST "mob_before_spell_cast"

/// From tg's attack chain: sent on an atom when it is attacked. Used by blade-shield reaction and curse retaliation.
/// NOTE: master220 does not emit this in its attack chain yet; listeners compile but won't fire until wired in the runtime pass.
#define COMSIG_ATOM_WAS_ATTACKED "atom_was_attacked"
