/obj/effect/proc_holder/spell/pointed/mind_gate
	name = "Врата разума"
	desc = "Вызывает у цели галлюцинации, ошеломление на 10 секунд, удушие и повреждения мозга. \
			Наносит вашему мозгу 20 единиц урона за каждое использование."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mind_gate"

	sound = 'sound/magic/curse.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 20 SECONDS

	invocation = "ТКР'Й СВ'Й Р'З'М"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	cast_range = 6

	active_msg = "Вы подготовились открыть свой разум..."


/obj/effect/proc_holder/spell/pointed/mind_gate/can_cast(feedback = TRUE)
	return ..() && isliving(action.owner)


/obj/effect/proc_holder/spell/pointed/mind_gate/valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)


/obj/effect/proc_holder/spell/pointed/mind_gate/cast(list/targets)
	var/mob/living/carbon/human/cast_on = targets[1]
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("Вы внезапно чувствуете что ваш разум закрыт. К чему бы это?"))
		to_chat(action.owner, span_warning("Разум жертвы не смог раскрыться, ровно как и ваш."))
		return FALSE

	cast_on.Confused(20 SECONDS)
	cast_on.EyeBlurry(10 SECONDS)
	cast_on.Druggy(10 SECONDS)
	cast_on.Slur(10 SECONDS)
	cast_on.Jitter(10 SECONDS)
	cast_on.adjustOxyLoss(60)
	cast_on.Hallucinate(120 SECONDS)
	cast_on.cause_hallucination(/datum/hallucination/delusion/preset/heretic/gate, "Эффект Врат Разума")
	cast_on.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 30)

	var/mob/living/living_owner = action.owner
	living_owner.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 10, 140)
