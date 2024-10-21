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

/obj/item/organ/internal/liver/drask
	species_type = /datum/species/drask
	name = "metabolic strainer"
	icon = 'icons/obj/species_organs/drask.dmi'
	icon_state = "kidneys"
	alcohol_intensity = 0.8

/obj/item/organ/internal/liver/drask/insert(mob/living/carbon/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()

	if(!.)
		return FALSE

	var/datum/action/innate/drask_coma/coma = new
	coma.Grant(owner)

/obj/item/organ/internal/liver/drask/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT)
	var/datum/action/innate/drask_coma/coma = locate() in owner.actions
	coma?.Remove(owner)

	return ..()

/datum/action/innate/drask_coma
	name = "Enter coma"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/drask_coma/activate()
	if(owner.has_status_effect(STATUS_EFFECT_DRASK_COMA))
		owner.remove_status_effect(STATUS_EFFECT_DRASK_COMA)
		return

	owner.apply_status_effect(STATUS_EFFECT_DRASK_COMA)
	

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
