// /obj signals
///from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"
///called in /obj/structure/setAnchored(): (value)
#define COMSIG_OBJ_SETANCHORED "obj_setanchored"
///from base of code/game/machinery
#define COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH "obj_default_unfasten_wrench"
///from base of /turf/proc/levelupdate(). (intact) true to hide and false to unhide
#define COMSIG_OBJ_HIDE "obj_hide"
///from base of /proc/possess(): (mob/user)
#define COMSIG_OBJ_POSSESSED "obj_possessed"
///from base of /proc/release(): (mob/user)
#define COMSIG_OBJ_RELEASED "obj_released"
///from [/obj/structure/sink/attack_hand]
#define COMSIG_SINK_ACT "sink_act"
	/// returns on succes of species special sink_act()
	#define COMSIG_SINK_ACT_SUCCESS (1<<0)

// /obj/item signals
///from base of obj/item/attack(): (/mob/living/target, /mob/living/user, params, def_zone)
#define COMSIG_ITEM_ATTACK "item_attack"
///from base of obj/item/attack_self(): (/mob)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"
//from base of obj/item/attack_self_secondary(): (/mob)
#define COMSIG_ITEM_ATTACK_SELF_SECONDARY "item_attack_self_secondary"
///from base of obj/item/attack_obj(): (/obj, /mob)
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"
///from base of obj/item/pre_attackby(): (atom/target, mob/user, params)
#define COMSIG_ITEM_PRE_ATTACKBY "item_pre_attackby"
///from base of obj/item/afterattack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"
///from base of obj/item/attack_qdeleted(): (atom/target, mob/user, params)
#define COMSIG_ITEM_ATTACK_QDELETED "item_attack_qdeleted"
///from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_EQUIPPED "item_equip"
///called on [/obj/item] before unequip from base of [mob/proc/do_Equip]: (force, atom/newloc, no_move, invdrop)
#define COMSIG_ITEM_PRE_UNEQUIP "item_pre_unequip"
	///only the pre unequip can be cancelled
	#define COMPONENT_ITEM_BLOCK_UNEQUIP (1<<0)
///called on [/obj/item] AFTER unequip from base of [mob/proc/do_unEquip]: (force, atom/newloc, no_move, invdrop, silent)
#define COMSIG_ITEM_POST_UNEQUIP "item_post_unequip"
///from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_DROPPED "item_drop"
///from base of obj/item/pickup(): (/mob/taker)
#define COMSIG_ITEM_PICKUP "item_pickup"
///return a truthy value to prevent ensouling, checked in /obj/effect/proc_holder/spell/lichdom/cast(): (mob/user)
#define COMSIG_ITEM_IMBUE_SOUL "item_imbue_soul"
///called before marking an object for retrieval, checked in /obj/effect/proc_holder/spell/summonitem/cast() : (mob/user)
#define COMSIG_ITEM_MARK_RETRIEVAL "item_mark_retrieval"
	#define COMPONENT_BLOCK_MARK_RETRIEVAL (1<<0)
///from base of obj/item/hit_reaction(): (list/args)
#define COMSIG_ITEM_HIT_REACT "item_hit_react"
	#define COMPONENT_BLOCK_SUCCESSFUL (1 << 0)
///called on item when crossed by something (): (/atom/movable, mob/living/crossed)
#define COMSIG_ITEM_WEARERCROSSED "wearer_crossed"
///from base of item/sharpener/attackby(): (amount, max)
#define COMSIG_ITEM_SHARPEN_ACT "sharpen_act"
	#define COMPONENT_BLOCK_SHARPEN_APPLIED (1<<0)
	#define COMPONENT_BLOCK_SHARPEN_BLOCKED (1<<1)
	#define COMPONENT_BLOCK_SHARPEN_ALREADY (1<<2)
	#define COMPONENT_BLOCK_SHARPEN_MAXED (1<<3)
///from base of [/obj/item/proc/tool_check_callback]: (mob/living/user)
#define COMSIG_TOOL_IN_USE "tool_in_use"
///from base of [/obj/item/proc/tool_start_check]: (mob/living/user)
#define COMSIG_TOOL_START_USE "tool_start_use"
///from [/obj/item/proc/disableEmbedding]:
#define COMSIG_ITEM_DISABLE_EMBED "item_disable_embed"
///from [/obj/effect/mine/proc/triggermine]:
#define COMSIG_MINE_TRIGGERED "minegoboom"

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

