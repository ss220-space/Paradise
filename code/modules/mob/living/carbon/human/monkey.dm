/mob/living/carbon/human/lesser
	var/master_commander = null //переменная хранящая владельца "животного"
	fire_dmi = 'icons/mob/species/monkey/OnFire.dmi'
	genetic_mutable = 'icons/mob/species/monkey/genetics.dmi'
	var/sentience_type = SENTIENCE_ORGANIC

/mob/living/carbon/human/lesser/monkey/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey)
	tts_seed = "sniper"

/mob/living/carbon/human/lesser/farwa/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/tajaran)
	tts_seed = "gyro"

/mob/living/carbon/human/lesser/wolpin/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/vulpkanin)
	tts_seed = "bloodseeker"

/mob/living/carbon/human/lesser/neara/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/skrell)
	tts_seed = "bounty"

/mob/living/carbon/human/lesser/stok/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/unathi)
	tts_seed = "witchdoctor"

/mob/living/carbon/human/lesser/slip(description, stun, weaken, tilesSlipped, walkSafely, slipAny, slipVerb = "поскользнулись")
	. = ..()
	if(prob(50))
		unEquip(shoes, 1)
