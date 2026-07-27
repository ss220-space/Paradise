/obj/effect/proc_holder/spell/pointed/blind
	name = "Слепота"
	desc = "Это заклинание временно ослепляет одну цель."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "eye"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	sound = 'sound/magic/blind.ogg'
	school = SCHOOL_TRANSMUTATION
	base_cooldown = 30 SECONDS

	invocation = "СТ' К'Л'!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	active_msg = "Вы готовитесь ослепить цель..."

	/// The amount of blindness to apply.
	var/eye_blind_duration = 20 SECONDS
	/// The amount of blurriness to apply.
	var/eye_blur_duration = 40 SECONDS


/obj/effect/proc_holder/spell/pointed/blind/valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE

	var/mob/living/carbon/human/human_target = cast_on
	return !human_target.is_blind()


/obj/effect/proc_holder/spell/pointed/blind/cast(list/targets, mob/user = usr)
	. = ..()
	var/mob/living/carbon/human/cast_on = targets[1]
	if(!istype(cast_on))
		return FALSE

	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("Ваш глаз зудит, но это быстро проходит."))
		to_chat(action.owner, span_warning("Заклинание не возымело эффекта!"))
		return FALSE

	to_chat(cast_on, span_warning("Ваши глаза вспыхивают болью!"))
	cast_on.EyeBlind(eye_blind_duration)
	cast_on.EyeBlurry(eye_blur_duration)
	return TRUE


/obj/effect/proc_holder/spell/pointed/blind/eldritch
	name = "Жуткая Слепота"
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	invocation = "ГЛ'З"

	cast_range = 10
