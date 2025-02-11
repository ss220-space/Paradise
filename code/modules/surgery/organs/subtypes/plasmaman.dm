/obj/item/organ/internal/liver/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman liver"
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_liver"

/obj/item/organ/internal/eyes/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman eyeballs"
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_eyes"

/obj/item/organ/internal/heart/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman heart"
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_heart-on"
	item_base = "plasmaman_heart"

/obj/item/organ/internal/brain/plasmaman
	species_type = /datum/species/plasmaman
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	icon_state = "brain2"
	item_state = "plasmaman_brain"
	mmi_icon = 'icons/obj/species_organs/plasmaman.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/kidneys/plasmaman
	species_type = /datum/species/plasmaman
	name = "plasmaman kidneys"
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	item_state = "plasmaman_kidneys"

/obj/item/organ/internal/lungs/plasmaman
	name = "plasma filter"
	desc = "A spongy rib-shaped mass for filtering plasma from the air."
	icon = 'icons/obj/species_organs/plasmaman.dmi'
	icon_state = "lungs"
	item_state = "plasmaman_lungs"
	safe_oxygen_min = 0 //We don't breath this
	safe_toxins_min = 16 //We breathe THIS!
	safe_toxins_max = 0
