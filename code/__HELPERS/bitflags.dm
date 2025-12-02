/// Check if a bit flag is set in a container
#define HASBIT(CONTAINER, FLAG) ((CONTAINER) & (FLAG))
/// Set a bit flag in a container
#define SETBIT(CONTAINER, FLAG) ((CONTAINER) |= (FLAG))
/// Clear a bit flag from a container
#define CLEARBIT(CONTAINER, FLAG) ((CONTAINER) &= ~(FLAG))
/// Toggle a bit flag in a container
#define TOGGLEBIT(CONTAINER, FLAG) ((CONTAINER) ^= (FLAG))
