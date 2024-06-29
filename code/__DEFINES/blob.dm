#define BLOB_RESTRICTED_JOBS list(JOB_TITLE_CYBORG, JOB_TITLE_AI)
#define BLOB_RESTRICTED_SPECIES list(SPECIES_MACNINEPERSON)
#define TIME_TO_BURST_H 15 MINUTES
#define TIME_TO_BURST_L 10 MINUTES
#define TIME_TO_BURST_ADDED_H 7 MINUTES
#define TIME_TO_BURST_ADDED_L 5 MINUTES
#define TIME_TO_BURST_MOUSE_H 3 MINUTES
#define TIME_TO_BURST_MOUSE_L 1 MINUTES
#define BURST_FIRST_STAGE_COEF 0.5
#define BURST_SECOND_STAGE_COEF 0.85
#define FIRST_STAGE_COEF 0.2
#define SECOND_STAGE_COEF 0.3
#define THIRD_STAGE_COEF 0.8
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
#define TIME_TO_ADD_OM_DATUM 3 SECONDS
#define BLOB_BASE_TARGET_POINT 350
#define BLOB_TARGET_POINT_PER_CORE 350
#define BLOB_PLAYERS_PER_CORE 30
#define AWAY_STATION_WARN "<span class='userdanger'>Вы готовы лопнуть, но это не подходящее место!  Вы должны вернуться на станцию!</span>"
#define FIRST_STAGE_WARN "<span class='userdanger'>Вы чувствуете усталость и раздутость</span>"
#define SECOND_STAGE_WARN "<span class='userdanger'>Вы чувствуете, что вот-вот лопнете</span>"

#define isblobbernaut(M) istype((M), /mob/living/simple_animal/hostile/blob/blobbernaut)

//Few global vars to track the blob
GLOBAL_LIST_EMPTY(blobs)
GLOBAL_LIST_EMPTY(blob_cores)
GLOBAL_LIST_EMPTY(blob_nodes)
