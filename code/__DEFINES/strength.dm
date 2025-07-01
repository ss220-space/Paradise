#define STRENGTH_LEVEL_WEAK			1
#define STRENGTH_LEVEL_NORMAL		2
#define STRENGTH_LEVEL_STRONG		3
#define STRENGTH_LEVEL_IDEAL		4
#define STRENGTH_LEVEL_SUPERHUMAN	5


GLOBAL_LIST_INIT(strength_grab_speed_modifiers, list(0.8, 1, 1.15, 1.3, 1.5))

GLOBAL_LIST_INIT(strength_pull_slowdown_modifiers, list(1.2, 1, 0.75, 0.5, 0))

GLOBAL_LIST_INIT(strength_melee_damage_deltas, list(-2, 0, 2, 4, 6))

GLOBAL_LIST_INIT(strength_req_to_upgrade, list(10, 20, 30, 35))

GLOBAL_LIST_INIT(strength_examines, list("слаб", "нормальн", "сильн", "очень сильн", "необыкновенно сильн"))


#define STRENGTH_LEVEL_MAXDEFAULT	4
#define STRENGTH_LEVEL_DEFAULT		2
