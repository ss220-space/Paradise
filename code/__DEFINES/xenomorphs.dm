
/// Cooldown for vector inject larva ablity
#define XENO_VECTOR_INJECT_COOLDOWN 3.5 MINUTES

/// How many players we need for evolve to one praetorian
#define XENO_PLAYERS_FOR_PRAETORIAN 25

/// How many players we need for evolve to empress
#define XENO_PLAYERS_FOR_EMPRESS round(2 + num_station_players() / 6)

#define EVOLVE_ANNOUNCE_TRIGGER 0.1

#define TO_EMPRESS_EVOLVE_TIME 250 SECONDS

#define TO_EMPRESS_EVOLVE_COST 750

#define LARVA_TYPE /mob/living/carbon/alien/larva

#define QUEEN_TYPE /mob/living/carbon/alien/humanoid/queen

#define EMPRESS_TYPE /mob/living/carbon/alien/humanoid/empress

#define XENO_STAGE_START 0
#define XENO_STAGE_PROTECT_COCON 1
#define XENO_STAGE_STORM 2
#define XENO_STAGE_END 3
#define XENO_STAGE_POST_END 4

#define XENO_EMBRYO_TIME pick(15, 30) SECONDS
