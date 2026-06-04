/datum/action/changeling/augmented_eyesight
	name = "Продвинутое зрение"
	desc = "Создаёт тепловые рецепторы и светочувствительные мембраны в наших глазах."
	helptext = "Рецепторы дают нам видеть во тьме и улавливать тепло, но делает нас уязвимыми ко вспышкам, а мембраны защищают от вспышек и лечат поврежения глаз. Они видны на сканерах. Можно использовать в низшей форме."
	dna_cost = 1
	button_icon_state = "augmented_eyesight"
	power_type = CHANGELING_PURCHASABLE_POWER

/datum/action/changeling/augmented_eyesight/on_purchase(mob/user, /datum/antagonist/changeling/antag)
	if(!..())
		return FALSE

	var/obj/item/organ/internal/cyberimp/eyes/shield/ling/eyes = new(null)
	eyes.insert(user)

/datum/action/changeling/augmented_eyesight/sting_action(mob/living/carbon/user)
	if(!istype(user))
		return FALSE

	var/obj/item/organ/internal/cyberimp/eyes/eyes
	if(active)
		eyes = new /obj/item/organ/internal/cyberimp/eyes/shield/ling(null)
		user.balloon_alert(user, "защитные мембраны")
		active = FALSE
	else
		eyes = new /obj/item/organ/internal/cyberimp/eyes/thermals/ling(null)
		user.balloon_alert(user, "тепловые рецепторы")
		active = TRUE

	eyes.insert(user)
	return TRUE

/obj/item/organ/internal/cyberimp/eyes/shield/ling
	name = "protective membranes"
	desc = "Эти защитные мембраны с переменной прозрачностью защитят вас от сварочных работ и вспышек, а также помогут восстановить поврежденные глаза."
	icon_state = "ling_eyeshield"
	implant_overlay = null
	slot = INTERNAL_ORGAN_EYE_LING
	status = NONE
	aug_message = "Мембраны приспосабливаются для защиты глаз от яркого света."

/obj/item/organ/internal/cyberimp/eyes/shield/ling/get_ru_names()
	return alist(
		NOMINATIVE = "защитные мембраны",
		GENITIVE = "защитных мембран",
		DATIVE = "защитным мембранам",
		ACCUSATIVE = "защитные мембраны",
		INSTRUMENTAL = "защитными мембранами",
		PREPOSITIONAL = "защитных мембранах",
	)

/obj/item/organ/internal/cyberimp/eyes/shield/ling/emp_act(severity)
	return

/obj/item/organ/internal/cyberimp/eyes/shield/ling/on_life()
	if(!QDELETED(owner))
		return

	var/update_flags = STATUS_UPDATE_NONE

	var/obj/item/organ/internal/eyes/eyes = owner.get_int_organ(/obj/item/organ/internal/eyes)
	if(owner.AmountBlinded() || owner.AmountEyeBlurry() || (eyes?.damage > 0))
		owner.reagents.add_reagent("oculine", 1)

	if(HAS_TRAIT(owner, TRAIT_NEARSIGHTED) || HAS_TRAIT(owner, TRAIT_BLIND))
		update_flags |= owner.CureNearsighted()
		update_flags |= owner.CureBlind()
		owner.SetEyeBlind(0)

	return ..() | update_flags

/obj/item/organ/internal/cyberimp/eyes/shield/ling/prepare_eat()
	var/obj/object = ..()
	object.reagents.add_reagent("oculine", 15)
	return object

/obj/item/organ/internal/cyberimp/eyes/thermals/ling
	name = "heat receptors"
	desc = "Эти тепловые рецепторы повысят вашу чувствительность к световому и тепловому излучению."
	icon_state = "ling_thermal"
	eye_colour = "#000000"
	implant_overlay = null
	slot = INTERNAL_ORGAN_EYE_LING
	status = NONE
	aug_message = "Рецепторы фокусируются и позволяют нам лучше видеть в темноте и сквозь препятствия."

/obj/item/organ/internal/cyberimp/eyes/thermals/ling/get_ru_names()
	return alist(
		NOMINATIVE = "тепловые рецепторы",
		GENITIVE = "тепловых рецепторов",
		DATIVE = "тепловым рецепторам",
		ACCUSATIVE = "тепловые рецепторы",
		INSTRUMENTAL = "тепловыми рецепторами",
		PREPOSITIONAL = "тепловых рецепторах",
	)

/obj/item/organ/internal/cyberimp/eyes/thermals/ling/emp_act(severity)
	return

/obj/item/organ/internal/cyberimp/eyes/thermals/ling/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/h_owner = owner
		h_owner.weakeyes = TRUE
		if(!h_owner.vision_type)
			h_owner.set_vision_override(/datum/vision_override/nightvision)

/obj/item/organ/internal/cyberimp/eyes/thermals/ling/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	if(ishuman(owner))
		var/mob/living/carbon/human/h_owner = owner
		h_owner.weakeyes = FALSE
		h_owner.set_vision_override(null)
	. = ..()
