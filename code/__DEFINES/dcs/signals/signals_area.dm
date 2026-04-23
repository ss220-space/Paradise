// Area signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of area/proc/power_change(): ()
#define COMSIG_AREA_POWER_CHANGE "area_power_change"
///from base of area/Entered(): (atom/movable/arrived, area/old_area)
#define COMSIG_AREA_ENTERED "area_entered"
///from base of area/Exited(): (atom/movable/departed, area/new_area)
#define COMSIG_AREA_EXITED "area_exited"
///from base of area/Entered(): (area/current_area, area/old_area)
#define COMSIG_ATOM_ENTERED_AREA "atom_entered_area"
///from base of area/Exited(): (area/current_area, area/new_area)
#define COMSIG_ATOM_EXITED_AREA "atom_exited_area"
///from base of area/Entered(): (area/new_area). Sent to "area-sensitive" movables, see __DEFINES/traits.dm for info.
#define COMSIG_ENTER_AREA "enter_area"
///from base of area/Exited(): (area). Sent to "area-sensitive" movables, see __DEFINES/traits.dm for info.
#define COMSIG_EXIT_AREA "exit_area"
/// Called when some weather starts in this area
#define COMSIG_WEATHER_BEGAN_IN_AREA(event_type) "weather_began_in_area_[event_type]"
/// Called when some weather ends in this area
#define COMSIG_WEATHER_ENDED_IN_AREA(event_type) "weather_ended_in_area_[event_type]"

// /datum/alarm_manager
#define COMSIG_TRIGGERED_ALARM "alarmmanager_triggered"
#define COMSIG_CANCELLED_ALARM "alarmmanager_cancelled"
