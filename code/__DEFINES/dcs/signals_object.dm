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

/// from base of /obj/item/slimepotion/speed/interact_with_atom(): (obj/target, /obj/src, mob/user)
#define COMSIG_SPEED_POTION_APPLIED "speed_potion"
	#define SPEED_POTION_STOP (1<<0)

