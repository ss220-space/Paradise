//DRASK ORGAN
/obj/item/organ/internal/drask
	species_type = /datum/species/drask
	name = "drask organ"
	icon = 'icons/obj/species_organs/drask.dmi'
	icon_state = "innards"
	desc = "A greenish, slightly translucent organ. It is extremely cold."

/obj/item/organ/internal/heart/drask
	species_type = /datum/species/drask
	name = "drask heart"
	icon = 'icons/obj/species_organs/drask.dmi'
	parent_organ_zone = BODY_ZONE_HEAD
	organ_actions = list(/datum/action/innate/drask_coma)

/obj/item/organ/internal/liver/drask
	species_type = /datum/species/drask
	name = "metabolic strainer"
	icon = 'icons/obj/species_organs/drask.dmi'
	icon_state = "kidneys"
	alcohol_intensity = 0.8

/obj/item/organ/internal/brain/drask
	species_type = /datum/species/drask
	icon = 'icons/obj/species_organs/drask.dmi'
	icon_state = "brain2"
	mmi_icon = 'icons/obj/species_organs/drask.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/eyes/drask
	species_type = /datum/species/drask
	name = "drask eyeballs"
	icon = 'icons/obj/species_organs/drask.dmi'
	desc = "Drask eyes. They look even stranger disembodied."
	see_in_dark = 5

/datum/action/innate/drask_coma
	name = "Enter coma"
	desc = "Постепенно останавливает метаболизм, понижает температуру тела и заставляет уснуть на некоторое время."

	check_flags = AB_CHECK_CONSCIOUS

	button_icon = 'icons/obj/species_organs/drask.dmi'
	button_icon_state = "heart_on"

/datum/action/innate/drask_coma/activate()
	. = TRUE

	if(owner.has_status_effect(STATUS_EFFECT_DRASK_COMA))
		owner.remove_status_effect(STATUS_EFFECT_DRASK_COMA)
		. = FALSE

	if(.)
		owner.apply_status_effect(STATUS_EFFECT_DRASK_COMA)

	UpdateButtonIcon()

/datum/action/innate/drask_coma/UpdateButtonIcon()
	button_icon_state = owner.has_status_effect(STATUS_EFFECT_DRASK_COMA) ? "heart_off" : initial(button_icon_state)
	return ..()
