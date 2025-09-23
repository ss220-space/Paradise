// Defines for SSmapping's multiz_levels
/// TRUE if we're ok with going up
#define Z_LEVEL_UP 1
/// TRUE if we're ok with going down
#define Z_LEVEL_DOWN 2
#define LARGEST_Z_LEVEL_INDEX Z_LEVEL_DOWN

#define SPACE_RUINS_NUMBER rand(CONFIG_GET(number/extra_space_ruin_levels_min), CONFIG_GET(number/extra_space_ruin_levels_max))

GLOBAL_LIST_EMPTY(lazis_primary_turfs)


#define DISABLE_LAVALAND (1<<0)
#define DISABLE_AWAY_MISSIONS (1<<1)
#define DISABLE_SPACE_RUINS (1<<2)
#define DISABLE_TAIPAN (1<<3)

#define DISABLE_ALL ALL
