/mob/living/carbon/human/lesser
	icon = 'icons/mob/monkey.dmi'	// for mappers
	var/master_commander = null
	var/sentience_type = SENTIENCE_ORGANIC

/mob/living/carbon/human/lesser/setup_dna(datum/species/new_species, monkeybasic = TRUE)
	. = ..()
	// since we are created as monkas we need to manually set our GLOB.monkeyblock as activated
	LAZYOR(active_genes, /datum/dna/gene/monkey)

/mob/living/carbon/human/lesser/monkey
	icon_state = "monkey1"

/mob/living/carbon/human/lesser/monkey/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey)
	tts_seed = "Sniper"

/mob/living/carbon/human/lesser/farwa
	icon_state = "tajkey1"

/mob/living/carbon/human/lesser/farwa/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/tajaran)
	tts_seed = "Gyro"

/mob/living/carbon/human/lesser/wolpin
	icon_state = "wolfling"

/mob/living/carbon/human/lesser/wolpin/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/vulpkanin)
	tts_seed = "Bloodseeker"

/mob/living/carbon/human/lesser/neara
	icon_state = "skrellkey1"

/mob/living/carbon/human/lesser/neara/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/skrell)
	tts_seed = "Bounty"

/mob/living/carbon/human/lesser/stok
	icon_state = "stokkey1"

/mob/living/carbon/human/lesser/stok/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/unathi)
	tts_seed = "Witchdoctor"
