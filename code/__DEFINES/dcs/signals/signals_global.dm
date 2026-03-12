// global signals
// These are signals which can be listened to by any component on any parent
// start global signals with "!", this used to be necessary but now it's just a formatting choice

///from base of datum/controller/subsystem/mapping/proc/add_new_zlevel(): (list/args)
#define COMSIG_GLOB_NEW_Z "!new_z"
/// sent after world.maxx and/or world.maxy are expanded: (has_exapnded_world_maxx, has_expanded_world_maxy)
#define COMSIG_GLOB_EXPANDED_WORLD_BOUNDS "!expanded_world_bounds"
/// called after a successful var edit somewhere in the world: (list/args)
#define COMSIG_GLOB_VAR_EDIT "!var_edit"
/// called after an explosion happened : (epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
#define COMSIG_GLOB_EXPLOSION "!explosion"
/// mob was created somewhere : (mob)
#define COMSIG_GLOB_MOB_CREATED "!mob_created"
/// mob died somewhere : (mob , gibbed)
#define COMSIG_GLOB_MOB_DEATH "!mob_death"
/// global living say plug - use sparingly: (mob/speaker , message)
#define COMSIG_GLOB_LIVING_SAY_SPECIAL "!say_special"
/// a person somewhere has thrown something : (mob/living/carbon/carbon_thrower, target)
#define COMSIG_GLOB_CARBON_THROW_THING "!throw_thing"
/// called by datum/cinematic/play() : (datum/cinematic/new_cinematic)
#define COMSIG_GLOB_PLAY_CINEMATIC "!play_cinematic"
	#define COMPONENT_GLOB_BLOCK_CINEMATIC (1<<0)
/// ingame button pressed (/obj/machinery/button/button)
#define COMSIG_GLOB_BUTTON_PRESSED "!button_pressed"
/// cable was placed or joined somewhere : (turf)
#define COMSIG_GLOB_CABLE_UPDATED "!cable_updated"

#define COMSIG_GLOB_WEB_STORM_ENDED "!web_storm_ended"
#define COMSIG_GLOB_EMPRESS_EGG_DESTROYED "!empress_egg_destroyed"
#define COMSIG_GLOB_EMPRESS_EGG_BURST "!empress_egg_burst"
#define COMSIG_GLOB_IFECTION_CREATED "!infection_created"
#define COMSIG_GLOB_IFECTION_REMOVED "!infection_removed"
#define COMSIG_GLOB_XENO_STORM_ENDED "!xeno_storm_ended"
#define COMSIG_GLOB_SUBSYSTEMS_INIT_ENDED "!subsystems_init_ended"

#define COMSIG_WEATHER_TELEGRAPH(event_type) "!weather_telegraph [event_type]"
#define COMSIG_WEATHER_START(event_type) "!weather_start [event_type]"
#define COMSIG_WEATHER_WINDDOWN(event_type) "!weather_winddown [event_type]"
#define COMSIG_WEATHER_END(event_type) "!weather_end [event_type]"

/// Global signal called after the station changes its name.
/// (new_name, old_name)
#define COMSIG_GLOB_STATION_NAME_CHANGED "!station_name_changed"
