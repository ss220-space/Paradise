#define MIN_SUPPLIED_LAW_NUMBER 15
#define MAX_SUPPLIED_LAW_NUMBER 50

// Transfer_ai() defines. Main proc in ai_core.dm

/// Downloading AI to InteliCard
#define AI_TRANS_TO_CARD 1
/// Uploading AI from InteliCard
#define AI_TRANS_FROM_CARD 2
/// Malfunctioning AI hijacking mecha
#define AI_MECH_HACK 3


// Since each cyborgs skin have different height and width, they need unusual riding offsets

#define CYBORG_RIDING_OFFSET_DRAKE list(TEXT_NORTH = list(0, 10), TEXT_SOUTH = list(0, 10), TEXT_EAST = list(0, 10), TEXT_WEST = list(0, 10))

#define CYBORG_RIDING_OFFSET_RAPTOR list(TEXT_NORTH = list(0, 5), TEXT_SOUTH = list(0, 5), TEXT_EAST = list(5, 5), TEXT_WEST = list(-5, 5))

#define CYBORG_RIDING_OFFSET_STANDART list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(-4, 4), TEXT_WEST = list(4, 4))

#define CYBORG_RIDING_OFFSET_TALL list(TEXT_NORTH = list(0, 11), TEXT_SOUTH = list(0, 11), TEXT_EAST = list(-4, 11), TEXT_WEST = list(4, 11))

#define CYBORG_RIDING_OFFSET_TALL_AND_WIDE list(TEXT_NORTH = list(0, 11), TEXT_SOUTH = list(0, 11), TEXT_EAST = list(-8, 11), TEXT_WEST = list(8, 11))

#define CYBORG_RIDING_OFFSET_MEKA list(TEXT_NORTH = list(0, 20), TEXT_SOUTH = list(0, 20), TEXT_EAST = list(-4, 20), TEXT_WEST = list(4, 20))

#define CYBORG_RIDING_OFFSET_FLYING list(TEXT_NORTH = list(0, 12), TEXT_SOUTH = list(0, 12), TEXT_EAST = list(-4, 12), TEXT_WEST = list(4, 12))

#define CYBORG_RIDING_OFFSET_LANDMINE list(TEXT_NORTH = list(0, 15), TEXT_SOUTH = list(0, 15), TEXT_EAST = list(0, 15), TEXT_WEST = list(0, 15))

#define CYBORG_RIDING_OFFSET_WALLE list(TEXT_NORTH = list(0, 9), TEXT_SOUTH = list(0, 9), TEXT_EAST = list(-13, 9), TEXT_WEST = list(12, 9))

#define CYBORG_RIDING_OFFSET_DESTROYER list(TEXT_NORTH = list(0, 11), TEXT_SOUTH = list(0, 11), TEXT_EAST = list(-23, 11), TEXT_WEST = list(23, 11))

/// Names for cyborg modueles. Currently used only in UI

#define CYBORG_MODULE_NAME_GENERALIST "Генералист"

#define CYBORG_MODULE_NAME_MEDIC "Медик"
#define CYBORG_MODULE_NAME_MEDIC_ERT "Тактический медик"
#define CYBORG_MODULE_NAME_MEDIC_ERT_SPECIAL "Боевой медик"

#define CYBORG_MODULE_NAME_ENGINEER "Инженер"
#define CYBORG_MODULE_NAME_ENGINEER_ERT "Боевой инженер"
#define CYBORG_MODULE_NAME_SABOTEUR "Саботёр"

#define CYBORG_MODULE_NAME_JANITOR "Уборщик"
#define CYBORG_MODULE_NAME_JANITOR_ERT "Тактический уборщик"

#define CYBORG_MODULE_NAME_MINER "Шахтёр"

#define CYBORG_MODULE_NAME_SERVICE "Сервисный работник"

#define CYBORG_MODULE_NAME_SECURITY "Охранник"
#define CYBORG_MODULE_NAME_SOLIDER "Боец"
#define CYBORG_MODULE_NAME_BATTLEDROID "Штурмовик"
