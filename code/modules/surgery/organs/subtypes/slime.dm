/obj/item/organ/internal/heart/slime
	species_type = /datum/species/slime
	icon = 'icons/obj/species_organs/slime.dmi'
	name = "slime heart"
	icon_state = "heart"
	item_state = "slime_heart"
	desc = "This is a slime's osmotic pressure regulator, it appears to be some kind of biological pump that uses osmotic pressure to regulate water flow. It seems to work similar to a heart."
	dead_icon = null

/obj/item/organ/internal/heart/slime/update_icon_state()
	return

/obj/item/organ/internal/lungs/slime
	species_type = /datum/species/slime
	icon = 'icons/obj/species_organs/slime.dmi'
	name = "slime lungs"
	icon_state = "lungs"
	item_state = "slime_lungs"
	desc = "This is a slime's gas exchange membrane, this membrane used for oxygen intake and gas exchange. These seem to work similar to lungs."

/obj/item/organ/internal/brain/slime
	species_type = /datum/species/slime
	name = "slime core"
	desc = "A complex, organic knot of jelly and crystalline particles."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "green slime extract"
	mmi_icon_state = "slime_mmi"
	parent_organ_zone = BODY_ZONE_CHEST
