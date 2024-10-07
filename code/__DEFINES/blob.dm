#define BLOB_RESTRICTED_JOBS list(JOB_TITLE_CYBORG, JOB_TITLE_AI)
#define BLOB_RESTRICTED_SPECIES list(SPECIES_MACNINEPERSON, SPECIES_SKELETON)
#define TIME_TO_BURST_HIGHT 25 MINUTES
#define TIME_TO_BURST_LOW 23 MINUTES
#define TIME_TO_BURST_ADDED_HIGHT 7 MINUTES
#define TIME_TO_BURST_ADDED_LOW 5 MINUTES
#define TIME_TO_BURST_MOUSE_HIGHT 3 MINUTES
#define TIME_TO_BURST_MOUSE_LOW 1 MINUTES
#define BURST_FIRST_STAGE_COEF 0.5
#define BURST_SECOND_STAGE_COEF 0.85
#define FIRST_STAGE_COEF 0.2
#define SECOND_STAGE_COEF 0.3
#define THIRD_STAGE_COEF 0.75
#define FIRST_STAGE_THRESHOLD 300
#define SECOND_STAGE_THRESHOLD 400
#define BLOB_STAGE_NONE -1
#define BLOB_STAGE_ZERO 0
#define BLOB_STAGE_FIRST 1
#define BLOB_STAGE_SECOND 2
#define BLOB_STAGE_THIRD 3
#define BLOB_STAGE_STORM 4
#define BLOB_STAGE_END 5
#define BLOB_STAGE_POST_END 6
#define BLOB_NONE_REPORT 0
#define BLOB_FIRST_REPORT 1
#define BLOB_SECOND_REPORT 2
#define BLOB_THIRD_REPORT 3
#define BLOB_AHUD_NAME "hudblob"
#define STAGES_CALLBACK_TIME 1 SECONDS
#define AWAY_AFTER_WARN_TIME 1 MINUTES
#define MOUSE_REVOTE_TIME 5 SECONDS
#define TIME_TO_ANNOUNCE_BLOBS_DIE 10 SECONDS
#define TIME_TO_SWITCH_CODE 10 SECONDS
#define BURST_BLOB_TICK 1 SECONDS
#define BURST_MESSAGE_TICK 10 SECONDS
#define TIME_TO_ADD_OM_DATUM 1 SECONDS
#define BLOB_BASE_TARGET_POINT 350
#define BLOB_TARGET_POINT_PER_CORE 350
#define BLOB_PLAYERS_PER_CORE 30
#define BLOB_DEATH_REPORT_FIRST 0
#define BLOB_DEATH_REPORT_SECOND 1
#define BLOB_DEATH_REPORT_THIRD 2
#define BLOB_DEATH_REPORT_FOURTH 3
#define BLOB_INFECTED_ATMOS_REC list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
#define BLOB_INFECTED_MIN_BODY_TEMP -INFINITY
#define BLOB_INFECTED_MIN_PRESSURE -INFINITY
#define AWAY_STATION_WARN span_userdanger("Вы готовы лопнуть, но это не подходящее место! Вы должны вернуться на станцию!")
#define FIRST_STAGE_WARN span_userdanger("Вы чувствуете усталость и раздутость.")
#define SECOND_STAGE_WARN span_userdanger("Вы чувствуете, что вот-вот лопнете.")

#define isblobbernaut(M) istype((M), /mob/living/simple_animal/hostile/blob/blobbernaut)

//Few global vars to track the blob
GLOBAL_LIST_EMPTY(blobs)
GLOBAL_LIST_EMPTY(blob_cores)
GLOBAL_LIST_EMPTY(blob_nodes)
