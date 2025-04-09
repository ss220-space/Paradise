
/// Signal sent when a blackboard key is set to a new value
#define COMSIG_AI_BLACKBOARD_KEY_SET(blackboard_key) "ai_blackboard_key_set_[blackboard_key]"

///Signal sent before a blackboard key is cleared
#define COMSIG_AI_BLACKBOARD_KEY_PRECLEAR(blackboard_key) "ai_blackboard_key_pre_clear_[blackboard_key]"

/// Signal sent when a blackboard key is cleared
#define COMSIG_AI_BLACKBOARD_KEY_CLEARED(blackboard_key) "ai_blackboard_key_clear_[blackboard_key]"

/// From /datum/element/basic_eating/try_eating()
#define COMSIG_MOB_PRE_EAT "mob_pre_eat"
	///cancel eating attempt
	#define COMSIG_MOB_CANCEL_EAT (1<<0)

/// From /datum/element/basic_eating/finish_eating()
#define COMSIG_MOB_ATE "mob_ate"
	///cancel post eating
	#define COMSIG_MOB_TERMINATE_EAT (1<<0)


// simple_animal signals
/// called when a simplemob is given sentience from a sentience potion (target = person who sentienced)
#define COMSIG_SIMPLEMOB_SENTIENCEPOTION "simplemob_sentiencepotion"
/// called when a simplemob is given sentience from a consciousness transference potion (target = person who sentienced)
#define COMSIG_SIMPLEMOB_TRANSFERPOTION "simplemob_transferpotion"

/// From /mob/living/befriend() : (mob/living/new_friend)
#define COMSIG_LIVING_BEFRIENDED "living_befriended"

/// From /mob/living/unfriend() : (mob/living/old_friend)
#define COMSIG_LIVING_UNFRIENDED "living_unfriended"
