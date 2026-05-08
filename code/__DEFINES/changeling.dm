/// Cling chemical recharge rate
#define CLING_CHEM_RECHARGE_RATE 3
/// Cling genetic damage reduction
#define CLING_GENETIC_DAMAGE_REDUCTION 2
/// How many stacks cling can get before getting nerfed
#define CLING_STACKS_BEFORE_EXHAUSTION 10
///Speedlegs chemical consumption modifier for exhaustion
#define CLING_EXHAUSTION_MODIFICATOR 0.1
/// Time before changeling can revive himself.
#define CLING_FAKEDEATH_TIME 60 SECONDS
/// The lowest value of genetic_damage [/datum/antagonist/changeling/process()] can take it to while dead.
#define CLING_DEAD_GENETIC_DAMAGE_HEAL_CAP 50
/// The amount of recent spoken lines to gain on absorbing a mob
#define CLING_ABSORB_RECENT_SPEECH 8
/// How long headslug egg will wait until gib body and create monkey with ling
#define CLING_EGG_INCUBATION_DEAD_TIME 60
/// How long headslug egg will living in living body before died
#define CLING_EGG_INCUBATION_LIVING_TIME 200
/// Denotes that this power is free and should be given to all changelings by default.
#define CHANGELING_INNATE_POWER "changeling_innate_power"
/// Denotes that this power can only be obtained by purchasing it.
#define CHANGELING_PURCHASABLE_POWER "changeling_purchasable_power"
/// Denotes that this power can not be obtained normally. Primarily used for base types such as [/datum/action/changeling/weapon].
#define CHANGELING_UNOBTAINABLE_POWER "changeling_unobtainable_power"