#define COMSIG_CRYSTAL_MASS_CONSUME "crystal_mass_consume"

///from base of obj/gun/projectile/automatic/toggle_firemode(): (/mob/user, firemode)
#define COMSIG_GUN_TOGGLE_FIREMODE "gun_firemode_toggle"
///from base of obj/gun/process_fire(): (/atom/target, /mob/living/user)
#define COMSIG_GUN_AFTER_PROCESS_FIRE "gun_after_process_fire"

///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_MOB_FIRED_GUN "mob_fired_gun"

///called in /obj/item/gun/process_fire (user, target)
#define COMSIG_GUN_FIRED "gun_fired"

/// Sent from obj/item/gun/toggle_gunlight_verb(): (user)
#define COMSIG_GUN_LIGHT_TOGGLE "gun_light_toggle"

/// Sent from obj/item/gun/zoom(): (user, zoomed)
#define COMSIG_GUN_ZOOM_TOGGLE "gun_zoom_toggle"

/// Sent from datum/component/laser_sight/datum/keybinding/toggle_laser_sight/down(): (user, gun)
#define COMSIG_KEYBINDING_GUN_LASER_SIGHT "keybbinding_laser_sight_toggle"

/// Sent from datum/component/laser_sight/process_aim(): (user, enable)
#define COMSIG_GUN_AFTER_LASER_SIGHT_TOGGLE "gun_after_laser_sight_toggle"

/// Sent from obj/item/gun_module/on_attach(): (user, obj/item/gun, obj/item/gun_module)
#define COMSIG_GUN_MODULE_ATTACH "gun_module_attach"
/// Sent from obj/item/gun_module/on_detach(): (user, obj/item/gun, obj/item/gun_module)
#define COMSIG_GUN_MODULE_DETACH "gun_module_detach"

// /obj/item/grenade signals
///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_PRIME "grenade_prime"
///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_ARMED "grenade_armed"

// /obj/projectile signals (sent to the firer)
///from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_SELF_ON_HIT "projectile_self_on_hit"
///from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_ON_HIT "projectile_on_hit"
///from base of /obj/projectile/proc/fire(): (obj/projectile, atom/original_target)
#define COMSIG_PROJECTILE_BEFORE_FIRE "projectile_before_fire"
///from the base of /obj/projectile/proc/fire(): ()
#define COMSIG_PROJECTILE_FIRE "projectile_fire"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_PREHIT "com_proj_prehit"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_RANGE_OUT "projectile_range_out"
///sent when trying to force an embed (mainly for projectiles, only used in the embed element)
#define COMSIG_EMBED_TRY_FORCE "item_try_embed"

///sent to targets during the process_hit proc of projectiles
#define COMSIG_PELLET_CLOUD_INIT "pellet_cloud_init"

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

// /obj/machinery/power/supermatter_crystal
/// from /obj/machinery/power/supermatter_crystal/process_atmos(); when the SM sounds an audible alarm
#define COMSIG_SUPERMATTER_DELAM_ALARM "sm_delam_alarm"
/// from /datum/component/supermatter_crystal/proc/consume()
/// called on the thing consumed, passes the thing which consumed it
#define COMSIG_SUPERMATTER_CONSUMED "sm_consumed_this"

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

// /obj/item signals for economy
///called when an item is sold by the exports subsystem
#define COMSIG_ITEM_SOLD "item_sold"
///called when a wrapped up structure is opened by hand
#define COMSIG_STRUCTURE_UNWRAPPED "structure_unwrapped"
#define COMSIG_ITEM_UNWRAPPED "item_unwrapped"
///called when a wrapped up item is opened by hand
	#define COMSIG_ITEM_SPLIT_VALUE (1<<0)
///called when getting the item's exact ratio for cargo's profit.
#define COMSIG_ITEM_SPLIT_PROFIT "item_split_profits"
///called when getting the item's exact ratio for cargo's profit, without selling the item.
#define COMSIG_ITEM_SPLIT_PROFIT_DRY "item_split_profits_dry"

