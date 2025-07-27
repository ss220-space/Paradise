/obj/effect/proc_holder/spell/pointed/moon_smile
	name = "Лунная улыбка"
	desc = "Позволяет обратить на кого-то взгляд луны. \
			Временно ослепляет, заглушает, не даёт говорить и ошеломляет одну цель."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "moon_smile"
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'sound/magic/blind.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 20 SECONDS
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND
	invocation = "Л'НН УЛ'БК!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	cast_range = 6

	active_msg = "Вы готовы позволить им увидеть истинное лицо луны..."


/obj/effect/proc_holder/spell/pointed/moon_smile/can_cast(feedback = TRUE)
	return ..() && isliving(action.owner)


/obj/effect/proc_holder/spell/pointed/moon_smile/valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)


/obj/effect/proc_holder/spell/pointed/moon_smile/cast(list/targets)
	. = ..()
	var/mob/living/carbon/human/cast_on = targets[1]
	if(!istype(cast_on))
		return FALSE

	var/moon_smile_duration = 15 SECONDS
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("Луна отворачивается, и ее улыбка больше не обращена к вам."))
		to_chat(action.owner, span_warning("Луна не желает улыбаться."))
		return FALSE

	playsound(cast_on, 'sound/hallucinations/i_see_you1.ogg', 50, 1)
	to_chat(cast_on, span_warning("Слёзы текут из ваших глаз! Ваши уши кровоточат, а губы слипаются! \
									ЛУНА УЛЫБАЕТСЯ ВАМ!"))
	cast_on.EyeBlind(moon_smile_duration + 1 SECONDS)
	cast_on.EyeBlurry(moon_smile_duration + 2 SECONDS)

	cast_on.adjustOrganLoss(INTERNAL_ORGAN_EARS, 10)
	cast_on.Silence(moon_smile_duration + 1 SECONDS)
	return TRUE
