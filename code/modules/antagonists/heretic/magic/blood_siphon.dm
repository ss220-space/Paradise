/datum/action/cooldown/spell/pointed/blood_siphon
	name = "Вампиризм"
	desc = "Заклинание, которое лечит ваши раны и наносит урон врагу. \
			Есть вероятность, что серьёзные повреждения (вроде переломов) \
			также смогут передаться."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "blood_siphon"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "В'МП'Р'ЗМ"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 6


/datum/action/cooldown/spell/pointed/blood_siphon/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)


/datum/action/cooldown/spell/pointed/blood_siphon/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on)


/datum/action/cooldown/spell/pointed/blood_siphon/cast(mob/living/cast_on)
	. = ..()
	playsound(owner, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(cast_on.can_block_magic())
		owner.balloon_alert(owner, "spell blocked!")
		cast_on.visible_message(
			span_danger("[DECLENT_RU_CAP(cast_on, NOMINATIVE)] отражает заклинание!"),
			span_danger("Заклинание отскакивает от вас!"),
		)
		return FALSE

	cast_on.visible_message(
		span_danger("[DECLENT_RU_CAP(cast_on, NOMINATIVE)] бледне[PLUR_ET_YUT(cast_on)], охваченн[GEND_YI_AYA_OE_YE(cast_on)] алым сиянием!"),
		span_danger("Вы бледнеете, когда вас окутывает алое сияние!"),
	)

	var/mob/living/living_owner = owner
	cast_on.adjustBruteLoss(20)
	living_owner.adjustBruteLoss(-20)

	if(!cast_on.blood_volume || !living_owner.blood_volume)
		return TRUE

	cast_on.blood_volume -= 20
	if(living_owner.blood_volume < BLOOD_VOLUME_MAXIMUM) // we dont want to explode from casting
		living_owner.blood_volume += 20

	if(!ishuman(cast_on) || !ishuman(owner))
		return TRUE

	var/mob/living/carbon/human/human_user = owner
	var/mob/living/carbon/human/human_target = cast_on
	for(var/obj/item/organ/external/bodypart as anything in human_user.bodyparts)
		if(prob(50) && bodypart.has_internal_bleeding())
			bodypart.stop_internal_bleeding()
			var/obj/item/organ/external/targ_bodypart = pick(human_target.bodyparts)
			targ_bodypart.internal_bleeding()

		if(prob(50) && bodypart.has_fracture())
			bodypart.mend_fracture()
			var/obj/item/organ/external/targ_bodypart = pick(human_target.bodyparts)
			targ_bodypart.fracture()

	return TRUE
