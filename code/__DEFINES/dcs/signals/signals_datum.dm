// Datum signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /datum signals
/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of ClearFromParent(): (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"
/// before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PREQDELETED "parent_preqdeleted"
/// just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called
#define COMSIG_QDELETING "parent_qdeleting"
/// generic topic handler (usr, href_list)
#define COMSIG_TOPIC "handle_topic"
/// Forces you to equip a hood
#define COMSIG_EQUIP_HOOD "force_hood_equip"

/// fires on the target datum when an element is attached to it (/datum/element)
#define COMSIG_ELEMENT_ATTACH "element_attach"
/// fires on the target datum when an element is attached to it  (/datum/element)
#define COMSIG_ELEMENT_DETACH "element_detach"

// /datum/species signals
///from datum/species/on_species_gain(): (datum/species/new_species, datum/species/old_species)
#define COMSIG_SPECIES_GAIN "species_gain"
///from datum/species/on_species_loss(): (datum/species/lost_species)
#define COMSIG_SPECIES_LOSS "species_loss"

// /datum/action signals
///from base of datum/action/proc/Trigger(): (datum/action)
#define COMSIG_ACTION_TRIGGER "action_trigger"
	#define COMPONENT_ACTION_BLOCK_TRIGGER (1<<0)
/// From /datum/action/Grant(): (mob/grant_to)
#define COMSIG_ACTION_GRANTED "action_grant"
/// From /datum/action/Grant(): (datum/action)
#define COMSIG_MOB_GRANTED_ACTION "mob_action_grant"
/// From /datum/action/Remove(): (mob/removed_from)
#define COMSIG_ACTION_REMOVED "action_removed"
/// From /datum/action/Remove(): (datum/action)
#define COMSIG_MOB_REMOVED_ACTION "mob_action_removed"
/// From /datum/action/apply_button_overlay()
#define COMSIG_ACTION_OVERLAY_APPLY "action_overlay_applied"
// TODO: spaghetti write comment here
#define COMSIG_ACTION_BUTTON_UPDATE "action_button_update"
	#define COMSIG_ACTION_UPDATE_INTERRUPT (1<<0)
/// From base of /datum/action/cooldown/proc/set_statpanel_format(): (list/stat_panel_data)
#define COMSIG_ACTION_SET_STATPANEL "ability_set_statpanel"
/// From /datum/action/innate/borer/make_larvae/Activate (turf/turf)
#define COMSIG_BORER_REPRODUCE "borer_reproduced"
///from /datum/action/armguard_hidden_blade/Trigger(): ()
#define COMSIG_ARMGUARD_ACTION_TOGGLE "armguard_action_toggle"

// //datum/status_effect
/// from base of /datum/status_effect/Destroy() : (effect_type)
#define COMSIG_MOB_STATUS_EFFECT_ENDED "mob_status_effect_ended"

// /datum/objective signals
///from datum/objective/proc/find_target()
#define COMSIG_OBJECTIVE_TARGET_FOUND "objective_target_found"
///from datum/objective/is_invalid_target()
#define COMSIG_OBJECTIVE_CHECK_VALID_TARGET "objective_check_valid_target"
	#define OBJECTIVE_VALID_TARGET (1<<0)
	#define OBJECTIVE_INVALID_TARGET (1<<1)

/// From /datum/diablerie_level/proc/gain()
#define SIGNAL_DIABLERIE_LEVEL_GAIN "diablerie_level_gain"
/// From /datum/diablerie_level/proc/remove()
#define SIGNAL_DIABLERIE_LEVEL_REMOVE "diablerie_level_remove"

// /datum/component/storage signals
///() - returns bool.
#define COMSIG_CONTAINS_STORAGE "is_storage"
///(obj/item/inserting, mob/user, silent, force) - returns bool
#define COMSIG_TRY_STORAGE_INSERT "storage_try_insert"
///(mob/show_to, force) - returns bool.
#define COMSIG_TRY_STORAGE_SHOW "storage_show_to"
///(mob/hide_from) - returns bool
#define COMSIG_TRY_STORAGE_HIDE_FROM "storage_hide_from"
///returns bool
#define COMSIG_TRY_STORAGE_HIDE_ALL "storage_hide_all"
///(newstate)
#define COMSIG_TRY_STORAGE_SET_LOCKSTATE "storage_lock_set_state"
///() - returns bool. MUST CHECK IF STORAGE IS THERE FIRST!
#define COMSIG_IS_STORAGE_LOCKED "storage_get_lockstate"
///(type, atom/destination, amount = INFINITY, check_adjacent, force, mob/user, list/inserted) - returns bool - type can be a list of types.
#define COMSIG_TRY_STORAGE_TAKE_TYPE "storage_take_type"
///(type, amount = INFINITY, force = FALSE). Force will ignore max_items, and amount is normally clamped to max_items.
#define COMSIG_TRY_STORAGE_FILL_TYPE "storage_fill_type"
///(obj, new_loc, force = FALSE) - returns bool
#define COMSIG_TRY_STORAGE_TAKE "storage_take_obj"
///(loc) - returns bool - if loc is null it will dump at parent location.
#define COMSIG_TRY_STORAGE_QUICK_EMPTY "storage_quick_empty"
///(list/list_to_inject_results_into, recursively_search_inside_storages = TRUE)
#define COMSIG_TRY_STORAGE_RETURN_INVENTORY "storage_return_inventory"
///(obj/item/insertion_candidate, mob/user, silent) - returns bool
#define COMSIG_TRY_STORAGE_CAN_INSERT "storage_can_equip"

// /datum/component/two_handed signals
///from base of datum/component/two_handed/proc/wield(mob/living/carbon/user): (/mob/user)
#define COMSIG_TWOHANDED_WIELD "twohanded_wield"
	#define COMPONENT_TWOHANDED_BLOCK_WIELD (1<<0)
///from base of datum/component/two_handed/proc/unwield(mob/living/carbon/user): (/mob/user)
#define COMSIG_TWOHANDED_UNWIELD "twohanded_unwield"

///from /datum/component/bubble_icon_override/get_bubble_icon(): (list/holder)
#define COMSIG_GET_BUBBLE_ICON "get_bubble_icon"

// /datum/component/bluespace_rift_scanner signals
/// from scanner's `process()` : (seconds, emagged)
#define COMSIG_SCANNING_RIFTS "scanning_rifts"
	/// No rifts within the scanner's range
	#define COMPONENT_SCANNED_NOTHING (1<<0)
	/// There are some rifts within the scanner's range
	#define COMPONENT_SCANNED_NORMAL (1<<1)
	/// The scanner is within critical range of a rift
	#define COMPONENT_SCANNED_CRITICAL (1<<2)
	/// There are no servers available
	#define COMPONENT_SCANNED_NO_SERVERS (1<<3)

//NTnet
///called on an object by its NTNET connection component on receive. (sending_id(number), sending_netname(text), data(datum/netdata))
#define COMSIG_COMPONENT_NTNET_RECEIVE "ntnet_receive"

// /datum/component/overlay_lighting signals, (for-future-backporting)
///from base of atom/CheckParts(): (atom/movable/new_craft) - The atom has just been used in a crafting recipe and has been moved inside new_craft.
#define COMSIG_ATOM_USED_IN_CRAFT "atom_used_in_craft"

/// Source: /datum/component/ritual_object/proc/pre_ritual_check (status_bitflag, mob/living/carbon/human, list/invokers, list/used_things)
#define COMSIG_RITUAL_ENDED "ritual_ended"

/// Source: /datum/component/object_possession/proc/on_move (mob/mob, new_loc, direct)
#define COMSIG_POSSESSED_MOVEMENT "possessed_movement"

/// Source: /datum/component/lunge_attack/Detach (obj/item/target)
#define COMSIG_LUNGE_DUAL_STRIKE "lunge_dual_strike"

///from /datum/spawners_menu/ui_act(): (mob/user)
#define COMSIG_IS_GHOST_CONTROLABLE "is_ghost_controllable"
	/// Return this to signal that the mob can be controlled by ghosts
	#define COMPONENT_GHOST_CONTROLABLE (1<<0)

/// datum/element/reagent_attack
/// Source: /datum/element/reagent_attack/proc/inject (datum/element/reagent_attack, mob/living/carbon/target, reagent_id, reagent_amount, target_zone)
#define COMSIG_REAGENT_INJECTED "reagent_inject"

// /datum/element/movetype_handler signals
/// Called when the floating anim has to be temporarily stopped and restarted later: (timer)
#define COMSIG_PAUSE_FLOATING_ANIM "pause_floating_anim"
/// From base of datum/element/movetype_handler/on_movement_type_trait_gain: (flag, old_movement_type)
#define COMSIG_MOVETYPE_FLAG_ENABLED "movetype_flag_enabled"
/// From base of datum/element/movetype_handler/on_movement_type_trait_loss: (flag, old_movement_type)
#define COMSIG_MOVETYPE_FLAG_DISABLED "movetype_flag_disabled"

///from base of /datum/element/after_attack/Attach(): (datum/sender, proc_ref)
#define COMSIG_ITEM_REGISTER_AFTERATTACK "register_item_afterattack"
///from base of /datum/element/after_attack/Detach(): (proc_ref)
#define COMSIG_ITEM_UNREGISTER_AFTERATTACK "unregister_item_afterattack"

#define COMSIG_MASKFILTER_UPDATE_STATE "ttsfilter_update_state"

/// Sent after addind a camera to the cameranet datum (/datum/cameranet/proc/addCamera(obj/machinery/camera/c))
#define COMSIG_CAMERANET_CAMERA_ADDED "cameranet_camera_added"

/// Sent after removing a camera from the cameranet datum (/datum/cameranet/proc/removeCamera(obj/machinery/camera/c))
#define COMSIG_CAMERANET_CAMERA_REMOVED "cameranet_camera_removed"
