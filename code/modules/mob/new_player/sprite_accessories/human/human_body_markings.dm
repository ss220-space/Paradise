/datum/sprite_accessory/body_markings/none
	name = "None"
	species_allowed = list(SPECIES_HUMAN, "Unathi", SPECIES_DIONA, "Grey", SPECIES_MACNINEPERSON, "Tajaran", "Vulpkanin", "Skrell", "Slime People", SPECIES_SKELETON, "Vox", SPECIES_KIDAN)
	icon_state = "none"

/datum/sprite_accessory/body_markings/tiger
	name = "Tiger Body"
	species_allowed = list("Unathi", "Tajaran", "Vulpkanin")
	icon_state = "tiger"

/datum/sprite_accessory/body_markings/tattoo // Tattoos applied post-round startup with tattoo guns in item_defines.dm
	species_allowed = list(SPECIES_HUMAN, "Unathi", "Vulpkanin", "Tajaran", "Skrell")
	icon_state = "none"

/datum/sprite_accessory/body_markings/tattoo/elliot
	name = "Elliot Circuit Tattoo"
	icon_state = "campbell"
	species_allowed = null

/datum/sprite_accessory/body_markings/tattoo/tiger_body // Yep, this is repeated. To be fixed later
	name = "Tiger-stripe Tattoo"
	species_allowed = list(SPECIES_HUMAN, "Unathi", "Vulpkanin", "Tajaran", "Skrell")
	icon_state = "tiger"

/datum/sprite_accessory/body_markings/tattoo/heart
	name = "Heart Tattoo"
	icon_state = "heart"

/datum/sprite_accessory/body_markings/tattoo/hive
	name = "Hive Tattoo"
	icon_state = "hive"

/datum/sprite_accessory/body_markings/tattoo/nightling
	name = "Nightling Tattoo"
	icon_state = "nightling"

/datum/sprite_accessory/body_markings/heterochromia
	name = "Heterochromia"
	species_allowed = list(SPECIES_HUMAN)
	icon_state = "heterochromia"

/datum/sprite_accessory/body_markings/eyebrows
	name = "Eyebrows"
	species_allowed = list(SPECIES_HUMAN)
	icon_state = "eyebrows"

/datum/sprite_accessory/body_markings/mono_eyebrows
	name = "Monobrows"
	species_allowed = list(SPECIES_HUMAN)
	icon_state = "mono_eyebrows"
