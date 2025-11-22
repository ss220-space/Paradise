//Action availability flags
///Action button checks if hands are unusable
#define AB_CHECK_HANDS_BLOCKED (1<<0)
///Action button checks if user is immobile
#define AB_CHECK_IMMOBILE (1<<1)
///Action button checks if user is resting
#define AB_CHECK_LYING (1<<2)
///Action button checks if user is conscious
#define AB_CHECK_CONSCIOUS (1<<3)
///Action button checks if user is incapacitated (weakened/stunned/stamcrited/paralyzed/sleeping)
#define AB_CHECK_INCAPACITATED (1<<4)
///Action button checks if user is currently in turf contents
#define AB_CHECK_TURF (1<<5)
///Action button checks if it should be given to new mob, after mind transfer
#define AB_TRANSFER_MIND (1<<6)

///Action button triggered with right click
#define TRIGGER_SECONDARY_ACTION (1<<0)
///Action triggered to ignore any availability checks
#define TRIGGER_FORCE_AVAILABLE (1<<1)

//Advanced action types
//Those actions have cooldown, and unavailable until it ends
#define ADV_ACTION_TYPE_RECHARGE "recharge"
//Those actions are toggled on and off
#define ADV_ACTION_TYPE_TOGGLE "toggle"
//Those actions have cooldown, but u can turn the corresponding ability off before it ends,
//or do something else with a smart use of "action_ready" var
#define ADV_ACTION_TYPE_TOGGLE_RECHARGE "toggle_recharge"
//Those actions have charges and are unavailable until you regain at least one charge.
#define ADV_ACTION_TYPE_CHARGES "charges"

// Defines for formatting cooldown actions for the stat panel.
/// The stat panel the action is displayed in.
#define PANEL_DISPLAY_PANEL "panel"
/// The status shown in the stat panel.
/// Can be stuff like "ready", "on cooldown", "active", "charges", "charge cost", etc.
#define PANEL_DISPLAY_STATUS "status"
/// The name shown in the stat panel.
#define PANEL_DISPLAY_NAME "name"


#define ACTION_BUTTON_KEY_BG_ICON "bg_icon"
#define ACTION_BUTTON_KEY_BG_STATE "bg_state"
#define ACTION_BUTTON_KEY_BG_STATE_ACTIVE "bg_state_active"

/// Default action button background
#define ACTION_BUTTON_DEFAULT_BACKGROUND "bg_default"
/// Default active action button background
#define ACTION_BUTTON_DEFAULT_BACKGROUND_ACTIVE "bg_default_on"
/// Default targeting action button overlay
#define ACTION_BUTTON_DEFAULT_TARGETING_OVERLAY "targeting"

// Action button update flags
#define UPDATE_BUTTON_NAME (1<<0)
#define UPDATE_BUTTON_ICON (1<<1)
#define UPDATE_BUTTON_BACKGROUND (1<<2)
#define UPDATE_BUTTON_OVERLAY (1<<3)
#define UPDATE_BUTTON_STATUS (1<<4)
