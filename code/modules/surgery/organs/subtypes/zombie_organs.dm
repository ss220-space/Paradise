/obj/item/organ/internal/zombietumor
	name = "necrotic tumor"
	desc = "Крошечное скопление дурно пахнущих грибов, которые питаются мозговым веществом и управляют им."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "chanterelle"
	w_class = WEIGHT_CLASS_TINY
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_BRAIN_TUMOR
	destroy_on_removal = TRUE

/obj/item/organ/internal/zombietumor/get_ru_names()
	return alist(
		NOMINATIVE = "некротическая опухоль",
		GENITIVE = "некротической опухоли",
		DATIVE = "некротической опухоли",
		ACCUSATIVE = "некротическую опухоль",
		INSTRUMENTAL = "некротической опухолью",
		PREPOSITIONAL = "некротической опухоли",
	)

/obj/item/organ/internal/zombietumor/remove(mob/living/carbon/target, special = 0)
	for(var/datum/disease/virus/zombie/disease in target?.diseases)
		disease.cure(need_immunity = FALSE)
	var/mob/living/carbon/human/human = target
	for(var/obj/item/organ/limb as anything in human?.bodyparts)
		if(limb.status & ORGAN_DEAD && !limb.is_robotic())
			limb.status &= ~ORGAN_DEAD
	human?.update_body()
	return ..()
