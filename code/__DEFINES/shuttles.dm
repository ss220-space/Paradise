// these define the time taken for the shuttle to get to SS13
// and the time before it leaves again
#define SHUTTLE_CALLTIME 	6000	//10 minutes = 6000 deciseconds - time taken for emergency shuttle to reach the station when called (in deciseconds)
#define SHUTTLE_DOCKTIME 	1800	//3 minutes = 1800 deciseconds - time taken for emergency shuttle to leave again once it has docked (in deciseconds)
#define SHUTTLE_ESCAPETIME	1200	//2 minutes = 1200 deciseconds - time taken for emergency shuttle to reach a safe distance after leaving station (in deciseconds)

//shuttle mode defines
/// Shuttles "ingites" checking for transit zone
#define SHUTTLE_IGNITING "igniting"
/// Idle status
#define SHUTTLE_IDLE "idle"
/// Shuttle in "recall" state.
#define SHUTTLE_RECALL "recall"
/// Shuttle called and is flying to station
#define SHUTTLE_CALL "call"
/// Shuttle docked
#define SHUTTLE_DOCKED "docked"
/// Special state caused by external forces (doomsday device example)
#define SHUTTLE_STRANDED "stranded"
/// Escaped and is returning to CentCom
#define SHUTTLE_ESCAPE "escape"
/// Docked back to CentCom
#define SHUTTLE_ENDGAME "endgame: game over"
/// Shuttle is recharging
#define SHUTTLE_RECHARGING "recharging"

#define EMERGENCY_IDLE_OR_RECALLED (SSshuttle.emergency && ((SSshuttle.emergency.mode == SHUTTLE_IDLE) || (SSshuttle.emergency.mode == SHUTTLE_RECALL)))
#define EMERGENCY_ESCAPED_OR_ENDGAMED (SSshuttle.emergency && ((SSshuttle.emergency.mode == SHUTTLE_ESCAPE) || (SSshuttle.emergency.mode == SHUTTLE_ENDGAME)))
#define EMERGENCY_AT_LEAST_DOCKED (SSshuttle.emergency && SSshuttle.emergency.mode != SHUTTLE_IDLE && SSshuttle.emergency.mode != SHUTTLE_RECALL && SSshuttle.emergency.mode != SHUTTLE_CALL)
#define EMERGENCY_PAST_POINT_OF_NO_RETURN ((SSshuttle.emergency && SSshuttle.emergency.mode == SHUTTLE_CALL && !SSshuttle.canRecall()) || EMERGENCY_AT_LEAST_DOCKED)

#define SHUTTLE_CONSOLE_RECHARGING "recharging"

// Shuttle return values
#define SHUTTLE_CAN_DOCK "can_dock"
#define SHUTTLE_NOT_A_DOCKING_PORT "not_a_docking_port"
#define SHUTTLE_DWIDTH_TOO_LARGE "docking_width_too_large"
#define SHUTTLE_WIDTH_TOO_LARGE "width_too_large"
#define SHUTTLE_DHEIGHT_TOO_LARGE "docking_height_too_large"
#define SHUTTLE_HEIGHT_TOO_LARGE "height_too_large"
#define SHUTTLE_ALREADY_DOCKED "we_are_already_docked"
#define SHUTTLE_SOMEONE_ELSE_DOCKED "someone_else_docked"

// Ripples, effects that signal a shuttle's arrival
#define SHUTTLE_RIPPLE_TIME 100
#define SHUTTLE_RIPPLE_FADEIN 50

#define TRANSIT_REQUEST 1
#define TRANSIT_READY 2

#define SHUTTLE_TRANSIT_BORDER 16
