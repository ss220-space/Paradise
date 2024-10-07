// String identifiers for associative list lookup


#define CHECK_DNA_AND_SPECIES(C) if((!(C.dna)) || (!(C.dna.species))) return

/// Ignores any restrictions (except flag MUTCHK_IGNORE_DEFAULT) while we are making gene checks
#define MUTCHK_FORCED (1<<0)
/// Allows to modify species default genes
#define MUTCHK_IGNORE_DEFAULT (1<<1)

// Used in preferences.
#define DISABILITY_FLAG_NEARSIGHTED (1<<0)
#define DISABILITY_FLAG_OBESITY (1<<1)
#define DISABILITY_FLAG_BLIND (1<<2)
#define DISABILITY_FLAG_MUTE (1<<3)
#define DISABILITY_FLAG_COLOURBLIND (1<<4)
#define DISABILITY_FLAG_WINGDINGS (1<<5)
#define DISABILITY_FLAG_NERVOUS (1<<6)
#define DISABILITY_FLAG_SWEDISH (1<<7)
#define DISABILITY_FLAG_LISP (1<<8)
#define DISABILITY_FLAG_DIZZY (1<<9)
#define DISABILITY_FLAG_AULD_IMPERIAL (1<<10)
#define DISABILITY_FLAG_DEAF (1<<11)
#define DISABILITY_FLAG_COFFEE_ADDICT (1<<12)
#define DISABILITY_FLAG_TEA_ADDICT (1<<13)
#define DISABILITY_FLAG_ALCOHOLE_ADDICT (1<<14)
#define DISABILITY_FLAG_NICOTINE_ADDICT (1<<15)
#define DISABILITY_FLAG_PARAPLEGIA 		  (1<<16)


//Nutrition levels for humans. No idea where else to put it
#define NUTRITION_LEVEL_FAT 600
#define NUTRITION_LEVEL_FULL 550
#define NUTRITION_LEVEL_WELL_FED 450
#define NUTRITION_LEVEL_FED 350
#define NUTRITION_LEVEL_HUNGRY 250
#define NUTRITION_LEVEL_STARVING 150
#define NUTRITION_LEVEL_HYPOGLYCEMIA 100
#define NUTRITION_LEVEL_CURSED 0

//Used as an upper limit for species that continuously gain nutriment
#define NUTRITION_LEVEL_ALMOST_FULL 535

//Blood levels
#define BLOOD_VOLUME_MAXIMUM		2000
#define BLOOD_VOLUME_NORMAL			560 // 100%
#define BLOOD_VOLUME_SAFE			501	// 89.5%
#define BLOOD_VOLUME_PALE			448 // 80%
#define BLOOD_VOLUME_REGENERATION	392 // 70%
#define BLOOD_VOLUME_OKAY			346 // 61.8%
#define BLOOD_VOLUME_BAD			234 // 41.8%
#define BLOOD_VOLUME_SURVIVE		168 // 30%

//Sizes of mobs, used by mob/living/var/mob_size
#define MOB_SIZE_TINY 0
#define MOB_SIZE_SMALL 1
#define MOB_SIZE_HUMAN 2
#define MOB_SIZE_LARGE 3

//Used for calculations for negative effects of having genetics powers
#define DEFAULT_GENE_STABILITY 100
#define GENE_INSTABILITY_MINOR 5
#define GENE_INSTABILITY_MODERATE 10
#define GENE_INSTABILITY_MAJOR 15

#define GENETIC_DAMAGE_STAGE_1 80
#define GENETIC_DAMAGE_STAGE_2 65
#define GENETIC_DAMAGE_STAGE_3 35

#define CLONER_FRESH_CLONE "fresh"
#define CLONER_MATURE_CLONE "mature"

