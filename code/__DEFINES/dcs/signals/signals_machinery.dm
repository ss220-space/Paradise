// /obj/machinery signals

///from /obj/machinery/obj_break(damage_flag): (damage_flag)
#define COMSIG_MACHINERY_BROKEN "machinery_broken"
///from base power_change() when power is lost
#define COMSIG_MACHINERY_POWER_LOST "machinery_power_lost"
///from base power_change() when power is restored
#define COMSIG_MACHINERY_POWER_RESTORED "machinery_power_restored"

// obj/machinery/door_timer signals
///from obj/machinery/door_timer/timer_start(): (/mob/living/target, crimes, duration_min)
#define COMSIG_DOOR_TIMER_START "door_timer_start"
///from obj/machinery/door_timer/timer_end(): (/mob/living/target, crimes, duration_min)
#define COMSIG_DOOR_TIMER_FINISH "door_timer_finish"

// obj/machinery/crematorium
///from obj/machinery/crematorium/cremate(): (/mob/living/target)
#define COMSIG_LIVING_CREMATED "crematorium_cremated_living"

#define COMSIG_CRYOPOD_DESPAWN "cryopod_despawn"

#define COMSIG_REQUEST_CONSOLE_MESSAGE "request_console_message"
