/datum/action/cooldown/spell/pointed/mind_gate
	name = "Врата Разума"
	desc = "Вызывает у цели галлюцинации, ошеломление на 10 секунд, удушье и повреждения мозга. \
			Наносит вашему мозгу 20 единиц урона за каждое использование."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mind_gate"

	sound = 'sound/magic/curse.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS

	invocation = "ТКР'Й СВ'Й Р'З'М"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	cast_range = 6

	active_msg = "Вы подготовились открыть свой разум..."


/datum/action/cooldown/spell/pointed/mind_gate/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)


/datum/action/cooldown/spell/pointed/mind_gate/is_valid_target(atom/cast_on)
	if(!ishuman(cast_on))
		cast_on?.balloon_alert(owner, "нет разума!")
		return FALSE
	return ..()


/datum/action/cooldown/spell/pointed/mind_gate/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("Вы внезапно чувствуете, что ваш разум закрыт. К чему бы это?"))
		to_chat(owner, span_warning("Разум жертвы не смог раскрыться, ровно как и ваш."))
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
	to_chat(cast_on, span_warning("Ваши глаза кричат от боли, уши кровоточат, а губы немеют! ЛУНА УЛЫБАЕТСЯ ВАМ!"))

	var/mob/living/living_owner = owner
	if(living_owner)
		living_owner.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 20, 140) // Caster takes brain damage per cast too.
