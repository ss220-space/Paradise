/// from /obj/docking_port/mobile/proc/canMove()
#define COMSIG_SHUTTLE_SHOULD_MOVE "shuttle_should_move"
#define BLOCK_SHUTTLE_MOVE (1<<0)

/// from /obj/docking_port/mobile/proc/request() when ignition starts
#define COMSIG_SHUTTLE_IGNITION "shuttle_ignition"

/// from /obj/docking_port/mobile/proc/enterTransit() after a successful transit dock
#define COMSIG_SHUTTLE_TRANSIT "shuttle_transit"

/// from /obj/docking_port/mobile/proc/dock() before turf transfer
#define COMSIG_SHUTTLE_PRE_DOCK "shuttle_pre_dock"

/// from /obj/docking_port/mobile/proc/dock()
#define COMSIG_SHUTTLE_DOCK "shuttle_dock"

/// after leaving an old dock
#define COMSIG_SHUTTLE_UNDOCK "shuttle_undock"
