// Defines for SSmapping's multiz_levels
/// TRUE if we're ok with going up
#define Z_LEVEL_UP 1
/// TRUE if we're ok with going down
#define Z_LEVEL_DOWN 2
#define LARGEST_Z_LEVEL_INDEX Z_LEVEL_DOWN

#define SPACE_RUINS_NUMBER rand(CONFIG_GET(number/extra_space_ruin_levels_min), CONFIG_GET(number/extra_space_ruin_levels_max))
