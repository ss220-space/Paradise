#define TS_DAMAGE_SIMPLE 0
#define TS_DAMAGE_POISON 1
#define TS_DAMAGE_BRUTE 2

//TIER 1
#define TS_DESC_KNIGHT "Рыцарь - ШТУРМ"
#define TS_DESC_LURKER "Наблюдатель - ЗАСАДЫ"
#define TS_DESC_HEALER "Лекарь - ЛЕЧЕНИЕ"
#define TS_DESC_REAPER "Жнец - БОЙ"
#define TS_DESC_BUILDER "Дрон - СТРОИТЕЛЬСТВО"
//TIER 2
#define TS_DESC_WIDOW "Вдова - ОТРАВЛЕНИЕ"
#define TS_DESC_GUARDIAN "Защитник - ОБОРОНА"
#define TS_DESC_DESTROYER "Разрушитель - САБОТАЖ"
//TIER 3
#define TS_DESC_PRINCE "Принц - КРОВАВАЯ БАНЯ"
#define TS_DESC_PRINCESS "Принцесса - РАЗМНОЖЕНИЕ"
#define TS_DESC_MOTHER "Мать - ПОДДЕРЖКА"
#define TS_DESC_DEFILER "Осквернитель - ЗАРАЖЕНИЕ"
//TIER 4
#define TS_DESC_QUEEN "Королева - ЛИДЕР"

#define TS_TIER_1 1
#define TS_TIER_2 2
#define TS_TIER_3 3
#define TS_TIER_4 4
#define TS_TIER_5 5

#define TERROR_QUEEN "Королева Ужаса"
#define TERROR_PRINCE "Принц Ужаса"
#define TERROR_PRINCESS "Принцесса Ужаса"
#define TERROR_DEFILER "Осквернитель Ужаса"
#define TERROR_OTHER "Пауки Ужаса"
#define SPAWN_TERROR_TYPES list(TERROR_QUEEN, TERROR_PRINCE, TERROR_PRINCESS, TERROR_DEFILER)

#define TERROR_STAGE_START 0
#define TERROR_STAGE_PROTECT_EGG 1
#define TERROR_STAGE_STORM 2
#define TERROR_STAGE_END 3
#define TERROR_STAGE_POST_END 4

#define TERROR_VOTE_LEN 30 SECONDS

#define TERROR_VOTE_TICKS 30

#define INFECTIONS_ANNOUNCE_TRIGGER 0.1

#define SPIDERS_ANNOUNCE_TRIGGER 0.1

#define TIME_TO_ANNOUNCE 10 SECONDS

#define EMPRESS_EGG_TARGET_COUNT 2 + num_station_players() / 5
