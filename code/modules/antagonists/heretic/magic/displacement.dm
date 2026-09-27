
/datum/action/cooldown/spell/pointed/displacement
	name = "Смещение"
	desc = "Вырывает выбранного противника из пространства на восемь секунд. \
			Следующее его осознанное действие уйдёт в изнанку и оставит после себя Разлом. \
			Если за это время цель ничего не предпримет, эффект спадёт без последствий."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "displacement"

	sound = 'sound/effects/phasein.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "СМ'Щ'Н'!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	active_msg = "Вы нащупываете нить, которой цель держится за мир..."


/datum/action/cooldown/spell/pointed/displacement/is_valid_target(atom/cast_on)
	if(!isliving(cast_on) || cast_on == owner)
		return FALSE
	var/mob/living/living_target = cast_on
	return !IS_HERETIC_OR_MONSTER(living_target)


/datum/action/cooldown/spell/pointed/displacement/cast(mob/living/cast_on)
	. = ..()
	var/mob/living/caster = owner
	if(!caster || !isliving(cast_on))
		return FALSE

	if(cast_on.can_block_magic(MAGIC_RESISTANCE))
		to_chat(caster, span_warning("Связь [cast_on.declent_ru(GENITIVE)] с миром защищена!"))
		return FALSE

	cast_on.apply_status_effect(/datum/status_effect/displacement, caster)
	return TRUE
