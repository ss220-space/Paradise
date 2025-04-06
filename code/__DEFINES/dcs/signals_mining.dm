/// Fired by a mob which has been grabbed by a goliath
#define COMSIG_GOLIATH_TENTACLED_GRABBED "comsig_goliath_tentacle_grabbed"
/// Fired by a goliath tentacle which is returning to the earth
#define COMSIG_GOLIATH_TENTACLE_RETRACTING 	"comsig_goliath_tentacle_retracting"
/// Fired by a mob which has triggered a brimdust explosion from itself (not the mobs that get hit)
#define COMSIG_BRIMDUST_EXPLOSION "comsig_brimdust_explosion"

///before attackingtarget has happened, source is the attacker and target is the attacked
#define COMSIG_HOSTILE_PRE_ATTACKINGTARGET "hostile_pre_attackingtarget"
	#define COMPONENT_HOSTILE_NO_ATTACK COMPONENT_CANCEL_ATTACK_CHAIN //cancel the attack, only works before attack happens

