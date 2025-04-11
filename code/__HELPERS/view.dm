#define DEFAULT_SIGHT_DISTANCE 7
/// Basic check to see if the src object can see the target object.
#define CAN_I_SEE(target) ((src in viewers(DEFAULT_SIGHT_DISTANCE, target)) || in_range(target, src))

/// Basic check to see if the src object can hear the target object. Uniqueness in calculating with opaque objects.
#define CAN_I_HEAR(target) ((src in hearers(DEFAULT_SIGHT_DISTANCE, target)) || in_range(target, src))
