// Defines for SSmapping's multiz_levels
/// TRUE if we're ok with going up
#define Z_LEVEL_UP 1
/// TRUE if we're ok with going down
#define Z_LEVEL_DOWN 2
#define LARGEST_Z_LEVEL_INDEX Z_LEVEL_DOWN

#define SPACE_RUINS_NUMBER rand(CONFIG_GET(number/extra_space_ruin_levels_min), CONFIG_GET(number/extra_space_ruin_levels_max))

GLOBAL_LIST_EMPTY(lazis_primary_turfs)

GLOBAL_LIST_INIT(multiz_protected_areas, list(
	/area/derelict/bridge,
	/area/crew_quarters,
	/area/comms,
	/area/server,
	/area/ntrep,
	/area/crew_quarters/captain,
	/area/crew_quarters/captain/bedroom,
	/area/crew_quarters/recruit,
	/area/crew_quarters/heads/hop,
	/area/crew_quarters/heads/hor,
	/area/crew_quarters/heads/chief,
	/area/crew_quarters/heads/hos,
	/area/crew_quarters/heads/cmo,
	/area/crew_quarters/courtroom,
	/area/crew_quarters/heads,
	/area/crew_quarters/hor,
	/area/crew_quarters/hos,
	/area/crew_quarters/chief,
	/area/derelict/bridge/ai_upload,
	/area/maintenance/ai,
	/area/turret_protected,
	/area/security,
))
