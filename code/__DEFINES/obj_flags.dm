// Flags for the obj_flags var on /obj

/// Does this object prevent same-direction things from being built on it?
#define BLOCKS_CONSTRUCTION_DIR (1<<0)

// Object flags FOR OBJECT. If you want some flags for object USE THIS INSTEAD OF FLAGS_2
#define BLOCK_Z_OUT_DOWN		(1<<1)  // Should this object block z falling from loc?
#define BLOCK_Z_OUT_UP			(1<<2) // Should this object block z uprise from loc?
#define BLOCK_Z_IN_DOWN			(1<<3) // Should this object block z falling from above?
#define BLOCK_Z_IN_UP			(1<<4) // Should this object block z uprise from below?
