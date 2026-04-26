// /mob/living/simple_animal signals
///from /mob/living/attack_animal():	(mob/living/simple_animal/M)
#define COMSIG_SIMPLE_ANIMAL_ATTACKEDBY "simple_animal_attackedby"
	#define COMPONENT_SIMPLE_ANIMAL_NO_ATTACK (1<<0)

// /mob/living/simple_animal/hostile signals
///before attackingtarget has happened, source is the attacker and target is the attacked
#define COMSIG_HOSTILE_PRE_ATTACKINGTARGET "hostile_pre_attackingtarget"
	#define COMPONENT_HOSTILE_NO_ATTACK COMPONENT_CANCEL_ATTACK_CHAIN //cancel the attack, only works before attack happens
///after attackingtarget has happened, source is the attacker and target is the attacked, extra argument for if the attackingtarget was successful
#define COMSIG_HOSTILE_POST_ATTACKINGTARGET "hostile_post_attackingtarget"

/// Called when a /mob/living/simple_animal/hostile fines a new target: (atom/source, give_target)
#define COMSIG_HOSTILE_FOUND_TARGET "comsig_hostile_found_target"

/// Source: /mob/living/simple_animal/borer, listening in datum/antagonist/borer
#define	COMSIG_BORER_ENTERED_HOST "borer_on_enter" // when borer entered host
#define COMSIG_BORER_EARLY_LEFT_HOST "borer_early_leave"

/// from start of /mob/living/simple_animal/soulscythe/Life(): (amount)
#define COMSIG_BLOOD_LEVEL_TICK "blood_level_tick"

