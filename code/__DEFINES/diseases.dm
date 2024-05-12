//Visibility Flags
#define VISIBLE 0
#define HIDDEN_HUD 1		//hidden from huds & medbots
#define HIDDEN_SCANNER	2	//hidden from health analyzers & stationary body analyzers
#define HIDDEN_PANDEMIC	4	//hidden from pandemic

//Severity Defines
#define NONTHREAT	"No threat"
#define MINOR		"Minor"
#define MEDIUM		"Medium"
#define HARMFUL		"Harmful"
#define DANGEROUS 	"Dangerous!"
#define BIOHAZARD	"BIOHAZARD THREAT!"

//Spread Flags
#define NON_CONTAGIOUS	(1<<0)	//virus can't spread
#define BITES 			(1<<1)	//virus can spread with bites
#define BLOOD 			(1<<2)	//virus can spread with infected blood
#define CONTACT 		(1<<3)	//virus can spread with any touch
#define AIRBORNE 		(1<<4)	//virus spreads through the air