// /obj/item/pda signals
///called on pda when the user changes the ringtone: (mob/living/user, new_ringtone)
#define COMSIG_PDA_CHANGE_RINGTONE "pda_change_ringtone"
	#define COMPONENT_STOP_RINGTONE_CHANGE (1<<0)
#define COMSIG_PDA_CHECK_DETONATE "pda_check_detonate"
	#define COMPONENT_PDA_NO_DETONATE (1<<0)

// /obj/item/radio signals
///called from base of /obj/item/radio/proc/set_frequency(): (list/args)
#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"

// /obj/item/pen signals
///called after rotation in /obj/item/pen/attack_self(): (rotation, mob/living/carbon/user)
#define COMSIG_PEN_ROTATED "pen_rotated"

// /obj/item/implant signals
///from base of /obj/item/implant/proc/activate(): ()
#define COMSIG_IMPLANT_ACTIVATED "implant_activated"
///from base of /obj/item/implant/proc/implant(): (list/args)
#define COMSIG_IMPLANT_IMPLANTING "implant_implanting"
	#define COMPONENT_STOP_IMPLANTING (1<<0)
///called on already installed implants when a new one is being added in /obj/item/implant/proc/implant(): (list/args, obj/item/implant/new_implant)
#define COMSIG_IMPLANT_OTHER "implant_other"
	//#define COMPONENT_STOP_IMPLANTING (1<<0) //The name makes sense for both
	#define COMPONENT_DELETE_NEW_IMPLANT (1<<1)
	#define COMPONENT_DELETE_OLD_IMPLANT (1<<2)
///called on implants being implanted into someone with an uplink implant: (datum/component/uplink)
#define COMSIG_IMPLANT_EXISTING_UPLINK "implant_uplink_exists"
	//This uses all return values of COMSIG_IMPLANT_OTHER


// /obj/mecha signals
///sent from mecha action buttons to the mecha they're linked to
#define COMSIG_MECHA_ACTION_ACTIVATE "mecha_action_activate"

// /obj/docking_port/mobile signals
///from /obj/docking_port/mobile/proc/dock(): (obj/docking_port/stationary/new_dock)
#define COMSIG_SHUTTLE_DOCK "shuttle_dock"


#define COMSIG_GLOVES_DOUBLE_HANDS_TOUCH "gloves_double_hands_touch"

// /obj/item/clothing signals
///from [/mob/living/carbon/human/Move]: ()
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"
///from base of /obj/item/clothing/suit/space/proc/toggle_spacesuit(): (obj/item/clothing/suit/space/suit)
#define COMSIG_SUIT_SPACE_TOGGLE "suit_space_toggle"

#define COMSIGN_TICKET_COUNT_UPDATE "ticket_count_updated"

/// Called on tripwire activation (/obj/item/tripwire)
#define COMSIG_TRIPWIRE_TRIGGERED "tripwire_triggered"
// Called on payload installing at tripwire
#define COMSIG_TRIPWIRE_BASE_ACTIVATE "tripwire_base_activate"

/// Called when attempting to insert a stack into the material container. (obj/item/stack/stack, amount)
#define COMSIG_MATERIAL_CONTAINER_ON_INSERT_STACK "material_container_on_insert_stack"
	/// Stack was successfully inserted into the container
	#define CONTAINER_INSERT_SUCCESS (1<<0)
	/// Failed to insert stack (no space, invalid material, etc)
	#define CONTAINER_INSERT_FAILED (1<<1)

/// Called when using tool from toolbox via radial menu
#define COMSIG_TOOLBOX_RADIAL_MENU_TOOL_USAGE "toolbox_radial_menu_tool_usage"

/// /obj/item/card/id/proc/freeze_linked_account(datum/source)
#define COMSIG_FREEZE_LINKED_ACCOUNT "nigga_freeze"

/// from base of atom/obj/item/death_book
#define COMSIG_PHANTOM_DELETE "phantom_delete"

/// Called after placing item on table. (mob/user, obj/structure/table)
#define COMSIG_ITEM_PLACED_ON_TABLE "item_placed_on_table"
