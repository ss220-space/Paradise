/// Speed modifier for gravity area
#define POD_GRAVITY_SPEED_MOD 2 // multiplayer (2x slowler)
/// Slow fly pod speed
#define POD_MOVE_MIN_DELAY (0.1 SECONDS)
#define POD_MOVE_MAX_DELAY (2.5 SECONDS)
/// Speed coefficient for calculate current speed from thrust and mass (lesser - high speed, greater - slow speed)
#define POD_SPEED_COEFF 7

/// Eject occupant from spacepod from outside by grab attack
#define POD_OCCUPANT_EJECT_DURATION (5 SECONDS)
/// Passenger loading from outside by drag and drop
#define POD_OCCUPANT_INSERT_DURATION (5 SECONDS)
/// Passenger or pilot enter into spacepod duration
#define POD_ENTER_DURATION (4 SECONDS)

#define POD_MODULE_FIRE_DAMAGE 5
#define POD_MODULE_HIT_CHANCE_SMALL 5
#define POD_MODULE_HIT_CHANCE_NORMAL 10
#define POD_MODULE_HIT_CHANCE_LARGE 20
#define POD_MODULE_HIT_CHANCE_EXTRA_LARGE 40
#define POD_HULL_HIT_CHANCE 25

/// Armor plate modules by one engine
#define POD_ARMOR_PLATE_BY_ENGINE 3
/// Passenger seats by one engine
#define POD_PASSENGERS_BY_ENGINE 1
/// Max engines for pod
#define POD_MAX_ENGINES 3
/// Max fuel tanks for pod
#define POD_MAX_FUEL_TANKS 4

/// Spacepod frame mass in kg
#define POD_FRAME_MASS 300

/// List of active trackers
GLOBAL_LIST_EMPTY(pod_trackers)
