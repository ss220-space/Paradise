//Slime evolution threshold. Controls how fast slimes can split/grow
#define SLIME_EVOLUTION_THRESHOLD 10
#define SLIME_EVOLUTION_THRESHOLD_OLD 30
#define SLIME_EVOLUTION_THRESHOLD_EVOLVE 50
#define SLIME_EVOLUTION_THRESHOLD_EVOLVE_SLIMEMAN 100

#define SLIME_BABY 		"baby"
#define SLIME_ADULT 	"adult"
#define SLIME_OLD 		"old"
#define SLIME_ELDER 	"elder"
#define SLIME_SLIMEMAN 	"slimeman"

//Slime commands defines
#define SLIME_COMMAND_GREETING 1
#define SLIME_COMMAND_FOLLOW 2
#define SLIME_COMMAND_STAY 3
#define SLIME_COMMAND_STOP 4
#define SLIME_COMMAND_ATTACK 5
#define SLIME_COMMAND_EAT 6
#define SLIME_COMMAND_DEFEND 7
#define SLIME_COMMAND_REPRODUCE 8
#define SLIME_COMMAND_NOREPRODUCE 9

//Minimum levels of friendship to order some commands
#define SLIME_FRIENDSHIP_FOLLOW 			3 //Min friendship to order it to follow
#define SLIME_FRIENDSHIP_STOPEAT 			5 //Min friendship to order it to stop eating someone
#define SLIME_FRIENDSHIP_STOPEAT_NOANGRY	7 //Min friendship to order it to stop eating someone without it losing friendship
#define SLIME_FRIENDSHIP_STOPCHASE			4 //Min friendship to order it to stop chasing someone (their target)
#define SLIME_FRIENDSHIP_STOPCHASE_NOANGRY	6 //Min friendship to order it to stop chasing someone (their target) without it losing friendship
#define SLIME_FRIENDSHIP_STAY				3 //Min friendship to order it to stay
#define SLIME_FRIENDSHIP_ATTACK				8 //Min friendship to order it to attack
#define SLIME_FRIENDSHIP_DEFEND				10 //Min friendship to order it to defend
#define SLIME_FRIENDSHIP_STOPDEFEND			10 //Min friendship to order it to stop defend
#define SLIME_FRIENDSHIP_REPRODUCE_CONTROL	3 //Min friendship to order it to stop defend

//Mood of the slime. Responsible for the displayed face
#define SLIME_MOOD_ANGRY "angry"
#define SLIME_MOOD_MISCHIEVOUS "mischievous"
#define SLIME_MOOD_SAD "sad"
#define SLIME_MOOD_POUT "pout"
#define SLIME_MOOD_3 ":3"
#define SLIME_MOOD_33 ":33"

//Slime's hunger level
#define SLIME_HUNGER_NOT_HUNGRY 0
#define SLIME_HUNGER_HUNGRY 1
#define SLIME_HUNGER_STARVING 2

//Temperature borders for slimes
#define SLIME_FAST_T (T0C + 100)
#define SLIME_SLOW_T (T0C - 100)
#define SLIME_MAX_SLOW 10
#define SLIME_MIN_SLOW 1
#define SLIME_THAW_T (T0C + 5)				// Slime thaw temperature
#define SLIME_STUN_T (T0C - 40)				// Slime stun temperature
#define SLIME_HURT_T (T0C - 50)				// Slime hurt temperature

#define SLIME_MAX_T_DMG 30		// Damage per tick at 0°K
#define SLIME_MIN_T_DMG 5		// Damage per tick at SLIME_HURT_T°K


#define SLIME_BEHAVIOR_ATTACK 1
#define SLIME_BEHAVIOR_EAT 2

#define SLIME_BEHAVIOR_DEFAULT 0
#define SLIME_BEHAVIOR_REPRODUCE 1
#define SLIME_BEHAVIOR_EVOLVE 2

#define SLIME_ATTACK_COOLDOWN 4.5 SECONDS

#define SLIME_LOOSE_FRIEND_CHANCE 1
