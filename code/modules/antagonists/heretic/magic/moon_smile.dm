/datum/action/cooldown/spell/pointed/moon_smile
	name = "Улыбка Луны"
	desc = "Позволяет обратить на кого-то взгляд луны, кликнув по нему. \
			Временно ослепляет, заглушает и ошеломляет одну цель."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "moon_smile"
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'sound/magic/blind.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND
	invocation = "Л'НН УЛ'БК!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	cast_range = 6

	active_msg = "Вы готовы позволить им увидеть истинное лицо луны..."


/datum/action/cooldown/spell/pointed/moon_smile/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)


/datum/action/cooldown/spell/pointed/moon_smile/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)


/datum/action/cooldown/spell/pointed/moon_smile/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(!istype(cast_on))
		return FALSE

	var/moon_smile_duration = 15 SECONDS
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("Луна отворачивается, и её улыбка больше не обращена к вам."))
		to_chat(owner, span_warning("Луна не желает улыбаться."))
		return FALSE

	playsound(cast_on, 'sound/hallucinations/i_see_you1.ogg', 50, 1)
	to_chat(cast_on, span_warning("Слёзы текут из ваших глаз! Ваши уши кровоточат, а губы слипаются! \
									ЛУНА УЛЫБАЕТСЯ ВАМ!"))
	cast_on.EyeBlind(moon_smile_duration + 1 SECONDS)
	cast_on.EyeBlurry(moon_smile_duration + 2 SECONDS)

	cast_on.adjustOrganLoss(INTERNAL_ORGAN_EARS, 10)
	cast_on.Silence(moon_smile_duration + 1 SECONDS)
	return TRUE
