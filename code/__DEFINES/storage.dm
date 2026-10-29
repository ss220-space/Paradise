// Storage component defines

// Storage collection defines
#define COLLECT_ONE 0
#define COLLECT_EVERYTHING 1
#define COLLECT_SAME 2

// Drop style defines
#define DROP_NOTHING 0
#define DROP_AT_PARENT 1
#define DROP_AT_LOCATION 2

// Defines for fancy boxes (ie. boxes that display how many items there are
// inside of them)
#define FANCY_CONTAINER_CLOSED 0
#define FANCY_CONTAINER_OPEN 1
#define FANCY_CONTAINER_ALWAYS_OPEN 2

// Defines for levels of storage locking
// Also used fort the force param of can_insert
// Higher values are "more" locked then lower ones
#define STORAGE_NOT_LOCKED 0
#define STORAGE_SOFT_LOCKED 1
#define STORAGE_FULLY_LOCKED 2

///the area channel of the important_recursive_contents list, everything in here will be sent a signal when their last holding object changes areas
#define RECURSIVE_CONTENTS_AREA_SENSITIVE "recursive_contents_area_sensitive"
///the hearing channel of the important_recursive_contents list, everything in here will count as a hearing atom
#define RECURSIVE_CONTENTS_HEARING_SENSITIVE "recursive_contents_hearing_sensitive"
///the client mobs channel of the important_recursive_contents list, everything in here will be a mob with an attached client
///this is given to both a clients mob, and a clients eye, both point to the clients mob
#define RECURSIVE_CONTENTS_CLIENT_MOBS "recursive_contents_client_mobs"
///the parent of storage components currently shown to some client mob get this. gets removed when nothing is viewing the parent
#define RECURSIVE_CONTENTS_ACTIVE_STORAGE "recursive_contents_active_storage"
