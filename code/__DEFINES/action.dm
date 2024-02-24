//Action availability flags
#define AB_CHECK_RESTRAINED (1<<0)
#define AB_CHECK_STUNNED (1<<1)
#define AB_CHECK_LYING (1<<2)
#define AB_CHECK_CONSCIOUS (1<<3)
#define AB_TRANSFER_MIND (1<<4)
#define AB_CHECK_TURF (1<<5)

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
