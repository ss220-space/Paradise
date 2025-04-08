
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
