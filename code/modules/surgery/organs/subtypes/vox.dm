/obj/item/organ/internal/liver/vox
	species_type = /datum/species/vox
	name = "vox liver"
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_liver"
	alcohol_intensity = 1.6
	sterile = TRUE

/obj/item/organ/internal/eyes/vox
	species_type = /datum/species/vox
	name = "vox eyeballs"
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_eyes"
	sterile = TRUE

/obj/item/organ/internal/heart/vox
	species_type = /datum/species/vox
	name = "vox heart"
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_heart-on"
	item_base = "vox_heart"
	sterile = TRUE

/obj/item/organ/internal/brain/vox
	species_type = /datum/species/vox
	name = "cortical stack"
	desc = "A peculiarly advanced bio-electronic device that seems to hold the memories and identity of a Vox."
	icon = 'icons/obj/species_organs/vox.dmi'
	icon_state = "cortical-stack"
	item_state = "vox_cortical-stack"
	mmi_icon = 'icons/obj/species_organs/vox.dmi'
	mmi_icon_state = "mmi_full"
	sterile = TRUE

/obj/item/organ/internal/kidneys/vox
	species_type = /datum/species/vox
	name = "vox kidneys"
	icon = 'icons/obj/species_organs/vox.dmi'
	item_state = "vox_kidneys"
	sterile = TRUE

/obj/item/organ/internal/lungs/vox
	name = "Vox lungs"
	desc = "They're filled with dust....wow."
	icon = 'icons/obj/species_organs/vox.dmi'
	icon_state = "lungs"
	item_state = "vox_lungs"

	safe_oxygen_min = 0 //We don't breathe this
	safe_oxygen_max = 0.05 //This is toxic to us
	safe_nitro_min = 16 //We breathe THIS!
	oxy_damage_type = TOX //And it poisons us

/obj/item/organ/external/tail/vox
	species_type = /datum/species/vox
	name = "vox tail"
	icon_name = "voxtail_s"
	max_damage = 25
	min_broken_damage = 20
