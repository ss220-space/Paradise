
// /mob/living signals
///from base of mob/living/resist() (/mob/living)
#define COMSIG_LIVING_RESIST "living_resist"
///from base of mob/living/IgniteMob() (/mob/living)
#define COMSIG_LIVING_IGNITED "living_ignite"
///from base of mob/living/WetMob() (/mob/living)
#define COMSIG_LIVING_WET "living_weted"
///from base of mob/living/ExtinguishMob() (/mob/living)
#define COMSIG_LIVING_EXTINGUISHED "living_extinguished"
///from base of mob/living/electrocute_act(): (shock_damage, atom/source, siemens_coeff, flags)
#define COMSIG_LIVING_ELECTROCUTE_ACT "living_electrocute_act"
	/// Block the electrocute_act() proc from proceeding
	#define COMPONENT_LIVING_BLOCK_SHOCK (1<<0)
///sent when items with siemen coeff. of 0 block a shock: (power_source, source, siemens_coeff, dist_check)
#define COMSIG_LIVING_SHOCK_PREVENTED "living_shock_prevented"
///sent by stuff like stunbatons and tasers: ()
#define COMSIG_LIVING_MINOR_SHOCK "living_minor_shock"
/// Source: /mob/living/proc/flash_eyes(intensity, override_blindness_check, affect_silicon, visual, type)
#define COMSIG_LIVING_EARLY_FLASH_EYES "living_flash_eyes"
	#define STOP_FLASHING_EYES (1<<0)
///from base of mob/living/revive() (full_heal, admin_revive)
#define COMSIG_LIVING_REVIVE "living_revive"

///sent from living mobs every tick of fire
#define COMSIG_LIVING_FIRE_TICK "living_fire_tick"
///sent from living mobs every tick of wet
#define COMSIG_LIVING_WET_TICK "living_wet_tick"
//sent from living mobs when they are ahealed
#define COMSIG_LIVING_AHEAL "living_aheal"
///From living/Life(). (deltatime, times_fired)
#define COMSIG_LIVING_LIFE "living_life"
///from base of mob/living/death(): (gibbed)
#define COMSIG_LIVING_EARLY_DEATH "living_early_death"
///from base of mob/living/death(): (gibbed)
#define COMSIG_LIVING_DEATH "living_death"
//sent from mobs when they exit their body as a ghost
#define COMSIG_LIVING_GHOSTIZED "ghostized"
//sent from mobs when they re-enter their body as a ghost
#define COMSIG_LIVING_REENTERED_BODY "reentered_body"
//sent from a mob when they set themselves to DNR
#define COMSIG_LIVING_SET_DNR "set_dnr"
///from base of mob/living/set_buckled(): (new_buckled)
#define COMSIG_LIVING_SET_BUCKLED "living_set_buckled"
///from base of mob/living/set_body_position()
#define COMSIG_LIVING_SET_BODY_POSITION "living_set_body_position"
///From living/set_resting(): (new_resting, silent, instant)
#define COMSIG_LIVING_RESTING "living_resting"
///from base of mob/update_transform()
#define COMSIG_LIVING_POST_UPDATE_TRANSFORM "living_post_update_transform"
/// Source: /mob/living/proc/apply_status_effect(datum/status_effect/new_instance)
#define COMSIG_LIVING_GAINED_STATUS_EFFECT "living_gained_status_effect"
/// Source: /mob/living/proc/remove_status_effect(datum/status_effect/existing_effect)
#define COMSIG_LIVING_EARLY_LOST_STATUS_EFFECT "living_early_lost_status_effect" // Called before qdel
/// From mob/living/try_speak(): (message)
#define COMSIG_MOB_TRY_SPEECH "living_vocal_speech"
	/// Return if the mob cannot speak.
	#define COMPONENT_CANNOT_SPEAK (1<<0)
/// From mob/living/proc/on_fall
#define COMSIG_LIVING_THUD "living_thud"
/// Sent to a mob grabbing another mob: (mob/living/grabbing)
#define COMSIG_LIVING_GRAB "living_grab"
// Return COMPONENT_CANCEL_ATTACK_CHAIN to stop the grab

///From base of mob/living/ZImpactDamage() (mob/living, levels, turf/t)
#define COMSIG_LIVING_Z_IMPACT "living_z_impact"
/// Just for the signal return, does not run normal living handing of z fall damage for mobs
	#define ZIMPACT_CANCEL_DAMAGE (1<<0)
	/// Do not show default z-impact message
	#define ZIMPACT_NO_MESSAGE (1<<1)
	/// Do not do the spin animation when landing
	#define ZIMPACT_NO_SPIN (1<<2)

	///From base of mob/living/MobBump() (mob/living)
