/mob/living/carbon/human/monkey
	var/mob/living/carbon/human/master_commander = null //переменная хранящая владельца "животного"

/mob/living/carbon/human/monkey/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey)

/mob/living/carbon/human/farwa/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/tajaran)

/mob/living/carbon/human/wolpin/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/vulpkanin)

/mob/living/carbon/human/neara/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/skrell)

/mob/living/carbon/human/stok/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/unathi)
