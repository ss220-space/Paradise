#define REACTOR_INACTIVE 0		// Reactor is not operational
#define REACTOR_NORMAL 1		// Normal operation
#define REACTOR_NOTIFY 2		// Above 90% of heat_damage_threshold
#define REACTOR_WARNING 3		// Integrity < 99%
#define REACTOR_DANGER 4		// Integrity < 50%
#define REACTOR_EMERGENCY 5		// Integrity < 25%
#define REACTOR_MELTDOWN 6		// Integrity < 5%

// The states of nuclear reactor chambers.
#define CHAMBER_DOWN 1
#define CHAMBER_UP 2
#define CHAMBER_OPEN 3
#define CHAMBER_OVERLOAD_IDLE 4
#define CHAMBER_OVERLOAD_ACTIVE 5

#define HEAT_MODIFIER 450 //! A flat multiplier for all reactor heat. Higher = more heat production.
