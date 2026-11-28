#define COMSIG_OVERMAP_MOVED "overmap_moved"

#define COMSIG_OVERMAP_DISPLAY_CHANGED "overmap_display_changed"

#define COMSIG_OVERMAP_NOTICE "overmap_notice"

#define COMSIG_OVERMAP_RELAY_TRANSIT "overmap_relay_transit"

#define COMSIG_OVERMAP_MANUAL_CONTROL "overmap_manual_control"

#define COMSIG_OVERMAP_NAVIGATION_ARRIVED "overmap_navigation_arrived"

#define COMSIG_OVERMAP_DOCK_MATCH_PAD "overmap_dock_match_pad"
	#define COMPONENT_OVERMAP_PAD_MATCH (1<<0)

#define COMSIG_GLOB_OVERMAP_VESSEL_REGISTERED "overmap_vessel_registered"

#define COMSIG_GLOB_OVERMAP_NINJA_CONSOLE "overmap_ninja_console"

#define COMSIG_OVERMAP_WEAPON_QUERY "overmap_weapon_query"

#define COMSIG_OVERMAP_WEAPON_FIRE "overmap_weapon_fire"

#define COMSIG_OVERMAP_WEAPON_CAN_AIM "overmap_weapon_can_aim"

#define COMSIG_OVERMAP_WEAPON_ROTATED "overmap_weapon_rotated"

#define COMSIG_OVERMAP_WEAPON_AUTOMATIC "overmap_weapon_automatic"

#define COMSIG_OVERMAP_WEAPON_PROCESS "overmap_weapon_process"

#define COMSIG_OVERMAP_WEAPON_CONFIGURE "overmap_weapon_configure"

#define COMSIG_OVERMAP_WEAPON_HOST "overmap_weapon_host"

#define COMSIG_OVERMAP_SENSOR_JOURNAL "overmap_sensor_journal"

#define COMSIG_OVERMAP_SENSOR_STATUS "overmap_sensor_status"
	#define COMPONENT_OVERMAP_HAS_SENSORS (1<<0)

#define COMSIG_OVERMAP_SENSOR_SET_ENABLED "overmap_sensor_set_enabled"
	#define COMPONENT_OVERMAP_SENSOR_APPLIED (1<<0)

#define COMSIG_OVERMAP_SENSOR_IDENTIFY_CONTACTS "overmap_sensor_identify_contacts"

#define COMSIG_OVERMAP_POD_STATE "overmap_pod_state"
	#define COMPONENT_OVERMAP_POD_LINKED (1<<0)
	#define COMPONENT_OVERMAP_POD_IN_POCKET (1<<1)
	#define COMPONENT_OVERMAP_POD_UNDOCKING (1<<2)

#define COMSIG_OVERMAP_POD_RESCUE "overmap_pod_rescue"
	#define COMPONENT_OVERMAP_POD_RESCUING (1<<0)

#define COMSIG_OVERMAP_POD_LAND "overmap_pod_land"
	#define COMPONENT_OVERMAP_POD_LANDED (1<<0)
