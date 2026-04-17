// Jetpack things

//called in /obj/item/tank/jetpack/proc/turn_on() : ()
#define COMSIG_JETPACK_ACTIVATED "jetpack_activated"
	#define JETPACK_ACTIVATION_FAILED (1<<0)
//called in /obj/item/tank/jetpack/proc/turn_off() : ()
#define COMSIG_JETPACK_DEACTIVATED "jetpack_deactivated"

/// Sent from obj/item/ui_action_click(): (mob/user, datum/action, leftclick)
#define COMSIG_ITEM_UI_ACTION_CLICK "item_action_click"
	/// Return to prevent the default behavior (attack_selfing) from ocurring.
	#define COMPONENT_ACTION_HANDLED (1<<0)

/// Sent from obj/item/item_action_slot_check(): (slot, mob/user, datum/action)
#define COMSIG_ITEM_UI_ACTION_SLOT_CHECKED "item_action_slot_checked"
	/// Return to prevent the default behavior (attack_selfing) from ocurring.
	#define COMPONENT_ITEM_ACTION_SLOT_INVALID (1<<0)

#define COMSIG_SPEED_POTION_APPLIED "speed_potion"
	#define SPEED_POTION_STOP (1<<0)

///from base of [/obj/proc/update_integrity]: (old_value, new_value)
#define COMSIG_OBJ_INTEGRITY_CHANGED "obj_integrity_changed"

///sent to targets during the process_hit proc of projectiles
#define COMSIG_FIRE_CASING "fire_casing"

///called in /obj/item/grenade/proc/prime(): (user)
#define COMSIG_GRENADE_DETONATE "grenade_prime"

///from [/obj/structure/closet/supplypod/proc/preOpen]:
#define COMSIG_SUPPLYPOD_LANDED "supplypodgoboom"

#define COMSIG_MORTAR_DETONATE "mortar_prime"

/// from  /datum/surgery_step/proc/initiate() : (&time)
#define COMSIG_SURGERY_STEP_INIT "surgery_step_init"

#define COMSIG_DISPOSAL_INJECT "disposal_inject"

/// Called by /obj/item/proc/worn_overlays(list/overlays, mutable_appearance/standing, isinhands, icon_file)
#define COMSIG_ITEM_GET_WORN_OVERLAYS "item_get_worn_overlays"
/// Called by /obj/item/proc/separate_worn_overlays(list/overlays, mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file)
#define COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS "item_get_separate_worn_overlays"

// /obj/machinery/atmospherics/components/binary/valve signals

/// from /obj/machinery/atmospherics/components/binary/valve/toggle(): (on)
#define COMSIG_VALVE_SET_OPEN "valve_toggled"

/// from /obj/machinery/atmospherics/set_on(active): (on)
#define COMSIG_ATMOS_MACHINE_SET_ON "atmos_machine_set_on"

/// from /obj/machinery/light_switch/set_lights(), sent to every switch in the area: (status)
#define COMSIG_LIGHT_SWITCH_SET "light_switch_set"


// /obj/item/gun signals

///called in /obj/item/gun/process_chamber (src)
#define COMSIG_GUN_CHAMBER_PROCESSED "gun_chamber_processed"


// /obj access signals

#define COMSIG_OBJ_ALLOWED "door_try_to_activate"
	#define COMPONENT_OBJ_ALLOW (1<<0)
	#define COMPONENT_OBJ_DISALLOW (1<<1)

#define COMSIG_AIRLOCK_SHELL_ALLOWED "airlock_shell_try_allowed"

// /obj/machinery/door/airlock signals

//from /obj/machinery/door/airlock/open(): (forced)
#define COMSIG_AIRLOCK_OPEN "airlock_open"
//from /obj/machinery/door/airlock/close(): (forced)
#define COMSIG_AIRLOCK_CLOSE "airlock_close"
///from /obj/machinery/door/airlock/set_bolt():
#define COMSIG_AIRLOCK_SET_BOLT "airlock_set_bolt"

// /obj/machinery/firealarm signals
/// from /obj/machinery/firealarm/proc/alarm()
#define COMSIG_FIREALARM_ON_TRIGGER "firealarm_trigger"
/// from /obj/machinery/firealarm/proc/reset()
#define COMSIG_FIREALARM_ON_RESET "firealarm_reset"

// /obj/item/camera signals

///from /obj/item/camera/captureimage(): (atom/target, mob/user)
#define COMSIG_CAMERA_IMAGE_CAPTURED "camera_image_captured"

/// from /obj/item/assembly/proc/pulsed(mob/pulser)
#define COMSIG_ASSEMBLY_PULSED "assembly_pulsed"

/// Sent from /obj/item/assembly/on_attach(): (atom/holder)
#define COMSIG_ASSEMBLY_ATTACHED "assembly_attached"

/// Sent from /obj/item/assembly/on_detach(): (atom/holder)
#define COMSIG_ASSEMBLY_DETACHED "assembly_detached"

/*
 * The following two signals are separate from the above two because buttons don't set the holder of the inserted assembly.
 * This causes subtle behavioral differences that future handlers for these signals may need to account for,
 * even if none of the currently implemented handlers do.
 */

/// Sent from /obj/machinery/button/assembly_act(obj/machinery/button/button, mob/user)
#define COMSIG_ASSEMBLY_ADDED_TO_BUTTON "assembly_added_to_button"

/// Sent from /obj/machinery/button/remove_assembly(obj/machinery/button/button, mob/user)
#define COMSIG_ASSEMBLY_REMOVED_FROM_BUTTON "assembly_removed_from_button"

/// Sent from /datum/powernet/add_cable()
#define COMSIG_CABLE_ADDED_TO_POWERNET "cable_added_to_powernet"

/// Sent from /datum/powernet/remove_cable()
#define COMSIG_CABLE_REMOVED_FROM_POWERNET "cable_removed_from_powernet"

/// Sent from /datum/powernet/remove_cable()
#define COMSIG_UPDATE_TWOHANDED_DAMAGE "update_twohanded_damage"

/// Sent from /obj/structure/bingle_hole to /datum/team/bingles
#define COMSIG_BINGLE_HOLE_INITIALIZED "bingle_hole_initialized"

/// Sent from /obj/structure/bingle_hole to /datum/team/bingles
#define COMSIG_BINGLE_HOLE_GROW "bingle_hole_grow"

/// Sent on camera switch in camera monitors (/obj/machinery/computer/security/ui_act(action, params))
#define COMSIG_MONITOR_CAMERA_SWITCHED "monitor_camera_switched"

/// From base of [/obj/item/proc/pre_attack_secondary()]: (atom/target, mob/user, list/modifiers, list/attack_modifiers)
#define COMSIG_ITEM_PRE_ATTACK_SECONDARY "item_pre_attack_secondary"
	#define COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN (1<<0)
	#define COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN (1<<1)
	#define COMPONENT_SECONDARY_CALL_NORMAL_ATTACK_CHAIN (1<<2)
///from base of obj/item/pre_attack_secondary(): (obj/item/weapon, atom/target, list/modifiers, list/attack_modifiers)
#define COMSIG_USER_PRE_ITEM_ATTACK_SECONDARY "user_pre_item_attack_secondary"
/// From base of [/obj/item/proc/attack_secondary()]: (atom/target, mob/user, list/modifiers, list/attack_modifiers)
#define COMSIG_ITEM_ATTACK_SECONDARY "item_attack_secondary"

#define COMSIG_CRUSHER_FIRED_BLAST "crusher_fired_blast"
