// /mob/living/carbon signals

///from base of mob/living/carbon/soundbang_act(): (list(intensity))
#define COMSIG_CARBON_SOUNDBANG "carbon_soundbang"
///from /item/organ/proc/Insert() (/obj/item/organ/)
#define COMSIG_CARBON_GAIN_ORGAN "carbon_gain_organ"
///from /item/organ/proc/Remove() (/obj/item/organ/)
#define COMSIG_CARBON_LOSE_ORGAN "carbon_lose_organ"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_EQUIP_HAT "carbon_equip_hat"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_UNEQUIP_HAT "carbon_unequip_hat"
///defined twice, in carbon and human's topics, fired when interacting with a valid embedded_object to pull it out (mob/living/carbon/target, /obj/item, /obj/item/bodypart/L)
#define COMSIG_CARBON_EMBED_RIP "item_embed_start_rip"
///called when removing a given item from a mob, from mob/living/carbon/remove_embedded_object(mob/living/carbon/target, /obj/item)
#define COMSIG_CARBON_EMBED_REMOVAL "item_embed_remove_safe"
// called when carbon receiving a /obj/item/organ/external/proc/fracture (/datum/fracture)
#define COMSIG_CARBON_RECEIVE_FRACTURE "carbon_receive_fracture"
///called when something thrown hits a mob, from /mob/living/carbon/human/hitby(mob/living/carbon/target, /obj/item)
#define COMSIG_CARBON_HITBY "carbon_hitby"
/// From /mob/living/carbon/human/hitby()
#define COMSIG_CARBON_THROWN_ITEM_CAUGHT "carbon_thrown_item_caught"
/// From /mob/living/carbon/toggle_throw_mode()
#define COMSIG_CARBON_TOGGLE_THROW "carbon_toggle_throw"
///When a carbon slips. Called on /turf/simulated/handle_slip()
#define COMSIG_ON_CARBON_SLIP "carbon_slip"
///called on /carbon when attempting to pick up an item, from base of /mob/living/carbon/put_in_hand_check(obj/item/I, hand_id)
#define COMSIG_CARBON_TRY_PUT_IN_HAND "carbon_try_put_in_hand"
	/// Can't pick up
	#define COMPONENT_CARBON_CANT_PUT_IN_HAND (1<<0)
#define COMSIG_ITEM_TRY_PUT_IN_HAND "carbon_try_put_in_hand"
	/// Can't pick up
	#define COMPONENT_ITEM_CANT_PUT_IN_HAND (1<<0)
/// from /mob/living/carbon/enter_stamcrit()
#define COMSIG_CARBON_ENTER_STAMCRIT "carbon_enter_stamcrit"
///Called from apply_overlay(cache_index, overlay)
#define COMSIG_CARBON_APPLY_OVERLAY "carbon_apply_overlay"
///Called from remove_overlay(cache_index, overlay)
#define COMSIG_CARBON_REMOVE_OVERLAY "carbon_remove_overlay"
#define COMSIG_CARBON_UPDATING_HEALTH_HUD "carbon_health_hud_update"
#define COMSIG_HUMAN_UPDATING_HEALTH_HUD "human_health_hud_update"
	/// Return if you override the carbon's or human's health hud with something else
	#define COMPONENT_OVERRIDE_HEALTH_HUD (1<<0)
///Called when someone attempts to cuff a carbon
#define COMSIG_CARBON_CUFF_ATTEMPTED "carbon_attempt_cuff"


// /mob/living/carbon/human signals

///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity)
#define COMSIG_HUMAN_EARLY_UNARMED_ATTACK "human_early_unarmed_attack"
///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"
///from mob/living/carbon/human/UnarmedAttack(): (mob/living/carbon/human/attacker)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY "human_melee_unarmed_attackby"
///Hit by successful disarm attack (mob/living/carbon/human/attacker,zone_targeted)
#define COMSIG_HUMAN_DISARM_HIT "human_disarm_hit"
///Whenever EquipRanked is called, called after job is set
#define COMSIG_JOB_RECEIVED "job_received"
// called after DNA is updated
#define COMSIG_HUMAN_UPDATE_DNA "human_update_dna"
/// From /mob/living/carbon/human/proc/try_update_nutrition_level()
#define COMSIG_HUMAN_NUTRITION_UPDATE "human_nutrition_update"
/// From /mob/living/carbon/human/proc/update_nutrition_slowdown()
#define COMSIG_HUMAN_NUTRITION_UPDATE_SLOWDOWN "human_nutrition_update_slowdown"
/// From mob/living/carbon/human/change_body_accessory(): (mob/living/carbon/human/H, body_accessory_style)
#define COMSIG_HUMAN_CHANGE_BODY_ACCESSORY "human_change_body_accessory"
	#define COMSIG_HUMAN_NO_CHANGE_APPEARANCE (1<<0)
/// From mob/living/carbon/human/change_head_accessory(): (mob/living/carbon/human/H, head_accessory_style)
#define COMSIG_HUMAN_CHANGE_HEAD_ACCESSORY "human_change_head_accessory"
///From mob/living/carbon/human/do_suicide()
#define COMSIG_HUMAN_SUICIDE_ACT "human_suicide_act"
///From mob/living/carbon/human/regenerate_icons()
#define COMSIG_HUMAN_REGENERATE_ICONS "human_regenerate_icons"
///From /mob/living/carbon/human/proc/set_species(): (datum/species/old_species)
#define COMSIG_HUMAN_SPECIES_CHANGED "human_species_changed"
	#define COMPONENT_HAS_ELEMENT (1<<0)
/// Source: /mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
#define COMSIG_HUMAN_EARLY_HANDLE_ENVIRONMENT "human_early_handle_environment"
///From mob/living/carbon/human/update_inv_back()
#define	COMSIG_HUMAN_UPDATE_BACK "human_update_back"

///from /mob/living/carbon/human/proc/check_shields(): (atom/hit_by, damage, attack_text, attack_type, armour_penetration, damage_type)
#define COMSIG_HUMAN_CHECK_SHIELDS "human_check_shields"
	#define SHIELD_BLOCK (1<<0)

#define COMSIG_HUMAN_DESTROYED "human_destroyed"

/// Source: /proc/random_hair_style (mob/living/carbon/human/human, valid_hairstyles, robohead)
#define COMSIG_RANDOM_HAIR_STYLE "random_hair_style"
