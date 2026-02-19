//Visibility Flags
#define VISIBLE 0
#define HIDDEN_HUD 1 //hidden from huds & medbots
#define HIDDEN_SCANNER 2 //hidden from health analyzers & stationary body analyzers
#define HIDDEN_PANDEMIC 4 //hidden from pandemic

//Severity Defines
/// Diseases that buff, heal, or at least do nothing at all
#define DISEASE_SEVERITY_POSITIVE "Положительная"
/// Diseases that may have annoying effects, but nothing disruptive (sneezing)
#define DISEASE_SEVERITY_NONTHREAT "Угрозы нет"
/// Diseases that can annoy in concrete ways (dizziness)
#define DISEASE_SEVERITY_MINOR "Незначительная"
/// Diseases that can do minor harm, or severe annoyance (vomit)
#define DISEASE_SEVERITY_MEDIUM "Средняя"
/// Diseases that can do significant harm, or severe disruption (brainrot)
#define DISEASE_SEVERITY_HARMFUL "Опасная"
/// Diseases that can kill or maim if left untreated (flesh eating, blindness)
#define DISEASE_SEVERITY_DANGEROUS "Очень опасная!"
/// Diseases that can quickly kill an unprepared victim (fungal tb, gbs)
#define DISEASE_SEVERITY_BIOHAZARD "БИОЛОГИЧЕСКАЯ УГРОЗА!"
/// Diseases that are uncurable (kuru)
#define DISEASE_SEVERITY_UNCURABLE "Неизлечимая!"

//Spread Flags
#define NON_CONTAGIOUS (1<<0) //virus can't spread
#define BITES (1<<1) //virus can spread with bites
#define BLOOD (1<<2) //virus can spread with infected blood
#define CONTACT (1<<3) //virus can spread with any touch
#define AIRBORNE (1<<4) //virus spreads through the air

// infection
#define INFECTION_LEVEL_ONE 100
#define INFECTION_LEVEL_TWO 500
#define INFECTION_LEVEL_THREE 1000

// Medical stuff
#define SYMPTOM_ACTIVATION_PROB 3