#define COMSIG_LIVING_MOB_BUMP "living_mob_bump"

///from base of /mob/living/examine(): (mob/user, list/.)
#define COMSIG_LIVING_EXAMINE "living_examine"

/// Source: /mob/living/AdjustBlood(amount)
#define COMSIG_LIVING_BLOOD_ADJUST "living_blood_adjust"
	#define COMPONENT_PREVENT_BLOODLOSS (1<<0)
/// Source: /mob/living/AdjustBlood(amount)
#define COMSIG_LIVING_BLOOD_ADJUSTED "living_blood_adjusted"
/// Source: /mob/living/setBlood(amount)
#define COMSIG_LIVING_EARLY_SET_BLOOD "living_early_set_blood"
/// Source: /mob/living/setBlood(amount)
#define COMSIG_LIVING_SET_BLOOD "living_set_blood"

///From post-can inject check of syringe after attack (mob/user)
#define COMSIG_LIVING_TRY_SYRINGE "living_try_syringe"

///from base of /mob/living/can_track(): (mob/user)
#define COMSIG_LIVING_CAN_TRACK "mob_cantrack"
	#define COMPONENT_CANT_TRACK (1<<0)

/// From /mob/living/get_examine_name(mob/user) : (mob/examined, visible_name, list/name_override)
/// Allows mobs to override how they perceive others when examining
#define COMSIG_LIVING_PERCEIVE_EXAMINE_NAME "living_perceive_examine_name"
	#define COMPONENT_EXAMINE_NAME_OVERRIDEN (1<<0)

// Organ signals
///from [/obj/item/organ/internal/insert]:
#define COMSIG_ORGAN_IMPLANTED "organ_implanted"
///from [/obj/item/organ/internal/remove]:
#define COMSIG_ORGAN_REMOVED "organ_removed"
///from [/obj/item/organ/internal/cyberimp/mouth/translator/check_lang]
#define COMSIG_LANG_PRE_ACT "check_language"
	#define COMSIG_LANG_SECURED (1<<0)

// /datum/mind signals

///from base of /datum/mind/proc/transfer_to(mob/living/new_character)
#define COMSIG_MIND_TRANSER_TO "mind_transfer_to"
///called on the mob instead of the mind
#define COMSIG_BODY_TRANSFER_TO "body_transfer_to"

///from base of mob/living/Stun() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_STUN "living_stun"
///from base of mob/living/Weaken() (amount, ignore_canweaken)
#define COMSIG_LIVING_STATUS_WEAKEN "living_weaken"
///from base of mob/living/Knockdown() (amount, ignore_canknockdown)
#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown"
///from base of mob/living/Immobilize() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"
///from base of mob/living/unconscious() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_UNCONSCIOUS "living_unconscious"
///from base of mob/living/Paralyze() (amount, ignore_canparalyse)
#define COMSIG_LIVING_STATUS_PARALYZE "living_paralyze"
///from base of mob/living/Sleeping() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"
/// from mob/living/check_incapacitating_immunity(): (check_flags, force_apply)
#define COMSIG_LIVING_GENERIC_INCAPACITATE_CHECK "living_check_incapacitate"
	#define COMPONENT_NO_EFFECT (1<<0) //For all of them

/// From /mob/living/proc/stop_leaning()
#define COMSIG_LIVING_STOPPED_LEANING "living_stopped_leaning"

/// Source: /mob/living/say (message, verb, ignore_speech_problems, ignore_atmospherics, ignore_languages, datum/multilingual_say_piece)
#define COMSIG_LIVING_EARLY_SAY "living_early_say"
	#define COMPONENT_PREVENT_SPEAKING (1<<0)

/// Source: /mob/living/UnarmedAttack (atom/atom, proximity_flag)
#define COMSIG_LIVING_UNARMED_ATTACK "living_unarmed_attack"

/// from /proc/healthscan(): (list/scan_results, advanced, mob/user, mode)
/// Consumers are allowed to mutate the scan_results list to add extra information
#define COMSIG_LIVING_HEALTHSCAN "living_healthscan"

/// from start of /mob/living/handle_breathing(): (delta_time, times_fired)
#define COMSIG_LIVING_HANDLE_BREATHING "living_handle_breathing"

///from base of /mob/living/regenerate_limbs(): (noheal, excluded_limbs)
#define COMSIG_LIVING_REGENERATE_LIMBS "living_regen_limbs"
///from base of /obj/item/bodypart/proc/attach_limb(): (new_limb, special) allows you to fail limb attachment
#define COMSIG_LIVING_ATTACH_LIMB "living_attach_limb"
	#define COMPONENT_NO_ATTACH (1<<0)
