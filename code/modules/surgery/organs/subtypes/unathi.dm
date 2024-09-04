/obj/item/organ/internal/liver/unathi
	species_type = /datum/species/unathi
	name = "unathi liver"
	icon = 'icons/obj/species_organs/unathi.dmi'
	desc = "A large looking liver."
	alcohol_intensity = 0.8

/obj/item/organ/internal/eyes/unathi
	species_type = /datum/species/unathi
	name = "unathi eyeballs"
	icon = 'icons/obj/species_organs/unathi.dmi'
	see_in_dark = 3

/obj/item/organ/internal/heart/unathi
	species_type = /datum/species/unathi
	name = "unathi heart"
	desc = "A large looking heart."
	icon = 'icons/obj/species_organs/unathi.dmi'

/obj/item/organ/internal/brain/unathi
	species_type = /datum/species/unathi
	icon = 'icons/obj/species_organs/unathi.dmi'
	desc = "A smallish looking brain."
	icon_state = "brain2"
	mmi_icon = 'icons/obj/species_organs/unathi.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/lungs/unathi
	species_type = /datum/species/unathi
	name = "unathi lungs"
	icon = 'icons/obj/species_organs/unathi.dmi'

/obj/item/organ/internal/kidneys/unathi
	species_type = /datum/species/unathi
	name = "unathi kidneys"
	icon = 'icons/obj/species_organs/unathi.dmi'

/obj/item/organ/external/tail/unathi
	species_type = /datum/species/unathi
	name = "unathi tail"
	icon_name = "sogtail_s"
	max_damage = 30
	min_broken_damage = 20

/obj/item/organ/internal/lungs/unathi/ash_walker
	name = "ash walker lungs"
	safe_oxygen_min = 8 // can breathe on lavaland

/obj/item/organ/internal/eyes/unathi/ash_walker
	name = "ash walker eyes"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	see_in_dark = 3

/obj/item/organ/internal/eyes/unathi/ash_walker_shaman
	name = "ash walker shaman eyes"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/organ/internal/eyes/unathi/ash_walker_shaman/insert(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(target)

/obj/item/organ/internal/eyes/unathi/ash_walker_shaman/remove(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.remove_hud_from(target)
