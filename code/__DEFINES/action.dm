//Action availability flags
///Action button checks if hands are unusable
#define AB_CHECK_HANDS_BLOCKED (1<<0)
///Action button checks if user is immobile
#define AB_CHECK_IMMOBILE (1<<1)
///Action button checks if user is resting
#define AB_CHECK_LYING (1<<2)
///Action button checks if user is conscious
#define AB_CHECK_CONSCIOUS (1<<3)
///Action button checks if user is incapacitated
#define AB_CHECK_INCAPACITATED (1<<4)
///Action button checks if user is currently in turf contents
#define AB_CHECK_TURF (1<<5)
///Action button checks if it should be given to new mob, after mind transfer
#define AB_TRANSFER_MIND (1<<6)


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
